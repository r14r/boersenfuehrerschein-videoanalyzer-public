# Video Analyzer Documentation

Öffentliche technische Dokumentation des Video Analyzer.

Die GitHub-Pages-Site basiert auf dem **Aviator Jekyll Template** von CloudCannon. GitHub Pages verwendet den Ordner `docs/` als Jekyll-Source; die eigentliche Dokumentation wird unter `/docs/` veröffentlicht.

## Lokal installieren und bauen

Voraussetzungen:

- Ruby
- Bundler
- just

Einmalig bzw. nach Änderungen am `Gemfile`:

```bash
just install
```

Die Gems werden repository-lokal unter `vendor/bundle/` installiert.

Build:

```bash
just build
```

Der Build wird nach `docs/_site/` geschrieben und prüft explizit, dass mindestens folgende Artefakte existieren:

- Root-Redirect `index.html`
- `docs/index.html`
- Architektur-Seite
- Retrieval/RAG-Seite
- Aviator CSS
- Architekturdiagramm

Lokale Vorschau:

```bash
just serve
```

## Struktur

```text
/
├── Gemfile
├── justfile
├── README.md
└── docs/
    ├── _config.yml
    ├── _layouts/
    ├── _includes/
    ├── assets/
    ├── css/
    ├── images/
    ├── js/
    ├── root.html
    ├── index.md
    ├── architecture.md
    ├── retrieval-rag.md
    └── ...
```

`docs/root.html` erzeugt die Root-URL des GitHub-Pages-Projekts und leitet auf `/docs/` weiter. Dadurch liefert auch

`https://r14r.github.io/boersenfuehrerschein-videoanalyzer-public/`

keinen 404 mehr.

Die Original-Lizenz und Attribution des Aviator Templates stehen in `THIRD_PARTY_NOTICES.md`.
