---
layout: default
title: Transkripte
permalink: /transcripts
---

# Transkripte

## Kanonisches YAML

| Feld | Bedeutung |
|---|---|
| `speaker` | Sprecherlabel |
| `timeframe.start` | `HH:MM:SS.mmm` |
| `timeframe.end` | `HH:MM:SS.mmm` |
| `text` | normalisierter gesprochener Text |

Intern existieren außerdem stabile Satz-IDs und numerische Sekundenwerte.

## Warum YAML?
YAML ist menschenlesbar, diff-freundlich, strukturiert und lässt sich direkt tabellarisch bearbeiten.

## Zeitrepräsentation
Menschen sehen `00:12:41.200`; der Player verwendet `761.2` Sekunden. Beide Werte stammen aus derselben Source.

## Editing
Die UI schreibt Sprecher, Start, Ende und Text strukturiert zurück. HTML ist für neue Transkripte nicht das führende Format.

## Legacy
Ältere JSON-Transkripte bleiben lesbar und können beim Speichern/Export normalisiert werden.

## Diarisierung
Whisper identifiziert Sprecher nicht zuverlässig. Eine spätere Diarisierungsstufe kann dieselben Records mit echten Sprecherlabels anreichern, ohne das Retrieval-Schema zu ändern.
