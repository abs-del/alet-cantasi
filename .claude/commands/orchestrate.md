---
description: Karmaşık çok-adımlı görevler için master orchestrator. codebase-orchestrator agent'ını çağırır, plan üretir, onay alır, paralel delege eder.
argument-hint: "<hedef>"
---

# /orchestrate

Çok agent gerektiren büyük görevler için tek giriş noktası.

## Akış

1. `codebase-orchestrator` agent (Opus model) spawn edilir
2. Görevi parse eder, etki alanı çıkarır
3. Hangi alt agentlar gerekli, sırayla mı paralel mi?
4. Token bütçesi tahmini
5. Kullanıcıya plan + onay sorusu
6. Onay → paralel `Task` spawn'ları
7. Sonuçları birleştirir, özet rapor

## Kullanım

```
/orchestrate "100 vault'a hover-peek özelliği ekle, regression testi geç, v3.3.0 yayımla"
/orchestrate "PromptVault'a full RAG pipeline kur (Transformers.js + hnswlib + worker)"
```

## Tipik plan çıktısı

```
🎯 ORCHESTRATION PLAN: Add hover-peek to 100 vaults
=====================================================
Adımlar:
  1. [ui-craftsman]            → Prototip tek vault'ta              (seri)
  2. [qa-expert]               → Visual baseline                    (seri)
  3. [refactoring-specialist]  → Script ile 99 vault'a apply        (paralel A)
  4. [security-auditor]        → CSP + XSS denetimi                 (paralel A)
  5. [qa-expert]               → Regression + a11y sweep            (3+4 sonrası)
  6. [release-manager]         → CHANGELOG + v3.3.0 release         (seri son)

Token tahmini:
  - Claude main:      ~80,000 (40% of limit)
  - codex-delegate:   ~140,000 (bağımsız)
  - gemini-delegate:  ~25,000 (CSP araştırması)
Süre tahmini: ~3 saat

Risk: MEDIUM (99 vault paralel write — atomic commit zorunlu)

✅ Onayınızı bekliyorum: "go" yazın.
```

## Onay sözcükleri

- `go` / `evet` / `onay` → çalışır
- `dur` / `iptal` → çıkar
- `değiştir: <not>` → plan tekrar üretilir
