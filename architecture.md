---
layout: default
title: Architektur
permalink: /architecture
---

# Architektur

## Datenklassen

- **Originaldaten:** Video/Audio und kanonisches YAML-Transkript.
- **Abgeleitete Daten:** Analysen, Retrieval Sources, FTS-Index, Embeddings.
- **Operativer State:** Jobs, Provider-Konfiguration, Chat-Sessions, Audit-Daten.

Originaldaten bleiben nachvollziehbar. Abgeleitete Daten müssen aus ihnen reproduzierbar sein.

## Services

### Browser
Chromium besitzt ein persistentes Docker-Named-Volume für Cookies und Sessions. Das vermeidet Bind-Mount-Probleme bei Colima und Docker Desktop.

### Backend
FastAPI orchestriert Download, Bibliothek, Transkriptzugriff, Retrieval, RAG, Analysen, Provider und Source-Auflösung.

### Transcriber
`faster-whisper` oder `whisper.cpp` arbeiten isoliert vom Backend. Ergebnis ist ein job-versioniertes YAML-Artefakt.

### LLM Gateway
Das Gateway abstrahiert Ollama und NVIDIA. Retrieval findet vor dem Modellaufruf statt.

![Architekturdiagramm]({{ '/assets/images/architecture.svg' | relative_url }}){: .diagram }

## Vertrauensgrenzen

Das LLM ist niemals autoritative Quelle für `video_id`, `filename`, `speaker`, `start` oder `end`. Diese Werte werden aus persistierten Source Records aufgelöst.
