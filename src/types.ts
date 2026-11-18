export type Key = { t: number; v: number };
/** Canlandırılabilir değer: keyframe yoksa sabit `v`, varsa `k` üzerinden ara değer. */
export type Anim = { v: number; k?: Key[] };

export type ShapeKind = 'circle' | 'roundrect' | 'rect' | 'triangle' | 'star' | 'hexagon' | 'heart' | 'plus';

export type Effect =
  | { id: string; type: 'blur'; amount: number }
  | { id: string; type: 'sway'; amount: number; speed: number }
  | { id: string; type: 'shake'; amount: number; speed: number }
  | { id: string; type: 'glow'; amount: number; color: string };

export type LayerType = 'shape' | 'text' | 'image' | 'cb';

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
}

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
