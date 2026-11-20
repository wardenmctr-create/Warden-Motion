// Hazır CB pack'inin PNG'lerini ve bayrak listesini üretir.
// Çalıştırma: npm run pack   (Playwright + Chromium gerekir)
import { createRequire } from 'node:module';
const { chromium } = createRequire(import.meta.url)('playwright');
import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const packDir = path.join(root, 'public', 'packs', 'hazir');
const flagDir = path.join(root, 'public', 'flags');

const K = '#000000'; // countryball geleneği: siyah kontur
const W = '#FFFFFF';
const s = (body, vb = '0 0 512 512') =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}" width="512" height="512">${body}</svg>`;

// Göz çifti yardımcıları (iki göz yan yana, 512x512 içinde ortalı)
const eyePair = (one) => s(`<g transform="translate(150 256)">${one}</g><g transform="translate(362 256)">${one}</g>`);
const eyeWhite = `<ellipse cx="0" cy="0" rx="62" ry="78" fill="${W}" stroke="${K}" stroke-width="16"/>`;

const items = {
  'Gövdeler': {
    // Her gövde iki parça: siyah dış çizgi + aynı şekli tam dolduran beyaz iç
    'Top Çizgi': s(`<circle cx="256" cy="256" r="236" fill="none" stroke="${K}" stroke-width="24"/>`),
    'Top İç': s(`<circle cx="256" cy="256" r="236" fill="${W}"/>`),
    'Dikdörtgen Çizgi': s(`<rect x="20" y="96" width="472" height="320" rx="6" fill="none" stroke="${K}" stroke-width="24"/>`),
    'Dikdörtgen İç': s(`<rect x="20" y="96" width="472" height="320" rx="6" fill="${W}"/>`),
    'Küp Çizgi': s(`<path d="M40 150 L140 60 H472 V362 L372 452 H40Z M40 150 H372 V452 M372 150 L472 60" fill="none" stroke="${K}" stroke-width="22" stroke-linejoin="round"/>`),
    'Küp İç': s(`<path d="M40 150 L140 60 H472 V362 L372 452 H40Z" fill="${W}"/>`),
    'Üçgen Çizgi': s(`<path d="M256 34 L486 452 H26Z" fill="none" stroke="${K}" stroke-width="24" stroke-linejoin="round"/>`),
    'Üçgen İç': s(`<path d="M256 34 L486 452 H26Z" fill="${W}" stroke="${W}" stroke-width="0"/>`),
    // Günümüz çizim tarzı: yere konmuş yumuşak top gibi, alt kısmı hafif basık ve yayvan
    'Yumuşak Top Çizgi': s(`<path d="M256 28 C390 28 488 130 488 265 C488 352 462 410 420 438 C380 462 320 470 256 470 C192 470 132 462 92 438 C50 410 24 352 24 265 C24 130 122 28 256 28Z" fill="none" stroke="${K}" stroke-width="24" stroke-linejoin="round"/>`),
    'Yumuşak Top İç': s(`<path d="M256 28 C390 28 488 130 488 265 C488 352 462 410 420 438 C380 462 320 470 256 470 C192 470 132 462 92 438 C50 410 24 352 24 265 C24 130 122 28 256 28Z" fill="${W}"/>`),
    'Yumuşak Küp Çizgi': s(`<path d="M124 46 Q256 32 388 46 Q462 52 466 124 Q476 256 466 392 Q462 466 388 472 Q256 480 124 472 Q50 466 46 392 Q36 256 46 124 Q50 52 124 46Z" fill="none" stroke="${K}" stroke-width="24" stroke-linejoin="round"/>`),
    'Yumuşak Küp İç': s(`<path d="M124 46 Q256 32 388 46 Q462 52 466 124 Q476 256 466 392 Q462 466 388 472 Q256 480 124 472 Q50 466 46 392 Q36 256 46 124 Q50 52 124 46Z" fill="${W}"/>`),
  },
  'Gözler': {
    'Normal': eyePair(eyeWhite),
    'Mutlu': eyePair(`<path d="M-60 20 Q0 -70 60 20" fill="none" stroke="${K}" stroke-width="20" stroke-linecap="round"/>`),
    'Kızgın': s(`
      <g transform="translate(150 270)"><clipPath id="a"><path d="M-90 -40 L90 20 L90 120 L-90 120Z"/></clipPath>
        <ellipse rx="62" ry="78" fill="${W}" clip-path="url(#a)"/><path d="M-62 -38 L62 4" stroke="${K}" stroke-width="18" stroke-linecap="round"/>
        <ellipse rx="62" ry="78" fill="none" stroke="${K}" stroke-width="16" clip-path="url(#a)"/></g>
      <g transform="translate(362 270)"><clipPath id="b"><path d="M90 -40 L-90 20 L-90 120 L90 120Z"/></clipPath>
        <ellipse rx="62" ry="78" fill="${W}" clip-path="url(#b)"/><path d="M62 -38 L-62 4" stroke="${K}" stroke-width="18" stroke-linecap="round"/>
        <ellipse rx="62" ry="78" fill="none" stroke="${K}" stroke-width="16" clip-path="url(#b)"/></g>`),
    'Üzgün': s(`
      <g transform="translate(150 270)"><clipPath id="c"><path d="M-90 20 L90 -40 L90 120 L-90 120Z"/></clipPath>
        <ellipse rx="62" ry="78" fill="${W}" clip-path="url(#c)"/><path d="M-62 4 L62 -38" stroke="${K}" stroke-width="18" stroke-linecap="round"/>
        <ellipse rx="62" ry="78" fill="none" stroke="${K}" stroke-width="16" clip-path="url(#c)"/></g>
      <g transform="translate(362 270)"><clipPath id="d"><path d="M90 20 L-90 -40 L-90 120 L90 120Z"/></clipPath>
        <ellipse rx="62" ry="78" fill="${W}" clip-path="url(#d)"/><path d="M62 4 L-62 -38" stroke="${K}" stroke-width="18" stroke-linecap="round"/>
        <ellipse rx="62" ry="78" fill="none" stroke="${K}" stroke-width="16" clip-path="url(#d)"/></g>`),
    'Şaşkın': eyePair(`<circle r="86" fill="${W}" stroke="${K}" stroke-width="16"/>`),
    'Kapalı': eyePair(`<path d="M-60 0 H60" stroke="${K}" stroke-width="20" stroke-linecap="round"/>`),
    'Ağlayan': s(`<g transform="translate(150 230)">${eyeWhite}</g><g transform="translate(362 230)">${eyeWhite}</g>
      <path d="M150 316 q-26 50 0 80 q26 -30 0 -80z" fill="#4FB3FF" stroke="${K}" stroke-width="8"/>
      <path d="M362 316 q-26 50 0 80 q26 -30 0 -80z" fill="#4FB3FF" stroke="${K}" stroke-width="8"/>`),
  },
  'Ağızlar': {
    'Gülümseme': s(`<path d="M146 220 Q256 330 366 220" fill="none" stroke="${K}" stroke-width="22" stroke-linecap="round"/>`),
    'Kahkaha': s(`<path d="M136 200 H376 Q370 360 256 360 Q142 360 136 200Z" fill="#3A0B0B" stroke="${K}" stroke-width="18" stroke-linejoin="round"/>
      <path d="M200 330 Q256 290 312 330 Q290 356 256 358 Q222 356 200 330Z" fill="#E8556B"/>`),
    'Düz': s(`<path d="M166 256 H346" stroke="${K}" stroke-width="22" stroke-linecap="round"/>`),
    'Üzgün': s(`<path d="M146 310 Q256 200 366 310" fill="none" stroke="${K}" stroke-width="22" stroke-linecap="round"/>`),
    'Şaşkın': s(`<ellipse cx="256" cy="256" rx="54" ry="70" fill="#3A0B0B" stroke="${K}" stroke-width="18"/>`),
  },
  'Şapkalar': {
    'Silindir': s(`<rect x="166" y="70" width="180" height="250" rx="10" fill="#1A1A1A" stroke="${K}" stroke-width="14"/>
      <rect x="166" y="262" width="180" height="40" fill="#B3262F"/>
      <ellipse cx="256" cy="330" rx="200" ry="44" fill="#1A1A1A" stroke="${K}" stroke-width="14"/>`),
    'Kep': s(`<path d="M106 330 Q106 150 256 150 Q406 150 406 330Z" fill="#2F6FD6" stroke="${K}" stroke-width="14" stroke-linejoin="round"/>
      <path d="M376 316 Q470 316 486 350 Q420 360 360 350Z" fill="#2559B0" stroke="${K}" stroke-width="14" stroke-linejoin="round"/>
      <circle cx="256" cy="150" r="16" fill="#2559B0" stroke="${K}" stroke-width="10"/>`),
    'Taç': s(`<path d="M106 360 L126 160 L196 250 L256 130 L316 250 L386 160 L406 360Z" fill="#F2C230" stroke="${K}" stroke-width="14" stroke-linejoin="round"/>
      <circle cx="256" cy="300" r="22" fill="#D2263A" stroke="${K}" stroke-width="8"/>
      <circle cx="176" cy="310" r="15" fill="#2F6FD6" stroke="${K}" stroke-width="8"/>
      <circle cx="336" cy="310" r="15" fill="#2F6FD6" stroke="${K}" stroke-width="8"/>`),
    'Fes': s(`<path d="M166 360 L190 150 Q256 128 322 150 L346 360Z" fill="#B8202A" stroke="${K}" stroke-width="14" stroke-linejoin="round"/>
      <path d="M256 140 Q300 150 318 250" fill="none" stroke="#1A1A1A" stroke-width="10"/>
      <path d="M304 246 l14 70 l14 -66z" fill="#1A1A1A"/>`),
    'Miğfer': s(`<path d="M96 330 Q96 120 256 120 Q416 120 416 330Z" fill="#5C6B3A" stroke="${K}" stroke-width="14" stroke-linejoin="round"/>
      <path d="M76 330 H436" stroke="${K}" stroke-width="26" stroke-linecap="round"/>
      <path d="M76 330 H436" stroke="#4A5730" stroke-width="12" stroke-linecap="round"/>`),
  },
  'Aksesuarlar': {
    'Gözlük': s(`<circle cx="160" cy="256" r="74" fill="#BFE3FF" fill-opacity=".35" stroke="${K}" stroke-width="16"/>
      <circle cx="352" cy="256" r="74" fill="#BFE3FF" fill-opacity=".35" stroke="${K}" stroke-width="16"/>
      <path d="M234 250 Q256 228 278 250" fill="none" stroke="${K}" stroke-width="14"/>`),
    'Güneş Gözlüğü': s(`<path d="M70 210 H442 V236 H70Z" fill="${K}"/>
      <path d="M86 220 H236 Q236 320 160 320 Q90 320 86 220Z" fill="#111" stroke="${K}" stroke-width="10"/>
      <path d="M276 220 H426 Q422 320 352 320 Q276 320 276 220Z" fill="#111" stroke="${K}" stroke-width="10"/>
      <path d="M110 238 L150 238" stroke="#9AA6B8" stroke-width="10" stroke-linecap="round"/>`),
    'Bıyık': s(`<path d="M256 236 C220 200 150 210 120 260 C100 290 70 280 60 262 C70 320 160 330 256 276 C352 330 442 320 452 262 C442 280 412 290 392 260 C362 210 292 200 256 236Z" fill="#2A1A12" stroke="${K}" stroke-width="10" stroke-linejoin="round"/>`),
    'Papyon': s(`<path d="M256 256 L96 166 Q76 256 96 346Z" fill="#C8202F" stroke="${K}" stroke-width="14" stroke-linejoin="round"/>
      <path d="M256 256 L416 166 Q436 256 416 346Z" fill="#C8202F" stroke="${K}" stroke-width="14" stroke-linejoin="round"/>
      <rect x="226" y="216" width="60" height="80" rx="14" fill="#A01826" stroke="${K}" stroke-width="14"/>`),
    'Monokl': s(`<circle cx="300" cy="230" r="86" fill="#BFE3FF" fill-opacity=".35" stroke="#C9A227" stroke-width="16"/>
      <path d="M300 316 Q290 400 240 450" fill="none" stroke="#C9A227" stroke-width="8"/>`),
  },
  'Eşyalar': {
    'Konuşma Balonu': s(`<path d="M76 90 H436 Q466 90 466 120 V320 Q466 350 436 350 H210 L120 430 L140 350 H76 Q46 350 46 320 V120 Q46 90 76 90Z" fill="${W}" stroke="${K}" stroke-width="14" stroke-linejoin="round"/>`),
    'Soru İşareti': s(`<text x="256" y="400" text-anchor="middle" font-family="Arial Black, Arial, sans-serif" font-weight="900" font-size="380" fill="#F2C230" stroke="${K}" stroke-width="14" paint-order="stroke">?</text>`),
    'Ünlem': s(`<text x="256" y="400" text-anchor="middle" font-family="Arial Black, Arial, sans-serif" font-weight="900" font-size="380" fill="#E8333F" stroke="${K}" stroke-width="14" paint-order="stroke">!</text>`),
    'Kalp': s(`<path d="M256 440 C120 340 60 270 60 190 A98 98 0 0 1 256 150 A98 98 0 0 1 452 190 C452 270 392 340 256 440Z" fill="#E8333F" stroke="${K}" stroke-width="14" stroke-linejoin="round"/>`),
    'Ter Damlası': s(`<path d="M256 70 Q370 260 340 340 A90 90 0 0 1 172 340 Q142 260 256 70Z" fill="#7CC8FF" stroke="${K}" stroke-width="14" stroke-linejoin="round"/>
      <path d="M210 320 Q206 280 226 250" fill="none" stroke="${W}" stroke-width="14" stroke-linecap="round"/>`),
    'Patlama': s(`<path d="M256 40 L300 180 L440 120 L350 240 L480 300 L330 320 L370 470 L256 360 L142 470 L182 320 L32 300 L162 240 L72 120 L212 180Z" fill="#FFB020" stroke="${K}" stroke-width="14" stroke-linejoin="round"/>
      <path d="M256 150 L280 230 L360 210 L300 270 L350 330 L270 310 L256 380 L232 310 L162 330 L212 270 L152 210 L232 230Z" fill="#FF5A1F"/>`),
  },
};

const slug = (t) => t.toLocaleLowerCase('tr').replace(/ı/g, 'i').replace(/ğ/g, 'g').replace(/ü/g, 'u').replace(/ş/g, 's').replace(/ö/g, 'o').replace(/ç/g, 'c').replace(/[^a-z0-9]+/g, '-');

fs.rmSync(packDir, { recursive: true, force: true });
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 512, height: 512 } });
const manifest = { name: 'Hazır Pack', folders: [] };
for (const [folder, list] of Object.entries(items)) {
  const fdir = path.join(packDir, slug(folder));
  fs.mkdirSync(fdir, { recursive: true });
  const entry = { name: folder, items: [] };
  for (const [name, svg] of Object.entries(list)) {
    await page.setContent(`<html><body style="margin:0;background:transparent">${svg}</body></html>`);
    const file = `${slug(name)}.png`;
    await page.locator('svg').screenshot({ path: path.join(fdir, file), omitBackground: true });
    entry.items.push({ name, src: `packs/hazir/${slug(folder)}/${file}` });
  }
  manifest.folders.push(entry);
}
fs.writeFileSync(path.join(packDir, 'manifest.json'), JSON.stringify(manifest, null, 1));

// Önizleme sayfası (sohbette göstermek için)
const outPreview = process.argv[2];
if (outPreview) {
  const html = `<html><body style="margin:0;padding:24px;background:#0B1430;font-family:Inter,Arial,sans-serif;color:#DCE9FF;width:1100px">
  <div style="font-size:26px;font-weight:800;margin-bottom:6px">Warden Motion · Hazır CB Pack</div>
  <div style="font-size:14px;color:#8FA6D6;margin-bottom:18px">${manifest.folders.reduce((n, f) => n + f.items.length, 0)} PNG · ${manifest.folders.length} klasör · şeffaf arka plan, 512×512</div>
  ${manifest.folders.map((f) => `<div style="font-size:16px;font-weight:700;margin:16px 0 8px;color:#22D3C5">${f.name}</div>
   <div style="display:flex;flex-wrap:wrap;gap:10px">${f.items.map((it) => `<div style="width:140px;text-align:center;font-size:12px">
    <div style="width:140px;height:140px;border-radius:12px;background:conic-gradient(#C9D3E3 25%,#E8EDF5 0 50%,#C9D3E3 0 75%,#E8EDF5 0) 0 0/20px 20px;display:flex;align-items:center;justify-content:center">
    <img src="file://${path.join(root, 'public', it.src)}" style="width:118px;height:118px"></div><div style="margin-top:5px">${it.name}</div></div>`).join('')}</div>`).join('')}
  <div style="font-size:16px;font-weight:700;margin:20px 0 8px;color:#22D3C5">Örnek: parçalardan kurulmuş countryball'lar</div>
  <div style="display:flex;gap:26px">${[['tr', 'Normal', 'Gülümseme', 'Fes'], ['pl', 'Kızgın', 'Düz', 'Miğfer'], ['fr', 'Mutlu', 'Kahkaha', 'Silindir'], ['jp', 'Şaşkın', 'Şaşkın', ''], ['de', 'Üzgün', 'Üzgün', 'Gözlük']].map(([c, e, m, h]) => {
    const p = (fo, n) => `file://${path.join(root, 'public', manifest.folders.find((f) => f.name === fo).items.find((i) => i.name === n).src)}`;
    return `<div style="position:relative;width:170px;height:200px">
      <div style="position:absolute;left:10px;top:40px;width:150px;height:150px;border-radius:50%;overflow:hidden;border:4px solid #000;box-sizing:border-box;background:url(file://${path.join(root, 'node_modules/flag-icons/flags/1x1', c + '.svg')}) center/cover"></div>
      <img src="${p('Gözler', e)}" style="position:absolute;left:35px;top:62px;width:100px">
      <img src="${p('Ağızlar', m)}" style="position:absolute;left:60px;top:110px;width:50px">
      ${h ? `<img src="${p(h === 'Gözlük' ? 'Aksesuarlar' : 'Şapkalar', h)}" style="position:absolute;left:${h === 'Gözlük' ? 30 : 30}px;top:${h === 'Gözlük' ? 64 : -10}px;width:${h === 'Gözlük' ? 110 : 110}px">` : ''}</div>`;
  }).join('')}</div></body></html>`;
  const p2 = await browser.newPage({ viewport: { width: 1148, height: 400 } });
  const tmp = path.join(path.dirname(outPreview), 'pack-preview.html');
  fs.writeFileSync(tmp, html);
  await p2.goto('file://' + tmp);
  await p2.waitForTimeout(400);
  await p2.screenshot({ path: outPreview, fullPage: true });
}
await browser.close();

// Bayraklar: flag-icons (MIT) 4x3 SVG'leri
fs.rmSync(flagDir, { recursive: true, force: true });
fs.mkdirSync(flagDir, { recursive: true });
const src = path.join(root, 'node_modules', 'flag-icons', 'flags', '4x3');
const codes = fs.readdirSync(src).filter((f) => f.endsWith('.svg')).map((f) => f.replace('.svg', ''));
for (const c of codes) fs.copyFileSync(path.join(src, c + '.svg'), path.join(flagDir, c + '.svg'));
const meta = JSON.parse(fs.readFileSync(path.join(root, 'node_modules', 'flag-icons', 'country.json'), 'utf8'));
const byCode = Object.fromEntries(meta.map((m) => [m.code, m]));
fs.writeFileSync(path.join(flagDir, 'flags.json'), JSON.stringify(codes.map((c) => ({ code: c, en: byCode[c]?.name ?? c, continent: byCode[c]?.continent ?? '', iso: !!byCode[c]?.iso }))));
console.log('pack:', manifest.folders.map((f) => `${f.name}(${f.items.length})`).join(' '), '| flags:', codes.length);
