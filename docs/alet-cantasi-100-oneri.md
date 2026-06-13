# Alet Çantası — Temel 100 Öneri

> Bu dosya projenin temel geliştirme önerilerini içerir.
> `vault-curator`, `cost-router`, `qa-expert` gibi agent'ların tasarım kararlarının referansıdır.

---

## 🗂️ Vault Mimarisi (1–20)

1. Her vault tek bir `.html` dosyasıdır — hiçbir zaman ayrı JS/CSS dosyasına bölme.
2. `<script id="data" type="application/json">` data island zorunludur.
3. Şema alanları: `id`, `cat`, `name`, `desc`, `badge1?`, `badge2?`, `tags[]`, `source`, `content`.
4. `id` formatı: `kebab-case-YYYY-MM-DD` — çakışmayı önler, sıralanabilir.
5. `tags` her zaman array olmalı — string geçmişi `vault-guardian` drift check'i yakalar.
6. `source` alanı `community` veya URL — "unknown" geçersiz.
7. Her vault'un `<title>` ve `<meta description>` alanı dolu olmalı.
8. Vault başına maksimum öğe sayısı: 10.000 (performans sınırı).
9. 5.000'i geçen vault'lar virtual scroll gerektirir — `performance-engineer` zorunlu.
10. Her vault'un `index.html`'de linki olmalı — orphan vault kabul edilmez.
11. Vault isimleri PascalCase: `PromptVault`, `ChainVault`, `RegexVault`.
12. CDN bağımlılıkları SRI hash ile kilitlenir — `integrity="sha384-..."`.
13. Her vault offline çalışabilmeli — `offline-pack` skill zorunluluğu.
14. `data/audit-log.ndjson` append-only — silme yasak, arşivleme mevcut.
15. Vault JSON'u minify edilmez — okunabilirlik > boyut optimizasyonu.
16. `badge1` öneri tipi/kategorisi, `badge2` zorluk/olgunluk seviyesi için.
17. `desc` alanı 280 karakter sınırı — tweet gibi kısa ve öz.
18. `content` alanında Markdown desteklenir ama render isteğe bağlı.
19. Her vault `data/snapshots/` altında en az 1 yedeğe sahip olmalı.
20. Vault birleştirme (merge) sadece `vault-diff` agent onayından geçtikten sonra.

---

## 🤖 Agent Tasarımı (21–40)

21. Her agent tek bir uzmanlık alanına odaklanır — `god agent` yasak.
22. Agent `model` seçimi: basit görev → `haiku`, orta → `sonnet`, karmaşık → `opus`.
23. `tools` listesi minimum tutulur — gereksiz araç = istenmeyen yan etki riski.
24. Her agent'ın `description` frontmatter'ı `cost-router`'ın karar matrisini besler.
25. Subagent spawn → her zaman `Task` tool ile, inline yürütme yasak.
26. Agent çıktısı her zaman `audit-log`'a yazılır — iz bırakmayan işlem yok.
27. Paralel task'lar için `codebase-orchestrator` zorunlu — elle paralel spawn yasak.
28. `vault-curator` her vault yazımından önce `vault-inspector` çağırır.
29. `release-manager` her release öncesi `vault-guardian` çalıştırır.
30. `cost-router` her dış API çağrısından önce bütçe kontrolü yapar.
31. Agent hata mesajları emoji prefix ile: `✅ başarı`, `⚠️ uyarı`, `🛑 blok`, `❌ hata`.
32. `gemini-delegate` ve `codex-delegate` sadece `cost-router` yönlendirmesiyle çağrılır.
33. Agent içinde `find /` veya `grep -r /` yasak — her zaman scoped.
34. Her agent markdown tablosu formatında çıktı üretir — okunabilirlik.
35. `qa-expert` her yeni vault şemasında test senaryosu üretir.
36. `refactoring-specialist` değişiklik öncesi `vault-diff` snapshot alır.
37. `i18n-translator` çeviriyi `bleu-check.mjs` ile doğrular (BLEU ≥ 0.70).
38. `security-auditor` API key varlığını asla log'a yazmaz — maskeleme zorunlu.
39. `performance-engineer` virtual scroll değişikliklerinde Playwright benchmark alır.
40. Agent koordinasyonu için `agent-memory-mesh` skill + memory MCP kullanılır.

---

## 🪝 Hook Güvenliği (41–60)

41. Her hook `set -euo pipefail` ile başlar.
42. Hook'lar kullanıcı etkileşimi gerektirmez — non-blocking çalışır.
43. `bash-safety.sh` allow listesi minimal tutulur — whitelist yaklaşımı.
44. `large-file-guard.sh` 500KB eşiği vault boyutlarına göre ayarlanabilir.
45. `vault-schema-check.sh` sadece `*Vault.html` dosyalarını kontrol eder.
46. Hook hata kodu: `0` = başarı, `1` = uyarı (devam et), `2` = blok (dur).
47. `audit-log-append.sh` timestamp ISO 8601 formatında — `date -u +%Y-%m-%dT%H:%M:%SZ`.
48. `session-summary.sh` PPID bazlı — çakışan oturumları karıştırmaz.
49. `vault-telemetry-append.sh` PII içermez — sadece dosya adı ve operasyon tipi.
50. `agent-perf-tracker.sh` OTel trace formatına uyar — gelecekte export edilebilir.
51. Hook çıktıları stderr'a gider — stdout temiz kalır, pipe'ları kırmaz.
52. Hook'lar idempotent olmalı — aynı input → aynı output.
53. `token-budget-reminder.sh` sadece toplu okuma pattern'lerinde uyarı verir.
54. Hook'lar `/tmp` dışına geçici dosya yazmaz.
55. `session-start.sh` 1 günden eski `/tmp/session-start-*.ts` dosyalarını temizler.
56. Her yeni hook mutlaka `settings.json`'a eklenir — unwired hook çalışmaz.
57. Hook test edilmeden merge kabul edilmez — `qa-expert` mock JSON ile doğrular.
58. Hook'lar `jq` yoksa graceful degrade eder — hard dependency değil.
59. `vault-schema-check.sh` data island dışındaki `"id"` false positive'lerini yakalamalı.
60. Hook zinciri toplam overhead'i < 500ms olmalı — aksi halde profil alınır.

---

## 💰 Maliyet & Performans (61–80)

61. Her dış API çağrısı öncesi `cost-router` sorgulama zorunludur.
62. `config/budget.json` monthly_usd hard limit aşılırsa tüm API çağrıları durur.
63. Semantic cache TTL: genel görevler 7 gün, volatile (haber/güncel) 1 gün.
64. Cache hit rate < %40 ise cache key stratejisi gözden geçirilir.
65. Embedding hesabı lokal önce (`Transformers.js MiniLM`), cloud fallback.
66. Token tahmini sağlayıcıya göre farklı tokenizer — claude, gpt, llama ayrı.
67. `perf-bench` komutu her major release öncesi çalıştırılır — regresyon kontrolü.
68. Virtual scroll threshold: 200 öğe üzeri zorunlu — DOM performansı.
69. Büyük batch işlemler için `/cost-check` ile ön tahmin alınır.
70. Provider health check her 5 dakikada bir — 429 → 60 saniye karaliste.
71. `agent-perf-history.json` provider kalite skorlaması — 3 başarısız → fallback.
72. CDN bağımlılıkları `preload` hint ile önceden yüklenir.
73. Vault JSON parse single-pass yapılır — çoklu parse yasak.
74. `compact-smart` komutu context 60% dolduğunda önerilir.
75. Search index lazy-build — vault açılışta değil, ilk aramada oluşturulur.
76. `offline-pack` skill web worker kullanır — UI thread bloklanmaz.
77. `bleu-check.mjs` sıfır bağımlılık — her ortamda çalışır.
78. Vault snapshot gzip sıkıştırma ile — ham HTML'in ~%15'i boyutunda.
79. Memory MCP koordinasyonu ile agent state senkronizasyonu.
80. `rag-architect` embedding index incremental güncelleme yapar — full rebuild yok.

---

## 🔒 Güvenlik (81–100)

81. API key asla vault HTML içine yazılmaz — localStorage'da şifreli saklanır.
82. `security-auditor` her release öncesi API key pattern tarar — regex: `/sk-[a-zA-Z0-9]{48}/`.
83. `bash-safety.sh` deny listesi: rm -rf /, fork bomb, dd sıfırlama, curl|sh.
84. `git push --tags` yasak — her tag ayrı push: `git push origin vX.Y.Z`.
85. `npm publish` çift onay protokolü: önce dry-run, sonra gerçek.
86. `.env*` dosyaları hem read hem write deny — settings.json enforce eder.
87. CORS, CSP header'ları her vault'ta tanımlı — inline script nonce ile.
88. SRI hash kontrolü: CDN değişikliklerinde `integrity` attribute güncellenmeli.
89. `vault-schema-check.sh` SQL/script injection pattern'lerini içerikte tarar.
90. `audit-log.ndjson` append-only — truncate veya delete hook tarafından engellenir.
91. `filesystem` MCP server `--read-only` flag ile çalışır.
92. `git push --force` ve `git push --force-with-lease` hook tarafından uyarı verir.
93. Kullanıcı onayı gerektiren aksiyonlar CLAUDE.md'de açıkça listelenir.
94. `agent-memory-mesh` içinde hassas veri tutulmaz — sadece task koordinasyonu.
95. Her dış bağlantı `fetch` MCP üzerinden — direkt network call yasak.
96. `telemetry.ndjson` PII içermez — anonim operasyon logları.
97. Vault import öncesi `vault-inspector` ile şema doğrulama zorunlu.
98. `release-manager` changelog'u otomatik oluşturur — manuel commit mesajı parse.
99. `data/snapshots/` dizini git'e commit edilmez — `.gitignore` ile hariç tutulur.
100. Her major versiyon bir `MIGRATION_GUIDE.md` içerir — geriye dönük uyumluluk.

---

*Bu dosya `vault-curator`, `release-manager` ve `qa-expert` agent'larının tasarım kararlarında başvuru kaynağıdır.*
