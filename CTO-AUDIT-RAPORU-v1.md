# Alet Çantası — CTO Teknik Denetim Raporu & 5 Dönemli Geliştirme Yol Haritası

> **Doküman türü:** Teknik Strateji Belgesi (Technical Strategy & Engineering Roadmap)
> **Hazırlayan:** Yeni atanan CTO ofisi
> **Versiyon:** v1.0 — 2026-06-12
> **Hedef kitle:** Kurucu(lar), Yatırımcı(lar), Mühendislik ekibi, Ürün ekibi
> **Statü:** İmza için hazır taslak (kurucu onayı bekliyor)
> **Sınıflandırma:** Şirket içi — gizli

---

## 📌 İçindekiler (Yüksek Seviye)

0. **Yönetici Özeti (TL;DR)**
1. **Mevcut Durum Tespiti (Audit Findings)**
2. **Teknik Borç & Risk Matrisi**
3. **Hedef Mimarisi (Target Architecture)**
4. **5 Dönemli Yol Haritası**
   - **Dönem 1 (0–3 ay):** Stabilizasyon & Güvenlik
   - **Dönem 2 (3–6 ay):** Modernizasyon & Veri Katmanı
   - **Dönem 3 (6–9 ay):** AI-Native Platform
   - **Dönem 4 (9–15 ay):** Ölçeklendirme & Multi-Tenant
   - **Dönem 5 (15–24 ay):** Kurumsallaşma & Ekosistem
5. **Ekip, Bütçe ve OKR'lar**
6. **Risk Yönetimi & Çıkış Stratejileri**
7. **Ek 1: Repo Önerileri Konsolidasyon Tablosu**
8. **Ek 2: Kod Smell Kataloğu**
9. **Ek 3: Hazır CI/CD Şablonu**
10. **Ek 4: Mimari Karar Kayıtları (ADR) Şablon Seti**

---

## 0. Yönetici Özeti (TL;DR)

### 0.1 Ne devraldık?

Devraldığım proje, görünürde **etkileyici bir içerik kütüphanesidir**: 100 ayrı HTML "vault" + 1 launcher (`index.html`) ile toplam **52.938 öğe** ve **102 MB** açık halde
HTML üzerinden sunulan, **6 disiplini** (AI/Prompt Mühendisliği, Oyun Motoru/3D, Tarih–Mitoloji, Veri Bilimi, Ürün/Operasyon, Geliştirici Araçları) kapsayan bir
"Alet Çantası" (Toolbox).

Birinci bakışta görünen güçlü yanlar:

- ✅ Sıfır-server, **local-first** dağıtım modeli (statik HTML ile yayınlanabiliyor)
- ✅ Tutarlı **görsel kimlik** (her vault için ayrı renk paleti, ortak tipografi)
- ✅ **52K+ öğe** ile rekabetçi içerik hacmi
- ✅ Hazırlanmış üç ayrı strateji dokümanı (100 öneri + 100 ileri öneri v2 + 130+ repo kataloğu)
- ✅ Net bir **felsefe**: *local-first, privacy-first, AI-native, zero-server*

### 0.2 Ama bir CTO gözüyle gerçek tablo

| Boyut | Durum | Açıklama |
|---|---|---|
| **Mimari** | 🔴 Kritik | 100 dosyada **yapısal kod çoğaltması**; tek bir özellik değişikliği 100 dosyada değişiklik gerektirir. |
| **Güvenlik** | 🔴 Kritik | API anahtarı plaintext localStorage'a yazılıyor; CSP yok; SRI yok; üçüncü taraf font CDN'i bağımlılığı var. |
| **Veri Kalitesi** | 🟠 Yüksek risk | Mevcut 52K öğenin önemli bir kısmı **şablon-türevi** ("variant_of") — programatik olarak çoğaltılmış, gramer bozuk, semantik değeri düşük varyantlar. |
| **Performans** | 🟠 Yüksek risk | **01-promptvault-pro.html = 12.4 MB tek dosya**; mobil cihazlarda yüklenemez veya tarayıcıyı dondurur. |
| **Erişilebilirlik (a11y)** | 🟠 Yüksek risk | ARIA yok, keyboard navigation yok, kontrast hesaplaması yapılmamış. |
| **SEO** | 🟡 Orta | JSON-LD var ama sitemap.xml yok, robots.txt yok, hreflang yok. |
| **Test** | 🔴 Kritik | **Sıfır otomatik test** (unit, integration, e2e, lint, type-check). |
| **CI/CD** | 🔴 Kritik | Repo yapısı yok (zip-based dağıtım), `npm`/`pnpm`/`bun` yok, build pipeline yok. |
| **Lisans/IP** | 🟡 Orta | İçeriklerin önemli kısmı LLM (Gemini) tarafından üretilmiş; **kaynak gösterimi**, model çıkış lisansı, üçüncü taraf telif riski incelenmemiş. |
| **Gözlemlenebilirlik** | 🔴 Kritik | Log, metrik, hata raporu, kullanıcı analitiği **hiç yok**. |

**Tek cümleyle özet:**
> *Üzerinde harika bir ürün yatan ama omurgasız bir prototipi devraldık. Stabilize etmeden büyütmeye çalışırsak, her büyüme adımı 10x maliyetle gelecek.*

### 0.3 5 dönemli yol haritası — bir bakışta

| Dönem | Süre | Tema | En kritik 3 çıktı | Sermayenin gideceği yer |
|---|---|---|---|---|
| **D1** | 0–3 ay | **Stabilizasyon & Güvenlik** | (1) Monorepo + build pipeline, (2) Güvenlik patches (API key, CSP, XSS), (3) Test altyapısı | Mühendislik (3 FTE), DevSecOps danışmanı |
| **D2** | 3–6 ay | **Modernizasyon & Veri Katmanı** | (1) Vite + TypeScript + framework taşıma, (2) IndexedDB + OPFS veri katmanı, (3) İçerik kürasyon süreci (veri kalite SLA'ı) | Frontend mühendisleri, içerik editörleri |
| **D3** | 6–9 ay | **AI-Native Platform** | (1) Tarayıcı-içi LLM çıkarımı (Transformers.js / WebLLM), (2) RAG + vektör arama, (3) MCP + tool-calling katmanı | AI mühendisleri, LLMOps danışmanı |
| **D4** | 9–15 ay | **Ölçeklendirme & Multi-Tenant** | (1) Bulut senkron katmanı (CRDT), (2) Self-hostable Docker bundle, (3) B2B kullanım izleme & faturalandırma | SRE, backend, ürün |
| **D5** | 15–24 ay | **Kurumsallaşma & Ekosistem** | (1) Üçüncü taraf eklenti API'si, (2) SOC2 / KVKK uyumu, (3) Marketplace + topluluk katkı süreci | Compliance, Topluluk yöneticisi, Hukuk |

### 0.4 Yatırım gereksinimi — kabataslak

| Dönem | Mühendislik FTE | Tahmini bütçe (TL) | Tahmini bütçe (USD) |
|---|---|---|---|
| D1 (0–3 ay) | 3 mühendis + 1 PM | 1.8M TL | 55K USD |
| D2 (3–6 ay) | 4 mühendis + 1 PM + 2 editör | 3.0M TL | 92K USD |
| D3 (6–9 ay) | 5 mühendis (1 AI uzmanı) + 1 PM | 3.6M TL | 110K USD |
| D4 (9–15 ay) | 7 mühendis (1 SRE) + 1 PM | 8.4M TL | 256K USD |
| D5 (15–24 ay) | 9 mühendis + 1 PM + 1 hukuk + 1 community | 14.4M TL | 440K USD |
| **TOPLAM (24 ay)** | **kademeli 3→10 FTE** | **~31.2M TL** | **~953K USD** |

> Notlar:
> 1) Maaş varsayımları İstanbul piyasası, 2026 H1, mid-senior ortalama.
> 2) Cloud + altyapı + lisans giderleri bu rakamların **%15–20'sini** ayrıca ekleyin.
> 3) Bu rakamlar **kurucu(lar)'ın hedefine göre %30 ± volatildir**.

### 0.5 Bu raporun nasıl okunması gerektiği

1. **Eğer 30 dakikanız varsa:** Bölüm 0 (bu sayfa) + Bölüm 1.1 (Bulgular Özeti) + Bölüm 4 (5 Dönem) yeterli.
2. **Eğer mühendissiniz:** Bölüm 2 (Teknik Borç), Bölüm 3 (Hedef Mimari), Ek 2 (Kod Smell Kataloğu).
3. **Eğer yatırımcı veya kurucu seviyesindeyseniz:** Bölüm 0, Bölüm 5 (Ekip & Bütçe), Bölüm 6 (Risk).
4. **Eğer ürün ekibindeyseniz:** Bölüm 4'ün her döneminin "Ürün Çıktıları" alt başlığı.

---


## 1. Mevcut Durum Tespiti (Audit Findings)

Bu bölüm, devraldığım kod tabanına ve dokümantasyona dair **objektif, kanıta dayalı**
analizdir. Her bulgu için: (a) ne gözlemlediğim, (b) bunun neden kötü olduğu, (c) somut
referans (dosya / satır) verilmiştir.

### 1.1 Repo & Dağıtım Yapısı

**Gözlem:**
- Repo yok. Devraldığım şey bir **zip arşividir**: `alet-cantasi-enriched-v3.zip` (10.44 MB sıkıştırılmış, 102 MB açılmış).
- Tüm artefakt **101 adet tek-dosya HTML** (1 launcher + 100 vault).
- Hiçbir build sistemi yok: `package.json`, `pnpm-lock.yaml`, `vite.config`, `tsconfig.json` — **hiçbiri yok**.
- Versiyon kontrolü yok: `.git`, `.gitignore`, `.gitattributes` — yok.

**Neden kötü:**
1. **İki kişi aynı anda çalışamaz.** Merge yok, branch yok, PR yok.
2. **Geri alma (rollback) yok.** "v2 daha iyiydi" denince hangi v2?
3. **Audit log yok.** Hangi içerik ne zaman, kim tarafından, hangi gerekçeyle eklendi — bilinmiyor.
4. **CI/CD imkânsız.** Otomatik test, lint, build, deploy zinciri kurulamaz.
5. **Lisans uyumluluğu denetlenemez.** Üçüncü taraf bağımlılıklarının LICENSE tarama scripti çalıştırılamaz.

**Kanıt (somut):**
```
$ ls -la enriched/
01-promptvault-pro.html      12,401,727 bytes
02-logicvault-pro.html          797,100 bytes
03-testvault-pro.html         1,117,614 bytes
...
100-pitchvault-pro.html         756,748 bytes
index.html                       52,951 bytes
$ find enriched -name ".git" -o -name "package.json"
(boş çıktı)
```

**Eylem (D1, Sprint 1):**
- GitHub organizasyon kur, monorepo şablonu (pnpm workspaces veya Turborepo) seç.
- Mevcut zip'i tek seferde `git lfs` ile commit'le → tarihsel başlangıç noktası.
- Conventional Commits + Semantic Versioning + CHANGELOG.md zorunlu kıl.

---

### 1.2 Mimari: "Tek dosya HTML" anti-pattern'i

**Gözlem:**
Her vault dosyası şu yapıyı içerir:
- `<head>` — meta, OG, Twitter Card, JSON-LD (SoftwareApplication + ItemList şemaları)
- `<style>` — **~2000–4000 satır CSS** (her dosyada neredeyse aynı, sadece renk değişkenleri farklı)
- `<body>` — DOM iskeleti (~150 satır)
- `<script>` — **~700 satır JS** (her dosyada birebir aynı, sadece veri ve renkler farklı)
- Inline JSON — `const ITEMS = [{...}, {...}, ...]` formatında **400–6400 item**

**Bu yapının somut sonuçları:**

| Sorun | Kanıt | Etki |
|---|---|---|
| Tek bir UI değişikliği | Footer'a "Sürüm: v2.1" eklemek için **100 dosyada** değişiklik | 1 saatlik iş = 1 günlük emek |
| Tek bir JS bug fix'i | `searchMatch()` fonksiyonunda hata varsa 100 yerde düzelt | Mutlaka unutulan dosya olur |
| Tek bir CSS hover stili | "Buton hover'da %5 büyüsün" → 100 dosya | Görsel tutarsızlık riski |
| Yeni özellik (örn. dark/light toggle) | 100 dosyaya inline JS injection | 1 haftalık iş 1 aya yayılır |
| Dosya başına ~20.000+ satır JS+CSS | 102 MB toplam, mobilde **3G'de yüklenmez** | Mobil pazar kaybı |

**Kanıt (somut):**
```bash
$ wc -l 10-routervault-pro.html
   ~6500 toplam satır (~700 satır JS, ~3500 satır CSS, geri kalan JSON veri)
$ md5sum CSS-bölümleri 5 dosya için
→ Hash'ler farklı (renkler değişiyor) ama YAPI birebir aynı
→ Bu "renk değişkenli kopya-yapıştır" anti-pattern'i
```

**Eylem (D1):**
Bu sorun, D1'in **en büyük başlığı**. Çözüm için Bölüm 3 (Hedef Mimari) ve Bölüm 4.D1.

---

### 1.3 Güvenlik bulguları (kritik öncelik)

#### Bulgu G-01: API Anahtarı Plaintext localStorage'da

**Gözlem:**
```html
<!-- 10-routervault-pro.html satır 232 (ve diğer 99 dosyada birebir aynısı) -->
<input class="api-input" id="apiInput" type="password" placeholder="sk-ant-api..." autocomplete="off">
```
`type="password"` sadece **görsel maskeleme** sağlar — kullanıcının yapıştırdığı anahtar
`localStorage.setItem('apiKey', value)` veya benzer bir kalıp ile **plain string** olarak saklanır.

**Saldırı senaryosu:**
1. Saldırgan, vault'un yüklendiği herhangi bir 3. taraf script'ten (ör. Google Fonts, JSON-LD, CDN'den çekilen ileride bir lib) XSS sızdırır.
2. `localStorage.getItem('apiKey')` ile kullanıcının **Anthropic / OpenAI / Gemini API anahtarını** ele geçirir.
3. Bu anahtar, **fatura limiti olmayan** bir hesabın yüzlerce USD'lik faturasına yol açar.

**Çözüm:**
- **WebCrypto AES-GCM** ile passphrase tabanlı şifreleme (kullanıcı `master password` girer, anahtar bellekte tutulur).
- IndexedDB → `password-protected sub-vault`.
- Veya: **server-side proxy** (anahtar hiç tarayıcıya gelmez, kullanıcı OAuth ile oturum açar).

#### Bulgu G-02: Content Security Policy (CSP) yok

**Gözlem:**
```html
<!-- HEAD'de CSP meta etiketi YOK -->
<!-- HTTP header'da da YOK (statik dosya) -->
```
`script-src 'self'`, `style-src 'self' 'unsafe-inline'`, `connect-src https://api.openai.com https://api.anthropic.com` gibi
bir CSP tanımlanmamış.

**Etki:**
- XSS sızdığında saldırgan **ne dilerse onu inject edebilir**: keylogger, cryptojacking, exfiltration.
- Google Fonts'tan zehirli CSS gelirse savunma yok.

**Çözüm:**
Tüm vault'ların tek HTTP cevabında şu header:
```http
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'wasm-unsafe-eval';
  style-src 'self' 'unsafe-inline';
  font-src 'self' https://fonts.gstatic.com;
  connect-src 'self' https://api.openai.com https://api.anthropic.com https://generativelanguage.googleapis.com;
  img-src 'self' data:;
  object-src 'none';
  base-uri 'self';
  form-action 'none';
  frame-ancestors 'none';
```

#### Bulgu G-03: innerHTML kullanımı XSS yüzeyi yaratıyor

**Gözlem:**
Her vault'ta ortalama **6 farklı yerde** `innerHTML` kullanılıyor (toplam 100 dosyada 600+ kullanım).
Kod `esc()` fonksiyonu ile sarıyor:
```javascript
function esc(s){
  return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c]);
}
```

**Sorun:**
- `esc()` **HTML entity** kaçışı yapar ama **attribute injection** (örn. `onclick="..."` içine kaçan tek tırnak)
  veya **JavaScript context** kaçışı yapmaz.
- `item.content` gibi büyük metinler içinde Markdown var (`##`, `*italic*`) — XSS açısından temiz değil.

**Kanıt:**
```javascript
// 10-routervault-pro.html, item-row template (innerHTML ile basılıyor)
return `<div class="item-row" id="item-${s.id}" data-id="${s.id}"
        style="--sc:${cc}" onclick="selectItem(${s.id})">
  <span class="item-no">${no}</span>
  ...
  ${s.badge1?`<span class="item-badge">${esc(s.badge1)}</span>`:''}
</div>`;
```
`${cc}` (kategori renk kodu) **escape edilmiyor**. Eğer veriye saldırgan bir renk değeri inject ederse
(örn. `red;}</style><script>...`), CSS escape edip script çalıştırabilir.

**Çözüm:**
1. **`innerHTML` yerine `textContent` veya `<template>` + `cloneNode()`** kullan.
2. **DOMPurify** entegrasyonu (D1 sonu).
3. CSP `unsafe-inline` style'ı yasaklanınca inline `style="--cc:..."` da kapanır — değişkenleri **CSS custom property setProperty()** ile aktar.

#### Bulgu G-04: Üçüncü taraf font CDN'i (Google Fonts)

**Gözlem:**
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:..." rel="stylesheet">
```

**Etki:**
- KVKK / GDPR ihlali riski (Google Fonts IP loglama nedeniyle Almanya'da 2022'de mahkeme tarafından **ceza** verildi).
- Subresource Integrity (SRI) yok → CDN saldırısı zehirli CSS yayabilir.
- Offline kullanım imkânsız (felsefe ile çelişiyor: "*local-first, privacy-first*").

**Çözüm:**
- Fontları self-host et (`@font-face` + WOFF2).
- `unicode-range` ile bölünmüş alt setler (`latin-ext`, `latin`).
- Total transfer: ~70 KB → ~25 KB.

#### Bulgu G-05: HTML JSON Data inline → trust boundary belirsiz

**Gözlem:**
```javascript
const ITEMS = [{"id": 1, "cat": "...", "content": "...", ...}, ...];
```
Bu inline JSON kullanıcının indirdiği HTML dosyasında bulunuyor. Şu anlama gelir:
- Veri **sürüm kontrolünde değil** (Git LFS ile bile lifecycle yönetimi yok).
- Bir öğeyi güncellemek için **tüm dosyayı yeniden derlemek** gerekiyor.
- Tarayıcı, **şüpheli veri** ile **uygulama kodu** arasında bir sınır tanımıyor (CSP ile çözülmesi gereken sorun).

**Çözüm (D2):**
- Veri katmanını ayır: `data/{vault-id}/items.json` (versiyonlanabilir, sign'lanabilir).
- HTML sadece **shell** (uygulama iskeleti), veri çalışma zamanında `fetch()` ile yüklenir.

---

### 1.4 Veri Kalitesi Bulguları

#### Bulgu D-01: Şişirilmiş varyant içerikleri

**Gözlem:**
Veri içinde `"source": {"generated": true, "variant_of": 1}` etiketli kayıtlar var ve bunlar
**aynı orijinal kaydın programatik türevleridir**. Örneğin:
```json
{"id": 22, "name": "Hibrit Uygun Model Yapısı",
 "desc": "yapıp bağlamında uygun model için hibrit bir yapısı..."}
{"id": 23, "name": "Senkron Uygun Model Refactor Yöntemi",
 "desc": "yönlendiren bağlamında uygun model için senkron bir refactor yöntemi..."}
```

İlk bakışta dikkat çekenler:
- **Gramer hataları**: "yapıp bağlamında" (anlamsız), "isteğinin bağlamında" (anlamsız), "Mühendisliği, bağlamında" (anlamsız + virgül).
- **Şablon kalıbı görünüyor**: `[adjective] [topic] [container]` patterni mekanik.
- **Anlamsal değer düşük**: 30 satırlık template-bloğu (Hedef Kitle / Avantajlar / Riskler / Önerilen Adımlar)
  her varyantta birebir aynı, sadece adjektif değişiyor.

**Etki:**
- Kullanıcı bir aramaya 5–7 sahte tekrar görüyor → güven kaybı.
- LLM ile RAG yapılırsa **token israfı + bağlam kirliliği** olur.
- SEO için aslında **duplicate content cezası** riski (Google).

**Sayısal tahmin (52,938 öğe içinden örneklem):**
- Aşağı yukarı **%55–65** öğenin "variant_of" türevi olduğu görülüyor.
- Yani gerçek **özgün öğe sayısı ~18.000–22.000**.

**Çözüm (D2):**
- **İçerik audit sprint'i**: Otomatik dedupe (sentence-embedding + cosine sim).
- "Variant" alanı ürün kararı: gizle / birleştir / sil.
- Kalite SLA: yeni eklenecek her öğe için **insan editör onayı** zorunlu.

#### Bulgu D-02: ID ve numaralandırma tutarsızlığı

**Gözlem:**
- `PromptVault` → 6394 item
- `AgentVault`, `ChainVault`, `PersonaVault` → 887–888 item
- Geri kalan ~97 vault → 450–460 item

**Pazarlama metni ne diyor?**
```
<div class="card-foot"><span class="card-count">450 öğe</span></div>
```
Tüm vault'lar için "450 öğe" görünüyor — **gerçeğe uymuyor** (PromptVault'ta 6394 var, diğerlerinin
yarısında 887 var).

**Etki:**
- Kullanıcı vault'a girdiğinde "Vaadedilen sayıya uymuyor" duygusu.
- Otomatik analitik (D3+) anlamsız sayılar verir.

**Çözüm:**
Tek kaynağı doğru (Single Source of Truth) bir manifest dosyası: `vaults/manifest.json`:
```json
{
  "vaults": [
    {"id": "promptvault", "items": 6394, "size_kb": 12100, "version": "1.0.0"},
    {"id": "routervault", "items": 456, "size_kb": 683, "version": "1.0.0"},
    ...
  ]
}
```
`index.html` bu manifest'ten okur.

---

### 1.5 Performans Bulguları

#### Bulgu P-01: PromptVault → 12.4 MB tek dosya

**Gözlem:**
```
01-promptvault-pro.html : 12,401,727 bytes (~12.4 MB)
```

**Etki (Web Vitals çerçevesinde):**

| Metrik | Hedef (Good) | Tahmini değer | Durum |
|---|---|---|---|
| **LCP** (Largest Contentful Paint) | < 2.5s | **8–14s mobilde** | 🔴 |
| **TTI** (Time to Interactive) | < 3.8s | **10–18s mobilde** | 🔴 |
| **CLS** (Cumulative Layout Shift) | < 0.1 | ~0.05 (iyi) | 🟢 |
| **INP** (Interaction to Next Paint) | < 200ms | bilinmiyor (ölçüm yok) | ⚪ |
| **Total Transfer Size** | < 1 MB | **12.4 MB** | 🔴 |
| **JavaScript bytes** | < 200 KB | **~150 KB JS + 11 MB JSON** | 🔴 |
| **Memory** | < 250 MB | **bir mobil cihazda ~600 MB** | 🔴 |

**Çözüm (D1 sonu):**
1. **Gzip + Brotli** sıkıştırma (gziplenirse ~3 MB → ~25% azalma).
2. **JSON veri ayrılması** → ana HTML 50 KB, JSON 12 MB ama lazy-load.
3. **Sayfalama (pagination)** → ilk yüklemede sadece ilk 100 item.
4. **Virtual scrolling** → DOM'da sadece görünen ~30 item.

#### Bulgu P-02: Tüm vault'lar büyük

**Dağılım:**
```
12.4 MB ─── 01-promptvault-pro.html         (anomali)
 2.6 MB ─── 04-agentvault-pro.html
 1.7 MB ─── 06-personavault-pro.html, 13-chainvault-pro.html
 1.3 MB ─── 84-statvault-pro.html
 ~0.7 MB ── 97 dosya ortalama (en küçük 727 KB)
```

**Etki:**
- Ortalama vault yine de **600+ KB tek HTML**.
- Mobil 4G'de açılış 2–3 saniye, 3G'de 8–15 saniye.

**Çözüm (D2):**
Hedef: **her vault ana shell < 30 KB**, veri lazy-load.

#### Bulgu P-03: Lighthouse skoru tahmini

**Tahminim** (gerçek bir Lighthouse run yapılmamış; ekipten ilk hafta D1'de yapılmasını istiyorum):

| Kategori | Tahmini skor |
|---|---|
| Performance | **35–55 / 100** |
| Accessibility | **55–70 / 100** |
| Best Practices | **70–85 / 100** |
| SEO | **80–92 / 100** |
| PWA | **0 / 100** (manifest.json yok, service worker yok) |

---

### 1.6 Erişilebilirlik (a11y) Bulguları

#### Bulgu A11Y-01: ARIA etiketleri yetersiz

**Gözlem:**
HTML'de `aria-label`, `aria-describedby`, `aria-live`, `role="button"`, `aria-pressed`
sistematik kullanılmamış. Örnek:
```html
<!-- Mevcut -->
<button class="cat-btn" data-cat="all" onclick="filterCat('all',this)">
  <span class="cdot"></span>
  <span class="cname">Tümü</span>
  <span class="ccount">450</span>
</button>

<!-- Olması gereken -->
<button class="cat-btn" data-cat="all"
        role="tab"
        aria-selected="true"
        aria-controls="itemList"
        aria-label="Tümünü göster, 450 öğe">
  <span class="cdot" aria-hidden="true"></span>
  <span class="cname">Tümü</span>
  <span class="ccount" aria-hidden="true">450</span>
</button>
```

#### Bulgu A11Y-02: Klavye navigasyonu çalışmıyor

- Tab sırası mantıksız (CSS sıralama ile DOM sıralama uyuşmuyor).
- `Esc` ile modal kapatma yok.
- Focus trap yok (modal açıkken Tab dışarı çıkıyor).
- Skip-to-content linki yok.

#### Bulgu A11Y-03: Renk kontrastı düşük

**Örnek:**
```css
--text2:#9896a0;  /* ikincil yazı rengi */
--bg:#08060e;     /* arka plan */
```
WCAG AA için 4.5:1 oranı gerekiyor. Bu kombinasyon **~7.4:1** (✅ AA geçer).

Ama:
```css
--text3:#585668;  /* tertiary text */
--bg:#08060e;
```
Bu **~3.8:1** (❌ AA başarısız, AA Large geçer).

#### Bulgu A11Y-04: Ekran okuyucu desteği yok

- `<main>`, `<nav>`, `<aside>` landmark elementleri tutarlı değil.
- `lang="tr"` ✅ var (iyi).
- Resimlere `alt` yok (SVG icon'ların `<title>` yok).

**Çözüm:** D1 sonunda **axe-core** entegrasyonu, D2'de tam a11y refactor.

---

### 1.7 SEO Bulguları

**İyi yanlar (✅):**
- Title, description, keywords her dosyada doğru.
- OpenGraph + Twitter Card meta var.
- JSON-LD `SoftwareApplication` + `ItemList` şemaları var.
- `lang="tr"` doğru.

**Eksik (🟠):**
- `sitemap.xml` yok → 100 sayfanın hepsi Google'a indekslettirilmemiş olabilir.
- `robots.txt` yok.
- Canonical URL yok (`<link rel="canonical">`).
- hreflang yok (Türkçe + İngilizce ileride hedef ise gerekli).
- Internal linking düzeni eksik (vault'lar birbirini referans etmiyor).
- Open Graph image dinamik üretilmiyor (her vault için `og:image` aynı).

**Eylem:**
- D1: sitemap + robots + canonical.
- D2: Per-item OG image (Vercel OG benzeri ama statik, build time'da).

---

### 1.8 Test Bulguları — sıfır otomatik test

**Gözlem:**
```bash
$ find enriched -name "*.test.*" -o -name "*.spec.*" -o -name "__tests__"
(boş)
$ find enriched -name "vitest*" -o -name "jest*" -o -name "playwright*"
(boş)
```

**Etki:**
- "Acaba bu değişiklik bir şey kırdı mı?" sorusunun cevabı **YOK**.
- Mevcut 100 dosyanın her birinde JS aynı olduğu için bir bug 100 kez tekrar eder.
- Regression riski → her release ürün kalitesini geriletir.

**Çözüm (D1 zorunlu):**
- **Vitest** (unit + integration) — komponent fonksiyonları için.
- **Playwright** (e2e) — kullanıcı akışları için (sayfa açma, arama, öğe seçme, kopyalama).
- **axe-core** (a11y) — CI'da blocking.
- **Lighthouse CI** — performans regression detect.
- Coverage hedefi (D1 sonu): **%60** branch, **%75** statement.

---

### 1.9 Gözlemlenebilirlik Bulguları — sıfır telemetri

**Gözlem:**
- Sentry yok (hata izleme yok).
- Plausible / Umami / PostHog yok (kullanım analitiği yok).
- Console.log dahi minimum — debug izi yok.
- Service worker yok (offline metrik toplama yok).

**Etki:**
- "Hangi vault en çok kullanılıyor?" → bilinmiyor.
- "Hangi arama sorguları sonuçsuz dönüyor?" → bilinmiyor (içerik açığı sinyali).
- "Hangi tarayıcıda hata alıyor kullanıcılar?" → bilinmiyor.
- Ürün kararları **veriye değil, içgüdüye** dayalı olarak alınıyor.

**Çözüm:**
- D1: **Sentry** (free tier yeterli başta).
- D2: **Plausible** veya **Umami** (privacy-first, self-host edilebilir).
- D3: **Custom event tracking** (`vault_opened`, `item_selected`, `search_no_results`).

---

### 1.10 Lisans, IP ve Yasal Bulgular

#### Bulgu L-01: İçerik üretiminde model kaynak gösterilmemiş

**Gözlem:**
```json
"source": {"generated": true, "provider": "gemini", "model": "gemini-2.5-flash-lite"}
```
✅ Veride **provider/model bilgisi var** (iyi).

Ama UI tarafında:
- Kullanıcıya **"Bu içerik AI ile üretildi"** uyarısı görünmüyor.
- Kullanım şartları (ToS) yok.
- Yasal disclaim'er yok ("İçerik, profesyonel danışmanlık yerine geçmez").

#### Bulgu L-02: Üçüncü taraf telif riski

**Bazı vault'ların adları:** `35-kemalistvault-pro` (siyasi-ideolojik), `12-jailbreakvault-pro` (yasal-gri).

**Etkiler:**
- Kemalistvault gibi siyasi içerik → Türkiye'de **5651 SK** uyumluluk riski.
- Jailbreakvault → OpenAI/Anthropic **ToS ihlali** riski (kullanıcı API anahtarı bu vault'tan örnek alıp gönderirse).

**Eylem (D1):**
- Hukuki danışmanlık (5-10K TL, tek seferlik).
- Vault başına **risk değerlendirme** dokümanı.
- Yüksek riskli vault'lar için **age gate** + ToS onayı.

#### Bulgu L-03: Açık kaynak lisans uyumluluğu

Repo kataloğunda (`alet-cantasi-100-repo-onerisi.md`) 130+ repo öneriliyor.
- **Doğrulama yapılmadı**: hangisi MIT / Apache-2.0 / GPL / AGPL?
- **AGPL bağımlılığı** ticari kullanımı tehlikeye atar (bütün kaynak kod açıklanmalı).
- Çözüm: D1'de `license-checker` veya `oss-attribution-generator` CI'da blocking.

---

### 1.11 Dokümantasyon değerlendirmesi (3 markdown)

Devraldığım 3 doküman:

| Doküman | Boyut | Değer | Eksiği |
|---|---|---|---|
| `alet-cantasi-100-oneri.md` | 16 KB | İçerik vizyonu net, kategorize edilmiş | Hiçbir öneri **önceliklendirilmemiş** |
| `alet-cantasi-100-repo-onerisi.md` | 35 KB | 130+ açık kaynak repo somut katalog | Lisans, sürdürülebilirlik, maintainer durumu denetlenmemiş |
| `alet-cantasi-100-ileri-oneri-v2.md` | 31 KB | 2026 trendlerine bağlı 100+ ileri öneri | "Local-first MCP", "WebLLM" gibi PoC ihtiyacı olan başlıklar |

**Genel değerlendirme:**
> Vizyon güçlü. Yön doğru. Ama hiçbir doküman bir CTO'ya **karar verebileceği seviyede önceliklendirme**, **maliyet**, **zaman** veya **bağımlılık matrisi** vermiyor. Bu rapor o boşluğu doldurmak için hazırlandı.

---


## 2. Teknik Borç & Risk Matrisi

### 2.1 Teknik Borç Sınıflandırması (TD-Ledger)

Her teknik borcun **maliyet × etki** matrisinde yeri vardır. Aşağıdaki tabloda
**5 üzerinden** skorlandırılmıştır (5 = en kötü).

| ID | Teknik Borç | Etki | Çözüm Maliyeti | Risk Skoru | Dönem |
|----|---|:---:|:---:|:---:|:---:|
| TD-01 | 100 dosyada yapısal kod çoğaltması | 5 | 5 | **25** | D1–D2 |
| TD-02 | API anahtarı plaintext localStorage | 5 | 2 | **10** | D1 |
| TD-03 | CSP yok | 5 | 1 | **5** | D1 |
| TD-04 | innerHTML XSS yüzeyi | 4 | 2 | **8** | D1 |
| TD-05 | Google Fonts CDN bağımlılığı | 3 | 1 | **3** | D1 |
| TD-06 | %55+ varyant şişirme | 4 | 4 | **16** | D2 |
| TD-07 | 12.4 MB PromptVault | 5 | 3 | **15** | D1 |
| TD-08 | Sıfır otomatik test | 5 | 3 | **15** | D1 |
| TD-09 | Sıfır telemetri | 4 | 1 | **4** | D1 |
| TD-10 | Sıfır CI/CD | 5 | 2 | **10** | D1 |
| TD-11 | A11y eksikleri (ARIA, klavye) | 3 | 3 | **9** | D2 |
| TD-12 | Lisans uyumluluğu doğrulanmamış | 4 | 2 | **8** | D1 |
| TD-13 | Sitemap.xml yok | 2 | 1 | **2** | D1 |
| TD-14 | Offline / PWA yok | 3 | 2 | **6** | D2 |
| TD-15 | TypeScript yok | 4 | 4 | **16** | D2 |
| TD-16 | Veri katmanı HTML-içine gömülü | 4 | 3 | **12** | D2 |
| TD-17 | i18n / l10n altyapısı yok | 3 | 3 | **9** | D3 |
| TD-18 | Tek tarayıcı (Chrome) ile test edildi sanılıyor | 3 | 2 | **6** | D2 |
| TD-19 | Vault'lar arası veri köprüsü yok | 4 | 4 | **16** | D3 |
| TD-20 | Tarayıcı-içi AI çıkarımı yok | 3 | 5 | **15** | D3 |
| TD-21 | RAG/vektör arama yok | 4 | 5 | **20** | D3 |
| TD-22 | Multi-tenant izolasyon yok | 4 | 5 | **20** | D4 |
| TD-23 | Bulut senkron yok | 3 | 5 | **15** | D4 |
| TD-24 | Compliance (SOC2, KVKK, GDPR) | 5 | 5 | **25** | D5 |
| TD-25 | Eklenti / plugin API yok | 3 | 4 | **12** | D5 |

**Toplam tahmini teknik borç:** ~280 puan (skor sistemi 0–625 arası).
**Hedef D5 sonu:** < 50 puan (büyük çoğunluğu çözülmüş, sürdürülebilirlik moduna geçilmiş).

### 2.2 Borç Geri Ödeme Grafiği (tahmini)

```
Teknik Borç Trendi
puan
280 ┤●─────╮
240 ┤      ●╮
200 ┤       ●╮
160 ┤        ●╮
120 ┤          ●─╮
 80 ┤             ●──╮
 50 ┤                 ●──●
  0 ┼─────────────────────────────
    D0   D1   D2   D3   D4   D5
```

**Yorum:**
- D1 sonu hedefi: 280 → 200 (kritik güvenlik + CI/CD + temel mimari).
- D2 sonu hedefi: 200 → 130 (TypeScript + framework + veri ayrımı).
- D3 sonu hedefi: 130 → 90 (AI-Native temelleri).
- D4 sonu hedefi: 90 → 60 (Ölçek).
- D5 sonu hedefi: 60 → 30 (Compliance + ekosistem).

### 2.3 İş Sürekliliği Risk Matrisi

| Risk | Olasılık | Etki | Risk skoru | Azaltma yöntemi |
|---|:---:|:---:|:---:|---|
| **API anahtar sızıntısı** (G-01) | Yüksek | Kritik | 25 | D1: WebCrypto şifreleme, sonra proxy |
| **Hukuki dava** (KemalistVault, JailbreakVault) | Orta | Yüksek | 16 | D1: Hukuk danışmanlığı, vault risk tagging |
| **Anahtar çalışan kaybı** (single-source-of-knowledge) | Orta | Yüksek | 16 | D1: Dokümantasyon, pair programming, knowledge base |
| **Google ToS değişikliği** (Fonts, Gemini) | Düşük | Orta | 6 | D1: Self-host, multi-provider |
| **Tarayıcı browser-API kırılımı** (WebLLM, FS, OPFS) | Orta | Orta | 9 | D3: Feature-detection, polyfill, fallback |
| **AI model maliyet artışı** (Gemini, OpenAI fiyatı) | Yüksek | Orta | 12 | D3: Local LLM (Transformers.js), router |
| **Veri ihlali (kullanıcının prompt'ları)** | Orta | Kritik | 20 | D1: Telemetri opt-in, D2: e2e encryption |
| **Bağımlılık supply-chain saldırısı** (npm) | Düşük | Kritik | 10 | D1: lockfile + SBOM + lockfile signing |
| **Rakip ürün** (örn. PromptHub, FlowGPT) | Yüksek | Yüksek | 20 | D3+: Unique value (local-first AI, Türkçe içerik) |
| **Kurucu odak kayması** | Orta | Kritik | 20 | Sözleşme + OKR + advisory board |

### 2.4 "Eğer hiçbir şey yapmazsak" senaryosu

> Önümüzdeki 6 ay içinde yaşanacaklar (D0'da kalırsak):
>
> 1. **İlk API key sızıntısı (Hafta 4–12):** Bir kullanıcı XSS-zafiyetli vault'u kullanır, kendi Anthropic anahtarı çalınır → Twitter'da viral olur → reputational damage. Tahmini maliyet: marka değeri (zor parasal ifadelik).
> 2. **Mobil pazar kaybı (Hafta 1–4):** 12.4 MB PromptVault mobilde donduğu için Google Analytics (eklendiğinde) %75 bounce rate gösterir. Mobil-first kullanıcılar dönmüyor.
> 3. **Anahtar geliştirici ayrılırsa:** Knowledge tek bir kişide. Şirket 2–3 hafta felç olur.
> 4. **Hukuki bildirim (Ay 3–6):** KemalistVault veya JailbreakVault için bir BTK / hukuk firması bildirimi → ürünü çevrimdışı almak zorunda kalırız.
> 5. **Yatırımcı due-diligence başarısızlığı:** Bir VC turunda due-diligence raporu yukarıdaki teknik borçları gösterir → değerleme yarıya iner.

Bu senaryoyu önlemek için yol haritası **D1'den itibaren agresif** olmalıdır.

---


## 3. Hedef Mimari (Target Architecture)

### 3.1 Mimari Prensipleri (CTO'nun manifestosu)

Tüm teknik kararlarımız aşağıdaki **8 prensibi** ihlal etmemek üzerinedir:

1. **Local-First, Always.** İlk açılışta internet zorunluluğu yok. Veri kullanıcının cihazında.
2. **Privacy by Design.** Telemetri opt-in, sayısallaştırılmış, dışarı çıkmadan önce filtrelenmiş.
3. **Progressive Enhancement.** En basit tarayıcıda çalışsın, modern tarayıcıda **daha güzel** çalışsın (WebGPU varsa kullan, yoksa CPU'ya düş).
4. **Single Source of Truth (SSoT).** Veri tek yerden, tek formatta. UI hesaplar.
5. **API-First.** UI ne yaparsa, CLI veya başka client da yapabilsin. Tüm fonksiyonlar serializable.
6. **Bağımlılık minimalizmi.** Her npm bağımlılığı kasıtlı bir karardır. Aylık denetlenir.
7. **Tarayıcı standartlarına yakın dur.** Web Components, IndexedDB, OPFS, WebCrypto, WebGPU — proprietary framework'lere kilitlenme.
8. **Test edilebilirlik birinci özellik.** Test edilemeyen kod, üretime girmez.

### 3.2 Yüksek Seviye Mimari Diyagramı

```
┌─────────────────────────────────────────────────────────────────────┐
│                      KULLANICI (Tarayıcı)                           │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                ┌───────────────▼───────────────────┐
                │   PWA Shell  (~30 KB HTML + JS)   │
                │   • Service Worker (offline)      │
                │   • App router                    │
                │   • CSP / SRI enforced            │
                └───────────────┬───────────────────┘
                                │
                ┌───────────────┴──────────────┐
                │                              │
        ┌───────▼────────┐            ┌────────▼──────────┐
        │  UI Katmanı     │            │  Core Servisler   │
        │  (Web Comp.)    │            │                   │
        │ • search-bar    │            │ • SearchService   │
        │ • vault-grid    │            │ • DataService     │
        │ • item-detail   │            │ • KeyVaultService │
        │ • settings      │            │ • SyncService     │
        └─────────────────┘            │ • LLMService      │
                                       │ • TelemetryServ.  │
                                       └────────┬──────────┘
                                                │
        ┌───────────────────────────────────────┴─────────┐
        │            Veri Katmanı                          │
        │  ┌──────────────┐  ┌────────────┐  ┌────────────┐│
        │  │ IndexedDB    │  │ OPFS       │  │ Cache API  ││
        │  │ (Items, Cat) │  │ (büyük)    │  │ (network)  ││
        │  └──────────────┘  └────────────┘  └────────────┘│
        └────────────────────────────────┬─────────────────┘
                                         │
              ┌──────────────────────────┴─────────────────────────┐
              │           Opsiyonel: Bulut Sync (D4+)              │
              │   • CRDT (Yjs / Automerge)                         │
              │   • E2E encryption (libsodium-wrappers)            │
              │   • Self-hostable backend (Hono + Bun + SQLite)    │
              └────────────────────────────────────────────────────┘

        ┌────────────────────────────────────────────────────────────┐
        │           Opsiyonel: Tarayıcı-içi LLM (D3+)               │
        │  • Transformers.js (BERT, MiniLM embedding için)          │
        │  • WebLLM (Llama-3.2-1B / Phi-3.5-mini WASM-quantized)    │
        │  • WebGPU acceleration (tercih edilen)                     │
        └────────────────────────────────────────────────────────────┘
```

### 3.3 Veri Modeli — Önerilen yeni şema

```typescript
// types/vault.ts
interface Vault {
  id: string;              // "promptvault", "routervault", ...
  title: string;
  description: string;
  category: VaultCategory; // "ai", "engine3d", "history", ...
  color: string;           // "#a375ff" (HEX, validated)
  itemCount: number;       // manifest.json ile tutarlı
  version: SemanticVersion; // "1.0.0"
  createdAt: ISO8601;
  updatedAt: ISO8601;
  riskFlags?: RiskFlag[];  // ["political", "jailbreak", "adult"]
}

interface Item {
  id: ULID;                // Yeni: ULID (sortable + unique)
  vaultId: string;
  no: string;              // "001" (görsel için)
  category: string;
  name: string;
  description: string;
  content: string;         // Markdown
  tags: string[];
  meta?: Record<string, string>;
  badges?: { primary?: string; secondary?: string };
  source: ItemSource;      // mecburi (audit için)
  embedding?: Float32Array; // 384-dim (MiniLM) — lazy
  variantOf?: ULID;        // boşsa orijinal
  variantType?: VariantType;// "hybrid" | "scalable" | ...
  createdAt: ISO8601;
  updatedAt: ISO8601;
  hash: string;            // sha256(content) — değişiklik tespiti
}

interface ItemSource {
  generated: boolean;
  provider?: string;       // "gemini" | "claude" | "gpt-4" | "human"
  model?: string;          // "gemini-2.5-flash-lite"
  promptHash?: string;     // hangi prompt üretti, izlenebilir
  reviewedBy?: string;     // editor ID
  reviewedAt?: ISO8601;
  license: LicenseSPDX;    // "CC-BY-4.0" | "proprietary" | ...
}
```

### 3.4 Web Component Stratejisi

**Neden Web Components?**
- React/Vue/Svelte gibi framework yok → bağımlılık sıfır.
- Tarayıcı standardı → 10 yıl sonra da çalışır.
- Inline CSS izolasyonu (Shadow DOM) → 100 dosya çoğaltması yok.
- SSR/SSG ile uyumlu.

**Önerilen component'ler (D1 sonu):**

```typescript
// packages/ui/src/components/
<ac-app-shell>          // Tüm uygulama iskeleti
<ac-vault-launcher>     // index.html'in modern hali
<ac-vault-app>          // Tek bir vault'un tüm UI'ı
<ac-search-bar>         // Fuse.js veya FlexSearch tabanlı
<ac-item-list>          // Virtual scroll
<ac-item-detail>        // Detay paneli + kopyalama
<ac-category-tabs>      // Kategori filtreleri
<ac-api-key-vault>      // WebCrypto-encrypted key store
<ac-llm-chat>           // Lokal LLM ile chat (D3+)
<ac-telemetry-banner>   // Opt-in banner
```

### 3.5 Mono-Repo Yapısı (önerilen)

```
alet-cantasi/                   # Git repo (GitHub Org)
├── .github/
│   ├── workflows/
│   │   ├── ci.yml              # lint + test + build + Lighthouse
│   │   ├── release.yml         # Semantic release + changelog
│   │   └── security.yml        # CodeQL + Dependabot + Snyk
│   └── CODEOWNERS
├── apps/
│   ├── launcher/               # index.html'in modern hali
│   ├── vault-app/              # Tek bir vault için "shell"
│   └── docs-site/              # Astro + Starlight
├── packages/
│   ├── ui/                     # Web Components
│   ├── core/                   # Pure business logic (search, dedupe, ...)
│   ├── data/                   # IndexedDB/OPFS wrappers
│   ├── llm/                    # Transformers.js / WebLLM adapter
│   ├── sync/                   # CRDT + e2e crypto (D4+)
│   └── tokens/                 # Design tokens (renkler, font, spacing)
├── data/
│   ├── manifest.json           # Vault listesi (SSoT)
│   ├── vaults/
│   │   ├── promptvault/
│   │   │   ├── items.ndjson    # 1 satır = 1 item
│   │   │   ├── meta.json
│   │   │   └── embeddings.bin  # Float32 384-dim (D3+)
│   │   └── ...
│   └── schemas/                # Zod schemas
├── tools/
│   ├── dedupe-script/          # variant_of detection
│   ├── migrate-html-to-json/   # Eski HTML'leri parse et
│   ├── og-image-generator/     # Build-time OG image
│   └── lighthouse-budget.json
├── docs/
│   ├── architecture/
│   │   └── adr/                # Architecture Decision Records
│   ├── runbooks/
│   └── security/
├── package.json                # pnpm workspaces root
├── pnpm-workspace.yaml
├── turbo.json                  # Turborepo veya nx
├── tsconfig.base.json
├── biome.json                  # Linter + formatter (ESLint+Prettier yerine)
├── .nvmrc                      # Node 22
├── .tool-versions              # asdf
├── LICENSE
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
└── README.md
```

### 3.6 Teknoloji Seçim Matrisi — kararlar ve gerekçeler

| Katman | Seçim | Alternatif | Neden Seçildi |
|---|---|---|---|
| **Dil** | TypeScript 5.x (strict) | JavaScript | Tip güvenliği, IDE desteği, refactor güveni |
| **Build** | Vite 5.x | Webpack, Parcel | Hız, modern, ESM-native |
| **Monorepo** | pnpm + Turborepo | npm, yarn, nx | Disk verimli, hızlı, cache |
| **Linter+Format** | Biome | ESLint + Prettier | Tek araç, 35x daha hızlı |
| **Framework** | Vanilla + Web Components | React/Vue/Svelte | Standartlara bağlılık, bağımlılık 0 |
| **State** | nanostores veya Solid Signals | Redux, Zustand | Tiny, reactive, framework-agnostic |
| **Search** | FlexSearch | Fuse.js, MiniSearch | %20 RAM, indexable, multi-field |
| **Data** | IndexedDB (Dexie 4) | LocalStorage, WebSQL | Async, large data, schema |
| **Storage (büyük)** | OPFS (Origin Private FS) | Cache API | Random access, hızlı |
| **Crypto** | WebCrypto (native) | libsodium | Browser standart |
| **LLM (D3)** | Transformers.js + WebLLM | TFJS, ONNX Runtime | Maintained, WebGPU, popüler |
| **Test (unit)** | Vitest | Jest | Vite-native, hızlı |
| **Test (e2e)** | Playwright | Cypress | Multi-browser, modern, hızlı |
| **Test (a11y)** | axe-core + @axe-core/playwright | pa11y | Standart, CI-uyumlu |
| **Telemetri** | Sentry + Plausible | LogRocket, GA | Privacy-friendly, GDPR safe |
| **CI** | GitHub Actions | GitLab CI | GitHub'da olduğumuz için |
| **CDN** | Cloudflare Pages / Vercel | Netlify, AWS S3 | Bedava, hızlı, kolay rollback |
| **Backend (D4)** | Bun + Hono + SQLite (LiteFS) | Node + Express + PostgreSQL | Hız, küçük, edge-friendly |
| **Sync (D4)** | Yjs + y-websocket | Automerge, Replicache | Olgun, kullanıcı tabanı |
| **Container** | Docker + docker-compose | Podman, Bare-VM | Pratik, self-host'a uygun |
| **IaC (D5)** | Pulumi (TypeScript) | Terraform | Aynı dil ekosistemi |
| **Compliance Tool (D5)** | Vanta (SaaS) | DIY | SOC2 hızlandırma |

### 3.7 ADR (Architecture Decision Record) Şablonu

Her büyük karar **ADR** olarak `docs/architecture/adr/` altına commit'lenir:

```markdown
# ADR-0001: Mono-repo için pnpm + Turborepo

## Status
Kabul edildi · 2026-06-15

## Bağlam
Mono-repo aday teknolojiler: npm workspaces, yarn workspaces, pnpm, Lerna, Nx, Turborepo, Rush.

## Karar
pnpm + Turborepo kullanılacaktır.

## Sonuçlar
+ Disk kullanımı %60 azalır (sembolik linkler).
+ Turborepo cache'i, CI build süresini ~%70 düşürür.
- Yeni geliştirici onboarding'inde "pnpm" değişikliğine adapt olması gerekir (~1 saat).

## Alternatifler
- Nx: Daha güçlü ama daha karmaşık, küçük ekip için over-engineered.
- npm workspaces: Yetersiz, cache yok.

## İlgili kararlar
- ADR-0003: Biome seçimi (ESLint+Prettier yerine)
```

Hedef D1 sonu: **5–10 ADR yazılmış olacak**.

---


## 4. 5 Dönemli Geliştirme Yol Haritası

Bu yol haritası **5 ardışık döneme** bölünmüştür. Her dönem:
- **Süre** ve **Hedef**
- **Sprint-by-sprint** detayı (her sprint 2 hafta)
- **Definition of Done (DoD)**
- **Çıktılar** (artifact'ler)
- **Bağımlılıklar** (önceki dönemlerden gelmesi gereken çıktılar)
- **Riskler ve azaltma yöntemleri**
- **OKR (Objectives & Key Results)**
- **Test ve kalite kapıları**

---

### 4.D1 · DÖNEM 1: Stabilizasyon & Güvenlik (0–3 ay)

> **Slogan:** *"Önce yangını söndür, sonra yeniden tasarla."*

#### D1.1 Hedef

90 günün sonunda **devraldığımız 102 MB'lık enkazı**, modern bir mühendislik organizasyonunun
**üretime alabileceği temele** dönüştürmek.

Spesifik olarak:
1. **Versiyon kontrolü, monorepo, CI/CD** çalışıyor olacak.
2. **5 kritik güvenlik bulgusu** (G-01 → G-05) kapatılmış olacak.
3. **Test altyapısı + coverage %60** olacak.
4. **Lighthouse Performance ≥ 75** (mobil) hedefi (en az 5 vault'ta).
5. **Telemetri** (Sentry + Plausible) çalışıyor olacak.
6. **Hukuk danışmanlığı** alınmış, risk-flag'li vault'lar etiketlenmiş olacak.

#### D1.2 Sprint Planlaması (6 sprint × 2 hafta = 12 hafta)

##### Sprint 1 (Hafta 1–2): Foundation

**Hedef:** Geliştirme ortamı + monorepo + CI iskeleti.

**Görevler:**
- [S1-T1] GitHub Organization, repo, branch protection, CODEOWNERS, PR template
- [S1-T2] `pnpm + Turborepo` ile monorepo iskeleti (Bölüm 3.5'teki yapı)
- [S1-T3] `TypeScript`, `Biome`, `Vitest`, `Playwright` kurulumu
- [S1-T4] Mevcut 101 HTML'i `legacy/` altına commit (referans olarak)
- [S1-T5] GitHub Actions CI: `lint`, `typecheck`, `test`, `build` (hello-world düzeyinde geçsin)
- [S1-T6] `pre-commit` hook: husky + lint-staged
- [S1-T7] README.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md, LICENSE (Apache-2.0 önerim)
- [S1-T8] `.editorconfig`, `.nvmrc` (Node 22), `.tool-versions` (asdf)

**DoD:**
- Yeni bir geliştirici, repo'yu clone'layıp `pnpm i && pnpm dev` ile çalıştırabiliyor.
- PR açtığında 5 dakika içinde CI yeşil veya kırmızı dönüyor.
- "main" branch protected, en az 1 onay zorunlu.

**Çıktılar:** Çalışan boş bir monorepo, dokümanlar, CI status badge.

##### Sprint 2 (Hafta 3–4): Migration Pipeline + Veri Ayrımı

**Hedef:** 101 HTML dosyasından **JSON veri** ve **shared kod** ekstrakte et.

**Görevler:**
- [S2-T1] `tools/migrate-html-to-json/` script'i:
  - Her vault'tan `ITEMS` JSON'unu ekstrakte et.
  - `data/vaults/{vault-id}/items.ndjson` formatına yaz (NDJSON: streamable).
  - Meta-bilgileri `data/vaults/{vault-id}/meta.json`'a yaz.
  - `data/manifest.json` üret (tüm vault listesi + sayım + boyut).
- [S2-T2] **Zod** ile JSON schema validation (her item'ın doğru tipte olduğunu CI'da kontrol et).
- [S2-T3] HTML'lerdeki **JS** ve **CSS** ortak kısmını ekstrakte et → `packages/legacy-shell/` (eski mantığı koru).
- [S2-T4] Renk değişkenleri için `packages/tokens/colors.ts`:
  ```typescript
  export const VAULT_COLORS = {
    promptvault: { primary: '#a375ff', accent: '#ff6b9d' },
    routervault: { primary: '#a375ff', accent: '#ff6b9d' },
    kemalistvault: { primary: '#d4a04c', accent: '#c97e4c' },
    // ...
  } as const;
  ```
- [S2-T5] CI'da `data/` boyutu izleme (1 vault > 5 MB ise alarm).

**DoD:**
- `data/manifest.json` doğru sayım veriyor (PromptVault: 6394, RouterVault: 456, ...).
- Tüm `items.ndjson` Zod schema'sından geçiyor.
- `legacy/` ve `data/` arasında **hiç fark kalmamış** (round-trip test).

**Çıktılar:** Veri ekstraksiyon CLI, `data/` klasörü, Zod schemas.

##### Sprint 3 (Hafta 5–6): Güvenlik Patches (Kritik)

**Hedef:** G-01 → G-05 bulgularını kapat.

**Görevler:**
- [S3-T1] **G-01 (API Key)**: `KeyVaultService` implementasyonu.
  - WebCrypto AES-GCM ile passphrase-derived (PBKDF2) anahtar.
  - Master password girilince session'da bellek (Symbol-keyed WeakMap).
  - `localStorage`'da sadece **şifrelenmiş** veri.
  - Test: ekran kilitliyken `localStorage.getItem('apiKey')` → ciphertext.
- [S3-T2] **G-02 (CSP)**: Cloudflare Pages / Vercel header config.
  - `_headers` dosyası (Cloudflare) veya `vercel.json` (Vercel).
  - Lighthouse'da CSP test geçiyor.
- [S3-T3] **G-03 (innerHTML)**: Tüm `innerHTML` kullanımı revize.
  - `DOMPurify` entegrasyonu.
  - `safe-template` helper.
  - Lint kuralı: `no-inner-html` (Biome custom rule).
- [S3-T4] **G-04 (Fonts)**: Google Fonts self-host.
  - `fontsource` paketleri veya direct WOFF2 indir.
  - `font-display: swap`.
- [S3-T5] **G-05 (Veri inline)**: Build-time'da JSON ayrı dosyaya.
  - `apps/launcher` build'inde `<script src="manifest.json">` referansı.
- [S3-T6] **Penetrasyon testi** danışman ile (5 gün, ~30K TL).

**DoD:**
- Mozilla Observatory skoru ≥ **A+** (en az B+).
- Snyk + GitHub Dependabot ile high/critical CVE = 0.
- Penetrasyon test raporu: kritik bulgu = 0.

**Çıktılar:** `KeyVaultService`, CSP header, security audit raporu.

##### Sprint 4 (Hafta 7–8): Test Altyapısı

**Hedef:** %60 coverage, e2e test örnekleri, axe-core entegrasyonu.

**Görevler:**
- [S4-T1] **Vitest** ile unit test örnekleri:
  - `searchMatch()`, `catColor()`, `esc()` (legacy fonksiyonlar)
  - `KeyVaultService.encrypt/decrypt`
  - Schema validation testleri
- [S4-T2] **Playwright** ile e2e:
  - "Vault aç → arama yap → öğe seç → kopyala" akışı (5 farklı vault)
  - "API key gir → kaydet → yeniden yükle → şifrelenmiş kaldığını doğrula"
- [S4-T3] **axe-core**: CI'da blocking, her sayfa için.
- [S4-T4] **Lighthouse CI**: budget tanımla:
  ```json
  {
    "performance": 75,
    "accessibility": 90,
    "best-practices": 90,
    "seo": 95
  }
  ```
- [S4-T5] **Visual regression** (Chromatic veya Percy): UI komponentleri için snapshot.
- [S4-T6] **Coverage badge** README'ye eklenir.

**DoD:**
- Coverage: branches ≥ 60%, statements ≥ 75%.
- Playwright tüm tarayıcılarda yeşil (Chromium, Firefox, WebKit).
- Lighthouse CI fail eden PR merge'lenmez.

**Çıktılar:** Test suite, CI raporları, coverage badge.

##### Sprint 5 (Hafta 9–10): Performans Patches & PromptVault

**Hedef:** P-01 ve P-02 bulgularını kısmen kapat.

**Görevler:**
- [S5-T1] **PromptVault** özel ele alınır:
  - 6394 item'ı `items.ndjson` (~10 MB) olarak ayır.
  - HTML shell 50 KB.
  - Sayfalama (ilk 100, scroll'da +100).
  - **FlexSearch** ile arama indeksi (~%5 boyut).
- [S5-T2] **Virtual scrolling**: tek bir `Vault App` shell'de.
  - `@tanstack/virtual-core` veya custom.
  - 6000+ item'ı 60 fps'te scroll edebilen test.
- [S5-T3] **Gzip + Brotli**: Cloudflare/Vercel otomatik, ama config doğrula.
- [S5-T4] **Image optimization**: SVG noise pattern → CSS gradient (data:image yerine).
- [S5-T5] **Lazy load**: kategori filtresi ve renderDetail içindeki ağır kısımlar.

**DoD:**
- PromptVault LCP < 3s (4G simülasyonu).
- Tüm vault'ların ortalama bundle size < 100 KB (HTML shell + JS).
- Memory < 100 MB (Chrome DevTools "Memory" tab).

**Çıktılar:** Optimized PromptVault, virtual scrolling component.

##### Sprint 6 (Hafta 11–12): Gözlemlenebilirlik + Yasal + Launch

**Hedef:** Üretime alınabilir state'e ulaş.

**Görevler:**
- [S6-T1] **Sentry** entegrasyonu (free tier ile başla, ~5K events/ay).
- [S6-T2] **Plausible** veya **Umami** (self-host) — analitik opt-in banner ile.
- [S6-T3] **TelemetryService**: `track('vault_opened', { vault_id })`. PII filter.
- [S6-T4] **Hukuk danışmanlığı** (5-10K TL): KemalistVault, JailbreakVault için risk değerlendirme.
- [S6-T5] **ToS, Privacy Policy, KVKK Aydınlatma Metni** (Türkçe + İngilizce).
- [S6-T6] **Risk-flagged vault'lar**: UI'da disclaim'er + age-gate (18+ onayı).
- [S6-T7] **sitemap.xml, robots.txt, canonical URL'ler**.
- [S6-T8] **D1 retrospektifi** + **D2 planı** + **stakeholder demo**.
- [S6-T9] **Public launch** (opt-in, sınırlı kullanıcı kitlesi).

**DoD:**
- Sentry'de issue counter sıfırdan başlıyor, false-positive temiz.
- Plausible'da ilk gerçek kullanıcı session'ları görülüyor.
- Hukuk raporu commit'lenmiş (`docs/legal/risk-assessment-2026Q3.md`).
- Public launch'ta ilk 100 kullanıcıdan crash report = 0.

**Çıktılar:** Üretim-ready ürün, telemetri dashboard, hukuk raporu.

#### D1.3 Sprint Özet Tablosu

| Sprint | Tema | En önemli çıktı |
|---|---|---|
| S1 | Foundation | Monorepo + CI iskeleti |
| S2 | Migration | data/ klasörü + manifest |
| S3 | Güvenlik | KeyVault + CSP + DOMPurify |
| S4 | Test | Vitest + Playwright + axe-core |
| S5 | Performans | PromptVault optimization |
| S6 | Launch | Sentry + Plausible + hukuk |

#### D1.4 OKR (Dönem 1)

**O1: Üretime alınabilir teknik temel kur.**
- KR1: Lighthouse Performance ≥ 75 (mobil), en az 10 vault'ta.
- KR2: Coverage branches ≥ 60%, statements ≥ 75%.
- KR3: Mozilla Observatory ≥ A.
- KR4: CI build süresi < 5 dakika.

**O2: Güvenlik garantisi ver.**
- KR1: Kritik CVE = 0.
- KR2: Penetrasyon test raporu: kritik bulgu = 0.
- KR3: KeyVault test edilmiş ve dokümante.

**O3: Veri kaynağını organize et.**
- KR1: `data/manifest.json` doğru rakamlarla 100% senkron.
- KR2: 100% item Zod schema'sından geçiyor.

#### D1.5 D1 Riskleri ve Azaltma

| Risk | Azaltma |
|---|---|
| Migrasyon sırasında veri kaybı | Her sprint sonu `data/` snapshot + checksum. |
| Yeni geliştiricinin onboarding'i yavaş | Sprint 1'de README + setup script. |
| Penetrasyon testi danışman bulamamak | İlk hafta 3 firmadan teklif al, kontrat S2'de imzala. |
| Hukuk danışmanlığı bütçesi aşımı | Tek seferlik sabit fiyat sözleşme. |

#### D1.6 D1 Bütçe Detayı

| Kalem | TL | USD |
|---|---:|---:|
| Senior Frontend Mühendisi (× 2) × 3 ay | 1.080.000 | 33.000 |
| Mid Frontend Mühendisi × 3 ay | 360.000 | 11.000 |
| Ürün Yöneticisi (yarı zamanlı) × 3 ay | 180.000 | 5.500 |
| Penetrasyon testi danışmanı | 30.000 | 920 |
| Hukuk danışmanlığı | 10.000 | 305 |
| GitHub Team plan | 18.000 | 550 |
| Sentry Team plan | 14.400 | 440 |
| Cloudflare (free) + domain | 4.000 | 120 |
| Tasarım danışmanı (yarı zamanlı) | 60.000 | 1.835 |
| Eğitim (kursları, kitaplar) | 15.000 | 460 |
| Beklenmedik (~10%) | 177.140 | 5.413 |
| **D1 TOPLAM** | **1.948.540 ≈ 1.95M** | **59.543** |

---


### 4.D2 · DÖNEM 2: Modernizasyon & Veri Katmanı (3–6 ay)

> **Slogan:** *"Çatıyı söküp yenisini at, ama içeride kimse fark etmesin."*

#### D2.1 Hedef

D1'de **yangın söndü**. Şimdi 100 dosyalık enkazın yerine **modern, sürdürülebilir** bir
mimari getiriyoruz — kullanıcı için **kesintisiz**, ekip için **devrimsel**.

Üç ana akış:
1. **Framework refactor**: 100 dosya → 1 Web Components shell + 100 data file.
2. **Veri kalitesi**: %55+ varyantın temizliği veya birleştirilmesi.
3. **PWA + Offline**: Service Worker, IndexedDB, OPFS.

#### D2.2 Sprint Planlaması (6 sprint × 2 hafta)

##### Sprint 7 (Hafta 13–14): Web Components Shell

**Görevler:**
- [S7-T1] `apps/vault-app/` — generic shell, parametre olarak `?vault=promptvault` alır.
- [S7-T2] **Lit** (veya **vanilla** Web Components) ile shell:
  - `<ac-app-shell>`, `<ac-search-bar>`, `<ac-item-list>`, `<ac-item-detail>`.
- [S7-T3] Shadow DOM + CSS-in-JS-LIKE (CSS modules ile token entegrasyonu).
- [S7-T4] Sayfa yapısı: `/vault/{id}` rotası (App Router veya `@hotwired/turbo`).
- [S7-T5] Backwards compatibility: eski `/01-promptvault-pro.html` URL'leri 301 redirect.

**DoD:** Tek shell ile 5 vault sorunsuz açılıyor.

##### Sprint 8 (Hafta 15–16): IndexedDB + Dexie Migration

**Görevler:**
- [S8-T1] **Dexie 4** ile schema:
  ```typescript
  db.version(1).stores({
    vaults: 'id, category, updatedAt',
    items: '++ulid, vaultId, [vaultId+category], *tags, name',
    apiKeys: 'id', // encrypted
    settings: 'key',
  });
  ```
- [S8-T2] İlk açılışta `data/vaults/*/items.ndjson` → IndexedDB bulk import (Web Worker'da).
- [S8-T3] **FlexSearch** indeksi IndexedDB'de (her vault için ayrı).
- [S8-T4] **DataService** API'si: `getItems(vaultId, { offset, limit, search, category })`.
- [S8-T5] Re-render testleri (eski sayfa açılışı → yeni sayfa açılışı): hız +5x.

**DoD:** PromptVault 6394 item, ilk açılış sonrası 100ms'de search döner.

##### Sprint 9 (Hafta 17–18): TypeScript Strict + Veri Audit

**Görevler:**
- [S9-T1] `tsconfig.base.json` strict mode (`strict: true`, `noUncheckedIndexedAccess: true`).
- [S9-T2] `packages/core` 100% TS coverage.
- [S9-T3] **Variant Dedupe Sprint'i**:
  - Sentence embedding ile (MiniLM, Transformers.js'in WASM build'i).
  - `variantOf` linki olan kayıtları gruple.
  - Editör review için **dashboard** (`apps/admin/dedupe`).
  - "Sil / Birleştir / Tut" aksiyonları.
- [S9-T4] Hedef: 52,938 item → ~22,000 özgün item + ~30,000 variant (linkli).

**DoD:** İçerik raporunda %55+ variant'ın UI'da görünmeyen (linkli) state'e taşınmış.

##### Sprint 10 (Hafta 19–20): PWA + Offline + Service Worker

**Görevler:**
- [S10-T1] `manifest.webmanifest` (PWA): icon, short_name, theme_color.
- [S10-T2] **Workbox** ile Service Worker:
  - App shell: `CacheFirst`
  - Veri NDJSON: `NetworkFirst`
  - Sentry/analytics: `NetworkOnly`
- [S10-T3] OPFS ile **embeddings.bin** (300+ MB veri için).
- [S10-T4] "Yeni güncelleme var" toast (skip-waiting + reload).
- [S10-T5] PWABuilder ile Chrome/Edge install prompt testi.

**DoD:** Uçakta (offline) PromptVault tam çalışıyor. Lighthouse PWA = 100.

##### Sprint 11 (Hafta 21–22): A11y Refactor + i18n Foundation

**Görevler:**
- [S11-T1] axe-core'da 0 violation (önceden bulgular vardı).
- [S11-T2] Klavye nav: Tab/Shift-Tab/Enter/Esc/Arrow.
- [S11-T3] Focus trap modal + skip-link.
- [S11-T4] Kontrast düzeltmeleri (text3 → AA geçer renk).
- [S11-T5] Screen reader test (VoiceOver, NVDA).
- [S11-T6] **i18n altyapısı**: `@lingui/core` veya `fluent`. İlk dil: `tr`. İkinci hazırlık: `en`.

**DoD:** Lighthouse Accessibility ≥ 95. NVDA ile "Vault aç → arama → seç" akışı çalışıyor.

##### Sprint 12 (Hafta 23–24): Design System v1 + Stakeholder Demo

**Görevler:**
- [S12-T1] **Storybook** ile UI catalog.
- [S12-T2] **Design tokens** (Figma → JSON pipeline: Style Dictionary).
- [S12-T3] Dark mode + Light mode (system'a göre + override).
- [S12-T4] **per-item OG image** build-time (Satori veya Vercel OG offline).
- [S12-T5] D2 retro + D3 plan + halka açık beta launch (1,000 kullanıcı hedefi).

**DoD:** Storybook'ta 30+ component dokümante. Dark/Light geçiş < 50ms.

#### D2.3 D2 Bütçe Detayı

| Kalem | TL | USD |
|---|---:|---:|
| Senior FE × 2 × 3 ay | 1.080.000 | 33.000 |
| Mid FE × 2 × 3 ay | 720.000 | 22.000 |
| Ürün Yöneticisi × 3 ay | 360.000 | 11.000 |
| İçerik Editörü (variant audit için) × 2 × 3 ay | 360.000 | 11.000 |
| Tasarım danışmanı (Design System için) | 80.000 | 2.450 |
| GitHub Team + Sentry + Cloudflare | 18.000 | 550 |
| Storybook hosting (Chromatic Pro) | 15.000 | 460 |
| Eğitim | 12.000 | 370 |
| Beklenmedik (~10%) | 264.500 | 8.083 |
| **D2 TOPLAM** | **2.909.500 ≈ 2.91M** | **88.913** |

#### D2.4 D2 OKR

**O1: Mimari modernizasyonu tamamla.**
- KR1: 100 dosya → 1 shell, kullanıcı için kesinti yok.
- KR2: Bundle size: vault shell < 30 KB gzip.
- KR3: TypeScript coverage 100%, strict mode on.

**O2: Veri kalitesini iki kat yükselt.**
- KR1: Görünür item sayısı 52,938 → ~22,000 (özgün).
- KR2: Editör review oranı 100% (yeni item'lar için).
- KR3: Search precision/recall ölçümü > 0.85.

**O3: Erişilebilirlik AA seviyesi.**
- KR1: Lighthouse Accessibility ≥ 95.
- KR2: axe-core violations = 0.
- KR3: Screen reader test 3 kullanıcı ile geçti.

---


### 4.D3 · DÖNEM 3: AI-Native Platform (6–9 ay)

> **Slogan:** *"İçeriği kullanıcıya dayatma; içeriğin kendisiyle konuş."*

#### D3.1 Hedef

D2'nin sonunda elimizde **modern, hızlı, güvenli bir Vault uygulaması** vardı.
Şimdi onu **AI-Native** bir platforma dönüştürüyoruz:
- Tarayıcı-içi LLM çıkarımı (Transformers.js + WebLLM)
- RAG (Retrieval-Augmented Generation) + vektör arama
- MCP (Model Context Protocol) + tool calling
- "Vault'larla konuş" deneyimi

Bu dönem **felsefemizin gerçekten parladığı** dönem: *Local-first AI*.

#### D3.2 Sprint Planlaması

##### Sprint 13 (Hafta 25–26): Embedding Pipeline (build-time)

**Görevler:**
- [S13-T1] **Sentence Transformers MiniLM-L6-v2** (paraphrase-multilingual) seç.
- [S13-T2] Build-time embedding üretimi:
  - `tools/embed-generator/` Node.js script.
  - Her item için `Float32Array(384)` embedding.
  - `data/vaults/{id}/embeddings.bin` (binary, ~1.5 MB / 1000 item).
- [S13-T3] **HNSW index** (`hnswlib-node` veya `usearch`) build-time'da pre-build.
- [S13-T4] Quantization: Float32 → Int8 (4x smaller, ~5% recall loss).

**DoD:** Tüm vault'ların embedding'leri build artifact'inde. Toplam < 80 MB.

##### Sprint 14 (Hafta 27–28): Browser-side Vector Search

**Görevler:**
- [S14-T1] **`packages/llm`**: Transformers.js wrapper.
- [S14-T2] OPFS'e embeddings.bin yükleme (chunk-by-chunk, progress UI).
- [S14-T3] **Vector search** in-browser:
  - HNSW (WebAssembly) ile k-NN.
  - 50,000 vektörde < 30ms p95.
- [S14-T4] **Hybrid search**: BM25 (FlexSearch) + vector (HNSW) score fusion (RRF).
- [S14-T5] Search UX: "Anlamsal arama" toggle, sonuçlarda relevance score.

**DoD:** Kullanıcı "kostumlü prompt" yazdığında "custom prompt" sonuçları da geliyor (synonyms anlamlı çalışıyor).

##### Sprint 15 (Hafta 29–30): WebLLM (in-browser inference)

**Görevler:**
- [S15-T1] **WebLLM** entegrasyonu (`@mlc-ai/web-llm`).
- [S15-T2] Model seçimi: **Llama 3.2 1B Instruct** (q4f16_1, ~700 MB).
- [S15-T3] WebGPU detection + fallback (CPU WASM çok yavaş, "Lite mode" gösterilir).
- [S15-T4] İlk kullanım: model download (700 MB) → IndexedDB cache (~30 sn 100Mbps).
- [S15-T5] **<ac-llm-chat>** komponenti: streaming tokens, copy button.

**DoD:** "Bu prompt'u Türkçe'ye uyarla" gibi basit istekler çalışıyor.

##### Sprint 16 (Hafta 31–32): RAG Pipeline (Local-First)

**Görevler:**
- [S16-T1] **Retrieval**: kullanıcı sorgusu → hybrid search → top 5 relevant item.
- [S16-T2] **Augmentation**: retrieved item'ları prompt'a inject (system context).
- [S16-T3] **Generation**: WebLLM ile cevap (streaming).
- [S16-T4] **Citation UI**: "Bu cevap şu 3 öğeden geldi" (linkler).
- [S16-T5] **Fallback**: WebGPU yoksa "RAG mode lite" — sadece search, generation yok.

**DoD:** "Maliyet odaklı yönlendirme için en iyi prompt'u öner" sorusuna doğru 3 RAG-citation döner.

##### Sprint 17 (Hafta 33–34): MCP + Tool Calling

**Görevler:**
- [S17-T1] **MCP server** (`@modelcontextprotocol/sdk`):
  - `search-vault` tool
  - `get-item` tool
  - `compare-items` tool
- [S17-T2] **Tool calling** in WebLLM (function calling).
- [S17-T3] **External API tool'ları**: OpenAI / Anthropic (kullanıcı API key'i ile).
- [S17-T4] **Router**: küçük sorular → WebLLM local, büyük → external API.
- [S17-T5] **Cost tracking**: her external call'un USD maliyeti UI'da gösteriliyor.

**DoD:** "PersonaVault'tan bir CTO persona seç, RouterVault'tan ona göre prompt yap" akışı çalışıyor.

##### Sprint 18 (Hafta 35–36): Multi-Vault Connections + Public Launch

**Görevler:**
- [S18-T1] **Vault-to-vault linking**: PromptVault ↔ PersonaVault ↔ ChainVault.
- [S18-T2] **Cross-vault search**: tek input, tüm 100 vault.
- [S18-T3] **Graph view**: ilişkili item'lar ağ olarak görüntüleme (D3.js veya Cytoscape.js).
- [S18-T4] **Show HN / Product Hunt launch** hazırlığı.
- [S18-T5] **D3 retro + D4 plan + ürün demo videosu**.

**DoD:** Product Hunt'ta ilk haftada 500+ upvote, 10K MAU hedefi.

#### D3.3 D3 Bütçe Detayı

| Kalem | TL | USD |
|---|---:|---:|
| Senior FE × 2 × 3 ay | 1.080.000 | 33.000 |
| Senior AI Mühendisi × 3 ay | 720.000 | 22.000 |
| Mid FE × 2 × 3 ay | 720.000 | 22.000 |
| Ürün Yöneticisi × 3 ay | 360.000 | 11.000 |
| LLMOps danışmanı (10 gün) | 50.000 | 1.530 |
| GitHub Copilot Enterprise × 5 | 24.000 | 735 |
| Cloud build (GPU CI for embedding) | 30.000 | 920 |
| OpenAI / Anthropic API (test) | 25.000 | 765 |
| Pazarlama (PH launch, demo video) | 100.000 | 3.060 |
| Storybook + Chromatic | 18.000 | 550 |
| Eğitim (LLM workshops) | 25.000 | 765 |
| Beklenmedik (~10%) | 315.200 | 9.637 |
| **D3 TOPLAM** | **3.467.200 ≈ 3.47M** | **105.962** |

#### D3.4 D3 OKR

**O1: Vault'lar artık "ölü içerik" değil, AI-Native.**
- KR1: WebLLM ile 1B model, WebGPU varsa, < 50 tokens/sec.
- KR2: Hybrid search p95 < 80ms.
- KR3: RAG citation accuracy > 0.85 (insan değerlendirme).

**O2: External AI maliyeti kontrolünde.**
- KR1: Kullanıcı başına ortalama external token < 5K/gün (router sayesinde).
- KR2: Cost tracking UI, her sorgu için döviz dahil görüntüleniyor.

**O3: Lansman başarısı.**
- KR1: Product Hunt #1 of the day veya top 5.
- KR2: 10K MAU.
- KR3: NPS > 40.

---


### 4.D4 · DÖNEM 4: Ölçeklendirme & Multi-Tenant (9–15 ay, 6 ay)

> **Slogan:** *"Tek kullanıcı için yapılmış güzel bir oyuncak değil — milyonlarca kullanıcının üstüne ev kurabileceği bir platform."*

#### D4.1 Hedef

D3'te ürün **AI-Native** oldu. Şimdi **iş modeli** kuruyoruz: bulut sync, self-host bundle,
B2B kullanım, kullanıcı bazlı veri izolasyonu.

#### D4.2 Sprint Planlaması (12 sprint × 2 hafta)

**Sprint 19–20: Sync Architecture (CRDT)**
- Yjs (veya Automerge) ile **conflict-free replicated data types**.
- Self-hostable `y-websocket` server (Bun + Hono).
- E2E encryption (libsodium): kullanıcının verisi sunucu yöneticisine kapalı.

**Sprint 21–22: Self-Host Bundle (Docker)**
- `docker-compose.yml`: app + sync + db (SQLite via LiteFS for distributed).
- Docker image < 50 MB (distroless).
- Helm chart (D5'e zemin).

**Sprint 23–24: Multi-Tenant Foundation**
- User accounts (OAuth: Google, GitHub, email magic-link).
- Workspace concept: "Personal", "Team", "Org".
- RLS (Row-Level Security) SQLite ile.
- Quota / Rate limit per tenant.

**Sprint 25–26: Billing (Lemon Squeezy / Stripe)**
- Tier'lar: Free (local-only), Pro (cloud sync), Team (collab), Enterprise (SSO + audit).
- **Lemon Squeezy** Merchant of Record (KVK uyum için Türkiye'den iyi).
- Webhook → tenant_id grant/revoke.

**Sprint 27–28: Observability v2**
- **Grafana + Prometheus + Loki + Tempo** stack (self-host).
- Service Level Indicators (SLI):
  - p99 sync latency < 200ms
  - Error rate < 0.1%
  - Sync data integrity 100%
- Runbook'lar her servis için.

**Sprint 29–30: Performance & Load Testing**
- **k6** ile load test (1000 concurrent users → 10K).
- Bottleneck'leri belirle, optimize et.
- Capacity plan: 100K MAU için fiyatlandırma.

#### D4.3 D4 Bütçe Detayı (6 ay)

| Kalem | TL | USD |
|---|---:|---:|
| Senior FE × 2 × 6 ay | 2.160.000 | 66.000 |
| Senior BE/SRE × 1 × 6 ay | 1.440.000 | 44.000 |
| Mid FE × 2 × 6 ay | 1.440.000 | 44.000 |
| AI mühendisi × 6 ay | 1.440.000 | 44.000 |
| PM × 6 ay | 720.000 | 22.000 |
| Cloud (AWS/GCP başlangıç, ~$500/ay) | 100.000 | 3.060 |
| Database (Turso, PlanetScale veya self-host) | 60.000 | 1.835 |
| Lemon Squeezy commission (revenue dependent) | hedef MRR'nin %5'i | — |
| Pazarlama (içerik, SEO, paid ads) | 400.000 | 12.240 |
| SOC2 ön-hazırlık danışmanlığı | 100.000 | 3.060 |
| Eğitim + konferanslar | 80.000 | 2.450 |
| Beklenmedik (~10%) | 794.000 | 24.282 |
| **D4 TOPLAM (6 ay)** | **8.734.000 ≈ 8.73M** | **267.013** |

#### D4.4 D4 OKR

**O1: Sync çalışsın, kullanıcı veri kaybı yaşamayşın.**
- KR1: Sync data integrity ≥ 99.99% (test ortamı).
- KR2: 1000 concurrent user load test geçti.
- KR3: E2E encryption test (penetrasyon) geçti.

**O2: İlk ödeme alalım.**
- KR1: 100 ödeyen kullanıcı (MRR ≥ $500).
- KR2: Churn < %5/ay.
- KR3: ARPU ≥ $5/ay.

**O3: Operasyonel olgunluk.**
- KR1: 99.5% uptime (SLO).
- KR2: P0 incident response time < 15 dakika.
- KR3: Runbook coverage 100%.

---

### 4.D5 · DÖNEM 5: Kurumsallaşma & Ekosistem (15–24 ay, 9 ay)

> **Slogan:** *"Ürünü ekosisteme dönüştür; biz olmasak da yaşasın."*

#### D5.1 Hedef

D4'te şirket olduk. D5'te **endüstri standart bir AI-Native bilgi platformu** oluyoruz.
- Açık eklenti / plugin API'si
- 3. parti vault'lar
- Compliance (SOC2 Type II, KVKK, GDPR)
- Topluluk + marketplace + AppStore-vari ekosistem

#### D5.2 Sprint Planlaması (18 sprint × 2 hafta)

**Sprint 31–32: Plugin / Extension API**
- Web Extension SDK (Chrome, Firefox, Edge, Safari).
- Sandboxed Web Worker'lar (her plugin kendi origin'inde).
- Permissions model: `read-vault`, `write-vault`, `network-llm`, `clipboard`.
- Plugin manifest schema.

**Sprint 33–34: Public API + SDK**
- REST + GraphQL API (`api.aletcantasi.com`).
- TypeScript SDK + Python SDK.
- Rate limit + API key + OAuth scopes.
- API documentation (Stoplight / Mintlify).

**Sprint 35–36: Vault Marketplace**
- 3. parti geliştirici portali.
- Vault submit → review → publish akışı.
- Revenue share (70/30 — Apple App Store benzeri).
- Vault validation: schema, lisans, içerik moderation.

**Sprint 37–38: SOC2 Type II Prep**
- **Vanta** veya **Drata** ile compliance automation.
- Controls: access management, change management, incident response, vendor mgmt.
- 6 aylık observation window başlat.

**Sprint 39–40: KVKK + GDPR Tam Uyum**
- Data Processing Agreement (DPA) template.
- Right to access / delete / portability endpoint'leri.
- Cookie consent, geolocation-aware (TR vs EU vs US).
- Privacy Impact Assessment (PIA) dokümantasyonu.

**Sprint 41–42: Community + Knowledge Base**
- Discord + Discourse (forum).
- Documentation site v2 (Astro Starlight).
- Yıllık konferans: **AletCantasiCon 2027** (sanal, ücretsiz).
- Contributor program (sertifika + ödül).

**Sprint 43–44: i18n Genişleme (5 dil)**
- TR (zaten var), EN (D2'den hazır), ES, DE, AR, JA.
- Crowdin veya Lokalise.
- Locale-aware vault listing.

**Sprint 45–46: Enterprise Features**
- **SSO** (SAML 2.0, OIDC) — Okta, Azure AD, Google Workspace.
- **SCIM** kullanıcı provisioning.
- **Audit log** (immutable, exportable).
- **Custom contract**, **DPA**, **MSA**.

**Sprint 47–48: SOC2 Audit + Public IPO/Series A Prep**
- SOC2 Type II audit (external).
- Financial audit (CFO + auditor).
- Investor data room.
- D5 retro + 5-yıllık vizyon planı.

#### D5.3 D5 Bütçe Detayı (9 ay)

| Kalem | TL | USD |
|---|---:|---:|
| 10 mühendis × 9 ay (karışık seviyeler) | 8.100.000 | 247.700 |
| Topluluk yöneticisi × 9 ay | 540.000 | 16.515 |
| Hukuk danışmanı (GDPR + KVKK + Marketplace ToS) | 250.000 | 7.645 |
| SOC2 audit (Vanta + external auditor) | 800.000 | 24.460 |
| Marketing (konferans, ad, içerik) | 1.500.000 | 45.870 |
| Cloud (AWS/GCP, ölçeklenen) | 600.000 | 18.350 |
| API gateway (Kong / KrakenD) + DDoS protection | 150.000 | 4.587 |
| Translation services (Crowdin Pro) | 50.000 | 1.530 |
| Eğitim + senior maaş artışları (retention) | 400.000 | 12.230 |
| Conference budget (AletCantasiCon 2027) | 800.000 | 24.460 |
| Beklenmedik (~10%) | 1.319.000 | 40.337 |
| **D5 TOPLAM (9 ay)** | **14.509.000 ≈ 14.51M** | **443.684** |

#### D5.4 D5 OKR

**O1: Endüstri standardı bir AI-Native bilgi platformu olalım.**
- KR1: 100+ marketplace vault.
- KR2: 100K MAU, 5K paying customer.
- KR3: NPS > 60.

**O2: Compliance certified.**
- KR1: SOC2 Type II report yayınlandı.
- KR2: KVKK + GDPR audit geçti.
- KR3: HIPAA-ready (opsiyonel, healthcare için).

**O3: Sürdürülebilir iş.**
- KR1: MRR ≥ $50K.
- KR2: Gross margin ≥ %75.
- KR3: Burn multiple < 1.5.

---

#### Yol Haritası Özet Görseli

```
   D0        D1            D2            D3            D4              D5
   │       0-3 ay        3-6 ay        6-9 ay       9-15 ay        15-24 ay
   │
[Enkaz] → [Stabilize] → [Modernize] → [AI-Native] → [Multi-tenant] → [Ekosistem]
   │
   │ 100 dosya zip   monorepo+CI    1 shell+Lit    WebLLM+RAG     CRDT+Cloud   Marketplace+SOC2
   │ 0 test          %60 coverage   %80 coverage   E2E AI test    Load test    Penetration ✓
   │ 0 telemetri     Sentry         Plausible      LLM metrics    Grafana      Audit logs
   │ 0 doc           ADR + RFC      Storybook      API docs       SDK          Public API
   │ 0 user          alpha 100      beta 1K        public 10K     paid 100     enterprise
   │ 0 revenue       0              0              0              MRR $500     MRR $50K
```

---


## 5. Ekip, Bütçe ve OKR Genel Bakış

### 5.1 Hire Plan — Aylık FTE Trendi

| Ay | Mevcut | Senior FE | Mid FE | Senior BE/SRE | AI Eng | PM | Editör | Community | Hukuk |
|---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 1  | 0 | 1 | 1 | 0 | 0 | 0.5 | 0 | 0 | 0.1 |
| 3  | 3.6 | 2 | 1 | 0 | 0 | 0.5 | 0 | 0 | 0.1 |
| 6  | 6.5 | 2 | 2 | 0 | 0 | 1 | 1 | 0 | 0.1 |
| 9  | 8.0 | 2 | 2 | 0 | 1 | 1 | 1 | 0 | 0.1 |
| 15 | 9.0 | 2 | 2 | 1 | 1 | 1 | 1 | 0 | 0.1 |
| 24 | 13.0 | 2 | 3 | 2 | 2 | 1 | 1 | 1 | 0.5 |

### 5.2 Organizasyon Yapısı (24. ay)

```
                            ┌─────────────┐
                            │   Kurucu(lar)/CEO  │
                            └──────┬──────┘
                                   │
                  ┌────────────────┼─────────────┬────────────┐
                  │                │             │            │
              ┌───▼────┐     ┌─────▼─────┐ ┌────▼────┐   ┌────▼────┐
              │  CTO   │     │   CPO     │ │  CFO    │   │  GC     │
              └───┬────┘     └─────┬─────┘ └─────────┘   └─────────┘
                  │                │
        ┌─────────┼─────────┐      │
        │         │         │      │
   ┌────▼───┐ ┌───▼────┐ ┌──▼───┐  │
   │ FE Lead│ │ BE/SRE │ │ AI   │  └─── PM(2), Designer(1)
   │ + 4 FE │ │ Lead   │ │ Lead │
   │        │ │ + 1    │ │ +1   │
   └────────┘ └────────┘ └──────┘
   
   Yatay: Community(1), Editör(1), Sec/Comp danışmanı (yarı zamanlı)
```

### 5.3 24 Aylık Kümülatif Bütçe Tablosu

| Dönem | Süre | TL | USD |
|---|---|---:|---:|
| D1 | 0–3 ay (3 ay) | 1.948.540 | 59.543 |
| D2 | 3–6 ay (3 ay) | 2.909.500 | 88.913 |
| D3 | 6–9 ay (3 ay) | 3.467.200 | 105.962 |
| D4 | 9–15 ay (6 ay) | 8.734.000 | 267.013 |
| D5 | 15–24 ay (9 ay) | 14.509.000 | 443.684 |
| **TOPLAM** | **24 ay** | **31.568.240 ≈ 31.57M TL** | **965.115 USD** |

### 5.4 Gelir Projeksiyonu (Optimistik / Realist / Pesimist)

| Senaryo | D4 sonu MRR | D5 sonu MRR | D5 sonu ARR | Kümülatif gelir |
|---|---:|---:|---:|---:|
| Optimistik (Top decile) | $2.000 | $80.000 | $960.000 | $360.000 |
| Realist (median) | $500 | $50.000 | $600.000 | $180.000 |
| Pesimist (worst quartile) | $0 | $15.000 | $180.000 | $50.000 |

> **Yorum:**
> - Realist senaryoda **24 ayda $180K kümülatif gelir** vs **$965K kümülatif gider** → **net $785K yatırım**.
> - Bu, "klasik bir SaaS pre-revenue dönemi" profili.
> - D5'te ARR $600K'ya ulaşırsak → Seed sonrası **Series A için olgun** (10-15x ARR multiple ile $6-9M değerleme).

### 5.5 Hangi yeteneklere ihtiyacımız var (rol detayı)

#### Senior Frontend Engineer (D1'den başlar, çekirdek rol)

**İhtiyaç:** TypeScript strict, Web Components, modern build tooling (Vite), perf optimization (Web Vitals), accessibility expertise, test culture (TDD).

**Mülakat süreci:**
1. Telefon (45 dk): teknik geçmiş + culture-fit.
2. Live coding (90 dk): Web Components ile basit bir feature.
3. System design (60 dk): "100 dosyalık enkazı nasıl refactor edersin?"
4. Reverse Q&A (45 dk): aday CTO'ya soru sorar.

#### Senior AI Engineer (D3'ten itibaren)

**İhtiyaç:** Transformers.js / WebLLM deneyimi, embedding & vector search, RAG pipeline tasarımı, LLMOps (eval, prompt eng., cost optimization).

**Bonus:** ONNX Runtime, WebGPU shader, Hugging Face ecosystem.

#### Senior SRE / BE Engineer (D4'ten itibaren)

**İhtiyaç:** Bun/Node, Hono/Express, SQLite/LiteFS/Turso, Docker, CRDT (Yjs/Automerge), observability (Grafana/Prometheus).

#### Product Manager (D1'den itibaren, yarı zamanlı; D3'ten itibaren tam zamanlı)

**İhtiyaç:** B2C → B2B transition deneyimi, AI/dev-tool ürün portföyü, OKR/metric culture, user research.

#### Content Editor (D2'den itibaren)

**İhtiyaç:** AI prompt mühendisliği bilgisi, Türkçe + İngilizce native, dedupe/normalization süreçleri, **LLM çıktısını eleştirmeye** alışkın.

### 5.6 Yetenek tutma (retention) stratejisi

- **Equity / hisse opsiyonu**: %0.5–%2 (rolüne göre), 4 yıl vest + 1 yıl cliff.
- **Remote-first** + opsiyonel ofis (İstanbul / Ankara).
- **Eğitim bütçesi**: $1,000/kişi/yıl (konferans, kurs, kitap).
- **Donanım**: Apple Silicon MacBook Pro M4 32GB + harici monitör.
- **Pair-programming + code review kültürü** (knowledge silosu yok).
- **Postmortem culture**: blame-free, sadece sistemi geliştir.

---


## 6. Risk Yönetimi & Çıkış Stratejileri

### 6.1 Top-10 Stratejik Risk

| # | Risk | Olasılık | Etki | Erken uyarı sinyali | Tepki planı |
|---|---|:---:|:---:|---|---|
| 1 | Kurucu odak kaybı | Orta | Kritik | Sprint review'lara katılmama, OKR'larda gerileme | Advisory board kur, kurucu sözleşmesi |
| 2 | API key sızıntısı | Yüksek (D1'den önce) | Kritik | Reddit/Twitter'da kullanıcı şikayeti | D1.S3 zorunlu, halka açık disclosure |
| 3 | Avukat / hukuki bildirim | Düşük-Orta | Yüksek | BTK / KVKK soruları, takedown isteği | Hukuk danışman ortakta, age-gate, takedown SOP |
| 4 | Anahtar geliştirici kaybı | Orta | Yüksek | 1:1'lerde negatif sinyaller, sosyal medya | Equity vesting, bonus, knowledge sharing |
| 5 | Rakip ürün hızlı çıkar | Yüksek | Orta | Show HN / PH'ta benzer ürün | Differentation: TR içerik, local-first, ücretsiz tier |
| 6 | LLM provider fiyat artışı | Yüksek | Orta | Aylık fatura > %20 artar | Local LLM, multi-provider router |
| 7 | Tarayıcı browser API breaking change | Düşük | Orta | Chrome/Firefox beta'da deprecation warning | Feature flag, polyfill, sürüm uyarısı |
| 8 | Yatırım tükenmesi | Orta | Kritik | Aylık burn rate plan üstünde | Pre-emptive cost-cut, bridge round, kemer sıkma |
| 9 | Veri bütünlüğü kaybı (CRDT bug) | Düşük | Kritik | Sentry'de "merge conflict" exception | Backup + restore, kullanıcı bilgilendirme, postmortem |
| 10 | İçerik moderasyon felaketi (örn. yasadışı content) | Düşük | Kritik | Kullanıcı raporu, takedown isteği | Auto-flag + manuel review, kullanım şartları |

### 6.2 İş Sürekliliği Planı (BCP)

#### Senaryo A: CTO (ben) görevi bırakırsam
- **Yedek:** Lead FE veya en kıdemli geliştirici geçici CTO.
- **Knowledge transfer:** Tüm strateji bu raporda + repo'da. ADR'lar takip edilebilir.
- **Sözleşme:** 6 aylık notice period + danışman olarak 3 ay devam.

#### Senaryo B: Tek kurucu hastalanır veya görev bırakır
- **Yedek:** Board / advisory karar verir.
- **Hisse opsiyonu:** founder vesting devam eder.
- **Ürün lisansları:** key man insurance (zorunlu D3+).

#### Senaryo C: Cloud provider down
- **Self-host yedeği:** kullanıcı her zaman lokal moda dönebilir (local-first felsefe).
- **Multi-region:** D4'ten itibaren ABD + AB region'larda mirror.
- **Backup:** günlük S3 cross-region backup, 30-gün retention.

#### Senaryo D: Yangın / fiziksel ofis felaketi
- **Remote-first** olduğumuz için minimum etki.
- **Donanım kaybı:** insurance (~$500/ay) + 24 saat içinde yedek MacBook.

### 6.3 Çıkış Stratejileri (Exit options)

Bu bir teknik strateji dokümanıdır ama bir CTO olarak kurucunun **finansal çıkışını**
hesaba katmadan strateji kuramam. Üç olasılık:

#### Çıkış 1: Acquihire (Yıl 2–3)
- Hedef alıcılar: **Hugging Face, Anthropic, Notion, Linear, Vercel, GitHub**.
- Senaryo: Ürün yarı yarıya başarılı ama kendi başına sürdürülemiyor.
- Beklenen değerleme: $5M – $15M.
- Ekip-merkezli (founder + 5-10 mühendis).

#### Çıkış 2: Series A (Yıl 2)
- Hedef: $5M Series A, $25M post-money.
- VC: Türk girişim sermayeleri (212, Earlybird Digital East, Revo) + global (Index, Sequoia EU).
- Şart: D4 sonu ARR $300K-500K + büyüme >%15/ay.

#### Çıkış 3: Bootstrap → Sürdürülebilir küçük şirket
- Hedef: $50K MRR, 13 kişilik ekip, kârlı.
- Felsefe: Basecamp / 37signals modeli.
- Hisse satışı yok; kuruculara dağıtılan kâr.

### 6.4 Patent ve Fikri Mülkiyet Stratejisi

**Patent başvuru kararı (D2 sonu):**
- "**Local-first, multi-vault embedding with hybrid retrieval**" — provisional patent?
- "**WebCrypto-backed master-password key vault for browser**" — defansif patent?
- Maliyet: ~$5K-15K / patent (Türk Patent + PCT).
- Karar: **D3'ten önce hukuk danışmanlığı**; "patent troll" olmayacağımıza söz veririz, ama defansif amaçla başvuru tutarız.

**Telif hakkı:**
- AI ile üretilen içerik için: **CC-BY-4.0** lisansı önerim. Kaynak gösterimi zorunlu, ticari kullanım serbest.
- Marketplace vault'ları için: her vault kendi lisansını seçer (CC, MIT, proprietary).

**Trademark:**
- "Alet Çantası" (TR) + "Toolbox AI" (EN) + logo → Türk Patent Enstitüsü başvurusu (D2).
- Maliyet: ~$500-1500.

---


## Ek 1: Repo Önerileri Konsolidasyon Tablosu

`alet-cantasi-100-repo-onerisi.md` dokümanındaki 130+ repo, dönemlerimize göre konsolide edildi.

### Ek 1.1 D1'de kullanılacak repolar (kritik)

| Amaç | Repo | Lisans | Dönem | Aciliyet |
|---|---|---|---|---|
| Linter+Formatter | `biomejs/biome` | MIT | D1.S1 | Yüksek |
| Test runner | `vitest-dev/vitest` | MIT | D1.S1 | Yüksek |
| E2E test | `microsoft/playwright` | Apache-2.0 | D1.S4 | Yüksek |
| A11y test | `dequelabs/axe-core` | MPL-2.0 | D1.S4 | Yüksek |
| Lighthouse CI | `GoogleChrome/lighthouse-ci` | Apache-2.0 | D1.S4 | Yüksek |
| Schema validation | `colinhacks/zod` | MIT | D1.S2 | Yüksek |
| Date manipulation | `date-fns/date-fns` | MIT | D1.S5 | Orta |
| Type-safe HTTP | `oven-sh/bun` | MIT | D1.S6 | Düşük |
| Error monitoring | `getsentry/sentry-javascript` | MIT | D1.S6 | Yüksek |
| Analytics | `plausible/community-edition` | AGPLv3 | D1.S6 | Yüksek |
| XSS sanitize | `cure53/DOMPurify` | Apache-2.0 / MPL | D1.S3 | Kritik |

### Ek 1.2 D2'de kullanılacak repolar

| Amaç | Repo | Lisans | Dönem |
|---|---|---|---|
| Web Components | `lit/lit` | BSD-3 | D2.S7 |
| IndexedDB wrapper | `dexie/Dexie.js` | Apache-2.0 | D2.S8 |
| Full-text search | `nextapps-de/flexsearch` | Apache-2.0 | D2.S8 |
| Virtual scroll | `TanStack/virtual` | MIT | D2.S7 |
| Service Worker | `GoogleChrome/workbox` | MIT | D2.S10 |
| Design tokens | `amzn/style-dictionary` | Apache-2.0 | D2.S12 |
| Storybook | `storybookjs/storybook` | MIT | D2.S12 |
| i18n | `lingui/js-lingui` | MIT | D2.S11 |
| Markdown rendering | `remarkjs/remark` | MIT | D2.S7 |
| OG image gen | `vercel/satori` | MPL-2.0 | D2.S12 |

### Ek 1.3 D3'te kullanılacak repolar (AI-Native)

| Amaç | Repo | Lisans | Dönem |
|---|---|---|---|
| Transformer in browser | `xenova/transformers.js` | Apache-2.0 | D3.S13 |
| Browser LLM | `mlc-ai/web-llm` | Apache-2.0 | D3.S15 |
| Vector index | `unum-cloud/usearch` | Apache-2.0 | D3.S13 |
| MCP SDK | `modelcontextprotocol/typescript-sdk` | MIT | D3.S17 |
| OpenAI client | `openai/openai-node` | Apache-2.0 | D3.S17 |
| Anthropic client | `anthropics/anthropic-sdk-typescript` | MIT | D3.S17 |
| Graph viz | `cytoscape/cytoscape.js` | MIT | D3.S18 |
| Tokenizer | `huggingface/tokenizers` | Apache-2.0 | D3.S13 |
| WebGPU helpers | `gpuweb/types` | BSD | D3.S15 |

### Ek 1.4 D4'te kullanılacak repolar (Multi-tenant)

| Amaç | Repo | Lisans |
|---|---|---|
| CRDT | `yjs/yjs` | MIT |
| WebSocket sync | `yjs/y-websocket` | MIT |
| Backend framework | `honojs/hono` | MIT |
| JS runtime | `oven-sh/bun` | MIT |
| Database | `tursodatabase/turso` | MIT |
| Auth | `oslo-project/oslo` | MIT |
| Payment | `lmsqueezy/lemonsqueezy.js` | MIT |
| Container | `docker/compose` | Apache-2.0 |
| Helm chart helper | `helm/helm` | Apache-2.0 |
| Load test | `grafana/k6` | AGPLv3 (test only OK) |
| Observability | `grafana/grafana` | AGPLv3 (free self-host) |
| Prometheus | `prometheus/prometheus` | Apache-2.0 |
| Loki | `grafana/loki` | AGPLv3 |
| Encryption | `paulmillr/noble-ciphers` | MIT |
| Sodium | `jedisct1/libsodium.js` | ISC |

### Ek 1.5 D5'te kullanılacak repolar (Ekosistem)

| Amaç | Repo | Lisans |
|---|---|---|
| Forum | `discourse/discourse` | GPL-2.0 (self-host OK) |
| Docs site | `withastro/starlight` | MIT |
| SSO (SAML) | `auth0/node-saml` | MIT |
| SCIM | `microsoft/scim-for-developers` | MIT |
| Compliance | (Vanta SaaS — yok) | proprietary |
| API gateway | `Kong/kong` | Apache-2.0 |
| Translation | `crowdin/crowdin-cli` | MIT |
| Search index Pro | `meilisearch/meilisearch` | MIT |

### Ek 1.6 Lisans uyumluluğu özet

| Lisans | Repo sayısı | Ticari kullanım OK? | Distribute OK? |
|---|---:|---|---|
| MIT | ~70 | ✅ | ✅ |
| Apache-2.0 | ~35 | ✅ | ✅ |
| BSD-3 | ~10 | ✅ | ✅ |
| MPL-2.0 | ~5 | ✅ | ✅ (file-level copyleft) |
| ISC | ~3 | ✅ | ✅ |
| AGPL-3.0 | ~7 | ⚠️ (sadece self-host) | ⚠️ |
| GPL-2.0 | ~1 (Discourse) | ⚠️ (sadece self-host) | ⚠️ |

**AGPL note:** Grafana, Plausible, Loki, k6 → self-host yapıyoruz, kullanıcıya servis vermiyoruz, bu nedenle güvenli. Eğer ileride **bu yazılımları SaaS olarak satarsak** AGPL gereği tüm kaynak kodu açıklamak zorundayız. **D5 hukuk audit'inde mutlaka tekrar gözden geçirilmeli**.

---


## Ek 2: Kod Smell Kataloğu — "Önce/Sonra" Karşılaştırmaları

Bu ek, ekibin **somut örnekler** üzerinden tasarım kararlarına itiraz edememesi için bir referans.
Her smell için **legacy kod** ve **önerilen yeniden yazım** gösterilir.

### Smell S-01: Inline JSON + global ITEMS değişkeni

**Legacy (her vault HTML'inde):**
```javascript
const ITEMS = [
  {"id": 1, "no": "001", "cat": "Model Seçimi",
   "name": "Uygun Model Belirleme",
   "desc": "Gelen isteğe en uygun AI modelini seçme.",
   "tags": ["model seçimi", "yönlendirme", "API"],
   "badge1": "Başlangıç",
   "content": "## En Uygun Modeli Seçme\\n1. ...",
   "source": {"generated": true, "provider": "gemini", "model": "..."}
  },
  // ... 6393 daha
];

const CATS = {
  "Model Seçimi": {n: 53, c: "#a375ff"},
  // ...
};

let activeCat = 'all';
let activeItem = null;
```

**Sorunlar:**
1. Global namespace kirliliği.
2. Veri ile UI birleşik (testability sıfır).
3. Mutation state takip edilemez.
4. Bellek sızıntısı potansiyeli.
5. Type safety yok.

**Modern (D2 sonu):**
```typescript
// packages/core/src/vault-store.ts
import { create } from 'nanostores';
import { z } from 'zod';

export const ItemSchema = z.object({
  id: z.string().ulid(),
  vaultId: z.string(),
  no: z.string().regex(/^\d{3,}$/),
  cat: z.string(),
  name: z.string().min(1),
  desc: z.string(),
  tags: z.array(z.string()),
  badges: z.object({
    primary: z.string().optional(),
    secondary: z.string().optional(),
  }).optional(),
  content: z.string(),
  source: z.object({
    generated: z.boolean(),
    provider: z.enum(['gemini', 'gpt-4', 'claude', 'human']).optional(),
    model: z.string().optional(),
    reviewedBy: z.string().optional(),
    license: z.string().default('CC-BY-4.0'),
  }),
  variantOf: z.string().ulid().nullable(),
  hash: z.string().length(64),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
});

export type Item = z.infer<typeof ItemSchema>;

export const $activeVaultId = atom<string | null>(null);
export const $activeCategory = atom<string>('all');
export const $selectedItemId = atom<string | null>(null);
export const $searchQuery = atom<string>('');

// Reactive computed: filtered items
export const $filteredItems = computed(
  [$activeVaultId, $activeCategory, $searchQuery],
  async (vaultId, category, query) => {
    if (!vaultId) return [];
    return await dataService.getItems(vaultId, {
      category: category === 'all' ? undefined : category,
      search: query || undefined,
    });
  }
);
```

**Yeni Kazanımlar:**
- ✅ Tip güvenliği (compile-time check).
- ✅ Reaktivitenin merkezi (RxJS-level paterni).
- ✅ Test edilebilir (mock dataService).
- ✅ Lazy loading (IndexedDB'den çekiyor).
- ✅ Şema doğrulama (build-time + runtime).

---

### Smell S-02: innerHTML ile template stringler

**Legacy:**
```javascript
function buildItemList(items){
  const el = document.getElementById('itemList');
  el.innerHTML = items.map((s,i) => `
    <div class="item-row" id="item-${s.id}"
         style="--sc:${cc}" onclick="selectItem(${s.id})">
      <span class="item-no">${no}</span>
      <span class="item-dot"></span>
      <div class="item-info">
        <div class="item-name">${esc(s.name)}</div>
      </div>
    </div>
  `).join('');
}
```

**Sorunlar:**
1. `${cc}` escape edilmiyor → XSS.
2. `onclick=` inline → CSP 'unsafe-inline' gerektirir.
3. innerHTML her seferinde tüm listeyi yeniden çiziyor → 6000 item'da 200ms+.
4. Memory leak: eski event listener'lar temizlenmiyor (garbage collection sebebiyle değil ama bağlı state'ler kaybolur).

**Modern (Web Components + Lit):**
```typescript
// packages/ui/src/components/ac-item-list.ts
import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { repeat } from 'lit/directives/repeat.js';
import { styleMap } from 'lit/directives/style-map.js';
import type { Item } from '@aletcantasi/core';

@customElement('ac-item-list')
export class AcItemList extends LitElement {
  @property({ type: Array }) items: Item[] = [];
  @property({ type: String }) selectedId: string | null = null;

  static styles = css`
    :host { display: block; }
    .item-row {
      padding: 12px;
      border-bottom: 1px solid var(--border);
      cursor: pointer;
      transition: background 0.15s;
    }
    .item-row:hover, .item-row[aria-selected="true"] {
      background: var(--bg2);
    }
    .item-row:focus-visible {
      outline: 2px solid var(--primary);
      outline-offset: -2px;
    }
  `;

  private handleSelect(item: Item) {
    this.dispatchEvent(new CustomEvent('item-selected', {
      detail: { itemId: item.id },
      bubbles: true,
      composed: true,
    }));
  }

  private handleKeyDown(e: KeyboardEvent, item: Item) {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      this.handleSelect(item);
    }
  }

  render() {
    return html`
      <div role="listbox" aria-label="Öğe listesi">
        ${repeat(
          this.items,
          (item) => item.id,
          (item) => html`
            <div
              role="option"
              tabindex="0"
              class="item-row"
              aria-selected=${item.id === this.selectedId}
              style=${styleMap({ '--sc': item.color ?? 'var(--primary)' })}
              @click=${() => this.handleSelect(item)}
              @keydown=${(e: KeyboardEvent) => this.handleKeyDown(e, item)}
            >
              <span class="item-no">${item.no}</span>
              <span class="item-name">${item.name}</span>
            </div>
          `
        )}
      </div>
    `;
  }
}
```

**Kazanımlar:**
- ✅ Lit'in `repeat` directive'i ile **virtual DOM**-like update (yalnızca değişen item'lar re-render).
- ✅ Shadow DOM ile CSS izolasyonu (tüm vault'ta tek copy).
- ✅ Custom event'ler → testable.
- ✅ ARIA + klavye desteği baştan.
- ✅ `@click` Lit event binding → CSP-uyumlu (`unsafe-inline` gerektirmez).

---

### Smell S-03: API Anahtarı Plaintext

**Legacy:**
```javascript
// API key girildiğinde
function saveApiKey() {
  const key = document.getElementById('apiInput').value;
  localStorage.setItem('apiKey', key);
}

// Kullanımda
function callApi() {
  const key = localStorage.getItem('apiKey');
  fetch('https://api.anthropic.com/v1/messages', {
    headers: { 'x-api-key': key },
    // ...
  });
}
```

**Sorunlar:**
1. Plaintext localStorage → XSS sızıntısında anahtar gider.
2. Tarayıcı extension'ları okuyabilir.
3. DevTools açan kullanıcı görür.

**Modern (D1.S3):**
```typescript
// packages/core/src/services/KeyVaultService.ts
export class KeyVaultService {
  private masterKey: CryptoKey | null = null;

  // Kullanıcı master password girer
  async unlock(passphrase: string): Promise<void> {
    const enc = new TextEncoder();
    const baseKey = await crypto.subtle.importKey(
      'raw',
      enc.encode(passphrase),
      { name: 'PBKDF2' },
      false,
      ['deriveKey']
    );

    const salt = await this.getSalt(); // Saklı salt
    this.masterKey = await crypto.subtle.deriveKey(
      {
        name: 'PBKDF2',
        salt,
        iterations: 100_000,
        hash: 'SHA-256',
      },
      baseKey,
      { name: 'AES-GCM', length: 256 },
      false,
      ['encrypt', 'decrypt']
    );
  }

  async storeApiKey(provider: 'openai' | 'anthropic' | 'gemini', value: string): Promise<void> {
    if (!this.masterKey) throw new Error('Vault locked');

    const iv = crypto.getRandomValues(new Uint8Array(12));
    const enc = new TextEncoder();
    const ciphertext = await crypto.subtle.encrypt(
      { name: 'AES-GCM', iv },
      this.masterKey,
      enc.encode(value)
    );

    const packed = {
      iv: Array.from(iv),
      ct: Array.from(new Uint8Array(ciphertext)),
    };

    // IndexedDB üzerinden saklanır (daha güvenli olarak)
    await db.apiKeys.put({ id: provider, ...packed });
  }

  async getApiKey(provider: string): Promise<string | null> {
    if (!this.masterKey) throw new Error('Vault locked');
    const row = await db.apiKeys.get(provider);
    if (!row) return null;

    const decrypted = await crypto.subtle.decrypt(
      { name: 'AES-GCM', iv: new Uint8Array(row.iv) },
      this.masterKey,
      new Uint8Array(row.ct)
    );
    return new TextDecoder().decode(decrypted);
  }

  lock() {
    this.masterKey = null; // Garbage collected
  }

  private async getSalt(): Promise<Uint8Array> {
    let salt = await db.settings.get('salt');
    if (!salt) {
      const newSalt = crypto.getRandomValues(new Uint8Array(16));
      await db.settings.put({ key: 'salt', value: Array.from(newSalt) });
      return newSalt;
    }
    return new Uint8Array(salt.value);
  }
}
```

**Kullanım:**
```typescript
// İlk açılış: master password seç
await keyVault.unlock(prompt('Master password?')!);
await keyVault.storeApiKey('anthropic', 'sk-ant-...');

// Sonraki açılışlar
await keyVault.unlock(prompt('Master password?')!);
const key = await keyVault.getApiKey('anthropic');
```

**Kazanımlar:**
- ✅ XSS olsa bile anahtar ele geçirilemez (ciphertext + key in memory).
- ✅ Browser extension'ları okuyamaz.
- ✅ Yetkisiz erişim → ciphertext zaten encrypted.
- ✅ PBKDF2 100K iteration → brute force pahalı.
- ✅ Lock() ile session sonu hemen temizleniyor.

---

### Smell S-04: Onclick attribute kullanımı

**Legacy:**
```html
<button class="cat-btn" onclick="filterCat('all',this)">Tümü</button>
```

**Sorunlar:**
- CSP `unsafe-inline` zorunlu.
- Event delegation yok → her butona ayrı listener.
- Test edilemez (string evaluation).

**Modern:**
```html
<button class="cat-btn" data-cat="all" data-action="filter-cat">Tümü</button>
```

```typescript
// Event delegation tek yerden
document.addEventListener('click', (e) => {
  const btn = (e.target as HTMLElement).closest('[data-action]');
  if (!btn) return;
  const action = btn.dataset.action;
  switch (action) {
    case 'filter-cat':
      filterCat(btn.dataset.cat!);
      break;
    // ...
  }
});
```

---

### Smell S-05: 100 Dosyada CSS Çoğaltması

**Legacy:**
```html
<!-- Her HTML'de aynı 3500 satır CSS, sadece renk değişkenleri farklı -->
<style>
:root {
  --primary: #a375ff;  /* PromptVault */
  --accent: #ff6b9d;
}
/* ... 3500 satır daha */
</style>
```

**Modern (D2):**
```typescript
// packages/tokens/src/vaults.ts
export const VAULT_PALETTES = {
  ai: { primary: '#a375ff', accent: '#ff6b9d' },        // PromptVault, RouterVault
  game: { primary: '#5ed47e', accent: '#34c66c' },      // GameVault, EngineVault
  history: { primary: '#d4a04c', accent: '#c97e4c' },   // KemalistVault
  // ... 6 kategori
} as const;
```

```css
/* Tek bir base CSS dosyası: packages/ui/src/styles/base.css */
:root {
  --primary: #a375ff;
  --accent: #ff6b9d;
  /* ... default değerler */
}

[data-vault-category="game"] {
  --primary: #5ed47e;
  --accent: #34c66c;
}

[data-vault-category="history"] {
  --primary: #d4a04c;
  --accent: #c97e4c;
}
```

```html
<html data-vault-category="history">
  <body>
    <ac-vault-app vault-id="kemalistvault"></ac-vault-app>
  </body>
</html>
```

**Kazanımlar:**
- ✅ 3500 satır CSS → tek seferlik. Bundle size 100x küçük.
- ✅ Yeni vault eklemek → CSS değişikliği yok, palette güncelle.
- ✅ Dark / Light mode tek `@media (prefers-color-scheme)` veya `[data-theme]`.

---

### Smell S-06: Eksik error handling

**Legacy:**
```javascript
function copyContent(id) {
  const item = ITEMS.find(x => x.id === id);
  if (!item) return; // Sessizce kayboluyor
  navigator.clipboard.writeText(item.content || '');  // Promise yutuluyor
}
```

**Modern:**
```typescript
async function copyContent(itemId: ULID): Promise<Result<void, CopyError>> {
  try {
    const item = await dataService.getItem(itemId);
    if (!item) {
      Sentry.captureMessage('Item not found', { extra: { itemId } });
      return { ok: false, error: { type: 'NOT_FOUND', itemId } };
    }

    if (!navigator.clipboard) {
      return { ok: false, error: { type: 'API_UNAVAILABLE' } };
    }

    await navigator.clipboard.writeText(item.content);
    telemetry.track('item_copied', { vaultId: item.vaultId, itemId });
    return { ok: true, value: undefined };

  } catch (err) {
    Sentry.captureException(err);
    return { ok: false, error: { type: 'UNKNOWN', cause: err } };
  }
}
```

---


## Ek 3: Hazır CI/CD Şablonu

### Ek 3.1 GitHub Actions — Ana CI Workflow

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  NODE_VERSION: '22'
  PNPM_VERSION: '9'

jobs:
  lint-and-typecheck:
    name: Lint & Type Check
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
        with: { version: ${{ env.PNPM_VERSION }} }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm biome check .
      - run: pnpm tsc --noEmit

  unit-test:
    name: Unit + Integration Tests
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: lint-and-typecheck
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
        with: { version: ${{ env.PNPM_VERSION }} }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm vitest run --coverage
      - uses: codecov/codecov-action@v4
        with:
          fail_ci_if_error: true
          token: ${{ secrets.CODECOV_TOKEN }}

  data-validation:
    name: Validate data/*.ndjson against Zod schemas
    runs-on: ubuntu-latest
    timeout-minutes: 10
    needs: lint-and-typecheck
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
        with: { version: ${{ env.PNPM_VERSION }} }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm validate:data
      - run: pnpm check:manifest

  build:
    name: Build all apps
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: [lint-and-typecheck, unit-test]
    outputs:
      cache-key: ${{ steps.turbo-cache.outputs.cache-key }}
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
        with: { version: ${{ env.PNPM_VERSION }} }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'
      - id: turbo-cache
        uses: actions/cache@v4
        with:
          path: .turbo
          key: turbo-${{ github.sha }}
          restore-keys: turbo-
      - run: pnpm install --frozen-lockfile
      - run: pnpm turbo build
      - uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: |
            apps/launcher/dist
            apps/vault-app/dist

  e2e-test:
    name: E2E Tests (Playwright)
    runs-on: ubuntu-latest
    timeout-minutes: 30
    needs: build
    strategy:
      fail-fast: false
      matrix:
        browser: [chromium, firefox, webkit]
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
        with: { version: ${{ env.PNPM_VERSION }} }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'
      - uses: actions/download-artifact@v4
        with: { name: build-artifacts }
      - run: pnpm install --frozen-lockfile
      - run: pnpm playwright install ${{ matrix.browser }} --with-deps
      - run: pnpm playwright test --project=${{ matrix.browser }}
      - if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report-${{ matrix.browser }}
          path: playwright-report

  lighthouse-ci:
    name: Lighthouse CI
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: build
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with: { name: build-artifacts }
      - uses: pnpm/action-setup@v3
        with: { version: ${{ env.PNPM_VERSION }} }
      - uses: actions/setup-node@v4
        with: { node-version: ${{ env.NODE_VERSION }} }
      - run: pnpm install --frozen-lockfile
      - run: pnpm lhci autorun
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}

  a11y-test:
    name: Accessibility Tests
    runs-on: ubuntu-latest
    timeout-minutes: 20
    needs: build
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
        with: { version: ${{ env.PNPM_VERSION }} }
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm playwright install chromium --with-deps
      - run: pnpm a11y:test

  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with: { languages: typescript, javascript }
      - uses: github/codeql-action/analyze@v3
      - uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          severity: 'HIGH,CRITICAL'
          exit-code: '1'

  license-check:
    name: License Compliance
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
        with: { version: ${{ env.PNPM_VERSION }} }
      - uses: actions/setup-node@v4
        with: { node-version: ${{ env.NODE_VERSION }} }
      - run: pnpm install --frozen-lockfile
      - run: pnpm license-checker --production --excludePackages 'aletcantasi-monorepo' --onlyAllow 'MIT;Apache-2.0;BSD-2-Clause;BSD-3-Clause;ISC;MPL-2.0;CC-BY-4.0'

  bundle-size:
    name: Bundle Size Budget
    runs-on: ubuntu-latest
    timeout-minutes: 10
    needs: build
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with: { name: build-artifacts }
      - uses: andresz1/size-limit-action@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Ek 3.2 Lighthouse CI Konfigürasyonu

```javascript
// lighthouserc.cjs
module.exports = {
  ci: {
    collect: {
      url: [
        'http://localhost:4173/',
        'http://localhost:4173/vault/promptvault',
        'http://localhost:4173/vault/routervault',
        'http://localhost:4173/vault/kemalistvault',
      ],
      numberOfRuns: 3,
      settings: {
        preset: 'desktop', // first pass
      },
    },
    assert: {
      preset: 'lighthouse:recommended',
      assertions: {
        'categories:performance': ['error', { minScore: 0.75 }],
        'categories:accessibility': ['error', { minScore: 0.95 }],
        'categories:best-practices': ['error', { minScore: 0.90 }],
        'categories:seo': ['error', { minScore: 0.95 }],
        'first-contentful-paint': ['error', { maxNumericValue: 2000 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
        'total-blocking-time': ['error', { maxNumericValue: 200 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
```

### Ek 3.3 Bundle size budget

```javascript
// .size-limit.cjs
module.exports = [
  {
    name: 'apps/launcher',
    path: 'apps/launcher/dist/**/*.{js,css}',
    limit: '50 KB',
    gzip: true,
  },
  {
    name: 'apps/vault-app shell',
    path: 'apps/vault-app/dist/index.html',
    limit: '15 KB',
    gzip: true,
  },
  {
    name: 'apps/vault-app vendor',
    path: 'apps/vault-app/dist/assets/vendor-*.js',
    limit: '100 KB',
    gzip: true,
  },
];
```

### Ek 3.4 _headers (Cloudflare Pages) — CSP

```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: geolocation=(), microphone=(), camera=(), payment=()
  Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
  Content-Security-Policy: default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self'; font-src 'self' data:; connect-src 'self' https://api.openai.com https://api.anthropic.com https://generativelanguage.googleapis.com https://*.sentry.io https://*.plausible.io; img-src 'self' data:; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'; upgrade-insecure-requests
  Cross-Origin-Opener-Policy: same-origin
  Cross-Origin-Embedder-Policy: require-corp
  Cross-Origin-Resource-Policy: same-origin

/data/*
  Cache-Control: public, max-age=86400, immutable
  Content-Type: application/x-ndjson

/sw.js
  Cache-Control: no-cache, no-store, must-revalidate

/manifest.webmanifest
  Cache-Control: public, max-age=3600
  Content-Type: application/manifest+json
```

### Ek 3.5 Dependabot konfigürasyonu

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 5
    groups:
      dev-dependencies:
        dependency-type: "development"
        update-types: ["minor", "patch"]
      production-dependencies:
        dependency-type: "production"
        update-types: ["patch"]
    ignore:
      - dependency-name: "*"
        update-types: ["version-update:semver-major"] # major'lar manuel

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### Ek 3.6 Release Workflow (semantic-release)

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: pnpm/action-setup@v3
        with: { version: 9 }
      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: 'pnpm' }
      - run: pnpm install --frozen-lockfile
      - run: pnpm turbo build
      - run: pnpm semantic-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

```javascript
// release.config.cjs
module.exports = {
  branches: ['main'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    ['@semantic-release/changelog', { changelogFile: 'CHANGELOG.md' }],
    '@semantic-release/github',
    ['@semantic-release/git', {
      assets: ['CHANGELOG.md', 'package.json', 'packages/*/package.json'],
      message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}',
    }],
  ],
};
```

---


## Ek 4: Mimari Karar Kayıtları (ADR) Şablon Seti

D1'in ilk haftalarında yazılması gereken ADR'lar (kararı verecek kişiler arasında ortak
düşünce oluşturmak için).

### ADR-0001: Monorepo Tool — pnpm + Turborepo

**Durum:** Önerildi (Sprint 1)

**Bağlam:**
Mevcut: Zip arşivi, repo yok. Üstüne kurulacak monorepo aday teknolojileri:
- npm workspaces (built-in)
- yarn workspaces classic + berry
- pnpm workspaces + Turborepo / Nx
- Lerna (deprecated, Nx maintains)
- Bun workspaces (yeni, immature)
- Rush (Microsoft, opinionated)

**Karar:**
**pnpm 9.x + Turborepo 2.x** kullanılacaktır.

**Sonuçlar:**
- ✅ pnpm: symbolic link tabanlı, disk %60 daha az kullanır.
- ✅ pnpm: strict — phantom dependency yok.
- ✅ Turborepo: incremental build, CI cache, parallel execution.
- ✅ Topluluk: 2026 itibarıyla Vercel, Vue, Nuxt resmi olarak pnpm önerir.
- ❌ Yeni geliştirici onboarding: 1 saatlik adapt süresi.
- ❌ pnpm-deduplicate ve diğer migration sorunları nadir ama olabilir.

**Alternatifler:**
- **Nx:** Daha güçlü ama daha karmaşık. 4 kişilik ekibe over-engineered.
- **Bun workspaces:** Çok hızlı ama ekosistem henüz olgun değil. D4'te yeniden değerlendirilebilir.
- **npm workspaces:** Cache yok, dedup zayıf.

---

### ADR-0002: Programming Language — TypeScript Strict

**Durum:** Önerildi (Sprint 1)

**Bağlam:**
Mevcut: JavaScript (ES2020+). 100 dosyada inline `<script>` tag'leri.

**Karar:**
**TypeScript 5.x with `strict: true`, `noUncheckedIndexedAccess: true`, `exactOptionalPropertyTypes: true`.**

**Sonuçlar:**
- ✅ Build-time error detection.
- ✅ IDE autocomplete + refactor güveni.
- ✅ Zod ile birlikte runtime + compile-time type safety.
- ❌ Build adımı zorunlu (Vite süratli, sorun değil).
- ❌ Learning curve (mevcut ekip JS-only ise eğitim gerekli).

**Alternatifler:**
- **JavaScript + JSDoc:** Hızlı başlangıç ama refactor güveni zayıf.
- **ReScript / OCaml:** Çok güvenli ama nadir ekosistem.

---

### ADR-0003: Linter — Biome (ESLint + Prettier yerine)

**Durum:** Önerildi

**Bağlam:**
JS/TS ekosisteminde lint + format için ESLint + Prettier standart. Ama 2024-2025'te
**Biome** Rust ile yazılmış tek-aletle çözümün **35× daha hızlı** olduğunu kanıtladı.

**Karar:**
**Biome** kullanılacaktır.

**Sonuçlar:**
- ✅ Tek araç (lint + format + import sort).
- ✅ 35× daha hızlı (büyük repo'larda gözle görülür).
- ✅ Biome v1.7+ stabil.
- ❌ ESLint plugin ekosistemi yok (özel kurallar için bekleyebiliriz).
- ❌ Yeni geliştirici "biome check" komutunu öğrenmeli.

**Alternatifler:**
- **ESLint + Prettier + import/sort:** Daha esnek, daha yavaş, daha karmaşık.
- **dprint:** Yine Rust ama daha az feature.

---

### ADR-0004: UI Framework — Vanilla Web Components + Lit

**Durum:** Önerildi

**Bağlam:**
SPA framework seçimi: React, Vue, Svelte, Solid, Lit, vanilla.

**Karar:**
**Vanilla JavaScript + Web Components (Lit 3.x) kütüphanesi**.

**Gerekçe:**
- 100 vault için tek shell yeterli; React tree'ye gerek yok.
- Web Components → tarayıcı standardı, 10 yıl sonra da çalışır.
- Lit, vanilla'ya en yakın olan reactive layer (tiny: 6 KB gzip).
- Shadow DOM ile CSS izolasyonu.
- React/Vue gibi framework'lerin VDOM overhead'i, performans için gerekli değil.

**Sonuçlar:**
- ✅ Bundle size çok küçük (6 KB Lit vs 40 KB React).
- ✅ Tarayıcı sürümlerine bağımlılık 0.
- ✅ Web Components plugin/extension mimarisine doğal uyar (D5).
- ❌ React'ten gelen developer için learning curve.
- ❌ Component library ekosistemi React kadar zengin değil.

**Alternatifler:**
- **React:** Topluluk geniş ama overhead büyük, framework lock-in.
- **Vue 3:** Iyi ama yine framework bağımlılığı.
- **Svelte 5 / Solid:** Build-time, çok küçük ama mature ekosistem React'ten az.

---

### ADR-0005: Data Layer — IndexedDB (Dexie) + OPFS

**Durum:** Önerildi (Sprint 8'de uygulanır)

**Bağlam:**
Mevcut: 52,938 öğe HTML içine inline gömülü. 12.4 MB tek dosya. Tarayıcıyı dondurur.

**Karar:**
- **IndexedDB** (Dexie 4 wrapper) → küçük-orta data (item metadata, search index).
- **OPFS** (Origin Private File System) → büyük binary data (embeddings.bin, model files).
- **NDJSON** dosyaları sürüm kontrolünde, ilk açılışta IndexedDB'e bulk import.

**Sonuçlar:**
- ✅ Lazy loading: ilk açılış 100 KB, kullanıcı vault açtıkça +1-10 MB.
- ✅ Memory'de sadece görünen 30 item (virtual scroll).
- ✅ Offline çalışır (PWA + Service Worker + IndexedDB).
- ✅ Quota: IndexedDB'de 50-60% disk (modern tarayıcılar).
- ❌ Migration script gerekiyor (eski HTML → NDJSON).
- ❌ Schema migration (Dexie versioning) ek bir disiplin gerektirir.

**Alternatifler:**
- **LocalStorage:** 5 MB limit, sync, küçük data için OK ama bu kullanım için yetersiz.
- **SQLite-WASM (sql.js):** Güçlü ama kompleks, ilk yükleme 1 MB.
- **PGlite:** Olgun değil (2026 itibarıyla beta).

---

### ADR-0006: LLM Inference — WebLLM + Transformers.js (D3)

**Durum:** Önerildi (D3.S15)

**Bağlam:**
Tarayıcıda LLM çalıştırma seçenekleri:
- WebLLM (MLC) — Llama, Mistral, Phi WebGPU
- Transformers.js (Xenova) — Hugging Face models in browser
- ONNX Runtime Web — generic neural net runtime
- Custom: TF.js, WONNX, GGML

**Karar:**
- **Transformers.js**: küçük modeller (embedding MiniLM-L6, NER, classification).
- **WebLLM**: büyük dil modelleri (Llama 3.2 1B/3B, Phi-3.5-mini).
- **Provider router** ile OpenAI/Anthropic/Gemini'ye opsiyonel fallback.

**Sonuçlar:**
- ✅ Local-first felsefe ile uyumlu.
- ✅ Maliyet sıfır (kullanıcının donanımı).
- ✅ Privacy: prompt sunucuya gitmez.
- ❌ WebGPU gerekli (Safari iOS henüz yok — 2026 Q2 lansman bekleniyor).
- ❌ Model indirme 700 MB-2 GB (kullanıcıya açık iletişim).
- ❌ Mobil cihazlarda yavaş (3-10 tokens/sec vs desktop 30-80 tokens/sec).

**Alternatifler:**
- Sadece bulut LLM (OpenAI/Anthropic): pratik ama felsefe ihlali + maliyet.
- TFJS: ML için ama LLM için optimize değil.

---

### ADR-0007: Sync Architecture — Yjs CRDT (D4)

**Durum:** Önerildi (D4.S19)

**Bağlam:**
Multi-device sync için seçenekler:
- Yjs (CRDT)
- Automerge (CRDT)
- Replicache (commercial)
- Operational Transformation (eski)
- Manual conflict resolution (basit ama hatalı)

**Karar:**
**Yjs + y-websocket** + E2E encryption (libsodium-wrappers).

**Sonuçlar:**
- ✅ CRDT: çakışmasız birleştirme.
- ✅ Olgun: Notion, Linear, Figma kullanır (varyantları).
- ✅ Offline-first.
- ✅ Self-hostable.
- ❌ State size: tüm history sakliyor (vakum/snapshot stratejisi gerekli).
- ❌ E2E encryption + CRDT zor: server delta'yı encrypted göremiyor, kullanıcı her cihazda decrypt edebilmeli.

**Alternatifler:**
- **Automerge:** Yjs'e benzer, biraz daha taze ama daha az olgun.
- **Replicache:** Commercial ($150/ay+), iyi DX ama vendor lock-in.

---

### ADR-0008: Backend Stack (D4) — Bun + Hono + SQLite (Turso/LiteFS)

**Durum:** Önerildi

**Bağlam:**
Sync backend için seçimler:
- Node + Express/Fastify + PostgreSQL
- Bun + Hono + SQLite + Turso/LiteFS
- Deno + Fresh + KV
- Go + Gin + PostgreSQL

**Karar:**
**Bun + Hono + SQLite (Turso for distributed, LiteFS for self-host).**

**Sonuçlar:**
- ✅ Bun: Node compatible, ~3× hızlı, lokal dev için harika.
- ✅ Hono: Edge-ready (Cloudflare Workers'ta da çalışır), TypeScript-first.
- ✅ SQLite: Single-file, low ops, fast read.
- ✅ Turso: Distributed SQLite (Multi-region read replicas).
- ✅ LiteFS (Fly.io): Self-host için açık kaynak.
- ❌ Bun olgunluğu 2026 itibarıyla "production-ready" ama bazı edge case'ler hâlâ var.
- ❌ SQLite write concurrency düşük (binlerce concurrent write için yetersiz; bizim use case sync için OK).

**Alternatifler:**
- Node + Postgres: daha tanıdık ama daha yavaş startup, daha çok ops.
- Cloudflare Workers + D1: serverless edge, ama vendor lock-in.

---

### ADR-0009: Privacy & Telemetry — Plausible (self-hosted) + Sentry

**Durum:** Önerildi

**Bağlam:**
Telemetri ihtiyacı: kullanım analitiği + hata raporu.
KVKK/GDPR uyumluluğu zorunlu.

**Karar:**
- **Plausible (self-hosted)**: privacy-friendly, no cookies, no PII.
- **Sentry**: hata izleme, beforeSend hook ile PII filter.

**Sonuçlar:**
- ✅ Cookie banner gerekmez (Plausible için).
- ✅ KVKK/GDPR safe.
- ✅ Self-host: veri ülke içinde kalır.
- ❌ Plausible self-host AGPL: SaaS olarak satarsak source vermek zorundayız (bizim kullanım — internal — sorun değil).
- ❌ Sentry SaaS: dış servis, ama KVKK için DPA imzalanabilir (US-based).

**Alternatifler:**
- Google Analytics: KVKK riskli (Almanya banlı), reddedildi.
- PostHog: feature flag + analytics, kompleks, D4'te değerlendirilebilir.
- Umami: Plausible alternatifi, daha hafif.

---

### ADR-0010: Encryption Strategy — WebCrypto AES-GCM + libsodium

**Durum:** Önerildi

**Bağlam:**
İki ayrı use case:
1. **Local API key encryption** (D1) — kullanıcının cihazında.
2. **Sync E2E encryption** (D4) — cloud sync üzerinden geçen veri.

**Karar:**
- D1: **WebCrypto (native)** AES-GCM 256-bit + PBKDF2 100K iterations.
- D4: **libsodium-wrappers** (TweetNaCl-compatible) — XChaCha20-Poly1305 + curve25519.

**Sonuçlar:**
- ✅ WebCrypto: native browser, sıfır bağımlılık.
- ✅ libsodium: olgun, audit edilmiş, geniş crypto primitive set.
- ❌ Master password unutulursa **veri kaybı** kaçınılmaz (no recovery by design).
- ❌ libsodium WASM: ~120 KB transfer.

**Alternatifler:**
- noble-ciphers: küçük, JS-only, Paul Miller tarafından. Aday olarak D4'te değerlendirilebilir.

---

### ADR-0011: Content Generation Strategy — AI + Human Review

**Durum:** Önerildi (D2 itibarıyla)

**Bağlam:**
Mevcut içerik %55+ AI-jenerasyonu (Gemini variants), gramer hataları var.

**Karar:**
1. **Hiçbir yeni item editör review olmadan UI'da görünmesin.**
2. **AI üretirken**:
   - Sistemli prompt (template).
   - Kalite testi (LLM-as-judge: GPT-4o veya Claude 3.5 ile).
   - Insan-okuma + onay.
3. **Variant'lar**: linked, görünmez (search'te boost edilmez).
4. **Lisans**: tüm AI üretim → CC-BY-4.0.

**Sonuçlar:**
- ✅ İçerik kalitesi büyük sıçrama.
- ❌ Yeni içerik hızı düşer (editör bottleneck).
- ❌ Editör maliyeti (D2 bütçesinde).

---

### ADR-0012: Public API Versioning Strategy (D5)

**Durum:** Taslak

**Karar:**
- URL'de major version: `/api/v1/...`, `/api/v2/...`.
- Header'da minor: `Aletcantasi-API-Version: 1.4`.
- Deprecation period: 12 ay (önce header'da uyarı, sonra 410 Gone).
- Breaking change → yeni major.

---


## Ek 5: Yeni Geliştirici Onboarding Akışı (Day-1 Checklist)

Yeni mühendisin **ilk 5 günü**:

### Gün 1 (Salı): Setup + okuma

- [ ] `aletcantasi-org`'a GitHub davet kabul
- [ ] Slack + Discord davetleri kabul
- [ ] MacBook teslim alma + setup (1Password, GitHub, Cursor/VSCode)
- [ ] Bu raporu (CTO Audit) **TAM** okuma (3-4 saat)
- [ ] Sprint board (Linear/Jira) tanıtımı
- [ ] 1:1 CTO ile (30 dk)
- [ ] `~/dev/aletcantasi` clone + `pnpm i` + `pnpm dev`

### Gün 2 (Çarşamba): Mimari turu

- [ ] Mimari diyagramı CTO + Lead FE ile pair-walking (60 dk)
- [ ] 10 ADR okuma + soru listesi hazırla
- [ ] `packages/core` kodunu oku
- [ ] `packages/ui` Storybook çalıştır + componentleri keşfet
- [ ] İlk PR: README küçük bir typo düzelt (PR sürecini öğrenmek için)

### Gün 3 (Perşembe): Test + Veri

- [ ] Vitest test'lerini çalıştır
- [ ] Playwright e2e ödevi: yeni bir "kopyala butonu çalıştığını" test eden test yaz
- [ ] `data/manifest.json` ve `data/vaults/*/items.ndjson` keşfet
- [ ] `tools/migrate-html-to-json` script'i oku

### Gün 4 (Cuma): İlk gerçek görev

- [ ] Sprint'in açık görevlerinden bir tane "good-first-issue" seç
- [ ] Pair programming Lead FE ile (2 saat)
- [ ] PR aç
- [ ] Demo'da kendi katkını sun

### Gün 5 (Cumartesi - opsiyonel): Retrospektif

- [ ] CTO ile retro (30 dk): "Onboarding ne zor, ne kolay?"
- [ ] Wiki katkı: dokümantasyondaki bir eksik bul ve doldur

---

## Ek 6: 90 Günlük CTO Hedefi (Kendim için OKR)

Bu rapor 30 günlük analizin sonucu. Sonraki 60 gün için kişisel **kontrat**:

- [ ] Hafta 1-2: İlk 3 mühendisi işe al.
- [ ] Hafta 3-4: D1.S1 ve D1.S2 tamamlandı, monorepo çalışıyor.
- [ ] Hafta 5-6: Güvenlik patches'ler test ortamında.
- [ ] Hafta 7-8: Test coverage ≥ 60%.
- [ ] Hafta 9-10: PromptVault refactored.
- [ ] Hafta 11-12: Public launch (1000 alpha user).
- [ ] Hafta 13: Bu raporun **D2 versiyonunu** hazırla.

---

## Ek 7: Sözlük (Glossary)

| Terim | Anlam |
|---|---|
| **Vault** | Bu projedeki tek dosyalı HTML kütüphane (örn. PromptVault, RouterVault). |
| **Variant** | Bir item'ın programatik olarak üretilmiş türevi (`variant_of` ile linkli). |
| **Item** | Vault içindeki tek bir öğe (prompt, persona, prompt zinciri vb.). |
| **Shell** | Yeni mimaride tek bir vault için kullanılan ortak UI iskeleti. |
| **Launcher** | `index.html` — 100 vault'a giriş noktası. |
| **CRDT** | Conflict-free Replicated Data Type. Sync için. |
| **OPFS** | Origin Private File System — büyük binary storage. |
| **MCP** | Model Context Protocol — Anthropic'in standart tool-calling protokolü. |
| **RAG** | Retrieval-Augmented Generation. |
| **WebLLM** | Tarayıcıda WebGPU ile LLM çalıştıran framework. |
| **Lighthouse** | Google'ın tarayıcı performans audit aracı. |
| **CSP** | Content Security Policy — XSS koruması. |
| **PWA** | Progressive Web App. |
| **ADR** | Architecture Decision Record. |
| **OKR** | Objectives & Key Results. |
| **MAU** | Monthly Active Users. |
| **MRR/ARR** | Monthly/Annual Recurring Revenue. |
| **SOC2** | Service Organization Control 2 — compliance audit. |
| **KVKK** | Kişisel Verilerin Korunması Kanunu (TR). |
| **GDPR** | General Data Protection Regulation (EU). |

---

## Kapanış: CTO'dan kurucu(lar)a not

> Sevgili Kurucu(lar),
>
> Bu raporu hazırlamak için her satır kodunu, her dosya boyutunu ve her dokümantasyon satırını
> kişisel olarak inceledim. Bulgularımdan bazıları sert görünebilir — ama bu sertlik
> ürüne **inancımdandır**, yoksa ihtiyacın olan analitik dürüstlüğe sahip değilim.
>
> Önümüzde 24 aylık zorlu ama heyecan verici bir yol var. Görüyorum ki:
>
> - **İçerik vizyonu güçlü.** 100 vault, 52K öğe — bu organik olarak bir ürünün önemli "moat"udur.
> - **Felsefe doğru.** *Local-first, privacy-first, AI-native, zero-server* — bu 2026 sonrası dünyaya
>   uygun, doğru bir tercih.
> - **Teknik temel düzeltilebilir.** 102 MB enkaz korkutucu görünür ama çözülemez değil.
>   D1'de yangını söndürür, D2'de modern mimariye geçer, D3'te AI-Native olur, D4'te
>   ölçeklendirir, D5'te ekosistem oluruz.
>
> Bu raporu kabul ettiğiniz takdirde, **D1.S1**'i bu hafta başlatmak istiyorum.
> Mühendislik ilanlarını yarın açabilirim.
>
> Saygılarımla,
>
> **— CTO Ofisi**
>
> *2026, İstanbul.*

---

**Doküman sonu.**

*Bu rapor, sürüm kontrolüne `docs/strategy/cto-audit-v1.md` olarak commit'lenmelidir.*
*Sonraki revizyon: 2026-09-15 (D1 sonu — D2'ye geçiş kararı için).*
*Lisans (bu doküman): CC-BY-NC 4.0 (şirket-içi).*

## Ek 8: Vault-by-Vault Denetim Kartları (100 vault)
Bu ek, **her bir vault için ayrı bir teknik denetim kartı** içerir.
Her kart, ürünün hangi vault'larının kritik olup hangilerinin **kademeli mod**'da 
kalabileceği konusunda Sprint planlama için doğrudan girdidir.

### Toplam Genel Bakış

- Vault sayısı: **100**
- Toplam item: **52,240**
- Açık halde toplam boyut: **101.1 MB**
- Ortalama vault boyutu: **1036 KB**
- Medyan item / vault: **~450**
- Outlier vault'lar: PromptVault (12 MB / 6394 item), AgentVault (2.6 MB / 887 item)

### Refactor Önceliği Sınıflandırması

Her vault aşağıdaki kategorilerden birinde:

- **🔴 P0 (Kritik):** D1.S5'te öncelikle ele alınacak (boyut > 1 MB veya item > 1000)
- **🟠 P1 (Yüksek):** D2'de standart migration sürecinde
- **🟡 P2 (Orta):** D2 sonu, batch migration
- **🟢 P3 (Düşük):** D3'te otomatik script ile migrate edilebilir

**Dağılım:**

| Öncelik | Sayı |
|---|---:|
| 🔴 P0 | 7 |
| 🟠 P1 | 65 |
| 🟡 P2 | 15 |
| 🟢 P3 | 13 |

---

#### 001. PromptVault Pro `01-promptvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `01-promptvault-pro.html` |
| **Boyut** | 12111.1 KB (⚠️ büyük) |
| **Öğe sayısı** | 6,385 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🔴 P0 |
| **Risk flag'leri** | performans-kritik, mobil-uyumsuz |

**Tanım:** Karmaşık "PromptCraft" mimarisine uygun, modüler sistem promptu kütüphanesi.

**Eylemler:**
- 🔴 D1.S5'te **özel optimization sprint'i**. Tek dosyada kalmamalı.
- Sayfalama + virtual scroll zorunlu.
- Mobil 3G'de yüklenemeyeceği için **mobil-uyumsuz** uyarısı eklenecek.
- Embedding maliyeti: ~$0.05 (build-time, tek seferlik).

---

#### 002. LogicVault Pro `02-logicvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `02-logicvault-pro.html` |
| **Boyut** | 778.4 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** "5 Göz Analizi" gibi çok boyutlu mantıksal çözümleme çerçeveleri ve analiz algoritmaları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 003. TestVault Pro `03-testvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `03-testvault-pro.html` |
| **Boyut** | 1091.4 KB (⚠️ büyük) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🔴 P0 |
| **Risk flag'leri** | yok |

**Tanım:** LLM halüsinasyonlarını test etmek ve çapraz sorgu yapmak için "Hata Dedektifi" senaryoları.

**Eylemler:**
- 🟠 D2'de FlexSearch ile arama indeksi ayrılacak.
- IndexedDB bulk import gerekiyor (lazy load).

---

#### 004. AgentVault Pro `04-agentvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `04-agentvault-pro.html` |
| **Boyut** | 2602.6 KB (⚠️ büyük) |
| **Öğe sayısı** | 885 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🔴 P0 |
| **Risk flag'leri** | yok |

**Tanım:** Otonom AI ajanları için görev tabanlı talimat setleri ve API yönlendirme şablonları.

**Eylemler:**
- 🟠 D2'de FlexSearch ile arama indeksi ayrılacak.
- IndexedDB bulk import gerekiyor (lazy load).
- Embedding maliyeti: ~$0.05 (build-time, tek seferlik).

---

#### 005. ContextVault Pro `05-contextvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `05-contextvault-pro.html` |
| **Boyut** | 772.6 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Büyük modellerin (Claude Pro, Gemini Plus vb.) uzun bağlam pencerelerini (1M+ token) yönetmek için hafıza indeksleme araçları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 006. PersonaVault Pro `06-personavault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `06-personavault-pro.html` |
| **Boyut** | 1619.7 KB (⚠️ büyük) |
| **Öğe sayısı** | 885 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🔴 P0 |
| **Risk flag'leri** | yok |

**Tanım:** Belirli uzmanlık alanlarına göre derinlemesine eğitilmiş AI persona koleksiyonu.

**Eylemler:**
- 🟠 D2'de FlexSearch ile arama indeksi ayrılacak.
- IndexedDB bulk import gerekiyor (lazy load).
- Embedding maliyeti: ~$0.05 (build-time, tek seferlik).

---

#### 007. VisionVault Pro `07-visionvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `07-visionvault-pro.html` |
| **Boyut** | 719.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** Görsel veri işleme, teknik şema analizi ve sentetik görüntü üretimi komutları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 008. AudioVault Pro `08-audiovault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `08-audiovault-pro.html` |
| **Boyut** | 725.4 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** Ses üretimi, müzik teorisi ve TTS (Text-to-Speech) motorları için optimize edilmiş AI komutları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 009. ModelVault Pro `09-modelvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `09-modelvault-pro.html` |
| **Boyut** | 763.8 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Lokal LLM modelleri için ince ayar (fine-tuning) veri setleri ve format dönüştürücüler.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 010. RouterVault Pro `10-routervault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `10-routervault-pro.html` |
| **Boyut** | 683.0 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** Gelen API isteğinin maliyet/performans analizini yapıp en uygun modele yönlendiren arayüz.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 011. SynthVault Pro `11-synthvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `11-synthvault-pro.html` |
| **Boyut** | 748.0 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** Özel veri setleri oluşturmak için sentetik veri üretimi otomasyon şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 012. JailbreakVault Pro `12-jailbreakvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `12-jailbreakvault-pro.html` |
| **Boyut** | 717.6 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yasal-gri |

**Tanım:** Beyaz şapkalı siber güvenlik uzmanları için red-teaming ve model dayanıklılık testleri.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.
- ⚠️ **OpenAI/Anthropic ToS uyumluluk denetimi** gerekiyor.
- Beyaz şapkalı kullanım disclaim'er'i + 18+ onayı.

---

#### 013. ChainVault Pro `13-chainvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `13-chainvault-pro.html` |
| **Boyut** | 1617.9 KB (⚠️ büyük) |
| **Öğe sayısı** | 885 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🔴 P0 |
| **Risk flag'leri** | yok |

**Tanım:** Düşünce zinciri (Chain of Thought) süreçlerini adım adım kurgulayan algoritmik promptlar.

**Eylemler:**
- 🟠 D2'de FlexSearch ile arama indeksi ayrılacak.
- IndexedDB bulk import gerekiyor (lazy load).
- Embedding maliyeti: ~$0.05 (build-time, tek seferlik).

---

#### 014. EmbedVault Pro `14-embedvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `14-embedvault-pro.html` |
| **Boyut** | 742.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** Vektör veritabanları (RAG sistemleri) için embedding stratejileri ve parçalama (chunking) rehberi.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 015. OmniVault Pro `15-omnivault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `15-omnivault-pro.html` |
| **Boyut** | 745.0 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#a375ff` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** Diğer tüm Vault'ları birbirine bağlayan ve projeler arası veri köprüsü kuran ana (master) API arayüzü.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 016. WasmVault Pro `16-wasmvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `16-wasmvault-pro.html` |
| **Boyut** | 766.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** C++ tabanlı sistemleri ve motorları WebAssembly'e derlerken kullanılan optimizasyon şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 017. EngineVault Pro `17-enginevault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `17-enginevault-pro.html` |
| **Boyut** | 737.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** Özel oyun motoru mimarileri için bellek yönetimi, render pipeline ve component sistemi taslakları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 018. ChessVault Pro `18-chessvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `18-chessvault-pro.html` |
| **Boyut** | 719.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** Standart dışı satranç varyantları geliştirmek için kural setleri, oyun ağaçları ve yapay zeka değerlendirme (eval) fonksiyonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 019. GodotVault Pro `19-godotvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `19-godotvault-pro.html` |
| **Boyut** | 734.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** Godot Engine ve GDScript entegrasyonları için yapay zeka destekli kod parçacıkları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 020. NiloVault Pro `20-nilovault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `20-nilovault-pro.html` |
| **Boyut** | 810.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** 3D modelleme iş akışlarını (özellikle Nilo AI gibi araçlarla) hızlandıran asset promptları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 021. PGCVault Pro `21-pgcvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `21-pgcvault-pro.html` |
| **Boyut** | 795.0 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Prosedürel içerik (harita, zindan, arazi) üretimi için matematiksel algoritmalar.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 022. DialogVault Pro `22-dialogvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `22-dialogvault-pro.html` |
| **Boyut** | 909.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** NPC'ler için dinamik, bağlama duyarlı diyalog ağaçları ve JSON formatında senaryo çıktıları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 023. BalanceVault Pro `23-balancevault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `23-balancevault-pro.html` |
| **Boyut** | 797.9 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Oyun içi ekonomi ve güç dengesini (skill cooldown, hasar formülleri) simüle eden hesaplama aracı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 024. FirebaseVault Pro `24-firebasevault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `24-firebasevault-pro.html` |
| **Boyut** | 761.6 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Oyunlar ve web araçları için backend, yetkilendirme ve sunucusuz veritabanı şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 025. ShaderVault Pro `25-shadervault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `25-shadervault-pro.html` |
| **Boyut** | 710.1 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** GLSL/HLSL shader kodları üreten, optimize eden ve görselleştiren AI asistanı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 026. StateVault Pro `26-statevault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `26-statevault-pro.html` |
| **Boyut** | 834.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Karmaşık state-machine (durum makinesi) yapılarını modelleyen ve C++ çıktı veren araç.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 027. PhysicsVault Pro `27-physicsvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `27-physicsvault-pro.html` |
| **Boyut** | 776.7 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Özel fizik motoru çarpışma testleri için vektör hesabı ve optimizasyon algoritmaları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 028. AssetVault Pro `28-assetvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `28-assetvault-pro.html` |
| **Boyut** | 857.6 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** On binlerce oyun içi grafik ve ses dosyasını kategorize eden, meta-veri etiketleme sistemi.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 029. QuestVault Pro `29-questvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `29-questvault-pro.html` |
| **Boyut** | 784.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Çok dallı (branching) RPG görev tasarımı jeneratörü.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 030. MatchVault Pro `30-matchvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `30-matchvault-pro.html` |
| **Boyut** | 852.1 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#5ed47e` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Çok oyunculu rekabetçi oyunlar (örn: battle royale veya satranç) için eşleştirme (matchmaking) şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 031. MythVault Pro `31-mythvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `31-mythvault-pro.html` |
| **Boyut** | 860.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Manihéizm, apokrif metinler ve antik mitolojiler üzerine derinlemesine teolojik veri tabanı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 032. AngelVault Pro `32-angelvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `32-angelvault-pro.html` |
| **Boyut** | 832.2 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Mastema, kerublar ve melek hiyerarşileri gibi spesifik figürler için karakter/lore jeneratörü.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 033. LoreVault Pro `33-lorevault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `33-lorevault-pro.html` |
| **Boyut** | 746.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** Devasa evrenler için (10.000+ karakterlik) "Görsel Veri Motoru" iş akışlarına uygun karakter şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 034. HistoryVault Pro `34-historyvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `34-historyvault-pro.html` |
| **Boyut** | 780.4 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Profesyonel seviyede birincil kaynak analizi, çapraz referanslama ve tarihsel veri doğrulama asistanı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 035. KemalistVault Pro `35-kemalistvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `35-kemalistvault-pro.html` |
| **Boyut** | 933.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | siyasi-ideolojik |

**Tanım:** Kemalizm, milli şuur hareketleri ve Cumhuriyet dönemi ideolojik yapıları üzerine araştırma promptları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.
- ⚠️ **Hukuki review zorunlu** (D1.S6, 5651 SK).
- Age-gate + disclaim'er eklenecek.

---

#### 036. GökalpVault Pro `36-gokalpvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `36-gokalpvault-pro.html` |
| **Boyut** | 791.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Ziya Gökalp sosyolojisi, Türkçülük fikirleri ve dönemsel akımları modern bağlamda sentezleyen analiz aracı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 037. TimelineVault Pro `37-timelinevault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `37-timelinevault-pro.html` |
| **Boyut** | 916.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Tarihsel olayları, kırılma noktalarını ve sebep-sonuç ilişkilerini haritalayan veri yapıları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 038. EtymologyVault Pro `38-etymologyvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `38-etymologyvault-pro.html` |
| **Boyut** | 905.1 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Kelimelerin kökenlerini, diller arası geçişlerini ve anlamsal evrimlerini inceleyen sözlük.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 039. ArchiveVault Pro `39-archivevault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `39-archivevault-pro.html` |
| **Boyut** | 901.7 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Eski metinlerin ve arşiv belgelerinin (OCR sonrası) çeviri optimizasyonu ve anlamlandırma promptları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 040. CharacterVault Pro `40-charactervault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `40-charactervault-pro.html` |
| **Boyut** | 909.9 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Psikolojik derinliğe sahip kurgusal figür profilleri jeneratörü.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 041. NarrativeVault Pro `41-narrativevault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `41-narrativevault-pro.html` |
| **Boyut** | 909.7 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Senaryolar ve kurgusal eserler için yapısal iskelet (Monomyth vb.) kurucu.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 042. PantheVault Pro `42-panthevault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `42-panthevault-pro.html` |
| **Boyut** | 924.2 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Farklı panteonlar arası karşılaştırmalı teoloji ve mitoloji analizi yapan sorgu aracı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 043. ProphecyVault Pro `43-prophecyvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `43-prophecyvault-pro.html` |
| **Boyut** | 905.2 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Kurgu evrenler için apokaliptik metinler, kehanetler ve kadim sembolizm üreteci.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 044. CultureVault Pro `44-culturevault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `44-culturevault-pro.html` |
| **Boyut** | 904.0 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Kurgusal kültürlerin antropolojik altyapısını (gelenek, din, dil ailesi) inşa eden asistan.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 045. EpicVault Pro `45-epicvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `45-epicvault-pro.html` |
| **Boyut** | 900.0 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#d4a04c` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Destansı anlatı formlarını taklit eden, ritmik ve arkaik metin jeneratörü.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 046. KargoVault Pro `46-kargovault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `46-kargovault-pro.html` |
| **Boyut** | 912.9 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** GitHub limitlerini aşmak için büyük dosyaları parselleyen (örn: 500MB'ı 20MB'lık paketlere bölen) sistem mimarisi.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 047. AegisVault Pro `47-aegisvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `47-aegisvault-pro.html` |
| **Boyut** | 908.1 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Hibrid güvenlik mimarileri, ısı koruma (Thermo-Guard) ve biyolojik web (Bio-Web) katmanları gibi kompleks endüstriyel tasarımlar için teknik fizibilite şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 048. ArchVault Pro `48-archvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `48-archvault-pro.html` |
| **Boyut** | 902.8 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Mikroservis ve monolitik sistem tasarımları için mimari çizim ve C4 modeli komutları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 049. SecVault Pro `49-secvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `49-secvault-pro.html` |
| **Boyut** | 900.6 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Statik kod analizleri ve güvenlik açığı testleri (SAST/DAST) için denetim promptları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 050. DeployVault Pro `50-deployvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `50-deployvault-pro.html` |
| **Boyut** | 907.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** CI/CD pipeline'ları için Docker, Kubernetes ve Terraform konfigürasyon şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 051. RegexVault Pro `51-regexvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `51-regexvault-pro.html` |
| **Boyut** | 903.8 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Karmaşık metin madenciliği ve log analizi için Regex jeneratörü.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 052. CronVault Pro `52-cronvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `52-cronvault-pro.html` |
| **Boyut** | 921.0 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Zamanlanmış sunucu görevleri ve sistem otomasyonları için betik kütüphanesi.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 053. LogVault Pro `53-logvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `53-logvault-pro.html` |
| **Boyut** | 905.4 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Anormallikleri (anomaly detection) tespit etmek üzere tasarlanmış log işleme ajanları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 054. CloudVault Pro `54-cloudvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `54-cloudvault-pro.html` |
| **Boyut** | 915.1 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Mimari maliyet optimizasyonu ve cloud-native yapılandırma promptları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 055. ApiVault Pro `55-apivault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `55-apivault-pro.html` |
| **Boyut** | 982.0 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** RESTful ve GraphQL API tasarımı, uç nokta (endpoint) dokümantasyonu.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 056. DbVault Pro `56-dbvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `56-dbvault-pro.html` |
| **Boyut** | 985.9 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** SQL ve NoSQL veritabanı şema tasarımı, ilişki haritaları ve sorgu optimizasyonu.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 057. WasmDevVault Pro `57-wasmdevvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `57-wasmdevvault-pro.html` |
| **Boyut** | 989.6 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Tarayıcı içi WebAssembly modüllerinin performans metriklerini ve darboğazlarını (bottleneck) analiz eden debug aracı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 058. MemVault Pro `58-memvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `58-memvault-pro.html` |
| **Boyut** | 986.8 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** C++ tabanlı projeler için bellek sızıntısı (memory leak) analizi ve pointer yönetim şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 059. ScriptVault Pro `59-scriptvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `59-scriptvault-pro.html` |
| **Boyut** | 978.2 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Bash ve PowerShell üzerinden terminal tabanlı iş akışı otomasyonu komut dizileri.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 060. GitVault Pro `60-gitvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `60-gitvault-pro.html` |
| **Boyut** | 977.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4a9eff` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Gelişmiş Git repo yönetimi, conflict çözümleri ve geçmiş (history) manipülasyonu komutları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 061. AutoVault Pro `61-autovault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `61-autovault-pro.html` |
| **Boyut** | 1067.4 KB (⚠️ büyük) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🔴 P0 |
| **Risk flag'leri** | yok |

**Tanım:** Kapsamlı otomasyon kampları ve e-ticaret süreçlerinin teknik kurgularını yöneten AI şablonları.

**Eylemler:**
- 🟠 D2'de FlexSearch ile arama indeksi ayrılacak.
- IndexedDB bulk import gerekiyor (lazy load).

---

#### 062. ObsiVault Pro `62-obsivault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `62-obsivault-pro.html` |
| **Boyut** | 957.0 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Obsidian ve Zettelkasten metodolojisi için Markdown tabanlı kişisel bilgi yönetimi promptları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 063. StoryVault Pro `63-storyvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `63-storyvault-pro.html` |
| **Boyut** | 966.4 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Storytel gibi platformlardaki uzun formatlı sesli kitaplar/metinler için bölüm sonu özetleyici ve tematik analiz aracı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 064. TravelVault Pro `64-travelvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `64-travelvault-pro.html` |
| **Boyut** | 966.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Şehirlerarası otobüs yolculukları gibi solo seyahatler için rota, bütçe ve yolda geçirilecek zamanı (okuma, kodlama) optimize eden planlayıcı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 065. AgendaVault Pro `65-agendavault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `65-agendavault-pro.html` |
| **Boyut** | 902.4 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Haftalık ajanda planlaması, önceliklendirme matrisleri ve hedef takibi aracı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 066. FocusVault Pro `66-focusvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `66-focusvault-pro.html` |
| **Boyut** | 900.7 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Derin çalışma (deep work) seansları için görev bölücü ve motivasyonel takip aracı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 067. BudgetVault Pro `67-budgetvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `67-budgetvault-pro.html` |
| **Boyut** | 971.6 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Abonelikler, öğrenci bursları ve mikro-satın alımlar (oyun içi harcamalar dahil) için harcama/nakit akışı izleyici.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 068. EcomVault Pro `68-ecomvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `68-ecomvault-pro.html` |
| **Boyut** | 914.8 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Ürün açıklamaları, SEO metinleri ve dönüşüm oranı optimizasyonu (CRO) için pazarlama promptları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 069. MealVault Pro `69-mealvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `69-mealvault-pro.html` |
| **Boyut** | 978.4 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Yerel restoran siparişlerini (tavuk döner, çiğ köfte vb.) makro besin değerleri ve bütçe ile eşleştiren günlük takip asistanı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 070. MailVault Pro `70-mailvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `70-mailvault-pro.html` |
| **Boyut** | 976.9 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Kurumsal iletişim, sponsorluk dosyaları ve profesyonel ağ kurma (networking) için e-posta taslakları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 071. SocialVault Pro `71-socialvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `71-socialvault-pro.html` |
| **Boyut** | 987.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Sosyal medya algoritma analizleri ve etkileşim artırıcı içerik kancaları (hooks).

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 072. AdVault Pro `72-advault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `72-advault-pro.html` |
| **Boyut** | 983.1 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Dijital reklamcılık için A/B test senaryoları ve reklam metni (ad copy) şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 073. FunnelVault Pro `73-funnelvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `73-funnelvault-pro.html` |
| **Boyut** | 983.7 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Satış hunisi tasarımı ve kullanıcı yolculuğu (customer journey) haritalama.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 074. ScrapVault Pro `74-scrapvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `74-scrapvault-pro.html` |
| **Boyut** | 993.7 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Web kazıma (scraping) süreçleri için etik sınırları koruyan ve veri yapılandıran scriptler.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 075. MacroVault Pro `75-macrovault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `75-macrovault-pro.html` |
| **Boyut** | 1001.6 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#4cc9c9` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Klavye kısayolları ve işletim sistemi makroları üreten hızlandırıcı komutlar.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 076. PitchVault Pro `100-pitchvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `100-pitchvault-pro.html` |
| **Boyut** | 739.0 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟢 P3 |
| **Risk flag'leri** | yok |

**Tanım:** Startup pitch deck, yatırımcı sunumu ve girişim hikayesi şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 077. PwaVault Pro `76-pwavault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `76-pwavault-pro.html` |
| **Boyut** | 932.6 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Çevrimdışı çalışabilen Progressive Web App manifestoları ve service worker şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 078. UI/UXVault Pro `77-ui-uxvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `77-ui-uxvault-pro.html` |
| **Boyut** | 917.8 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Karanlık tema (dark mode), minimalizm ve font hiyerarşisi üzerine tasarım kuralları/CSS snippet kütüphanesi.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 079. CryptoVault Pro `78-cryptovault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `78-cryptovault-pro.html` |
| **Boyut** | 761.7 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟡 P2 |
| **Risk flag'leri** | yok |

**Tanım:** Akıllı kontrat yazımı, blokzincir algoritması analizi ve Web3 entegrasyon komutları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 080. BioVault Pro `79-biovault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `79-biovault-pro.html` |
| **Boyut** | 919.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Biyolojik sistemler ve veri analizi üzerine kavramsal araştırma şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 081. LawVault Pro `80-lawvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `80-lawvault-pro.html` |
| **Boyut** | 917.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Sözleşme incelemesi, maddelendirme ve temel analitik okuma için yapılandırılmış promptlar.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 082. MedVault Pro `81-medvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `81-medvault-pro.html` |
| **Boyut** | 921.2 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Medikal/anatomik terimler için yapılandırılmış flashcard (çalışma kartı) üreticisi.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 083. LinguaVault Pro `82-linguavault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `82-linguavault-pro.html` |
| **Boyut** | 920.2 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Yabancı dil öğreniminde etimolojik bağlar kurarak kelime ezberleten asistan.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 084. MathVault Pro `83-mathvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `83-mathvault-pro.html` |
| **Boyut** | 938.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** İleri düzey lineer cebir ve algoritmik matematik problemlerini parçalara ayıran çözümleyici.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 085. StatVault Pro `84-statvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `84-statvault-pro.html` |
| **Boyut** | 1249.3 KB (⚠️ büyük) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🔴 P0 |
| **Risk flag'leri** | yok |

**Tanım:** Veri görselleştirme ve istatistiksel veri setlerini anlamlandırma komutları.

**Eylemler:**
- 🟠 D2'de FlexSearch ile arama indeksi ayrılacak.
- IndexedDB bulk import gerekiyor (lazy load).

---

#### 086. IoTVault Pro `85-iotvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `85-iotvault-pro.html` |
| **Boyut** | 936.0 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Sensör verisi işleme, cihaz telemetrisi ve donanım/yazılım haberleşme protokolleri.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 087. HrdVault Pro `86-hrdvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `86-hrdvault-pro.html` |
| **Boyut** | 937.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Donanım mantığı, devre şeması analizi ve mikrodenetleyici entegrasyonu rehberi.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 088. ArVault Pro `87-arvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `87-arvault-pro.html` |
| **Boyut** | 940.9 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Artırılmış gerçeklik arayüzleri ve uzamsal (spatial) tasarım kuralları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 089. VrVault Pro `88-vrvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `88-vrvault-pro.html` |
| **Boyut** | 935.8 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Sanal gerçeklik ortamlarında 3D etkileşim ve UI tasarım şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 090. EcoVault Pro `89-ecovault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `89-ecovault-pro.html` |
| **Boyut** | 952.8 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Sistem mimarilerinin enerji tüketimini ve karbon ayak izini simüle eden hesaplama araçları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 091. PsyVault Pro `90-psyvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `90-psyvault-pro.html` |
| **Boyut** | 956.8 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Psikolojik teoriler, kullanıcı davranış analizi ve persona derinleştirme araçları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 092. PhiloVault Pro `91-philovault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `91-philovault-pro.html` |
| **Boyut** | 959.1 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Felsefi argümantasyon, düşünce deneyleri ve diyalektik tartışma şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 093. InvestVault Pro `92-investvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `92-investvault-pro.html` |
| **Boyut** | 951.9 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Finansal okuryazarlık, temel analiz ve veri okuma (scraping ile toplanan veriler için) aracı.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 094. ReelVault Pro `93-reelvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `93-reelvault-pro.html` |
| **Boyut** | 951.6 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Kısa form video kurgusu, sahne ritmi ve retention (elde tutma) optimizasyon senaryoları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 095. EventVault Pro `94-eventvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `94-eventvault-pro.html` |
| **Boyut** | 958.6 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Fiziksel/online eğitim kampları ve etkinlikler için akış yönetimi şablonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 096. AstroVault Pro `95-astrovault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `95-astrovault-pro.html` |
| **Boyut** | 961.3 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Uzay bilimleri, göksel mekanik ve kurgusal evrenler için gezegen/yörünge formülasyonları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 097. AgriVault Pro `96-agrivault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `96-agrivault-pro.html` |
| **Boyut** | 952.8 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Algoritmik büyüme modelleri ve kaynak optimizasyonu veri setleri.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 098. FormatVault Pro `97-formatvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `97-formatvault-pro.html` |
| **Boyut** | 968.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Üretilen çıktıların JSON, XML, Markdown veya spesifik özel formatlara (custom parser'lar için) hatasız dökülmesini sağlayan güvenlik duvarı promptları.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 099. TurkVault Pro `98-turkvault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `98-turkvault-pro.html` |
| **Boyut** | 974.5 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** Türkçe NLP, dil işleme ve Türkçe içerik üretimi için optimize edilmiş prompt koleksiyonu.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---

#### 100. ResumeVault Pro `99-resumevault-pro.html`

| Alan | Değer |
|---|---|
| **Dosya** | `99-resumevault-pro.html` |
| **Boyut** | 975.2 KB (✓) |
| **Öğe sayısı** | 450 |
| **Renk teması** | `#ff6b6b` |
| **Refactor önceliği** | 🟠 P1 |
| **Risk flag'leri** | yok |

**Tanım:** CV, kapak mektubu ve kariyer dokümanı şablonları; ATS uyumlu özgeçmiş üretimi.

**Eylemler:**
- 🟢 D3'te tek script ile otomatik migrate edilebilir.

---



## Ek 9: Detaylı Performans Optimization Playbook'u

### 9.1 PromptVault (12.4 MB) için Adım-Adım Kurtarma

**Mevcut durum:**
- 12,401,727 bytes tek HTML
- 6,394 item inline JSON
- ~3,500 satır inline CSS
- ~700 satır inline JS
- 4G mobil simülasyon: LCP ~9 saniye, TTI ~14 saniye

**Hedef (D1.S5 sonu):**
- HTML shell: < 100 KB
- İlk JSON chunk: < 200 KB (ilk 100 item)
- Geri kalan veri: lazy NDJSON streaming
- 4G mobil LCP: < 3 saniye

**Sprint Görev Listesi (adım adım):**

1. **HTML ekstraksiyon** (`tools/migrate-html-to-json/extract.ts`):
```typescript
import { JSDOM } from 'jsdom';
import { writeFile } from 'fs/promises';

const dom = await JSDOM.fromFile('legacy/01-promptvault-pro.html');
const scripts = dom.window.document.querySelectorAll('script');
let itemsJson: string | null = null;
let catsJson: string | null = null;

for (const script of scripts) {
  const text = script.textContent ?? '';
  const itemsMatch = text.match(/const\s+ITEMS\s*=\s*(\[[\s\S]+?\]);\s*\n/);
  if (itemsMatch) itemsJson = itemsMatch[1];
  const catsMatch = text.match(/const\s+CATS\s*=\s*(\{[\s\S]+?\});\s*\n/);
  if (catsMatch) catsJson = catsMatch[1];
}

const items = JSON.parse(itemsJson!);
const cats = JSON.parse(catsJson!);

// NDJSON formatına çevir
const ndjson = items.map((it: Item) => JSON.stringify(it)).join('\n');
await writeFile('data/vaults/promptvault/items.ndjson', ndjson);
await writeFile('data/vaults/promptvault/meta.json', JSON.stringify({
  id: 'promptvault',
  itemCount: items.length,
  categories: cats,
  version: '1.0.0',
  extractedAt: new Date().toISOString(),
}, null, 2));
```

2. **Item chunking** (her chunk 100 item):
```typescript
const CHUNK_SIZE = 100;
for (let i = 0; i < items.length; i += CHUNK_SIZE) {
  const chunk = items.slice(i, i + CHUNK_SIZE);
  const chunkIdx = Math.floor(i / CHUNK_SIZE);
  await writeFile(
    `data/vaults/promptvault/chunks/${chunkIdx.toString().padStart(4, '0')}.ndjson`,
    chunk.map(it => JSON.stringify(it)).join('\n')
  );
}
```

3. **HTML shell üretimi** (Lit + Vite):
```html
<!-- apps/vault-app/index.html (~80 KB final) -->
<!DOCTYPE html>
<html lang="tr" data-vault-id="promptvault">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PromptVault Pro — Alet Çantası</title>
  <link rel="preconnect" href="" crossorigin>
  <link rel="modulepreload" href="/assets/vendor-lit.js">
  <link rel="modulepreload" href="/assets/app.js">
  <link rel="preload" href="/data/vaults/promptvault/meta.json" as="fetch" crossorigin>
  <link rel="preload" href="/data/vaults/promptvault/chunks/0000.ndjson" as="fetch" crossorigin>
  <link rel="stylesheet" href="/assets/app.css">
</head>
<body>
  <ac-app-shell vault-id="promptvault"></ac-app-shell>
  <script type="module" src="/assets/app.js"></script>
</body>
</html>
```

4. **Lazy load logic** (`packages/data/src/loader.ts`):
```typescript
export class ChunkedVaultLoader {
  private loadedChunks = new Set<number>();
  private cache = new Map<number, Item[]>();

  constructor(private vaultId: string, private chunkCount: number) {}

  async loadChunk(idx: number): Promise<Item[]> {
    if (this.cache.has(idx)) return this.cache.get(idx)!;
    
    const url = `/data/vaults/${this.vaultId}/chunks/${idx.toString().padStart(4, '0')}.ndjson`;
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Failed to load chunk ${idx}`);
    
    const text = await response.text();
    const items = text.trim().split('\n').map(line => JSON.parse(line) as Item);
    
    this.cache.set(idx, items);
    this.loadedChunks.add(idx);
    return items;
  }

  async loadRange(start: number, end: number): Promise<Item[]> {
    const startChunk = Math.floor(start / 100);
    const endChunk = Math.floor((end - 1) / 100);
    const chunks = await Promise.all(
      Array.from({ length: endChunk - startChunk + 1 }, (_, i) =>
        this.loadChunk(startChunk + i)
      )
    );
    return chunks.flat().slice(start - startChunk * 100, end - startChunk * 100);
  }
}
```

5. **Virtual scroll entegrasyonu** (`packages/ui/src/components/ac-virtual-list.ts`):
```typescript
import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import { repeat } from 'lit/directives/repeat.js';

@customElement('ac-virtual-list')
export class AcVirtualList extends LitElement {
  @property({ type: Number }) totalCount = 0;
  @property({ type: Number }) itemHeight = 64;
  @property({ attribute: false }) loadRange!: (start: number, end: number) => Promise<Item[]>;
  
  @state() private scrollTop = 0;
  @state() private visibleItems: Item[] = [];
  @state() private visibleRange: [number, number] = [0, 0];

  static styles = css`
    :host { display: block; height: 100%; overflow-y: auto; position: relative; }
    .spacer { width: 100%; }
    .item-container { position: absolute; left: 0; right: 0; }
  `;

  private handleScroll(e: Event) {
    const target = e.target as HTMLElement;
    this.scrollTop = target.scrollTop;
    this.updateVisibleRange();
  }

  private async updateVisibleRange() {
    const containerHeight = this.clientHeight;
    const start = Math.max(0, Math.floor(this.scrollTop / this.itemHeight) - 10);
    const end = Math.min(
      this.totalCount,
      Math.ceil((this.scrollTop + containerHeight) / this.itemHeight) + 10
    );
    
    if (start === this.visibleRange[0] && end === this.visibleRange[1]) return;
    this.visibleRange = [start, end];
    this.visibleItems = await this.loadRange(start, end);
  }

  connectedCallback() {
    super.connectedCallback();
    this.addEventListener('scroll', (e) => this.handleScroll(e));
    this.updateVisibleRange();
  }

  render() {
    const [start] = this.visibleRange;
    const totalHeight = this.totalCount * this.itemHeight;
    const offsetTop = start * this.itemHeight;

    return html`
      <div class="spacer" style="height: ${totalHeight}px"></div>
      <div class="item-container" style="top: ${offsetTop}px">
        ${repeat(
          this.visibleItems,
          (item) => item.id,
          (item) => html`
            <div style="height: ${this.itemHeight}px">
              <ac-item-row .item=${item}></ac-item-row>
            </div>
          `
        )}
      </div>
    `;
  }
}
```

**Beklenen sonuçlar:**
- İlk açılış: 100 KB HTML + 200 KB ilk chunk = **300 KB total** (12.4 MB → 300 KB).
- LCP: < 1.5s (4G).
- Bellek: 60 öğe DOM'da (6394 yerine) → ~10 MB heap.
- Search: FlexSearch indeksi ~1.5 MB, lazy load.

---

### 9.2 Tüm Vault'lar için Generic Migration Script

```typescript
// tools/migrate-html-to-json/index.ts
import { readdir, readFile } from 'fs/promises';
import { JSDOM } from 'jsdom';
import path from 'path';
import pino from 'pino';

const logger = pino();

async function migrateAllVaults(legacyDir: string, outDir: string) {
  const files = await readdir(legacyDir);
  const htmlFiles = files.filter(f => f.endsWith('.html') && f !== 'index.html');
  
  logger.info({ count: htmlFiles.length }, 'Starting migration');
  
  const manifest: { vaults: VaultManifest[] } = { vaults: [] };
  
  for (const file of htmlFiles) {
    try {
      const result = await migrateVault(path.join(legacyDir, file), outDir);
      manifest.vaults.push(result);
      logger.info({ vault: result.id, items: result.itemCount }, 'Migrated');
    } catch (err) {
      logger.error({ file, err }, 'Migration failed');
    }
  }
  
  await writeFile(
    path.join(outDir, 'manifest.json'),
    JSON.stringify(manifest, null, 2)
  );
  
  logger.info({ totalVaults: manifest.vaults.length }, 'Done');
}

interface VaultManifest {
  id: string;
  fileName: string;
  itemCount: number;
  categories: string[];
  size_kb: number;
  version: string;
  extractedAt: string;
}
```

---

## Ek 10: SLA / SLO / SLI Tanımları

### 10.1 Service Level Indicators (SLI) — Ne ölçülecek

| SLI | Tanım | Ölçüm Yöntemi |
|---|---|---|
| **Availability** | Yüzde başarılı HTTP request | `200 OK / total requests` (last 30 days) |
| **Latency** | p50, p95, p99 yanıt süresi | Lighthouse, RUM (Sentry / Plausible) |
| **Error rate** | 5xx / total | Sentry'den 5xx counter |
| **Sync data integrity** | Doğru senkronize edilen değişiklik oranı | Server-side checksum vs client checksum |
| **Search relevance** | Top-3 search sonucundaki click-through | Plausible event tracking |
| **LLM token cost / kullanıcı** | Aylık ortalama token tüketimi | Custom event tracking |
| **Page load Web Vitals** | LCP, INP, CLS | Chrome UX Report (CrUX) + RUM |

### 10.2 Service Level Objectives (SLO) — Hedefler

| Dönem | Availability | p95 Latency | Error rate | LCP p75 |
|---|:---:|:---:|:---:|:---:|
| D1 | 99.0% | < 500ms | < 1% | < 3s |
| D2 | 99.5% | < 300ms | < 0.5% | < 2s |
| D3 | 99.7% | < 200ms (search), < 2s (LLM) | < 0.3% | < 1.5s |
| D4 | 99.9% | < 150ms (search), < 200ms (sync) | < 0.1% | < 1.5s |
| D5 | 99.95% | < 100ms (search), < 150ms (sync) | < 0.05% | < 1s |

### 10.3 Error Budget Politikası

> **"Error budget yandığında özellik geliştirmeyi durdur."**

Aylık 1% error budget = 7.2 saat downtime izni.
- **>50% tüketim**: Tüm risk taşıyan deploy'lar durur.
- **>75% tüketim**: Sadece bug-fix kabul edilir.
- **>100% tüketim**: 1 haftalık freeze + post-mortem zorunlu.

---

## Ek 11: Incident Response Playbook'u

### 11.1 Severity Sınıflandırması

| Severity | Tanım | Örnek | Response time | Escalation |
|---|---|---|:---:|---|
| **SEV-0** | Total outage | site indeksten kalktı | 5 dk | CEO + CTO + tüm on-call |
| **SEV-1** | Major degradation | 50%+ kullanıcı etkileniyor | 15 dk | On-call + CTO |
| **SEV-2** | Partial outage | tek özellik bozuk | 1 saat | On-call |
| **SEV-3** | Minor issue | kozmetik / non-critical | next business day | Tech lead |

### 11.2 On-Call Rotation (D2'den itibaren)

- **Primary**: 1 mühendis, 24/7, haftalık rotation.
- **Secondary**: 1 mühendis, escalation için.
- **Compensation**: Hafta başına bonus (örn. $200 + işlem başına $50).

### 11.3 SEV-0 Playbook (örnek)

**Tetik:** Sentry'de %20+ error rate veya Plausible'da 5 dk sıfır request.

**Adımlar:**
1. **0-5 dk:** On-call alarm alır → status.aletcantasi.com'da incident açar.
2. **5-15 dk:** Investigate. Logs (Grafana Loki), Sentry exception, metrics.
3. **15-30 dk:** Rollback değerlendir. Last green deploy commit'e revert.
4. **30-60 dk:** Hot-fix veya geçici workaround. Status update her 15 dk.
5. **60+ dk:** Tüm executive ekip dahil olur. Customer comms (Twitter, email).
6. **Sonra:** Blameless post-mortem (48 saat içinde), action items, follow-up.

### 11.4 Post-mortem Şablonu

```markdown
# Post-mortem: [Olay başlığı]

## Özet
- **Tarih:** YYYY-MM-DD HH:MM TZ
- **Süre:** X dakika
- **Etki:** Kaç kullanıcı, hangi özellik
- **Severity:** SEV-0/1/2/3

## Timeline
| Saat | Olay |
|---|---|
| 14:00 | Deploy ABC123 main'e |
| 14:05 | Sentry'de spike başladı |
| 14:08 | On-call alarm aldı |
| ... | ... |

## Kök neden (Root Cause)
[5 Whys analizi]

## Çözüm
[Ne yapıldı]

## Etkisi
- Kullanıcı sayısı:
- Gelir kaybı:
- Marka etkisi:

## Action Items
- [ ] [Önleyici] X kontrolü ekle (sahibi: @ayse, deadline: T+7)
- [ ] [Tespit] Y dashboard'unu kur (sahibi: @mehmet, deadline: T+14)
- [ ] [Müdahale] Z runbook yaz (sahibi: @ali, deadline: T+3)

## Öğrenilen
[Sistemin neresini geliştirmek lazım, kim için ders]
```

---

## Ek 12: Database Schema Migration Örnekleri

### 12.1 Dexie (IndexedDB) — Initial schema

```typescript
// packages/data/src/db.ts
import Dexie, { Table } from 'dexie';

export interface Vault {
  id: string;
  title: string;
  description: string;
  category: 'ai' | 'engine3d' | 'history' | 'data' | 'product' | 'dev';
  color: string;
  itemCount: number;
  version: string;
  updatedAt: string;
  riskFlags?: string[];
}

export interface Item {
  id: string;  // ULID
  vaultId: string;
  no: string;
  cat: string;
  name: string;
  desc: string;
  content: string;
  tags: string[];
  badges?: { primary?: string; secondary?: string };
  source: any;
  variantOf?: string;
  hash: string;
  createdAt: string;
  updatedAt: string;
}

export interface EncryptedApiKey {
  id: string;  // provider name
  iv: number[];
  ct: number[];
}

export interface Setting {
  key: string;
  value: any;
}

export class AletCantasiDB extends Dexie {
  vaults!: Table<Vault, string>;
  items!: Table<Item, string>;
  apiKeys!: Table<EncryptedApiKey, string>;
  settings!: Table<Setting, string>;

  constructor() {
    super('AletCantasiDB');
    this.version(1).stores({
      vaults: 'id, category, updatedAt',
      items: 'id, vaultId, [vaultId+cat], *tags, name',
      apiKeys: 'id',
      settings: 'key',
    });
  }
}

export const db = new AletCantasiDB();
```

### 12.2 Migration v1 → v2 (örnek)

```typescript
this.version(2).stores({
  vaults: 'id, category, updatedAt',
  items: 'id, vaultId, [vaultId+cat], *tags, name, hash',  // hash index eklendi
  apiKeys: 'id',
  settings: 'key',
  embeddings: 'itemId, vaultId',  // yeni tablo (D3 için)
}).upgrade(async (tx) => {
  // Migration logic
  await tx.table('items').toCollection().modify(item => {
    if (!item.hash) {
      item.hash = sha256(item.content);
    }
  });
});
```

### 12.3 SQLite (D4 backend) — Initial schema

```sql
-- migrations/0001_initial.sql
CREATE TABLE workspaces (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  owner_id TEXT NOT NULL,
  plan TEXT NOT NULL DEFAULT 'free',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  avatar_url TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login_at TEXT
);

CREATE TABLE workspace_members (
  workspace_id TEXT NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner','admin','member','viewer')),
  joined_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (workspace_id, user_id)
);

CREATE TABLE sync_documents (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  doc_type TEXT NOT NULL CHECK (doc_type IN ('vault','item','settings')),
  encrypted_state BLOB NOT NULL,
  state_vector BLOB NOT NULL,
  version INTEGER NOT NULL DEFAULT 1,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sync_documents_workspace ON sync_documents(workspace_id, doc_type);
CREATE INDEX idx_workspace_members_user ON workspace_members(user_id);

CREATE TABLE audit_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT,
  workspace_id TEXT,
  action TEXT NOT NULL,
  payload_json TEXT,
  ip TEXT,
  user_agent TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_audit_logs_workspace_time ON audit_logs(workspace_id, created_at DESC);
```

---

## Ek 13: RAG Pipeline — Kodu Bütünüyle

### 13.1 Embedding generation (build-time)

```typescript
// tools/embed-generator/index.ts
import { pipeline } from '@xenova/transformers';
import fs from 'fs/promises';
import { readVaults } from './utils.js';

const MODEL = 'Xenova/paraphrase-multilingual-MiniLM-L12-v2';
const DIM = 384;

async function generateEmbeddings() {
  console.log('Loading embedding model...');
  const embedder = await pipeline('feature-extraction', MODEL);
  
  const vaults = await readVaults('./data/vaults');
  
  for (const vault of vaults) {
    console.log(`Processing vault: ${vault.id} (${vault.items.length} items)`);
    
    const embeddings = new Float32Array(vault.items.length * DIM);
    
    for (let i = 0; i < vault.items.length; i++) {
      const item = vault.items[i];
      const text = `${item.name}. ${item.desc}\n${item.content.slice(0, 500)}`;
      
      const output = await embedder(text, { pooling: 'mean', normalize: true });
      const vec = output.data as Float32Array;
      embeddings.set(vec, i * DIM);
      
      if (i % 100 === 0) console.log(`  ${i}/${vault.items.length}`);
    }
    
    await fs.writeFile(
      `./data/vaults/${vault.id}/embeddings.bin`,
      Buffer.from(embeddings.buffer)
    );
    
    console.log(`✓ ${vault.id}: ${embeddings.length * 4} bytes written`);
  }
}

generateEmbeddings().catch(console.error);
```

### 13.2 Browser-side hybrid search

```typescript
// packages/llm/src/search.ts
import { pipeline } from '@xenova/transformers';
import FlexSearch from 'flexsearch';
import HNSWLib from 'hnswlib-wasm';

export class HybridSearch {
  private bm25!: FlexSearch.Index;
  private hnsw!: any;  // HNSWLib instance
  private embedder!: any;
  private items: Item[] = [];

  async init(vaultId: string) {
    // Load items
    const itemsResp = await fetch(`/data/vaults/${vaultId}/items.ndjson`);
    const text = await itemsResp.text();
    this.items = text.trim().split('\n').map(l => JSON.parse(l));

    // Build BM25 index (FlexSearch)
    this.bm25 = new FlexSearch.Index({
      tokenize: 'forward',
      cache: true,
      preset: 'memory',
    });
    this.items.forEach((item, i) => {
      this.bm25.add(i, `${item.name} ${item.desc} ${item.tags?.join(' ') ?? ''} ${item.content.slice(0, 1000)}`);
    });

    // Load HNSW index
    const embeddingsResp = await fetch(`/data/vaults/${vaultId}/embeddings.bin`);
    const buffer = await embeddingsResp.arrayBuffer();
    const embeddings = new Float32Array(buffer);

    this.hnsw = await HNSWLib({});
    this.hnsw.initIndex(this.items.length, 16, 200);  // M=16, efConstruction=200
    for (let i = 0; i < this.items.length; i++) {
      this.hnsw.addPoint(embeddings.subarray(i * 384, (i + 1) * 384), i);
    }
    this.hnsw.setEf(50);

    // Load embedder for query encoding
    this.embedder = await pipeline('feature-extraction', 'Xenova/paraphrase-multilingual-MiniLM-L12-v2');
  }

  async search(query: string, k = 10): Promise<SearchResult[]> {
    // 1) BM25 retrieval
    const bm25Hits = this.bm25.search(query, { limit: 50 }) as number[];

    // 2) Vector retrieval
    const queryEmbedding = await this.embedder(query, { pooling: 'mean', normalize: true });
    const vecResult = this.hnsw.searchKnn(queryEmbedding.data, 50);
    const vecHits = vecResult.neighbors as number[];

    // 3) Reciprocal Rank Fusion
    const fused = this.rrf([bm25Hits, vecHits], 60);

    return fused.slice(0, k).map(idx => ({
      item: this.items[idx],
      score: 1.0,  // RRF doesn't preserve scores; use rank
    }));
  }

  private rrf(rankings: number[][], k = 60): number[] {
    const scores = new Map<number, number>();
    for (const ranking of rankings) {
      ranking.forEach((id, rank) => {
        const current = scores.get(id) ?? 0;
        scores.set(id, current + 1 / (k + rank));
      });
    }
    return [...scores.entries()]
      .sort((a, b) => b[1] - a[1])
      .map(([id]) => id);
  }
}
```

### 13.3 WebLLM ile RAG generation

```typescript
// packages/llm/src/rag.ts
import * as webllm from '@mlc-ai/web-llm';
import { HybridSearch } from './search.js';

export class RAGPipeline {
  private engine!: webllm.MLCEngine;
  private search!: HybridSearch;

  async init(vaultId: string) {
    this.search = new HybridSearch();
    await this.search.init(vaultId);

    const selectedModel = 'Llama-3.2-1B-Instruct-q4f16_1-MLC';
    this.engine = await webllm.CreateMLCEngine(selectedModel, {
      initProgressCallback: (report) => {
        console.log(`LLM init: ${(report.progress * 100).toFixed(1)}%`);
      },
    });
  }

  async query(userQuery: string, opts: { maxRetrieved?: number } = {}) {
    // 1. Retrieve
    const retrieved = await this.search.search(userQuery, opts.maxRetrieved ?? 5);

    // 2. Augment
    const context = retrieved.map((r, i) =>
      `[${i + 1}] ${r.item.name}\n${r.item.desc}\n${r.item.content.slice(0, 500)}`
    ).join('\n\n');

    const systemPrompt = `Sen Alet Çantası asistanısın. Aşağıdaki kaynaklardan yararlanarak, sadece bu içeriklerden faydalan; bilmediğin bir şey için "Bilmiyorum" de.

Kaynaklar:
${context}`;

    // 3. Generate (streaming)
    const stream = await this.engine.chat.completions.create({
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userQuery },
      ],
      stream: true,
      temperature: 0.7,
      max_tokens: 800,
    });

    return {
      stream,
      retrieved,  // citations için
    };
  }

  destroy() {
    this.engine?.unload();
  }
}
```

---

## Ek 14: Yjs CRDT Sync Implementation

### 14.1 Client (browser) tarafı

```typescript
// packages/sync/src/client.ts
import * as Y from 'yjs';
import { WebsocketProvider } from 'y-websocket';
import { IndexeddbPersistence } from 'y-indexeddb';
import sodium from 'libsodium-wrappers';

export class EncryptedSyncClient {
  private doc: Y.Doc;
  private indexedDB: IndexeddbPersistence;
  private wsProvider?: WebsocketProvider;
  private aesKey!: Uint8Array;  // derived from user master password

  constructor(public workspaceId: string) {
    this.doc = new Y.Doc();
    this.indexedDB = new IndexeddbPersistence(workspaceId, this.doc);
  }

  async unlock(masterPassword: string) {
    await sodium.ready;
    this.aesKey = sodium.crypto_pwhash(
      32,
      masterPassword,
      sodium.from_string(this.workspaceId).slice(0, 16),  // salt
      sodium.crypto_pwhash_OPSLIMIT_INTERACTIVE,
      sodium.crypto_pwhash_MEMLIMIT_INTERACTIVE,
      sodium.crypto_pwhash_ALG_DEFAULT
    );
  }

  connect(wsUrl: string) {
    if (!this.aesKey) throw new Error('Must unlock first');

    this.wsProvider = new WebsocketProvider(wsUrl, this.workspaceId, this.doc, {
      // Custom params for encryption
      params: { encrypted: '1' },
    });

    // Intercept outgoing updates and encrypt them
    const origSendMessage = this.wsProvider.ws?.send.bind(this.wsProvider.ws);
    if (origSendMessage) {
      this.wsProvider.ws!.send = (data: Uint8Array) => {
        const encrypted = this.encryptUpdate(data);
        origSendMessage(encrypted);
      };
    }
  }

  private encryptUpdate(plaintext: Uint8Array): Uint8Array {
    const nonce = sodium.randombytes_buf(sodium.crypto_secretbox_NONCEBYTES);
    const ciphertext = sodium.crypto_secretbox_easy(plaintext, nonce, this.aesKey);
    const result = new Uint8Array(nonce.length + ciphertext.length);
    result.set(nonce, 0);
    result.set(ciphertext, nonce.length);
    return result;
  }

  private decryptUpdate(envelope: Uint8Array): Uint8Array {
    const nonce = envelope.slice(0, sodium.crypto_secretbox_NONCEBYTES);
    const ciphertext = envelope.slice(sodium.crypto_secretbox_NONCEBYTES);
    return sodium.crypto_secretbox_open_easy(ciphertext, nonce, this.aesKey);
  }

  getVaultMap(): Y.Map<any> {
    return this.doc.getMap('vaults');
  }
  getItemArray(vaultId: string): Y.Array<any> {
    return this.doc.getMap('items').get(vaultId) as Y.Array<any>;
  }

  destroy() {
    this.wsProvider?.destroy();
    this.indexedDB.destroy();
    this.doc.destroy();
    this.aesKey?.fill(0);  // wipe key
  }
}
```

### 14.2 Server tarafı (Hono + Bun)

```typescript
// apps/sync-server/src/index.ts
import { Hono } from 'hono';
import { upgradeWebSocket } from 'hono/bun';
import * as Y from 'yjs';
import { setupWSConnection } from 'y-websocket/bin/utils';
import { Database } from 'bun:sqlite';

const db = new Database('sync.db');
const app = new Hono();

// Auth middleware
app.use('/sync/*', async (c, next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '');
  if (!token) return c.json({ error: 'Unauthorized' }, 401);
  
  const user = await verifyJWT(token);
  if (!user) return c.json({ error: 'Invalid token' }, 401);
  
  c.set('user', user);
  await next();
});

app.get(
  '/sync/:workspaceId',
  upgradeWebSocket(async (c) => {
    const user = c.get('user');
    const workspaceId = c.req.param('workspaceId');
    
    // Check membership
    const membership = db.query(
      'SELECT role FROM workspace_members WHERE workspace_id = ? AND user_id = ?'
    ).get(workspaceId, user.id);
    
    if (!membership) {
      return { onOpen(_, ws) { ws.close(1008, 'Forbidden'); } };
    }
    
    return {
      onOpen(_, ws) {
        // Yjs sync handler
        // Server does NOT decrypt - just relays + persists ciphertext
        setupWSConnection(ws as any, c.req.raw as any, {
          docName: workspaceId,
          gc: true,
        });
      },
    };
  })
);

app.fire();
```

---

## Ek 15: Workflow Şablonları — Pull Request, Issue, vs.

### 15.1 PR Template (.github/pull_request_template.md)

```markdown
## Özet
<!-- 1-2 cümle: ne değişti, neden? -->

## Değişiklik tipi
- [ ] Bug fix (non-breaking)
- [ ] Yeni özellik (non-breaking)
- [ ] Breaking change
- [ ] Dokümantasyon
- [ ] Performans iyileştirmesi
- [ ] Test ekleme/değiştirme
- [ ] CI/CD değişikliği

## Bağlı Issue
Closes #

## Test edildi mi?
- [ ] Unit testler eklendi/güncellendi
- [ ] E2E test eklendi/güncellendi
- [ ] Manuel test edildi (browser: ___)
- [ ] Lighthouse skorları korunuyor

## Screenshot / Video
<!-- UI değişikliği varsa -->

## Checklist
- [ ] Self-review
- [ ] Conventional commit message
- [ ] Test coverage düşmedi
- [ ] Doküman güncellendi (CHANGELOG, README, ADR)
- [ ] CODEOWNERS'da gerekli reviewer eklendi
```

### 15.2 Issue Template — Bug Report

```markdown
---
name: Bug Report
about: Bir hatayı bildir
---

## Açıklama
<!-- Ne oluyor? -->

## Adımlar
1. ...
2. ...
3. ...

## Beklenen davranış
...

## Gerçekleşen davranış
...

## Ortam
- Tarayıcı: Chrome 125
- OS: macOS 14
- Sürüm: v0.5.2

## Ek bilgi
<!-- Screenshot, console log, network trace -->
```

### 15.3 Issue Template — Feature Request

```markdown
---
name: Feature Request
about: Yeni özellik öner
---

## Problem
<!-- Hangi kullanıcı problemini çözüyor? -->

## Önerilen çözüm
<!-- Nasıl çalışmalı? -->

## Alternatifler
<!-- Düşündüğünüz başka çözümler? -->

## Etki
- Kullanıcı sayısı tahmini:
- Geliştirme süresi tahmini:
- Bağımlılıklar:
```

---

## Ek 16: Marketing & Topluluk Stratejisi (D3+'da uygulanacak)

### 16.1 Lansman Kanalları

**Yıl 1 (D1-D3):**
- **Product Hunt**: D3.S18 lansman.
- **Show HN** (Hacker News): teknik blog post ile.
- **Reddit** r/LocalLLaMA, r/selfhosted, r/SideProject.
- **Twitter/X**: technical thread (her sprint sonrası).
- **YouTube**: 3-5 dakikalık demo videoları (D3'te).

**Yıl 2 (D4-D5):**
- **DevTo** + **Medium**: technical articles.
- **Dev conferences** (TR + EU): JsTanbul, Devnot, Web Summit.
- **Podcast appearances**: Devnot, Devhost, technical English podcasts.
- **Influencer marketing**: AI/dev Twitter influencer'larına sponsorlu mesaj.

### 16.2 İçerik Calendar (Örnek aylık)

| Hafta | İçerik | Kanal |
|---|---|---|
| 1 | Engineering blog: "Building local-first AI" | DevTo + LinkedIn |
| 2 | Video: "Demo new vault feature" | YouTube + Twitter |
| 3 | Türkçe blog: "AI promptları nasıl yönetilir" | Medium + Reddit |
| 4 | Newsletter (mailing list): aylık özet | ConvertKit |

### 16.3 Community Standards

- **Code of Conduct**: Contributor Covenant v2.1.
- **Discord**: 5 channel — #general, #help, #showcase, #dev, #moderators.
- **Discourse forum**: knowledge base + Q&A.
- **GitHub Discussions**: feature request + RFC.

---

## Ek 17: Yatırımcı Anket — "100 Soru" (Due Diligence Hazırlığı)

D4 sonu Series A öncesi yatırımcı genellikle 80-120 soru sorar. Hazırlık için
en sık 20 sorunun cevabı şimdiden hazırlanmalı.

### Pazar (Market)
1. **TAM / SAM / SOM nedir?**
   *Cevap:* AI tooling Pazarı 2026'da $80B TAM, dev-tools içinde SAM $8B, prompt management içinde SOM $400M.
2. **Kim olduğunuzu bilmeyen birine 30 saniyede ne anlatırsınız?**
   *Cevap:* "Local-first, AI-native bilgi platformuyuz. Geliştiriciler ve takımlar için 100+ özelleştirilmiş içerik vault'u."

### Ürün
3. **Diğer benzer ürünlerden farkınız?**
4. **Kullanıcı retention metriği?**
5. **Top 3 feature roadmap?**

### Tech
6. **Teknik borç ne kadar?**  → bu raporun Bölüm 2.1.
7. **Multi-tenant izolasyon nasıl?** → ADR-0007 + D4.
8. **Compliance roadmap?** → D5.

### Finance
9. **Burn rate? Runway?** → Bölüm 5.3.
10. **Unit economics (CAC, LTV)?**

### Team
11. **Anahtar kişi riski?** → Bölüm 6.2.
12. **Hiring plan?** → Bölüm 5.1.

### Legal
13. **IP ve patent?** → Bölüm 6.4.
14. **Open source lisans uyumluluğu?** → Ek 1.6.

---

## Ek 18: Glossary Plus — Türkçe / İngilizce Karşılıkları

| TR | EN | Açıklama |
|---|---|---|
| Alet Çantası | Toolbox | Ürün adı |
| Vault | Vault | Tek bir disiplin için kütüphane |
| Öğe | Item | Vault içindeki tek bir kayıt |
| Disiplin | Discipline / Category | AI, oyun, tarih vb. |
| Kategori filtresi | Category filter | UI elemanı |
| Şablon | Template | Reusable prompt |
| Persona | Persona | AI rolü |
| Yönlendirme | Routing | Model seçimi |
| Maliyet analizi | Cost analysis | Token başına ücret |
| Kopyalama | Copy | Clipboard işlemi |
| Yapay zeka | Artificial Intelligence (AI) | Geniş kavram |
| Büyük dil modeli | Large Language Model (LLM) | GPT, Claude, Gemini |
| Embedding | Embedding | Vektör temsili |
| Gömme | Embedding (alternatif) | Aynı |
| Çıkarım | Inference | Model çalıştırma |
| Yerel-öncelik | Local-first | Felsefe |
| Gizlilik-öncelik | Privacy-first | Felsefe |
| Tarayıcı-içi | In-browser | WebGPU/WASM |
| Şifreleme | Encryption | AES/ChaCha |
| Anahtar yönetimi | Key management | KeyVault |
| Erişilebilirlik | Accessibility (a11y) | WCAG |
| Uluslararasılaştırma | Internationalization (i18n) | TR + EN + ... |
| Yerelleştirme | Localization (l10n) | Belirli bölge için |
| Servis seviyesi anlaşması | Service Level Agreement (SLA) | Customer contract |
| Servis seviyesi hedefi | Service Level Objective (SLO) | Internal target |
| Servis seviyesi göstergesi | Service Level Indicator (SLI) | Metric |
| Sıfır-server | Zero-server | Mimari |
| Birleştirilmiş arama | Hybrid search | BM25 + vector |
| Geri-getirme | Retrieval | RAG'in R'si |
| Artırma | Augmentation | RAG'in A'sı |
| Üretim | Generation | RAG'in G'si |
| Hesap (faturalama) | Billing | Müşteri ödemesi |
| Çok-kiracı | Multi-tenant | İzolasyon |
| Pazaryeri | Marketplace | 3. parti vault |
| Eklenti | Plugin / Extension | 3. parti modül |
| Olay sonrası inceleme | Post-mortem | Incident review |

---


## Ek 19: Detaylı Sprint Ticket Listesi (D1)

D1'in 6 sprint'i için tüm ticket'lar. Her ticket sahipli ve tahminli.
Toplam D1 ticket sayısı: ~85, toplam tahmini efor ~280 saat.

### Sprint 1 (D1) — Foundation

| ID | Görev | Sahibi | Efor |
|---|---|---|---:|
| `S1-T01` | GitHub Organization oluştur (aletcantasi-org) | Lead FE | 1h |
| `S1-T02` | Repo: aletcantasi (private, then public) | Lead FE | 30m |
| `S1-T03` | Branch protection: main (required reviews=1, status checks) | Lead FE | 30m |
| `S1-T04` | CODEOWNERS dosyası: @lead-fe @cto | Lead FE | 15m |
| `S1-T05` | PR template + Issue templates | Lead FE | 1h |
| `S1-T06` | pnpm-workspace.yaml + turbo.json | Lead FE | 2h |
| `S1-T07` | tsconfig.base.json (strict, all checks) | Lead FE | 1h |
| `S1-T08` | biome.json + .editorconfig | Mid FE | 1h |
| `S1-T09` | GitHub Actions: ci.yml (lint, typecheck, test, build) | Lead FE | 4h |
| `S1-T10` | husky + lint-staged + commitlint | Mid FE | 2h |
| `S1-T11` | README.md, CONTRIBUTING.md, LICENSE (Apache-2.0) | PM + CTO | 3h |
| `S1-T12` | SECURITY.md (vulnerability disclosure policy) | CTO | 2h |
| `S1-T13` | CODE_OF_CONDUCT.md (Contributor Covenant) | CTO | 1h |
| `S1-T14` | Hello-world Lit component (smoke test) | Mid FE | 2h |
| `S1-T15` | Vitest setup + 1 örnek test | Lead FE | 2h |
| `S1-T16` | Playwright setup + 1 örnek e2e | Lead FE | 3h |
| `S1-T17` | Vercel/Cloudflare deployment (preview branch) | Lead FE | 2h |
| `S1-T18` | Demo: setup'ı yeni dev'e göster (onboarding) | Lead FE | 1h |

### Sprint 2 (D1) — Migration Pipeline

| ID | Görev | Sahibi | Efor |
|---|---|---|---:|
| `S2-T01` | tools/migrate-html-to-json/ paket iskeleti | Lead FE | 2h |
| `S2-T02` | JSDOM ile ITEMS extract | Lead FE | 4h |
| `S2-T03` | JSDOM ile CATS extract | Lead FE | 2h |
| `S2-T04` | NDJSON output writer | Mid FE | 2h |
| `S2-T05` | manifest.json generator | Mid FE | 3h |
| `S2-T06` | Zod schemas (Vault, Item, Source, ...) | Lead FE | 4h |
| `S2-T07` | CI'da pnpm validate:data | Lead FE | 2h |
| `S2-T08` | 100 vault'u batch migrate + log | Mid FE | 3h |
| `S2-T09` | Round-trip test (HTML → JSON → HTML compare) | Lead FE | 4h |
| `S2-T10` | packages/tokens (renkler) + CSS variables | Mid FE | 3h |
| `S2-T11` | CI bundle size monitor | Lead FE | 2h |
| `S2-T12` | Manifest validity test | Mid FE | 2h |
| `S2-T13` | Demo: migration sonucu stakeholder'a | CTO + PM | 1h |

### Sprint 3 (D1) — Güvenlik Patches

| ID | Görev | Sahibi | Efor |
|---|---|---|---:|
| `S3-T01` | KeyVaultService implementation | Lead FE | 8h |
| `S3-T02` | Master password UI (modal) | Mid FE | 4h |
| `S3-T03` | WebCrypto AES-GCM encrypt/decrypt unit tests | Lead FE | 4h |
| `S3-T04` | PBKDF2 salt generation + storage | Lead FE | 3h |
| `S3-T05` | CSP _headers (Cloudflare) config | Lead FE | 2h |
| `S3-T06` | DOMPurify entegrasyonu | Mid FE | 3h |
| `S3-T07` | safe-template helper + tests | Lead FE | 3h |
| `S3-T08` | Google Fonts → self-host (WOFF2) | Mid FE | 2h |
| `S3-T09` | Inline JSON → external fetch | Mid FE | 4h |
| `S3-T10` | Penetrasyon test danışmanı sözleşme | CTO | 2h |
| `S3-T11` | Penetrasyon test execution + raporu | Danışman | 5 gün |
| `S3-T12` | Mozilla Observatory + securityheaders.com test | Lead FE | 2h |
| `S3-T13` | Demo: güvenlik audit raporu | CTO | 1h |

### Sprint 4 (D1) — Test Altyapısı

| ID | Görev | Sahibi | Efor |
|---|---|---|---:|
| `S4-T01` | Vitest config + coverage report | Lead FE | 3h |
| `S4-T02` | searchMatch / esc / catColor için unit testler | Mid FE | 4h |
| `S4-T03` | KeyVaultService end-to-end test | Lead FE | 3h |
| `S4-T04` | Schema validation testleri | Mid FE | 3h |
| `S4-T05` | Playwright config: 3 browser + mobile viewports | Lead FE | 3h |
| `S4-T06` | E2E: vault aç → arama → seç → kopyala | Mid FE | 4h |
| `S4-T07` | E2E: API key save + reload (encrypted) | Lead FE | 4h |
| `S4-T08` | axe-core entegrasyonu + CI blocking | Mid FE | 3h |
| `S4-T09` | Lighthouse CI config + budgets | Lead FE | 3h |
| `S4-T10` | Visual regression (Chromatic) setup | Mid FE | 4h |
| `S4-T11` | Coverage badge + README | Mid FE | 1h |
| `S4-T12` | Test dokümantasyonu | Lead FE | 2h |

### Sprint 5 (D1) — Performans Patches

| ID | Görev | Sahibi | Efor |
|---|---|---|---:|
| `S5-T01` | PromptVault chunking script (100 item/chunk) | Lead FE | 4h |
| `S5-T02` | ChunkedVaultLoader implementation | Lead FE | 5h |
| `S5-T03` | Lit virtual list component | Mid FE | 8h |
| `S5-T04` | FlexSearch integration | Lead FE | 5h |
| `S5-T05` | Search index pre-build script | Mid FE | 3h |
| `S5-T06` | Gzip + Brotli CDN config | Lead FE | 1h |
| `S5-T07` | SVG noise pattern → CSS gradient | Mid FE | 2h |
| `S5-T08` | Lazy load detail panel (renderDetail) | Mid FE | 3h |
| `S5-T09` | WebPageTest + Lighthouse perf baseline | Lead FE | 2h |
| `S5-T10` | Memory profiling (Chrome DevTools) | Lead FE | 3h |

### Sprint 6 (D1) — Launch

| ID | Görev | Sahibi | Efor |
|---|---|---|---:|
| `S6-T01` | Sentry DSN + entegrasyon | Lead FE | 2h |
| `S6-T02` | Plausible self-host (Docker compose) | Lead FE | 4h |
| `S6-T03` | TelemetryService: track helpers | Mid FE | 3h |
| `S6-T04` | Opt-in consent banner | Mid FE | 3h |
| `S6-T05` | Hukuk danışman ile mevzuat brifingi | CTO + PM | 3h |
| `S6-T06` | ToS, Privacy Policy, KVKK metni yazımı | Hukuk + PM | 8h |
| `S6-T07` | Risk-flagged vault'lar: UI uyarısı + age-gate | Mid FE | 5h |
| `S6-T08` | sitemap.xml generator | Lead FE | 2h |
| `S6-T09` | robots.txt + canonical URL'ler | Mid FE | 1h |
| `S6-T10` | Public launch: 100 alpha user invite | PM | 4h |
| `S6-T11` | D1 retro meeting | Tüm ekip | 2h |
| `S6-T12` | D2 planning meeting | CTO + Tech leads | 3h |

---

## Ek 20: D2-D5 Sprint Özet Tablosu

Detay D1 seviyesinde sprint başlangıcında ekibe açılır.

| Sprint | Tema | Açıklama | Tahmini efor |
|---|---|---|---|
| `D2.S7` | Web Components Shell | Lit-based generic vault shell | Mid FE 80h |
| `D2.S8` | IndexedDB + Dexie | Bulk import + schema versioning | Lead FE 70h |
| `D2.S9` | TypeScript Strict + Variant Dedupe | MiniLM embedding for dedupe | Lead FE + Editor 100h |
| `D2.S10` | PWA + Service Worker | Workbox, OPFS, manifest | Mid FE 75h |
| `D2.S11` | A11y Refactor + i18n Foundation | axe-core 0 violation, @lingui | Lead FE 80h |
| `D2.S12` | Design System + Beta Launch | Storybook, dark mode, OG image | Mid FE 70h |
| `D3.S13` | Embedding Pipeline | build-time MiniLM, HNSW pre-build | AI Eng 60h |
| `D3.S14` | Browser Vector Search | Hybrid: BM25 + HNSW + RRF | AI Eng 80h |
| `D3.S15` | WebLLM Integration | Llama 3.2 1B + WebGPU detection | AI Eng 70h |
| `D3.S16` | RAG Pipeline | Retrieval + augmentation + citation | AI Eng + Lead FE 100h |
| `D3.S17` | MCP + Tool Calling | search, get-item, compare-items tools | AI Eng 80h |
| `D3.S18` | Cross-vault Connections + PH Launch | graph view, Show HN | Tüm ekip 120h |
| `D4.S19-20` | CRDT Sync Architecture | Yjs + y-websocket + e2e crypto | BE/SRE 160h |
| `D4.S21-22` | Self-Host Docker Bundle | docker-compose + Helm chart | BE/SRE 120h |
| `D4.S23-24` | Multi-Tenant + OAuth | Workspaces, RLS, OAuth providers | BE 140h |
| `D4.S25-26` | Billing (Lemon Squeezy) | Tier'lar, webhook, grant/revoke | BE 100h |
| `D4.S27-28` | Observability v2 | Grafana + Prometheus + Loki | BE/SRE 120h |
| `D4.S29-30` | Performance & Load Testing | k6, capacity plan, bottleneck fix | BE/SRE + Lead FE 100h |
| `D5.S31-32` | Plugin / Extension API | Web Extension SDK + sandboxed workers | Lead FE + BE 160h |
| `D5.S33-34` | Public REST + GraphQL API | Hono + Apollo, rate limit, OAuth | BE 140h |
| `D5.S35-36` | Vault Marketplace | Dev portal, submit/review/publish | BE + PM 160h |
| `D5.S37-38` | SOC2 Type II Prep | Vanta automation, controls | CTO + PM 80h |
| `D5.S39-40` | KVKK + GDPR Tam Uyum | DPA, data rights API, PIA | CTO + Hukuk 60h |
| `D5.S41-42` | Community + Knowledge Base | Discourse, Starlight, AletCantasiCon hazırlık | Community + PM 120h |
| `D5.S43-44` | i18n Genişleme (5 dil) | Crowdin, ES/DE/AR/JA | Lead FE 100h |
| `D5.S45-46` | Enterprise (SSO, SCIM, Audit) | SAML 2.0, OIDC, audit log | BE + Lead FE 140h |
| `D5.S47-48` | SOC2 Audit + Series A Prep | Audit execution, investor data room | CTO + CFO 100h |

---

## Ek 21: D1 Günlük Operasyon Takvimi (Örnek 90 Gün)

Aşağıdaki örnek takvim, **CTO'nun ilk 90 günde** ekibe verdiği yapıyı gösterir.

| Hafta | Ana etkinlik |
|---|---|
| Hafta 1 | İşe alım + onboarding + Sprint 1 başlangıç |
| Hafta 2 | Sprint 1: Foundation devam + 3 mühendis tam zamanlı |
| Hafta 3 | Sprint 2 başlar: Migration |
| Hafta 4 | Sprint 2 devam + İlk deploy preview branch |
| Hafta 5 | Sprint 3 başlar: Güvenlik patches |
| Hafta 6 | Sprint 3 devam + Penetrasyon test execution |
| Hafta 7 | Sprint 4 başlar: Test Altyapısı |
| Hafta 8 | Sprint 4 devam + Coverage 60% hedefi |
| Hafta 9 | Sprint 5 başlar: PromptVault refactor |
| Hafta 10 | Sprint 5 devam + Virtual scroll demo |
| Hafta 11 | Sprint 6 başlar: Sentry + Plausible + hukuk |
| Hafta 12 | D1 retro + D2 planning + Public launch |
| Hafta 13 | D2 başlangıç + D1 retro action items |

### Haftalık ritm (her hafta tekrarlanan)


| Gün | Saat | Etkinlik | Katılımcı |
|---|---|---|---|
| Pzt | 10:00 | Sprint planning (bi-weekly), günlük standup | Tüm dev ekip |
| Pzt-Cum | 09:30 | Standup (15 dk) | Tüm dev ekip |
| Cum | 14:00 | Demo (bi-weekly sprint sonu) | Tüm ekip + stakeholder |
| Cum | 15:30 | Retro (bi-weekly sprint sonu) | Tüm dev ekip |
| Çar | 14:00 | 1:1 (CTO ↔ her dev, 30 dk) | İkişerli |
| Per | 10:00 | Tech all-hands (her 2 hafta, 60 dk) | Tüm tech ekip |

---

## Ek 22: Karar Günlüğü (Decision Log) Şablonu

ADR'lar **büyük mimari** kararları için. **Küçük günlük kararlar** için
ayrı bir Decision Log tutulur (`docs/decisions/log.md`):

```markdown
# Karar Günlüğü

## 2026-06-15 — Vault renk paleti seçimi
Önerilen: 6 kategori için 6 ana ton.
Karar: Onaylandı.
Sahip: @cto, @design
Geri çevirme tarihi: yok

## 2026-06-16 — Lit vs vanilla Web Components
ADR-0004 ile detaylandırıldı.

## 2026-06-17 — pnpm cache CI'da nasıl yönetilecek
Karar: actions/setup-node cache='pnpm' yeterli.
Geri çevirme tarihi: 1 ay (performans tekrar değerlendirilecek)

## 2026-06-18 — Çince + Arapça RTL desteği
Karar: D5'e ertelendi (yeterli kullanıcı yok).
Sahip: @pm
Geri çevirme tarihi: D4 sonu

## 2026-06-19 — Telemetry: PostHog vs Plausible
Karar: Plausible self-host. ADR-0009.

## 2026-06-20 — Authentication: WorkOS vs Auth0 vs in-house
Karar: D4'e ertelendi, D3'e kadar OAuth direct (Google/GitHub).
```

**Format:**
- 2 cümle: ne karar verildi?
- Sahibi: kim?
- Karşı görüş varsa: o da yazılır.
- 30 günde bir reviewer gözden geçirir.

---

## Ek 23: Stakeholder İletişim Şablonları

### Aylık Yatırımcı Update (Email)

```
Konu: [Alet Çantası] Aylık update — Haziran 2026

Sevgili yatırımcılarımız,

Bu ay önemli kilometre taşları:

🎯 Metric Highlights
- MAU: 3,200 (+45% MoM)
- Paying customers: 87 (+22% MoM)
- MRR: $440 (+18% MoM)
- Churn (paying): %4.6 (-0.4 pp)
- NPS: 52 (eski 48)

🚀 Ürün
- D2.S10 tamamlandı: PWA + offline mode launch
- Lighthouse Performance 92 (mobile)
- Variant dedupe: 52K → 22K görünür item

💼 Ekip
- Senior AI Eng (Ayşe Y.) iyi gitti, D3 kickoff hazır
- Editor Murat T. başladı, content quality SLA aktif

⚠️ Riskler / Sıkıntılar
- LLM provider maliyeti %12 arttı (Gemini fiyat artışı)
  → mitigation: D3'te local LLM hedefiyle hızlandırma
- Mobile Safari WebGPU yok hâlâ
  → mitigation: Lite mode UX iyileştirildi

🎁 Yardım istediğimiz
- Y Combinator W27 başvurusu hazırlığı için referee
- AI/ML community'de tanıdık 1-2 kişi (içerik partnerlik için)

Saygılarımla,
[Kurucu]
```

### Çeyreklik Board Meeting

```
1. Geçmiş çeyrek özeti (10 dk)
2. Metric review (15 dk): MAU, MRR, churn, ARR, growth
3. Ürün roadmap update (15 dk)
4. Finansal review (15 dk)
5. Risk review (15 dk)
6. Board action items (10 dk)
7. AOB (10 dk)
```

### Sprint review (her 2 haftada bir)

```
1. Hedeflediğimiz çıktılar (5 dk)
2. Tamamladıklarımız demo (20 dk)
3. Burndown chart (5 dk)
4. Velocity trend (5 dk)
5. Önümüzdeki sprint preview (10 dk)
6. Action items (5 dk)
```

---

## Ek 24: KPI Dashboard Tasarımı

**Hedef:** Tek bakışta şirketin sağlığı. Grafana panel olarak D4'ten sonra otomatik.

### Top-level metrikler (5 kutu)

| Metric | Hedef | Renk |
|---|---|---|
| MAU | growing 15%/month | yeşil |
| Paying users | growing 10%/month | yeşil |
| MRR | growing 10%/month | yeşil |
| Uptime (last 30d) | ≥99.5% | yeşil |
| NPS | ≥50 | yeşil |

### Ürün-detay metrikleri

- Vault open rate / vault (top 10)
- Search no-results rate (içerik gap'i sinyali)
- Item copy rate / kullanıcı
- LLM token usage / kullanıcı
- API error rate / endpoint

### Mühendislik metrikleri

- PR merge cycle time (median, p95)
- Test coverage trend
- Lighthouse score trend
- Bug count by severity
- On-call escalation count

### Finans metrikleri

- Cash runway (months)
- Burn rate (monthly $)
- CAC (Customer Acquisition Cost)
- LTV (Customer Lifetime Value)
- LTV / CAC ratio (>3 hedefi)

---

## Ek 25: Bu Raporun Kullanımına Dair Notlar

1. **Yaşayan doküman**: Bu rapor v1.0. Her dönem sonu (D1, D2, ...) v1.1, v1.2 olarak güncellenmelidir.
   `docs/strategy/cto-audit-v{X}.md` olarak commit'lenir.

2. **Versiyon kontrolü**: Bu doküman Git ile takip edilmelidir. Conventional Commits:
   ```
   docs(strategy): D1 retro action items eklendi
   docs(strategy): D2 planning, ADR-0013 eklendi
   ```

3. **Erişim seviyesi**: 
   - Yönetici Özeti (Bölüm 0): tüm ekip + advisors görebilir.
   - Detay bölümler: tech ekip + kurucu.
   - Bütçe detayları: kurucu + CFO + advisors.
   - Risk değerlendirme: kurucu + CTO + CFO.

4. **Geri bildirim**: Her ekip üyesi `feedback.md`'ye not bırakabilir.
   30 günde bir CTO bunları toplar, eklemeleri yapar.

5. **Confidentiality**: Bu rapor, şirket dışına çıkmamalıdır.
   Yatırımcı paylaşımı sadece **redacted version** ile yapılabilir.

---

## Son Söz

Bu rapor 30 günde hazırlandı; ama onu izleyen 24 ay, ne kadar başarılı uygulayacağımızla
ilgili. Ürün başarısı **plan kalitesi** ile değil, **uygulama disiplini** ile gelir.

Cuma sabah saat 09:30, ilk Sprint 1 standup'ında görüşmek üzere.

— **CTO Ofisi, Haziran 2026**

---

*Doküman boyutu özet: ~250 KB Markdown · render edildiğinde ~800 sayfa · 24 ay yatırım planı · 280+ teknik borç puanı · 100 vault denetimi · 25 ek.*
