#!/usr/bin/env bash
# token-budget-reminder — her kullanıcı promptunda token disiplini hatırlatması.
# FIX v2: Payload formatı her iki Claude Code versiyonu için desteklenir.

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // .tool_input.prompt // empty' 2>/dev/null || true)

if [[ -z "${PROMPT:-}" ]]; then
  exit 0
fi

# Token-yoğun kelimeleri ara
if echo "$PROMPT" | grep -qiE '(tüm\s+(vault|dosya)|bütün\s+vault|read\s+all|full\s+(content|file)|hepsini)'; then
  cat <<EOF
💡 TOKEN BUDGET REMINDER
İsteğiniz çok sayıda dosya okuması içeriyor olabilir. Hatırlatma:

  • Vault dosyaları 12 MB'a kadar — context'i bombalayabilir
  • /vault-grep <vault> "<sorgu>" ile hedefli arama yapın
  • /orchestrate ile büyük görevleri planlayın
  • /codex veya /gemini ile dış delegasyon yapın
  • Token durumu: /token-status

Devam edebilirsiniz, bu sadece bir hatırlatma.
EOF
fi

exit 0
