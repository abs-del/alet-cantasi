#!/usr/bin/env bash
# session-start — StartHook: Oturum başladığında timestamp yazar.
# FIX v4: session-summary.sh'ın "1 saat sabit" hatasını çözer.
# Claude Code hook doc: StartHook her yeni oturumda tetiklenir.
#
# Timestamp dosyası: /tmp/session-start-<PPID>.ts
# PPID: Claude Code sürecinin PID'i — bu oturuma özgü sabit kalır.

set -euo pipefail

SESSION_FILE="/tmp/session-start-${PPID}.ts"

# Unix epoch timestamp yaz
date -u +%s > "$SESSION_FILE" 2>/dev/null || true

# Okunabilir versiyon da yaz (debug için)
echo "started_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$SESSION_FILE" 2>/dev/null || true

# Eski session dosyalarını temizle (1 günden eski)
find /tmp -name "session-start-*.ts" -mtime +1 -delete 2>/dev/null || true

exit 0
