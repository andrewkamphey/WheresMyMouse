// wheresmymouse.com: serves site/ as static assets, and counts page views and downloads in D1
// for the /stats page. Only the paths in wrangler.jsonc's run_worker_first reach this code first.

const RELEASES = 'https://github.com/andrewkamphey/WheresMyMouse/releases/latest/download/';
const DOWNLOADS = { '/download': 'WheresMyMouse.dmg', '/download.zip': 'WheresMyMouse.zip' };
// Amore's appcast, the update feed Sparkle checks (SUFeedURL in Resources/Info.plist). Once it's
// set, both download links go to the newest release Amore hosts; until then, to GitHub's.
const FEED = '';
const BOT = /bot|crawl|spider|slurp|preview|facebookexternalhit|embedly|headless|lighthouse|curl|wget|python|go-http|java\/|node-fetch|axios/i;

const today = () => new Date().toISOString().slice(0, 10);
const isBot = (req) => BOT.test(req.headers.get('user-agent') || '');

function bump(env, metric, day = today()) {
  return env.DB.prepare(
    'INSERT INTO daily (day, metric, n) VALUES (?1, ?2, 1) ON CONFLICT (day, metric) DO UPDATE SET n = n + 1'
  ).bind(day, metric).run();
}

async function visitorHash(req, env, day) {
  const raw = `${env.SALT || 'wmm'}|${day}|${req.headers.get('cf-connecting-ip')}|${req.headers.get('user-agent')}`;
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(raw));
  return btoa(String.fromCharCode(...new Uint8Array(digest).slice(0, 12)));
}

async function countView(req, env, form) {
  const day = today();
  await bump(env, 'view', day);
  const h = await visitorHash(req, env, day);
  const res = await env.DB.prepare('INSERT OR IGNORE INTO seen (day, h) VALUES (?1, ?2)').bind(day, h).run();
  if (!res.meta.changes) return;
  await bump(env, 'visitor', day);
  // Yesterday's hashes, and the sources kept with them, are no longer needed.
  await env.DB.prepare('DELETE FROM seen WHERE day < ?1').bind(day).run();
  await recordVisit(req, env, form, day, h);
}

async function countDownload(req, env, url) {
  const day = today();
  await bump(env, 'download', day);
  await recordDownload(req, env, url, day);
}

// Sources: where visitors and downloads come from, for the bottom half of /stats.
// Only daily totals are stored (in `breakdown`): no cookies, no IPs, no full referrer URLs. The first
// visit's source is also kept beside its hash in `seen` for the rest of that UTC day, so a download from
// a Download button can be credited to where that visitor arrived from. All of it runs after the counts
// above and can fail without affecting them.

const OWN = /(^|\.)(wheresmymouse|whereismymouse)\.com$/;
const HOSTS = {
  'youtu.be': 'youtube.com', 't.co': 'x.com', 'twitter.com': 'x.com', 'lnkd.in': 'linkedin.com',
  // Android apps send android-app://<package>/ as the referrer.
  'com.google.android.gm': 'mail.google.com', 'com.google.android.googlequicksearchbox': 'google.com',
  'com.zhiliaoapp.musically': 'tiktok.com', 'com.ss.android.ugc.trill': 'tiktok.com', 'com.reddit.frontpage': 'reddit.com',
};
// Referring sites with a short source name, matching the utm_source values in LINKS.md.
const NAMES = {
  'google.com': 'google', 'bing.com': 'bing', 'duckduckgo.com': 'duckduckgo', 'tiktok.com': 'tiktok',
  'youtube.com': 'youtube', 'github.com': 'github', 'reddit.com': 'reddit', 'x.com': 'x', 'facebook.com': 'facebook',
  'instagram.com': 'instagram', 'linkedin.com': 'linkedin', 'news.ycombinator.com': 'hackernews',
  'producthunt.com': 'producthunt', 'mail.google.com': 'gmail', 'bettersheets.co': 'bettersheets',
  'kit.com': 'kit', 'chatgpt.com': 'chatgpt', 'perplexity.ai': 'perplexity',
};
// In-app browsers often send no referrer, but say which app they're in.
const APPS = { 'TikTok app': 'tiktok', 'Instagram app': 'instagram', 'Facebook app': 'facebook', 'LinkedIn app': 'linkedin' };

const clean = (s, max = 64) => (s || '').trim().toLowerCase().replace(/\s+/g, '-').slice(0, max);
const parseURL = (s) => { try { return new URL(s); } catch { return null; } };

// 'www.google.co.uk' → 'google.com', 'old.reddit.com' → 'reddit.com'. '' when there's no referrer.
function refDomain(host) {
  host = clean(host, 253).replace(/^(www|m|l|lm|out|old|mobile|vm)\./, '');
  if (/^google\.[a-z.]+$/.test(host)) return 'google.com';
  if (/(^|\.)(convertkit-mail\d*\.com|ck\.page)$/.test(host)) return 'kit.com';
  return HOSTS[host] || host.slice(0, 64);
}

function cleanPath(p) {
  return typeof p === 'string' && p.startsWith('/') ? p.slice(0, 100) : '';
}

// iPads ask for the desktop site with a Mac user agent; the page sends `touch` to tell them apart.
function osOf(ua, touch) {
  if (/iPhone|iPad|iPod/.test(ua)) return 'iOS';
  if (/Macintosh|Mac OS X/.test(ua)) return touch ? 'iOS' : 'macOS';
  if (/Android/.test(ua)) return 'Android';
  if (/CrOS/.test(ua)) return 'ChromeOS';
  if (/Windows/.test(ua)) return 'Windows';
  if (/Linux|X11/.test(ua)) return 'Linux';
  return 'Other';
}

function browserOf(ua) {
  if (/BytedanceWebview|musical_ly|TikTok|trill_/i.test(ua)) return 'TikTok app';
  if (/Instagram/.test(ua)) return 'Instagram app';
  if (/FBAN|FBAV|FB_IAB/.test(ua)) return 'Facebook app';
  if (/LinkedInApp/.test(ua)) return 'LinkedIn app';
  if (/Edg(e|A|iOS)?\//.test(ua)) return 'Edge';
  if (/OPR\/|Opera/.test(ua)) return 'Opera';
  if (/SamsungBrowser/.test(ua)) return 'Samsung Internet';
  if (/Firefox\/|FxiOS/.test(ua)) return 'Firefox';
  if (/Chrome\/|CriOS/.test(ua)) return 'Chrome';
  if (/Safari\//.test(ua)) return 'Safari';
  return 'Other';
}

// Source is the link's utm_source if it had one, else the referring site, else the in-app browser, else 'direct'.
function attribution(params, ref, ua, landing) {
  const s = clean(params.get('utm_source')), m = clean(params.get('utm_medium'));
  return {
    source: s || NAMES[ref] || ref || APPS[browserOf(ua)] || 'direct',
    ref: ref || 'direct',
    utm: s && m ? `${s} / ${m}` : s,
    campaign: clean(params.get('utm_campaign')),
    landing: landing || '/',
  };
}

function device(req, ua, touch) {
  return { country: req.cf?.country || req.headers.get('cf-ipcountry') || 'XX', os: osOf(ua, touch), browser: browserOf(ua) };
}

function breakdown(env, day, metric, dims) {
  return Object.entries(dims).filter(([, v]) => v).map(([dim, value]) => env.DB.prepare(
    'INSERT INTO breakdown (day, metric, dim, value, n) VALUES (?1, ?2, ?3, ?4, 1) ON CONFLICT (day, metric, dim, value) DO UPDATE SET n = n + 1'
  ).bind(day, metric, dim, value));
}

async function recordVisit(req, env, form, day, h) {
  try {
    const ua = req.headers.get('user-agent') || '';
    let ref = refDomain(form.get('r'));
    if (OWN.test(ref)) ref = ''; // a new day (or IP) mid-browse
    const landing = cleanPath(form.get('p')) || parseURL(req.headers.get('referer'))?.pathname;
    const a = attribution(form, ref, ua, landing);
    const d = device(req, ua, form.get('t') === '1');
    await env.DB.batch([
      env.DB.prepare('UPDATE seen SET src = ?3 WHERE day = ?1 AND h = ?2').bind(day, h, JSON.stringify(a)),
      ...breakdown(env, day, 'visitor', { ...a, ...d, source_mac: d.os === 'macOS' && a.source }),
    ]);
  } catch (e) {
    console.error('source tracking (visit):', e.message);
  }
}

async function recordDownload(req, env, url, day) {
  try {
    const ua = req.headers.get('user-agent') || '';
    const page = parseURL(req.headers.get('referer'));
    const ref = refDomain(page?.hostname);
    let a;
    if (url.searchParams.has('utm_source') || (ref && !OWN.test(ref))) {
      // A link straight to /download, like the README's: credit the link.
      a = attribution(url.searchParams, ref, ua, url.pathname);
    } else {
      // A Download button on the site: credit where this visitor arrived from today.
      const row = await env.DB.prepare('SELECT src FROM seen WHERE day = ?1 AND h = ?2')
        .bind(day, await visitorHash(req, env, day)).first();
      a = row?.src ? JSON.parse(row.src)
        : attribution(page && OWN.test(ref) ? page.searchParams : url.searchParams, '', ua, page?.pathname || url.pathname);
    }
    const file = `${await latestVersion()} ${DOWNLOADS[url.pathname].split('.').pop()}`;
    await env.DB.batch(breakdown(env, day, 'download', { ...a, ...device(req, ua, false), file }));
  } catch (e) {
    console.error('source tracking (download):', e.message);
  }
}

// The newest stable release in the appcast, { build, version: 'v2.0.0', url }, cached for 10 minutes.
async function latestRelease() {
  const key = new Request('https://wheresmymouse.com/_cache/latest-release');
  const hit = await caches.default.match(key);
  if (hit) return hit.json();
  const xml = await (await fetch(FEED)).text();
  const field = (item, name) => item.match(new RegExp(`<sparkle:${name}>([^<]+)<`))?.[1] ?? item.match(new RegExp(`sparkle:${name}="([^"]+)"`))?.[1];
  let best = null;
  for (const [, item] of xml.matchAll(/<item>([\s\S]*?)<\/item>/g)) {
    if (field(item, 'channel')) continue; // betas
    const url = item.match(/<enclosure[^>]*\surl="([^"]+)"/)?.[1]?.replaceAll('&amp;', '&');
    const build = Number(field(item, 'version'));
    if (url && (!best || build > best.build)) best = { build, url, version: `v${field(item, 'shortVersionString') ?? build}` };
  }
  if (!best) throw new Error('no release in the appcast');
  await caches.default.put(key, new Response(JSON.stringify(best), { headers: { 'cache-control': 'max-age=600' } }));
  return best;
}

async function downloadURL(path) {
  if (FEED) {
    try {
      return (await latestRelease()).url;
    } catch (e) {
      console.error('appcast:', e.message);
    }
  }
  return RELEASES + DOWNLOADS[path];
}

// The newest version ('v2.0.0'): from the appcast, or the tag GitHub's /releases/latest points to.
async function latestVersion() {
  if (FEED) return (await latestRelease().catch(() => null))?.version ?? 'unknown';
  try {
    const key = new Request('https://wheresmymouse.com/_cache/latest-version');
    const hit = await caches.default.match(key);
    if (hit) return hit.text();
    const res = await fetch('https://github.com/andrewkamphey/WheresMyMouse/releases/latest', { redirect: 'manual' });
    const tag = decodeURIComponent((res.headers.get('location') || '').split('/releases/tag/')[1] || '');
    if (!tag) return 'unknown';
    await caches.default.put(key, new Response(tag, { headers: { 'cache-control': 'max-age=600' } }));
    return tag;
  } catch {
    return 'unknown';
  }
}

export default {
  async fetch(req, env, ctx) {
    const url = new URL(req.url);

    if (url.pathname in DOWNLOADS) {
      if (!isBot(req) && req.method === 'GET') ctx.waitUntil(countDownload(req, env, url));
      return Response.redirect(await downloadURL(url.pathname), 302);
    }

    if (url.pathname === '/api/hit' && req.method === 'POST') {
      // The body has to be read before responding; the counting happens after.
      const form = new URLSearchParams((await req.text().catch(() => '')).slice(0, 2000));
      if (!isBot(req)) ctx.waitUntil(countView(req, env, form));
      return new Response(null, { status: 204 });
    }

    if (url.pathname === '/api/stats') {
      const { results } = await env.DB.prepare(
        "SELECT day, metric, n FROM daily WHERE day >= date('now', '-800 days') ORDER BY day"
      ).all();
      return Response.json(results, { headers: { 'cache-control': 'public, max-age=60' } });
    }

    if (url.pathname === '/api/sources') {
      const [rows, first] = await env.DB.batch([
        env.DB.prepare("SELECT metric, dim, value, SUM(n) AS n FROM breakdown WHERE day >= date('now', '-29 days') GROUP BY metric, dim, value"),
        env.DB.prepare('SELECT MIN(day) AS day FROM breakdown'),
      ]);
      return Response.json({ since: first.results[0]?.day || null, rows: rows.results },
        { headers: { 'cache-control': 'public, max-age=60' } });
    }

    return env.ASSETS.fetch(req);
  },
};
