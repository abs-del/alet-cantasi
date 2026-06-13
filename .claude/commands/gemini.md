---
description: Görevi Google Gemini CLI'ya pasla. Web search + multimodal görev için. gemini-delegate agent kullanır.
argument-hint: "<görev>"
---

# /gemini

Güncel bilgi / web araştırma / görsel analizi → Gemini.

## Ne zaman kullan

- "2026'da X kütüphanesinin son sürümü ne?" gibi taze bilgi
- 50+ URL tarama (Claude WebFetch'i yorma)
- Görsel analizi (multimodal)
- GitHub trend repo bulma

## Akış

1. `gemini-delegate` agent spawn edilir
2. `gemini` CLI ile çağrı (`@web` tool built-in, ekstra MCP gerekmez)
3. Sonuç **özet + kaynak URL'ler** olarak döner

## Kullanım

```
/gemini "2026'da en popüler client-side vector DB'ler nelerdir?"
/gemini "PWA için OPFS quota artırma yöntemleri (2026 spec güncellemesi)"
/gemini --image cover.png "Bu görsel PromptVault için uygun mu?"
```

## Önkoşul

```bash
which gemini || npm install -g @google/gemini-cli
gemini auth   # Google OAuth
```
