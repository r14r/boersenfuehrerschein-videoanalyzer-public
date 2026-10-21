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
