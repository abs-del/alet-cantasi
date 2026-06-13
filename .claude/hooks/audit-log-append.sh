#!/usr/bin/env bash
# audit-log-append — Her Edit/Write sonrası data/audit-log.ndjson'a kayıt ekler.
# [YENİ] İmmutable append-only değişiklik günlüğü (Eksik #3 düzeltmesi).

set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .input.file_path // empty' 2>/dev/null || true)
AGENT=$(echo "$INPUT" | jq -r '.agent_name // "unknown"' 2>/dev/null || echo "unknown")

if [[ -z "${FILE:-}" ]]; then
  exit 0
fi

# Sadece vault ve önemli dosyalar için log
case "$FILE" in
  *Vault.html|*vault.html|*.json|CLAUDE.md|index.html) ;;
  *) exit 0 ;;
esac

# data/ dizini yoksa oluştur
mkdir -p data 2>/dev/null || true

AUDIT_LOG="data/audit-log.ndjson"
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
SIZE=$(stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE" 2>/dev/null || echo 0)

echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"file_write\",\"file\":\"$FILE\",\"agent\":\"$AGENT\",\"branch\":\"$BRANCH\",\"size_bytes\":$SIZE}" >> "$AUDIT_LOG" 2>/dev/null || true

exit 0
