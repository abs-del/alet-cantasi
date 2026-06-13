---
description: Yeni vault HTML'i oluşturur. html-vault-generator skill kullanır. Boş veya seed item'lı.
argument-hint: <VaultName> "<title TR>" "<discipline>"
---

# /new-vault

Yeni vault yarat (öneri 89'un sistematik versiyonu).

## Kullanım

```
/new-vault AcademicVault "Akademik Kasa" "Research"
/new-vault DesignVault "Tasarım Kasası" "Creative"
```

## Akış

1. `html-vault-generator` skill spawn edilir
2. Template `templates/vault-template.html` kullanılır
3. Token replace (vault name, başlık, disiplin)
4. `index.html` güncellenir (yeni vault listede)
5. `i18n-translator` agent ile dil dosyaları update
6. İlk commit önerisi

## Üretilen

- `{VaultName}.html` — stand-alone, < 80 KB
- `index.html` — güncellenmiş vault listesi
- `locales/tr.json`, `locales/en.json` — yeni key'ler
- (opsiyonel) `tests/schema/{VaultName}.test.js`

## Çıktı

```
✨ Yeni vault oluşturuldu
   Dosya: AcademicVault.html (76 KB)
   index.html'e eklendi
   i18n: 3 yeni key (TR + EN)
   Test paketi: tests/schema/AcademicVault.test.js ✅
   
Sonraki adım: /vault-add AcademicVault "İlk öğe" "..."
```
