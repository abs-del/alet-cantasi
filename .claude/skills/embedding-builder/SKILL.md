---
name: embedding-builder
description: Bir vault için Transformers.js + hnswlib-wasm ile lokal embedding indeksi oluşturur. Sunucu kullanmaz. IndexedDB'ye persist eder. İlk indeksleme background'da, sonra anlık RAG hazır.
---

# Embedding Builder Skill

Vault içeriğini tarayıcı içinde vektörleştirip ANN indeksi kurar (öneri 10 + 139–149'un birleşik implementasyonu).

## Ne zaman kullanılır

- Bir vault'a ilk kez semantic search ekleniyorsa
- Embedding modeli güncellendiyse (cache invalidate)
- Yeni 100+ öğe eklendiyse (incremental indexing)

## Pipeline

1. **Loader** — Vault HTML'inden data island'ı parse et (vault-inspector skill'i kullan)
2. **Chunker** — `content` alanını 300 token chunk'lara böl, 50 token overlap
3. **Embedder** — `@xenova/transformers` ile `Xenova/all-MiniLM-L6-v2` (90MB)
4. **Index builder** — `hnswlib-wasm` HierarchicalNSW (M=16, ef=200, space=cosine)
5. **Persistor** — Dexie tablosu `embeddings` (vault, item_id, chunk_idx, vec Float32Array, hash)
6. **Snapshot** — HNSW index'i OPFS'e binary olarak yaz (`{vault}-hnsw.bin`)

## Kodlanmış script

`scripts/build-embeddings.mjs`:

```js
import { pipeline } from '@xenova/transformers';
import { HierarchicalNSW } from 'hnswlib-wasm';
import Dexie from 'dexie';
import { readFile } from 'node:fs/promises';

// CLI'dan: node build-embeddings.mjs PromptVault.html
const [, , vaultPath] = process.argv;

const html = await readFile(vaultPath, 'utf8');
const dataMatch = html.match(/<script[^>]*id="data"[^>]*>([\s\S]*?)<\/script>/);
if (!dataMatch) throw new Error('No data island in vault');
const items = JSON.parse(dataMatch[1]);

const embedder = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');
const dim = 384;
const hnsw = new HierarchicalNSW('cosine', dim);
hnsw.initIndex(items.length * 3, 16, 200);

let idx = 0;
for (const item of items) {
  const chunks = chunk(item.content, 300, 50); // token-aware splitter
  for (let i = 0; i < chunks.length; i++) {
    const { data } = await embedder(chunks[i], { pooling: 'mean', normalize: true });
    hnsw.addPoint(Array.from(data), idx);
    await db.embeddings.put({
      vault: vaultPath,
      item_id: item.id,
      chunk_idx: i,
      vec_idx: idx,
      hash: sha256(chunks[i]),
    });
    idx++;
  }
}

await hnsw.writeIndex('snapshot.bin');
console.log(`✅ ${idx} vektör, ${items.length} öğe indekslendi.`);
```

## Cache versioning

```js
// Embedding modeli versiyonu cache key'in parçası
const CACHE_KEY = `MiniLM-L6-v2_${CHUNKER_VERSION}_${CONTENT_HASH}`;
```

Model değişirse tüm cache otomatik invalidate olur.

## Performans

| Vault | Öğe sayısı | İndeksleme süresi (M1 Pro) | Boyut |
|---|---|---|---|
| TurkVault | 200 | ~6s | 1.2 MB |
| PromptVault | 6,000 | ~80s | 26 MB |

## Worker mode (üretim)

Production'da bu skill'i çağıran kod main thread'de değil, **Comlink Web Worker**'da çalışmalı (öneri 58). UI bloke olmaz.
