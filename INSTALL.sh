#!/usr/bin/env bash
# Alet Çantası Claude Code Sistem Paketi v2 — Kurulum betiği
# Bu betik mevcut proje köküne kurar; tahrip etmez.

set -euo pipefail

cd "$(dirname "$0")"

echo "═════════════════════════════════════════════════════════"
echo "  ALET ÇANTASI v2 — Claude Code Sistem Paketi Kurulumu   "
echo "═════════════════════════════════════════════════════════"
echo ""

# 1. Claude Code kontrolü
if ! command -v claude &>/dev/null; then
  echo "❌ Claude Code CLI bulunamadı."
  echo "   Kurmak için: https://code.claude.com/docs/install"
  echo "   veya: npm install -g @anthropic-ai/claude-code"
  exit 1
fi
echo "✅ Claude Code: $(claude --version 2>/dev/null || echo 'version bilinmiyor')"

# 2. Hedef dizin
TARGET="${1:-.}"
if [[ ! -d "$TARGET" ]]; then
  echo "❌ Hedef dizin yok: $TARGET"
  exit 1
fi
TARGET=$(cd "$TARGET" && pwd)
echo "📁 Hedef: $TARGET"

# 3. Mevcut .claude/ varsa yedek al
if [[ -d "$TARGET/.claude" ]]; then
  BACKUP="$TARGET/.claude.backup-$(date +%Y%m%d-%H%M%S)"
  echo "⚠️  Mevcut .claude/ → yedek: $BACKUP"
  cp -r "$TARGET/.claude" "$BACKUP"
fi

# 4. Kopyalama
echo "📦 Dosyalar kopyalanıyor..."
cp -r .claude "$TARGET/"
cp -n CLAUDE.md "$TARGET/" 2>/dev/null || echo "   (CLAUDE.md zaten var — manuel merge edin)"
cp -n .mcp.json "$TARGET/" 2>/dev/null || echo "   (.mcp.json zaten var — atlandı)"
cp REFERENCES.md "$TARGET/" 2>/dev/null || true

# 5. Scripts dizini
if [[ -d "scripts" ]]; then
  mkdir -p "$TARGET/scripts"
  cp -r scripts/* "$TARGET/scripts/"
  echo "   ✅ scripts/ kopyalandı (bleu-check.mjs dahil)"
fi

# 6. data/ dizini (audit log için)
mkdir -p "$TARGET/data"
touch "$TARGET/data/audit-log.ndjson"
echo "   ✅ data/audit-log.ndjson oluşturuldu"

# 7. Executable bits
chmod +x "$TARGET/.claude/hooks/"*.sh 2>/dev/null || true
chmod +x "$TARGET/.claude/skills/vault-inspector/scripts/"*.sh 2>/dev/null || true

# 8. Bağımlılık kontrolleri
echo ""
echo "🔍 Bağımlılıklar:"
for cmd in jq rg node npm git bc; do
  if command -v "$cmd" &>/dev/null; then
    echo "   ✅ $cmd"
  else
    echo "   ⚠️  $cmd YOK — bazı özellikler çalışmayabilir"
  fi
done

# 9. Node.js versiyonu (bleu-check.mjs için)
if command -v node &>/dev/null; then
  NODE_VER=$(node --version)
  echo "   ✅ Node.js $NODE_VER (bleu-check.mjs için gerekli)"
fi

# 10. Opsiyonel CLI'lar
echo ""
echo "🔧 Opsiyonel CLI'lar:"
for cmd in codex gemini gh; do
  if command -v "$cmd" &>/dev/null; then
    echo "   ✅ $cmd"
  else
    case $cmd in
      codex) echo "   ⏳ codex → 'npm install -g @openai/codex' (opsiyonel)" ;;
      gemini) echo "   ⏳ gemini → 'npm install -g @google/gemini-cli' (opsiyonel)" ;;
      gh) echo "   ⏳ gh → GitHub Release için (opsiyonel)" ;;
    esac
  fi
done

# 11. Güvenlik notu
echo ""
echo "🔒 Güvenlik notları:"
echo "   • .mcp.json'daki filesystem server kapsam daraltıldı (read-only)"
echo "   • .env* dosyaları hem okuma hem yazmadan korunuyor"
echo "   • bash-safety.sh: npm publish ve git push --tags engellendi"
echo "   • Tam güvenlik için: /audit-security --all"

# 12. Environment
echo ""
echo "🔑 Environment (~/.zshrc veya ~/.bashrc):"
cat <<EOF
   export ANTHROPIC_API_KEY="sk-ant-..."
   export OPENAI_API_KEY="..."           # opsiyonel (codex için)
   export GEMINI_API_KEY="..."           # opsiyonel
   export OPENROUTER_API_KEY="..."       # opsiyonel
   export GITHUB_TOKEN="ghp_..."         # opsiyonel
EOF

# 13. MCP
echo ""
echo "🔌 MCP aktifleştirme:"
echo "   cd $TARGET && claude"
echo "   (başlarken .mcp.json otomatik yüklenir)"

# 14. Tamamlandı
echo ""
echo "═════════════════════════════════════════════════════════"
echo "✨ Kurulum tamamlandı! (v2 — düzeltmeler uygulandı)"
echo ""
echo "Sonraki adımlar:"
echo "   1. cd $TARGET"
echo "   2. claude"
echo "   3. /onboard            (5 dakikalık tur)"
echo "   4. /token-status       (token durumu)"
echo "   5. /audit-security --all  (ilk güvenlik taraması)"
echo ""
echo "📖 README.md'e bakın."
echo "═════════════════════════════════════════════════════════"
