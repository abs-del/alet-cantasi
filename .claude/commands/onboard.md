---
description: Yeni katkıda bulunan için 5 dakikalık hızlı turlar. Proje yapısı, agent'lar, slash komutları gezdirir.
---

# /onboard

Yeni geliştirici tanıtım turu — v4.0.0.

## İçerik

1. **Proje 30 saniyede** — 100 vault, index.html, local-first felsefe

2. **Vault şeması** — `vault-inspector` ile bir örnek vault'u incele

3. **Agent takımı** — `.claude/agents/` listele, her birinin rolünü 1 cümle ile

4. **Komutlar** — En sık 5 komut:
   - `/vault-add` — öğe ekle
   - `/enrich` — AI ile zenginleştir
   - `/cost-check` — para harcamadan tahmin
   - `/orchestrate` — büyük görev
   - `/vault-snapshot` — anlık vault yedeği [YENİ v4]

5. **Token disiplini** — CLAUDE.md'deki sert kuralları oku

6. **MCP entegrasyonu** — `.mcp.json` özetle

7. **v4 yenilikleri:**
   - `session-start.sh` StartHook → oturum başında timestamp yazılır
   - `session-summary.sh` [FIX] → gerçek oturum süresi gösterir
   - `bash-safety.sh` [FIX] → `git push --tags` artık gerçekten bloklanır
   - `vault-telemetry-append.sh` → her vault erişimi `data/telemetry.ndjson`'a kaydedilir
   - `agent-perf-tracker.sh` → her Task tamamlanması `docs/agent-perf-history.json`'a yazılır
   - `vault-guardian` agent → `/release` öncesi ekosistem şema sağlığı kontrolü
   - `vault-diff` agent [FIX] → jq tabanlı tam-obje hash karşılaştırması
   - `release-manager` [FIX] → pseudo-CLI kaldırıldı, gerçek Task tool

8. **Pratik egzersiz:**
   - "PromptVault'un yapısını incele" → `/vault-grep PromptVault.html "system"`
   - "Vault yedekle" → `/vault-snapshot PromptVault.html`
   - "Tahmini maliyeti çıkar" → `/cost-check`

## Çıktı

```
👋 Hoş geldiniz, Alet Çantası v4.0.0 geliştirici turu
══════════════════════════════════════════════════════
Bu projede 100 stand-alone HTML vault var, 52.240 öğe.
v4: 5 hata düzeltildi, 4 yeni özellik eklendi.

Çalışma kuralları:
  ⚠️ Vault HTML'ini ASLA tek seferde okuma (12 MB)
  ⚠️ Büyük görevler /orchestrate ile başlar
  ⚠️ git push --tags YASAK — tek tag: git push origin vX.Y.Z
  ⚠️ Web/akademik araştırma → /gemini, kod analizi → /codex

Pratik için: /vault-grep PromptVault.html "system prompt"
Yedekleme:   /vault-snapshot PromptVault.html
```
