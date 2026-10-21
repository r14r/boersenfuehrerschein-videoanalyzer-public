---
layout: default
title: Betrieb & Entwicklung
permalink: /operations-development
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
Media und Analyse-State liegen persistent im Datenbereich. Das Chromium-Profil liegt in einem Docker-Named-Volume. Der Retrieval Store liegt in SQLite im Analyse-State.

## Rebuild

~~~bash
just docker-build-service backend
just docker-build-service transcriber
just docker-up
~~~

## Teststrategie

1. YAML enthält Sprecher und Millisekunden-Timeframes.
2. Source Store enthält erwartete Sätze.
3. FTS findet exakte Begriffe.
4. Search API liefert korrekte Video-ID und Zeitwerte.
5. RAG behält Source IDs bis zur Antwort.
6. UI springt zur erwarteten Stelle.
7. Legacy-JSON bleibt lesbar.
