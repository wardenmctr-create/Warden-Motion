// Kullanım: node sheet.cjs çıktı.png tür1 tür2 ... → her efektin p=0.3 karesi (240 px) yan yana, adıyla
const { chromium } = require('playwright'); const fs = require('fs'); const path = require('path');
const ROOT = path.resolve(__dirname, '../../..');
(async () => { const [out, ...types] = process.argv.slice(2); const b = await chromium.launch({ args: ['--use-gl=angle', '--use-angle=swiftshader'] }); let p = null;
  async function fresh() { if (p) await p.close(); p = await b.newPage({ viewport: { width: 480, height: 480 } });
    p.route('http://lab.local/**', (r) => { const f = path.join(ROOT, decodeURIComponent(new URL(r.request().url()).pathname)); if (!fs.existsSync(f)) return r.fulfill({ status: 404, body: '' }); r.fulfill({ status: 200, body: fs.readFileSync(f) }); });
    await p.goto('http://lab.local/native/tools/fxlab/lab.html'); await p.waitForFunction(() => window.ready || window.bootErr, null, { timeout: 30000 }); }
  const imgs = []; let n = 0;
  for (const t of types) { if (n++ % 8 === 0) await fresh();
    try { imgs.push([t, await p.evaluate(async (t) => { const sc = autoScene(t); return await frame(sc, 0.3); }, t)]); } catch (e) { imgs.push([t, null]); console.log('HATA', t, String(e).slice(0, 200)); } }
  await fresh();
  const data = await p.evaluate(async (imgs) => { const C = 6, W = 240, H = 262; const c = document.createElement('canvas'); c.width = C * W; c.height = Math.ceil(imgs.length / C) * H; const x = c.getContext('2d'); x.fillStyle = '#222'; x.fillRect(0, 0, c.width, c.height);
    for (let i = 0; i < imgs.length; i++) { const [t, u] = imgs[i]; const cx = (i % C) * W, cy = Math.floor(i / C) * H; if (u) { const im = new Image(); im.src = u; await im.decode(); x.drawImage(im, cx, cy, W, W); } x.fillStyle = '#fff'; x.font = '15px sans-serif'; x.fillText(t, cx + 4, cy + W + 17); }
    return c.toDataURL('image/png'); }, imgs);
  fs.writeFileSync(out, Buffer.from(data.split(',')[1], 'base64')); await b.close(); })();
