# Alet Çantası — Claude Code Proje Hafızası

> Bu dosya **her oturumun başında otomatik yüklenir**. Kısa, kararlı ve yüksek-sinyal tutulmalıdır.
> Detaylar/değişkenler `.claude/docs/` altına gider — buraya değil.

---

## 🎯 Proje Kimliği

- **Ad:** Alet Çantası (Toolkit) · **Versiyon:** v4.0.0
- **Yapı:** 100 HTML vault dosyası + `index.html` ana yönlendirici
- **Ölçek:** 52.240 toplam öğe · 6 disiplin · ~12 MB en büyük vault
- **Felsefe:** *Local-first, privacy-first, AI-native, **zero-server**.*
- **Tek bağımlılık (üretim):** Tarayıcı + opsiyonel Anthropic API key (kullanıcının localStorage'ında).
- **Asla yapma:** Backend server kurma, kullanıcı verisini bulut servisine yollama, npm/build adımı zorunlu kılma.

---

## ⚡ Token & Context Disiplini (SERT KURALLAR)

> Claude Code'un en kıt kaynağı **context window**. Bu projede vault dosyaları büyük (12 MB'a kadar), kuralları ihlal etmek seansı bitirir.

1. **ASLA bir vault HTML'ini tek seferde okumayın.** Önce `head -200`, `wc -l`, `grep -n` ile yapıyı çıkarın. Tam okuma gerekiyorsa `vault-inspector` skill'ini veya `vault-curator` agent'ını çağırın — onlar ayrı context'te çalışır.
2. **Çoklu dosya araştırması her zaman subagent'a gider.** "Tüm vault'larda `badge1` alanı var mı?" gibi soruları kendi context'inizde değil, `Task` tool ile bir subagent'a delege edin.
3. **Uzun çıktıyı tek seferde değil, akışlı (streaming) tasarlayın.** Toplu işler için `/cost-check` ile token tahmini alın.
4. **Her 10 araç çağrısında bir, `/compact` reflexini düşünün.** Görev tamamlandıysa `/clear`.
5. **Hızlı soru için `/btw`** kullanın — context'e yazılmaz.
6. **Ağır araştırmaları `codex` veya `gemini` subagent'larına paslayın** — tokeniniz korunur, sonuç özet halinde gelir.
7. **Asla `find /` veya `grep -r` çalıştırmayın.** Daima belirli vault'a sınırlandırın.
8. **Anthropic prompt caching:** 1024+ token'lık `system` veya sabit bağlam parçalarına `cache_control` ekleyin.

---

## 🗂️ Repo Topolojisi

```
alet-cantasi/
├── index.html              # Ana router; 100 vault'a link verir
├── PromptVault.html        # En büyük (6.000+ öğe)
├── ChainVault.html         # Zincir prompt'lar
├── RegexVault.html, LogVault.html, ShaderVault.html, MemVault.html, ...
├── config/
│   └── budget.json              # [v4.1] Maliyet bütçesi — cost-router okur
├── data/
│   ├── audit-log.ndjson         # Immutable append-only değişiklik günlüğü
│   ├── telemetry.ndjson         # [YENİ v4] Vault erişim analitiği
│   ├── schema-drift-report.json # [YENİ v4] vault-guardian raporu
│   └── snapshots/               # [YENİ v4] Point-in-time vault yedekleri
│       └── PromptVault-20260613_143021.html.gz
├── docs/
│   ├── alet-cantasi-100-oneri.md       # Temel 100 tasarım kuralı
│   ├── alet-cantasi-100-ileri-oneri-v2.md
│   ├── alet-cantasi-100-repo-onerisi.md
│   ├── perf-history.json               # /perf-bench geçmişi
│   └── agent-perf-history.json         # Task tool istatistikleri (agent-perf-tracker besler)
└── .claude/
```

**Her vault'un kayıt şeması (immutable):**
```json
{ "id": "string", "cat": "string", "name": "string", "desc": "string",
  "badge1": "string?", "badge2": "string?", "tags": ["string"],
  "source": "community|url", "content": "string" }
```

**Yeni alanlar ASLA bu şemayı kırmadan eklenir** — geriye dönük uyumluluk şart.

---

## 🧭 Görev Yönlendirme Kuralları

| İstek tipi | Önce çağrılacak |
|---|---|
| Yeni vault öğesi ekle / zenginleştir | `vault-curator` agent + `/enrich` komutu |
| Vault şemasını doğrula (tek) | `vault-inspector` skill |
| **Ekosistem şema sağlığı [v4]** | **`vault-guardian` agent** |
| **Kullanılmayan agent/skill/command tespiti [v4.1]** | **`/knip-audit` komutu** — JS dead code + .claude/ ekosistemi analizi |
| Yeni bir vault HTML üret | `html-vault-generator` skill |
| MCP server taslağı | `mcp-builder` agent |
| Embedding / semantic search | `rag-architect` agent |
| **Dosya setini context'e dönüştür [v4.1]** | **`rag-architect` + `files-to-prompt` köprüsü** |
| Performans / virtual scroll / Worker | `performance-engineer` agent |
| Güvenlik / API key crypto | `security-auditor` agent |
| Çoklu sağlayıcı routing / maliyet | `cost-router` agent |
| **Codex/Gemini CLI köprüsü [v4.1]** | **`llm` CLI + `codex-delegate` / `gemini-delegate`** |
| Akademik araştırma / 50+ dosya tarama | `codex` subagent |
| Web/güncel doküman araması | `gemini` subagent |
| UI/UX (Tailwind/DaisyUI) | `ui-craftsman` agent |
| Test üretimi | `qa-expert` agent |
| Refactor | `refactoring-specialist` agent |
| Çalıştırılabilir kod denemesi | `code-runner` agent |
| Agent arası hafıza koordinasyonu | `agent-memory-mesh` skill |
| **İki vault versiyonu karşılaştır [v4]** | **`vault-diff` agent** |
| **Vault yedekle [v4]** | **`/vault-snapshot` komutu** |
| Sürüm çıkar | `release-manager` agent + `/release` |

---

## 🔄 Agent Hata Yayılımı (Error Propagation)

Paralel agent task'larında hata yönetimi zorunludur:

```
Başarısız task → orchestrator'a ERROR_RESULT döner
orchestrator:
  - Bağımlı adımları askıya al (dependent_steps)
  - Kullanıcıya bildir: "Adım X başarısız: <özet>"
  - Seçenekleri sun: retry | skip | abort
  - ASLA sessizce devam etme
```

`codebase-orchestrator`, her Task spawn'ından önce `/tmp/orchestration-budget.json`'a bağımlılık haritası yazar.

---

## 🪝 Hook Ekosistemi [v4 güncel + v4.1 notlar]

| Hook | Tetikleyici | Ne Yapar |
|---|---|---|
| `session-start.sh` | Start | Oturum timestamp yazar → `/tmp/session-start-$PPID.ts` |
| `large-file-guard.sh` | PreToolUse(Read) | 500KB+ vault okumalarını bloklar |
| `bash-safety.sh` | PreToolUse(Bash) | Tehlikeli komutları engeller |
| `vault-schema-check.sh` | PostToolUse(Edit/Write) | Vault şema bütünlüğü |
| `audit-log-append.sh` | PostToolUse(Edit/Write) | `data/audit-log.ndjson`'a kayıt — **[v4.1]** Temporal ISO 8601 format |
| `vault-telemetry-append.sh` | PostToolUse(R/W/Bash) | `data/telemetry.ndjson`'a erişim logu |
| `agent-perf-tracker.sh` | PostToolUse(Task) | `docs/agent-perf-history.json`'a Task istatistikleri — **[v4.1]** OTel trace format uyumu |
| `token-budget-reminder.sh` | UserPromptSubmit | Toplu okuma uyarısı |
| `session-summary.sh` | Stop | **[FIX v4]** Gerçek oturum süresiyle özet (PPID timestamp) — **[v4.1]** Temporal polyfill ile macOS/Linux tutarlılığı |

**[v4.1 Ekleme] Temporal Polyfill Kullanımı:**
- `session-summary.sh` içinde `date` komutunun macOS (`date -u -d`) vs Linux (`date -u -D`) farkları [`@js-temporal/temporal-polyfill`](https://github.com/js-temporal/temporal-polyfill) ile çözülür.
- Audit log timestamp karşılaştırmaları (`jq` filter'larında) ISO 8601 standart formatını garanti eder: `2026-06-13T14:30:21.000Z` (masaüstü uyumluluk).
- Node.js ortamında: `const Temporal = require('@js-temporal/polyfill'); const now = Temporal.Now.zonedDateTimeISO();`
- Bash ortamında: POSIX `date` yerine `date -u +%FT%T.000Z` (manual) veya Node.js helper script opsiyonu.

---

## 🛠️ Kod Tarzı & Sınırlamalar

- **Vanilla JS / HTML / CSS — varsayılan.** Framework eklemek için açık gerekçe ve kullanıcı onayı şart.
- **Tek dosya tercih.** Her vault stand-alone `.html` olarak yayınlanır.
- **CDN bağımlılığı:** Sadece *immutable, SRI-hash'li* CDN'ler.
- **TR/EN i18n:** Arayüz metinleri `data-i18n` attribute ile.
- **A11y:** ARIA roller, klavye-only navigasyon, `prefers-reduced-motion` zorunlu.
- **Test:** Vitest + Playwright. Coverage hedefi: %70.

---

## 🚦 Onay Gerektiren Aksiyonlar

Aşağıdakileri **sormadan yapma**:
- 12 MB'tan büyük dosyayı tek seferde okuma
- Backend / sunucu kodu yazma
- Mevcut vault şemasını kıran alan ekleme
- 10+ API çağrısı içeren batch işlem (`/cost-check` zorunlu)
- npm dependency ekleme
- `npm publish` veya `git push <tag>` (her ikisi çift onay gerektirir)
- `git push --tags` — YASAK. Yalnızca tek tag: `git push origin vX.Y.Z`

---

## 📚 Referanslar

- `docs/alet-cantasi-100-oneri.md` — Temel 100 öneri
- `docs/alet-cantasi-100-ileri-oneri-v2.md` — İleri 100+ öneri
- `docs/alet-cantasi-100-repo-onerisi.md` — Repo katalogu
- [Claude Code best-practices](https://code.claude.com/docs/en/best-practices)
- [MCP spec](https://modelcontextprotocol.io)
- [Anthropic Prompt Caching](https://platform.claude.com/docs/build-with-claude/prompt-caching)

---

**Son söz:** *Bu projede her satır, kullanıcının cihazından çıkmadan çalışmalı. Bir feature için "sadece bir sunucu kuralım" demek, bu projeyi bitirir. Önce local çözüm.*
