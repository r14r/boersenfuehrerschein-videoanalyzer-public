---
layout: default
title: Überblick
permalink: /
---

# Video Analyzer

Der Video Analyzer verarbeitet Videoinhalte zu einem **quellengenauen, durchsuchbaren Wissensbestand**. Ziel ist nicht nur eine Zusammenfassung, sondern eine belastbare Kette von der LLM-Antwort zurück zur konkreten Stelle im Originalvideo.

![Gesamtarchitektur]({{ '/assets/images/architecture.svg' | relative_url }}){: .diagram }

## Zielbild

1. Videoquelle authentifiziert öffnen.
2. Videodatei herunterladen.
3. Audio lokal transkribieren.
4. Transkript als YAML mit `speaker`, `timeframe` und `text` speichern.
5. Stabile Retrieval Sources erzeugen.
6. SQLite FTS5 und Embeddings kombinieren.
7. Relevante Sources an Ollama oder NVIDIA übergeben.
8. Antwort mit Source IDs erzeugen.
9. Source IDs serverseitig in Video, Sprecher und Zeitbereich auflösen.
10. Im UI direkt an die referenzierte Videostelle springen.

<div class="callout"><strong>Leitprinzip:</strong> Das LLM interpretiert Inhalte, aber Video-ID, Dateiname, Sprecher und Zeitstempel stammen immer aus dem Retrieval Store.</div>

## Komponenten

| Komponente | Aufgabe |
|---|---|
| Browser | Login, Session, Quellenerkennung |
| Backend | Jobs, Library, Retrieval, RAG, LLM-Gateway |
| Transcriber | Audio-Extraktion, Whisper, YAML |
| Ollama | lokale LLMs und Embeddings |
| NVIDIA | optionale externe LLMs |
| Frontend | Bibliothek, Transkripte, Analyse, Chat, Player |
| SQLite | State und Full-Text-Retrieval |
