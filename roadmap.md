---
layout: default
title: Roadmap
permalink: /roadmap
---

# Roadmap

## Phase 1 — Source Store & FTS
Stabile Source IDs, SQLite `transcript_sources`, FTS5, Search API, Synchronisation nach Transkription und Tests.

## Phase 2 — Hybrid Retrieval
Embeddings auf denselben Source IDs, Score-Merge, Context Windows und optionaler Reranker.

## Phase 3 — Structured Answers
LLM-Schema mit `source_ids` und serverseitige Source-Auflösung.

## Phase 4 — Player Integration
Source Cards, Deep Links mit `?t=`, Seek/Play und visuelle Markierung des Quellbereichs.

## Phase 5 — Speaker Diarization
Echte Sprechererkennung und manuelle Korrektur im bestehenden YAML-Schema.

## Qualitätsziel
„Wo wird XY erwähnt?“ liefert Fundstellen, die jeweils direkt zu **Video + Sprecher + exakt abspielbarer Zeitposition** führen.
