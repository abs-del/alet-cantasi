---
description: Lighthouse + Playwright ile vault performans benchmark. performance-engineer agent'ını çağırır.
argument-hint: [VaultName veya --all]
---

# /perf-bench

LCP, INP, CLS, bundle size, memory peak ölçer. History takip eder.

## Akış

1. `performance-engineer` agent çağrılır
2. Playwright + Lighthouse CLI ile metrikler toplanır
3. `docs/perf-history.json`'a satır eklenir
4. Önceki ölçüm ile regression varsa uyarı

## Kullanım

```
/perf-bench PromptVault.html
/perf-bench --all   # 100 vault sweep (uzun sürer)
```

## Çıktı

```
🚀 PERF BENCH — PromptVault.html
═══════════════════════════════════════
LCP:          0.9s    (target < 2.5s) ✅
INP:          80ms    (target < 200)  ✅
CLS:          0.02    (target < 0.1)  ✅
Bundle:       4.2 MB  (compressed)    ⚠️
Memory peak:  124 MB                  ✅
Lighthouse:   94                      ✅

Regression: yok (önceki: 95, sapma kabul edilebilir)
```

## CI entegrasyonu

`.github/workflows/perf.yml`:
```yaml
on: [pull_request]
jobs:
  perf:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: claude --command "/perf-bench --all"
      - uses: actions/upload-artifact@v4
        with:
          name: perf-report
          path: docs/perf-history.json
```
