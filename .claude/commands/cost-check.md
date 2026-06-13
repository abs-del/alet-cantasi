---
description: Bir görevin tahmini token + USD maliyetini çıkarır. cost-router agent'ı kullanır. API çağrısı YAPMAZ.
argument-hint: "<görev tanımı>" [--provider=claude|gpt|gemini|groq]
---

# /cost-check

Maliyet öngörüsü — hiçbir API'yi çağırmaz, sadece tahmin yapar.

## Kullanım

```
/cost-check "PromptVault'taki 6000 öğeyi zenginleştir"
/cost-check "Yeni AcademicVault için 50 seed item üret" --provider=claude
```

## Çıktı

```
💰 Maliyet öngörüsü
═══════════════════════════════════════════
Görev: PromptVault batch enrichment (6000 öğe)

Token tahmini (input):  ~12.5M tokens
Token tahmini (output):  ~2.4M tokens
Prompt cache hit (öngörü): %72

Sağlayıcı karşılaştırması:
  ┌──────────────────┬──────────┬──────────┬─────────┐
  │ Provider         │ Cost USD │ Süre     │ Kalite  │
  ├──────────────────┼──────────┼──────────┼─────────┤
  │ Claude Sonnet 4.6│  $14.20  │ ~4 saat  │  ★★★★★  │
  │ Claude Opus 4.6  │  $71.00  │ ~6 saat  │  ★★★★★  │
  │ GPT-4o           │  $9.80   │ ~3 saat  │  ★★★★☆  │
  │ Groq Llama 3.3   │  FREE    │ ~1 saat  │  ★★★☆☆  │
  │ DeepSeek V3      │  $1.20   │ ~5 saat  │  ★★★★☆  │
  └──────────────────┴──────────┴──────────┴─────────┘

Öneri: Sonnet ana, Groq ile etiket görevleri.
Karma maliyet: $4.10 (öneri 157 free-tier dengeleyici)

Aylık bütçeniz: $5.00 → bu görev %82'sini tüketir.
```
