---
layout: default
title: Roadmap
permalink: /roadmap
---

# Roadmap

## Phase 1 — Source Store & FTS ✅

Implementiert: stabile Source IDs, SQLite Source Store, FTS5, Search API, automatische Synchronisation und Provenienz mit Sprecher/Timeframe.

## Phase 2 — Hybrid Retrieval ✅

Implementiert:

- FTS5 + semantische Embeddings
- gewichtete Reciprocal Rank Fusion
- Locate-vs-Knowledge Intent
- Transcript-Priorisierung für Fundstellenfragen
- strukturierte Retrieval-Provenienz
- Hybrid-Diagnose-Endpunkt

## Phase 3 — Structured Answers ✅ Basis implementiert

Implementiert:

- `sources` getrennt vom LLM-Fließtext
- vertrauenswürdige `source_ids`
- Source-ID, Sprecher und Timeframe im Prompt-Kontext
- persistente Provenienz in Chat-Sessions

Noch offen: optionales striktes JSON-Ausgabeformat und automatische Prüfung der tatsächlich zitierten `[Quelle N]`.

## Phase 4 — Player Integration ✅ Basis implementiert

Implementiert:

- Source Cards im Chat
- Deep Links mit `?t=` und `&end=`
- Seek/Play
- Pausieren am Ende eines referenzierten Bereichs

Noch offen: Timeline-Markierungen und vorherige/nächste Quelle im Player.

## Phase 5 — Context Windows

Nächster Retrieval-Ausbauschritt:

- benachbarte Transcript-Sätze als Context Window
- Citation Units einzeln erhalten
- überlappende Treffer deduplizieren
- Kontextfenster an das LLM, konkrete Source Units an die UI

## Phase 6 — Provider-Neutraler Chat

- Ollama und NVIDIA direkt auswählbar
- identische Retrieval-/Source-Pipeline
- providerunabhängiges Answer-Schema

## Phase 7 — Speaker Diarization

- echte Sprechererkennung
- Mapping auf bestehendes YAML
- manuelle Korrektur

## Qualitätsziel

„Wo wird XY erwähnt?“ liefert Fundstellen, die direkt zu **Video + Sprecher + millisekundengenauer, abspielbarer Originalstelle** führen.
