// Postra LP — language-aware Worker.
// Routes localizable pages (/, /privacy.html, /terms.html, /contact.html,
// /releases.html) to the appropriate JP or EN file based on:
//   1. ?lang=en|ja query param (sets cookie, then redirects to clean URL)
//   2. postra_lang cookie
//   3. CF-IPCountry header (JP -> ja)
//   4. Accept-Language header
//   5. Default: en
//
// Static assets, direct .en.html / .ja.html access, and tokushoho.html
// (JP-only legal page) pass through unchanged.

const PAGE_MAP = {
  '/': 'index',
  '/index.html': 'index',
  '/privacy.html': 'privacy',
  '/terms.html': 'terms',
  '/contact.html': 'contact',
  '/releases.html': 'releases',
  '/tutorials.html': 'tutorials',
};

const STATIC_EXT_RE = /\.(css|js|png|jpg|jpeg|webp|gif|mp4|webm|ico|svg|woff2?|ttf|map|json|xml|txt)$/i;

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname;

    // 1. Pass-through cases
    if (
      path.startsWith('/assets/') ||
      STATIC_EXT_RE.test(path) ||
      path === '/tokushoho.html' ||
      path.endsWith('.en.html') ||
      path.endsWith('.ja.html')
    ) {
      return env.ASSETS.fetch(request);
    }

    // 2. Localizable page?
    const page = PAGE_MAP[path];
    if (!page) {
      return env.ASSETS.fetch(request); // unknown path; let assets handler 404
    }

    // 3. ?lang= override -> set cookie, redirect to clean URL
    const queryLang = url.searchParams.get('lang');
    if (queryLang === 'en' || queryLang === 'ja') {
      const cleanUrl = new URL(url);
      cleanUrl.searchParams.delete('lang');
      const location = cleanUrl.pathname + cleanUrl.search + cleanUrl.hash;
      return new Response(null, {
        status: 302,
        headers: {
          'Location': location || '/',
          'Set-Cookie': `postra_lang=${queryLang}; Path=/; Max-Age=31536000; SameSite=Lax`,
          'Cache-Control': 'no-store',
        },
      });
    }

    // 4. Detect language
    const lang = detectLang(request);

    // 5. Fetch the right file
    const fileName = lang === 'en' ? `${page}.en.html` : `${page}.html`;
    const targetUrl = new URL(`/${fileName}`, url.origin);
    const targetReq = new Request(targetUrl, request);
    const response = await env.ASSETS.fetch(targetReq);

    // 6. Add Vary + Content-Language headers
    const headers = new Headers(response.headers);
    headers.set('Vary', 'Cookie, Accept-Language');
    headers.set('Content-Language', lang);
    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers,
    });
  },
};

function detectLang(request) {
  // Cookie
  const cookie = request.headers.get('cookie') || '';
  const cookieMatch = cookie.match(/(?:^|;\s*)postra_lang=(en|ja)/);
  if (cookieMatch) return cookieMatch[1];

  // CF-IPCountry: Japan -> ja
  const country = (request.headers.get('cf-ipcountry') || '').toUpperCase();
  if (country === 'JP') return 'ja';

  // Accept-Language: any "ja" tag -> ja
  const acceptLang = (request.headers.get('accept-language') || '').toLowerCase();
  if (/(?:^|[,;\s])ja(?:$|[\s,;-])/.test(acceptLang)) return 'ja';

  // Default
  return 'en';
}
