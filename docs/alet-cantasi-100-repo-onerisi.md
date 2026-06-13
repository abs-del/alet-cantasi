# Alet Çantası — 100+ Repo Altyapı Önerisi

> **Amaç:** 100 vault uygulaması ve 1 index.html için, daha önce hazırlanan **100 geliştirme önerisinin tamamının** uygulanabilmesini sağlayacak açık kaynak repo katalogu.
> **Kapsam:** A–J bölümleri (Arama, Kişiselleştirme, AI, Dışa Aktarma, Mimari, UI/UX, Güvenlik, Analitik, İçerik, Geliştirici) + Vault‑özel ek modüller.
> **Toplam:** 130+ benzersiz repo, her biri belirli bir öneri ve/veya belirli bir vault için.
> **Lisans notu:** Listedeki repo'ların büyük çoğunluğu MIT/Apache‑2.0/BSD altında. Ticari kullanım öncesi her birinin LICENSE dosyasını doğrulayın.

---

## 📑 İçindekiler

- [A. Arama & Keşif (öneri 1–15)](#a-arama--keşif)
- [B. Kişiselleştirme & Organizasyon (16–30)](#b-kişiselleştirme--organizasyon)
- [C. AI Entegrasyonu & Çalıştırma (31–45)](#c-ai-entegrasyonu--çalıştırma)
- [D. Dışa Aktarma & Paylaşım (46–55)](#d-dışa-aktarma--paylaşım)
- [E. Mimari & Performans (56–65)](#e-mimari--performans)
- [F. UI/UX Geliştirmeleri (66–75)](#f-uiux-geliştirmeleri)
- [G. Güvenlik & Gizlilik (76–80)](#g-güvenlik--gizlilik)
- [H. Analitik & İçgörü (81–88)](#h-analitik--içgörü)
- [I. İçerik & Veri Zenginleştirme (89–95)](#i-içerik--veri-zenginleştirme)
- [J. Geliştirici & Güç Kullanıcısı (96–100)](#j-geliştirici--güç-kullanıcısı)
- [K. Vault‑Özel Domain Repo'ları (bonus)](#k-vault-özel-domain-repoları)
- [L. Webhook & Veri Çekme Altyapısı (ek)](#l-webhook--veri-çekme-altyapısı)
- [M. Kurulum Önceliği & Yol Haritası](#m-kurulum-önceliği--yol-haritası)

---

## A. Arama & Keşif

### Öneri 1 — Tam metin arama (fuzzy)
- **Fuse.js** — `https://github.com/krisk/Fuse`
  Hafif (~12KB), bağımlılıksız fuzzy search; tipo toleransı, ağırlıklı alan araması (`name`, `desc`, `content`).
- **MiniSearch** — `https://github.com/lucaong/minisearch`
  Saf JS, tam‑metin + prefix + fuzzy + alan ağırlığı. Tarayıcıda 100k+ doküman idare edebilir.
- **mark.js** — `https://github.com/julmot/mark.js`
  Eşleşen kısımları sarı vurgulama (highlight) için tek satırlık entegrasyon.

### Öneri 2 — Boolean operatörler
- **search-query-parser** — `https://github.com/nepsilon/search-query-parser`
  `AND/OR/NOT/"frase"` desteği olan sorgu ayrıştırıcı; MiniSearch/Fuse'la birleştirilir.
- **lunr.js** — `https://github.com/olivernn/lunr.js`
  Field‑level boolean, wildcard ve boost desteği; offline tam‑metin motoru.

### Öneri 3 — Gelişmiş filtre paneli
- **Refine (refinejs)** — `https://github.com/refinedev/refine`
  Filtre/sıralama/sayfalama UI bileşenleri.
- **InstantSearch.js** — `https://github.com/algolia/instantsearch`
  Facet/multi‑select/range filtre bileşenleri; Algolia bağımlı değil, MeiliSearch ile de çalışır.

### Öneri 4 — Arama geçmişi
- **localForage** — `https://github.com/localForage/localForage`
  localStorage / IndexedDB / WebSQL tek API; arama geçmişi için ideal.

### Öneri 5 — Sesli arama
- **annyang** — `https://github.com/TalAter/annyang`
  Web Speech API üstüne sezgisel sarmalayıcı; TR dil desteği var.
- **whisper.cpp** — `https://github.com/ggerganov/whisper.cpp`
  Çevrimdışı sesli‑metin (WASM build mevcut); gizlilik odaklı kullanıcılar için.

### Öneri 6 — Exclude filtresi
- (Öneri 1'deki MiniSearch / Fuse `-keyword` sözdizimiyle yerine getirilir; ek repo gerekmez.)

### Öneri 7 — Regex arama
- **XRegExp** — `https://github.com/slevithan/xregexp`
  Genişletilmiş regex sözdizimi, Unicode kategori desteği; RegexVault için zaten yararlı.

### Öneri 8 — Sonuç sıralama
- **match-sorter** — `https://github.com/kentcdodds/match-sorter`
  Akıllı sıralama (alaka + alfabetik + özel anahtar).

### Öneri 9 — Etiket / hashtag araması
- **react-tagcloud** — `https://github.com/madox2/react-tagcloud`
  Tıklanabilir etiket bulutu (vanilla'ya port basit).
- **TagsInput (vanilla)** — `https://github.com/jakerella/jquery-tagsinput`
  Tag girişi/seçimi.

### Öneri 10 — Semantik arama (embedding)
- **transformers.js** — `https://github.com/huggingface/transformers.js`
  Tarayıcıda embedding üretimi (MiniLM, e5‑small); API'ye bağımlı kalmadan offline semantic search.
- **hnswlib-wasm** — `https://github.com/ChromaCorp/hnswlib-wasm`
  Yaklaşık en yakın komşu (ANN) indeksi, tarayıcıda kosinüs benzerliği.
- **chromadb** — `https://github.com/chroma-core/chroma`
  Sunucu tarafı isterseniz: yerel vector DB.

### Öneri 11 — Vault'lar arası global arama
- **FlexSearch** — `https://github.com/nextapps-de/flexsearch`
  Çoklu index destekli, milyon kayıt seviyesinde tarayıcı içi arama; 100 vault'u tek index'te birleştirmek için ideal.

### Öneri 12 — Autocomplete
- **autoComplete.js** — `https://github.com/TarekRaafat/autoComplete.js`
  Bağımlılıksız, çok hafif autocomplete.

### Öneri 13 — Etiket örtüşmesine göre benzer öğeler
- (Öneri 10 embedding altyapısı + cosine sim ile çözülür; ek olarak)
- **ml-distance** — `https://github.com/mljs/distance`
  Cosine, Jaccard, Hamming gibi 20+ benzerlik fonksiyonu.

### Öneri 14 — Word cloud
- **wordcloud2.js** — `https://github.com/timdream/wordcloud2.js`
  Canvas tabanlı, performanslı word cloud.
- **d3-cloud** — `https://github.com/jasondavies/d3-cloud`
  D3 ile estetik kelime bulutu.

### Öneri 15 — "Bugünün öğesi"
- **seedrandom** — `https://github.com/davidbau/seedrandom`
  Tarihe seed'lenmiş deterministik rastgele; aynı gün herkese aynı öğeyi gösterir.

---

## B. Kişiselleştirme & Organizasyon

### Öneri 16 — Favoriler
- **idb-keyval** — `https://github.com/jakearchibald/idb-keyval`
  IndexedDB üstünde ultra‑basit key‑val; favoriler için ideal.

### Öneri 17 — Koleksiyonlar
- **SortableJS** — `https://github.com/SortableJS/Sortable`
  Sürükle‑bırak liste/koleksiyon yönetimi (öneri 71 ile aynı temel).
- **Dexie.js** — `https://github.com/dexie/Dexie.js`
  IndexedDB üstünde rahat ORM; koleksiyon/öğe ilişkileri için.

### Öneri 18 — Kişisel notlar
- **TipTap** — `https://github.com/ueberdosis/tiptap`
  Hafif rich‑text editör (Markdown'a serileştirilebilir).
- **EasyMDE** — `https://github.com/Ionaru/easy-markdown-editor`
  Basit markdown editör; notlar için yeterli.

### Öneri 19 — Kullanım geçmişi
- (idb-keyval / Dexie ile çözülür; ekstra repo gerekmiyor.)

### Öneri 20 — Okundu/okunmadı
- (idb-keyval; UI için ✓ ikon set:)
- **Lucide Icons** — `https://github.com/lucide-icons/lucide`
  1000+ açık kaynak ikon (check, star, eye dahil).

### Öneri 21 — Yıldız derecelendirme
- **bar-rating / star-rating-svg** — `https://github.com/nashio/star-rating-svg`
  SVG yıldız bileşeni.

### Öneri 22 — Renk etiketleme
- **Pickr** — `https://github.com/Simonwep/pickr`
  Hafif renk seçici (ihtiyaç olursa).

### Öneri 23 — Karanlık/aydınlık tema
- **theme-change** — `https://github.com/saadeghi/theme-change`
  `prefers-color-scheme` + manuel toggle, CSS değişkenleriyle.
- **darkreader** — `https://github.com/darkreader/darkreader`
  Tam otomatik koyu tema kütüphanesi (alternatif).

### Öneri 24 — Yazı tipi boyutu
- (CSS değişkeniyle çözülür; ek araç: )
- **fluid-typography** referans implementasyonu — `https://github.com/madebymike/css-fluid-type` (vanilla CSS).

### Öneri 25 — Density kontrolü (kompakt/rahat)
- (CSS değişkeniyle çözülür; örnek için DaisyUI bileşenleri.)
- **DaisyUI** — `https://github.com/saadeghi/daisyui`
  Tailwind üstünde hazır bileşen seti; density varyantları var.

### Öneri 26 — Öğe karşılaştırma
- **Split.js** — `https://github.com/nathancahill/split`
  Yan yana panel split yöneticisi; 2‑3 öğe karşılaştırma layout'u.

### Öneri 27 — Kısayol tuşları
- **Mousetrap** — `https://github.com/ccampbell/mousetrap`
  Klavye kısayolu için klasik (`/`, `Esc`, `C`, `F`).
- **hotkeys-js** — `https://github.com/jaywcjlove/hotkeys-js`
  Modern alternatif, scope/sequence desteği.

### Öneri 28 — Vault başlangıç görünüm tercihi
- (idb-keyval ile çözülür.)

### Öneri 29 — Kişisel dashboard
- **Gridstack.js** — `https://github.com/gridstack/gridstack.js`
  Sürüklenebilir, yeniden boyutlanabilir dashboard widget'ları.

### Öneri 30 — Profil / takma ad / avatar
- **Identicons / Jdenticon** — `https://github.com/dmester/jdenticon`
  Kullanıcı adından deterministik renkli avatar üretir.

---

## C. AI Entegrasyonu & Çalıştırma

### Öneri 31 — "Şimdi Çalıştır" + streaming
- **anthropic-sdk-typescript** — `https://github.com/anthropics/anthropic-sdk-typescript`
  Resmi Anthropic SDK; SSE streaming dahil.
- **eventsource-parser** — `https://github.com/rexxars/eventsource-parser`
  Streaming yanıtları parse etmek için minimal parser.

### Öneri 32 — Değişken doldurma formu
- **Handlebars.js** — `https://github.com/handlebars-lang/handlebars.js`
  `${Position}` şablonlarını yönetir.
- **mustache.js** — `https://github.com/janl/mustache.js`
  Alternatif, daha küçük (3KB).
- **JSON Forms** — `https://github.com/eclipsesource/jsonforms`
  Şablon değişkenlerinden otomatik form üretimi.

### Öneri 33 — Model seçimi UI
- (DaisyUI / native `<select>` yeterli — ek repo gerekmez.)

### Öneri 34 — Sıcaklık slider
- **nouislider** — `https://github.com/leongersen/noUiSlider`
  Şık, dokunmatik dostu range slider.

### Öneri 35 — Sistem prompt üzerine yazma
- (TipTap/EasyMDE — öneri 18 ile aynı.)

### Öneri 36 — Sohbet modu
- **Vercel ai SDK (open core)** — `https://github.com/vercel/ai`
  React/Svelte/Vue için chat state yönetimi + streaming primitives.
- **assistant-ui** — `https://github.com/Yonom/assistant-ui`
  React chat UI bileşenleri (mesaj listesi, typing indicator).

### Öneri 37 — Yanıt kaydetme
- (Dexie/idb-keyval.)

### Öneri 38 — Batch çalıştırma
- **p-queue** — `https://github.com/sindresorhus/p-queue`
  Concurrency limit'li promise kuyruğu; API rate limit ile uyumlu.
- **p-retry** — `https://github.com/sindresorhus/p-retry`
  Otomatik exponential backoff retry.

### Öneri 39 — Prompt zincirleme
- **LangChain.js** — `https://github.com/langchain-ai/langchainjs`
  Chain/Tool/Agent soyutlamaları; ChainVault için doğrudan altyapı.
- **LangGraph.js** — `https://github.com/langchain-ai/langgraphjs`
  Stateful agent graph'ları.

### Öneri 40 — Maliyet tahmini
- **gpt-tokenizer** — `https://github.com/niieani/gpt-tokenizer`
  Tarayıcıda token sayımı (cl100k_base, Claude için iyi yaklaşım).
- **tiktoken (wasm)** — `https://github.com/dqbd/tiktoken`
  OpenAI tokenizer'ın resmi WASM portu.

### Öneri 41 — 👍/👎 geri bildirim
- (idb-keyval + basit toggle butonları; ek repo gerekmez.)

### Öneri 42 — Düzenle & Çalıştır
- (TipTap / EasyMDE.)

### Öneri 43 — Hazır talimat etiketleri
- (Veri dosyası; kütüphane gerekmez. Öneri 39'daki LangChain'in "PromptTemplate" sınıfı tavsiye edilir.)

### Öneri 44 — A/B karşılaştırma
- **diff** — `https://github.com/kpdecker/jsdiff`
  İki yanıt arasındaki farkı renklendirmek için.
- **diff2html** — `https://github.com/rtfpessoa/diff2html`
  Diff'i şık HTML olarak gösterir.

### Öneri 45 — Kullanım panosu
- **Chart.js** — `https://github.com/chartjs/Chart.js`
  Basit bar/line/donut chart.
- **ApexCharts** — `https://github.com/apexcharts/apexcharts.js`
  Interaktif, mobil dostu alternatif.

---

## D. Dışa Aktarma & Paylaşım

### Öneri 46 — Markdown export
- **Turndown** — `https://github.com/mixmark-io/turndown`
  HTML → Markdown.
- **marked** — `https://github.com/markedjs/marked`
  Markdown ↔ HTML.

### Öneri 47 — JSON export
- **FileSaver.js** — `https://github.com/eligrey/FileSaver.js`
  Tarayıcıda dosya kaydet (her formatta).

### Öneri 48 — CSV export
- **PapaParse** — `https://github.com/mholt/PapaParse`
  CSV parse + serialize, streaming, otomatik tip tespiti.

### Öneri 49 — PDF export
- **jsPDF** — `https://github.com/parallax/jsPDF`
  Saf JS, vector PDF üretir.
- **html2pdf.js** — `https://github.com/eKoopmans/html2pdf.js`
  DOM → PDF tek satır.
- **pdf-lib** — `https://github.com/Hopding/pdf-lib`
  Var olan PDF'leri düzenlemek için.

### Öneri 50 — Obsidian export
- **gray-matter** — `https://github.com/jonschlinkert/gray-matter`
  YAML frontmatter parse/serialize.

### Öneri 51 — Notion import
- (PapaParse + gray-matter ile çözülür; Notion'un import şeması belgelenmiş.)

### Öneri 52 — Paylaşılabilir bağlantı (hash)
- **history-api-fallback** ya da native `history.pushState` (ek repo gerekmiyor).

### Öneri 53 — QR kod
- **qrcode** — `https://github.com/soldair/node-qrcode`
  Canvas/SVG/DataURL çıkışı.
- **qr-scanner** — `https://github.com/nimiq/qr-scanner`
  QR okumak gerekirse (mobil transfer).

### Öneri 54 — Embed iframe
- (Saf HTML; ek araç gerekmez.)

### Öneri 55 — Sosyal medya paylaşımı
- **ShareButtons / share-api-polyfill** — `https://github.com/koddr/share-buttons`
  Web Share API + fallback.

---

## E. Mimari & Performans

### Öneri 56 — Service Worker / PWA
- **Workbox** — `https://github.com/GoogleChrome/workbox`
  Google'ın resmi SW kütüphanesi; cache stratejileri, precache, runtime caching.
- **vite-plugin-pwa** — `https://github.com/vite-pwa/vite-plugin-pwa`
  Build zamanında PWA üretimi (Vite kullanırsanız).

### Öneri 57 — Sanal kaydırma
- **Clusterize.js** — `https://github.com/NeXTs/Clusterize.js`
  Vanilla, 10k+ satır için ideal; 6.000 öğeli PromptVault'ta birinci öncelik.
- **virtua** — `https://github.com/inokawa/virtua`
  React/Vue/Vanilla destekli modern virtual list.
- **react-window** — `https://github.com/bvaughn/react-window`
  React tabanlı virtual list (referans olarak).

### Öneri 58 — Web Worker ile arama
- **Comlink** — `https://github.com/GoogleChromeLabs/comlink`
  Web Worker'a RPC tarzı çağrı; FlexSearch/MiniSearch worker'a taşınır.
- **threads.js** — `https://github.com/andywer/threads.js`
  Worker pool yönetimi.

### Öneri 59 — Lazy loading / code splitting
- **Vite** — `https://github.com/vitejs/vite`
  Modern build tool; dinamik `import()` ile vault başına chunk.
- **lite-vite** ya da **esbuild** — `https://github.com/evanw/esbuild`
  Saf bundler; vite tercih edilmezse.

### Öneri 60 — Sıkıştırma
- **lz-string** — `https://github.com/pieroxy/lz-string`
  localStorage uyumlu string sıkıştırma.
- **fflate** — `https://github.com/101arrowz/fflate`
  Tarayıcıda gzip/deflate, en hızlı saf JS.

### Öneri 61 — IndexedDB veritabanı
- **Dexie.js** — `https://github.com/dexie/Dexie.js` (yukarıda).
- **RxDB** — `https://github.com/pubkey/rxdb`
  Reactive, replication destekli local DB; ileride senkronizasyon için.

### Öneri 62 — Sürüm hash'i / cache busting
- **hash-files** — `https://github.com/mac-/hash-files`
  Build sırasında dosya hash'i; Vite/esbuild zaten yapar.

### Öneri 63 — i18n
- **i18next** — `https://github.com/i18next/i18next`
  Endüstri standardı, plugin ekosistemi geniş.
- **fluent.js (Mozilla)** — `https://github.com/projectfluent/fluent.js`
  ICU/MessageFormat tabanlı; çoğul/cinsiyet uyumu güçlü.
- **lingui** — `https://github.com/lingui/js-lingui`
  Tip‑güvenli, ICU mesaj formatı.

### Öneri 64 — Erişilebilirlik (a11y)
- **axe-core** — `https://github.com/dequelabs/axe-core`
  CI'da otomatik a11y testi.
- **focus-trap** — `https://github.com/focus-trap/focus-trap`
  Modal/dialog için odak yönetimi.
- **a11y-dialog** — `https://github.com/KittyGiraudel/a11y-dialog`
  Erişilebilir dialog implementasyonu.

### Öneri 65 — Responsive mobil düzen
- **Tailwind CSS** — `https://github.com/tailwindlabs/tailwindcss`
  Utility‑first responsive sınıflar.
- **Open Props** — `https://github.com/argyleink/open-props`
  CSS değişken kütüphanesi; Tailwind kullanmak istemiyorsanız.

---

## F. UI/UX Geliştirmeleri

### Öneri 66 — Hover preview (peek)
- **Tippy.js** — `https://github.com/atomiks/tippyjs`
  Şık tooltip/popover; HTML içerik destekli.
- **Floating UI** — `https://github.com/floating-ui/floating-ui`
  Tippy'nin alt katmanı; tam kontrol isterseniz.

### Öneri 67 — Tam ekran okuma modu
- (Native `requestFullscreen()`; ek repo gerekmez.)

### Öneri 68 — Sözdizimi renklendirme
- **highlight.js** — `https://github.com/highlightjs/highlight.js`
  190+ dil.
- **Prism.js** — `https://github.com/PrismJS/prism`
  Daha küçük, modüler.
- **Shiki** — `https://github.com/shikijs/shiki`
  VSCode kalitesinde renklendirme (TextMate grammar).

### Öneri 69 — Markdown render
- **marked** — `https://github.com/markedjs/marked` (yukarıda).
- **markdown-it** — `https://github.com/markdown-it/markdown-it`
  Eklenti odaklı; tablo/footnote/diagram pluginleri.
- **remark + rehype** — `https://github.com/remarkjs/remark`
  AST tabanlı; ileri seviye dönüşümler için.

### Öneri 70 — Çoklu seçim
- **selecto** — `https://github.com/daybrush/selecto`
  Drag‑to‑select bileşeni.

### Öneri 71 — Drag & drop koleksiyon
- **SortableJS** — `https://github.com/SortableJS/Sortable` (yukarıda).
- **dnd-kit** — `https://github.com/clauderic/dnd-kit`
  React tabanlı modern alternatif.

### Öneri 72 — Skeleton loader
- **react-loading-skeleton** (vanilla CSS portu kolay) — `https://github.com/dvtng/react-loading-skeleton`
- **content-loader** — `https://github.com/danilowoz/react-content-loader`
  SVG tabanlı; CSS animasyonuna kolayca taşınır.

### Öneri 73 — Breadcrumb
- (CSS + native; ek repo gerekmez. Lucide ikonları yeterli.)

### Öneri 74 — Sütun sayısı
- **Masonry** — `https://github.com/desandro/masonry`
  Esnek grid; sütun sayısı dinamik.

### Öneri 75 — Geçiş animasyonu
- **Motion One** — `https://github.com/motiondivision/motionone`
  Tarayıcı Web Animations API üstüne ince katman; FLIP animasyonları için ideal.
- **GSAP (lisans dikkat)** — `https://github.com/greensock/GSAP`
  Açık MIT modülleri var; ücretli plugin'ler hariç.

---

## G. Güvenlik & Gizlilik

### Öneri 76 — API key maskeleme
- (Saf HTML `type="password"` + toggle; ek repo gerekmez.)

### Öneri 77 — Şifreleme (AES-GCM)
- **age-encryption.org/js** — `https://github.com/FiloSottile/typage`
  Modern, basit şifreleme.
- **libsodium.js** — `https://github.com/jedisct1/libsodium.js`
  Battle‑tested kripto kütüphanesi.
- **SubtleCrypto wrapper: crypto-es** — `https://github.com/entronad/crypto-es`
  CryptoJS modern ESM portu.

### Öneri 78 — Oturum süresi
- (idb-keyval'de TTL alanı yeterli.)

### Öneri 79 — Veri temizleme
- (Native `localStorage.clear()` + `indexedDB.deleteDatabase()`.)

### Öneri 80 — İzin açıklaması
- (UI metni; repo gerekmiyor.)

---

## H. Analitik & İçgörü

### Öneri 81 — Kullanım istatistikleri
- **Umami** (self‑host) — `https://github.com/umami-software/umami`
  GDPR uyumlu analitik; istek atmak istemezseniz tamamen local kalır.
- **Plausible** (self‑host) — `https://github.com/plausible/analytics`
  Alternatif gizlilik dostu analitik.

### Öneri 82 — Etiket frekansı
- **Chart.js / ApexCharts** (yukarıda).
- **observable-plot** — `https://github.com/observablehq/plot`
  D3 tabanlı, ifadeli sözdizimi.

### Öneri 83 — İçerik uzunluğu dağılımı
- (Chart.js histogram veya `observable-plot`.)

### Öneri 84 — Çalışma süresi
- **idle-tracker** — `https://github.com/jacobk/idle-js`
  Kullanıcı aktif/pasif takibi.

### Öneri 85 — Boşluk analizi
- (Saf veri; kütüphane gerekmez.)

### Öneri 86 — Bağlantı grafiği (node graph)
- **D3.js** — `https://github.com/d3/d3`
  Force‑directed graph klasiği.
- **Cytoscape.js** — `https://github.com/cytoscape/cytoscape.js`
  Büyük graph'lar için daha optimize.
- **vis-network** — `https://github.com/visjs/vis-network`
  Kolay başlangıç.

### Öneri 87 — İlerleme çubuğu
- **NProgress** — `https://github.com/rstacruz/nprogress` (sayfa için).
- (Genel ilerleme: CSS + JS yeterli.)

### Öneri 88 — Venn diyagramı
- **venn.js** — `https://github.com/benfred/venn.js`
  D3 tabanlı Venn/Euler.

---

## I. İçerik & Veri Zenginleştirme

### Öneri 89 — Kullanıcı tarafından öğe ekleme
- **JSON Forms** — `https://github.com/eclipsesource/jsonforms` (yukarıda).
- **Ajv** — `https://github.com/ajv-validator/ajv`
  JSON Schema doğrulama; vault verisinin bütünlüğünü korur.

### Öneri 90 — Topluluk önerileri (issue/feedback)
- **giscus** — `https://github.com/giscus/giscus`
  GitHub Discussions tabanlı yorum/öneri sistemi; statik siteye uygun.
- **utterances** — `https://github.com/utterance/utterances`
  GitHub Issues tabanlı yorumlar.

### Öneri 91 — Sürüm geçmişi (undo)
- **immer** — `https://github.com/immerjs/immer`
  Immutable state ile geçmişi kolay yönetir.
- **yjs** — `https://github.com/yjs/yjs`
  CRDT; ileride çoklu cihaz/kullanıcı senkronizasyonu istenirse.

### Öneri 92 — İçerik kalite skoru
- **textstat** (Python — referans) / vanilla JS portu **text-readability** — `https://github.com/clearnote01/readability`
  Okunabilirlik / uzunluk / yoğunluk metrikleri.

### Öneri 93 — Otomatik etiket önerisi
- (transformers.js + Anthropic API — öneri 10 ve 31 ile aynı katman.)

### Öneri 94 — Kaynak zenginleştirme
- **microlink.io openlibs** — `https://github.com/microlinkhq/metascraper`
  URL → açık metadata (başlık, yazar, görsel).

### Öneri 95 — Çeviri
- (Anthropic API doğrudan.)
- **bergamot-translator** — `https://github.com/browsermt/bergamot-translator`
  Tarayıcıda yerel makine çevirisi (Firefox kullanıyor).

---

## J. Geliştirici & Güç Kullanıcısı

### Öneri 96 — CLI / JSON endpoint modu
- **json-server** — `https://github.com/typicode/json-server`
  Vault verisinden anında REST API; geliştirme/test için altın değerinde.
- **Hono** — `https://github.com/honojs/hono`
  Edge runtime'larda ultra hızlı API; Cloudflare Workers/Deno deploy için.

### Öneri 97 — Webhook entegrasyonu
- **Svix Webhooks** — `https://github.com/svix/svix-webhooks`
  Imzalı webhook gönderimi (HMAC, retry, dead letter).
- **n8n** — `https://github.com/n8n-io/n8n`
  Self‑host workflow automation; vault → Discord/Slack/Notion otomasyonu.
- **node-RED** — `https://github.com/node-red/node-red`
  Görsel workflow; webhook akışları için klasik.
- **smee.io client** — `https://github.com/probot/smee-client`
  Webhook'u localhost'a aktaran proxy; geliştirme aşamasında çok faydalı.

### Öneri 98 — Özel CSS / kullanıcı temaları
- **prism-themes** — `https://github.com/PrismJS/prism-themes` (örnek koleksiyon).
- **starlight-themes** ya da CSS değişken referansı — kullanıcı snippet'i için pencere yeterli.

### Öneri 99 — Makro / kısayol kaydedici
- **rrweb** — `https://github.com/rrweb-io/rrweb`
  DOM aksiyonlarını kaydet/oynat; makro motorunun çekirdeği olabilir.
- **TestCafe / Playwright codegen referansı** — kullanıcı eylemini koda dökme örüntüsü için.

### Öneri 100 — OmniVault köprüsü
- **trpc** — `https://github.com/trpc/trpc`
  Tip‑güvenli vault‑arası RPC.
- **GraphQL Yoga** — `https://github.com/dotansimha/graphql-yoga`
  Vault'lar arası federated sorgular için.
- **Apollo Federation** — `https://github.com/apollographql/federation`
  Olgun federation katmanı.

---

## K. Vault‑Özel Domain Repo'ları

Aşağıdaki repo'lar, ilgili vault'un **içeriğine** özel teknik altyapı sağlar (çalıştırma, simülasyon, doğrulama).

| # | Vault | Repo Önerisi | Ne için |
|---|-------|--------------|---------|
| 03 | TestVault | **vitest** — `https://github.com/vitest-dev/vitest` | Vault verisi üzerinde unit/property test |
| 04 | AgentVault | **autogen** — `https://github.com/microsoft/autogen` | Multi‑agent örüntüleri referansı |
| 13 | ChainVault | **LangChain.js** — `https://github.com/langchain-ai/langchainjs` | Zincir tanımı/çalıştırma |
| 16 | WasmVault | **wabt** — `https://github.com/WebAssembly/wabt` | WAT↔WASM dönüşüm |
| 17 | EngineVault | **PlayCanvas** — `https://github.com/playcanvas/engine` | Tarayıcı oyun motoru referansı |
| 18 | ChessVault | **chess.js** — `https://github.com/jhlywa/chess.js` + **chessboard.js** — `https://github.com/oakmac/chessboardjs` | Hamle doğrulama + tahta UI |
| 19 | GodotVault | **godot-docs** — `https://github.com/godotengine/godot-docs` | Resmi dokümantasyon kaynağı |
| 22 | DialogVault | **inkjs** — `https://github.com/y-lohse/inkjs` | Interaktif diyalog motoru |
| 25 | ShaderVault | **glslCanvas** — `https://github.com/patriciogonzalezvivo/glslCanvas` + **lygia shader library** — `https://github.com/patriciogonzalezvivo/lygia` | GLSL canlı önizleme |
| 27 | PhysicsVault | **Rapier.js** — `https://github.com/dimforge/rapier.js` ya da **matter-js** — `https://github.com/liabru/matter-js` | 2D/3D fizik simülasyonu |
| 28 | AssetVault | **three.js** — `https://github.com/mrdoob/three.js` | 3D asset önizleme |
| 38 | EtymologyVault | **wiktionary-data dumps** + **wikiparse** — `https://github.com/wikimedia/parsoid` | Köken verisi doğrulama |
| 47 | AegisVault | **OWASP cheat-sheet-series** — `https://github.com/OWASP/CheatSheetSeries` | Güvenlik içerik referansı |
| 49 | SecVault | **trivy** — `https://github.com/aquasecurity/trivy` | Bağımlılık güvenlik taraması |
| 50 | DeployVault | **Coolify** — `https://github.com/coollabsio/coolify` veya **Dokploy** — `https://github.com/Dokploy/dokploy` | Self‑host PaaS örneği |
| 51 | RegexVault | **regex101 backend ref** + **vscode-regex-previewer** kütüphanesi | Canlı regex test |
| 52 | CronVault | **cronstrue** — `https://github.com/bradymholt/cronstrue` + **node-cron** — `https://github.com/node-cron/node-cron` | Cron parse + insan dili açıklama |
| 53 | LogVault | **pino** — `https://github.com/pinojs/pino` + **OpenTelemetry-JS** — `https://github.com/open-telemetry/opentelemetry-js` | Yapısal log + tracing |
| 54 | CloudVault | **Terraform** — `https://github.com/hashicorp/terraform` + **Pulumi** — `https://github.com/pulumi/pulumi` | IaC referansları |
| 55 | APIVault | **OpenAPI/Swagger UI** — `https://github.com/swagger-api/swagger-ui` + **Scalar** — `https://github.com/scalar/scalar` | API dokümantasyon UI |
| 56 | DBVault | **Prisma** — `https://github.com/prisma/prisma` + **Drizzle ORM** — `https://github.com/drizzle-team/drizzle-orm` | ORM örnekleri |
| 60 | GitVault | **isomorphic-git** — `https://github.com/isomorphic-git/isomorphic-git` | Tarayıcıda git işlemleri |
| 61 | AutoVault | **n8n** — `https://github.com/n8n-io/n8n` + **Activepieces** — `https://github.com/activepieces/activepieces` | Otomasyon platformları |
| 62 | ObsiVault | **obsidian-releases** — `https://github.com/obsidianmd/obsidian-releases` | Plugin ekosistemi referansı |
| 67 | BudgetVault | **maybe-finance** — `https://github.com/maybe-finance/maybe` veya **Actual Budget** — `https://github.com/actualbudget/actual` | Kişisel finans referans uygulaması |
| 68 | EcomVault | **Medusa.js** — `https://github.com/medusajs/medusa` | Headless ecommerce çekirdeği |
| 69 | MealVault | **TheMealDB-data** + **TandoorRecipes** — `https://github.com/TandoorRecipes/recipes` | Tarif veri/yönetim |
| 70 | MailVault | **Mautic** — `https://github.com/mautic/mautic` veya **listmonk** — `https://github.com/knadh/listmonk` | E‑posta kampanya referansı |
| 71 | SocialVault | **Mastodon API client: megalodon** — `https://github.com/h3poteto/megalodon` | Sosyal API entegrasyonu |
| 74 | ScrapVault | **Crawlee** — `https://github.com/apify/crawlee` + **Playwright** — `https://github.com/microsoft/playwright` | Modern web scraping |
| 76 | PWAVault | **Workbox** — `https://github.com/GoogleChrome/workbox` (yukarıda) | PWA örnekleri |
| 77 | UI/UXVault | **storybook** — `https://github.com/storybookjs/storybook` | Bileşen kütüphanesi |
| 78 | CryptoVault | **ccxt** — `https://github.com/ccxt/ccxt` | 100+ borsa API |
| 79 | BioVault | **biopython‑js / bioinformatics-tools listesi** — `https://github.com/danielecook/Awesome-Bioinformatics` | İçerik referans listesi |
| 81 | MedVault | **OHDSI / OMOP** — `https://github.com/OHDSI` | Sağlık veri standartları |
| 82 | LinguaVault | **compromise** — `https://github.com/spencermountain/compromise` | Tarayıcı içi NLP |
| 83 | MathVault | **KaTeX** — `https://github.com/KaTeX/KaTeX` + **MathJax** — `https://github.com/mathjax/MathJax` | LaTeX render |
| 84 | StatVault | **simple-statistics** — `https://github.com/simple-statistics/simple-statistics` + **danfo.js** — `https://github.com/javascriptdata/danfojs` | Tarayıcıda istatistik / dataframe |
| 85 | IoTVault | **MQTT.js** — `https://github.com/mqttjs/MQTT.js` | Cihaz mesajlaşma altyapısı |
| 87 | ARVault | **AR.js** — `https://github.com/AR-js-org/AR.js` + **MindAR** — `https://github.com/hiukim/mind-ar-js` | Tarayıcı AR |
| 88 | VRVault | **A-Frame** — `https://github.com/aframevr/aframe` | WebXR / VR çerçevesi |
| 89 | EcoVault | **OurWorldInData / covid-19-data** — `https://github.com/owid` | Açık çevre verisi |
| 91 | PhiloVault | **PhilPapers OAI export** + **Project Gutenberg-tools** | Kaynak metin sağlayıcılar |
| 92 | InvestVault | **OpenBB** — `https://github.com/OpenBB-finance/OpenBB` | Yatırım veri altyapısı |
| 93 | ReelVault | **ffmpeg.wasm** — `https://github.com/ffmpegwasm/ffmpeg.wasm` | Tarayıcıda video işleme |
| 94 | EventVault | **ICS.js** — `https://github.com/nwcell/ics.js` | iCalendar export |
| 95 | AstroVault | **astronomy-engine** — `https://github.com/cosinekitty/astronomy` | Astronomi hesaplama |
| 96 | AgriVault | **Open-Meteo** — `https://github.com/open-meteo/open-meteo` + **OpenAg-data** | Tarım/hava verisi |
| 97 | FormatVault | **Prettier** — `https://github.com/prettier/prettier` + **Biome** — `https://github.com/biomejs/biome` | Format motoru referansı |
| 98 | TurkVault | **zemberek-nlp** — `https://github.com/ahmetaa/zemberek-nlp` | Türkçe doğal dil işleme |
| 99 | ResumeVault | **JSON Resume** — `https://github.com/jsonresume/resume-schema` + **reactive-resume** — `https://github.com/AmruthPillai/Reactive-Resume` | CV şema + üretim referansı |
|100 | PitchVault | **reveal.js** — `https://github.com/hakimel/reveal.js` veya **slidev** — `https://github.com/slidevjs/slidev` | Pitch deck üretimi |

---

## L. Webhook & Veri Çekme Altyapısı

> "Webhook yöntemiyle veya benzeri veri çekeceğiz" notunuza özel: tüm 100 vault'a **dışarıdan veri besleme** için olgun açık kaynak yığını.

### Webhook gönder/al
- **Svix** — `https://github.com/svix/svix-webhooks` (imzalı, retry'lı webhook).
- **smee-client** — `https://github.com/probot/smee-client` (geliştirme tüneli).
- **webhookrelay docs** — referans (open core).

### Otomasyon orkestratörü
- **n8n** — `https://github.com/n8n-io/n8n`
- **Activepieces** — `https://github.com/activepieces/activepieces`
- **Windmill** — `https://github.com/windmill-labs/windmill`
- **Node-RED** — `https://github.com/node-red/node-red`
- **Huginn** — `https://github.com/huginn/huginn`

### Veri çekme / scraping
- **Crawlee** — `https://github.com/apify/crawlee`
- **Playwright** — `https://github.com/microsoft/playwright`
- **Puppeteer** — `https://github.com/puppeteer/puppeteer`
- **Cheerio** — `https://github.com/cheeriojs/cheerio`
- **Readability.js** — `https://github.com/mozilla/readability` (makale temizleme).

### Veri normalize/şema
- **Ajv** — `https://github.com/ajv-validator/ajv`
- **Zod** — `https://github.com/colinhacks/zod`
- **JSON Schema** — `https://github.com/json-schema-org/json-schema-spec`

### Job/queue / arka plan
- **BullMQ** — `https://github.com/taskforcesh/bullmq` (Redis tabanlı kuyruk).
- **graphile-worker** — `https://github.com/graphile/worker` (Postgres tabanlı).

### Self‑host backend hızlı kurulum
- **PocketBase** — `https://github.com/pocketbase/pocketbase` (tek dosya; auth + realtime + DB).
- **Supabase** — `https://github.com/supabase/supabase` (Postgres + REST + Auth).
- **Appwrite** — `https://github.com/appwrite/appwrite`.
- **Directus** — `https://github.com/directus/directus` (mevcut DB üstüne anında API + admin UI).

### Senkronizasyon / CRDT
- **Yjs** — `https://github.com/yjs/yjs`
- **Automerge** — `https://github.com/automerge/automerge`
- **ElectricSQL** — `https://github.com/electric-sql/electric` (Postgres → local sync).

### Statik veri API'leri
- **GitHub raw + Octokit** — `https://github.com/octokit/octokit.js` (vault verisini GitHub repo'sundan çekme).
- **Nocodb** — `https://github.com/nocodb/nocodb` (Airtable benzeri açık kaynak).

---

## M. Kurulum Önceliği & Yol Haritası

| Faz | Süre | Repo Setı | Çıktı |
|-----|------|-----------|-------|
| **F1 — Hızlı kazanım** | 1 hafta | Fuse.js, Mousetrap, idb-keyval, Clusterize.js, marked, highlight.js, Workbox | Öneri 1, 16, 27, 57, 56, 68, 69 hızlı çözüldü |
| **F2 — AI altyapı** | 1–2 hafta | Anthropic SDK + eventsource-parser, gpt-tokenizer, Handlebars, p-queue, LangChain.js, assistant-ui | Öneri 31, 32, 34, 38, 39, 40, 44 |
| **F3 — Veri & dışa aktarım** | 1 hafta | Dexie, PapaParse, FileSaver, html2pdf, gray-matter, Turndown | Öneri 17, 46–51 |
| **F4 — Performans & PWA** | 1–2 hafta | Vite, vite‑plugin‑pwa, Workbox runtime, Comlink, FlexSearch, lz-string | Öneri 11, 56, 58, 59, 60 |
| **F5 — UX & a11y & i18n** | 2 hafta | Tailwind, Floating UI, Tippy, focus-trap, axe-core, i18next, Motion One | Öneri 64, 65, 66, 75, 63 |
| **F6 — Analitik & graf** | 1 hafta | Chart.js, Cytoscape.js, observable-plot, venn.js | Öneri 81, 82, 86, 88 |
| **F7 — Webhook & otomasyon** | 2 hafta | Svix, n8n (self‑host), PocketBase/Supabase, BullMQ, Crawlee | Öneri 97 + tüm dış veri besleme |
| **F8 — Federation / cross‑vault** | 3+ hafta | trpc / GraphQL Yoga + Federation, RxDB/ElectricSQL | Öneri 100 OmniVault köprüsü |
| **F9 — Domain enriching** | sürekli | K. tablosundaki vault‑özel repo'lar | Her vault'a kendi alanına özel çalıştırma/önizleme |

---

## Hızlı CDN/Bundle Notları

- Hemen denemek için çoğu repo `unpkg.com/<paket>` veya `cdn.jsdelivr.net/npm/<paket>` üzerinden anında `<script>` ile yüklenebilir.
- Üretim için bundler (Vite) + bağımlılık ağacı zorunludur (özellikle LangChain, transformers.js, ffmpeg.wasm gibi ağır paketler).
- Vault başına lazy load: `dynamic import()` ile sadece kullanan vault'un kütüphanesini yükleyin (12MB PromptVault'unuzu yavaşlatmaması için kritik).

---

## Toplam Sayım

- **A–J önerilere bağlı repo:** ~85
- **K. vault‑özel domain:** ~55
- **L. webhook/veri çekme:** ~25
- **Bazı repo'lar birden fazla öneride paylaşıldığı için benzersiz repo sayısı: 130+**

İhtiyacınız olursa bir sonraki adım olarak şu seçenekleri öneririm:
1. Faz 1'deki 7 paketi tek bir `vendor.js` bundle olarak hazırlamak.
2. Webhook altyapısı için bir n8n + PocketBase docker‑compose iskeleti üretmek.
3. Her vault için K. tablosundaki repo'yu vault HTML'ine entegre eden minimal patch'ler.

Hangisiyle devam edelim?
