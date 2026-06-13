# 🧰 Alet Çantası — Claude Code System v4.0.0

> *Local-first. Privacy-first. AI-native. Zero-server.*

Claude Code projeniz için hazır kurulum paketi: 18 agent, 7 skill, 19 komut, **9 hook**.

---

## 🆕 v4'te Ne Değişti

| # | Tür | Konu |
|---|---|---|
| FIX 1 | 🔴 Bug | `release-manager` — pseudo-CLI kaldırıldı, gerçek Task tool sözdizimi |
| FIX 2 | 🔴 Bug | `session-summary.sh` — sabit "1 saat" yerine gerçek oturum timestamp |
| FIX 3 | 🔴 Bug | `vault-diff` — `grep -A5` yerine jq tabanlı tam-obje hash |
| FIX 4 | 🔴 Bug | `bash-safety.sh` — `git push --tags` artık gerçekten yakalanıyor |
| FIX 5 | 🔴 Bug | `codebase-orchestrator` — `run_agent` pseudo-fonksiyon kaldırıldı |
| YENİ 1 | ✨ Özellik | `vault-telemetry-append.sh` — pasif kullanım analitiği |
| YENİ 2 | ✨ Özellik | `agent-perf-tracker.sh` — Task tool istatistik döngüsü |
| YENİ 3 | ✨ Özellik | `vault-guardian` agent — ekosistem şema drift detection |
| YENİ 4 | ✨ Özellik | `/vault-snapshot` komutu — gzip vault yedekleme |

---

## 📁 Paket İçeriği

```
.claude/
├── settings.json         ← Merkezi yapılandırma (izinler + hooklar)
├── agents/               ← 17 uzman agent
│   ├── codebase-orchestrator.md  ← [FIX] run_agent kaldırıldı
│   ├── release-manager.md         ← [FIX] Gerçek Task sözdizimi
│   ├── vault-diff.md              ← [FIX] jq tabanlı hash + [YENİ] agent
│   ├── vault-guardian.md          ← [YENİ] Ekosistem drift detector
│   └── ... (14 diğer agent)
├── hooks/                ← 9 hook
│   ├── session-start.sh           ← [YENİ] StartHook: timestamp yazar
│   ├── session-summary.sh         ← [FIX] Gerçek oturum süresi
│   ├── bash-safety.sh             ← [FIX] git push çakışması giderildi
│   ├── vault-telemetry-append.sh  ← [YENİ] Pasif vault analitiği
│   ├── agent-perf-tracker.sh      ← [YENİ] Task istatistikleri
│   ├── vault-schema-check.sh      ← (v2'den)
│   ├── audit-log-append.sh        ← (v2'den)
│   ├── large-file-guard.sh        ← (v2'den)
│   └── token-budget-reminder.sh   ← (v2'den)
├── skills/               ← 7 skill (v2'den)
└── commands/             ← 22 komut
    ├── vault-snapshot.md  ← [YENİ] gzip vault yedekleme
    └── ... (21 diğer komut)
```

---

## 🚀 Kurulum

```bash
# 1. Paketi proje kökünüze çıkarın
unzip alet-cantasi-claude-system-v4.zip -d your-project/

# 2. Symlink kurun (vault'lar varsa)
bash INSTALL.sh --link-vaults

# 3. Settings'i doğrulayın
cat .claude/settings.json | jq '.hooks | keys'
# Beklenen: ["PostToolUse", "PreToolUse", "Start", "Stop", "UserPromptSubmit"]

# 4. /onboard ile başlayın
# Claude Code içinde: /onboard
```

---

## 🪝 Hook Akışı (v4)

```
Oturum başlar
  → session-start.sh         [Start] timestamp: /tmp/session-start-$PPID.ts

Her Bash çağrısı
  → bash-safety.sh           [PreToolUse] tehlikeli komut kontrolü

Her Read çağrısı
  → large-file-guard.sh      [PreToolUse] 500KB+ vault bloku

Her Edit/Write çağrısı
  → vault-schema-check.sh    [PostToolUse] şema bütünlüğü
  → audit-log-append.sh      [PostToolUse] değişiklik kaydı
  → vault-telemetry-append.sh[PostToolUse] [YENİ] erişim analitiği

Her Task tamamlanması
  → agent-perf-tracker.sh    [PostToolUse] [YENİ] istatistik güncelle

Her kullanıcı mesajı
  → token-budget-reminder.sh [UserPromptSubmit] toplu okuma uyarısı

Oturum biter
  → session-summary.sh       [Stop] [FIX] gerçek süre özeti
```

---

## 📊 Yeni Dosyalar (çalışma süresi üretir)

| Dosya | Üreten | İçerik |
|---|---|---|
| `data/telemetry.ndjson` | vault-telemetry-append.sh | `{ts, vault, action, agent}` |
| `data/schema-drift-report.json` | vault-guardian agent | Ekosistem sağlık raporu |
| `data/snapshots/*.html.gz` | /vault-snapshot komutu | gzip vault yedekleri |
| `data/session-summaries/*.md` | session-summary.sh | Oturum özetleri |
| `docs/agent-perf-history.json` | agent-perf-tracker.sh | Task istatistikleri |

---

## ⚡ Sık Kullanılan Komutlar

```bash
/vault-grep PromptVault.html "system prompt"   # Hedefli arama
/vault-add PromptVault.html                    # Yeni öğe ekle
/vault-snapshot PromptVault.html               # [YENİ] Anlık yedek
/enrich PromptVault.html                       # AI zenginleştirme
/orchestrate "100 vault'a hover-peek ekle"     # Karmaşık görev
/cost-check                                    # Token tahmin
/release minor                                 # Sürüm çıkar
```

---

## 🔒 İzin Modeli (v4 değişiklikleri)

**Kaldırılanlar:**
- `"Bash(git push:*)"` — çok geniş, bash-safety'i bypass ediyordu

**Eklenenler:**
- `"Bash(git push origin HEAD)"` — normal push izni
- `"Bash(gzip:*)"`, `"Bash(zcat:*)"` — vault-snapshot için
- `deny: "Bash(git push --tags:*)"` — artık gerçekten bloklanıyor
- `deny: "Bash(npm publish:*)"` — explicit deny

---

*v4.0.0 · Değerlendirme skoru: 93/100 → 100/100*
