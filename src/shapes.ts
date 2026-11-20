// Uygulamanın kendi şekilleri: çizim, ayarlar (Şekli Düzenle) ve önizlemedeki tutamaçlar.
import type { Layer, ShapeKind } from './types';

export interface ShapeParam { key: string; label: string; min: number; max: number; step: number; def: number; int?: boolean }
export const SHAPE_PARAMS: Partial<Record<ShapeKind, ShapeParam[]>> = {
  roundrect: [{ key: 'rad', label: 'Köşe yuvarlaklığı', min: 0, max: 0.5, step: 0.01, def: 0.18 }],
  star: [
    { key: 'n', label: 'Köşe sayısı', min: 3, max: 24, step: 1, def: 5, int: true },
    { key: 'inner', label: 'İç derinlik', min: 0.05, max: 0.95, step: 0.01, def: 0.45 },
  ],
  hexagon: [{ key: 'n', label: 'Kenar sayısı', min: 3, max: 24, step: 1, def: 6, int: true }],
  polygon: [{ key: 'n', label: 'Kenar sayısı', min: 3, max: 24, step: 1, def: 5, int: true }],
  plus: [{ key: 'thick', label: 'Kalınlık', min: 0.05, max: 0.95, step: 0.01, def: 0.32 }],
  bar: [{ key: 'round', label: 'Yuvarlak uçlar', min: 0, max: 1, step: 1, def: 1, int: true }],
  crescent: [
    { key: 'cx', label: 'Kesik yatay', min: -5, max: 5, step: 0.01, def: 0.3 },
    { key: 'cy', label: 'Kesik dikey', min: -5, max: 5, step: 0.01, def: -0.1 },
    { key: 'r', label: 'Kesik büyüklüğü', min: 0.1, max: 10, step: 0.01, def: 0.9 },
  ],
};
export const sp = (l: Pick<Layer, 'shape' | 'sp'>, key: string): number =>
  l.sp?.[key] ?? SHAPE_PARAMS[l.shape!]?.find((p) => p.key === key)?.def ?? 0;

export const regularPts = (n: number): [number, number][] =>
  Array.from({ length: n }, (_, i) => { const a = Math.PI * 2 / n * i - Math.PI / 2; return [Math.round(Math.cos(a) * 500) / 1000, Math.round(Math.sin(a) * 500) / 1000] as [number, number]; });

type ShapeLike = Pick<Layer, 'shape' | 'sp' | 'pts' | 'w' | 'h'>;

/** Şeklin yolu (hilal hariç: o, dış elipsten iç elips çıkarılarak çizilir) */
export function shapePath(kind: ShapeKind, w: number, h: number, l?: Partial<ShapeLike>): Path2D {
  const p = new Path2D();
  const hw = w / 2, hh = h / 2;
  const L = { shape: kind, sp: l?.sp };
  const poly = (pts: [number, number][]) => { pts.forEach(([x, y], i) => (i ? p.lineTo(x, y) : p.moveTo(x, y))); p.closePath(); };
  switch (kind) {
    case 'circle': case 'crescent': p.ellipse(0, 0, hw, hh, 0, 0, Math.PI * 2); break;
    case 'rect': p.rect(-hw, -hh, w, h); break;
    case 'roundrect': p.roundRect(-hw, -hh, w, h, Math.min(w, h) * sp(L, 'rad')); break;
    case 'bar': p.roundRect(-hw, -hh, w, h, sp(L, 'round') ? Math.min(w, h) / 2 : 0); break;
    case 'triangle': poly([[0, -hh], [hw, hh], [-hw, hh]]); break;
    case 'hexagon': case 'polygon': {
      const n = Math.round(sp(L, 'n'));
      poly(Array.from({ length: n }, (_, i) => { const a = Math.PI * 2 / n * i - Math.PI / 2; return [Math.cos(a) * hw, Math.sin(a) * hh] as [number, number]; }));
      break;
    }
    case 'star': {
      const n = Math.round(sp(L, 'n')), r0 = sp(L, 'inner');
      poly(Array.from({ length: n * 2 }, (_, i) => { const r = i % 2 ? r0 : 1, a = Math.PI / n * i - Math.PI / 2; return [Math.cos(a) * hw * r, Math.sin(a) * hh * r] as [number, number]; }));
      break;
    }
    case 'custom': poly((l?.pts ?? regularPts(5)).map(([x, y]) => [x * w, y * h])); break;
    case 'plus': {
      const t = sp(L, 'thick');
      p.rect(-hw * t, -hh, w * t, h); p.rect(-hw, -hh * t, w, h * t); break;
    }
    case 'heart':
      p.moveTo(0, hh);
      p.bezierCurveTo(-hw * 1.3, -hh * 0.1, -hw * 0.6, -hh * 1.2, 0, -hh * 0.45);
      p.bezierCurveTo(hw * 0.6, -hh * 1.2, hw * 1.3, -hh * 0.1, 0, hh);
      p.closePath(); break;
  }
  return p;
}

/** Şekli doldurur (hilal: dış elips − iç elips) */
export function fillShape(ctx: CanvasRenderingContext2D, l: ShapeLike & { shape: ShapeKind }) {
  const { w, h } = l;
  if (l.shape === 'crescent') {
    ctx.save();
    ctx.clip(shapePath('circle', w, h));
    const cut = new Path2D();
    const big = Math.max(w, h) * 20;
    cut.rect(-big, -big, big * 2, big * 2);
    cut.ellipse(sp(l, 'cx') * w, sp(l, 'cy') * h, sp(l, 'r') * w / 2, sp(l, 'r') * h / 2, 0, 0, Math.PI * 2);
    ctx.fill(cut, 'evenodd');
    ctx.restore();
    return;
  }
  ctx.fill(shapePath(l.shape, w, h, l));
}

// ---------------------------------------------------------------------------------------------
// Tutamaçlar (katmanın kendi koordinatında, ölçeksiz)
// ---------------------------------------------------------------------------------------------
export type HandleKind = 'corner' | 'edge' | 'crop' | 'special' | 'vertex';
export interface Handle { id: string; x: number; y: number; kind: HandleKind }

export const isAppShape = (l: Layer) => l.type === 'shape' && !!l.shape;
export const cropOf = (l: Layer) => ({ l: l.crop?.l ?? 0, t: l.crop?.t ?? 0, r: l.crop?.r ?? 0, b: l.crop?.b ?? 0 });
/** Görünen kutu (kırpma dahil) */
export function visBox(l: Layer) {
  const c = cropOf(l);
  return { x0: -l.w / 2 + c.l * l.w, x1: l.w / 2 - c.r * l.w, y0: -l.h / 2 + c.t * l.h, y1: l.h / 2 - c.b * l.h };
}

export function layerHandles(l: Layer): Handle[] {
  const b = visBox(l), mx = (b.x0 + b.x1) / 2, my = (b.y0 + b.y1) / 2;
  const out: Handle[] = [];
  if (l.shape === 'bar') {
    // Çubuk: uzunluk (uçta) ve kalınlık (üstte) tutamacı
    out.push({ id: 'bar-len', x: l.w / 2, y: 0, kind: 'special' }, { id: 'bar-thk', x: 0, y: -l.h / 2, kind: 'special' });
    return out;
  }
  for (const [sx, sy] of [[-1, -1], [1, -1], [1, 1], [-1, 1]]) out.push({ id: `c${sx}${sy}`, x: sx < 0 ? b.x0 : b.x1, y: sy < 0 ? b.y0 : b.y1, kind: 'corner' });
  if (isAppShape(l)) {
    out.push({ id: 'e-x', x: b.x0, y: my, kind: 'edge' }, { id: 'e+x', x: b.x1, y: my, kind: 'edge' }, { id: 'e-y', x: mx, y: b.y0, kind: 'edge' }, { id: 'e+y', x: mx, y: b.y1, kind: 'edge' });
  } else if (l.type !== 'text') {
    out.push({ id: 'k-l', x: b.x0, y: my, kind: 'crop' }, { id: 'k-r', x: b.x1, y: my, kind: 'crop' }, { id: 'k-t', x: mx, y: b.y0, kind: 'crop' }, { id: 'k-b', x: mx, y: b.y1, kind: 'crop' });
  }
  const min = Math.min(l.w, l.h);
  if (l.shape === 'crescent') out.push({ id: 'cres', x: sp(l, 'cx') * l.w, y: sp(l, 'cy') * l.h, kind: 'special' });
  if (l.shape === 'roundrect') { const o = Math.max(sp(l, 'rad') * min, min * 0.08); out.push({ id: 'rad', x: -l.w / 2 + o, y: -l.h / 2 + o, kind: 'special' }); }
  if (l.shape === 'star') {
    const n = Math.round(sp(l, 'n')), a = Math.PI / n - Math.PI / 2, r = sp(l, 'inner');
    out.push({ id: 'inner', x: Math.cos(a) * l.w / 2 * r, y: Math.sin(a) * l.h / 2 * r, kind: 'special' });
  }
  if (l.shape === 'custom') (l.pts ?? regularPts(5)).forEach(([x, y], i) => out.push({ id: 'v' + i, x: x * l.w, y: y * l.h, kind: 'vertex' }));
  return out;
}

const clamp = (v: number, a: number, b: number) => Math.max(a, Math.min(b, v));
const r3 = (v: number) => Math.round(v * 1000) / 1000;

/** Tutamaç sürüklenince katmanın yeni hâli. l0: sürükleme başındaki katman, lp: parmağın katman koordinatındaki yeri */
export function applyHandle(l0: Layer, id: string, lp: { x: number; y: number }, start: { x: number; y: number }): Partial<Layer> {
  const min = Math.min(l0.w, l0.h);
  if (id[0] === 'c' && id.length > 1 && (id[1] === '-' || id[1] === '1')) {
    // Köşe: orantılı büyüt/küçült (merkez sabit)
    const k = Math.max(0.02, Math.hypot(lp.x, lp.y) / Math.max(1, Math.hypot(start.x, start.y)));
    const out: Partial<Layer> = { w: Math.max(4, Math.round(l0.w * k)), h: Math.max(4, Math.round(l0.h * k)) };
    if (l0.type === 'text') out.fontSize = Math.max(6, Math.round((l0.fontSize ?? 64) * k));
    return out;
  }
  if (id === 'e-x' || id === 'e+x') return { w: Math.max(4, Math.round(Math.abs(lp.x) * 2)) };
  if (id === 'e-y' || id === 'e+y') return { h: Math.max(4, Math.round(Math.abs(lp.y) * 2)) };
  if (id === 'bar-len') return { w: Math.max(l0.h, Math.round(Math.abs(lp.x) * 2)) };
  if (id === 'bar-thk') return { h: Math.max(2, Math.min(l0.w, Math.round(Math.abs(lp.y) * 2))) };
  if (id.startsWith('k-')) {
    const c = cropOf(l0), fx = (lp.x + l0.w / 2) / l0.w, fy = (lp.y + l0.h / 2) / l0.h;
    if (id === 'k-l') c.l = r3(clamp(fx, 0, 1 - c.r - 0.05));
    if (id === 'k-r') c.r = r3(clamp(1 - fx, 0, 1 - c.l - 0.05));
    if (id === 'k-t') c.t = r3(clamp(fy, 0, 1 - c.b - 0.05));
    if (id === 'k-b') c.b = r3(clamp(1 - fy, 0, 1 - c.t - 0.05));
    return { crop: c };
  }
  if (id === 'cres') return { sp: { ...l0.sp, cx: r3(clamp(lp.x / l0.w, -5, 5)), cy: r3(clamp(lp.y / l0.h, -5, 5)) } };
  if (id === 'rad') return { sp: { ...l0.sp, rad: r3(clamp((lp.x + l0.w / 2) / min, 0, 0.5)) } };
  if (id === 'inner') {
    const n = Math.round(sp(l0, 'n')), a = Math.PI / n - Math.PI / 2;
    const ux = Math.cos(a) * l0.w / 2, uy = Math.sin(a) * l0.h / 2;
    return { sp: { ...l0.sp, inner: r3(clamp((lp.x * ux + lp.y * uy) / (ux * ux + uy * uy), 0.05, 0.95)) } };
  }
  if (id[0] === 'v') {
    const i = +id.slice(1), pts = [...(l0.pts ?? regularPts(5))];
    pts[i] = [r3(clamp(lp.x / l0.w, -0.5, 0.5)), r3(clamp(lp.y / l0.h, -0.5, 0.5))];
    return { pts };
  }
  return {};
}

/** Serbest çokgene köşe ekle (en uzun kenarın ortasına) / çıkar (sonuncuyu) */
export function addVertex(pts: [number, number][]): [number, number][] {
  let best = 0, bl = -1;
  for (let i = 0; i < pts.length; i++) { const a = pts[i], b = pts[(i + 1) % pts.length]; const d = Math.hypot(a[0] - b[0], a[1] - b[1]); if (d > bl) { bl = d; best = i; } }
  const a = pts[best], b = pts[(best + 1) % pts.length];
  const out = [...pts];
  out.splice(best + 1, 0, [r3((a[0] + b[0]) / 2), r3((a[1] + b[1]) / 2)]);
  return out;
}
