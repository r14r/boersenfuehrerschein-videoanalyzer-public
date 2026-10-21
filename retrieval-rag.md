---
layout: default
title: Retrieval & RAG
permalink: /retrieval-rag
---

# Retrieval & RAG

RAG ist im Video Analyzer keine reine Vektorsuche. Der produktive Pfad kombiniert **lexikalisches Retrieval über SQLite FTS5** mit **semantischem Retrieval über Embeddings** und fusioniert beide Ranglisten zu einer gemeinsamen, quellengenauen Ergebnisliste.

![Hybrid Retrieval]({{ '/assets/images/retrieval.svg' | relative_url }}){: .diagram }

## Canonical Source Record

Jeder aktive Transcript-Satz wird als kanonische Source persistiert:

~~~json
{
  "source_id": "video_abc:s000127",
  "transcript_job_id": "9d5c30e2a712",
  "video_id": "video_abc",
  "sentence_id": "s000127",
  "speaker": "Sprecher 1",
  "start": 761.2,
  "end": 769.9,
  "text": "Das Kurs-Umsatz-Verhältnis eignet sich insbesondere ...",
  "content_hash": "..."
}
~~~

Die stabile Source-ID hängt von Video und Satz ab, nicht vom LLM. Der jeweils neueste abgeschlossene Transkriptionsjob eines Videos stellt den aktiven Retrieval-Bestand.

## FTS5

SQLite FTS5 ist die autoritative lexikalische Suche für Eigennamen, Abkürzungen, Kennzahlen, exakte Formulierungen und Locate-Fragen wie „Wo wird NVIDIA erwähnt?“.

Natürlich formulierte Fragen werden vor dem FTS-Match normalisiert. Typische Funktionswörter und Locate-Formulierungen wie „wo“, „wird“, „erwähnt“, „where“ oder „mentioned“ werden entfernt.

~~~text
Wo wird das Kurs-Umsatz-Verhältnis erwähnt?
          ↓
Kurs AND Umsatz AND Verhältnis
~~~

## Semantische Suche

Embeddings ergänzen FTS, wenn Query und Transkript unterschiedliche Wörter verwenden.

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

Analyse-Artefakte werden bei Locate-Fragen aus der finalen Rangliste entfernt. „Wo wird XY erwähnt?“ soll auf Primärquellen im Transkript zeigen.

### Knowledge Queries

Für normale Wissensfragen werden lexikalische und semantische Treffer gleichwertiger fusioniert. Analyse-Artefakte können zusätzlich einfließen.

## Query Intent

| Intent | Beispiele | Verhalten |
|---|---|---|
| `locate` | „Wo wird X erwähnt?“, „Wann spricht sie über Y?“ | Transcript Sources priorisieren, FTS stärker gewichten |
| `knowledge` | „Was sagt sie über X?“, „Warum ist Y wichtig?“ | Hybrid Retrieval über Transcript + ggf. Analyse |

Die Intent-Erkennung ist deterministisch und regelbasiert; dafür ist kein zusätzlicher LLM-Aufruf erforderlich.

## Source Unit vs. Context Window

Die kleinste zitierbare Einheit bleibt ein Transcript-Satz. Für semantisches Retrieval können größere Kontextfenster sinnvoll sein. Wichtig ist die Trennung:

- **Retrieval Unit:** darf mehrere Sätze enthalten.
- **Citation Unit:** bleibt eine oder mehrere konkrete Source IDs.

## Fehlerfall und Fallback

Wenn das Embedding-Modell nicht verfügbar ist, fällt das System auf FTS5 zurück. Die Provenienz bleibt erhalten.

## Diagnose-API

Lexikalisch:

~~~http
GET /api/retrieval/search?q=NVIDIA&limit=20
~~~

Hybrid:

~~~http
GET /api/retrieval/hybrid-search?q=Wo%20wird%20NVIDIA%20erwähnt%3F&limit=20
~~~

Hybrid-Ergebnisse enthalten unter anderem `retrieval_methods`, `lexical_score`, `semantic_score` und `hybrid_score`.

## Rebuildability

FTS und Embeddings sind abgeleitete Daten. Der Retrieval Store wird beim Backend-Start aus den neuesten vorhandenen Transkripten rekonstruiert und nach Transkription, Editing, Recovery und Löschen aktualisiert.
