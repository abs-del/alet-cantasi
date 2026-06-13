---
description: Akıllı /compact — vault okuması yapılmış dosyaları sıkıştırır, konuşmanın özünü korur.
---

# /compact-smart

Standart `/compact`'in vault'a-özel versiyonu.

## Strateji

- Vault HTML'leri okunduysa → özetle:
  - "PromptVault.html okundu: 6000 öğe, 12 MB, 8 kategori"
  - Tam içerik atılır, bu bir cümle tutulur
- Tool çağrı sonuçları (Bash, Grep) → ilk 10 satır + "(N satır daha gösterilmedi)"
- Kod blokları → varlığı kaydedilir, kod gövdesi çıkarılır
- Karar/plan mesajları → tam korunur
- Hata mesajları → tam korunur (debug için)
- Test/QA özet sonuçları → tam korunur

## Sözleşme

Sıkıştırma sonrası ana mesaj zinciri **maksimum 8,000 token** olacak. Bu sınır aşılırsa, daha eski mesajlar tamamen drop edilir (`/btw` tarzı yorum belirteciyle).

## Kullanım

```
/compact-smart
/compact-smart --keep="security audit"   # belirli konuyu koru
```
