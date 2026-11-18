import { valueAt } from './anim';
import { getMedia } from './db';
import type { Layer, Project, ShapeKind } from './types';
import { fxFilter } from './effects';

// ---------- Görsel önbelleği ----------
const cache = new Map<string, HTMLImageElement | 'loading' | 'error'>();
let onLoaded: () => void = () => {};
export const setImageLoadedHandler = (fn: () => void) => { onLoaded = fn; };

export function resolveSrc(src: string): Promise<string> {
  if (src.startsWith('media:')) {
    return getMedia(src.slice(6)).then((b) => (b ? URL.createObjectURL(b) : ''));
  }
  return Promise.resolve(src);
}

export function getImage(src: string): HTMLImageElement | null {
  const c = cache.get(src);
  if (c instanceof HTMLImageElement) return c;
  if (c) return null;
  cache.set(src, 'loading');
  resolveSrc(src).then((url) => {
    if (!url) { cache.set(src, 'error'); return; }
    const img = new Image();
    img.onload = () => { cache.set(src, img); onLoaded(); };
    img.onerror = () => cache.set(src, 'error');
    img.src = url;
  });
  return null;
}

export function preloadImages(srcs: string[]): Promise<void> {
  return Promise.all(srcs.map((s) => new Promise<void>((res) => {
    if (getImage(s)) return res();
    const iv = setInterval(() => {
      const c = cache.get(s);
      if (c instanceof HTMLImageElement || c === 'error') { clearInterval(iv); res(); }
    }, 30);
  }))).then(() => undefined);
}

// ---------- Şekiller ----------
export function shapePath(kind: ShapeKind, w: number, h: number): Path2D {
  const p = new Path2D();
  const hw = w / 2, hh = h / 2;
  switch (kind) {
    case 'circle': p.ellipse(0, 0, hw, hh, 0, 0, Math.PI * 2); break;
    case 'rect': p.rect(-hw, -hh, w, h); break;
    case 'roundrect': p.roundRect(-hw, -hh, w, h, Math.min(w, h) * 0.18); break;
    case 'triangle': p.moveTo(0, -hh); p.lineTo(hw, hh); p.lineTo(-hw, hh); p.closePath(); break;
    case 'hexagon':
      for (let i = 0; i < 6; i++) {
        const a = Math.PI / 3 * i - Math.PI / 2;
        i ? p.lineTo(Math.cos(a) * hw, Math.sin(a) * hh) : p.moveTo(Math.cos(a) * hw, Math.sin(a) * hh);
      }
      p.closePath(); break;
    case 'star':
      for (let i = 0; i < 10; i++) {
        const r = i % 2 ? 0.45 : 1;
        const a = Math.PI / 5 * i - Math.PI / 2;
        i ? p.lineTo(Math.cos(a) * hw * r, Math.sin(a) * hh * r) : p.moveTo(Math.cos(a) * hw * r, Math.sin(a) * hh * r);
      }
      p.closePath(); break;
    case 'plus': {
      const t = 0.32;
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

// ---------- Kare çizimi ----------
const noise = (t: number, seed: number) => Math.sin(t * 12.9898 + seed * 78.233) * 0.5 + Math.sin(t * 4.1 + seed) * 0.5;

export function layerTransform(l: Layer, t: number) {
  let x = valueAt(l.x, t), y = valueAt(l.y, t), rot = valueAt(l.rotation, t);
  const local = t - l.start;
  for (const e of l.effects) {
    if (e.type === 'sway') rot += Math.sin(local * (e.speed ?? 0.8) * Math.PI * 2) * e.amount;
    if (e.type === 'shake') {
      const sp = e.speed ?? 1.5;
      const tt = Math.floor(local * sp * 10) / (sp * 10 || 1);
      x += noise(tt, 1) * e.amount; y += noise(tt, 2) * e.amount;
    }
  }
  return { x, y, rot, scale: valueAt(l.scale, t), opacity: valueAt(l.opacity, t) };
}

export type TR = ReturnType<typeof layerTransform>;
const IDENT: TR = { x: 0, y: 0, rot: 0, scale: 1, opacity: 1 };

/** Takip zinciri (ebeveyn) dahil, katmanın sahnedeki gerçek dönüşümü. */
export function worldTransform(p: Project, l: Layer, t: number, depth = 0): TR {
  const loc = layerTransform(l, t);
  const par = l.parent && depth < 8 ? p.layers.find((x) => x.id === l.parent) : undefined;
  if (!par) return loc;
  const pw = worldTransform(p, par, t, depth + 1);
  const a = pw.rot * Math.PI / 180;
  return {
    x: pw.x + (loc.x * Math.cos(a) - loc.y * Math.sin(a)) * pw.scale,
    y: pw.y + (loc.x * Math.sin(a) + loc.y * Math.cos(a)) * pw.scale,
    rot: pw.rot + loc.rot,
    scale: pw.scale * loc.scale,
    opacity: loc.opacity,
  };
}

export function parentWorld(p: Project, l: Layer, t: number): TR {
  const par = l.parent ? p.layers.find((x) => x.id === l.parent) : undefined;
  return par ? worldTransform(p, par, t) : IDENT;
}

/** Sahnedeki bir değeri (dünya) ebeveynin yerel koordinatına çevirir. */
export function toLocal(pw: TR, w: TR): TR {
  const a = -pw.rot * Math.PI / 180;
  const dx = (w.x - pw.x) / pw.scale, dy = (w.y - pw.y) / pw.scale;
  return { x: dx * Math.cos(a) - dy * Math.sin(a), y: dx * Math.sin(a) + dy * Math.cos(a), rot: w.rot - pw.rot, scale: w.scale / pw.scale, opacity: w.opacity };
}

export interface RenderOpts { selectedId?: string | null; quality?: number; /** Lite oynatma: bulanıklık/parlama atlanır */ fast?: boolean; /** Renk panelinde geçiş tutamaçlarını göster */ gradHandles?: boolean; /** Taşı ve Çevir açıkken seçili katmanın hareket yolu */ motionPath?: boolean }

let bufA: HTMLCanvasElement | null = null, bufB: HTMLCanvasElement | null = null;
const buf = (c: HTMLCanvasElement | null, w: number, h: number) => {
  const b = c ?? document.createElement('canvas');
  if (b.width !== w || b.height !== h) { b.width = w; b.height = h; }
  const x = b.getContext('2d')!;
  x.setTransform(1, 0, 0, 1, 0, 0);
  x.globalCompositeOperation = 'source-over';
  x.clearRect(0, 0, w, h);
  return b;
};

function paint(ctx: CanvasRenderingContext2D, p: Project, l: Layer, t: number, q: number, fast = false) {
  const tr = worldTransform(p, l, t);
  ctx.save();
  ctx.setTransform(q, 0, 0, q, 0, 0);
  ctx.translate(tr.x, tr.y);
  ctx.rotate(tr.rot * Math.PI / 180);
  ctx.scale(tr.scale, tr.scale);
  ctx.globalAlpha = Math.max(0, Math.min(1, tr.opacity));
  const filters: string[] = [];
  for (const e of l.effects) {
    if (fast && (e.type === 'blur' || e.type === 'glow' || e.type === 'shadow')) continue;
    const f = fxFilter(e, q);
    if (f) filters.push(f);
  }
  if (l.effects.some((e) => e.type === 'mirror' && e.amount >= 50)) ctx.scale(-1, 1);
  ctx.filter = filters.length ? filters.join(' ') : 'none';
  if (l.blend && l.blend !== 'normal' && !l.mask) ctx.globalCompositeOperation = l.blend as GlobalCompositeOperation;
  drawLayer(ctx, l);
  ctx.restore();
  return tr;
}

const visible = (l: Layer, t: number) => !l.hidden && t >= l.start && t < l.end;

export function renderFrame(ctx: CanvasRenderingContext2D, p: Project, t: number, opts: RenderOpts = {}) {
  const q = opts.quality ?? 1;
  const fast = !!opts.fast;
  ctx.setTransform(q, 0, 0, q, 0, 0);
  ctx.globalAlpha = 1;
  ctx.filter = 'none';
  ctx.globalCompositeOperation = 'source-over';
  ctx.fillStyle = p.background;
  ctx.fillRect(0, 0, p.width, p.height);
  for (const l of p.layers) {
    if (!visible(l, t)) continue;
    const m = l.mask ? p.layers.find((x) => x.id === l.mask) : undefined;
    if (m) {
      // Kırpma maskesi: katmanı ayrı tuvale çiz, maskenin şekliyle kes, sonra sahneye bas
      const W = ctx.canvas.width, H = ctx.canvas.height;
      bufA = buf(bufA, W, H); bufB = buf(bufB, W, H);
      paint(bufA.getContext('2d')!, p, l, t, q, fast);
      if (visible(m, t) || m.hidden) paint(bufB.getContext('2d')!, p, { ...m, hidden: false, effects: [] }, t, q);
      const a = bufA.getContext('2d')!;
      a.globalCompositeOperation = 'destination-in';
      a.drawImage(bufB, 0, 0);
      ctx.save();
      ctx.setTransform(1, 0, 0, 1, 0, 0);
      if (l.blend && l.blend !== 'normal') ctx.globalCompositeOperation = l.blend as GlobalCompositeOperation;
      ctx.drawImage(bufA, 0, 0);
      ctx.restore();
    } else {
      paint(ctx, p, l, t, q, fast);
    }
  }
  const sel = opts.selectedId ? p.layers.find((l) => l.id === opts.selectedId) : undefined;
  if (sel && opts.motionPath) drawMotionPath(ctx, p, sel, q);
  if (sel && visible(sel, t)) drawSelection(ctx, sel, worldTransform(p, sel, t), q, !!opts.gradHandles);
}

function drawImageCover(ctx: CanvasRenderingContext2D, img: HTMLImageElement, w: number, h: number) {
  const s = Math.max(w / img.naturalWidth, h / img.naturalHeight);
  const iw = img.naturalWidth * s, ih = img.naturalHeight * s;
  ctx.drawImage(img, -iw / 2, -ih / 2, iw, ih);
}

function fillOf(ctx: CanvasRenderingContext2D, l: Layer): string | CanvasGradient {
  if (!l.fill2 || !l.grad) return l.fill;
  const g = ctx.createLinearGradient(l.grad.x1 * l.w, l.grad.y1 * l.h, l.grad.x2 * l.w, l.grad.y2 * l.h);
  g.addColorStop(0, l.fill);
  g.addColorStop(1, l.fill2);
  return g;
}

function drawLayer(ctx: CanvasRenderingContext2D, l: Layer) {
  const { w, h } = l;
  if (l.type === 'shape' && l.shape) {
    ctx.fillStyle = fillOf(ctx, l);
    ctx.fill(shapePath(l.shape, w, h));
  } else if (l.type === 'text') {
    ctx.fillStyle = fillOf(ctx, l);
    ctx.font = `700 ${l.fontSize ?? 64}px Inter, system-ui, sans-serif`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    const lines = (l.text ?? '').split('\n');
    const lh = (l.fontSize ?? 64) * 1.15;
    lines.forEach((ln, i) => ctx.fillText(ln, 0, (i - (lines.length - 1) / 2) * lh));
  } else if (l.type === 'image' && l.src) {
    const img = getImage(l.src);
    if (img) ctx.drawImage(img, -w / 2, -h / 2, w, h);
  } else if (l.type === 'cb' && l.src) {
    const r = Math.min(w, h) / 2;
    ctx.save();
    ctx.beginPath();
    ctx.arc(0, 0, r, 0, Math.PI * 2);
    ctx.clip();
    const img = getImage(l.src);
    if (img) drawImageCover(ctx, img, r * 2, r * 2);
    else { ctx.fillStyle = '#C9D3E3'; ctx.fill(); }
    ctx.restore();
    const ow = l.cb?.outline ?? 6;
    if (ow > 0) {
      ctx.beginPath();
      ctx.arc(0, 0, r - ow / 2, 0, Math.PI * 2);
      ctx.lineWidth = ow;
      ctx.strokeStyle = '#000000';
      ctx.stroke();
    }
    if (l.cb?.eyes) {
      const eyes = getImage(l.cb.eyes);
      if (eyes) { const ew = r * 1.3; ctx.drawImage(eyes, -ew / 2, -r * 0.62, ew, ew); }
    }
  }
}

function drawSelection(ctx: CanvasRenderingContext2D, l: Layer, tr: TR, q: number, grad = false) {
  ctx.save();
  ctx.setTransform(q, 0, 0, q, 0, 0);
  ctx.translate(tr.x, tr.y);
  ctx.rotate(tr.rot * Math.PI / 180);
  const w = l.w * tr.scale, h = l.h * tr.scale;
  const lw = 2 / q * Math.max(1, ctx.canvas.width / q / 700);
  ctx.strokeStyle = '#3B9BFF';
  ctx.lineWidth = lw;
  ctx.strokeRect(-w / 2, -h / 2, w, h);
  ctx.fillStyle = '#DCE9FF';
  const hr = lw * 3.5;
  for (const [hx, hy] of [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]) {
    ctx.beginPath();
    ctx.arc(hx * w / 2, hy * h / 2, hr, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();
  }
  if (grad && l.grad && l.fill2) {
    const k = tr.scale;
    const a = [l.grad.x1 * l.w * k, l.grad.y1 * l.h * k], b = [l.grad.x2 * l.w * k, l.grad.y2 * l.h * k];
    ctx.beginPath(); ctx.moveTo(a[0], a[1]); ctx.lineTo(b[0], b[1]);
    ctx.strokeStyle = '#F7F8FA'; ctx.lineWidth = lw; ctx.stroke();
    for (const [pt, c] of [[a, l.fill], [b, l.fill2]] as [number[], string][]) {
      ctx.beginPath(); ctx.arc(pt[0], pt[1], hr * 1.6, 0, Math.PI * 2);
      ctx.fillStyle = c; ctx.fill(); ctx.strokeStyle = '#0B1430'; ctx.lineWidth = lw * 1.5; ctx.stroke();
    }
  }
  ctx.restore();
}

/** Önizlemede dokunulan katmanı bul (üstten alta). */
export function hitTest(p: Project, t: number, px: number, py: number, only?: string): Layer | null {
  for (let i = p.layers.length - 1; i >= 0; i--) {
    const l = p.layers[i];
    if (only && l.id !== only) continue;
    if (l.hidden || t < l.start || t >= l.end) continue;
    const tr = worldTransform(p, l, t);
    const a = -tr.rot * Math.PI / 180;
    const dx = px - tr.x, dy = py - tr.y;
    const lx = dx * Math.cos(a) - dy * Math.sin(a), ly = dx * Math.sin(a) + dy * Math.cos(a);
    if (Math.abs(lx) <= l.w * tr.scale / 2 && Math.abs(ly) <= l.h * tr.scale / 2) return l;
  }
  return null;
}

/** Konum keyframe'leri arasındaki yolu çizgi, keyframe noktalarını nokta olarak çizer */
function drawMotionPath(ctx: CanvasRenderingContext2D, p: Project, l: Layer, q: number) {
  const ts = new Set<number>();
  l.x.k?.forEach((k) => ts.add(k.t)); l.y.k?.forEach((k) => ts.add(k.t));
  const keys = [...ts].sort((a, b) => a - b);
  if (keys.length < 2) return;
  const t0 = keys[0], t1 = keys[keys.length - 1];
  const lw = 1.5 / q * Math.max(1, ctx.canvas.width / q / 700);
  ctx.save();
  ctx.setTransform(q, 0, 0, q, 0, 0);
  ctx.beginPath();
  const N = Math.max(24, Math.round((t1 - t0) * 30));
  for (let i = 0; i <= N; i++) {
    const w = worldTransform(p, l, t0 + (t1 - t0) * i / N);
    i ? ctx.lineTo(w.x, w.y) : ctx.moveTo(w.x, w.y);
  }
  ctx.strokeStyle = '#0D1631'; ctx.lineWidth = lw * 2.2; ctx.globalAlpha = 0.5; ctx.stroke();
  ctx.strokeStyle = '#F7F8FA'; ctx.lineWidth = lw; ctx.globalAlpha = 1; ctx.stroke();
  for (const kt of keys) {
    const w = worldTransform(p, l, kt);
    ctx.beginPath(); ctx.arc(w.x, w.y, lw * 3, 0, Math.PI * 2);
    ctx.fillStyle = '#22D3C5'; ctx.fill();
  }
  ctx.restore();
}
