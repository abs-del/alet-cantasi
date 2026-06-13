---
description: Bir vault öğesini AI ile zenginleştirir (özet, etiket, çeviri, kalite analizi). prompt-enricher agent'ını çağırır.
argument-hint: <VaultName> <itemId>
---

# /enrich

Mevcut bir vault öğesinin meta verisini AI ile geliştirir.

## Çağrılan agent

`prompt-enricher` — sonuçları `vault-curator`'a paslar (otomatik approve yok, kullanıcı onayı zorunlu).

## Akış

1. Öğeyi `vault-grep` ile getir
2. `prompt-enricher` agent'a iletir
3. Çıktı:
   - desc_tr / desc_en (TR ana metin, EN opsiyonel)
   - 3–6 etiket önerisi
   - A/B varyantı (öneri 44)
   - Kalite skoru ve eksik alanlar
4. Kullanıcı onayı → vault HTML'i güncellenir

## Token disiplini

- Prompt caching aktif (öneri 113) — system mesajı cached.
- Tek öğe için tahmini maliyet: ~$0.003 (Sonnet) veya **ücretsiz** (Groq Llama 3.3).
- Sağlayıcı seçimi `cost-router` agent'ına delege edilir.

## Kullanım

```
/enrich PromptVault jailbreak-detector-2026-06-12
```
