---
description: Dead code & kullanılmayan agent/skill/command tespiti. Knip ile JS/TS tarafını, kural tabanlı analizle .claude/ ekosistemini tarar. Temizlik öncesi ZORUNLU çalıştırılır.
argument-hint: "[--fix] [--scope=js|claude|all]"
---

# /knip-audit

Alet Çantası'nda kullanılmayan her şeyi tespit eder: ölü JS kodu, referanssız agent, çağrılmayan command, atıl skill.

## Kullanım

```
/knip-audit                    # Tümünü tara (js + .claude/)
/knip-audit --scope=claude     # Sadece agent/skill/command analizi
/knip-audit --scope=js         # Sadece JS dead code (knip)
/knip-audit --fix              # Güvenli sililebilecekleri listele (silmez, listeler)
```

## Akış

### 1. JS / TS Dead Code (scope=js veya all)

```bash
# knip kurulu mu kontrol
if command -v knip &>/dev/null || npx knip --version &>/dev/null 2>&1; then
  npx knip --reporter json 2>/dev/null | jq '{
    unused_exports: .exports | length,
    unused_files: .files | length,
    details: .
  }'
else
  echo "⚠️  knip bulunamadı. npm install -D knip ile kurun."
fi
```

### 2. .claude/ Ekosistemi Analizi (scope=claude veya all)

**Agent referans kontrolü:**
```bash
# CLAUDE.md'de referans edilmeyen agent'ları bul
for agent in .claude/agents/*.md; do
  name=$(basename "$agent" .md)
  if ! grep -q "$name" CLAUDE.md 2>/dev/null && \
     ! grep -rq "$name" .claude/commands/ 2>/dev/null && \
     ! grep -rq "$name" .claude/skills/ 2>/dev/null; then
    echo "🔶 UNREFERENCED AGENT: $name"
  fi
done
```

**Command ölü link kontrolü:**
```bash
# .claude/commands/ içindeki her command'ın CLAUDE.md'de veya başka yerde referansı var mı?
for cmd in .claude/commands/*.md; do
  name=$(basename "$cmd" .md)
  if ! grep -q "/$name" CLAUDE.md 2>/dev/null && \
     ! grep -rq "/$name" .claude/ 2>/dev/null; then
    echo "🔶 UNREFERENCED COMMAND: /$name"
  fi
done
```

**Skill kullanım kontrolü:**
```bash
# Agent'lar tarafından hiç çağrılmayan skill'leri bul
for skill_dir in .claude/skills/*/; do
  skill=$(basename "$skill_dir")
  if ! grep -rq "$skill" .claude/agents/ 2>/dev/null && \
     ! grep -rq "$skill" .claude/commands/ 2>/dev/null && \
     ! grep -q "$skill" CLAUDE.md 2>/dev/null; then
    echo "🔶 UNREFERENCED SKILL: $skill"
  fi
done
```

**Hook bağlantı kontrolü:**
```bash
# settings.json'da kayıtlı olmayan hook scriptleri
for hook in .claude/hooks/*.sh; do
  name=$(basename "$hook")
  if ! grep -q "$name" .claude/settings.json 2>/dev/null; then
    echo "⚠️  HOOK NOT WIRED: $name (settings.json'da eksik)"
  fi
done
```

### 3. REFERENCES.md Bağlantı Testi

```bash
# REFERENCES.md içindeki URL'lerin erişilebilirliğini kontrol et (opsiyonel)
if [[ "${CHECK_URLS:-0}" == "1" ]]; then
  grep -oE 'https?://[^)> ]+' REFERENCES.md | while read url; do
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null || echo "ERR")
    [[ "$status" != "200" ]] && echo "🔴 DEAD LINK ($status): $url"
  done
fi
```

## Çıktı Formatı

```
🔍 Knip Audit — Alet Çantası v4.x
══════════════════════════════════════
📦 JS/TS Dead Code
   unused exports : 3
   unused files   : 1
   → scripts/old-helper.mjs (son değişiklik: 45 gün önce)

🤖 Agent Analizi (18 agent)
   ✅ tümü referanslı

📋 Command Analizi (18 command)  
   🔶 /knip-audit → CLAUDE.md'de görevler tablosuna ekleyin

🔧 Skill Analizi (7 skill)
   ✅ tümü referanslı

🪝 Hook Analizi (9 hook)
   ✅ tümü settings.json'da kayıtlı

══════════════════════════════════════
📊 Özet: 1 dead code, 1 uyarı, 0 kritik sorun
💡 --fix ile güvenli temizlik listesi alın
```

## --fix Davranışı

`--fix` bayrağı **silmez** — sadece güvenle silinebilecekleri listeler ve her biri için onay ister:

```
Silinebilecekler:
  1. scripts/old-helper.mjs  (hiçbir yerde import edilmiyor, 45 gün atıl)
  
Her birini onaylamak için: "1 sil", "2 sil" veya "tümünü sil" yazın.
Şüpheli olanlar için önce /vault-diff ile karşılaştırın.
```

## Notlar

- `--scope=claude` analizi saf bash + grep ile çalışır, ek bağımlılık gerektirmez
- `--scope=js` için `knip` gerekir: `npm install -D knip`
- URL kontrolü varsayılan kapalıdır (`CHECK_URLS=1` ile açılır) — ağ erişimi gerektirir
- Bu komut `/release` pipeline'ından önce otomatik çalıştırılmalıdır (bkz. `release-manager` agent)
