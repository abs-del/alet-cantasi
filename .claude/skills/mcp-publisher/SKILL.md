---
name: mcp-publisher
description: aletcantasi-mcp npm paketini üretip yayımlama hazırlığı yapar. Vault'ları MCP resources/tools/prompts olarak expose eder. Claude Desktop, Cursor, Zed entegrasyonu için.
---

# MCP Publisher Skill

`mcp-builder` agent'ının ürettiği paketi npm-ready hale getirir, test eder, marketplace metadata'sı hazırlar.

## Pre-flight checklist

- [ ] `package.json` doğru: `bin`, `main`, `type: "module"`, `exports`
- [ ] `LICENSE` MIT veya Apache-2.0
- [ ] README.md kurulum + örnek + screenshot içerir
- [ ] `peerDependencies`: `@modelcontextprotocol/sdk` ^1.0
- [ ] CI: GitHub Actions ile `npm test` her PR'da
- [ ] semver kuralları → release-manager onayı

## Paket yapısı

```
aletcantasi-mcp/
├── package.json
├── LICENSE
├── README.md
├── CHANGELOG.md
├── tsconfig.json
├── src/
│   ├── server.ts
│   ├── resources.ts
│   ├── tools.ts
│   ├── prompts.ts
│   └── loaders/vault-loader.ts
├── dist/                  # build output
└── examples/
    ├── claude-desktop-config.json
    ├── cursor-config.json
    └── zed-config.json
```

## Local test (kullanıcı yayımlamadan önce)

```bash
# Build
npm run build

# MCP Inspector ile test
npx @modelcontextprotocol/inspector node dist/server.js
# Browser'da Inspector açılır, tüm resources/tools/prompts listelenir.

# Claude Desktop'ta dene (yayımlamadan)
# claude_desktop_config.json:
{
  "mcpServers": {
    "aletcantasi-dev": {
      "command": "node",
      "args": ["/full/path/to/dist/server.js"],
      "env": { "ALETCANTASI_VAULT_DIR": "/path/to/alet-cantasi" }
    }
  }
}
```

## Publish (onaylanırsa)

```bash
# 1. Versiyon
npm version minor

# 2. Tag + push
git push origin main --tags

# 3. npm publish
npm publish --access public

# 4. GitHub Release
gh release create v0.1.0 --notes-file CHANGELOG.md
```

## Marketplace başlığı (gelecek MCP marketplace)

```yaml
name: aletcantasi-mcp
display_name: Alet Çantası (100 Vault Toolkit)
description: |
  Expose 100 specialized vaults (PromptVault, ChainVault, RegexVault, ...)
  as MCP resources, tools, and prompts. Local-first, no server.
categories: [productivity, knowledge-base, ai-prompts]
homepage: https://github.com/USER/alet-cantasi
license: MIT
tested_clients:
  - claude-desktop
  - cursor
  - zed
  - continue
```

## Sınırlar

- Asla `npm publish` kendiliğinden çalıştırma. Kullanıcı onayı şart.
- `.env` veya API key dosyalarını paketleme — `.npmignore` zorunlu.
- Vault verisi paketin içine gömülmemeli — kullanıcı kendi dizinini `env` ile gösterir.
- Beta yayını için: `npm publish --tag beta`.
