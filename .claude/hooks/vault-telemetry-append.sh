#!/usr/bin/env bash
# vault-telemetry-append — PostToolUse hook: vault erişimlerini NDJSON'a kaydeder.
# YENİ v4: Özellik 1 — Pasif kullanım analitiği.
# Her vault-grep, vault-add, enrich, Read(*Vault.html) çağrısında tetiklenir.
# data/telemetry.ndjson'a {ts, vault, item_id?, action, agent} yazar.

set -euo pipefail

INPUT=$(cat)

TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
AGENT=$(echo "$INPUT" | jq -r '.agent_name // "main"' 2>/dev/null || echo "main")

TELEMETRY_LOG="data/telemetry.ndjson"
mkdir -p data 2>/dev/null || true

# Vault dosyası mı?
VAULT_NAME=""
ACTION=""

case "$TOOL" in
  Read|View)
    case "$FILE" in
      *Vault.html|*vault.html)
        VAULT_NAME=$(basename "$FILE" .html)
        ACTION="read"
        ;;
      *) exit 0 ;;
    esac
    ;;
  Edit|Write)
    case "$FILE" in
      *Vault.html|*vault.html)
        VAULT_NAME=$(basename "$FILE" .html)
        ACTION="write"
        ;;
      *) exit 0 ;;
    esac
    ;;
  Bash)
    # vault-grep, enrich, vault-add pattern'lerini yakala
    case "$CMD" in
      *vault-grep*|*vault_grep*)
        VAULT_NAME=$(echo "$CMD" | grep -oE '[A-Z][a-zA-Z]+Vault' | head -1 || echo "unknown")
        ACTION="grep"
        ;;
      *enrich*|*batch-enrich*)
        VAULT_NAME=$(echo "$CMD" | grep -oE '[A-Z][a-zA-Z]+Vault' | head -1 || echo "unknown")
        ACTION="enrich"
        ;;
      *vault-add*|*vault_add*)
        VAULT_NAME=$(echo "$CMD" | grep -oE '[A-Z][a-zA-Z]+Vault' | head -1 || echo "unknown")
        ACTION="add"
        ;;
      *) exit 0 ;;
    esac
    ;;
  *) exit 0 ;;
esac

[[ -z "$VAULT_NAME" ]] && exit 0

# Kayıt yaz
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "{\"ts\":\"$TS\",\"vault\":\"$VAULT_NAME\",\"action\":\"$ACTION\",\"agent\":\"$AGENT\"}" \
  >> "$TELEMETRY_LOG" 2>/dev/null || true

exit 0
