---
layout: default
title: End-to-End Workflow
permalink: /workflow
---

# End-to-End Workflow

## Download
Ein Download-Job erhält eine stabile `video_id`. Video und Artefakte liegen im Medienbereich; Titel, Tags und Notizen werden separat verwaltet.

## Transcribe
Audio wird in Chunks extrahiert. Segment-/Wortzeiten werden auf globale Videozeiten zurückgerechnet.

## Canonical Transcript

~~~yaml
- speaker: Sprecher 1
  timeframe:
    start: 00:12:41.200
    end: 00:12:49.900
  text: Das Kurs-Umsatz-Verhältnis eignet sich insbesondere ...
~~~

Ohne Diarisierung wird `Sprecher 1` gesetzt; Sprecherwechsel werden nicht erfunden.

## Retrieval Preparation
Jeder Eintrag wird ein Source Record mit stabiler ID wie `video_abc:s000127`.

## Indexing
FTS5 deckt exakte Begriffe ab; Embeddings semantisch ähnliche Formulierungen.

## Retrieval
Treffer werden dedupliziert und gerankt. Locate-Fragen priorisieren Transkript-Sources.

## Prompt Context
Das LLM sieht markierte Sources mit Video, Sprecher, Zeit und Text.

## Answer Resolution
Das Modell liefert idealerweise nur `answer` und `source_ids`. Das Backend reichert die Metadaten an.

## Playback
Die UI setzt `video.currentTime = source.start_seconds` und startet die Wiedergabe.
