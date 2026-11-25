// Kullanım: node run.js <çıktı klasörü> tür1 tür2 ...  → her tür için kareler ve GIF
// Sunucu açılmaz: sayfanın istekleri depo içindeki dosyalardan karşılanır.
const { chromium } = require('playwright'); const fs = require('fs'); const path = require('path'); const { execFileSync } = require('child_process');
const ROOT = path.resolve(__dirname, '../../..');
const MIME = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json', '.glsl': 'text/plain', '.png': 'image/png', '.svg': 'image/svg+xml', '.otf': 'font/otf' };
(async () => {
  const out = process.argv[2]; const types = process.argv.slice(3);
  const b = await chromium.launch({ args: ['--use-gl=angle', '--use-angle=swiftshader'] });
  const p = await b.newPage({ viewport: { width: 480, height: 480 } });
  await p.route('http://lab.local/**', (r) => {
    const rel = decodeURIComponent(new URL(r.request().url()).pathname);
    const f = path.join(ROOT, rel);
    if (!f.startsWith(ROOT) || !fs.existsSync(f)) return r.fulfill({ status: 404, body: '' });
    r.fulfill({ status: 200, contentType: MIME[path.extname(f)] || 'application/octet-stream', body: fs.readFileSync(f) });
  });
  p.on('console', (m) => { if (m.type() === 'error') console.log('KONSOL', m.text()); });
  await p.goto('http://lab.local/native/tools/fxlab/lab.html');
  await p.waitForFunction(() => window.ready || window.bootErr, null, { timeout: 30000 });
  const err = await p.evaluate(() => window.bootErr); if (err) { console.log('BOOT', err); process.exit(1); }
  for (const t of types) {
    const dir = `${out}/${t}`; fs.mkdirSync(dir, { recursive: true });
    let frames;
    try { frames = await p.evaluate((t) => render(t), t); } catch (e) { console.log('HATA', t, String(e).slice(0, 500)); continue; }
    frames.forEach((d, i) => fs.writeFileSync(`${dir}/${String(i).padStart(3, '0')}.png`, Buffer.from(d.split(',')[1], 'base64')));
    execFileSync('ffmpeg', ['-v', 'error', '-y', '-framerate', '20', '-i', `${dir}/%03d.png`, '-vf', 'scale=240:240:flags=lanczos,split[a][b];[a]palettegen=stats_mode=full[p];[b][p]paletteuse=dither=sierra2_4a', '-loop', '0', `${out}/${t}.gif`]);
    console.log('OK', t);
  }
  await b.close();
})();
