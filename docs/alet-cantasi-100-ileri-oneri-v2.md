# Alet Çantası — 100+ İleri Düzey Teknik Geliştirme Önerisi (v2)

> **Bağlam:** Bu dosya, **100 vault uygulaması + index.html** projesinin mevcut iki dokümanına (`alet-cantasi-100-oneri.md` ve `alet-cantasi-100-repo-onerisi.md`) **ek katman** olarak hazırlandı.
> **Amaç:** İlk dosyadaki 100 önerinin **ötesinde**, 2025–2026 dönemine ait güncel araştırma, GitHub trendleri ve Reddit (r/LocalLLaMA, r/selfhosted, r/PromptEngineering) tartışmalarından beslenen **100+ yeni, derinleştirilmiş ve daha ileri** teknik öneri.
> **Tarih:** 2026-06 · **Hedef kitle:** "Alet Çantası"nı kurumsal/araştırma seviyesine taşımak isteyen geliştirici.
> **Felsefe:** *Local-first, privacy-first, AI-native, zero-server.* Mevcut HTML+JS mimarisini bozmadan, kademeli olarak entegre edilebilir parçalar.

---

## 📚 İçindekiler

- [N. Tarayıcı-İçi AI Çıkarım Katmanı (101–115)](#n-tarayıcı-içi-ai-çıkarım-katmanı)
- [O. Local-First & Sync Mimarisi (116–127)](#o-local-first--sync-mimarisi)
- [P. MCP & Agent Entegrasyonu (128–138)](#p-mcp--agent-entegrasyonu)
- [Q. RAG ve Vektör Altyapısı (139–149)](#q-rag-ve-vektör-altyapısı)
- [R. Multi-Provider Routing & Maliyet (150–158)](#r-multi-provider-routing--maliyet)
- [S. Güvenlik & Tehdit Modeli (159–169)](#s-güvenlik--tehdit-modeli)
- [T. Gelişmiş UI/UX Paradigmaları (170–181)](#t-gelişmiş-uiux-paradigmaları)
- [U. Veri Mimarisi & Performans (182–192)](#u-veri-mimarisi--performans)
- [V. İçerik Zenginleştirme & Yapılandırılmış Çıktı (193–202)](#v-içerik-zenginleştirme--yapılandırılmış-çıktı)
- [W. Topluluk, Açık Kaynak & Sürdürülebilirlik (203–212)](#w-topluluk-açık-kaynak--sürdürülebilirlik)
- [X. Yol Haritası ve Öncelik Matrisi](#x-yol-haritası-ve-öncelik-matrisi)
- [Y. Referans Kaynaklar](#y-referans-kaynaklar)

---

## N. Tarayıcı-İçi AI Çıkarım Katmanı

> Anthropic API artık tek seçenek olmamalı. 2025'te WebGPU + WebLLM olgunlaştı; bazı görevler ücretsiz, gizli ve çevrimdışı yapılabilir hale geldi.

### 101 — WebLLM ile çevrimdışı sohbet
`@mlc-ai/web-llm` ile **Llama 3.2 / Qwen 2.5 / Phi-3.5** modelleri tarayıcıda çalıştırılır. API anahtarı yokken bile "Çalıştır" butonu işlevsel olur. Mevcut öneri 31'in **anahtarsız fallback** yolu.
→ Repo: `mlc-ai/web-llm` · Demo: [webllm.mlc.ai](https://webllm.mlc.ai/)

### 102 — Transformers.js v4 ile embedding üretimi (öneri 10'un derinleştirilmesi)
`Xenova/all-MiniLM-L6-v2` (90 MB) veya `Snowflake/snowflake-arctic-embed-xs` (33 MB) modelleri ile **API'siz semantik arama**. Embedding'ler IndexedDB'de cache'lenir; bir defa hesaplanır.
→ Repo: `huggingface/transformers.js`

### 103 — Whisper Turbo ile tarayıcıda sesli arama
Mevcut öneri 5 yalnızca Web Speech API'ye dayanıyor. `whisper-large-v3-turbo` (WebGPU, 809M parametre) sesleri **çevrimdışı** transkribe eder; özellikle TR/AR diller için doğruluk çok daha yüksek.
→ Demo: [Xenova/realtime-whisper-webgpu](https://huggingface.co/spaces/Xenova/realtime-whisper-webgpu)

### 104 — Web Stable Diffusion ile "kapak görseli" üretimi
Her vault için bir **otomatik tematik kapak görseli** üretimi (tamamen tarayıcıda, harici API'siz). Koleksiyonların görsel kimliği oluşur.
→ Repo: `mlc-ai/web-stable-diffusion`

### 105 — TinyLlama tabanlı yerel sınıflandırıcı
Yeni eklenen bir öğeyi otomatik **etiketleyen** ve kategoriye yerleştiren küçük model (~600 MB). Öneri 93'ün (otomatik etiket önerisi) API'siz versiyonu.

### 106 — Hibrit çıkarım stratejisi (router pattern)
Sorgu uzunluğu ve karmaşıklığına göre **lokal model ↔ Anthropic API** arasında otomatik geçiş yapan akıllı yönlendirici. Kısa özetler lokal, derin akıl yürütme Claude.

### 107 — Model indirme yöneticisi
Modellerin indirilme ilerlemesi, IndexedDB OPFS kullanımı, "modeli sil" butonu içeren mini panel. Tarayıcı 1–4 GB model dosyası tutabiliyor, bu açıkça yönetilmeli.

### 108 — Token streaming "yazıyor" efekti
`eventsource-parser` ile Anthropic SSE yanıtlarını parçalayıp **karakter-karakter** UI'a yazdırma. Mevcut öneri 31'in CLI hissi yerine ChatGPT benzeri akış.

### 109 — Prompt template önizleme (canlı render)
`${değişken}` yer tutucuları kullanıcı yazarken sağ panelde **canlı olarak doldurulmuş prompt** gösterir. JSON Schema → form otomasyonu (öneri 32'nin yapılandırılmış hali).
→ Repo: `eclipsesource/jsonforms`

### 110 — Constrained decoding (JSON Schema zorlaması)
Bir vault öğesi `outputSchema: {...}` taşıyabilsin. API çağrısı `response_format: { type: "json_schema", schema: {...} }` ile yapılır. Yanıtın **garantili JSON** olması sağlanır.

### 111 — Tool use / function calling desteği
Vault öğeleri `tools: [{ name, input_schema }]` tanımlayabilsin. Anthropic'in tool use API'si ile öğeler **çalıştırılabilir araç** haline gelir.

### 112 — Vision (görsel girdi) desteği
PromptVault'taki bazı promptlar görsel ister. Kullanıcı detay panelinde resim yapıştırabilsin (Ctrl+V), Claude Vision'a base64 olarak gönderilsin.

### 113 — Prompt caching otomatik tetiklemesi
Anthropic'in `cache_control` özelliğini kullanarak uzun sistem promptları **%90 ucuz** çalıştırma. 1024+ token üzerindeki içeriklere otomatik cache marker ekleme.
→ [Anthropic Prompt Caching docs](https://platform.claude.com/docs/build-with-claude/prompt-caching)

### 114 — Extended thinking (reasoning) toggle
Claude Sonnet 4.6 / Opus 4.6 için **thinking budget** kaydırıcısı (1k–64k token). Karmaşık vault öğelerinde akıl yürütme adımları görünür kılınır.

### 115 — Local model benchmarking sekmesi
Aynı promptu farklı yerel modellere gönderip latency / kalite (kullanıcı oyu) toplayan mini benchmark; hangi modelin hangi vault'a uygun olduğunu kullanıcı kendisi keşfeder.

---

## O. Local-First & Sync Mimarisi

> Mevcut localStorage tabanlı yaklaşım 5 MB sınırında patlar. Local-first hareketinin 2025'teki olgunlaşması bu projeyi domine etmeli.

### 116 — Yjs ile koleksiyon CRDT'si
Koleksiyonlar, notlar, favoriler `Y.Map` / `Y.Array` olarak tutulur. **Çakışmasız birleşme** garantili — birden fazla cihazda eşitlemeye hazır.
→ Repo: `yjs/yjs`

### 117 — Automerge ile yerel-önce dokümanlar
Kişisel notlar (öneri 18) `Automerge.Doc` olarak. **Tüm geçmiş** otomatik saklanır; öneri 91 (sürüm geçmişi) ücretsiz gelir.
→ Repo: `automerge/automerge`

### 118 — y-indexeddb ile yerel kalıcılık
Yjs dokümanları otomatik olarak IndexedDB'ye yazılır. Sayfa kapansa bile state korunur.

### 119 — y-webrtc ile peer-to-peer eşitleme
Aynı odadaki kullanıcılar **sunucusuz** olarak koleksiyon paylaşır. Sınıf ortamı için ideal: öğretmen vault önerir, öğrenciler anında alır.

### 120 — Liveblocks veya y-websocket opsiyonel relay
Şirket içi senkronizasyon isteyenler için minimal relay server (Cloudflare Durable Objects üzerinde 10 satır).

### 121 — OPFS tabanlı vault önbelleği
Vault HTML dosyaları **Origin Private File System**'e yazılır. Tekrar açılışlarda 100× daha hızlı yükleme. Çevrimdışı tam destek.
→ [web.dev/articles/origin-private-file-system](https://web.dev/articles/origin-private-file-system)

### 122 — wa-sqlite ile relasyonel sorgular
6.000+ öğeli PromptVault'ta `SELECT * FROM items WHERE tags LIKE '%persona%' ORDER BY rating` gibi sorgular. SQL gücünü tarayıcıya getirir.
→ Repo: `rhashimoto/wa-sqlite`

### 123 — DuckDB-WASM ile analitik (öneri 81–88'in derinleştirilmesi)
Tüm kullanım analitiği DuckDB üzerinde **Parquet** olarak tutulur. Pivot, window function, JOIN'ler tarayıcıda anlık çalışır.
→ Repo: `duckdb/duckdb-wasm`

### 124 — Replicache / Triplit gibi sync engine entegrasyonu
İleride bulut senkronizasyonu istenirse, mevcut local-first yapıdan **kopmadan** scale-up yolu. Mimaride bu boşluğu bırakmak önemli.

### 125 — Dexie Cloud (opsiyonel) ile multi-device
Premium kullanıcılar için Dexie Cloud (E2EE destekli) ile cihazlar arası favori/koleksiyon eşitleme.
→ Repo: `dexie/Dexie.js`

### 126 — Dosya dışa/içe alma ile manuel sync (zero-trust)
Tüm kullanıcı verisini **tek `.alet` dosyası** (gzipped JSON + CRDT history) olarak indir/yükle. Sunucu yok, manuel taşıma.

### 127 — Konflikt çözümü görselleştirici
İki cihazdan gelen değişiklikler çakıştığında, kullanıcıya hangi versiyon ne içerir görselleştiren mini diff arayüzü.

---

## P. MCP & Agent Entegrasyonu

> Model Context Protocol Kasım 2024'te Anthropic tarafından açıklandı, 2025 boyunca standart haline geldi. Alet Çantası'nın **MCP sunucusu** olarak konumlanması büyük fırsat.

### 128 — Alet Çantası'nı MCP server yapma
Tüm 100 vault, MCP `resources` ve `tools` olarak yayınlansın. Claude Desktop, Cursor, Zed bu vault'ları **doğrudan** kullanabilsin. Proje değeri 100×'e fırlar.
→ [modelcontextprotocol.io](https://modelcontextprotocol.io)

### 129 — `aletcantasi-mcp` npm paketi
`npx -y aletcantasi-mcp` ile çalışan minimal MCP stdio server. Claude Desktop config'e tek satırla eklenir.

### 130 — MCP `prompts` ile prompt vault'u
PromptVault'taki 6000+ prompt MCP'nin `prompts/list` ve `prompts/get` API'leriyle yayınlanır. Kullanıcı Claude'da `/prompt jailbreak-evaluator` yazar.

### 131 — MCP `tools` ile çalıştırılabilir vault öğeleri
ChainVault zincirleri MCP tool olarak. Claude bir görevde `aletcantasi.run_chain('research_outline')` çağırabilir.

### 132 — MCP Inspector entegrasyonu
Geliştiriciler için debug paneli; tüm MCP istek/yanıtları log'lar.
→ Repo: `modelcontextprotocol/inspector`

### 133 — Browser-tabanlı MCP client (deneysel)
WebContainers veya WebWorker üzerinde basit MCP client. Vault'tan vault'a tool çağırma index.html'de mümkün hale gelir.

### 134 — Agent loop (basit ReAct)
Bir vault öğesi `loop: true` taşıdığında, model her döngüde **bir araç** kullanarak hedefe ilerler. Mini-LangGraph davranışı.
→ Repo: `langchain-ai/langgraphjs`

### 135 — Sub-agent spawn (Claude'un yeni özelliği)
Karmaşık vault öğeleri (örn. "Tam stack uygulama tasarla") sub-agent'lara dağıtılır. Anthropic'in Claude Code paradigması.

### 136 — Code execution sandbox (MCP code execution)
Anthropic'in Kasım 2025'te tanıttığı **code execution with MCP**: Pyodide içinde, vault'tan gelen kod denenir, sonuç döner.
→ Repo: `pyodide/pyodide`

### 137 — Tool result streaming
Tool çıktıları (uzun belge analizleri vb.) streaming olarak UI'a aktarılır. Agent loop'ta sabırsızlık azalır.

### 138 — Agent memory (kalıcı bağlam)
Her agent koşusu, koleksiyon kapsamında bir **memory store**'a yazar. Sonraki koşular bu hafızadan beslenir. Yjs Map ile implementasyon.

---

## Q. RAG ve Vektör Altyapısı

> Mevcut öneri 10 (semantik arama) tek başına yetmez. 2025'te tam RAG pipeline'ları olgunlaştı, tarayıcıda mümkün hale geldi.

### 139 — MeMemo benzeri client-side RAG
Tüm vault içerikleri tarayıcıda embedding'lenir, HNSW indeksinde ANN search yapılır. Hiçbir sunucu yok.
→ Repo: `poloclub/mememo`

### 140 — hnswlib-wasm ile ANN
6000+ öğede milisaniyeler içinde top-K en yakın komşu. Cosine, L2, IP metrikleri.
→ Repo: `ChromaCorp/hnswlib-wasm`

### 141 — Hybrid search (BM25 + vektör)
Anahtar kelime maçı (MiniSearch) ve semantik benzerlik puanlarını **birleştiren** RRF (Reciprocal Rank Fusion) skorlaması. State-of-the-art RAG retrieval.

### 142 — Reranker katmanı
İlk N sonuç (örn. 50) bir cross-encoder reranker'dan (`Xenova/ms-marco-MiniLM-L-6-v2`) geçer; en alakalı 10 üste çıkar. Kalite belirgin yükselir.

### 143 — Chunking stratejileri (her vault için)
Uzun `content` alanları **paragraf** / **cümle** / **token** bazında chunk'lanır. Embedding kalitesi artar. LangChain TextSplitter portu.

### 144 — Cloudflare Vectorize opsiyonel sync
Premium kullanıcılar Vectorize free tier'a (5M vektör/ay) embedding'lerini yedekler. Cihaz değiştiğinde anında geri yükleme.

### 145 — Chroma Embedded mode
Daha güçlü makinelerde lokal Chroma DB. Çoklu koleksiyon, metadata filter, where clause.
→ Repo: `chroma-core/chroma`

### 146 — Embedding visualization (UMAP/t-SNE)
Tüm vault'un embedding uzayı 2D'de gösterilir. Kullanıcı semantik kümeleri **görsel olarak** keşfeder. Knowledge graph'ın daha az heyecan verici ama daha bilgilendirici versiyonu.

### 147 — Soru-yanıt RAG modu
Kullanıcı "Bu vault'ta jailbreak savunması nasıl yapılır?" yazar; retrieved öğeler birleştirilip Claude'a gönderilir, atıflı yanıt döner.

### 148 — Embedding cache key versioning
Embedding modeli değiştiğinde tüm cache invalidate olmalı: `cache_key = model_id + content_hash`. Sessiz hatalar engellenir.

### 149 — Few-shot example retriever
Kullanıcı bir prompt yazıyor; vault'tan **benzer 3 örnek** otomatik bulunup few-shot olarak prompt'a iliştirilir. Kalite kendi-kendine zenginleşir.

---

## R. Multi-Provider Routing & Maliyet

> Tek Anthropic'e bağımlılık kırılganlıktır. Açık kaynak rotacılar 2025'te olgun.

### 150 — OpenRouter desteği
Tek API key ile **Claude + GPT-4o + Gemini 2.5 + Llama 3.3 + Mistral**. Fallback ve fiyat-optimum routing.
→ [openrouter.ai](https://openrouter.ai)

### 151 — LiteLLM proxy (self-host opsiyonu)
Şirket içi kullanıcılar için LiteLLM ile 100+ sağlayıcıya tek arayüzden erişim, **kullanım izleme** dahil.
→ Repo: `BerriAI/litellm`

### 152 — Sağlayıcı sağlık kontrolü
Anthropic rate limit aldığında otomatik olarak OpenRouter veya Groq'a düşer. Kullanıcı kesintiyi hissetmez.

### 153 — Token tokenizer farklılığı uyarısı
Aynı içerik Claude'da 1200, GPT'de 1450 token olabilir. Mevcut öneri 40'ın çoklu-tokenizer versiyonu.
→ Repo: `dqbd/tiktoken`, `anthropic-tokenizer`

### 154 — Maliyet bütçesi & hard stop
Kullanıcı "Bu ay $5 limit" tanımlar. Limit aşıldığında API çağrıları durdurulur, uyarı gösterilir.

### 155 — Semantic cache (GPTCache prensibi)
Daha önce sorulan **anlamsal olarak benzer** soruların yanıtları cache'lenir. Aynı şeyi tekrar sormak ücretsiz olur.
→ Repo: `zilliztech/gptcache`

### 156 — Prompt caching dashboard
Hangi cache'ler vuruldu, ne kadar tasarruf? Anthropic prompt caching kullanımına özel panel.

### 157 — Free-tier (Groq, Together) dengeleyici
Düşük kaliteli görevler (etiket önerisi, kısa özet) ücretsiz Groq / Cerebras / Together free tier'a yönlendirilir.

### 158 — A/B otomatik kalite ölçümü
Aynı prompt 3 farklı modele paralel gider; kullanıcı **kör test** ile en iyiyi oylar. Zamanla kişisel "favorim" modeli öğrenilir.

---

## S. Güvenlik & Tehdit Modeli

> Mevcut G bölümü 5 madde ile yetersiz. AI uygulamaları yeni saldırı yüzeyleri açtı.

### 159 — Prompt injection defansı
Vault dışı kaynaklı içerikler (kullanıcı notları, web alıntıları) **delimited** edilir: `<untrusted_user_content>...</untrusted_user_content>`. Sistem promptu net ayrılır.
→ [OWASP LLM Prompt Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html)

### 160 — Output sanitization (XSS)
LLM yanıtları doğrudan `innerHTML` yazılmamalı. DOMPurify ile temizlik. Markdown render'da `target="_blank" rel="noopener"`.
→ Repo: `cure53/DOMPurify`

### 161 — CSP (Content Security Policy) sertleştirme
Vault HTML'leri sıkı CSP ile yüklenir: `script-src 'self'`, `connect-src api.anthropic.com`. Üçüncü taraf script enjeksiyonu engellenir.

### 162 — Iframe sandbox ile vault izolasyonu
Her vault `<iframe sandbox="allow-scripts allow-same-origin">` içinde. Bir vault diğerinin localStorage'ına erişemez.

### 163 — API key in-memory only opsiyonu
"Bu sekmede unut" modu: API key sayfa kapanınca silinir. localStorage'a hiç yazılmaz. Paranoyak kullanıcılar için.

### 164 — WebCrypto AES-GCM ile key vault
API key'i **non-extractable** CryptoKey olarak generate edilir, IndexedDB'de tutulur. Bellek dökümü saldırısı bile zorlaşır.
→ [W3C Web Cryptography Level 2](https://www.w3.org/TR/webcrypto-2/)

### 165 — Veri sızıntısı tespiti
Kullanıcının kopyaladığı içerik API key, SSH key, JWT içeriyor mu? Heuristik regex taraması ve uyarı.

### 166 — Çıktı içerik filtresi
LLM yanıtı PII, kötü amaçlı URL, telefon numarası içeriyor mu? Microsoft Presidio benzeri client-side filtre.

### 167 — Subresource Integrity (SRI)
Tüm CDN script'leri `integrity="sha384-..."` ile yüklenir. Tedarik zinciri saldırılarına karşı.

### 168 — Permissions Policy header
Tarayıcı API'lerine sıkı izin: `geolocation=(), microphone=(self)`. Hash route üzerinden saldırı yüzeyini daraltır.

### 169 — Tehdit modeli dokümantasyonu
`SECURITY.md` ile: aktör → varlık → saldırı yüzeyi → savunma matrisi. Açık kaynak güveni artırır.

---

## T. Gelişmiş UI/UX Paradigmaları

> Mevcut F bölümünün ötesi: 2025'te kullanıcıların alıştığı yeni mental modeller.

### 170 — `cmd+k` command palette
Tek tuşla her şeyi: vault değiştir, öğe ara, koleksiyon aç, ayar değiştir. Linear/Raycast paradigması.
→ Repo: `pacocoursey/cmdk` veya `timc1/kbar`

### 171 — Command palette içinde AI quick-action
`cmd+k > "kısalt seçili öğeyi"` → Claude'a gönderilir, yanıt aynı palette içinde. Notion AI deneyimi.

### 172 — Quick-look (macOS spacebar peek)
Liste satırını seçip **boşluk tuşu**: full overlay önizleme. Tekrar boşluk → kapanır. Power user paradigması.

### 173 — Three-pane Miller column (Finder gibi)
Kategori → öğe → alt-öğe / ilgili. Hiyerarşik navigasyonu görselleştirir; mevcut iki-pane'in üst seviyesi.

### 174 — Spotlight benzeri global arama overlay
`cmd+space` benzeri tam ekran modal; sonuçlar 7 başlık: Vault'lar, Öğeler, Koleksiyonlar, Notlar, Komutlar, Ayarlar, Yardım.

### 175 — Diff view A/B karşılaştırma (öneri 44'ün derinleştirilmesi)
İki API yanıtı `jsdiff` + `diff2html` ile satır-satır karşılaştırılır.
→ Repo: `rtfpessoa/diff2html`

### 176 — Excalidraw entegrasyonu (zihin haritası modu)
Bir koleksiyon Excalidraw kanvas'ında **görsel mind-map** olarak açılır. Öğeler düğüm, etiketler kenarlar.
→ Repo: `excalidraw/excalidraw`

### 177 — tldraw infinite canvas
Daha modern alternatif: koleksiyonlar tldraw'da düzenlenebilir, AI ile etkileşim native (Make Real).
→ Repo: `tldraw/tldraw`

### 178 — Ekran okuyucu live region
LLM streaming yanıtları `aria-live="polite"` bölgesine yazılır. Görme engelli kullanıcılar yanıtı duyabilir.

### 179 — Reduced motion respect
`prefers-reduced-motion` algılanır; animasyonlar kapatılır. WCAG 2.2 AAA gereği.

### 180 — Focus trap detay paneli
Modal açıkken Tab tuşu modal içinde kalır. `focus-trap` kütüphanesi.
→ Repo: `focus-trap/focus-trap`

### 181 — Skeleton loader (öneri 72'nin yapılandırılmış hali)
`react-content-loader` paterni vanilla'da. Daha estetik yükleme deneyimi.

---

## U. Veri Mimarisi & Performans

> 12 MB'lık vault dosyaları kabul edilemez. 2025'in bundling/streaming teknikleri ile çözüm var.

### 182 — Vault format devrimi: SQLite tek-dosya
Her vault `.sqlite` olarak. Tarayıcı `sql.js` ile bağlanır, **sadece görünen kayıtlar** yüklenir. 12 MB HTML → 4 MB SQLite + 200 KB shell.

### 183 — Parquet kolonel format
`apache-arrow` ile parquet kullanımı. Yalnızca okunan kolonlar getirilir. `content` kolonu ayrı sayfalı.

### 184 — HTTP range requests ile stream
SQLite/Parquet dosyaları **HTTP range** ile parça parça yüklenir. CDN üzerinden 10 GB veri bile sorun değil.
→ Demo: [phiresky/sql.js-httpvfs](https://github.com/phiresky/sql.js-httpvfs)

### 185 — Brotli precompression
Build zamanında tüm static asset'ler brotli ile sıkıştırılır. GitHub Pages otomatik servis eder. %25 ek tasarruf.

### 186 — Service Worker stale-while-revalidate
İlk açılış hızlı (cache'den), arka planda güncel kontrol. Workbox `StaleWhileRevalidate` stratejisi.
→ Repo: `GoogleChrome/workbox`

### 187 — Image lazy loading + AVIF
Vault'lardaki görsel önizlemeler `loading="lazy"` + AVIF. %50 boyut tasarrufu.

### 188 — Critical CSS inline + asset preload
İlk render için 14 KB inline CSS, geri kalanı `<link rel="preload">` ile. LCP < 1.0s hedefi.

### 189 — Web Workers'ta tüm ağır iş
Arama, embedding, rerank, parse: hepsi Comlink ile worker'da. Ana thread her zaman 60fps.
→ Repo: `GoogleChromeLabs/comlink`

### 190 — IntersectionObserver tabanlı virtual list
6000 öğeyi DOM'a basmak yerine: `virtua` veya custom IO implementasyonu. Mevcut öneri 57'nin modern versiyonu.
→ Repo: `inokawa/virtua`

### 191 — Bundle splitting per vault
Her vault ayrı chunk. `vault-promptvault.[hash].js` formatında. index.html sadece manifest'i bilir.
→ Repo: `vitejs/vite`

### 192 — Lighthouse CI / Web Vitals raporu
CI'da her PR Lighthouse skoru gerileyince fail. Performance bütçesi (LCP < 2.5s, CLS < 0.1) korunur.

---

## V. İçerik Zenginleştirme & Yapılandırılmış Çıktı

> Vault öğelerinin **kendileri** de daha akıllı olabilir.

### 193 — Frontmatter şeması (vault metadata standardı)
Her öğe için zorunlu schema: `id, name, desc, tags, source, model_hint, difficulty, output_format, examples[], anti_examples[]`. JSON Schema ile validate edilir.

### 194 — Anti-examples bölümü
Her promptun "kötü kullanım örnekleri" alanı. Kullanıcı **ne yapılmaması gerektiğini** de görür. Eğitim değeri artar.

### 195 — Mermaid diagram render
`content` içindeki ```mermaid blokları diagram'a çevrilir. ChainVault zincirleri görsel olarak akar.
→ Repo: `mermaid-js/mermaid`

### 196 — KaTeX matematik render
MathVault, StatsVault için TeX → HTML. Bilimsel içerik düzgün görünür.
→ Repo: `KaTeX/KaTeX`

### 197 — Highlight.js kod renklendirme (öneri 68'in mevcut implementasyonu)
ShaderVault, RegexVault için. 190+ dil desteği, MIT.
→ Repo: `highlightjs/highlight.js`

### 198 — Shiki ile VS Code teması
Highlight.js'in ötesi: TextMate grammar, daha hassas. Aydınlık/karanlık tema otomatik geçiş.
→ Repo: `shikijs/shiki`

### 199 — Auto-summarization batch job
Tüm vault öğelerine arka planda Claude Haiku ile 2 cümlelik özet üretilir, `auto_summary` alanına yazılır. Listede `desc` yerine bu kullanılır → hızlı tarama.

### 200 — Otomatik etiket önerisi v2 (öneri 93'ün operasyonel hali)
Etiketsiz öğeler tespit edilir; toplu olarak Claude'a gönderilir; öneriler localStorage'a düşer; kullanıcı tek tıkla onaylar.

### 201 — Kalite skoru hesaplama (öneri 92'nin spesifikasyonu)
Formül: `len(content) > 100 ? 0.3 : 0` + `tags.length >= 3 ? 0.2 : 0` + `has_example ? 0.2 : 0` + `source != "community" ? 0.15 : 0` + `user_rating/5 * 0.15`. 0–1 arası skor.

### 202 — Boşluk analizi (öneri 85'in derinleştirilmesi)
Embedding uzayında **kümelenmiş ama içerik az** bölgeler tespit edilir. "Bu konuda 47 prompt'un var ama X alt-konusunda hiç yok" raporu.

---

## W. Topluluk, Açık Kaynak & Sürdürülebilirlik

> Bir projenin uzun ömrü kod kalitesinden çok topluluk ve süreçlerle belirlenir.

### 203 — Monorepo + Turborepo / Nx
`apps/index`, `apps/vault-*`, `packages/core`, `packages/ui`. Build cache, bağımlılık grafiği. 100 vault için zorunlu.

### 204 — Conventional Commits + semantic-release
Her merge otomatik versiyon. CHANGELOG.md otomatik üretilir.

### 205 — Vault şablonu (Yeoman / create-aletcantasi-vault)
`npx create-aletcantasi-vault MyVault` ile yeni vault iskeleti. Topluluk kendi vault'ını eklesin.

### 206 — Açık kaynak yayını (GitHub) + license
MIT veya Apache-2.0. CONTRIBUTING.md, CODE_OF_CONDUCT.md, ISSUE_TEMPLATE/. Discord/Discourse topluluk.

### 207 — Sponsorluk / Open Collective
Anthropic API kullanımları için kullanıcılar **kendi key'lerini** kullansa da, proje altyapısı (CDN, domain) için sponsorluk.

### 208 — Mostly-zero-infra hosting
GitHub Pages + Cloudflare Pages. Aylık $0. 100 GB CDN traffic dahil.

### 209 — Playwright E2E test paketi
Her vault için: "kategori filtresi çalışıyor", "kopyala butonu pano'ya yazıyor", "API key kaydedilebilir". Regresyon engeli.
→ Repo: `microsoft/playwright`

### 210 — Vitest + jsdom unit testler
`core` paketindeki saf fonksiyonlar için. Coverage > %80 hedefi.

### 211 — Storybook ile component katalog
Her UI component'i izole olarak görsel test edilebilir. Tasarım sistemi şeffaflığı.
→ Repo: `storybookjs/storybook`

### 212 — i18n çerçevesi (öneri 63'ün operasyonel hali)
`i18next` ile TR/EN/AR/FA başlangıç. Crowdin ile topluluk çevirisi. **Doğum dilini koruyan** bir TR projesi olarak ek değer.
→ Repo: `i18next/i18next`

---

## X. Yol Haritası ve Öncelik Matrisi

### Faz 1 — Quick Wins (1–2 hafta, yüksek etki)
| Öncelik | Öneri | Neden | Repo / Teknoloji |
|---|---|---|---|
| 🔴 P0 | **170**, **171** — cmd+k palette | Anında premium hissi | `cmdk` |
| 🔴 P0 | **108** — Token streaming | LLM yanıtlarının "yaşayan" hissi | `eventsource-parser` |
| 🔴 P0 | **159**, **160** — Prompt injection + DOMPurify | Güvenlik temel | `DOMPurify` |
| 🟠 P1 | **190** — Virtual list | 6000+ öğeli PromptVault şart | `virtua` |
| 🟠 P1 | **128**, **129** — MCP server paketi | Proje değeri 10× | MCP SDK |

### Faz 2 — Strategic Foundations (3–6 hafta)
| Öncelik | Öneri | Neden | Repo / Teknoloji |
|---|---|---|---|
| 🟠 P1 | **102**, **139**, **140** — Embedding + RAG | Aramayı semantikleştirir | `transformers.js`, `hnswlib-wasm` |
| 🟠 P1 | **116**, **117**, **118** — Yjs CRDT | Local-first sync foundation | `yjs`, `y-indexeddb` |
| 🟠 P1 | **150**, **152** — OpenRouter routing | Tek-sağlayıcı kırılganlığı | OpenRouter |
| 🟡 P2 | **122** veya **123** — wa-sqlite veya DuckDB | Sorgu gücü tarayıcıda | `wa-sqlite` / `duckdb-wasm` |

### Faz 3 — Differentiation Layer (2–3 ay)
| Öncelik | Öneri | Neden | Repo / Teknoloji |
|---|---|---|---|
| 🟡 P2 | **101**, **103** — WebLLM + Whisper | Anahtarsız tam işlevsellik | `web-llm`, `transformers.js` |
| 🟡 P2 | **128–138** — MCP tam ekosistem | Claude Desktop / Cursor entegrasyonu | MCP |
| 🟢 P3 | **176**, **177** — Excalidraw / tldraw | Görsel knowledge graph | `tldraw` |
| 🟢 P3 | **203**, **205** — Monorepo + template | Topluluğa açılım | Turborepo |

### Faz 4 — Polish & Scale (sürekli)
- 192 (Lighthouse CI), 209 (Playwright), 211 (Storybook)
- 212 (i18n)
- 169 (security.md), 206 (open-source publish)
- 199 (auto-summary), 202 (boşluk analizi)

---

## Y. Referans Kaynaklar

> Bu dokümandaki önerilerin **iz sürülebilir kaynakları**.

### Resmi dokümantasyon
- [Anthropic — Model Context Protocol](https://www.anthropic.com/news/model-context-protocol)
- [Anthropic — Code execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)
- [WebLLM resmi](https://webllm.mlc.ai/) · [arXiv](https://arxiv.org/html/2412.15803v2)
- [web.dev — Origin Private File System](https://web.dev/articles/origin-private-file-system)
- [W3C — Web Cryptography Level 2](https://www.w3.org/TR/webcrypto-2/)
- [OWASP — LLM Prompt Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html)

### Endüstri raporları (2025–2026)
- [Thoughtworks — MCP's impact on 2025](https://www.thoughtworks.com/en-us/insights/blog/generative-ai/model-context-protocol-mcp-impact-2025)
- [Langfuse — Open-Source AI Agent Frameworks](https://langfuse.com/blog/2025-03-19-ai-agent-comparison)
- [LangChain — Best AI agent frameworks in 2026](https://www.langchain.com/resources/ai-agent-frameworks)
- [PowerSync — SQLite Persistence on the Web: May 2026](https://powersync.com/blog/sqlite-persistence-on-the-web)
- [LogRocket — Best React chart libraries in 2026](https://blog.logrocket.com/best-react-chart-libraries-2026/)
- [Velt — Best CRDT Libraries 2025](https://velt.dev/blog/top-crdt-libraries-for-real-time-data-sync)
- [GitHub — 100 Projects That Defined 2025](https://github.com/eon01/100-GitHub-Projects-That-Defined-2025)
- [Braintrust — Best Prompt Versioning Tools (2026)](https://www.braintrust.dev/articles/best-prompt-versioning-tools-2025)
- [Introl — Prompt Caching Infrastructure (Dec 2025)](https://introl.com/blog/prompt-caching-infrastructure-llm-cost-latency-reduction-guide-2025)

### Reddit thread'leri (saha tartışmaları)
- [r/LocalLLaMA — Whisper Turbo 100% locally in browser](https://www.reddit.com/r/LocalLLaMA/comments/1ftlznt/openais_new_whisper_turbo_model_running_100/)
- [r/LocalLLaMA — Best Local LLMs 2025](https://www.reddit.com/r/LocalLLaMA/comments/1pwh0q9/best_local_llms_2025/)
- [r/LocalLLM — WebLLM/WebGPU client-side](https://www.reddit.com/r/LocalLLM/comments/1laihft/can_we_use_webllm_or_webgpu_to_run_models_on_the/)
- [r/PromptEngineering — Best Practices 2025](https://www.reddit.com/r/PromptEngineering/comments/1nytj89/best_practices_for_ai_prompting_2025/)
- [r/PromptEngineering — Prompt management tools](https://www.reddit.com/r/PromptEngineering/comments/1j9gge2/which_prompt_management_tools_do_you_use/)
- [r/selfhosted — Favorite Self-Hosted Tools 2025](https://www.reddit.com/r/selfhosted/comments/1pdui2u/favorite_selfhosted_tools_in_2025_looking_for/)
- [r/webdev — Exploring RAG on the Client Side](https://www.reddit.com/r/webdev/comments/1iabxwj/exploring_rag_on_the_client_side_can_we_make/)
- [r/CloudFlare — AI search engine on Cloudflare free tier](https://www.reddit.com/r/CloudFlare/comments/1u085uo/i_built_a_full_aipowered_search_engine_using_only/)

### Önemli açık kaynak projeler
- `mlc-ai/web-llm` — In-browser LLM inference
- `huggingface/transformers.js` — Embedding/STT/sınıflandırma tarayıcıda
- `yjs/yjs` & `automerge/automerge` — CRDT local-first
- `duckdb/duckdb-wasm` & `rhashimoto/wa-sqlite` — Tarayıcıda DB
- `pacocoursey/cmdk` & `timc1/kbar` — Command palette
- `tldraw/tldraw` & `excalidraw/excalidraw` — Infinite canvas
- `cure53/DOMPurify` — XSS savunma
- `GoogleChrome/workbox` — PWA
- `BerriAI/litellm` & `OpenRouter` — Multi-provider routing
- `zilliztech/gptcache` — Semantic cache

---

## 📝 Notlar ve Kapanış

- Bu doküman **mevcut 100 öneri + 130 repo katalogunu YERLİĞE ALMAZ**; onların üzerine inşa edilen **stratejik ikinci dalgadır**. İlk dokümandaki Faz 1 (kritik) tamamlanmadan buradaki Faz 1'e geçilmemeli.
- Numaralandırma **101–212** olarak başlatıldı; ilk dokümanla çakışma yok.
- **MCP entegrasyonu (P bölümü)** projenin değer önerisini en hızlı katlayacak tek hamledir; Anthropic ekosistemine yapışan her aracın 2025'te kazandığını gözlemleyin.
- **WebLLM + Transformers.js (N bölümü)** projeyi "API key gerekli" sınıfından "her zaman çalışan" sınıfına geçirir; bu hedef pazarı 10× genişletir.
- **Yjs + OPFS (O & U)** mimarisi, projeyi 5MB localStorage zindanından kurtarır; gerçek bir "yerel-önce" üründür.

> _"100 vault bir cephanedir; ona ulaşan arayüz bir silahtır. v2 önerileri bu silahı modernize eder."_

— Alet Çantası teknik geliştirme yol haritası, v2 · 2026-06
