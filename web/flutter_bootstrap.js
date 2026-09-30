{{flutter_js}}
{{flutter_build_config}}

// Flutter no longer ships a caching service worker (research R10), so the
// app registers its own to keep working offline after the first load (SC-004).
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('sw.js').catch((error) => {
      console.warn('Service worker registration failed:', error);
    });
  });
}

_flutter.loader.load();
