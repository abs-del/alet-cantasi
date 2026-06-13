#!/usr/bin/env node
// scripts/bleu-check.mjs — Back-translation kalite skoru (BLEU-light)
// Kullanım: node bleu-check.mjs "Orijinal metin" "Geri çevrilmiş metin"
// Çıktı: 0.00 - 1.00 (>= 0.70 geçti)
// Bağımlılık yok — vanilla Node.js

function tokenize(text) {
  return text.toLowerCase()
    .replace(/[.,!?;:"""''()\[\]{}]/g, ' ')
    .split(/\s+/)
    .filter(t => t.length > 0);
}

function getNgrams(tokens, n) {
  const ngrams = {};
  for (let i = 0; i <= tokens.length - n; i++) {
    const gram = tokens.slice(i, i + n).join(' ');
    ngrams[gram] = (ngrams[gram] || 0) + 1;
  }
  return ngrams;
}

function ngramPrecision(candidate, reference, n) {
  const cands = getNgrams(candidate, n);
  const refs = getNgrams(reference, n);
  let matches = 0, total = 0;
  for (const [gram, count] of Object.entries(cands)) {
    matches += Math.min(count, refs[gram] || 0);
    total += count;
  }
  return total === 0 ? 0 : matches / total;
}

function brevityPenalty(candidate, reference) {
  const c = candidate.length;
  const r = reference.length;
  return c >= r ? 1 : Math.exp(1 - r / c);
}

function bleuLight(original, backTranslated) {
  const origTok = tokenize(original);
  const backTok = tokenize(backTranslated);

  if (origTok.length === 0 || backTok.length === 0) return 0;

  const p1 = ngramPrecision(backTok, origTok, 1);
  const p2 = ngramPrecision(backTok, origTok, 2);
  const bp = brevityPenalty(backTok, origTok);

  // Geometrik ortalama (p2 yoksa sadece p1)
  const geo = p2 > 0 ? Math.sqrt(p1 * p2) : p1;
  return Number((bp * geo).toFixed(4));
}

// CLI kullanımı
const [,, original, backTranslated] = process.argv;

if (!original || !backTranslated) {
  console.error('Kullanım: node bleu-check.mjs "Orijinal" "Geri çeviri"');
  process.exit(1);
}

const score = bleuLight(original, backTranslated);
const passed = score >= 0.70;

console.log(score.toFixed(4));
console.error(`BLEU-light: ${score.toFixed(4)} — ${passed ? '✅ Geçti (>= 0.70)' : '❌ Reddedildi (< 0.70)'}`);

process.exit(passed ? 0 : 1);
