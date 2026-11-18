import type { Anim, Key, Layer, Project } from './types';

const ease = (p: number) => (p < 0.5 ? 4 * p * p * p : 1 - Math.pow(-2 * p + 2, 3) / 2);

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
      return a0.v + (a1.v - a0.v) * ease(p);
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
  const k = a.k.filter((x) => Math.abs(x.t - t) >= EPS);
  k.push({ t, v });
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
