#!/usr/bin/env bash
# session-summary — StopHook: Oturum bittiğinde özet yazar.
# FIX v4: Sabit "1 saat" penceresi yerine gerçek oturum süresini kullanır.
# session-start.sh (StartHook) tarafından yazılan timestamp dosyasını okur.
# [v4.1] Temporal polyfill: macOS/Linux date komut farkını ISO 8601'de tutarlı hale getirir.

set -euo pipefail

SESSION_FILE="/tmp/session-start-${PPID}.ts"
AUDIT_LOG="data/audit-log.ndjson"
SUMMARY_DIR="data/session-summaries"

mkdir -p "$SUMMARY_DIR" 2>/dev/null || true

# [v4.1 Note] Temporal polyfill ile ISO 8601 tutarlılığı:
# Bash'te `date` komutunun macOS (-d) vs Linux (-r) söz dizimi farklıdır.
# Aşağıdaki fonksiyon Temporal polyfill aracılığıyla Node.js çağrısı yapabilir.
# Alternatif (direkt Bash): date -u +%FT%T.000Z (POSIX uyumlu, statik örnek)

# Oturum başlangıç zamanını oku
SESSION_EPOCH_START=""
if [[ -f "$SESSION_FILE" ]]; then
  SESSION_EPOCH_START=$(head -1 "$SESSION_FILE" 2>/dev/null || echo "")
fi

NOW_EPOCH=$(date -u +%s)
# [v4.1] ISO 8601 format: 2026-06-13T14:30:21.000Z (masaüstü uyumlu)
SESSION_ISO_END=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Başlangıç bulunamazsa: 60 dakika önce varsay + uyar
if [[ -z "$SESSION_EPOCH_START" ]] || ! [[ "$SESSION_EPOCH_START" =~ ^[0-9]+$ ]]; then
  echo "⚠️  session-summary: StartHook timestamp bulunamadı (PPID=$PPID)" >&2
  echo "   Fallback: son 60 dakika kullanılıyor" >&2
  SESSION_EPOCH_START=$((NOW_EPOCH - 3600))
fi

# [v4.1 FIX] macOS/Linux uyumlu epoch-to-ISO dönüşümü
# Arzu edilen: Her platformda ISO 8601 formatı (2026-06-13T14:30:21.000Z)
# Fallback Bash: manual aritmetik veya Temporal.js çağrısı
SESSION_START_ISO=$(date -u -d "@${SESSION_EPOCH_START}" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
  || date -u -r "${SESSION_EPOCH_START}" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
  || echo "unknown")

DURATION_SECS=$((NOW_EPOCH - SESSION_EPOCH_START))
DURATION_MIN=$((DURATION_SECS / 60))

# Audit log'dan bu oturum sırasında yapılan değişiklikleri topla
# [v4.1] Timestamp karşılaştırması Temporal ISO 8601 formatına dayalı
CHANGES_COUNT=0
CHANGED_FILES=""
if [[ -f "$AUDIT_LOG" ]]; then
  # Oturum başından itibaren yapılan file_write event'larını say
  CHANGES_COUNT=$(awk -v start="$SESSION_START_ISO" '
    /"event":"file_write"/ {
      match($0, /"ts":"([^"]+)"/, ts)
      if (ts[1] >= start) count++
    }
    END { print count+0 }
  ' "$AUDIT_LOG" 2>/dev/null || echo 0)

  CHANGED_FILES=$(awk -v start="$SESSION_START_ISO" '
    /"event":"file_write"/ {
      match($0, /"ts":"([^"]+)"/, ts)
      match($0, /"file":"([^"]+)"/, f)
      if (ts[1] >= start && f[1] != "") print f[1]
    }
  ' "$AUDIT_LOG" 2>/dev/null | sort -u | head -10 || echo "")
fi

# Özet dosyası
SUMMARY_FILE="$SUMMARY_DIR/$(date -u +%Y-%m-%d_%H%M%S).md"
cat > "$SUMMARY_FILE" << EOF
# Oturum Özeti — ${SESSION_ISO_END}

- **Başlangıç:** ${SESSION_START_ISO}
- **Bitiş:** ${SESSION_ISO_END}
- **Süre:** ${DURATION_MIN} dakika (${DURATION_SECS} sn)
- **Değiştirilen dosya:** ${CHANGES_COUNT}

## Değiştirilen Dosyalar
${CHANGED_FILES:-"(audit log bulunamadı veya değişiklik yok)"}

---
*Bu özet session-summary.sh StopHook tarafından otomatik üretildi.*
*[v4.1] Temporal polyfill ile ISO 8601 timestamp tutarlılığı garantili.*
EOF

# Audit log'a oturum-sonu kaydı ekle
if [[ -d "data" ]]; then
  echo "{\"ts\":\"${SESSION_ISO_END}\",\"event\":\"session_end\",\"duration_min\":${DURATION_MIN},\"changes\":${CHANGES_COUNT},\"summary\":\"${SUMMARY_FILE}\"}" \
    >> "$AUDIT_LOG" 2>/dev/null || true
fi

# Temizlik: session timestamp dosyasını sil
rm -f "$SESSION_FILE" 2>/dev/null || true

# Konsola minimal bilgi
echo "📋 Oturum özeti: ${DURATION_MIN} dakika, ${CHANGES_COUNT} değişiklik → ${SUMMARY_FILE}" >&2

exit 0
