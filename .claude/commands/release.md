---
description: Yeni sürüm yayımlar. release-manager agent. CHANGELOG, semver, git tag, GitHub release. QA + Security kapıları otomatik — bypass edilemez.
argument-hint: [major|minor|patch] [--dry-run]
---

# /release

Sürüm pipeline'ı — QA ve Security kapıları otomatik ve zorunludur.

## Akış

1. **Önce QA + Security kapıları** [FIX v2 — otomatik, atlatalamaz]:
   - `qa-expert` → `npm test && npm run e2e` → tüm testler ✅ olmadan devam etmez
   - `security-auditor` → Critical: 0 olmadan devam etmez
   - Bu adım başarısız olursa release **tamamen durur**
2. `release-manager` agent spawn
3. CHANGELOG.md update (git log → manuel review)
4. semver bump (`npm version`) — kullanıcı onayı zorunlu
5. Tag + push — kullanıcı onayı zorunlu
6. GitHub Release — kullanıcı onayı zorunlu
7. (Opsiyonel) `aletcantasi-mcp` npm publish — ÇİFT ONAY

## Kullanım

```
/release minor              # 3.1.x → 3.2.0
/release patch --dry-run    # ne olacağını göster
/release major              # 3.x → 4.0 (breaking change şart!)
```

## Onay gates

| Adım | Otomatik | Onay gerekli |
|---|---|---|
| QA testleri | ✅ zorunlu otomatik | — (başarısız → STOP) |
| Security audit | ✅ zorunlu otomatik | — (critical → STOP) |
| CHANGELOG üret | ✅ | review et |
| Version bump | — | ✅ |
| Git tag (signed) | — | ✅ |
| Push | — | ✅ |
| npm publish | — | ✅ ✅ (çift onay) |
