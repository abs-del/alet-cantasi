---
description: "Vault'un anlık görüntüsünü alır ve sıkıştırarak saklar. vault-diff için karşılaştırma noktası oluşturur. Her vault-curator yazımı öncesi otomatik tetiklenebilir."
argument-hint: "<vault-dosyası.html> [--auto]"
---

# /vault-snapshot

Vault'un o anki halini `data/snapshots/` dizinine gzip ile sıkıştırılmış olarak kaydeder.

## Kullanım

```bash
/vault-snapshot PromptVault.html            # Manuel snapshot
/vault-snapshot ChainVault.html --auto      # Hook tetiklemesinden gelir, sessiz çalışır
/vault-snapshot all                         # Tüm vault'lar (büyük işlem — onay gerekir)
```

## Çalışma Adımları

### 1. Doğrulama

```bash
VAULT_FILE="${ARGUMENTS[0]}"
MODE="${ARGUMENTS[1]:-manual}"

if [[ ! -f "$VAULT_FILE" ]]; then
  echo "❌ Dosya bulunamadı: $VAULT_FILE" >&2
  exit 1
fi

# Vault dosyası mı kontrol et
case "$VAULT_FILE" in
  *Vault.html|*vault.html) ;;
  *) echo "⚠️  Bu dosya vault değil — snapshot yine de alınacak." ;;
esac
```

### 2. Boyut kontrolü

```bash
SIZE=$(stat -c%s "$VAULT_FILE" 2>/dev/null || stat -f%z "$VAULT_FILE" 2>/dev/null || echo 0)
SIZE_MB=$(( SIZE / 1048576 ))

if [[ $SIZE -gt $((20 * 1048576)) ]] && [[ "$MODE" != "--auto" ]]; then
  echo "⚠️  Büyük dosya: ${SIZE_MB} MB — snapshot ~$((SIZE_MB / 10)) MB yer kaplar."
  echo "    Devam etmek için 'evet' yazın."
  # Kullanıcı onayı beklenir
fi
```

### 3. Snapshot al

```bash
mkdir -p data/snapshots 2>/dev/null || true

VAULT_BASE=$(basename "$VAULT_FILE" .html)
TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)
SNAPSHOT_PATH="data/snapshots/${VAULT_BASE}-${TIMESTAMP}.html.gz"

# gzip ile sıkıştır (~10× küçülme)
gzip -9 -c "$VAULT_FILE" > "$SNAPSHOT_PATH" 2>/dev/null

SNAP_SIZE=$(stat -c%s "$SNAPSHOT_PATH" 2>/dev/null || echo 0)
SNAP_KB=$(( SNAP_SIZE / 1024 ))
```

### 4. Metadata kaydet

```bash
MANIFEST="data/snapshots/manifest.ndjson"
echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"vault\":\"$VAULT_FILE\",\"snapshot\":\"$SNAPSHOT_PATH\",\"original_bytes\":$SIZE,\"compressed_bytes\":$SNAP_SIZE,\"mode\":\"$MODE\"}" \
  >> "$MANIFEST" 2>/dev/null || true
```

### 5. Temizlik — 30 günden eski snapshot'ları sil

```bash
find data/snapshots -name "*.html.gz" -mtime +30 -delete 2>/dev/null || true
```

## vault-diff ile kullanım

```bash
# En son snapshot'a karşı diff
LATEST_SNAP=$(ls -t data/snapshots/PromptVault-*.html.gz 2>/dev/null | head -1)
/vault-diff PromptVault.html "$LATEST_SNAP"

# Vault-diff agent otomatik olarak .gz dosyalarını açar:
# zcat "$LATEST_SNAP" > /tmp/vault-snap-$$.html
```

## Otomatik tetik (PreToolUse hook)

`settings.json`'da PreToolUse → vault-curator yazmadan önce otomatik snapshot:

```bash
# vault-auto-snapshot.sh PreToolUse hook
# vault-curator agent'ı Edit/Write yapmadan önce snapshot alır
TOOL=$(cat | jq -r '.tool_name')
FILE=$(cat | jq -r '.tool_input.file_path // empty')

case "$FILE" in
  *Vault.html)
    bash .claude/commands/vault-snapshot.sh "$FILE" --auto >&2 || true
    ;;
esac
exit 0
```

## Çıktı

```
📸 VAULT SNAPSHOT
════════════════════════════════
Vault:     PromptVault.html (11.4 MB)
Snapshot:  data/snapshots/PromptVault-20260613_143021.html.gz
Boyut:     1.1 MB (sıkıştırma: ~10×)
Manifest:  data/snapshots/manifest.ndjson (+1 kayıt)

Karşılaştırma için:
  vault-diff agent → dosyaları otomatik karşılaştırır
  Son 5 snapshot: ls -t data/snapshots/PromptVault-*.html.gz | head -5
```
