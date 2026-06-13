---
name: offline-pack
description: PWA manifest + Service Worker + Workbox runtime caching kurar. 100 vault çevrimdışı tam erişilebilir hale gelir (öneri 56 + 121). OPFS cache stratejisi.
---

# Offline Pack Skill

Alet Çantası'nı PWA'ya dönüştürür. Service worker + manifest + OPFS cache.

## Üretilecek dosyalar

```
manifest.webmanifest
sw.js                     # Service Worker (Workbox-derived)
icons/
  icon-192.png
  icon-512.png
  icon-maskable.png
offline-fallback.html     # Hiç vault yokken gösterilen sayfa
```

## manifest.webmanifest

```json
{
  "name": "Alet Çantası — 100 Vault Toolkit",
  "short_name": "AletÇantası",
  "description": "Local-first AI vault collection",
  "lang": "tr",
  "start_url": "/index.html",
  "scope": "/",
  "display": "standalone",
  "theme_color": "#0a0e1a",
  "background_color": "#0a0e1a",
  "icons": [
    { "src": "icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "icons/icon-512.png", "sizes": "512x512", "type": "image/png" },
    { "src": "icons/icon-maskable.png", "sizes": "512x512", "purpose": "maskable" }
  ],
  "categories": ["productivity", "developer", "education"],
  "shortcuts": [
    { "name": "PromptVault", "url": "/PromptVault.html" },
    { "name": "ChainVault", "url": "/ChainVault.html" }
  ]
}
```

## sw.js (cache stratejileri)

```js
// Sürüm hash — vault dosyaları değişince invalidate (öneri 62)
const VERSION = '__BUILD_HASH__';
const CACHE = `alet-${VERSION}`;

const PRECACHE = [
  '/index.html',
  '/manifest.webmanifest',
  '/offline-fallback.html',
  // Top 5 vault: kullanım analizi ile seçilir
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(PRECACHE)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k.startsWith('alet-') && k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);

  // Vault HTML → stale-while-revalidate
  if (url.pathname.endsWith('Vault.html')) {
    e.respondWith(staleWhileRevalidate(e.request));
    return;
  }

  // API çağrıları (Anthropic) → ASLA cache'leme
  if (url.host.includes('anthropic.com') || url.host.includes('openrouter.ai')) {
    return; // pass-through
  }

  // Statik asset → cache-first
  if (/\.(js|css|woff2|svg|png|webp)$/.test(url.pathname)) {
    e.respondWith(cacheFirst(e.request));
    return;
  }

  // Geri kalanı → network-first, offline fallback
  e.respondWith(
    fetch(e.request).catch(() => caches.match('/offline-fallback.html'))
  );
});

async function staleWhileRevalidate(req) {
  const cache = await caches.open(CACHE);
  const cached = await cache.match(req);
  const fetchPromise = fetch(req).then(res => {
    cache.put(req, res.clone());
    return res;
  });
  return cached || fetchPromise;
}

async function cacheFirst(req) {
  const cache = await caches.open(CACHE);
  const cached = await cache.match(req);
  if (cached) return cached;
  const res = await fetch(req);
  cache.put(req, res.clone());
  return res;
}
```

## OPFS hot cache (öneri 121)

Service Worker yetmez — büyük vault HTML'leri **Origin Private File System**'e yazılır:

```js
const opfsRoot = await navigator.storage.getDirectory();
const vaultsDir = await opfsRoot.getDirectoryHandle('vaults', { create: true });

async function cacheVaultToOPFS(name, html) {
  const fh = await vaultsDir.getFileHandle(`${name}.html`, { create: true });
  const stream = await fh.createWritable();
  await stream.write(html);
  await stream.close();
}

async function readVaultFromOPFS(name) {
  const fh = await vaultsDir.getFileHandle(`${name}.html`);
  return (await fh.getFile()).text();
}
```

İlk açılışta ağdan, sonraki açılışlarda OPFS'ten → 100× daha hızlı.

## Storage quota uyarısı

```js
const { usage, quota } = await navigator.storage.estimate();
if (usage / quota > 0.8) {
  notifyUser('Storage %80 dolu, eski vault cache temizlenecek.');
}
```

`navigator.storage.persist()` çağrısı ile kalıcılık iste — kullanıcı izin verir.

## Test

- Chrome DevTools → Application → Service Workers → "Offline" simülasyonu
- Lighthouse → PWA score ≥ 90 zorunlu
- WebPageTest "Offline" senaryosu
