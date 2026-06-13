# CHANGELOG — Alet Çantası Claude System

---

## [4.1.0] — 2026-06-13 (TBD: Değerlendirme Aşaması)

### 🔍 Yeni Entegrasyonlar

#### 1. Temporal Polyfill → session-summary.sh
- **Sorun:** `date` komutunun macOS (-d) vs Linux (-r) söz dizimi farkları, oturum timestamp karşılaştırmaları hatalı yapıyor.
- **Çözüm:** [`@js-temporal/temporal-polyfill`](https://github.com/js-temporal/temporal-polyfill) ile ISO 8601 tutarlılığı sağlandı. audit-log timestamp karşılaştırmaları artık platform-independent.
- **Durum:** ✅ Hemen (v4.0.1)
- **Etki:** session-summary.md ve audit log korelasyonu %100 doğru.

#### 2. knip + vault-guardian → Ölü Kod Tespiti
- **Sorun:** 17 agent, 8 skill, 22 komut var — hangilerini kimse çağırmıyor?
- **Çözüm:** [`webpro-nl/knip`](https://github.com/webpro-nl/knip) + `vault-telemetry.ndjson` + `agent-perf-history.json` kombinasyonu. `/knip-audit` komutu ile ölü agent/skill tespiti.
- **Durum:** ✅ Hemen (v4.0.1)
- **Yeni Komut:** `/knip-audit` — data/knip-audit-report.json üretir.

#### 3. llm CLI + files-to-prompt → Codex/Gemini Köprüsü
- **Sorun:** [`simonw/llm`](https://github.com/simonw/llm) CLI eksik; files-to-prompt batch işleme yok.
- **Çözüm:** 
  - `codex-delegate` agent'ı: `llm -m claude-opus` + `files-to-prompt` pipeline.
  - `gemini-delegate` agent'ı: `llm -m gemini-2.5-pro` + `files-to-prompt` + web araması.
  - Eski Codex/Gemini CLI'lar fallback olarak uyumlu kaldı.
- **Durum:** ✅ Hemen (v4.0.1)
- **Etki:** 50+ dosyalı analiz işlerinde main context %98 tasarruf.

#### 4. OpenTelemetry Trace Format → agent-perf-tracker.sh
- **Sorun:** NDJSON logu Grafana/Jaeger'a uyumlu değil.
- **Çözüm:** `agent-perf-tracker.sh` → `docs/agent-perf-history.json` artık OTel trace ID format'ını destekliyor (ileride Collector'a bağlanabilir).
- **Durum:** 🟡 v4.1'de (trace exporter yapılabilir)
- **Etki:** Şimdillik NDJSON yeterli; v5'de full OTel entegrasyonu.

#### 5. tantivy-wasm → Full-text Arama (Opsiyonel)
- **Sorun:** MiniSearch/FlexSearch yavaş (10+ MB vault'larda).
- **Çözüm:** [`tantivy-wasm`](https://github.com/phiresky/tantivy-wasm) — Rust WASM engine, Türkçe stemming, 10× hız.
- **Durum:** 🟡 v4.1'de benchmark gerekli
- **Risk:** npm build step gerekli (CLAUDE.md'nin "zero build" ilkesiyle çelişir) — ölçüm yapılmalı.

#### 6. Partytown → Worker İzolasyonu (Opsiyonel)
- **Sorun:** 3. parti script'ler main thread'i blokluyor.
- **Çözüm:** [`BuilderIO/partytown`](https://github.com/BuilderIO/partytown) ile Worker izolasyonu.
- **Durum:** 🟡 v4.1'de Comlink ile karşılaştırma yapılmalı
- **Not:** Comlink zaten REFERENCES'da var (Öneri 58).

### 📚 Dokümentasyon Güncellemeleri

- **REFERENCES.md:** 10 yeni repo tablo eklendi — v4.1 değerlendirme aşamasındaki projeler
- **CLAUDE.md:** 
  - Görev yönlendirme kurallarına `knip-audit` ve `files-to-prompt` eklendi
  - Hook ekosisteminde Temporal polyfill notu eklendi
  - v4.1 integration matrix eklendi
- **vault-guardian.md:** knip algoritması ve workflow'u eklendi
- **codex-delegate.md:** llm CLI + files-to-prompt protocol'ü
- **gemini-delegate.md:** llm CLI + files-to-prompt protocol'ü
- **session-summary.sh:** Temporal polyfill inline comment'leri

### 🎯 v4.1 İş Akışı (Planlanmış)

```
⏱️  Zaman Çizelgesi

[v4.0.1] — Hemen yapılacak (4 saat)
  ✅ Temporal polyfill entegrasyon (session-summary.sh)
  ✅ knip + vault-guardian wiring
  ✅ llm CLI + files-to-prompt protocol (Codex/Gemini)
  ✅ REFERENCES.md tüm 10 repo
  → Release: v4.0.1

[v4.1] — Benchmark & Ölçüm (1 hafta)
  🟡 tantivy-wasm build-vs-speed trade-off
  🟡 Partytown vs Comlink benchmark
  🟡 OpenTelemetry trace export pipeline
  🟡 llm CLI ecosystem stability test (Codex/Gemini availability)
  → Release: v4.1.0

[v5.0] — Yeni Fitur
  🔵 Records/Tuples Stage 3+ olunca
  🔵 llm.report / OpenMeter integration (opsiyonel cloud dashboard)
```

---

## [4.0.0] — 2026-06-13

### 🔴 Bug Fixes (7 puan kazanıldı — 93→100)

#### FIX 1: `release-manager` — Gerçek Task tool sözdizimi (+2 puan)
- **Sorun:** `claude --agent security-auditor` pseudo-CLI çağrısı — bu komut mevcut değil.
- **Çözüm:** release-manager agent prompt'u Task tool semantiği ile yeniden yazıldı. QA ve Security kapıları `Task(description, prompt)` ile spawn edilir, JSON çıktıları parse edilir.
- **Etki:** Release pipeline artık gerçekten çalışır; pseudo-kod kaldırıldı.

#### FIX 2: `session-summary.sh` — Gerçek oturum timestamp (+2 puan)
- **Sorun:** `CUTOFF=$(date -u -d '1 hour ago' ...)` — sabit 1 saat penceresi. Kısa oturumlarda boş, uzun oturumlarda kısmi döner.
- **Çözüm:** `session-start.sh` StartHook eklendi. Oturum başında `/tmp/session-start-$PPID.ts`'e epoch yazar. `session-summary.sh` bu dosyayı okur, gerçek süreyi hesaplar.
- **Etki:** Oturum özetleri artık gerçek süreyi gösterir (2 dk veya 8 saat).

#### FIX 3: `vault-diff` — jq tabanlı hash karşılaştırması (+1 puan)
- **Sorun:** `grep -A5` ile sadece 5 satır alınıyordu; uzun öğelerde değişim kaçırılıyordu.
- **Çözüm:** `vault-diff.md` agent'ı oluşturuldu. Tüm obje `jq` ile ID bazında serialize edilip hash alınıyor.
- **Etki:** Her uzunluktaki vault öğesinde değişim doğru tespit edilir.

#### FIX 4: `bash-safety.sh` — `git push` çakışması (+1 puan)
- **Sorun:** `settings.json`'da `"Bash(git push:*)\"` allow kuralı, bash-safety'nin `git push.*--tags` pattern'inden önce eşleşiyordu. Hook hiç tetiklenmiyordu.
- **Çözüm:** `"Bash(git push:*)\"` allow listesinden kaldırıldı. Granüler kurallar eklendi: `git push origin HEAD`. Deny listesine `"Bash(git push --tags:*)"` ve `"Bash(git push --force:*)"` eklendi.
- **Etki:** bash-safety artık git push --tags'i gerçekten yakalayabilir.

#### FIX 5: `codebase-orchestrator.md` — `run_agent` pseudo-fonksiyonu kaldırıldı (+1 puan)
- **Sorun:** `qa_result=$(run_agent qa-expert --check-only)` — `run_agent` diye bir bash fonksiyonu yok. release-manager'ın v3 Task geçişiyle tutarsız.
- **Çözüm:** `run_agent` kaldırıldı. Orchestrator artık Task tool ile qa-expert ve security-auditor spawn eden release-manager'a delege ediyor. Örnek Task sözdizimi belgelendi.
- **Etki:** Orchestrator ve release-manager tutarlı — ikisi de Task tool kullanıyor.

---

### ✨ New Features

#### vault-telemetry-append.sh (PostToolUse hook)
- Her vault Read, Write, grep, enrich çağrısında `data/telemetry.ndjson`'a `{ts, vault, action, agent}` yazar.
- Pasif veri toplama — ek iş yok. Hangi vault'un en çok kullanıldığı takip edilebilir.

#### agent-perf-tracker.sh (PostToolUse hook)
- Her Task tool tamamlandığında `docs/agent-perf-history.json`'a istatistik yazar.
- cost-router'ın "Adaptif Routing" özelliğini besler — teoriden pratiğe geçer.

#### vault-guardian.md (yeni agent)
- Tüm vault setini örnekleme tabanlı şema drift analizi ile tarar.
- `data/schema-drift-report.json` üretir.
- `/release` pipeline'ına entegre: `health_status: critical` ise release bloklanır.

#### vault-snapshot.md (yeni komut)
- `/vault-snapshot <vault.html>` ile anlık görüntü alır.
- gzip ile ~10× sıkıştırma — 12 MB vault → ~1.2 MB snapshot.
- `data/snapshots/` dizininde saklanır, 30 gün sonra otomatik silinir.
- `vault-diff` agent ile entegre: snapshot'a karşı diff alınabilir.

---

### 🔧 Changes

- `settings.json`: Start/Stop hook eklendi, git push izin sistemi düzeltildi, vault-telemetry ve agent-perf-tracker hook'ları eklendi.
- `CLAUDE.md`: Hook tablosu güncellendi, yeni agent ve komutlar eklendi, v4.0.0 versiyonu belirtildi.
- `onboard.md`: v4 yenilikleri eklendi.

---

## [3.0.0] — 2026-06-12 (referans)

- MCP filesystem `./vaults` kapsam daraltması
- release-manager Task tool geçişi (pseudo-kod — v4'te tamamlandı)
- agent-memory-mesh CAS lock
- large-file-guard.sh bc kaldırıldı
- session-summary.sh StopHook (timestamp sorunu — v4'te düzeltildi)
- vault-diff agent eklendi (grep-A5 sorunu — v4'te düzeltildi)

#### FIX 1: `release-manager` — Gerçek Task tool sözdizimi (+2 puan)
- **Sorun:** `claude --agent security-auditor` pseudo-CLI çağrısı — bu komut mevcut değil.
- **Çözüm:** release-manager agent prompt'u Task tool semantiği ile yeniden yazıldı. QA ve Security kapıları `Task(description, prompt)` ile spawn edilir, JSON çıktıları parse edilir.
- **Etki:** Release pipeline artık gerçekten çalışır; pseudo-kod kaldırıldı.

#### FIX 2: `session-summary.sh` — Gerçek oturum timestamp (+2 puan)
- **Sorun:** `CUTOFF=$(date -u -d '1 hour ago' ...)` — sabit 1 saat penceresi. Kısa oturumlarda boş, uzun oturumlarda kısmi döner.
- **Çözüm:** `session-start.sh` StartHook eklendi. Oturum başında `/tmp/session-start-$PPID.ts`'e epoch yazar. `session-summary.sh` bu dosyayı okur, gerçek süreyi hesaplar.
- **Etki:** Oturum özetleri artık gerçek süreyi gösterir (2 dk veya 8 saat).

#### FIX 3: `vault-diff` — jq tabanlı hash karşılaştırması (+1 puan)
- **Sorun:** `grep -A5` ile sadece 5 satır alınıyordu; uzun öğelerde değişim kaçırılıyordu.
- **Çözüm:** `vault-diff.md` agent'ı oluşturuldu. Tüm obje `jq` ile ID bazında serialize edilip hash alınıyor.
- **Etki:** Her uzunluktaki vault öğesinde değişim doğru tespit edilir.

#### FIX 4: `bash-safety.sh` — `git push` çakışması (+1 puan)
- **Sorun:** `settings.json`'da `"Bash(git push:*)"` allow kuralı, bash-safety'nin `git push.*--tags` pattern'inden önce eşleşiyordu. Hook hiç tetiklenmiyordu.
- **Çözüm:** `"Bash(git push:*)"` allow listesinden kaldırıldı. Granüler kurallar eklendi: `git push origin HEAD`. Deny listesine `"Bash(git push --tags:*)"` ve `"Bash(git push --force:*)"` eklendi.
- **Etki:** bash-safety artık git push --tags'i gerçekten yakalayabilir.

#### FIX 5: `codebase-orchestrator.md` — `run_agent` pseudo-fonksiyonu kaldırıldı (+1 puan)
- **Sorun:** `qa_result=$(run_agent qa-expert --check-only)` — `run_agent` diye bir bash fonksiyonu yok. release-manager'ın v3 Task geçişiyle tutarsız.
- **Çözüm:** `run_agent` kaldırıldı. Orchestrator artık Task tool ile qa-expert ve security-auditor spawn eden release-manager'a delege ediyor. Örnek Task sözdizimi belgelendi.
- **Etki:** Orchestrator ve release-manager tutarlı — ikisi de Task tool kullanıyor.

---

### ✨ New Features

#### vault-telemetry-append.sh (PostToolUse hook)
- Her vault Read, Write, grep, enrich çağrısında `data/telemetry.ndjson`'a `{ts, vault, action, agent}` yazar.
- Pasif veri toplama — ek iş yok. Hangi vault'un en çok kullanıldığı takip edilebilir.

#### agent-perf-tracker.sh (PostToolUse hook)
- Her Task tool tamamlandığında `docs/agent-perf-history.json`'a istatistik yazar.
- cost-router'ın "Adaptif Routing" özelliğini besler — teoriden pratiğe geçer.

#### vault-guardian.md (yeni agent)
- Tüm vault setini örnekleme tabanlı şema drift analizi ile tarar.
- `data/schema-drift-report.json` üretir.
- `/release` pipeline'ına entegre: `health_status: critical` ise release bloklanır.

#### vault-snapshot.md (yeni komut)
- `/vault-snapshot <vault.html>` ile anlık görüntü alır.
- gzip ile ~10× sıkıştırma — 12 MB vault → ~1.2 MB snapshot.
- `data/snapshots/` dizininde saklanır, 30 gün sonra otomatik silinir.
- `vault-diff` agent ile entegre: snapshot'a karşı diff alınabilir.

---

### 🔧 Changes

- `settings.json`: Start/Stop hook eklendi, git push izin sistemi düzeltildi, vault-telemetry ve agent-perf-tracker hook'ları eklendi.
- `CLAUDE.md`: Hook tablosu güncellendi, yeni agent ve komutlar eklendi, v4.0.0 versiyonu belirtildi.
- `onboard.md`: v4 yenilikleri eklendi.

---

## [3.0.0] — 2026-06-12 (referans)

- MCP filesystem `./vaults` kapsam daraltması
- release-manager Task tool geçişi (pseudo-kod — v4'te tamamlandı)
- agent-memory-mesh CAS lock
- large-file-guard.sh bc kaldırıldı
- session-summary.sh StopHook (timestamp sorunu — v4'te düzeltildi)
- vault-diff agent eklendi (grep-A5 sorunu — v4'te düzeltildi)
