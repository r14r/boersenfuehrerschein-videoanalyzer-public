---
layout: default
title: Prompting & UI
permalink: /prompting-ui
---

# Prompting & UI

## Prompt Contract

~~~text
Beantworte die Frage anhand der bereitgestellten Quellen.
Referenziere nur vorhandene SOURCE IDs.
Erfinde keine Dateinamen, Sprecher oder Zeitangaben.
~~~

## Gewünschtes Modellresultat

~~~json
{
  "answer": "Das KUV wird an zwei Stellen erläutert.",
  "source_ids": ["video_abc:s000127", "video_def:s000044"]
}
~~~

Das Backend löst die IDs auf; so können Zeitstempel nicht vom Modell halluziniert werden.

![Source-to-Player Flow]({{ '/assets/images/ui-source-flow.svg' | relative_url }}){: .diagram }

## Source Card
Eine Quelle zeigt Videotitel/Dateiname, Sprecher, Start/Ende, Textausschnitt und einen Play-Button.

## Deep Link
Empfohlen: `/videos/<video-id>?t=761.2&end=769.9`.

## Chat
Fließtext und Sources werden getrennt gerendert. Sources sind strukturierte Objekte, keine vom Modell formatierte Markdown-Zeichenkette.

## Bibliothek
Ein Videoklick klappt das Transkript als Tabelle auf.

## Transkripte
Nach Auswahl wird die editierbare Transcript-Tabelle unterhalb der Liste angezeigt; Analyse bleibt separat.
