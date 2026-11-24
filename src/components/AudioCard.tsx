import { useEffect, useState } from 'react';
import { Icon } from './Icon';

const GRADS = [
  ['#5B6FB8', '#C46A8E', '#E8A07A'], ['#4E9E7A', '#B9C76A', '#E8D27A'], ['#C27A3E', '#E0A85A', '#E8C27A'],
  ['#7A4EB8', '#4E6EC4', '#3E9EC2'], ['#B84E6E', '#E07A6A', '#E8B27A'], ['#3E8EA8', '#5AB8A0', '#A8D27A'],
];
const hash = (s: string) => { let h = 0; for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) | 0; return Math.abs(h); };
export const fmtSec = (s: number) => { const n = Math.max(0, Math.round(s)); return `${String(Math.floor(n / 60)).padStart(2, '0')}:${String(n % 60).padStart(2, '0')}`; };

// ---------- Ön dinleme: aynı anda tek ses çalar ----------
let cur: { key: string; el: HTMLAudioElement } | null = null;
const subs = new Set<(k: string) => void>();
const emit = () => subs.forEach((f) => f(cur?.key ?? ''));
/** Çalıyorsa durdurur, çalmıyorsa çalar (url'yi gerektiğinde ister) */
export async function toggleListen(key: string, getUrl: () => Promise<string>) {
  if (cur?.key === key) { stopListen(); return; }
  stopListen();
  const el = new Audio();
  cur = { key, el };
  emit();
  try {
    el.src = await getUrl();
    if (cur?.el !== el) return;
    el.onended = () => { if (cur?.el === el) { cur = null; emit(); } };
    await el.play();
  } catch { if (cur?.el === el) { cur = null; emit(); } }
}
export function stopListen() {
  if (!cur) return;
  cur.el.pause(); cur.el.removeAttribute('src');
  cur = null;
  emit();
}
export function useListening() {
  const [k, setK] = useState(cur?.key ?? '');
  useEffect(() => { subs.add(setK); return () => { subs.delete(setK); }; }, []);
  return k;
}

/** Süs amaçlı dalga (isme göre hep aynı) */
function FakeWave({ seed }: { seed: number }) {
  const bars = [];
  let x = seed || 1;
  for (let i = 0; i < 34; i++) {
    x = (x * 1103515245 + 12345) & 0x7fffffff;
    const env = Math.sin((i / 33) * Math.PI) * 0.7 + 0.3;
    const h = Math.max(2, ((x % 100) / 100) * 22 * env);
    bars.push(<rect key={i} x={i * 3} y={12 - h / 2} width={1.6} height={h} rx={0.8} />);
  }
  return <svg className="ac-wave" viewBox="0 0 102 24" preserveAspectRatio="none" aria-hidden="true">{bars}</svg>;
}

/** Ses kartı: karta basınca dinlenir, alttaki + ile projeye eklenir */
export function AudioCard({ name, dur, recent, playing, onListen, onAdd }: { name: string; dur?: number; recent?: boolean; playing?: boolean; onListen: () => void; onAdd: () => void }) {
  const h = hash(name);
  const g = GRADS[h % GRADS.length];
  const label = name.replace(/\.[^.]+$/, '');
  return (
    <div className={'acard' + (playing ? ' playing' : '')} role="button" tabIndex={0} aria-label={`${label} dinle`} onClick={onListen}
      onKeyDown={(e) => e.key === 'Enter' && onListen()} style={{ background: `linear-gradient(160deg, ${g[0]}, ${g[1]} 55%, ${g[2]})` }}>
      <span className="ac-name">{label}</span>
      {dur !== undefined && <span className="ac-dur">{fmtSec(dur)}</span>}
      <FakeWave seed={h} />
      {playing ? <span className="ac-recent on" aria-label="Çalıyor"><Icon name="pause" size={12} /></span>
        : recent && <span className="ac-recent" aria-label="Son kullanılan"><Icon name="clock" size={14} /></span>}
      <button className="ac-plus" aria-label={`${label} projeye ekle`} onClick={(e) => { e.stopPropagation(); stopListen(); onAdd(); }}><Icon name="plus" size={22} stroke={2.4} /></button>
    </div>
  );
}
