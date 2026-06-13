---
description: data/audit-log.ndjson dosyasını sorgular. Vault yazım geçmişi, agent aktivitesi, conflict'ler ve release kayıtları.
argument-hint: [--vault=<VaultName>] [--event=<type>] [--last=N]
---

# /audit-log

İmmutable değişiklik günlüğünü sorgular. [YENİ v2]

## Kullanım

```
/audit-log                          # Son 20 kayıt
/audit-log --vault=PromptVault      # Belirli vault
/audit-log --event=lock_conflict    # Sadece çakışmalar
/audit-log --event=release          # Release geçmişi
/audit-log --last=50                # Son 50 kayıt
```

## Akış

```bash
# Tüm loglar
tail -20 data/audit-log.ndjson | jq .

# Vault filtresi
grep '"vault":"PromptVault"' data/audit-log.ndjson | jq . | tail -20

# Event filtresi
grep '"event":"lock_conflict"' data/audit-log.ndjson | jq . | tail -10

# Özet istatistik
jq -r '.event' data/audit-log.ndjson | sort | uniq -c | sort -rn
```

## Çıktı

```
📋 AUDIT LOG — Son 10 kayıt
══════════════════════════════════
2026-06-12T14:32:01Z  vault_write      PromptVault.html  [vault-curator]  6001 items
2026-06-12T14:31:45Z  file_write       CLAUDE.md         [unknown]
2026-06-12T14:29:12Z  lock_conflict    PromptVault       [vault-curator vs prompt-enricher] → first_wins
2026-06-12T14:15:00Z  release          v3.1.5            [qa:pass, security:pass]
...

Toplam kayıt: 847
Event dağılımı:
  vault_write:     312
  file_write:      401
  lock_conflict:    12
  release:           7
  cache_invalidate: 115
```
