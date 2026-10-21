---
layout: default
title: API & Datenmodell
permalink: /docs/api-data-model/
---

# API & Datenmodell

## Transcript Source Store

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

Die stabile Source-ID lautet `<video-id>:<sentence-id>`.

## FTS5

~~~sql
CREATE VIRTUAL TABLE transcript_sources_fts USING fts5(
  source_id UNINDEXED,
  transcript_job_id UNINDEXED,
  video_id UNINDEXED,
  speaker,
  text,
  tokenize='unicode61 remove_diacritics 2'
);
~~~

## Lexical Search API

~~~http
GET /api/retrieval/search?q=Kurs-Umsatz-Verhältnis&limit=20
~~~

Optional:

~~~http
GET /api/retrieval/search?q=NVIDIA&video_id=video123
~~~

## Hybrid Search API

~~~http
GET /api/retrieval/hybrid-search?q=Wo%20wird%20NVIDIA%20erwähnt%3F&limit=20
~~~

Die Antwort enthält Query Intent, Modus, Fallback-Hinweis, Retrieval-Methoden und Scores sowie vollständige Source-Provenienz.

## Source Lookup

~~~http
GET /api/retrieval/sources/video123:s000042
~~~

## Public Source Shape

~~~json
{
  "source_id": "video123:s000042",
  "video_id": "video123",
  "speaker": "Sprecher 1",
  "start_seconds": 313.1,
  "end_seconds": 322.3,
  "timeframe": "00:05:13.100–00:05:22.300",
  "media_url": "/api/videos/video123/media",
  "text": "NVIDIA ..."
}
~~~

## Chat Response

~~~json
{
  "answer": "...",
  "sources": [...],
  "source_ids": ["video123:s000042"],
  "rag_mode": "hybrid",
  "rag_fallback": null,
  "context_budget": {
    "query_intent": "locate",
    "rag_sources": 4
  }
}
~~~

## Synchronisation

Nach erfolgreicher Transkription wird der aktive Source-Bestand des Videos ersetzt, FTS aktualisiert und der semantische Index inkrementell synchronisiert. Dasselbe gilt nach Transcript-Editing.

## Löschen

Beim Löschen eines Videos werden die zugehörigen Transcript Sources und FTS-Zeilen entfernt.
