import type { Anim, Key, Layer, Project } from './types';

/** cubic-bezier(x1,y1,x2,y2) eğrisinde x=p için y değeri (CSS ile aynı) */
export function bezier(e: [number, number, number, number] | undefined, p: number): number {
  if (!e) return p;
  const [x1, y1, x2, y2] = e;
  const bx = (u: number) => 3 * x1 * u * (1 - u) ** 2 + 3 * x2 * u * u * (1 - u) + u ** 3;
  const by = (u: number) => 3 * y1 * u * (1 - u) ** 2 + 3 * y2 * u * u * (1 - u) + u ** 3;
  let lo = 0, hi = 1, u = p;
  for (let i = 0; i < 24; i++) { u = (lo + hi) / 2; if (bx(u) < p) lo = u; else hi = u; }
  return by(u);
}

/** Hazır yumuşatma eğrileri */
export const EASES: { id: string; name: string; e?: [number, number, number, number] }[] = [
  { id: 'linear', name: 'Doğrusal' },
  { id: 'in', name: 'Yavaş başla', e: [0.42, 0, 1, 1] },
  { id: 'out', name: 'Yavaş bitir', e: [0, 0, 0.58, 1] },
  { id: 'inout', name: 'Yavaş başla ve bitir', e: [0.42, 0, 0.58, 1] },
  { id: 'back', name: 'Geri sekme', e: [0.34, 1.56, 0.64, 1] },
];
export const EASE_INOUT: [number, number, number, number] = [0.42, 0, 0.58, 1];

export function valueAt(a: Anim, t: number): number {
  const k = a.k;
  if (!k || k.length === 0) return a.v;
  if (t <= k[0].t) return k[0].v;
  const last = k[k.length - 1];
  if (t >= last.t) return last.v;
  for (let i = 0; i < k.length - 1; i++) {
    const a0 = k[i], a1 = k[i + 1];
    if (t >= a0.t && t <= a1.t) {
      const p = (t - a0.t) / (a1.t - a0.t || 1);
      return a0.v + (a1.v - a0.v) * bezier(a0.e, p);
    }
  }
  return last.v;
}

export const EPS = 1 / 120;

export function keyAt(a: Anim, t: number): Key | undefined {
  return a.k?.find((k) => Math.abs(k.t - t) < EPS);
}

/** Değeri yazar: keyframe'li ise o anda keyframe oluşturur/günceller. */
export function setAnim(a: Anim, t: number, v: number): Anim {
  if (!a.k || a.k.length === 0) return { v };
  const old = a.k.find((x) => Math.abs(x.t - t) < EPS);
  const k = a.k.filter((x) => Math.abs(x.t - t) >= EPS);
  k.push(old?.e ? { t, v, e: old.e } : { t, v });
  k.sort((p, q) => p.t - q.t);
  return { v, k };
}

/** Keyframe aç/kapat: o anda keyframe varsa siler, yoksa ekler. */
export function toggleKey(a: Anim, t: number): Anim {
  const cur = valueAt(a, t);
  if (keyAt(a, t)) {
    const k = a.k!.filter((x) => Math.abs(x.t - t) >= EPS);
    return k.length ? { v: cur, k } : { v: cur };
  }
  const k = [...(a.k ?? []), { t, v: cur }].sort((p, q) => p.t - q.t);
  return { v: cur, k };
}

export function projectDuration(p: Project): number {
  return Math.max(1, ...p.layers.map((l) => l.end));
}

export function layerKeyTimes(l: Layer): number[] {
  const s = new Set<number>();
  for (const a of [l.x, l.y, l.scale, l.rotation, l.opacity]) a.k?.forEach((k) => s.add(Math.round(k.t * 1000) / 1000));
  return [...s].sort((a, b) => a - b);
}

export const fmtTime = (t: number, fps = 30) => {
  const s = Math.floor(t);
  const f = Math.floor((t - s) * fps);
  const mm = String(Math.floor(s / 60)).padStart(2, '0');
  return `${mm}:${String(s % 60).padStart(2, '0')}:${String(f).padStart(2, '0')}`;
};

export const uid = () => Math.random().toString(36).slice(2, 10);

/** Zaman t'den önceki (ya da t'deki) keyframe: yumuşatma eğrisi bu keyframe'e yazılır */
export function segmentKey(a: Anim, t: number): Key | undefined {
  const k = a.k;
  if (!k || k.length < 2) return undefined;
  let best: Key | undefined;
  for (const x of k) if (x.t <= t + EPS) best = x;
  if (!best || best === k[k.length - 1]) best = k[Math.max(0, k.length - 2)];
  return best;
}

/** Verilen özelliklerin, t anındaki geçişine yumuşatma eğrisi yazar */
export function setEase(a: Anim, t: number, e: [number, number, number, number] | undefined): Anim {
  const seg = segmentKey(a, t);
  if (!seg || !a.k) return a;
  return { ...a, k: a.k.map((x) => (x === seg ? (e ? { ...x, e } : { t: x.t, v: x.v }) : x)) };
}
