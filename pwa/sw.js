/* Trovey vanilla PWA — Week 3/5
   install → activate → fetch
   Cache-First | Network-First | Stale-While-Revalidate | Cache-Only | Network-Only
*/
const SHELL = 'trovey-pwa-shell-v9';
const RUNTIME = 'trovey-pwa-runtime-v1';
const TEMPLATE = 'trovey-pwa-template-v1';

const PRECACHE = [
  '/',
  '/index.html',
  '/offline.html',
  '/manifest.json',
  '/styles.css',
  '/app.js',
  '/native.js',
  '/data.js',
  '/sw-stats.json',
  '/survey-template.json',
  '/icons/icon.svg',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  '/icons/splash-512.png',
  '/icons/splash-1080x1920.png',
  '/icons/splash-1170x2532.png',
  '/apple-touch-icon.png',
  '/favicon.png',
  '/fonts/be-vietnam-pro-400-vi.woff2',
  '/fonts/be-vietnam-pro-600-vi.woff2',
  '/fonts/be-vietnam-pro-700-vi.woff2',
  '/fonts/be-vietnam-pro-400-latin.woff2',
  '/fonts/be-vietnam-pro-600-latin.woff2',
  '/fonts/be-vietnam-pro-700-latin.woff2',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(SHELL).then((cache) => cache.addAll(PRECACHE)).then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((key) => key !== SHELL && key !== RUNTIME && key !== TEMPLATE).map((key) => caches.delete(key))),
    ).then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  const url = new URL(req.url);
  if (req.method !== 'GET') return;

  if (url.pathname.startsWith('/api/') || url.pathname.startsWith('/downloads/')) {
    event.respondWith(fetch(req));
    return;
  }
  if (url.pathname === '/offline.html') {
    event.respondWith(caches.match(req).then((hit) => hit || fetch(req)));
    return;
  }
  if (url.pathname === '/sw-stats.json') {
    event.respondWith(staleWhileRevalidate(req, RUNTIME));
    return;
  }
  if (url.pathname === '/survey-template.json') {
    event.respondWith(networkFirst(req, TEMPLATE));
    return;
  }
  if (req.mode === 'navigate') {
    event.respondWith(
      fetch(req)
        .then((fresh) => {
          if (fresh && fresh.ok) caches.open(SHELL).then((cache) => cache.put('/index.html', fresh.clone()));
          return fresh;
        })
        .catch(async () => (await caches.match('/index.html')) || (await caches.match('/offline.html'))),
    );
    return;
  }
  event.respondWith(cacheFirst(req));
});

self.addEventListener('sync', (event) => {
  if (event.tag === 'trovey-sync') {
    event.waitUntil(
      self.clients.matchAll({ type: 'window' }).then((clients) => {
        clients.forEach((client) => client.postMessage({ type: 'DRAIN_QUEUE' }));
      }),
    );
  }
});

async function cacheFirst(req) {
  const cached = await caches.match(req);
  if (cached) return cached;
  try {
    const fresh = await fetch(req);
    if (fresh.ok && req.url.startsWith(self.location.origin)) {
      caches.open(SHELL).then((cache) => cache.put(req, fresh.clone()));
    }
    return fresh;
  } catch {
    if (req.destination === 'document') return (await caches.match('/offline.html')) || Response.error();
    return Response.error();
  }
}

async function networkFirst(req, cacheName) {
  const cache = await caches.open(cacheName);
  try {
    const fresh = await fetch(req);
    cache.put(req, fresh.clone());
    return fresh;
  } catch {
    const cached = await cache.match(req);
    if (cached) return cached;
    throw new Error('network-first miss');
  }
}

async function staleWhileRevalidate(req, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(req);
  const fetching = fetch(req)
    .then((fresh) => {
      cache.put(req, fresh.clone());
      return fresh;
    })
    .catch(() => cached);
  return cached || fetching;
}
