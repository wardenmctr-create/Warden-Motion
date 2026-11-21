// Yapay zekânın verdiği işleri (actions) uygulamanın gerçek komutlarına çevirir.
// Yapay zekâ kafadan bir şey çizmez: katman ekle, keyframe koy, efekt ekle… gibi uygulamanın kendi işlerini kullanır.
import { EASES, uid, valueAt } from '../anim';
import { cbBodyLayers, makeLayer, newProject } from '../factories';
import { FX, makeEffect } from '../effects';
import { regularPts, SHAPE_PARAMS } from '../shapes';
import { saveProject } from '../db';
import { useStore } from '../store';
import type { AnimProp, Key, Layer, Project, ShapeKind } from '../types';
import { buildScript, find, type Goal, type Step, useAssistant } from '../assistant/engine';
import { expandRecipe } from './recipes';

export type Act = Record<string, unknown> & { do: string };

const SHAPES: ShapeKind[] = ['circle', 'roundrect', 'rect', 'triangle', 'star', 'hexagon', 'heart', 'plus', 'polygon', 'bar', 'crescent', 'custom'];
const PROPS: AnimProp[] = ['x', 'y', 'scale', 'rotation', 'opacity'];
const RATIOS: Record<string, [number, number]> = { '16:9': [1280, 720], '9:16': [720, 1280], '1:1': [720, 720], '4:5': [720, 900], '4:3': [960, 720] };

const num = (v: unknown, d: number) => (typeof v === 'number' && Number.isFinite(v) ? v : typeof v === 'string' && v.trim() !== '' && Number.isFinite(+v) ? +v : d);
const str = (v: unknown, d = '') => (typeof v === 'string' ? v : d);
const color = (v: unknown, d: string) => (typeof v === 'string' && /^#[0-9a-f]{3,8}$/i.test(v.trim()) ? v.trim().toUpperCase() : d);
const norm = (s: string) => s.toLocaleLowerCase('tr').replace(/[^\p{L}\p{N}]+/gu, ' ').trim();

// ---------- Bayraklar ve pack (isimle bul) ----------
let flagIndex: { code: string; names: string[] }[] | null = null;
async function flags() {
  if (flagIndex) return flagIndex;
  const all: { code: string; en: string; iso: boolean }[] = await fetch('flags/flags.json').then((r) => r.json());
  let dn: Intl.DisplayNames | null = null;
  try { dn = new Intl.DisplayNames(['tr'], { type: 'region' }); } catch { /* yok */ }
  flagIndex = all.map((f) => {
    const names = [f.code, norm(f.en)];
    if (f.iso && f.code.length === 2) { try { const n = dn?.of(f.code.toUpperCase()); if (n) names.push(norm(n)); } catch { /* yok */ } }
    if (f.code === 'wardencb') names.push('wardencb', 'warden', 'benim bayrağım');
    if (f.code === 'tr') names.push('turkiye', 'turkey', 'türkiye');
    return { code: f.code, names };
  });
  return flagIndex;
}
async function flagSrc(name: string): Promise<{ src: string; name: string } | null> {
  const q = norm(name);
  if (!q) return null;
  const list = await flags();
  const hit = list.find((f) => f.names.includes(q)) ?? list.find((f) => f.names.some((n) => n.startsWith(q) || q.startsWith(n) && n.length > 3));
  return hit ? { src: `flags/${hit.code}.svg`, name: name.trim() } : null;
}

interface PackItem { name: string; src: string; parts?: { name: string; src: string; back?: boolean; parent?: number }[]; root?: number }
let manifest: { name: string; items: PackItem[] }[] | null = null;
export async function packFolders() {
  if (!manifest) manifest = (await fetch('packs/hazir/manifest.json').then((r) => r.json())).folders;
  return manifest!;
}
async function packItem(item: string, folder?: string): Promise<PackItem | null> {
  const fs = await packFolders(), q = norm(item), fq = folder ? norm(folder) : '';
  const pool = fs.filter((f) => !fq || norm(f.name) === fq).flatMap((f) => f.items);
  return pool.find((i) => norm(i.name) === q) ?? pool.find((i) => norm(i.name).includes(q)) ?? fs.flatMap((f) => f.items).find((i) => norm(i.name) === q) ?? null;
}
const imgSize = (src: string) => new Promise<{ w: number; h: number }>((res) => {
  const i = new Image();
  i.onload = () => res({ w: i.naturalWidth || 512, h: i.naturalHeight || 512 });
  i.onerror = () => res({ w: 512, h: 512 });
  i.src = src;
});

// ---------- Ekranda gösterme (soru cevaplarken) ----------
const SHOW: Record<string, { need?: Goal; target: () => HTMLElement | null; needLayer?: boolean }> = {
  add: { need: { clean: true }, target: () => find('.fab-d') },
  shapes: { need: { add: 'Şekil' }, target: () => find('.addcard .addbody') },
  media: { need: { add: 'Medya' }, target: () => find('.addcard .addbody') },
  text: { need: { add: 'Metin' }, target: () => find('.addcard .addbody') },
  cb: { need: { add: 'CB' }, target: () => find('.addcard .addbody') },
  flags: { need: { add: 'Bayrak' }, target: () => find('.flag-scroll') },
  move: { need: { sel: () => true, noPanel: true }, target: () => find('.tbig', 'Taşı ve Çevir'), needLayer: true },
  effects: { need: { sel: () => true, noPanel: true }, target: () => find('.tbig', 'Efektler'), needLayer: true },
  color: { need: { sel: () => true, noPanel: true }, target: () => find('.tbig', 'Renk ve Dolgu'), needLayer: true },
  opacity: { need: { sel: () => true, noPanel: true }, target: () => find('.tbig', 'Karıştırma ve Opaklık'), needLayer: true },
  shape_edit: { need: { sel: (l) => l.type === 'shape', noPanel: true }, target: () => find('.tbig', 'Şekli Düzenle'), needLayer: true },
  keyframe: { need: { sel: () => true, panel: 'Taşı ve Çevir' }, target: () => find('[aria-label="Bu ana keyframe ekle"]') ?? find('[aria-label="Bu anki keyframe\'i sil"]'), needLayer: true },
  timeline: { need: { screen: 'editor' }, target: () => find('.tl') },
  play: { need: { screen: 'editor' }, target: () => find('[aria-label="Oynat"]') },
  export: { need: { clean: true }, target: () => find('[aria-label="Dışa aktar"]') },
  layer_menu: { need: { sel: () => true }, target: () => find('[aria-label="Diğer"]'), needLayer: true },
  tutorials: { need: { screen: 'tutorials' }, target: () => find('.tut-grid') },
  settings: { need: { screen: 'home' }, target: () => find('[aria-label="Ayarlar menüsü"]') },
  new_project: { need: { screen: 'home' }, target: () => find('.new-card') },
};
export const SHOW_KEYS = Object.keys(SHOW);

export function showOnScreen(target: string, say: string) {
  const s = SHOW[target];
  if (!s) return;
  const st = useStore.getState();
  if (s.needLayer && !(st.project?.layers.length)) {
    const sc = { id: 'ai-show', title: 'WardenCB', steps: [{ say: 'Bunun için önce bir katman lazım. + ile bir şey ekle, sonra göstereyim.', mood: 'point' as const, need: SHOW.add.need, target: SHOW.add.target, btn: 'Tamam', end: true }] };
    useAssistant.getState().start(sc);
    return;
  }
  const step: Step = { say, mood: 'point', need: s.need, target: s.target, btn: 'Tamam', end: true };
  useAssistant.getState().start({ id: 'ai-show', title: 'WardenCB', steps: [step] });
}

// ---------- Çalıştır ----------
export interface RunResult { project: Project; created: boolean; done: string[]; skipped: string[]; show?: string; play: boolean }

export async function runActions(acts: Act[], say: string): Promise<RunResult> {
  const st = useStore.getState();
  let p: Project | null = st.project ? structuredClone(st.project) : null;
  let created = false;
  const ids = new Map<string, string>(); // yapay zekânın verdiği isim → gerçek katman kimliği
  const done: string[] = [], skipped: string[] = [];
  let show: string | undefined, play = false;
  const need = () => {
    if (!p) { p = newProject('WardenCB Projesi', 720, 900, 30, '#FFFFFF'); created = true; }
    return p;
  };
  const layerOf = (ref: unknown) => {
    const r = str(ref);
    const id = ids.get(r) ?? r;
    return p?.layers.find((l) => l.id === id) ?? p?.layers.find((l) => norm(l.name) === norm(r));
  };
  const timing = (a: Act, pr: Project) => {
    const start = Math.max(0, num(a.start, 0));
    const end = Math.max(start + 0.1, num(a.end, Math.max(start + 2, ...pr.layers.map((l) => l.end), 2)));
    return { start, end };
  };
  const put = (a: Act, l: Layer) => { if (a.id) ids.set(str(a.id), l.id); };

  // Sıra: tarifler açıldıkça yerine kendi işleri girer
  const queue: Act[] = acts.slice(0, 60);
  let guard = 0;
  while (queue.length && guard++ < 400) {
    const a = queue.shift()!;
    try {
      switch (a.do) {
        case 'new_project': {
          const [w, h] = RATIOS[str(a.ratio, '4:5')] ?? RATIOS['4:5'];
          p = newProject(str(a.name, 'WardenCB Projesi').slice(0, 40), w, h, [24, 30, 60].includes(num(a.fps, 30)) ? num(a.fps, 30) : 30, color(a.background, '#FFFFFF'));
          created = true; ids.clear(); done.push('yeni proje');
          break;
        }
        case 'background': need().background = color(a.color, need().background); done.push('arka fon'); break;
        case 'add_shape': {
          const pr = need(), shape = (SHAPES.includes(a.shape as ShapeKind) ? a.shape : 'circle') as ShapeKind, { start, end } = timing(a, pr);
          const l: Layer = { ...makeLayer(pr, start, end - start, {
            type: 'shape', name: str(a.name, str(a.id, 'Şekil')).slice(0, 30), shape,
            w: Math.max(4, num(a.w, shape === 'bar' ? 320 : 200)), h: Math.max(2, num(a.h, shape === 'bar' ? 40 : 200)),
            fill: color(a.color, '#3B9BFF'), x: { v: num(a.x, pr.width / 2) }, y: { v: num(a.y, pr.height / 2) },
            rotation: { v: num(a.rotation, 0) }, opacity: { v: Math.min(1, Math.max(0, num(a.opacity, 1))) },
          }), id: uid() };
          if (a.color2) { l.fill2 = color(a.color2, l.fill); l.grad = { x1: 0, y1: -0.5, x2: 0, y2: 0.5 }; }
          if (a.params && typeof a.params === 'object') {
            const okKeys = (SHAPE_PARAMS[shape] ?? []).map((x) => x.key);
            l.sp = Object.fromEntries(Object.entries(a.params as Record<string, unknown>).filter(([k]) => okKeys.includes(k)).map(([k, v]) => [k, num(v, 0)]));
          }
          if (shape === 'custom') l.pts = Array.isArray(a.points) ? (a.points as unknown[][]).slice(0, 40).map((q) => [num(q[0], 0), num(q[1], 0)] as [number, number]) : regularPts(5);
          pr.layers.push(l); put(a, l); done.push(`${l.name}`);
          break;
        }
        case 'add_text': {
          const pr = need(), { start, end } = timing(a, pr), text = str(a.text, 'Metin').slice(0, 200);
          const size = Math.max(8, num(a.size, Math.round(pr.height / 12)));
          const l: Layer = { ...makeLayer(pr, start, end - start, { type: 'text', name: text.slice(0, 18), text, fontSize: size, fill: color(a.color, '#0D1631'), w: Math.round(Math.min(pr.width * 0.9, text.length * size * 0.62 + 20)), h: Math.round(size * 1.4 * text.split('\n').length), x: { v: num(a.x, pr.width / 2) }, y: { v: num(a.y, pr.height / 2) } }), id: uid() };
          pr.layers.push(l); put(a, l); done.push(`"${text.slice(0, 16)}" yazısı`);
          break;
        }
        case 'add_cb': {
          const pr = need(), { start, end } = timing(a, pr);
          const f = await flagSrc(str(a.flag));
          const body = ['yumusak-top', 'top', 'wardencb', 'yumusak-kup', 'kup'].includes(str(a.body)) ? str(a.body) : 'yumusak-top';
          const { layers, rootId } = cbBodyLayers(pr, start, end - start, body, f?.src ?? 'flags/xx.svg', f?.name ?? str(a.flag, 'CB'), num(a.size, Math.min(pr.width, pr.height) * 0.4));
          const root = layers.find((l) => l.id === rootId)!;
          root.x = { v: num(a.x, pr.width / 2) }; root.y = { v: num(a.y, pr.height / 2) };
          if (a.name) root.name = str(a.name).slice(0, 30);
          pr.layers.push(...layers); put(a, root); done.push(`${f?.name ?? 'CB'} CB`);
          if (!f) skipped.push(`"${str(a.flag)}" bayrağı bulunamadı`);
          break;
        }
        case 'add_pack': {
          const pr = need(), { start, end } = timing(a, pr);
          const it = await packItem(str(a.item), str(a.folder) || undefined);
          if (!it) { skipped.push(`"${str(a.item)}" pack'te yok`); break; }
          const parts = it.parts ?? [{ name: '', src: it.src }], root = it.root ?? 0;
          const { w, h } = await imgSize(parts[root].src);
          const onto0 = a.on ? layerOf(a.on) : undefined;
          const k = num(a.size, onto0 ? onto0.w * (it.parts ? 1.2 : 0.75) : Math.min(pr.width, pr.height) * 0.4) / Math.max(w, h);
          const pid = parts.map(() => uid());
          const made: Layer[] = parts.map((pt, i) => ({
            ...makeLayer(pr, start, end - start, { type: 'image', name: `${it.name}${pt.name ? ' ' + pt.name : ''}`, src: pt.src, w: Math.round(w * k), h: Math.round(h * k) }),
            id: pid[i], ...(i === root ? { x: { v: num(a.x, pr.width / 2) }, y: { v: num(a.y, pr.height / 2) } } : { parent: pid[pt.parent ?? root], x: { v: 0 }, y: { v: 0 } }),
          }));
          const backs = made.filter((_, i) => parts[i].back), rest = made.filter((_, i) => !parts[i].back);
          const onto = a.on ? layerOf(a.on) : undefined;
          if (onto) {
            // CB'ye takılan öğe (şapka vb.) CB'yi takip eder: konumu CB'ye göre
            const r = made[root], ox = valueAt(onto.x, start), oy = valueAt(onto.y, start);
            r.parent = onto.id;
            r.x = { v: a.x !== undefined ? Math.round(num(a.x, ox) - ox) : 0 };
            r.y = { v: a.y !== undefined ? Math.round(num(a.y, oy) - oy) : -Math.round(onto.h * (it.parts ? 0.32 : 0.5)) };
          }
          let at = pr.layers.length;
          if (backs.length && onto) {
            const fam = new Set([onto.id]);
            for (let ch = true; ch;) { ch = false; for (const l of pr.layers) if (l.parent && fam.has(l.parent) && !fam.has(l.id)) { fam.add(l.id); ch = true; } }
            at = pr.layers.findIndex((l) => fam.has(l.id));
          }
          pr.layers.splice(at, 0, ...backs);
          pr.layers.push(...rest);
          put(a, made[root]); done.push(it.name);
          break;
        }
        case 'animate': {
          const l = layerOf(a.id), prop = str(a.prop) as AnimProp;
          if (!l || !PROPS.includes(prop) || !Array.isArray(a.keys)) { skipped.push('bir hareket'); break; }
          const keys: Key[] = (a.keys as Record<string, unknown>[]).slice(0, 60).map((k) => {
            const e = EASES.find((x) => x.id === str(k.ease, 'inout'))?.e;
            return { t: Math.max(0, num(k.t, 0)), v: num(k.v, 0), ...(e ? { e } : {}) };
          }).sort((x, y) => x.t - y.t);
          if (!keys.length) break;
          l[prop] = { v: keys[0].v, k: keys };
          const last = keys[keys.length - 1].t;
          if (last > l.end) l.end = last + 0.2;
          done.push(`${l.name} hareketi`);
          break;
        }
        case 'effect': {
          const l = layerOf(a.id), type = str(a.type);
          const meta = FX.find((f) => f.type === type);
          if (!l || !meta) { skipped.push('bir efekt'); break; }
          const e = makeEffect(meta.type);
          if (a.params && typeof a.params === 'object') for (const [k, v] of Object.entries(a.params as Record<string, unknown>)) if (e.v?.[k]) e.v[k] = { v: num(v, e.v[k].v) };
          l.effects.push(e); done.push(`${meta.name}`);
          break;
        }
        case 'set': {
          const l = layerOf(a.id);
          if (!l) { skipped.push('bir değişiklik'); break; }
          if (a.color) l.fill = color(a.color, l.fill);
          if (a.name) l.name = str(a.name).slice(0, 30);
          if (a.start !== undefined) l.start = Math.max(0, num(a.start, l.start));
          if (a.end !== undefined) l.end = Math.max(l.start + 0.1, num(a.end, l.end));
          if (a.parent) {
            const par = layerOf(a.parent);
            if (par && par.id !== l.id && l.parent !== par.id) {
              // Takip etmeye başlayınca konum ebeveyne göre olur (ekranda yerinde kalsın)
              if (!l.parent) { const px = valueAt(par.x, l.start), py = valueAt(par.y, l.start); l.x = { v: Math.round(valueAt(l.x, l.start) - px) }; l.y = { v: Math.round(valueAt(l.y, l.start) - py) }; }
              l.parent = par.id;
            }
          }
          if (a.flipX !== undefined) l.flipX = !!a.flipX;
          done.push(`${l.name} ayarı`);
          break;
        }
        case 'delete': {
          const l = layerOf(a.id);
          if (l && p) { p.layers = p.layers.filter((x) => x.id !== l.id && x.parent !== l.id); done.push(`${l.name} silindi`); }
          break;
        }
        case 'play': play = true; break;
        case 'recipe': {
          const more = expandRecipe(a, (ref) => { const l = layerOf(ref); return l ? { x: valueAt(l.x, l.start), y: valueAt(l.y, l.start), end: l.end } : null; });
          if (more.length) { queue.unshift(...more); done.push(`tarif: ${str(a.name ?? a.tarif)}`); } else skipped.push(`"${str(a.name ?? a.tarif)}" tarifi`);
          break;
        }
        case 'show': if (SHOW[str(a.target)]) show = str(a.target); break;
        default: skipped.push(`bilinmeyen iş: ${a.do}`);
      }
    } catch { skipped.push(`${a.do} yapılamadı`); }
  }

  const changed = acts.some((a) => !['show', 'play'].includes(a.do));
  if (changed && p) {
    const pr = p as Project;
    pr.updatedAt = Date.now();
    if (created || !st.project || st.project.id !== pr.id) {
      await saveProject(pr);
      useStore.getState().open(pr);
    } else {
      useStore.getState().update(() => pr); // tek "Geri al" ile hepsi geri alınır
    }
    useStore.getState().select(null);
  }
  if (play) { useStore.getState().setTime(0); setTimeout(() => useStore.getState().setPlaying(true), 400); }
  if (show) setTimeout(() => showOnScreen(show!, say), 350);
  return { project: p ?? newProject('', 1, 1, 30, '#fff'), created, done, skipped, show, play };
}

export { buildScript };
