---
description: Bir vault'a yeni öğe ekler. vault-curator agent'ını çağırır, şema doğrulama + duplikasyon kontrolü yapar.
argument-hint: <VaultName> "<öğe adı>" "<içerik>"
---

# /vault-add

Yeni vault öğesi ekleme komutu.

## Kullanım

```
/vault-add PromptVault "Jailbreak Detector" "Aşağıdaki promptun jailbreak içerip içermediğini..."
```

## Akış

1. `vault-curator` agent'ı subagent olarak spawn et
2. Hedef vault: `$1`
3. Öğe adı: `$2`, içerik: `$3`
4. `vault-inspector` skill'i ile şemayı doğrula
5. Duplikasyon kontrolü yap
6. Otomatik etiket öner (3–6 tag)
7. Kalite skoru hesapla — < 3 ise reddet
8. Onay sonrası `Edit` ile vault HTML'ine ekle

## Çıktı

```
✅ PromptVault'a eklendi
   id: jailbreak-detector-2026-06-12
   tags: [jailbreak, safety, detection, prompt-injection]
   skor: 4/5
```
