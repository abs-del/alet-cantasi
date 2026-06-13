---
description: Bir vault'taki TÜM öğeleri batch olarak zenginleştirir. p-queue ile concurrency limit, semantic cache aktif.
argument-hint: <VaultName> [--limit=N] [--dry-run]
---

# /batch-enrich

Toplu zenginleştirme — maliyet kontrolü zorunlu.

## Akış

1. **Cost preview** — `cost-router` agent'a danış: tahmini token + USD.
2. **Kullanıcı onayı** — Tahmin gösterilir, "go" gerekir.
3. **p-queue** ile concurrency=3, otomatik retry (p-retry).
4. **Semantic cache** kontrolü — daha önce zenginleşmişse atla.
5. **Progress bar** — her 10 öğede bir update.
6. **Hata toleransı** — başarısız öğeler raporda listelenir, vault yine yazılır.

## Kullanım

```
/batch-enrich TurkVault --limit=50
/batch-enrich PromptVault --dry-run   # sadece maliyet tahmini
```

## Güvenlik

- Bütçe aşılırsa **hard stop** (öneri 154).
- 100+ öğelik vault'ta dry-run zorunlu önerilir.
- Çıktıdaki tüm değişiklikler tek atomic commit'te.
