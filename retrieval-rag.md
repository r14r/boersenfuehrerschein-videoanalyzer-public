---
layout: default
title: Retrieval & RAG
permalink: /retrieval-rag
---

# Retrieval & RAG

RAG ist hier nicht gleich Vektorsuche. Es umfasst Retrieval, Kontextaufbau und Grounding des LLM.

![Hybrid Retrieval]({{ '/assets/images/retrieval.svg' | relative_url }}){: .diagram }

## Canonical Source Record

~~~json
{
  "source_id": "video_abc:s000127",
  "video_id": "video_abc",
  "sentence_id": "s000127",
  "speaker": "Sprecher 1",
  "start": 761.2,
  "end": 769.9,
  "text": "Das Kurs-Umsatz-Verhältnis eignet sich insbesondere ..."
}
~~~

## FTS5
SQLite FTS5 ist ideal für Eigennamen, Abkürzungen, Kennzahlen und wörtliche Fundstellen. Für „Wo wird XY erwähnt?“ ist lexical search häufig präziser als reine Vektorsuche.

## Semantische Suche
Embeddings finden inhaltlich ähnliche Formulierungen, auch wenn Query und Transkript unterschiedliche Wörter verwenden.

## Hybrid Retrieval

1. FTS5 Candidates.
2. Semantic Candidates.
3. Merge per Source-ID.
4. Score-Normalisierung.
5. Deduplizierung benachbarter Treffer.
6. optionaler Reranker.
7. Context Windows um Top-Treffer.

## Source Unit vs. Context Window
Eine kleine Source Unit ist exakt zitierbar. Ein größeres Context Window verbessert semantisches Verständnis. Der Kontext darf aus mehreren Sources bestehen, die Antwort verweist aber auf die konkreten Source IDs.

## Locate Queries
Transcript Sources priorisieren, FTS hoch gewichten, mehrere Fundstellen liefern und immer Video/Sprecher/Zeit ausgeben.

## Rebuildability
FTS und Embeddings sind abgeleitete Daten und müssen vollständig aus dem kanonischen Transcript neu erzeugt werden können.
