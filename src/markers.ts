// Hareket işaretleyicileri (keyframe işaretleri): her "iş" için ayrı grup.
// Gruplar: 'pos' (konum), 'rot' (döndürme), 'scl' (ölçek), 'op' (opaklık), 'fx:<efektId>:<özellik>'
import { EPS } from './anim';
import { fxMeta, paramKeys } from './effects';
import type { Anim, Layer } from './types';

export interface Marker { group: string; t: number }

const PROP_GROUPS: Record<string, ('x' | 'y' | 'scale' | 'rotation' | 'opacity')[]> = {
  pos: ['x', 'y'], rot: ['rotation'], scl: ['scale'], op: ['opacity'],
};

export const GROUP_NAME: Record<string, string> = { pos: 'Konum', rot: 'Döndürme', scl: 'Ölçek', op: 'Opaklık' };

/** Grubun animasyon değerleri; set ile katmanın yeni hali üretilir */
function groupAnims(l: Layer, g: string): { a: Anim; set: (l: Layer, a: Anim) => Layer }[] {
  if (PROP_GROUPS[g]) return PROP_GROUPS[g].map((k) => ({ a: l[k], set: (L: Layer, a: Anim) => ({ ...L, [k]: a }) }));
  const [, fxId, pkey] = g.split(':');
  const e = l.effects.find((x) => x.id === fxId);
  if (!e) return [];
  const pr = fxMeta(e.type).params.find((p) => p.key === pkey);
  if (!pr) return [];
  return paramKeys(pr).filter((k) => e.v?.[k]).map((k) => ({
    a: e.v![k],
    set: (L: Layer, a: Anim) => ({ ...L, effects: L.effects.map((x) => (x.id === fxId ? { ...x, v: { ...x.v, [k]: a } } : x)) }),
  }));
}

/** Katmanın bütün işaretleyicileri (aynı grup + aynı an = tek işaretleyici) */
export function layerMarkers(l: Layer): Marker[] {
  const groups = [...Object.keys(PROP_GROUPS)];
  for (const e of l.effects) for (const pr of fxMeta(e.type).params) groups.push(`fx:${e.id}:${pr.key}`);
  const out: Marker[] = [];
  for (const g of groups) {
    const ts: number[] = [];
    for (const { a } of groupAnims(l, g)) for (const k of a.k ?? []) if (!ts.some((x) => Math.abs(x - k.t) < EPS)) ts.push(k.t);
    for (const t of ts) out.push({ group: g, t });
  }
  return out;
}

/** Grubun t anındaki keyframe'lerini başka bir ana taşır (oradaki varsa üzerine yazılır) */
export function moveMarker(l: Layer, g: string, t0: number, t1: number): Layer {
  let L = l;
  for (const { a, set } of groupAnims(l, g)) {
    if (!a.k) continue;
    const moving = a.k.find((k) => Math.abs(k.t - t0) < EPS);
    if (!moving) continue;
    const k = a.k.filter((x) => x !== moving && Math.abs(x.t - t1) >= EPS);
    k.push({ ...moving, t: t1 });
    k.sort((p, q) => p.t - q.t);
    L = set(L, { ...a, k });
  }
  return L;
}

/** Grubun t anındaki keyframe'lerini siler */
export function deleteMarker(l: Layer, g: string, t: number): Layer {
  let L = l;
  for (const { a, set } of groupAnims(l, g)) {
    if (!a.k) continue;
    const k = a.k.filter((x) => Math.abs(x.t - t) >= EPS);
    L = set(L, k.length ? { ...a, k } : { v: a.v });
  }
  return L;
}

export function groupLabel(l: Layer, g: string): string {
  if (GROUP_NAME[g]) return GROUP_NAME[g];
  const [, fxId, pkey] = g.split(':');
  const e = l.effects.find((x) => x.id === fxId);
  if (!e) return '';
  const m = fxMeta(e.type);
  return `${m.name} · ${m.params.find((p) => p.key === pkey)?.label ?? ''}`;
}
