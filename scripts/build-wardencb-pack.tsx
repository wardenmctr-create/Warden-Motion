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

interface Part { name: string; layers: WcbLayer[]; back?: boolean; parent?: number }
interface Item { folder: string; name: string; mood: Mood; parts: Part[]; root?: number; viewBox?: string; dir: string; file?: string; still?: boolean; noFlag?: boolean }
const WCB = 'packs/hazir/wardencb', GOV = 'packs/hazir/govdeler', GOZ = 'packs/hazir/gozler', SAP = 'packs/hazir/sapkalar';
// Pozlar: projeye bütün gibi gelir ama ayrı katmanlardır (alttan üste). Çizgi kök; arka kulak ushankayı takip eder.
const CHAR_PARTS = (fx: boolean): Part[] => [
  { name: 'Ushanka Arka Kulak', layers: ['hatBack'], parent: 4 }, { name: 'İç', layers: ['fill'] }, { name: 'Çizgi', layers: ['line'] },
  { name: 'Göz', layers: ['eyes'] }, { name: 'Ushanka', layers: ['hat'] }, ...(fx ? [{ name: 'İşaretler', layers: ['fx'] as WcbLayer[] }] : []),
];
const items: Item[] = [];
for (const [k, p] of Object.entries(POSES)) if (k !== 'point') items.push({ folder: 'Pozlar', name: p.name, mood: k as Mood, parts: CHAR_PARTS(!!(p as { fx?: unknown[] }).fx?.length), root: 2, dir: WCB });
// Gövdeler: diğer gövdeler gibi kare tuvalde çizgi + beyaz iç (bayrak "gövdesi kur" ile içe kırpılır)
const SQ_BODY = '122 290 400 400';
items.push({ folder: 'Gövdeler', name: 'Basık Çizgi', mood: 'idle', parts: [{ name: '', layers: ['line'] }], viewBox: SQ_BODY, dir: GOV, file: 'wardencb-cizgi', still: true });
items.push({ folder: 'Gövdeler', name: 'Basık İç', mood: 'idle', parts: [{ name: '', layers: ['fill'] }], viewBox: SQ_BODY, dir: GOV, file: 'wardencb-ic', still: true, noFlag: true });
// Gözler: iki göz de beyaz, kare tuval (diğer göz setleri gibi)
const eyeSets: [Mood, string][] = [
  ['idle', 'Bakan'], ['happy', 'Sevinçli'], ['laugh', 'Gülen'], ['wow', 'Şaşırmış'], ['shock', 'Şok'],
  ['sad', 'Hüzünlü'], ['angry', 'Sinirli'], ['sleepy', 'Uykulu'], ['sleep', 'Uyuyan'], ['wink', 'Göz Kırpan'],
  ['love', 'Kalp'], ['excited', 'Yıldız'], ['dizzy', 'Spiral'], ['dead', 'Çarpı'], ['suspicious', 'Şüpheli'],
];
for (const [m, n] of eyeSets) items.push({ folder: 'Gözler', name: n, mood: m, parts: [{ name: '', layers: ['eyes'] }], viewBox: '117 345 380 380', dir: GOZ, file: `wardencb-${slug(n)}`, still: true });
// Şapkalar: ushanka. Arka kulak ayrı katman, ana parçayı takip eder ve CB'nin arkasına konur.
items.push({ folder: 'Şapkalar', name: 'Ushanka', mood: 'idle', viewBox: '92 256 516 416', dir: SAP, file: 'ushanka', still: true,
  parts: [{ name: 'Arka Kulak', layers: ['hatBack'], back: true }, { name: 'Ön', layers: ['hat'] }], root: 1 });

for (const d of [GOV, GOZ, SAP]) for (const f of fs.readdirSync(path.join(root, 'public', d))) if (f.startsWith('wardencb') || f.startsWith('ushanka')) fs.rmSync(path.join(root, 'public', d, f));
for (const f of fs.readdirSync(path.join(root, 'public', 'packs/hazir/esyalar'))) if (f.startsWith('wardencb')) fs.rmSync(path.join(root, 'public', 'packs/hazir/esyalar', f));
fs.rmSync(outDir, { recursive: true, force: true });
fs.mkdirSync(outDir, { recursive: true });
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: W, height: 600 } });
type Out = { name: string; src: string; parts?: { name: string; src: string; back?: boolean; parent?: number }[]; root?: number };
const folders = new Map<string, Out[]>();
const shot = async (it: Item, layers: WcbLayer[], file: string) => {
  const svg = renderToStaticMarkup(h(WardenCB, { size: W, mood: it.mood, autoBlink: false, look: 0, lookY: 0, layers, flagHref: it.noFlag ? '' : flag, viewBox: it.viewBox, whiteEyes: true, still: it.still }));
  await page.setContent(`<html><body style="margin:0;background:transparent">${svg}</body></html>`);
  await page.waitForTimeout(30);
  await page.locator('svg').screenshot({ path: path.join(root, 'public', it.dir, file), omitBackground: true });
  return `${it.dir}/${file}`;
};
for (const it of items) {
  const base = it.file ?? `${slug(it.folder)}-${slug(it.name)}`;
  const src = await shot(it, it.parts.flatMap((p) => p.layers), `${base}.png`);
  const out: Out = { name: it.name, src };
  if (it.parts.length > 1) {
    out.parts = [];
    for (const pt of it.parts) out.parts.push({ name: pt.name, src: await shot(it, pt.layers, `${base}--${slug(pt.name)}.png`), ...(pt.back ? { back: true } : {}), ...(pt.parent !== undefined ? { parent: pt.parent } : {}) });
    out.root = it.root ?? 0;
  }
  if (!folders.has(it.folder)) folders.set(it.folder, []);
  folders.get(it.folder)!.push(out);
}
await browser.close();

// Manifest'e ekle (önceki WardenCB klasörleri varsa yenile)
const manPath = path.join(root, 'public', 'packs', 'hazir', 'manifest.json');
const man = JSON.parse(fs.readFileSync(manPath, 'utf8'));
man.folders = man.folders.filter((f: { name: string }) => !f.name.startsWith('WardenCB') && f.name !== 'Pozlar');
for (const f of man.folders) f.items = f.items.filter((i: Out) => !i.src.includes('wardencb') && !i.src.includes('ushanka'));
for (const [name, list] of folders) {
  const ex = man.folders.find((f: { name: string }) => f.name === name);
  if (ex) ex.items = [...ex.items.filter((i: Out) => !list.some((l) => l.name === i.name)), ...list];
  else man.folders.push({ name, items: list });
}
fs.writeFileSync(manPath, JSON.stringify(man, null, 1));
// Bayraklar: WardenCB'nin bayrağı (en başta görünsün diye listenin başına)
const flagsPath = path.join(root, 'public', 'flags', 'flags.json');
const flags = JSON.parse(fs.readFileSync(flagsPath, 'utf8')).filter((f: { code: string }) => f.code !== 'wardencb');
fs.writeFileSync(path.join(root, 'public', 'flags', 'wardencb.svg'), `<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 600 400"><image width="600" height="400" xlink:href="${flag}"/></svg>`);
fs.writeFileSync(flagsPath, JSON.stringify([{ code: 'wardencb', en: 'Warden', continent: '', iso: false }, ...flags]));
console.log('wardencb:', [...folders].map(([n, l]) => `${n}(${l.length})`).join(' '));
