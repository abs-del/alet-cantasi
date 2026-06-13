---
description: Mevcut oturumun token tüketim durumunu gösterir. Limit, kullanılan, kalan, delege oranı.
---

# /token-status

Oturum token muhasebesi.

## Çıktı

```
📊 TOKEN STATUS — session 2026-06-12-14h32m
══════════════════════════════════════════════
Claude main context:    47,200 / 200,000  (23.6%)
  Conversation:         12,100
  System prompt:          850
  CLAUDE.md:            1,840
  Tool definitions:     2,410
  File reads:          30,000  ← en büyük tüketici

Delegasyonlar (dış token, Claude limitini etkilemez):
  codex-delegate:      28,000  (1 görev)
  gemini-delegate:     12,500  (2 görev)
  pal/thinkdeep:        4,200

Bütçe durumu:
  Aylık USD:    $1.23 / $5.00 (24.6%)
  Prompt cache hit oranı: %72 (öneri 113 çalışıyor ✅)

Öneri: 
  - `/compact` çalıştırın (file reads'i sıkıştırır)
  - veya 30k+ token gerektiren bir sonraki görevi /codex'e paslayın
```

## Sinyal eşikleri

| Kullanım | Davranış |
|---|---|
| < 50% | normal |
| 50–75% | yumuşak uyarı, `/compact` öner |
| 75–90% | ağır görevleri zorunlu delege et |
| > 90% | sadece kritik araç çağrıları, `/clear` öner |
