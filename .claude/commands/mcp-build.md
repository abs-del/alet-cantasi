---
description: aletcantasi-mcp npm paketini sıfırdan üretir. mcp-builder agent + mcp-publisher skill kullanır.
argument-hint: [--publish]
---

# /mcp-build

Alet Çantası'nı MCP server'a dönüştür (öneri 128–138).

## Akış

1. `mcp-builder` agent çağrılır
2. `aletcantasi-mcp/` paketi üretilir (paket yapısı: src + dist + README)
3. `mcp-publisher` skill ile pre-flight checks
4. MCP Inspector ile local test
5. (`--publish` flag varsa) Kullanıcı onayı → `npm publish`

## Üretilen artefaktlar

```
aletcantasi-mcp/
├── package.json
├── src/server.ts
├── src/resources.ts
├── src/tools.ts
├── src/prompts.ts
├── dist/ (build çıktısı)
├── README.md
└── examples/claude-desktop-config.json
```

## Kullanım

```
/mcp-build              # build & test, publish ETME
/mcp-build --publish    # build & test & publish (onayla)
```

## Test çıktısı

```
🔧 MCP BUILD
═══════════════════════════════
Paket: aletcantasi-mcp@0.1.0
Resources: 52,240 öğe (100 vault)
Tools: 142 (ChainVault zincirleri)
Prompts: 6,012 (PromptVault)
Build: ✅ (dist/server.js, 124 KB)
Inspector test: ✅ (resources/list dönüyor)

Yayımlamak için: /mcp-build --publish
```
