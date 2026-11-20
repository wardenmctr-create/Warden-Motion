// WardenCB pack'ini (30 poz + parçalar) PNG olarak üretir ve hazır pack'in manifest'ine ekler.
// Çalıştırma: npx tsx scripts/build-wardencb-pack.tsx   (build-pack.mjs'ten SONRA; Playwright gerekir)
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { renderToStaticMarkup } from 'react-dom/server';
import { createElement as h } from 'react';
import { WardenCB, POSES, type Mood, type WcbLayer } from '../src/components/WardenCB';

const { chromium } = createRequire(import.meta.url)('playwright');
const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const outDir = path.join(root, 'public', 'packs', 'hazir', 'wardencb');
const flag = 'data:image/png;base64,' + fs.readFileSync(path.join(root, 'public', 'wardencb', 'bayrak.png')).toString('base64');

const slug = (t: string) => t.toLocaleLowerCase('tr').replace(/ı/g, 'i').replace(/ğ/g, 'g').replace(/ü/g, 'u').replace(/ş/g, 's').replace(/ö/g, 'o').replace(/ç/g, 'c').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
const W = 580; // her parça aynı tuvalde: üst üste koyunca hizalı

interface Item { folder: string; name: string; mood: Mood; layers?: WcbLayer[] }
const items: Item[] = [];
for (const [k, p] of Object.entries(POSES)) if (k !== 'point') items.push({ folder: 'WardenCB Pozlar', name: p.name, mood: k as Mood });
items.push({ folder: 'WardenCB Parçalar', name: 'Gövde', mood: 'idle', layers: ['body'] });
items.push({ folder: 'WardenCB Parçalar', name: 'Ushanka', mood: 'idle', layers: ['hat'] });
items.push({ folder: 'WardenCB Parçalar', name: 'Gölge', mood: 'idle', layers: ['shadow'] });
const eyeSets: [Mood, string][] = [
  ['idle', 'Göz Normal'], ['happy', 'Göz Mutlu'], ['laugh', 'Göz Kapalı'], ['wow', 'Göz Şaşkın'], ['shock', 'Göz Şok'],
  ['sad', 'Göz Üzgün'], ['angry', 'Göz Kızgın'], ['sleepy', 'Göz Uykulu'], ['sleep', 'Göz Uyuyor'], ['wink', 'Göz Kırpma'],
  ['love', 'Göz Kalp'], ['excited', 'Göz Yıldız'], ['dizzy', 'Göz Spiral'], ['dead', 'Göz Çarpı'], ['suspicious', 'Göz Şüpheli'],
];
for (const [m, n] of eyeSets) items.push({ folder: 'WardenCB Parçalar', name: n, mood: m, layers: ['eyes'] });

fs.rmSync(outDir, { recursive: true, force: true });
fs.mkdirSync(outDir, { recursive: true });
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: W, height: 490 } });
const folders = new Map<string, { name: string; src: string }[]>();
for (const it of items) {
  const svg = renderToStaticMarkup(h(WardenCB, { size: W, mood: it.mood, autoBlink: false, look: 0, layers: it.layers, flagHref: flag }));
  await page.setContent(`<html><body style="margin:0;background:transparent">${svg}</body></html>`);
  await page.waitForTimeout(30);
  const file = `${slug(it.folder)}-${slug(it.name)}.png`;
  await page.locator('svg').screenshot({ path: path.join(outDir, file), omitBackground: true });
  if (!folders.has(it.folder)) folders.set(it.folder, []);
  folders.get(it.folder)!.push({ name: it.name, src: `packs/hazir/wardencb/${file}` });
}
await browser.close();

// Manifest'e ekle (önceki WardenCB klasörleri varsa yenile)
const manPath = path.join(root, 'public', 'packs', 'hazir', 'manifest.json');
const man = JSON.parse(fs.readFileSync(manPath, 'utf8'));
man.folders = man.folders.filter((f: { name: string }) => !f.name.startsWith('WardenCB'));
for (const [name, list] of folders) man.folders.push({ name, items: list });
fs.writeFileSync(manPath, JSON.stringify(man, null, 1));
console.log('wardencb:', [...folders].map(([n, l]) => `${n}(${l.length})`).join(' '));
