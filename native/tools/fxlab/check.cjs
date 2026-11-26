// Kullanım: node check.cjs tür1 tür2 ... (ya da "ready" = hazır olanların hepsi) → derleme hatası / etkisiz efekt raporu
const { chromium } = require('playwright'); const fs = require('fs'); const path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
const MIME = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json', '.glsl': 'text/plain', '.png': 'image/png', '.svg': 'image/svg+xml', '.otf': 'font/otf' };
(async () => {
  let types = process.argv.slice(2);
  if (types[0] === 'ready') types = JSON.parse(fs.readFileSync(path.join(ROOT, 'native/app/src/main/assets/fx/catalog.json'))).effects.filter((e) => e.ready).map((e) => e.type);
  const b = await chromium.launch({ args: ['--use-gl=angle', '--use-angle=swiftshader'] });
  let p = null;
  async function fresh() { if (p) await p.close(); p = await b.newPage({ viewport: { width: 480, height: 480 } });
  p.route('http://lab.local/**', (r) => { const f = path.join(ROOT, decodeURIComponent(new URL(r.request().url()).pathname)); if (!f.startsWith(ROOT) || !fs.existsSync(f)) return r.fulfill({ status: 404, body: '' }); r.fulfill({ status: 200, contentType: MIME[path.extname(f)] || 'application/octet-stream', body: fs.readFileSync(f) }); });
  await p.goto('http://lab.local/native/tools/fxlab/lab.html');
  await p.waitForFunction(() => window.ready || window.bootErr, null, { timeout: 30000 }); }
  let bad = 0; let n = 0;
  for (const t of types) {
    if (n++ % 10 === 0) await fresh();
    try { const r = await p.evaluate((t) => probe(t), t); if (r.same || r.blank) { bad++; console.log('ETKİSİZ', t, JSON.stringify(r)); } }
    catch (e) { bad++; console.log('HATA', t, String(e).split('\n').slice(0, 4).join(' | ').slice(0, 400)); }
  }
  console.log(`${types.length} efekt denetlendi, ${bad} sorunlu`);
  await b.close();
})();
