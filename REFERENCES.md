# 📚 REFERENCES — Kaynak Repolar ve Dokümanlar

> Bu paketin tasarımında doğrudan veya dolaylı yararlanılan tüm açık kaynak projeler. Tümü MIT/Apache‑2.0/BSD altında — ticari kullanım öncesi LICENSE doğrulanmalı.

---

## 🥇 Birincil ekosistem (Claude Code)

| Kaynak | Açıklama | Kullanım yerimiz |
|---|---|---|
| [anthropics/claude-code](https://github.com/anthropics/claude-code) | Resmi Claude Code | Tüm `.claude/` mimarisi |
| [anthropics/skills](https://github.com/anthropics/skills) | Resmi Agent Skills | `.claude/skills/` formatı |
| [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices) | Context yönetimi | `CLAUDE.md` token disiplini |
| [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams) | Multi-agent docs | `settings.json` flag + orchestrator pattern |
| [Anthropic Prompt Caching](https://platform.claude.com/docs/build-with-claude/prompt-caching) | %90 tasarruf | `prompt-cache-optimizer` skill |
| [Anthropic MCP Spec](https://modelcontextprotocol.io) | Resmi protokol | `mcp-builder` agent + `.mcp.json` |

---

## 🥈 Curated awesome-list'ler

| Repo | İçerik | Yıldız (2026 Q2) |
|---|---|---|
| [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) | 154+ subagent kataloğu, kategoriler | yüksek |
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 1000+ skill (Claude+Codex+Gemini uyumlu) | yüksek |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Skills + hooks + slash + orchestrators | en yüksek |
| [hesreallyhim/a-list-of-claude-code-agents](https://github.com/hesreallyhim/a-list-of-claude-code-agents) | Agent listesi | yüksek |
| [travisvn/awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills) | Skills + resources | orta |
| [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) | Composio entegrasyonlu skills | orta |
| [rahulvrane/awesome-claude-agents](https://github.com/rahulvrane/awesome-claude-agents) | Sub-agent paralel ekip örnekleri | orta |
| [quemsah/awesome-claude-plugins](https://github.com/quemsah/awesome-claude-plugins) | Top 100 plugins listesi | orta |
| [danielrosehill/Claude-Slash-Commands](https://github.com/danielrosehill/Claude-Slash-Commands) | Reusable slash commands | orta |
| [alirezarezvani/claude-code-tresor](https://github.com/alirezarezvani/claude-code-tresor) | 30 subagent şablonu | orta |
| [disler/claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery) | Hook örnekleri (exit codes, JSON) | yüksek |

---

## 🥉 Multi-CLI köprü (Codex + Gemini + Claude)

| Repo | Açıklama |
|---|---|
| [BeehiveInnovations/pal-mcp-server](https://github.com/BeehiveInnovations/pal-mcp-server) | **clink** tool ile Codex/Gemini CLI köprüsü; planner, consensus, chat |
| [openai/codex](https://github.com/openai/codex) (CLI) | OpenAI resmi terminal CLI |
| [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) | Google resmi terminal CLI, built-in `@web` |
| [Multi-CLI MCP](https://mcpmarket.com/server/multi-cli) | Auto-detect Claude/Gemini/Codex/OpenCode bridge |
| [Zen MCP](https://github.com/BeehiveInnovations/zen-mcp-server) | PAL'in atası — collaborative problem solving |

---

## 🛠️ MCP Server'ları (önerilen)

| Server | Repo | Kullanım |
|---|---|---|
| `filesystem` | [@modelcontextprotocol/server-filesystem](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem) | Vault dosyalarına okuma |
| `github` | [github-mcp-server](https://github.com/github/github-mcp-server) | Issue, PR, repo yönetimi |
| `playwright` | [@playwright/mcp](https://github.com/microsoft/playwright-mcp) | E2E + visual regression |
| `fetch` | [@modelcontextprotocol/server-fetch](https://github.com/modelcontextprotocol/servers/tree/main/src/fetch) | Web içerik çekme |
| `memory` | [@modelcontextprotocol/server-memory](https://github.com/modelcontextprotocol/servers/tree/main/src/memory) | Agent persistent memory |
| `sequential-thinking` | [@modelcontextprotocol/server-sequential-thinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking) | Yapılandırılmış akıl yürütme |

---

## 🧠 Tarayıcı içi AI (Vault için doğrudan ilgili)

| Kütüphane | Repo | Hangi öneri |
|---|---|---|
| WebLLM | [mlc-ai/web-llm](https://github.com/mlc-ai/web-llm) | Öneri 101 (offline chat) |
| Transformers.js | [huggingface/transformers.js](https://github.com/huggingface/transformers.js) | Öneri 102, 142 (embed + rerank) |
| Whisper WASM | [Xenova/realtime-whisper-webgpu](https://huggingface.co/spaces/Xenova/realtime-whisper-webgpu) | Öneri 103 |
| Web Stable Diffusion | [mlc-ai/web-stable-diffusion](https://github.com/mlc-ai/web-stable-diffusion) | Öneri 104 |
| hnswlib-wasm | [ChromaCorp/hnswlib-wasm](https://github.com/ChromaCorp/hnswlib-wasm) | Öneri 140 |
| MiniSearch | [lucaong/minisearch](https://github.com/lucaong/minisearch) | Öneri 1, 11 |
| FlexSearch | [nextapps-de/flexsearch](https://github.com/nextapps-de/flexsearch) | Öneri 11 |

---

## 🗄️ Local-first storage

| Kütüphane | Repo | Öneri |
|---|---|---|
| Yjs | [yjs/yjs](https://github.com/yjs/yjs) | 116, 118, 119 |
| Automerge | [automerge/automerge](https://github.com/automerge/automerge) | 117 |
| Dexie.js | [dexie/Dexie.js](https://github.com/dexie/Dexie.js) | 61, 125 |
| wa-sqlite | [rhashimoto/wa-sqlite](https://github.com/rhashimoto/wa-sqlite) | 122 |
| DuckDB-WASM | [duckdb/duckdb-wasm](https://github.com/duckdb/duckdb-wasm) | 123 |

---

## 🚀 Performans

| Kütüphane | Repo | Öneri |
|---|---|---|
| Workbox | [GoogleChrome/workbox](https://github.com/GoogleChrome/workbox) | 56 |
| Clusterize.js | [NeXTs/Clusterize.js](https://github.com/NeXTs/Clusterize.js) | 57 |
| Comlink | [GoogleChromeLabs/comlink](https://github.com/GoogleChromeLabs/comlink) | 58 |
| Vite | [vitejs/vite](https://github.com/vitejs/vite) | 59 |
| lz-string | [pieroxy/lz-string](https://github.com/pieroxy/lz-string) | 60 |
| fflate | [101arrowz/fflate](https://github.com/101arrowz/fflate) | 60 |

---

## 🎨 UI

| Kütüphane | Repo |
|---|---|
| DaisyUI | [saadeghi/daisyui](https://github.com/saadeghi/daisyui) |
| Lucide Icons | [lucide-icons/lucide](https://github.com/lucide-icons/lucide) |
| TipTap | [ueberdosis/tiptap](https://github.com/ueberdosis/tiptap) |
| Floating UI | [floating-ui/floating-ui](https://github.com/floating-ui/floating-ui) |
| Motion One | [motiondivision/motionone](https://github.com/motiondivision/motionone) |
| SortableJS | [SortableJS/Sortable](https://github.com/SortableJS/Sortable) |

---

## 🤖 LLM Provider routing

| Kütüphane | Repo | Öneri |
|---|---|---|
| OpenRouter | [openrouter/openrouter](https://github.com/openrouter) | 150 |
| LiteLLM | [BerriAI/litellm](https://github.com/BerriAI/litellm) | 151 |
| Vercel AI SDK | [vercel/ai](https://github.com/vercel/ai) | 36 |
| LangChain.js | [langchain-ai/langchainjs](https://github.com/langchain-ai/langchainjs) | 39, 134 |
| GPTCache | [zilliztech/gptcache](https://github.com/zilliztech/gptcache) | 155 |

---

## 📖 Makaleler / Blog yazıları

- [10 GitHub Repositories To Master Claude Code](https://www.kdnuggets.com/10-github-repositories-to-master-claude-code) — KDnuggets
- [Best Claude Code Skills to Try in 2026](https://www.firecrawl.dev/blog/best-claude-code-skills) — Firecrawl
- [Best Claude Code MCP Servers in 2026](https://nimbalyst.com/blog/best-claude-code-mcp-servers/) — Nimbalyst
- [Claude Code Hooks Explained](https://joseparreogarcia.substack.com/p/claude-code-hooks-explained-the-missing) — Substack
- [Multi-agent orchestration for Claude Code in 2026](https://shipyard.build/blog/claude-code-multi-agent/) — Shipyard
- [The Code Agent Orchestra](https://addyosmani.com/blog/code-agent-orchestra/) — Addy Osmani
- [Anatomy of the .claude/ Folder](https://blog.dailydoseofds.com/p/anatomy-of-the-claude-folder)

---

## 🎯 Bu paketin doğrudan beslendiği proje dokümanları

- `docs/alet-cantasi-100-oneri.md` — Orijinal 100 öneri (A–J)
- `docs/alet-cantasi-100-ileri-oneri-v2.md` — İleri 100+ öneri (N–W)
- `docs/alet-cantasi-100-repo-onerisi.md` — 130+ repo katalogu

Bu üç dosyadaki **öneri numaraları** agent ve skill prompt'larında doğrudan referans verilmiştir (örn. "öneri 113", "öneri 139–149").

---

## 🔄 v4.1 Değerlendirme Aşamasındaki Repolar

Aşağıdaki 10 repo, v4.0.0 ekosistemini tamamlayan ancak hâlâ pilot/opsiyonel statüsünde olan projelerdir. Kullanım senaryonuza göre seçin.

| # | Kaynak | Açıklama | Durum | Öneri | v4 Entegrasyon |
|---|---|---|---|---|---|
| 1 | [simonw/llm](https://github.com/simonw/llm) | Claude/Gemini/Codex CLI — JSON output, streaming | ✅ Üretim hazır | Codex/Gemini subagent köprüsü | `codex-delegate`, `gemini-delegate` agent'larına CLI binding |
| 2 | [simonw/files-to-prompt](https://github.com/simonw/files-to-prompt) | Dosya setini context'e dönüştür (Markdown tree) | ✅ Üretim hazır | Vault batch zenginleştirme | `rag-architect` agent'ı + `/batch-enrich` komutu |
| 3 | [quickwit-oss/tantivy](https://github.com/quickwit-oss/tantivy) + [tantivy-wasm](https://github.com/phiresky/tantivy-wasm) | Rust WASM full-text engine — Türkçe stemming, 10× hız | ✅ Üretim hazır | Vault arama 100+ öğe için | `embedding-builder` skill — `TANTIVY_ENABLED` flag ile opsiyonel |
| 4 | [simonw/shot-scraper](https://github.com/simonw/shot-scraper) | Playwright CLI — vault öğelerinin PDF/PNG screenshot'ı | ⚠️ Artık önerilmiyor | Vault içeriği görselleştirme | `playwright` MCP zaten aktif (`.mcp.json`) — ekstra CLI gereksiz |
| 5 | [BuilderIO/partytown](https://github.com/BuilderIO/partytown) | Web Worker Main Thread Isolation Framework | ✅ Üretim hazır | 3. parti script izolasyonu | `performance-engineer` agent'ı — Comlink'den sonra değerlendirme |
| 6 | [js-temporal/temporal-polyfill](https://github.com/js-temporal/temporal-polyfill) | Temporal API polyfill — ISO 8601 timestamp tutarlılığı | ✅ Üretim hazır | `session-summary.sh` date macOS/Linux sorunu | `session-summary.sh` + audit log timestamp karşılaştırmaları |
| 7 | [webpro-nl/knip](https://github.com/webpro-nl/knip) | Dead code detector — kullanılmayan agent/skill tespiti | ✅ Üretim hazır | Ekosistem drift detection | `vault-guardian` agent'ı — `/knip-audit` komutu olarak |
| 8 | [open-telemetry/opentelemetry-js](https://github.com/open-telemetry/opentelemetry-js) | OpenTelemetry trace format — Grafana/Jaeger uyumu | ✅ Üretim hazır | Agent perf metriklerinin standart formatı | `agent-perf-tracker.sh` → NDJSON'dan OTel trace exportu |
| 9 | [tc39/proposal-records-tuples](https://github.com/tc39/proposal-records-tuples) + polyfill | Immutable records/tuples — vault şema bütünlüğü | 🔵 Stage 2 (henüz TC39 taslağı) | Vault öğelerinin immutable serialize'si | v5.0 hedefi — şimdilik JSON schema validation yeterli |
| 10 | [llm.report](https://llm.report) + [OpenMeter](https://openmeter.io) | Prompt maliyet görselleştirme dashboard'u | 🔵 Cloud-dependent (local-first ilkesiyle çelişir) | Vault telemetri real-time viz | Opsiyonel — `data/telemetry.ndjson` → webhook exportu yapılabilir |

### 🎯 Entegrasyon Stratejisi

**Hemen yapılacak (v4.0.1):**
- ✅ Temporal polyfill → `session-summary.sh` + audit-log timestamp
- ✅ knip entegrasyonu → `vault-guardian` agent'ı, `/knip-audit` komutu
- ✅ files-to-prompt binding → `rag-architect` agent'ı
- ✅ llm CLI mapping → `codex-delegate` / `gemini-delegate` agents

**Dikkatli değerlendirme (v4.1):**
- 🟡 tantivy-wasm — build pipeline risk vs. arama hızı trade-off ölçülmeli
- 🟡 Partytown — Comlink'le karşılaştırmalı benchmark gerekli
- 🟡 OpenTelemetry — NDJSON → OTel Collector pipeline yapılabilir

**v5 hedefi veya opsiyonel:**
- 🔵 Records/Tuples — Stage 3'e yükseldikten sonra
- 🔵 llm.report — cloud dashboard kullanıcılar için isteğe bağlı

---

**Not:** Her repo'nun LICENSE'ını üretim öncesi kontrol edin. Bu liste 2026 Q2 itibarıyladır — popüler repolar hızla değişir, periyodik review önerilir.
