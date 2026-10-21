---
layout: default
title: Betrieb & Entwicklung
permalink: /docs/operations-development/
---

# Betrieb & Entwicklung

## Docker

~~~bash
just docker-up
just docker-down
just docker-build
just docker-build-service backend
just docker-logs
just docker-clean
just data-clear
~~~

## Persistenz

Media und Analyse-State liegen persistent im Datenbereich. Das Chromium-Profil liegt in einem Docker-Named-Volume. Retrieval Sources liegen in SQLite; semantische Embeddings liegen im RAG-Index.

## RAG Context Window

Der semantische Transcript-Kontext wird über eine Umgebungsvariable gesteuert:

~~~bash
RAG_CONTEXT_RADIUS=2
~~~

Default ist `2`. Damit umfasst ein Context Window maximal fünf Sätze:

~~~text
2 vorher + Citation + 2 nachher
~~~

Eine Änderung sollte mit einem Rebuild/Restart des Backends verbunden werden. Durch RAG-Schema v4 erkennt der Backend-Sync inkompatible ältere Indexdaten und erzeugt die Embeddings neu.

## Rebuild

~~~bash
just docker-build-service backend
just docker-up
~~~

Nach Änderungen an Transcriber-Abhängigkeiten zusätzlich:

~~~bash
just docker-build-service transcriber
~~~

## Teststrategie

Wichtige Prüfpunkte:

1. YAML enthält Sprecher und Millisekunden-Timeframes.
2. Source Store enthält die erwarteten Citation Units.
3. FTS findet exakte Begriffe und natürliche Locate-Queries.
4. Context Window überschreitet keine Transcript-Grenzen.
5. Center-Satz behält seine stabile Source-ID.
6. Embedding-Text enthält Nachbarsätze.
7. öffentliche Source enthält nicht den kompletten internen Embedding-Kontext.
8. Hybrid Merge fusioniert lexical und semantic über dieselbe Source-ID.
9. Chat-Source Card öffnet die richtige Videostelle.
10. Legacy-JSON bleibt lesbar.

## Externe Chat-Provider

Das konservative Prompt-Budget für externe Chat-Provider wird separat konfiguriert:

~~~bash
EXTERNAL_CHAT_NUM_CTX=8192
~~~

Dieser Wert steuert den internen Context Builder. Er wird nicht als Ollama-spezifische `num_ctx`-Option an externe OpenAI-kompatible APIs gesendet.

Provider und Modelle werden unter **Admin → Provider / Modelle** verwaltet. Externe Credentials verbleiben serverseitig und werden nicht an den Browser ausgeliefert.
