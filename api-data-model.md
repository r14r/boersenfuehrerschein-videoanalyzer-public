---
layout: default
title: API & Datenmodell
permalink: /api-data-model
---

# API & Datenmodell

## Transcript Source

~~~sql
CREATE TABLE transcript_sources (
  source_id TEXT PRIMARY KEY,
  transcript_job_id TEXT NOT NULL,
  video_id TEXT NOT NULL,
  sentence_id TEXT NOT NULL,
  speaker TEXT NOT NULL,
  start REAL NOT NULL,
  end REAL NOT NULL,
  text TEXT NOT NULL,
  content_hash TEXT NOT NULL,
  created_at REAL NOT NULL,
  updated_at REAL NOT NULL
);
~~~

FTS5 indexiert Text, während Provenienz in der normalen Tabelle bleibt.

## Search API

~~~http
GET /api/retrieval/search?q=Kurs-Umsatz-Verhältnis&limit=20
~~~

~~~json
{
  "query": "Kurs-Umsatz-Verhältnis",
  "mode": "lexical",
  "results": [{
    "source_id": "video_abc:s000127",
    "video_id": "video_abc",
    "speaker": "Sprecher 1",
    "start_seconds": 761.2,
    "end_seconds": 769.9,
    "timeframe": {"start":"00:12:41.200","end":"00:12:49.900"},
    "text": "Das Kurs-Umsatz-Verhältnis ...",
    "score": 8.42
  }]
}
~~~

## Synchronisation
Nach Transkription: YAML laden, Sources erzeugen, Sources des Jobs atomar ersetzen/upserten, FTS aktualisieren und Embeddings nur für geänderte Content-Hashes neu berechnen.

## Löschen
Beim dauerhaften Löschen eines Videos müssen Sources, FTS-Zeilen und Embeddings entfernt werden.
