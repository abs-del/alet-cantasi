#!/usr/bin/env bash
# large-file-guard — Read aracı bir dosyayı tam okumadan önce kontrol eder.
# FIX v3: 1 MB+ dosyalar artık GERÇEKTEN bloklanır (exit 2).
# FIX v3: bc kaldırıldı — saf bash aritmetiği kullanılır.
# FIX v4: Payload formatı her iki Claude Code versiyonu için desteklenir.

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .input.file_path // empty' 2>/dev/null || true)

if [[ -z "${FILE_PATH:-}" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

SIZE_BYTES=$(stat -c%s "$FILE_PATH" 2>/dev/null || stat -f%z "$FILE_PATH" 2>/dev/null || echo 0)

# Saf bash aritmetiği — bc gerektirmez (FIX v3)
SIZE_MB_INT=$((SIZE_BYTES / 1048576))
SIZE_MB_DEC=$(( (SIZE_BYTES % 1048576) * 10 / 1048576 ))
SIZE_MB="${SIZE_MB_INT}.${SIZE_MB_DEC}"

case "$FILE_PATH" in
  *Vault.html|*vault.html)
    if [[ "$SIZE_BYTES" -gt 524288 ]]; then
      cat <<EOF >&2
🛑 LARGE FILE GUARD — BLOK
==================================================
Dosya: $FILE_PATH
Boyut: ${SIZE_MB} MB ($SIZE_BYTES bytes)

Bu vault dosyasını tam okumak context window'unu tüketir.
ZORUNLU alternatifler:
  1. /vault-grep "$FILE_PATH" "<aradığınız>"
  2. vault-inspector skill (sadece şema özeti)
  3. Belirli satır: Read(file, offset=X, limit=200)
  4. codex-delegate'e pasla (dış context'te işlensin)

Tam okuma için kullanıcı açık onay vermeli.
EOF
      exit 2
    fi
    ;;
  *)
    if [[ "$SIZE_BYTES" -gt 2097152 ]]; then
      cat <<EOF >&2
⚠️  LARGE FILE UYARI
==================================================
Dosya: $FILE_PATH
Boyut: ${SIZE_MB} MB

Bu dosyayı tam okumak context'i zorlayabilir.
Mümkünse head/grep/tail ile hedefli okuma yapın.
EOF
    fi
    ;;
esac

exit 0
