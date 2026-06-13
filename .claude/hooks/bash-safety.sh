#!/usr/bin/env bash
# bash-safety — tehlikeli komutları engeller.
# FIX v4: git push --tags çakışması düzeltildi.
#
# SORUN (v2/v3): settings.json allow listesinde "Bash(git push:*)" vardı.
# Bu kural her git push komutunu hook'tan önce geçiriyordu, bash-safety'nin
# 'git push.*--tags' pattern'i hiç tetiklenmiyordu.
#
# ÇÖZÜM: allow listesinden "Bash(git push:*)" kaldırıldı (bkz. settings.json).
# Granüler allow kuralları eklendi: git push origin HEAD, git push origin <branch>.
# deny listesine "Bash(git push --tags:*)" ve "Bash(git push.*--force:*)" eklendi.
# Bu hook artık git push komutlarını GERÇEKTEN görebilir.

set -euo pipefail

INPUT=$(cat)

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // .input.command // empty' 2>/dev/null || true)

if [[ -z "${CMD:-}" ]]; then
  exit 0
fi

# Yasaklı pattern'ler (öncelik sırasına göre)
BLOCKED=(
  'rm -rf /'
  'rm -rf ~/'
  'rm -rf \*'
  ':\(\)\{:\|:&\};:'
  'mkfs\.'
  'dd if=/dev/zero of='
  'curl .* \| sh'
  'curl .* \| bash'
  'wget .* \| sh'
  '> /dev/sda'
  'chmod -R 777 /'
  'find / '
  'grep -r .* /'
  'npm publish'
  # FIX v4: git push --tags artık gerçekten yakalanabilir
  # (allow listesindeki "Bash(git push:*)" kaldırıldı)
  'git push.*--tags'
  'git push.*--force[^-]'
  'git push.*--force$'
  '--force-with-lease'   # sadece uyarı, block değil (aşağıda kontrol)
)

for pattern in "${BLOCKED[@]}"; do
  if echo "$CMD" | grep -qE "$pattern"; then
    # force-with-lease için blok değil uyarı
    if [[ "$pattern" == '--force-with-lease' ]]; then
      cat <<EOF >&2
⚠️  BASH SAFETY UYARI — force-with-lease
==================================================
Komut: $CMD
Sebep: Force push tespit edildi — yıkıcı olabilir.
       Devam etmek için kullanıcı onayı gereklidir.
EOF
      continue
    fi

    cat <<EOF >&2
🛑 BASH SAFETY BLOCK
==================================================
Komut: $CMD
Sebep: '$pattern' pattern'i ile eşleşti — yıkıcı veya onay gerektiren işlem.

Bu komut için açık kullanıcı onayı gereklidir.
Güvenli bir alternatif önerin veya kullanıcıdan onay alın.

git push --tags yerine: git push origin vX.Y.Z (tek tag)
npm publish için: çift onay protokolü (CLAUDE.md)
EOF
    exit 2
  fi
done

# Uzun-süreli komutlar için uyarı (bloklamıyor)
if echo "$CMD" | grep -qE '(find\s+\.\s|sleep\s+[0-9]{3,}|while\s+true)'; then
  echo "⏱️  Uzun süreli komut tespit edildi: $CMD" >&2
  echo "    Timeout düşünün veya background'a alın." >&2
fi

exit 0
