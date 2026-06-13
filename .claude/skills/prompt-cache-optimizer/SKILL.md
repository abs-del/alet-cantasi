---
name: prompt-cache-optimizer
description: Anthropic API çağrılarında prompt caching uygulayarak %90'a kadar maliyet tasarrufu sağlar (öneri 113). 1024+ token sabit içeriklere otomatik cache_control marker ekler.
---

# Prompt Cache Optimizer Skill

Anthropic'in [prompt caching](https://platform.claude.com/docs/build-with-claude/prompt-caching) özelliğini doğru yerlere yerleştirir.

## Cache nereye konur?

```
[system message] ← uzun, sabit (binlerce token) → CACHE
[tools array]    ← sabit → CACHE
[user message: ön bağlam] ← sabit, birden fazla turn'de aynı → CACHE
[user message: anlık soru]   ← değişken → cache'lenmez
```

## Marker uygulama kuralı

1. Mesaj/içerik 1024 token'dan kısaysa cache'leme — gain yok.
2. 1024+ token ise `cache_control: {type: "ephemeral"}` ekle.
3. En fazla 4 cache breakpoint izinli (Anthropic limiti).
4. TTL: 5 dakika (default) veya `cache_control.ttl: "1h"`.

## Kod örneği

```js
const messages = [
  {
    role: "user",
    content: [
      {
        type: "text",
        text: longContextDocument,  // 5000+ token
        cache_control: { type: "ephemeral" }  // ← marker
      },
      {
        type: "text",
        text: userQuestion  // 50 token
      }
    ]
  }
];

const response = await client.messages.create({
  model: "claude-sonnet-4-6",
  max_tokens: 1024,
  system: [
    {
      type: "text",
      text: systemPrompt,
      cache_control: { type: "ephemeral" }
    }
  ],
  messages
});

console.log("cache_creation_input_tokens:", response.usage.cache_creation_input_tokens);
console.log("cache_read_input_tokens:", response.usage.cache_read_input_tokens);
```

## Hit rate dashboard

Her API çağrısı sonrası `cache_creation` ve `cache_read` token'ları DuckDB'ye yazılır:

```sql
SELECT
  date_trunc('day', timestamp) AS day,
  SUM(cache_read_input_tokens) AS cache_hits,
  SUM(cache_creation_input_tokens) AS cache_writes,
  SUM(input_tokens) AS uncached,
  (SUM(cache_read_input_tokens)::FLOAT / SUM(input_tokens + cache_read_input_tokens)) AS hit_rate
FROM api_calls
GROUP BY day;
```

UI'da gösterim: "Bugün %78 cache hit, ~$3.40 tasarruf" (öneri 156).

## Kontrol listesi

Skill çalıştırıldığında şu kontroller yapılır:
- [ ] System mesajı 1024+ token? → cache marker ekle
- [ ] Tools tanımı sabit mi? → cache marker ekle
- [ ] Aynı kullanıcının ardışık mesajlarında ortak bağlam var mı? → ortak parça cache'lenebilir
- [ ] Maksimum 4 breakpoint aşıldı mı? → en uzun olanlar kalır

## Anti-pattern

- Cache marker'ı user'ın anlık sorusuna koyma — her seferde değişir, miss → boş cache write.
- TTL'i 1h yapmak (premium) ama 5 dakikada bir farklı bağlam göndermek — boşa para.
- Cache hit/miss'i takip etmemek — tasarrufu doğrulayamazsın.

## Çıktı

```
💾 Prompt cache analizi
   System mesajı: 1847 tokens → cache eklendi
   Tools: 543 tokens → cache eklenemedi (< 1024)
   User context: 3210 tokens → cache eklendi
   Total cache markers: 2/4

   Sonraki çağrı tahmini:
     - Cached read: 5057 tokens (×0.1 maliyet)
     - Yeni input: ~80 tokens
     - Tahmini tasarruf: $0.012/çağrı
     - 100 çağrı/gün → aylık ~$36 tasarruf
```
