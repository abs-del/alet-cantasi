#!/usr/bin/env bash
# vault-schema-check — Edit/Write sonrası (v4: telemetry entegrasyonu) vault HTML dosyalarının şema bütünlüğünü kontrol eder.
# FIX v2: Regex yalnızca data island içindeki ID'leri sayar (content alanındaki "id" eşleşmesini önler).
#         Payload formatı her iki Claude Code versiyonu için desteklenir.

set -euo pipefail

INPUT=$(cat)

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .input.file_path // empty' 2>/dev/null || true)

if [[ -z "${FILE:-}" || ! -f "$FILE" ]]; then
  exit 0
fi

# Sadece *Vault.html dosyaları için çalış
case "$FILE" in
  *Vault.html|*vault.html) ;;
  *) exit 0 ;;
esac

# JSON island var mı?
DATA_LINE=$(grep -n 'id="data"' "$FILE" | head -1 | cut -d: -f1 || true)
if [[ -z "${DATA_LINE:-}" ]]; then
  echo "⚠️  Vault Schema: data island bulunamadı ($FILE)" >&2
  exit 0
fi

# Data island'ı izole et (script başlangıcından bitimine kadar)
SCRIPT_END=$(awk "NR>${DATA_LINE} && /<\/script>/{print NR; exit}" "$FILE" || true)

if [[ -z "${SCRIPT_END:-}" ]]; then
  exit 0
fi

# Sadece data island içindeki ID'leri say (FIX: content alanındaki "id" false positive'ini önler)
ISLAND=$(sed -n "${DATA_LINE},${SCRIPT_END}p" "$FILE" 2>/dev/null || true)

if [[ -z "${ISLAND:-}" ]]; then
  exit 0
fi

# ID sayısı — object-level id'leri bul (boşluk/tab sonrası "id": formatı)
TOTAL=$(echo "$ISLAND" | grep -oE '^\s+"id"\s*:\s*"[^"]+"' | wc -l || echo 0)
UNIQUE=$(echo "$ISLAND" | grep -oE '^\s+"id"\s*:\s*"[^"]+"' | sort -u | wc -l || echo 0)

if [[ "$TOTAL" -gt 0 && "$TOTAL" -ne "$UNIQUE" ]]; then
  DUP_IDS=$(echo "$ISLAND" | grep -oE '^\s+"id"\s*:\s*"[^"]+"' | sort | uniq -d | head -5 | tr -d ' ')
  cat <<EOF >&2
⚠️  VAULT SCHEMA WARNING — Duplicate ID'ler
==================================================
Dosya: $FILE
Toplam: $TOTAL, Benzersiz: $UNIQUE
Tekrarlananlar:
$DUP_IDS

vault-curator agent'ını çağırarak düzeltin: /vault-add
EOF
fi

# Zorunlu alan kontrolü
NAME_COUNT=$(echo "$ISLAND" | grep -oE '"name"\s*:' | wc -l || echo 0)
CONTENT_COUNT=$(echo "$ISLAND" | grep -oE '"content"\s*:' | wc -l || echo 0)

if [[ "$TOTAL" -gt 0 && "$TOTAL" -ne "$NAME_COUNT" ]]; then
  echo "⚠️  Şema uyarısı: $TOTAL id var ama $NAME_COUNT name. Eksik 'name' alanı olabilir." >&2
fi

if [[ "$TOTAL" -gt 0 && "$TOTAL" -ne "$CONTENT_COUNT" ]]; then
  echo "⚠️  Şema uyarısı: $TOTAL id var ama $CONTENT_COUNT content. Eksik 'content' alanı olabilir." >&2
fi

# Audit log'a yaz (append-only) — [YENİ]
AUDIT_LOG="data/audit-log.ndjson"
if [[ -d "data" ]]; then
  echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"vault_write\",\"file\":\"$FILE\",\"items\":$TOTAL}" >> "$AUDIT_LOG" 2>/dev/null || true
fi

exit 0
