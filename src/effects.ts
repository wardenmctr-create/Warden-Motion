import { uid, valueAt } from './anim';
import type { Effect, FxType } from './types';

export interface FxParam { /** jog: kaydırma cetveli (varsayılan), slider: kaydırıcı, toggle: aç/kapa */ kind?: 'jog' | 'slider' | 'toggle'; key: string; label: string; two?: boolean; min: number; max: number; step: number; def: number; defY?: number; /** jog: 1 px kaydırmanın değeri */ jog: number }
export interface FxMeta { type: FxType; name: string; cat: string; params: FxParam[]; color?: string; css: string; info?: string }

const P = (key: string, label: string, min: number, max: number, def: number, step = 1, jog = step): FxParam => ({ key, label, min, max, def, step, jog });

export const FX: FxMeta[] = [
  { type: 'fractal', name: 'Fraktal Bükme', cat: 'Bozulma', params: [
    { key: 'pos', label: 'Konum', two: true, min: -1e5, max: 1e5, def: 0, defY: 0, step: 1, jog: 1 },
    { key: 'par', label: 'Paralaks', two: true, min: -1e5, max: 1e5, def: 0, defY: 0, step: 1, jog: 1 },
    P('mag', 'Büyüklük', 0, 3, 0.2, 0.005, 0.005),
    P('det', 'Ayrıntı', 0, 6, 1, 0.01, 0.02),
    P('scl', 'Ölçek', 0.1, 10, 1, 0.01, 0.01),
  ], css: 'filter: url(#fx-warp)' },
  { type: 'motionblur', name: 'Hareket Bulanıklığı', cat: 'Bulanıklık', info: 'Kullanmak için katmanı Taşı ve Çevir ile canlandır (bulanıklık kendiliğinden uygulanır).', params: [
    { kind: 'slider', key: 'tune', label: 'Ayar', min: 0, max: 4, def: 1, step: 0.01, jog: 0.01 },
    { kind: 'toggle', key: 'pos', label: 'Konum', min: 0, max: 1, def: 1, step: 1, jog: 1 },
    { kind: 'toggle', key: 'scl', label: 'Ölçek', min: 0, max: 1, def: 1, step: 1, jog: 1 },
    { kind: 'toggle', key: 'ang', label: 'Açı', min: 0, max: 1, def: 1, step: 1, jog: 1 },
  ], css: 'filter: blur(2px); transform: translateX(-4px)' },
  { type: 'blur', name: 'Gauss Bulanıklığı', cat: 'Bulanıklık', params: [P('amount', 'Miktar', 0, 60, 8, 0.5, 0.2)], css: 'filter: blur(5px)' },
  { type: 'sway', name: 'Oto-Sallanma', cat: 'Hareket', params: [P('amount', 'Açı', 0, 45, 6, 0.5, 0.2), P('speed', 'Hız', 0.1, 5, 0.8, 0.05, 0.02)], css: 'animation: fx-sway 1.2s ease-in-out infinite' },
  { type: 'shake', name: 'Rastgele Titreşim', cat: 'Hareket', params: [P('amount', 'Mesafe', 0, 60, 8, 0.5, 0.2), P('speed', 'Hız', 0.1, 5, 1.5, 0.05, 0.02)], css: 'animation: fx-shake .35s steps(3) infinite' },
  { type: 'glow', name: 'Parlama', cat: 'Işık ve Gölge', params: [P('amount', 'Miktar', 0, 60, 16, 0.5, 0.2)], color: '#3FD0F0', css: 'filter: drop-shadow(0 0 7px #3FD0F0) drop-shadow(0 0 3px #3FD0F0)' },
  { type: 'shadow', name: 'Gölge', cat: 'Işık ve Gölge', params: [P('amount', 'Miktar', 0, 60, 14, 0.5, 0.2)], color: '#0D1631', css: 'filter: drop-shadow(5px 6px 4px rgba(13,22,49,.7))' },
  { type: 'brightness', name: 'Parlaklık', cat: 'Renk ve Işık', params: [P('amount', 'Yüzde', 0, 300, 140, 1, 0.5)], css: 'filter: brightness(1.6)' },
  { type: 'contrast', name: 'Kontrast', cat: 'Renk ve Işık', params: [P('amount', 'Yüzde', 0, 300, 150, 1, 0.5)], css: 'filter: contrast(1.9)' },
  { type: 'saturate', name: 'Doygunluk', cat: 'Renk ve Işık', params: [P('amount', 'Yüzde', 0, 300, 180, 1, 0.5)], css: 'filter: saturate(2.4)' },
  { type: 'hue', name: 'Ton Kaydırma', cat: 'Renk ve Işık', params: [P('amount', 'Derece', -180, 180, 90, 1, 0.5)], css: 'filter: hue-rotate(110deg)' },
  { type: 'grayscale', name: 'Siyah Beyaz', cat: 'Renk ve Işık', params: [P('amount', 'Yüzde', 0, 100, 100, 1, 0.5)], css: 'filter: grayscale(1)' },
  { type: 'sepia', name: 'Eski Fotoğraf', cat: 'Renk ve Işık', params: [P('amount', 'Yüzde', 0, 100, 100, 1, 0.5)], css: 'filter: sepia(1)' },
  { type: 'invert', name: 'Ters Çevir', cat: 'Renk ve Işık', params: [P('amount', 'Yüzde', 0, 100, 100, 1, 0.5)], css: 'filter: invert(1)' },
  { type: 'mirror', name: 'Ayna', cat: 'Bozulma', params: [], css: 'transform: scaleX(-1)' },
];

export const FX_CATS: { name: string; bg: string }[] = [
  { name: 'Renk ve Işık', bg: 'linear-gradient(135deg, #1B3A7A, #6B3FA0 60%, #E84393)' },
  { name: 'Işık ve Gölge', bg: 'linear-gradient(135deg, #0B1430, #1F3270 55%, #3FD0F0)' },
  { name: 'Bulanıklık', bg: 'radial-gradient(circle at 30% 40%, #8FA6D6, #2A3A72 70%)' },
  { name: 'Hareket', bg: 'linear-gradient(135deg, #0E5A63, #22D3C5)' },
  { name: 'Bozulma', bg: 'repeating-linear-gradient(135deg, #1B3A7A 0 10px, #2459B8 10px 20px)' },
];

export const FEATURED: FxType[] = ['motionblur', 'fractal', 'blur'];

export const fxMeta = (t: FxType) => FX.find((f) => f.type === t)!;

/** Parametre anahtarları (2B parametreler X/Y olarak iki anahtar) */
export const paramKeys = (pr: FxParam) => (pr.two ? [pr.key + 'X', pr.key + 'Y'] : [pr.key]);

/** Efekt parametresinin t anındaki değeri (eski projelerdeki amount/speed da okunur) */
export function fxVal(e: Effect, key: string, t: number): number {
  const a = e.v?.[key];
  if (a) return valueAt(a, t);
  if (key === 'amount') return e.amount;
  if (key === 'speed' && e.speed !== undefined) return e.speed;
  const m = fxMeta(e.type);
  const pr = m.params.find((p) => p.key === key || p.key + 'X' === key || p.key + 'Y' === key);
  if (!pr) return 0;
  return key.endsWith('Y') && pr.two ? (pr.defY ?? pr.def) : pr.def;
}

export function makeEffect(t: FxType): Effect {
  const m = fxMeta(t);
  const v: Record<string, { v: number }> = {};
  for (const pr of m.params) {
    if (pr.two) { v[pr.key + 'X'] = { v: pr.def }; v[pr.key + 'Y'] = { v: pr.defY ?? pr.def }; } else v[pr.key] = { v: pr.def };
  }
  return { id: uid(), type: t, amount: (v.amount?.v ?? 0), v, ...(m.color ? { color: m.color } : {}) };
}

/** Kanvas filtresi (render için) */
export function fxFilter(e: Effect, q: number, t: number): string | null {
  const a = fxVal(e, 'amount', t);
  switch (e.type) {
    case 'blur': return a > 0 ? `blur(${a * q}px)` : null;
    case 'glow': return a > 0 ? `drop-shadow(0 0 ${a * q}px ${e.color ?? '#3FD0F0'})` : null;
    case 'shadow': return a > 0 ? `drop-shadow(${a * 0.4 * q}px ${a * 0.5 * q}px ${a * 0.5 * q}px ${e.color ?? '#0D1631'})` : null;
    case 'brightness': return `brightness(${a}%)`;
    case 'contrast': return `contrast(${a}%)`;
    case 'saturate': return `saturate(${a}%)`;
    case 'hue': return `hue-rotate(${a}deg)`;
    case 'grayscale': return `grayscale(${a}%)`;
    case 'sepia': return `sepia(${a}%)`;
    case 'invert': return `invert(${a}%)`;
    default: return null;
  }
}

// ---------- Fraktal Bükme (fraktal gürültüyle yer değiştirme) ----------
const PERM = new Uint8Array(512);
{ let s = 1337; const p = Array.from({ length: 256 }, (_, i) => i); for (let i = 255; i > 0; i--) { s = (s * 16807) % 2147483647; const j = s % (i + 1); [p[i], p[j]] = [p[j], p[i]]; } for (let i = 0; i < 512; i++) PERM[i] = p[i & 255]; }
const GX = [1, -1, 1, -1, 1, -1, 0, 0], GY = [1, 1, -1, -1, 0, 0, 1, -1];
function perlin(x: number, y: number): number {
  const xi = Math.floor(x), yi = Math.floor(y), xf = x - xi, yf = y - yi;
  const X = xi & 255, Y = yi & 255;
  const u = xf * xf * xf * (xf * (xf * 6 - 15) + 10), v = yf * yf * yf * (yf * (yf * 6 - 15) + 10);
  const g = (h: number, dx: number, dy: number) => GX[h & 7] * dx + GY[h & 7] * dy;
  const aa = PERM[PERM[X] + Y], ab = PERM[PERM[X] + Y + 1], ba = PERM[PERM[X + 1] + Y], bb = PERM[PERM[X + 1] + Y + 1];
  const x1 = g(aa, xf, yf) + u * (g(ba, xf - 1, yf) - g(aa, xf, yf));
  const x2 = g(ab, xf, yf - 1) + u * (g(bb, xf - 1, yf - 1) - g(ab, xf, yf - 1));
  return x1 + v * (x2 - x1);
}
/** Katmanlı (fraktal) gürültü. Paralaks her katmanı farklı kaydırır: büyük şekiller sabit kalırken ayrıntı hareket eder. */
function fbm(x: number, y: number, oct: number, ox: number, oy: number, px: number, py: number, seed: number): number {
  let sum = 0, amp = 1, f = 1, norm = 0;
  const n = Math.ceil(oct) + 1;
  for (let i = 0; i < n; i++) {
    const w = i < Math.floor(oct) + 1 ? 1 : (oct + 1 - i);
    if (w <= 0) break;
    sum += perlin((x + ox + px * i) * f + seed, (y + oy + py * i) * f - seed) * amp * w;
    norm += amp * w; amp *= 0.5; f *= 2;
  }
  return norm ? sum / norm : 0;
}

/** Tuvaldeki katman görüntüsünü fraktal gürültüyle büker. q: tuval pikseli / proje pikseli. */
export function applyFractalWarp(c: HTMLCanvasElement, e: Effect, t: number, q: number, box: { x0: number; y0: number; x1: number; y1: number }) {
  const mag = fxVal(e, 'mag', t), det = fxVal(e, 'det', t), scl = Math.max(0.1, fxVal(e, 'scl', t));
  if (mag <= 0) return;
  const ox = fxVal(e, 'posX', t) / 200, oy = fxVal(e, 'posY', t) / 200, px = fxVal(e, 'parX', t) / 200, py = fxVal(e, 'parY', t) / 200;
  const D = mag * 260 * q; // en fazla yer değiştirme (tuval pikseli)
  const W = c.width, H = c.height;
  const x0 = Math.max(0, Math.floor(box.x0 - D)), y0 = Math.max(0, Math.floor(box.y0 - D));
  const x1 = Math.min(W, Math.ceil(box.x1 + D)), y1 = Math.min(H, Math.ceil(box.y1 + D));
  const bw = x1 - x0, bh = y1 - y0;
  if (bw <= 0 || bh <= 0) return;
  const ctx = c.getContext('2d')!;
  const src = ctx.getImageData(0, 0, W, H);
  const out = ctx.createImageData(bw, bh);
  const S = 1 / (200 * q * scl); // gürültü frekansı
  const G = 6; // gürültüyü 6 pikselde bir hesapla, aradakileri doğrusal doldur
  const gw = Math.ceil(bw / G) + 2, gh = Math.ceil(bh / G) + 2;
  const dxs = new Float32Array(gw * gh), dys = new Float32Array(gw * gh);
  for (let j = 0; j < gh; j++) for (let i = 0; i < gw; i++) {
    const X = (x0 + i * G) * S, Y = (y0 + j * G) * S;
    dxs[j * gw + i] = fbm(X, Y, det, ox, oy, px, py, 3.7) * D;
    dys[j * gw + i] = fbm(X, Y, det, ox, oy, px, py, 11.3) * D;
  }
  const sd = src.data, od = out.data;
  for (let y = 0; y < bh; y++) {
    const gy = y / G, j = Math.floor(gy), fy = gy - j;
    for (let x = 0; x < bw; x++) {
      const gx = x / G, i = Math.floor(gx), fx = gx - i;
      const k = j * gw + i;
      const dx = (dxs[k] * (1 - fx) + dxs[k + 1] * fx) * (1 - fy) + (dxs[k + gw] * (1 - fx) + dxs[k + gw + 1] * fx) * fy;
      const dy = (dys[k] * (1 - fx) + dys[k + 1] * fx) * (1 - fy) + (dys[k + gw] * (1 - fx) + dys[k + gw + 1] * fx) * fy;
      const sx = (x0 + x + dx) | 0, sy = (y0 + y + dy) | 0;
      if (sx < 0 || sy < 0 || sx >= W || sy >= H) continue;
      const si = (sy * W + sx) * 4, oi = (y * bw + x) * 4;
      od[oi] = sd[si]; od[oi + 1] = sd[si + 1]; od[oi + 2] = sd[si + 2]; od[oi + 3] = sd[si + 3];
    }
  }
  ctx.clearRect(x0, y0, bw, bh);
  ctx.putImageData(out, x0, y0);
}
