/** e: bu keyframe'den sonrakine geçişin yumuşatma eğrisi (cubic-bezier x1,y1,x2,y2). Yoksa doğrusal. */
export type Key = { t: number; v: number; e?: [number, number, number, number] };
/** Canlandırılabilir değer: keyframe yoksa sabit `v`, varsa `k` üzerinden ara değer. */
export type Anim = { v: number; k?: Key[] };

export type ShapeKind = 'circle' | 'roundrect' | 'rect' | 'triangle' | 'star' | 'hexagon' | 'heart' | 'plus' | 'polygon' | 'bar' | 'crescent' | 'custom';

export type FxType = 'blur' | 'sway' | 'shake' | 'glow' | 'brightness' | 'contrast' | 'saturate' | 'hue' | 'grayscale' | 'invert' | 'sepia' | 'shadow' | 'mirror' | 'fractal' | 'motionblur';
/** v: keyframe'lenebilir parametreler (2B parametreler 'posX' / 'posY' gibi iki anahtar). amount/speed eski projeler için. */
export interface Effect { id: string; type: FxType; amount: number; speed?: number; color?: string; v?: Record<string, Anim>; closed?: boolean }

export type LayerType = 'shape' | 'text' | 'image' | 'cb' | 'video' | 'audio';

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
  /** Şekil ayarları (Şekli Düzenle): köşe sayısı, iç derinlik, hilal kesiği… */
  sp?: Record<string, number>;
  /** Serbest çokgenin köşeleri (kutuya göre -0.5..0.5) */
  pts?: [number, number][];
  /** Kırpma (görsel/video/CB): her kenardan kesilen oran 0..1 */
  crop?: { l: number; t: number; r: number; b: number };
  text?: string;
  fontSize?: number;
  /** Görsel kaynağı: 'packs/…' / 'flags/…' gibi bir yol ya da 'media:<id>' */
  src?: string;
  cb?: { outline: number; eyes?: string };
  effects: Effect[];
  hidden?: boolean;
  /** Ses düzeyi (ses ve video katmanları), 1 = %100 */
  volume?: number;
  /** Sesi kapalı */
  muted?: boolean;
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
  /** Geçiş tipi: doğrusal (varsayılan) ya da dairesel */
  gtype?: 'linear' | 'radial';
  /** Dolgu yok (sadece şekil) */
  noFill?: boolean;
  flipX?: boolean;
  flipY?: boolean;
  /** Zaman çizelgesinde katman renk etiketi */
  tag?: string;
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
