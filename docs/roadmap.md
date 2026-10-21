---
layout: default
title: Roadmap
permalink: /docs/roadmap/
---

# Roadmap

## Phase 1 — Source Store & FTS ✅

Implementiert:

- stabile Transcript Source IDs
- SQLite Source Store
- FTS5
- Search API
- automatische Synchronisation
- Sprecher/Timeframe-Provenienz

## Phase 2 — Hybrid Retrieval ✅

Implementiert:

- FTS5 + semantische Embeddings
- gewichtete Reciprocal Rank Fusion
- Locate-vs-Knowledge Intent
- Transcript-Priorisierung
- Hybrid-Diagnose-Endpunkt

## Phase 3 — Structured Answers ✅

Implementiert:

- `sources` getrennt vom LLM-Fließtext
- vertrauenswürdige `source_ids`
- Source-ID, Sprecher und Timeframe im Prompt-Kontext
- persistente Provenienz in Chat-Sessions
- providerneutrales `video-analyzer.answer` Schema v1
- strukturierte Citations aus serverseitig validierten `[Quelle N]`-Referenzen
- Freitext-Streaming plus maschinenlesbares finales Answer Envelope

Optional später:

- providerseitiges natives JSON-Schema, sofern das gewählte Modell dies zuverlässig unterstützt

## Phase 4 — Player Integration ✅ Basis implementiert

Implementiert:

- Source Cards
- Deep Links `?t=` / `&end=`
- Seek/Play
- Pausieren am Ende des referenzierten Bereichs

Noch offen:

- Timeline-Markierungen
- vorherige/nächste Source direkt im Player

## Phase 5 — Context Windows ✅

Implementiert:

- pro Citation Unit ein zentriertes semantisches Context Window
- konfigurierbarer Radius über `RAG_CONTEXT_RADIUS`
- Default: zwei Sätze vorher und zwei nachher
- Embedding und Prompt-Kontext verwenden das Fenster
- UI/Source bleibt der zentrale einzelne Satz
- Context-Source-IDs und Context-Timeframe als Provenienz
- RAG-Index-Schema v4

Damit ist semantisches Retrieval kontextreicher, ohne präzise Videozitate zu verlieren.

## Phase 6 — Citation Validation ✅

Implementiert:

- `[Quelle N]` serverseitig gegen die tatsächlich bereitgestellte Prompt-Source-Liste validieren
- `provided_source_ids`, `cited_source_ids` und `uncited_source_ids`
- ungültige/out-of-range Quellenreferenzen erkennen
- doppelte Quellenverweise deduplizieren
- zitierte Sources prominent und unzitierte Sources separat im Chat darstellen

Noch offen:

- optional striktes strukturiertes Answer Schema
- providerseitiges JSON-Schema, soweit vom jeweiligen Modell unterstützt

## Phase 7 — Provider-Neutraler Chat

- Ollama und NVIDIA im Chat direkt auswählbar
- identische Retrieval-/Source-Pipeline
- providerunabhängiges Answer Schema

## Phase 8 — Speaker Diarization

- echte Sprechererkennung
- Mapping auf bestehendes YAML
- manuelle Korrektur

## Qualitätsziel

„Wo wird XY erwähnt?“ liefert Fundstellen, die direkt zu **Video + Sprecher + millisekundengenauer, abspielbarer Originalstelle** führen, während semantisches Retrieval genügend Nachbarsatz-Kontext besitzt.
