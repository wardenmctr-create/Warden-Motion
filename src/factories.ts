import { regularPts } from './shapes';
import { EASE_INOUT, uid } from './anim';
import type { Layer, Project, ShapeKind } from './types';

export function newProject(name: string, width: number, height: number, fps: number, background: string): Project {
  return { id: uid(), name, width, height, fps, background, layers: [], updatedAt: Date.now() };
}

const A = (v: number) => ({ v });

/**
 * CB gövdesi: çizgi (kök) + beyaz iç (takip eder) [+ içe kırpılmış bayrak + gözler].
 * Sıra alttan üste; "size" verilmezse projenin yarısı.
 */
export function cbBodyLayers(p: Project, t: number, dur: number, shape: string, flagSrc?: string, flagName?: string, size0?: number): { layers: Layer[]; rootId: string } {
  const size = Math.round(size0 ?? Math.min(p.width, p.height) * 0.5);
  const lineId = uid(), innerId = uid();
  const line = { ...makeLayer(p, t, dur, { type: 'image', name: `${flagName ?? 'Gövde'} Çizgi`, src: `packs/hazir/govdeler/${shape}-cizgi.png`, w: size, h: size }), id: lineId };
  const inner = { ...makeLayer(p, t, dur, { type: 'image', name: `${flagName ?? 'Gövde'} İç`, src: `packs/hazir/govdeler/${shape}-ic.png`, w: size, h: size }), id: innerId, parent: lineId, x: A(0), y: A(0) };
  const extra: Layer[] = [];
  if (flagSrc) {
    // Basık gövde: bayrak alt kısımda (üstü beyaz), gözler kendi göz setinden ve gövdeye göre ölçülü yerinde
    const wb = shape === 'wardencb';
    extra.push({ ...makeLayer(p, t, dur, { type: 'image', name: `${flagName} Bayrak`, src: flagSrc, w: Math.round(size * (wb ? 1 : 1.34)), h: Math.round(size * (wb ? 0.68 : 1)) }), id: uid(), parent: lineId, mask: innerId, x: A(0), y: A(wb ? Math.round(size * 0.1) : 0) });
    extra.push({ ...makeLayer(p, t, dur, { type: 'image', name: `${flagName} Gözler`, src: wb ? 'packs/hazir/gozler/wardencb-bakan.png' : 'packs/hazir/gozler/normal.png', w: Math.round(size * (wb ? 0.95 : 0.62)), h: Math.round(size * (wb ? 0.95 : 0.62)) }), id: uid(), parent: lineId, x: A(wb ? -Math.round(size * 0.0375) : 0), y: A(wb ? Math.round(size * 0.1125) : -Math.round(size * 0.06)) });
  }
  return { layers: [inner, ...extra.slice(0, 1), line, ...extra.slice(1)], rootId: lineId };
}

export function makeLayer(p: Project, start: number, dur: number, part: Partial<Layer> & Pick<Layer, 'type' | 'name'>): Omit<Layer, 'id'> {
  const size = Math.round(Math.min(p.width, p.height) * 0.35);
  return {
    start, end: start + dur,
    x: A(p.width / 2), y: A(p.height / 2), scale: A(1), rotation: A(0), opacity: A(1),
    w: size, h: size, fill: '#8F7CF0', effects: [],
    ...part,
  };
}

export const SHAPES: { kind: ShapeKind; name: string; w?: number; h?: number; sp?: Record<string, number>; pts?: [number, number][] }[] = [
  { kind: 'circle', name: 'Daire' }, { kind: 'roundrect', name: 'Yuvarlatılmış Dikdörtgen', w: 260 },
  { kind: 'plus', name: 'Artı' }, { kind: 'triangle', name: 'Üçgen' }, { kind: 'hexagon', name: 'Altıgen' },
  { kind: 'star', name: 'Yıldız' }, { kind: 'rect', name: 'Kare', w: 260 }, { kind: 'heart', name: 'Kalp' },
  { kind: 'bar', name: 'Çubuk', w: 320, h: 44 }, { kind: 'crescent', name: 'Hilal' },
  { kind: 'polygon', name: 'Çokgen' }, { kind: 'custom', name: 'Serbest Çokgen', pts: regularPts(5) },
];

// ---------- Şablonlar ----------
export interface Template { id: string; name: string; make: () => Project }

// Şablon keyframe'lerine yumuşak geçiş ver (varsayılan artık doğrusal)
const soft = (l: Omit<Layer, 'id'>): Omit<Layer, 'id'> => {
  const f = (a: Layer['x']) => (a.k ? { ...a, k: a.k.map((k) => ({ ...k, e: EASE_INOUT })) } : a);
  return { ...l, x: f(l.x), y: f(l.y), scale: f(l.scale), rotation: f(l.rotation), opacity: f(l.opacity) };
};
const withLayers = (p: Project, ls: Omit<Layer, 'id'>[]): Project => ({ ...p, layers: ls.map((l) => ({ ...soft(l), id: uid() })) });

export const TEMPLATES: Template[] = [
  {
    id: 'top', name: 'Zıplayan Top',
    make: () => {
      const p = newProject('Zıplayan Top', 720, 900, 30, '#FFFFFF');
      const ball = makeLayer(p, 0, 3, { type: 'shape', name: 'Top', shape: 'circle', fill: '#2F7BF6', w: 180, h: 180 });
      ball.y = { v: 200, k: [{ t: 0, v: 200 }, { t: 0.75, v: 700 }, { t: 1.5, v: 200 }, { t: 2.25, v: 700 }, { t: 3, v: 200 }] };
      ball.scale = { v: 1, k: [{ t: 0.6, v: 1 }, { t: 0.75, v: 0.85 }, { t: 0.9, v: 1 }, { t: 2.1, v: 1 }, { t: 2.25, v: 0.85 }, { t: 2.4, v: 1 }] };
      const shadow = makeLayer(p, 0, 3, { type: 'shape', name: 'Gölge', shape: 'circle', fill: '#9AA6B8', w: 200, h: 40 });
      shadow.y = { v: 800 };
      shadow.opacity = { v: 0.4, k: [{ t: 0, v: 0.2 }, { t: 0.75, v: 0.6 }, { t: 1.5, v: 0.2 }, { t: 2.25, v: 0.6 }, { t: 3, v: 0.2 }] };
      return withLayers(p, [shadow, ball]);
    },
  },
  {
    id: 'cb', name: 'CB Selam',
    make: () => {
      const p = newProject('CB Selam', 720, 900, 30, '#EAF4FF');
      const cb = makeLayer(p, 0, 4, { type: 'cb', name: 'Türkiyeball', src: 'flags/tr.svg', w: 360, h: 360, cb: { outline: 10, eyes: 'packs/hazir/gozler/normal.png' } });
      cb.effects = [{ id: uid(), type: 'sway', amount: 6, speed: 0.8 }];
      cb.y = { v: 520, k: [{ t: 0, v: 1150 }, { t: 0.8, v: 520 }] };
      const bubble = makeLayer(p, 1, 3, { type: 'image', name: 'Konuşma Balonu', src: 'packs/hazir/esyalar/konusma-balonu.png', w: 420, h: 420 });
      bubble.y = { v: 220 };
      bubble.scale = { v: 1, k: [{ t: 1, v: 0 }, { t: 1.3, v: 1 }] };
      const text = makeLayer(p, 1.2, 2.8, { type: 'text', name: 'Selam', text: 'Selam!', fontSize: 72, fill: '#0D1631', w: 300, h: 90 });
      text.y = { v: 205 };
      return withLayers(p, [cb, bubble, text]);
    },
  },
  {
    id: 'yazi', name: 'Yazı Girişi',
    make: () => {
      const p = newProject('Yazı Girişi', 1280, 720, 30, '#0B1430');
      const t = makeLayer(p, 0, 3, { type: 'text', name: 'Başlık', text: 'WARDEN', fontSize: 150, fill: '#3FD0F0', w: 700, h: 170 });
      t.scale = { v: 1, k: [{ t: 0, v: 0.4 }, { t: 0.6, v: 1 }] };
      t.opacity = { v: 1, k: [{ t: 0, v: 0 }, { t: 0.6, v: 1 }] };
      t.effects = [{ id: uid(), type: 'glow', amount: 18, color: '#22D3C5' }];
      const bar = makeLayer(p, 0.4, 2.6, { type: 'shape', name: 'Çizgi', shape: 'rect', fill: '#2F7BF6', w: 600, h: 12 });
      bar.y = { v: 470 };
      bar.scale = { v: 1, k: [{ t: 0.4, v: 0 }, { t: 1, v: 1 }] };
      return withLayers(p, [bar, t]);
    },
  },
];

// ---------- Öğreticiler ----------
export interface Tutorial {
  id: string; title: string; kind: 'CB' | 'Genel'; level: string; ready: boolean;
  summary: string; steps: string[]; tips: string[]; ratio: [number, number]; bg: string;
}

export const TUTORIALS: Tutorial[] = [
  {
    id: 'cb1', title: 'Temel CB', kind: 'CB', level: 'Temel', ready: true, ratio: [720, 900], bg: '#EAF4FF',
    summary: 'İlk countryball\'unu yap: bayrak, göz, ağız, şapka ve hafif sallanma.',
    steps: [
      'Sağ alttaki + butonuna bas, Bayraklar sekmesinden bir ülke seç ve "CB olarak ekle"ye dokun.',
      'CB seçiliyken alttaki "CB Ayarları"na gir. Bir göz seç ve kontur kalınlığını ayarla.',
      '+ → CB Araçları → Hazır Pack → Ağızlar\'dan bir ağız ekle. Önizlemede sürükleyip CB\'nin üstüne yerleştir.',
      'Şapkalar klasöründen bir şapka ekle. "Taşı ve Çevir" → Ölçek ile boyutunu ayarla.',
      'CB\'yi tekrar seç, Efektler\'den "Oto-Sallanma" ekle. Küçük bir açı (4–8°) yeterli.',
      '▶ ile oynat. Beğendiysen sağ üstteki dışa aktar butonuyla videonu kaydet!',
    ],
    tips: [
      'Klasik countryball\'larda göz bebeği yoktur; ifadeyi göz kapağının açısı verir (Kızgın / Üzgün).',
      'Ağzı çoğu sahnede hiç koyma; sadece konuşurken eklemek daha "CB" durur.',
      'Şapkayı topun biraz yan tarafına eğik koymak karaktere kişilik katar.',
    ],
  },
  {
    id: 'cb2', title: 'Orta CB', kind: 'CB', level: 'Orta', ready: false, ratio: [1280, 720], bg: '#EAF4FF',
    summary: 'Yüz ifadeleri, göz kırpma, konuşma balonu ve iki CB\'nin konuşması.', steps: [], tips: [],
  },
  {
    id: 'cb3', title: 'Ayrıntılı CB', kind: 'CB', level: 'Ayrıntılı', ready: false, ratio: [1280, 720], bg: '#EAF4FF',
    summary: 'Gölge ve parlaklık, aksesuarlar, kamera hareketi, çok karakterli sahne.', steps: [], tips: [],
  },
  {
    id: 'g1', title: 'Temel Animasyon', kind: 'Genel', level: 'Temel', ready: true, ratio: [720, 900], bg: '#FFFFFF',
    summary: 'Şekil ekle, ilk keyframe\'lerini koy ve hareket ettir.',
    steps: [
      'Sağ alttaki + butonuna bas, Şekil sekmesinden bir daire ekle.',
      'Daire seçiliyken alttaki "Taşı ve Çevir"e dokun.',
      'Zaman çizelgesi en baştayken (00:00:00) soldaki ◆ butonuna basarak ilk keyframe\'i ekle.',
      'Zaman çizelgesini parmağınla sola kaydırarak 1. saniyeye git.',
      'Daireyi önizlemede sürükle ya da X/Y değerlerini değiştir. İkinci keyframe kendiliğinden oluşur.',
      '▶ ile oynat. Tebrikler, ilk animasyonun hazır!',
    ],
    tips: [
      'İki keyframe arası yumuşak geçiş otomatik; çok fazla keyframe koymana gerek yok.',
      'Hareketin sonunda küçük bir "geri sekme" keyframe\'i eklemek animasyonu canlandırır.',
      'Önce kaba hareketi kur, ince ayarları en sona bırak.',
    ],
  },
  { id: 'g2', title: 'Temel-Orta Animasyon', kind: 'Genel', level: 'Temel-Orta', ready: false, ratio: [720, 900], bg: '#FFFFFF', summary: 'Ölçek, döndürme, opaklık, metin ve yumuşak geçişler.', steps: [], tips: [] },
  { id: 'g3', title: 'Orta Animasyon', kind: 'Genel', level: 'Orta', ready: false, ratio: [720, 900], bg: '#FFFFFF', summary: 'Gruplama, maske, efektler ve katman düzeni.', steps: [], tips: [] },
  { id: 'g4', title: 'Orta-Ayrıntılı Animasyon', kind: 'Genel', level: 'Orta-Ayrıntılı', ready: false, ratio: [720, 900], bg: '#FFFFFF', summary: 'Hareket yolu, easing eğrileri ve geçişler.', steps: [], tips: [] },
  { id: 'g5', title: 'Ayrıntılı Animasyon', kind: 'Genel', level: 'Ayrıntılı', ready: false, ratio: [1280, 720], bg: '#FFFFFF', summary: 'Kamera ve 3B, karmaşık sahneler, dışa aktarma taktikleri.', steps: [], tips: [] },
];
