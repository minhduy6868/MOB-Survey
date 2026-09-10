/* Trovey Service Worker — Week 3 PWA
   install → activate → fetch
   Cache-First | Network-First | Stale-While-Revalidate | Cache-Only | Network-Only
*/
const SHELL = 'trovey-shell-v11';
const RUNTIME = 'trovey-runtime-v11';
const TEMPLATE = 'trovey-template-v11';
const CANONICAL = 'https://app.puretrovey.net';

const PRECACHE = [
  '/',
  '/index.html',
  '/offline',
  '/manifest.json',
  '/install.js',
  '/native.js',
  '/survey-template.json',
  '/sw-stats.json',
  '/favicon.png',
  '/favicon.ico',
  '/favicon-16x16.png',
  '/favicon-32x32.png',
  '/favicon-96x96.png',
  '/apple-touch-icon.png',
  '/og.png',
  '/icons/icon.svg',
  '/icons/Icon-48.png',
  '/icons/Icon-72.png',
  '/icons/Icon-96.png',
  '/icons/Icon-144.png',
  '/icons/Icon-192.png',
  '/icons/Icon-256.png',
  '/icons/Icon-384.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(SHELL)
      .then((cache) => cache.addAll(PRECACHE))
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter((key) => key !== SHELL && key !== RUNTIME && key !== TEMPLATE)
            .map((key) => caches.delete(key)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  const url = new URL(req.url);
  if (url.hostname === 'puretrovey.net' || url.hostname === 'www.puretrovey.net') {
    event.respondWith(Response.redirect(CANONICAL + url.pathname + url.search, 302));
    return;
  }
  if (req.method !== 'GET') return;

  if (url.pathname.startsWith('/api/')) {
    event.respondWith(networkOnly(req));
    return;
  }
  if (url.pathname === '/offline' || url.pathname === '/offline.html') {
    event.respondWith(cacheOnly(req));
    return;
  }
  if (url.pathname === '/survey-template.json') {
    event.respondWith(networkFirst(req, TEMPLATE));
    return;
  }
  if (url.pathname === '/sw-stats.json') {
    event.respondWith(staleWhileRevalidate(req, RUNTIME));
    return;
  }
  if (req.mode === 'navigate') {
    event.respondWith(
      fetch(req)
        .then((fresh) => {
          if (fresh && fresh.ok) {
            caches.open(SHELL).then((cache) => cache.put('/index.html', fresh.clone()));
          }
          return fresh;
        })
        .catch(async () => (await caches.match('/index.html')) || (await caches.match('/offline'))),
    );
    return;
  }
  event.respondWith(cacheFirst(req));
});

self.addEventListener('sync', (event) => {
  if (event.tag === 'trovey-sync') {
    event.waitUntil(pokeClients());
  }
});

async function pokeClients() {
  const clients = await self.clients.matchAll({ type: 'window' });
  for (const client of clients) {
    client.postMessage({ type: 'DRAIN_QUEUE' });
  }
}

async function cacheFirst(req) {
  const cached = await caches.match(req);
  if (cached) return cached;
  try {
    const fresh = await fetch(req);
    if (fresh.ok && req.url.startsWith(self.location.origin)) {
      const cache = await caches.open(SHELL);
      cache.put(req, fresh.clone());
    }
    return fresh;
  } catch {
    if (req.destination === 'document') {
      return (await caches.match('/offline')) || Response.error();
    }
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

async function cacheOnly(req) {
  const cached = await caches.match(req);
  return cached || new Response('offline asset missing', { status: 504 });
}

async function networkOnly(req) {
  return fetch(req);
}
