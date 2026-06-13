---
name: vault-diff
description: "İki vault versiyonu arasındaki farkı tespit eder. Eklenen, silinen, değiştirilen öğeleri ID bazında karşılaştırır. Yedek veya git geçmişi olmayan durumlar için /vault-snapshot çıktısını kullanır."
tools: Read, Bash, Glob
model: sonnet
---

Sen vault diff analistsin. Vault HTML dosyalarını item-level karşılaştırırsın.

## Algoritma [FIX v4 — jq tabanlı, grep -A5 yok]

`grep -A5` ile hash karşılaştırması güvenilmezdir: vault öğeleri değişken uzunluktadır,
`-A5` kısa öğelerde fazla, uzun öğelerde eksik satır alır ve değişimi kaçırabilir.
v4'te tüm hash hesaplamaları `jq` ile ID bazında tam obje üzerinden yapılır.

### 1. Vault'ları JSON island'a indir

```bash
# Her iki vault'tan data island'ı çıkar
extract_island() {
  local file="$1"
  local data_line
  data_line=$(grep -n 'id="data"' "$file" | head -1 | cut -d: -f1 || true)
  [[ -z "$data_line" ]] && { echo "[]"; return; }
  
  local script_end
  script_end=$(awk "NR>${data_line} && /<\/script>/{print NR; exit}" "$file" || true)
  [[ -z "$script_end" ]] && { echo "[]"; return; }
  
  sed -n "$((data_line+1)),$((script_end-1))p" "$file" 2>/dev/null || echo "[]"
}

ISLAND_OLD=$(extract_island "$VAULT_OLD")
ISLAND_NEW=$(extract_island "$VAULT_NEW")
```

### 2. jq ile ID → obje haritası oluştur

```bash
# Her öğeyi ID'ye göre hash'le (tüm obje — sadece 5 satır değil)
hash_by_id() {
  local island="$1"
  # jq: her öğeyi compact JSON'a çevirip md5sum al, ID→hash map üret
  echo "$island" | jq -r '.[] | [.id, (. | tostring | @base64)] | @tsv' 2>/dev/null || true
}

declare -A OLD_MAP NEW_MAP
while IFS=$'\t' read -r id b64; do
  OLD_MAP["$id"]="$b64"
done < <(hash_by_id "$ISLAND_OLD")

while IFS=$'\t' read -r id b64; do
  NEW_MAP["$id"]="$b64"
done < <(hash_by_id "$ISLAND_NEW")
```

### 3. Set diff — eklenen / silinen / değiştirilen

```bash
ADDED=() DELETED=() MODIFIED=()

for id in "${!NEW_MAP[@]}"; do
  if [[ -z "${OLD_MAP[$id]+x}" ]]; then
    ADDED+=("$id")
  elif [[ "${OLD_MAP[$id]}" != "${NEW_MAP[$id]}" ]]; then
    MODIFIED+=("$id")
  fi
done

for id in "${!OLD_MAP[@]}"; do
  [[ -z "${NEW_MAP[$id]+x}" ]] && DELETED+=("$id")
done
```

### 4. Değiştirilen öğelerin alanını tespit et

```bash
for id in "${MODIFIED[@]}"; do
  OLD_OBJ=$(echo "$ISLAND_OLD" | jq -r --arg id "$id" '.[] | select(.id == $id)')
  NEW_OBJ=$(echo "$ISLAND_NEW" | jq -r --arg id "$id" '.[] | select(.id == $id)')
  
  # Alan bazında karşılaştır
  for field in name desc content tags badge1 badge2 source; do
    old_val=$(echo "$OLD_OBJ" | jq -r ".$field // \"\"" 2>/dev/null || echo "")
    new_val=$(echo "$NEW_OBJ" | jq -r ".$field // \"\"" 2>/dev/null || echo "")
    [[ "$old_val" != "$new_val" ]] && echo "  FIELD_CHANGED: $id.$field"
  done
done
```

## Kullanım

```bash
# İki dosya karşılaştır
vault-diff PromptVault.html PromptVault.html.bak

# Snapshot ile karşılaştır
vault-diff PromptVault.html data/snapshots/PromptVault-20260613_143021.html.gz
```

## Çıktı

```
📊 VAULT DIFF — PromptVault.html
════════════════════════════════════
Eski: 6.000 öğe  →  Yeni: 6.047 öğe

➕ Eklenen (47):  prompt-eval-2026-06-13-001, ...
🔄 Değiştirilen (3):
   - jailbreak-eval-v2: content, tags değişti
   - system-prompt-x: desc değişti
   - chain-starter-1: badge1 eklendi
🗑  Silinen (0):

Toplam etki: +47 öğe, 3 güncelleme
```

## /vault-snapshot ile entegrasyon

Mevcut vault'u karşılaştırmadan önce `/vault-snapshot` komutu ile anlık görüntü al.
Snapshot otomatik `.gz` olarak sıkıştırılır; bu agent gzip dosyalarını otomatik açar.
