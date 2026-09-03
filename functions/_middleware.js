/** Send apex / www to the campus-safe host. Chrome caches HTTP/3 on puretrovey.net. */
const CANONICAL = 'app.puretrovey.net';

export async function onRequest(context) {
  const url = new URL(context.request.url);
  const apex = url.hostname === 'puretrovey.net' || url.hostname === 'www.puretrovey.net';
  if (apex && !url.pathname.startsWith('/api/')) {
    url.hostname = CANONICAL;
    return Response.redirect(url.toString(), 302);
  }
  return context.next();
}
