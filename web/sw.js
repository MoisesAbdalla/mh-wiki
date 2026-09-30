// Offline support for the web build (research R10, SC-004).
//
// Strategy: network-first with cache fallback for every GET. Online users
// always get the latest build; every response is stored, so after one full
// online load the app (code, fonts, CanvasKit, datasets) works offline.
// Bump CACHE_VERSION when the caching strategy itself changes.
const CACHE_VERSION = 'mh-wiki-v1';

const PRECACHE = [
  './',
  'index.html',
  'flutter_bootstrap.js',
  'main.dart.js',
  'manifest.json',
  'assets/data/world_iceborne/monsters.json',
  'assets/data/rise_sunbreak/monsters.json',
  'assets/data/wilds/monsters.json',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(CACHE_VERSION)
      // Individual failures must not abort installation.
      .then((cache) => Promise.allSettled(PRECACHE.map((url) => cache.add(url))))
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(keys.filter((k) => k !== CACHE_VERSION).map((k) => caches.delete(k))),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET' || !request.url.startsWith('http')) return;

  event.respondWith(
    fetch(request)
      .then((response) => {
        if (response.ok || response.type === 'opaque') {
          const copy = response.clone();
          caches.open(CACHE_VERSION).then((cache) => cache.put(request, copy));
        }
        return response;
      })
      .catch(() =>
        caches.match(request).then(
          (cached) =>
            cached ||
            (request.mode === 'navigate' ? caches.match('index.html') : undefined) ||
            Response.error(),
        ),
      ),
  );
});
