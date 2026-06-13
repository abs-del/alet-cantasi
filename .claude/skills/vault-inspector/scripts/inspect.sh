#!/usr/bin/env bash
# vault-inspector — büyük HTML vault'unu context-friendly özetler.
set -euo pipefail

FILE="${1:-}"
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  echo "Kullanım: bash inspect.sh <VaultName.html>" >&2
  exit 1
fi

echo "═════════════════════════════════════════════════"
echo "  VAULT INSPECTOR — $FILE"
echo "═════════════════════════════════════════════════"
echo ""
echo "📏 Boyut:        $(du -h "$FILE" | cut -f1)"
echo "📃 Satır:        $(wc -l < "$FILE")"
echo "📅 Değişiklik:   $(date -r "$FILE" '+%Y-%m-%d %H:%M' 2>/dev/null || stat -f '%Sm' "$FILE")"
echo ""

# Data island konum bulma
DATA_LINE=$(grep -n -E 'id="data"|window\.__DATA__|const\s+DATA\s*=' "$FILE" | head -1 | cut -d: -f1 || echo "")
if [[ -n "$DATA_LINE" ]]; then
  echo "🎯 Data island bulundu: satır $DATA_LINE"
else
  echo "⚠️  Belirgin data island yok — inline render edilmiş olabilir."
fi
echo ""

# JSON pattern arama
if command -v jq &>/dev/null; then
  # Naive JSON extraction
  echo "🔍 Şema örnekleri (ilk 3 öğe):"
  if grep -oE '\{[^{}]*"id"[^{}]*"name"[^{}]*\}' "$FILE" | head -3 | while read -r line; do
    echo "$line" | jq -c '{id, cat, name, badge1, tags}' 2>/dev/null || echo "  (parse hatası)"
  done; then :; fi
fi
echo ""

# Etiket frekansı (öneri 82) — hızlı sayım
echo "🏷️  En sık 10 etiket:"
grep -oE '"tags"\s*:\s*\[[^]]*\]' "$FILE" 2>/dev/null \
  | grep -oE '"[^"]+"' \
  | sort | uniq -c | sort -rn | head -10 \
  | sed 's/^/   /' || echo "   (etiket bulunamadı)"
echo ""

# Kategori listesi
echo "📂 Kategoriler:"
grep -oE '"cat"\s*:\s*"[^"]+"' "$FILE" 2>/dev/null \
  | sort -u | head -20 | sed 's/^/   /' || echo "   (cat alanı yok)"
echo ""

# ID benzersizliği hızlı kontrol
TOTAL=$(grep -oE '"id"\s*:\s*"[^"]+"' "$FILE" | wc -l)
UNIQUE=$(grep -oE '"id"\s*:\s*"[^"]+"' "$FILE" | sort -u | wc -l)
echo "🔑 ID kontrolü:  $TOTAL toplam, $UNIQUE benzersiz"
if [[ "$TOTAL" -ne "$UNIQUE" ]]; then
  echo "   ⚠️  DUPLICATE ID VAR!"
fi
echo ""

echo "💡 Detay için: /vault-grep $FILE '<sorgu>'"
echo "💡 Şema değişikliği: önce vault-curator agent'ını çağırın."
