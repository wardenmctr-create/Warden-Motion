/** e: bu keyframe'den sonrakine geçişin yumuşatma eğrisi (cubic-bezier x1,y1,x2,y2). Yoksa doğrusal. */
export type Key = { t: number; v: number; e?: [number, number, number, number] };
/** Canlandırılabilir değer: keyframe yoksa sabit `v`, varsa `k` üzerinden ara değer. */
export type Anim = { v: number; k?: Key[] };

export type ShapeKind = 'circle' | 'roundrect' | 'rect' | 'triangle' | 'star' | 'hexagon' | 'heart' | 'plus';

export type FxType = 'blur' | 'sway' | 'shake' | 'glow' | 'brightness' | 'contrast' | 'saturate' | 'hue' | 'grayscale' | 'invert' | 'sepia' | 'shadow' | 'mirror';
export interface Effect { id: string; type: FxType; amount: number; speed?: number; color?: string }

export type LayerType = 'shape' | 'text' | 'image' | 'cb' | 'video';

export interface Layer {
  id: string;
  name: string;
  type: LayerType;
  start: number;
  end: number;
  x: Anim;
  y: Anim;
  scale: Anim;
  rotation: Anim;
  opacity: Anim;
  w: number;
  h: number;
  fill: string;
  shape?: ShapeKind;
  text?: string;
  fontSize?: number;
  /** Görsel kaynağı: 'packs/…' / 'flags/…' gibi bir yol ya da 'media:<id>' */
  src?: string;
  cb?: { outline: number; eyes?: string };
  effects: Effect[];
  hidden?: boolean;
  /** Takip edilen (ebeveyn) katman: konumu/dönüşü/ölçeği ona göre hesaplanır */
  parent?: string;
  /** Kırpma maskesi: bu katman, maske katmanının şekline kırpılır */
  mask?: string;
  /** true: maskenin şekli DIŞINDA kalan görünür (Hariç Tutma Grubu) */
  maskInvert?: boolean;
  /** Karıştırma modu (Normal, Çoğalt, Ekran…) */
  blend?: BlendMode;
  /** Geçişli renk: ikinci renk + katman kutusuna göre (-0.5..0.5) başlangıç/bitiş noktaları */
  fill2?: string;
  grad?: { x1: number; y1: number; x2: number; y2: number };
}

export type BlendMode = 'normal' | 'multiply' | 'screen' | 'overlay' | 'darken' | 'lighten' | 'color-dodge' | 'difference';

export interface Project {
  id: string;
  name: string;
  width: number;
  height: number;
  fps: number;
  background: string;
  layers: Layer[];
  updatedAt: number;
  tutorial?: string;
}

export type AnimProp = 'x' | 'y' | 'scale' | 'rotation' | 'opacity';
