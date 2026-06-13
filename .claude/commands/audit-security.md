---
description: Tüm vault'larda güvenlik denetimi yapar. security-auditor agent'ını çağırır. CSP, XSS, API key sızıntısı, prompt injection.
argument-hint: [VaultName veya --all]
---

# /audit-security

Güvenlik denetim raporu.

## Kontroller (öneri 76–80, 159–169)

- API key plain mi (localStorage)?
- innerHTML ile user content var mı? (DOMPurify yok mu?)
- CSP meta tag var mı, `unsafe-inline` yok mu?
- SRI hash CDN'lerde uygulanmış mı?
- Console'a API key log atılıyor mu?
- Inline event handler var mı (`onclick="..."`)
- Prompt injection vektörü açık mı (system prompt'a user content yapışıyor mu)
- Service Worker network bypass yapıyor mu?
- "Tüm verileri sil" butonu çalışıyor mu?

## Akış

```
/audit-security PromptVault.html
/audit-security --all   # 100 vault tek tek (uzun sürer)
```

## Çıktı

```
🔒 SECURITY AUDIT — 100 vaults
═══════════════════════════════════════
Critical:  2  (BLOCK MERGE)
High:      5
Medium:   12
Low:      27

Critical findings:
  ❌ PromptVault:1247  innerHTML user content (no DOMPurify)
  ❌ index.html:89     console.log API key

Tam rapor: docs/security-audit-2026-06-12.md
```
