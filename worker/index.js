// wheresmymouse.com: serves site/ as static assets, and counts page views and downloads in D1
// for the /stats page. Only the paths in wrangler.jsonc's run_worker_first reach this code first.

const RELEASES = 'https://github.com/andrewkamphey/WheresMyMouse/releases/latest/download/';
const DOWNLOADS = { '/download': 'WheresMyMouse.dmg', '/download.zip': 'WheresMyMouse.zip' };
const BOT = /bot|crawl|spider|slurp|preview|facebookexternalhit|embedly|headless|lighthouse|curl|wget|python|go-http|java\/|node-fetch|axios/i;

const today = () => new Date().toISOString().slice(0, 10);
const isBot = (req) => BOT.test(req.headers.get('user-agent') || '');

function bump(env, metric, day = today()) {
  return env.DB.prepare(
    'INSERT INTO daily (day, metric, n) VALUES (?1, ?2, 1) ON CONFLICT (day, metric) DO UPDATE SET n = n + 1'
  ).bind(day, metric).run();
}

async function countView(req, env) {
  const day = today();
  await bump(env, 'view', day);
  const raw = `${env.SALT || 'wmm'}|${day}|${req.headers.get('cf-connecting-ip')}|${req.headers.get('user-agent')}`;
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(raw));
  const h = btoa(String.fromCharCode(...new Uint8Array(digest).slice(0, 12)));
  const res = await env.DB.prepare('INSERT OR IGNORE INTO seen (day, h) VALUES (?1, ?2)').bind(day, h).run();
  if (res.meta.changes) await bump(env, 'visitor', day);
  // Yesterday's hashes are no longer needed.
  if (Math.random() < 0.02) await env.DB.prepare('DELETE FROM seen WHERE day < ?1').bind(day).run();
}

export default {
  async fetch(req, env, ctx) {
    const url = new URL(req.url);

    if (url.pathname in DOWNLOADS) {
      if (!isBot(req) && req.method === 'GET') ctx.waitUntil(bump(env, 'download'));
      return Response.redirect(RELEASES + DOWNLOADS[url.pathname], 302);
    }

    if (url.pathname === '/api/hit' && req.method === 'POST') {
      if (!isBot(req)) ctx.waitUntil(countView(req, env));
      return new Response(null, { status: 204 });
    }

    if (url.pathname === '/api/stats') {
      const { results } = await env.DB.prepare(
        "SELECT day, metric, n FROM daily WHERE day >= date('now', '-800 days') ORDER BY day"
      ).all();
      return Response.json(results, { headers: { 'cache-control': 'public, max-age=60' } });
    }

    return env.ASSETS.fetch(req);
  },
};
