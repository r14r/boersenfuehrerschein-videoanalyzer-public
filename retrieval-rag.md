---
layout: default
title: Retrieval & RAG
permalink: /retrieval-rag
---

# Retrieval & RAG

RAG ist im Video Analyzer keine reine Vektorsuche. Der produktive Pfad kombiniert **lexikalisches Retrieval über SQLite FTS5** mit **semantischem Retrieval über Embeddings** und fusioniert beide Ranglisten zu einer gemeinsamen, quellengenauen Ergebnisliste.

![Hybrid Retrieval]({{ '/assets/images/retrieval.svg' | relative_url }}){: .diagram }

## Canonical Source Record

Jeder aktive Transcript-Satz wird als kanonische Citation Source persistiert:

~~~json
{
  "source_id": "video_abc:s000127",
  "transcript_job_id": "9d5c30e2a712",
  "video_id": "video_abc",
  "sentence_id": "s000127",
  "speaker": "Sprecher 1",
  "start": 761.2,
  "end": 769.9,
  "text": "Das Kurs-Umsatz-Verhältnis eignet sich insbesondere ..."
}
~~~

Die stabile Source-ID hängt von Video und Satz ab, nicht vom LLM.

## Zwei Ebenen: Citation Unit und Context Window

Die aktuelle Retrieval-Architektur trennt bewusst zwei Dinge:

### Citation Unit

Die Citation Unit ist der **eine konkrete Transcript-Satz**, der später in Antwort und UI referenziert wird.

Sie besitzt:

- stabile `source_id`
- `speaker`
- exakten Start-/Endzeitpunkt
- Originaltext

Diese Einheit ist klein, präzise und direkt abspielbar.

### Context Window

Für semantisches Retrieval ist ein einzelner Satz oft zu kurz. Ein Satz wie:

> „Das ist besonders interessant.“

ist ohne Nachbarsätze kaum interpretierbar.

Deshalb erzeugt das System pro Citation Unit ein **zentriertes Context Window**. Standardmäßig werden zwei Sätze davor und zwei danach einbezogen:

~~~text
s125
s126
[s127]  ← Citation Unit
s128
s129
~~~

Bei `RAG_CONTEXT_RADIUS=2` enthält das semantische Fenster also maximal fünf Sätze.

Das Embedding wird aus dem Context Window erzeugt, die Source-ID bleibt jedoch die des zentralen Satzes:

~~~text
Embedding input:
Sprecher 1: Bei Wachstumsaktien ist der Umsatz besonders relevant.
Sprecher 1: Das KGV ist hier häufig wenig aussagekräftig.
Sprecher 1: Das Kurs-Umsatz-Verhältnis eignet sich insbesondere ...
Sprecher 2: Dabei muss das Wachstum berücksichtigt werden.
Sprecher 1: Ein isolierter Kennzahlenvergleich reicht nicht aus.

Citation:
video_abc:s000127
00:12:41.200–00:12:49.900
~~~

Damit verbessert sich die semantische Qualität, ohne die präzise Quellenreferenz zu verlieren.

## Warum nicht das ganze Context Window zitieren?

Weil Retrieval und Zitation unterschiedliche Anforderungen haben:

| Ebene | Ziel |
|---|---|
| Context Window | Bedeutung und semantische Ähnlichkeit verstehen |
| Citation Unit | konkrete Aussage exakt referenzieren |
| Playback | exakte Stelle im Video öffnen |

Würde das gesamte Fenster zur Citation Unit, wären Quellenkarten und Playback unnötig breit und unpräzise.

## Context Window Metadaten

Ein semantischer Treffer besitzt intern zusätzlich:

~~~json
{
  "context_source_ids": [
    "video_abc:s000125",
    "video_abc:s000126",
    "video_abc:s000127",
    "video_abc:s000128",
    "video_abc:s000129"
  ],
  "context_start": 748.8,
  "context_end": 781.4,
  "context_radius": 2
}
~~~

Der eigentliche Context-Text bleibt intern und wird nicht unnötig in Chat-Sessions dupliziert. Öffentlich werden nur kompakte Provenienz-Metadaten wie Satzanzahl und Context-Zeitbereich ausgegeben.

## FTS5

SQLite FTS5 ist die autoritative lexikalische Suche für Eigennamen, Abkürzungen, Kennzahlen, exakte Formulierungen und Locate-Fragen wie „Wo wird NVIDIA erwähnt?“.

Natürlich formulierte Fragen werden normalisiert:

~~~text
Wo wird das Kurs-Umsatz-Verhältnis erwähnt?
          ↓
Kurs AND Umsatz AND Verhältnis
~~~

## Semantische Suche

Embeddings arbeiten ab RAG-Schema v4 mit den beschriebenen Context Windows. Dadurch kann auch der Kontext um einen kurzen oder mehrdeutigen Satz in die Ähnlichkeitsbewertung einfließen.

## Hybrid Retrieval

Die Fusion verwendet **Weighted Reciprocal Rank Fusion (RRF)**:

~~~text
RRF(source) =
  lexical_weight  / (k + lexical_rank)
+ semantic_weight / (k + semantic_rank)
~~~

Aktuell wird `k = 60` verwendet.

### Locate Queries

Für Fundstellenfragen gilt:

~~~text
lexical_weight  = 1.35
semantic_weight = 0.75
~~~

Analyse-Artefakte werden bei Locate-Fragen entfernt. „Wo wird XY erwähnt?“ soll auf Primärquellen im Transkript zeigen.

### Knowledge Queries

Für normale Wissensfragen werden lexikalische und semantische Treffer gleichwertiger fusioniert.

## Warum FTS und Semantic Treffer weiterhin fusionierbar sind

Der zentrale Designpunkt ist:

> Auch ein semantischer Context-Window-Treffer behält die Source-ID der zentralen Citation Unit.

Damit können FTS und Embedding-Retrieval denselben Satz unter derselben ID treffen:

~~~text
FTS:
video_abc:s000127

Semantic Context Window:
video_abc:s000127

            ↓

Hybrid Merge:
video_abc:s000127
~~~

Es ist kein nachträgliches heuristisches Mapping erforderlich.

## Konfiguration

~~~bash
RAG_CONTEXT_RADIUS=2
~~~

Bedeutung:

| Wert | Fenster |
|---:|---|
| 0 | nur Citation-Satz |
| 1 | 1 vorher + Citation + 1 nachher |
| 2 | 2 vorher + Citation + 2 nachher |
| 3 | 3 vorher + Citation + 3 nachher |

Der Wert ist aktuell auf maximal 6 begrenzt.

Eine Änderung dieser Logik verwendet RAG-Index-Schema v4 und führt beim nächsten Sync zu einem Rebuild inkompatibler älterer Embeddings.

## Fehlerfall und Fallback

Wenn das Embedding-Modell nicht verfügbar ist, fällt das System auf FTS5 zurück. Die Source-Provenienz bleibt erhalten.

## Diagnose

Hybrid Search:

~~~http
GET /api/retrieval/hybrid-search?q=Wo%20wird%20NVIDIA%20erwähnt%3F&limit=20
~~~

RAG-Status:

~~~http
GET /api/admin/rag/status
~~~

Der Status enthält unter anderem `schema_version` und `context_radius`.

## Rebuildability

FTS und Embeddings sind abgeleitete Daten. Der semantische Index kann vollständig aus dem kanonischen Transcript neu aufgebaut werden.
