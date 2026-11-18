import { uid } from './anim';
import type { Effect, FxType } from './types';

export interface FxMeta {
  type: FxType; name: string; cat: string;
  /** Kaydırıcı: etiket, aralık, varsayılan */
  label: string; min: number; max: number; def: number; step?: number;
  speed?: boolean; color?: string;
  /** Efekt Tarayıcısı küçük resmine uygulanan CSS */
  css: string;
}

export const FX: FxMeta[] = [
  { type: 'blur', name: 'Gauss Bulanıklığı', cat: 'Bulanıklık', label: 'Miktar', min: 0, max: 60, def: 8, css: 'filter: blur(5px)' },
  { type: 'sway', name: 'Oto-Sallanma', cat: 'Hareket', label: 'Açı (°)', min: 0, max: 45, def: 6, speed: true, css: 'animation: fx-sway 1.2s ease-in-out infinite' },
  { type: 'shake', name: 'Rastgele Titreşim', cat: 'Hareket', label: 'Mesafe', min: 0, max: 60, def: 8, speed: true, css: 'animation: fx-shake .35s steps(3) infinite' },
  { type: 'glow', name: 'Parlama', cat: 'Işık ve Gölge', label: 'Miktar', min: 0, max: 60, def: 16, color: '#3FD0F0', css: 'filter: drop-shadow(0 0 7px #3FD0F0) drop-shadow(0 0 3px #3FD0F0)' },
  { type: 'shadow', name: 'Gölge', cat: 'Işık ve Gölge', label: 'Miktar', min: 0, max: 60, def: 14, color: '#0D1631', css: 'filter: drop-shadow(5px 6px 4px rgba(13,22,49,.7))' },
  { type: 'brightness', name: 'Parlaklık', cat: 'Renk ve Işık', label: 'Yüzde', min: 0, max: 300, def: 140, css: 'filter: brightness(1.6)' },
  { type: 'contrast', name: 'Kontrast', cat: 'Renk ve Işık', label: 'Yüzde', min: 0, max: 300, def: 150, css: 'filter: contrast(1.9)' },
  { type: 'saturate', name: 'Doygunluk', cat: 'Renk ve Işık', label: 'Yüzde', min: 0, max: 300, def: 180, css: 'filter: saturate(2.4)' },
  { type: 'hue', name: 'Ton Kaydırma', cat: 'Renk ve Işık', label: 'Derece', min: -180, max: 180, def: 90, css: 'filter: hue-rotate(110deg)' },
  { type: 'grayscale', name: 'Siyah Beyaz', cat: 'Renk ve Işık', label: 'Yüzde', min: 0, max: 100, def: 100, css: 'filter: grayscale(1)' },
  { type: 'sepia', name: 'Eski Fotoğraf', cat: 'Renk ve Işık', label: 'Yüzde', min: 0, max: 100, def: 100, css: 'filter: sepia(1)' },
  { type: 'invert', name: 'Ters Çevir', cat: 'Renk ve Işık', label: 'Yüzde', min: 0, max: 100, def: 100, css: 'filter: invert(1)' },
  { type: 'mirror', name: 'Ayna', cat: 'Bozulma', label: 'Karışım', min: 0, max: 100, def: 100, css: 'transform: scaleX(-1)' },
];

export const FX_CATS: { name: string; bg: string }[] = [
  { name: 'Renk ve Işık', bg: 'linear-gradient(135deg, #1B3A7A, #6B3FA0 60%, #E84393)' },
  { name: 'Işık ve Gölge', bg: 'linear-gradient(135deg, #0B1430, #1F3270 55%, #3FD0F0)' },
  { name: 'Bulanıklık', bg: 'radial-gradient(circle at 30% 40%, #8FA6D6, #2A3A72 70%)' },
  { name: 'Hareket', bg: 'linear-gradient(135deg, #0E5A63, #22D3C5)' },
  { name: 'Bozulma', bg: 'repeating-linear-gradient(135deg, #1B3A7A 0 10px, #2459B8 10px 20px)' },
];

export const FEATURED: FxType[] = ['blur', 'sway', 'glow'];

export const fxMeta = (t: FxType) => FX.find((f) => f.type === t)!;

export function makeEffect(t: FxType): Effect {
  const m = fxMeta(t);
  return { id: uid(), type: t, amount: m.def, ...(m.speed ? { speed: t === 'shake' ? 1.5 : 0.8 } : {}), ...(m.color ? { color: m.color } : {}) };
}

/** Kanvas filtresi (render için) */
export function fxFilter(e: Effect, q: number): string | null {
  const a = e.amount;
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
