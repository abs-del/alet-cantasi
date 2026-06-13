---
name: html-vault-generator
description: Yeni bir vault HTML'i oluşturur. Mevcut 100 vault'un şablonuna birebir uyar (UI, CSS, JS, data island şeması). Stand-alone, zero-server, çevrimdışı çalışabilir.
---

# HTML Vault Generator

Yeni vault yaratma için template'li üretici. Kullanıcı "Bir 'AcademicVault' istiyorum" derse, bu skill devreye girer.

## Girdi sözleşmesi

```yaml
vault_name: AcademicVault
title_tr: "Akademik Kasa"
title_en: "Academic Vault"
description: "Bilimsel makale özetleri ve referansları"
discipline: "Research"  # 6 disiplinden biri
categories:              # min 3, max 12
  - "Methodology"
  - "Statistics"
  - "Literature Review"
seed_items_count: 0       # opsiyonel, ilk içerik
custom_fields: []         # şemayı kırmadan eklenir
```

## Çıktı

`AcademicVault.html` — stand-alone dosya:
- `<style>` ile mevcut karanlık tema CSS variable'ları
- `<script id="data" type="application/json">` data island
- Sidebar / list / detail layout (responsive)
- Klavye kısayolları (öneri 27)
- Markdown render (öneri 69, marked + DOMPurify)
- API key save (encrypted, öneri 77)
- Export butonları (MD/JSON/CSV — öneri 46–48)

## Şablon

`templates/vault-template.html` — bir vault'un boilerplate'i. Her oluşturmada:
1. `{{VAULT_NAME}}`, `{{TITLE_TR}}`, `{{DISCIPLINE}}` token'ları replace edilir
2. `data` island boş `[]` ile başlar (veya seed_items varsa onlarla)
3. CSP meta tag mevcut: `default-src 'self'; ...`
4. SRI hash'li CDN bağımlılıkları (marked, DOMPurify, lucide)

## Tek dosya boyut hedefi

- Boş vault: < 80 KB (template + JS + CSS)
- 100 öğe ile: < 200 KB
- Sonra: `lz-string` ile gerekirse sıkıştır

## index.html güncelleme

Yeni vault üretildiğinde `index.html`'in vault listesi otomatik güncellenir:
```js
// index.html data island
VAULTS.push({
  file: "AcademicVault.html",
  name: "Akademik Kasa",
  discipline: "Research",
  itemCount: 0,
  size: "78 KB",
  icon: "🎓"
});
```

## Test (üretim sonrası otomatik)

`qa-expert` agent çağrılır:
- HTML W3C validate
- Lighthouse perf ≥ 85, a11y ≥ 95
- Şema testi: ilk render'da `items.length === seed_items_count`
- Çevrimdışı: SW register, refresh çevrimdışı modda çalışıyor

## Yasak

- Yeni vault'a başka bir vault'un kodunu **kopyala-yapıştır** yapma — template'ten üret.
- Şema dışı zorunlu alan ekleme.
- Backend endpoint zorunluluğu ekleme.
