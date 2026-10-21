---
layout: default
title: Prompting & UI
permalink: /docs/prompting-ui/
---

# Prompting & UI

Die Prompting-Schicht erhält nicht nur Text, sondern **strukturierte Provenienz**. Source-ID, Video, Sprecher und Zeitbereich bleiben vom Retrieval bis zur UI erhalten.

## Prompt Context

~~~text
[Quelle 1 · Transkript-Satz:
 Bewertung von Wachstumsaktien
 · Sprecher 1
 · 00:12:41.200–00:12:49.900
 · Source-ID video123:s000127]

Das Kurs-Umsatz-Verhältnis eignet sich insbesondere ...
~~~

Das Modell wird angewiesen, nur vorhandene Quellen zu verwenden, als `[Quelle N]` zu zitieren und keine Source-IDs, Sprecher oder Zeitangaben zu erfinden.

Bei Locate-Fragen kommt die zusätzliche Instruktion hinzu, relevante Fundstellen einzeln auszugeben.

## Strukturierte Provenienz neben der LLM-Antwort

~~~json
{
  "answer": "NVIDIA wird an zwei Stellen thematisiert [Quelle 1] [Quelle 2].",
  "source_ids": [
    "video123:s000042",
    "video456:s000117"
  ],
  "sources": [
    {
      "source_id": "video123:s000042",
      "video_id": "video123",
      "speaker": "Sprecher 1",
      "start_seconds": 313.1,
      "end_seconds": 322.3,
      "timeframe": "00:05:13.100–00:05:22.300",
      "text": "..."
    }
  ]
}
~~~

`source_ids` werden nicht aus dem Modelltext geparst. Das Backend erzeugt sie aus den tatsächlich in den Prompt aufgenommenen Retrieval Sources.

![Source-to-Player Flow]({{ '/assets/images/ui-source-flow.svg' | relative_url }}){: .diagram }

## Source Cards im Chat

Eine Karte enthält:

- Quelle N
- Video-Titel
- Sprecher
- Start- und Endzeit mit Millisekunden
- Textausschnitt
- Retrieval-Methode
- Hybrid Score
- Source-ID
- **Abspielen**-Button

## Deep Link und Player

~~~text
/videos/<video-id>?t=313.1&end=322.3
~~~

Beim Laden setzt der native Video-Player nach `loadedmetadata` die Position auf `t`. Die Wiedergabe wird gestartet, soweit die Browserregeln dies erlauben. Ist `end` gesetzt, pausiert der Player am Ende des referenzierten Abschnitts.

## Persistente Chat-Sessions

Assistant-Nachrichten speichern zusätzlich `sources`, `source_ids`, `rag_mode`, `rag_fallback`, Context-Budget, Request-ID und Gateway-Telemetrie.

## Sicherheitsprinzip

Das Modell entscheidet, **wie** es Inhalte erklärt. Das Backend entscheidet, **welche Quellen tatsächlich verwendet wurden** und welche Video-/Zeitmetadaten dazu gehören.

## Citation Validation

Nach Abschluss der Modellantwort wird jeder Verweis im Format `[Quelle N]` serverseitig validiert. Maßgeblich ist ausschließlich die Source-Liste, die tatsächlich in den Prompt aufgenommen wurde.

Beispiel:

~~~text
Das Thema wird an zwei Stellen behandelt [Quelle 1] [Quelle 3].
~~~

Das Backend erzeugt daraus strukturierte Provenienz:

~~~json
{
  "provided_source_ids": [
    "video1:s000010",
    "video1:s000011",
    "video2:s000044"
  ],
  "cited_source_ids": [
    "video1:s000010",
    "video2:s000044"
  ],
  "uncited_source_ids": [
    "video1:s000011"
  ],
  "invalid_citations": [],
  "citation_valid": true
}
~~~

Ungültige Verweise wie `[Quelle 7]`, obwohl nur drei Sources bereitgestellt wurden, werden nicht stillschweigend akzeptiert:

~~~json
{
  "invalid_citations": [
    {
      "label": "Quelle 7",
      "number": 7,
      "reason": "out_of_range"
    }
  ],
  "citation_valid": false
}
~~~

Die UI zeigt zitierte Quellen prominent und hält die ursprüngliche `[Quelle N]`-Nummerierung bei. Nicht zitierte, aber bereitgestellte Sources bleiben separat aufklappbar. Dadurch ist sichtbar, welcher Kontext verfügbar war und welche Sources das Modell tatsächlich referenziert hat.

Wichtig: `cited_source_ids` werden nicht aus vom Modell erzeugten Dateinamen oder Zeitstempeln abgeleitet. Die Nummer `N` wird ausschließlich gegen die serverseitig bekannte Source-Liste aufgelöst.

## Structured Answer Schema

Nach dem Streaming der menschenlesbaren Modellantwort erzeugt das Backend ein providerneutrales Answer Envelope. Dadurch bleibt die UI responsiv, während die finale Antwort zusätzlich maschinenlesbar und validierbar wird.

~~~json
{
  "schema": "video-analyzer.answer",
  "schema_version": 1,
  "answer": "NVIDIA wird an zwei Stellen behandelt [Quelle 1] [Quelle 3].",
  "citations": [
    {
      "source_id": "video1:s000010",
      "source_number": 1
    },
    {
      "source_id": "video2:s000044",
      "source_number": 3
    }
  ],
  "citation_valid": true
}
~~~

Das Modell erzeugt weiterhin normalen Antworttext mit `[Quelle N]`. Das Backend löst diese Marker gegen die tatsächlich bereitgestellte Prompt-Source-Liste auf und baut daraus das strukturierte Schema.

### Warum kein LLM-generierter Zeitstempel im Schema?

Das Structured Answer Schema enthält absichtlich nur die vertrauenswürdigen Referenzen:

- `source_id`
- ursprüngliche `source_number`

Nicht enthalten sind vom Modell erzeugte Kopien von:

- Sprecher
- Dateiname
- Startzeit
- Endzeit

Diese Metadaten werden weiterhin serverseitig aus der kanonischen Source aufgelöst. Damit kann eine Halluzination im Text die Playback-Zielposition nicht verändern.

### Streaming-Kompatibilität

Der Chat streamt weiterhin normalen Text. Erst beim Abschluss der Antwort wird das Envelope erzeugt und zusammen mit dem finalen `done`-Event sowie in der Chat-Session gespeichert.

Die UI zeigt die verwendete Schema-Version in den LLM-Details, z. B. `Answer Schema v1`.
