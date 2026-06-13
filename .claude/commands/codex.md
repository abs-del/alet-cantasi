---
description: Görevi OpenAI Codex CLI'ya pasla. Ana Claude context'ini koru. codex-delegate agent'ı kullanır.
argument-hint: "<görev>"
---

# /codex

Ağır kod analizi / refactor görevini Codex'e delege et.

## Ne zaman kullan

- 30+ dosya tarama (Claude context yorulur)
- Big refactor (TypeScript strict, async migration)
- "İkinci bir görüş" gerekiyor (architectural review)

## Akış

1. `codex-delegate` agent spawn edilir
2. Codex CLI veya `clink` (PAL MCP) üzerinden çağrı
3. Codex bağımsız context'te çalışır
4. Sonuç **özet** olarak Claude'a döner (max 500 token)
5. Patch önerisi varsa diff olarak gösterilir, onay istenir

## Kullanım

```
/codex "src/ altındaki tüm fetch çağrılarını AbortController desteğine geçir"
/codex "PromptVault.html'deki XSS riskini denetle, DOMPurify entegrasyonu öner"
```

## Önkoşul

```bash
# Codex CLI kurulu mu?
which codex || npm install -g @openai/codex

# Auth
codex login   # OAuth ile
```

Codex bulunmuyorsa otomatik `/gemini`'ye fallback önerilir.
