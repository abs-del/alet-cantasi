---
description: Vault HTML'i tek seferde okumadan içinde arama yapar. ripgrep + jq ile context-friendly sonuç döner.
argument-hint: <VaultName.html> "<arama sorgusu>"
---

# /vault-grep

Büyük vault dosyalarında context'i koruyarak arama.

## Akış

```bash
# 1. Pattern ile satır bul
rg -n "$2" "$1" | head -30

# 2. Etrafındaki JSON object'i çıkar
# (her hit için -B 2 -A 10 lines)
rg -n -B 2 -A 10 "$2" "$1" | head -100

# 3. jq ile parse'a uğraş (best-effort)
```

## Kullanım

```
/vault-grep PromptVault.html "jailbreak"
/vault-grep ChainVault.html "research"
```

## Çıktı

İlk 10 eşleşme, her birinin ~5 satır bağlamı + dosya:satır numarası.

**Asla** 12 MB dosyayı tamamen okumaz.
