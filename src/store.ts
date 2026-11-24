import { create } from 'zustand';
import type { Layer, Project } from './types';
import { saveProject } from './db';
import { uid } from './anim';

/** Lite'ın neyi ne kadar kısıtlayacağı (Lite ayarları) */
export interface LiteCfg {
  /** Önizleme çözünürlüğü: ekranın tam keskinliğine oranı (0.25..1) */ res: number;
  /** Oynatırken en fazla kare/sn */ fps: number;
  /** Efekt grupları (önizlemede) */
  /** Bulanıklık (Gauss + hareket bulanıklığı): 0 kapalı, 1 düşük, 2 orta, 3 tam */ blur: number;
  /** Bükme (fraktal bükme): 0 kapalı, 1 düşük, 2 tam */ warp: number;
  /** Işık ve gölge (parlama, gölge): 0 kapalı, 1 açık */ light: number;
  /** Renk ve ışık (parlaklık, kontrast, ton…): 0 kapalı, 1 açık */ color: number;
  /** İçe aktarılan görsellerin en uzun kenarı (px) */ media: number;
}
export const LITE_DEFAULT: LiteCfg = { res: 0.4, fps: 30, blur: 1, warp: 1, light: 1, color: 1, media: 1280 };
export const FULL_QUALITY: LiteCfg = { res: 1, fps: 60, blur: 3, warp: 2, light: 1, color: 1, media: 2048 };
/** O anki geçerli performans ayarı: Lite kapalıyken tam kalite */
export const perfOf = (s: Settings): LiteCfg => (s.lite ? { ...LITE_DEFAULT, ...s.liteCfg } : FULL_QUALITY);

export interface Settings {
  /** Lite ayarları (çubuklarla) */
  liteCfg?: Partial<LiteCfg>;
  /** Warden Motion Lite: zayıf cihazlar için hafif mod */
  lite: boolean;
  /** 'auto' = uygulama karar verdi, 'user' = kullanıcı ayarladı */
  liteSource: 'auto' | 'user';
  defaultDuration: number;
}

/** Zayıf cihaz tahmini: hafıza, çekirdek sayısı ve kısa bir çizim testi. */
export function detectWeakDevice(): boolean {
  const nav = navigator as Navigator & { deviceMemory?: number };
  if (nav.deviceMemory !== undefined && nav.deviceMemory <= 3) return true;
  if ((nav.hardwareConcurrency || 8) <= 4) return true;
  try {
    const c = document.createElement('canvas');
    c.width = 720; c.height = 900;
    const x = c.getContext('2d')!;
    const t0 = performance.now();
    for (let i = 0; i < 300; i++) {
      x.save(); x.translate(360, 450); x.rotate(i); x.globalAlpha = 0.5;
      x.fillStyle = i % 2 ? '#2F7BF6' : '#22D3C5'; x.fillRect(-200, -120, 400, 240); x.restore();
    }
    x.getImageData(0, 0, 1, 1);
    return performance.now() - t0 > 40;
  } catch { return false; }
}

const loadSettings = (): Settings => {
  let saved: Partial<Settings> = {};
  try { saved = JSON.parse(localStorage.getItem('wm-settings') || '{}'); } catch { /* yok */ }
  const base: Settings = { lite: false, liteSource: 'auto', defaultDuration: 2, ...saved };
  // Kullanıcı kendisi seçmediyse her açılışta cihaza göre karar ver
  if (base.liteSource !== 'user') base.lite = detectWeakDevice();
  return base;
};

type Screen = 'home' | 'editor' | 'tutorials' | 'account';

interface State {
  screen: Screen;
  settings: Settings;
  project: Project | null;
  past: Project[];
  future: Project[];
  selectedId: string | null;
  /** Çoklu seçim modu (uzun basınca); null = kapalı */
  multi: string[] | null;
  /** Efekt panelinde seçili parametre (önizlemede kaydırarak ayarlanır) */
  fxParam: { fx: string; key: string } | null;
  /** Açık panelin işi: bu grupların işaretleyicileri tam opak, diğerleri soluk (null = hepsi opak) */
  kfFocus: string[] | null;
  setKfFocus: (g: string[] | null) => void;
  setFxParam: (p: { fx: string; key: string } | null) => void;
  setMulti: (ids: string[] | null) => void;
  time: number;
  playing: boolean;
  tutorialStep: number;
  /** Ana sayfadaki ⋯ → Dışa Aktar: proje açılınca dışa aktarma penceresi açılsın */
  autoExport: boolean;
  go: (s: Screen) => void;
  setSettings: (s: Partial<Settings>) => void;
  open: (p: Project) => void;
  close: () => void;
  /** Projeyi değiştirir; commit=false sürükleme sırasında geçmişe yazmaz. */
  update: (fn: (p: Project) => Project, commit?: boolean) => void;
  checkpoint: () => void;
  updateLayer: (id: string, fn: (l: Layer) => Layer, commit?: boolean) => void;
  addLayer: (l: Omit<Layer, 'id'>) => void;
  removeLayer: (id: string) => void;
  duplicateLayer: (id: string) => void;
  undo: () => void;
  redo: () => void;
  select: (id: string | null) => void;
  setTime: (t: number) => void;
  setPlaying: (b: boolean) => void;
  setTutorialStep: (n: number) => void;
}

let saveTimer: ReturnType<typeof setTimeout> | undefined;
const scheduleSave = (p: Project) => {
  clearTimeout(saveTimer);
  saveTimer = setTimeout(() => saveProject(p), 400);
};

export const useStore = create<State>((set, get) => ({
  screen: 'home',
  settings: loadSettings(),
  project: null,
  past: [],
  future: [],
  selectedId: null,
  multi: null,
  fxParam: null,
  kfFocus: null,
  setKfFocus: (kfFocus) => set({ kfFocus }),
  setFxParam: (fxParam) => set({ fxParam }),
  setMulti: (multi) => set({ multi, selectedId: null }),
  time: 0,
  playing: false,
  tutorialStep: 0,
  autoExport: false,
  go: (screen) => set({ screen }),
  setSettings: (s) => {
    const settings = { ...get().settings, ...s };
    localStorage.setItem('wm-settings', JSON.stringify(settings));
    set({ settings });
  },
  open: (project) => set({ project, past: [], future: [], selectedId: null, multi: null, time: 0, playing: false, tutorialStep: 0, screen: 'editor' }),
  close: () => {
    const p = get().project;
    if (p) saveProject(p);
    set({ project: null, screen: 'home', playing: false });
  },
  update: (fn, commit = true) => {
    const cur = get().project;
    if (!cur) return;
    const next = { ...fn(cur), updatedAt: Date.now() };
    set(commit ? { project: next, past: [...get().past.slice(-49), cur], future: [] } : { project: next });
    scheduleSave(next);
  },
  // Sürükleme başlarken çağrılır: mevcut hali geri alma geçmişine yazar.
  checkpoint: () => {
    const cur = get().project;
    if (cur) set({ past: [...get().past.slice(-49), cur], future: [] });
  },
  updateLayer: (id, fn, commit = true) =>
    get().update((p) => ({ ...p, layers: p.layers.map((l) => (l.id === id ? fn(l) : l)) }), commit),
  addLayer: (l) => {
    const id = uid();
    get().update((p) => ({ ...p, layers: [...p.layers, { ...l, id }] }));
    set({ selectedId: id });
  },
  removeLayer: (id) => {
    get().update((p) => ({ ...p, layers: p.layers.filter((l) => l.id !== id) }));
    set({ selectedId: null });
  },
  duplicateLayer: (id) => {
    const l = get().project?.layers.find((x) => x.id === id);
    if (!l) return;
    const copy = { ...structuredClone(l), id: uid(), name: l.name + ' Kopya' };
    copy.x = { ...copy.x, v: copy.x.v + 30, k: copy.x.k?.map((k) => ({ ...k, v: k.v + 30 })) };
    get().update((p) => ({ ...p, layers: [...p.layers, copy] }));
    set({ selectedId: copy.id });
  },
  undo: () => {
    const { past, project, future } = get();
    if (!past.length || !project) return;
    const prev = past[past.length - 1];
    set({ project: prev, past: past.slice(0, -1), future: [project, ...future] });
    scheduleSave(prev);
  },
  redo: () => {
    const { past, project, future } = get();
    if (!future.length || !project) return;
    const next = future[0];
    set({ project: next, past: [...past, project], future: future.slice(1) });
    scheduleSave(next);
  },
  select: (selectedId) => set({ selectedId }),
  setTime: (time) => set({ time: Math.max(0, time) }),
  setPlaying: (playing) => set({ playing }),
  setTutorialStep: (tutorialStep) => set({ tutorialStep }),
}));
