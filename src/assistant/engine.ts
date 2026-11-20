// WardenCB asistanı: ekranı (DOM + uygulama durumu) canlı okur, kullanıcının basması gereken GERÇEK öğeyi bulur.
// Kullanıcı yanlış yere girdiyse önce oradan çıkış yolunu gösterir (route), sonra adıma devam eder.
import { create } from 'zustand';
import type { Mood } from '../components/WardenCB';
import type { Layer } from '../types';
import { useStore } from '../store';

export const APP_VERSION = '0.9';

// ---------------------------------------------------------------------------------------------
// Ekran okuma
// ---------------------------------------------------------------------------------------------
const q = (sel: string) => document.querySelector(sel) as HTMLElement | null;
const visible = (el: Element | null): el is HTMLElement => {
  if (!el) return false;
  const r = (el as HTMLElement).getBoundingClientRect();
  return r.width > 0 && r.height > 0;
};
/** Seçici + (isteğe bağlı) içinde geçen yazı ile görünür ilk öğe */
export function find(sel: string, text?: string): HTMLElement | null {
  const all = [...document.querySelectorAll(sel)] as HTMLElement[];
  for (const el of all) {
    if (!visible(el)) continue;
    if (text && !(el.textContent ?? '').toLocaleLowerCase('tr').includes(text.toLocaleLowerCase('tr')) && el.getAttribute('aria-label') !== text) continue;
    return el;
  }
  return null;
}
const label = (l: string) => find(`[aria-label="${l}"]`);

export interface UI {
  screen: 'home' | 'tutorials' | 'editor';
  sel: Layer | null;
  multi: boolean;
  /** açık editör paneli (başlığı), 'add' = Katman ekle kartı */
  panel: string | null;
  addTab: string | null;
  fxb: boolean;
  choice: boolean;
  menu: boolean;
  sheet: boolean;
  drawer: boolean;
}
export function readUI(): UI {
  const st = useStore.getState();
  const sel = st.project?.layers.find((l) => l.id === st.selectedId) ?? null;
  const add = q('.addcard');
  const dp = q('.dpanel[role="dialog"]');
  return {
    screen: st.screen === 'editor' && st.project ? 'editor' : st.screen === 'tutorials' ? 'tutorials' : 'home',
    sel, multi: !!st.multi,
    panel: add ? 'add' : dp?.getAttribute('aria-label') ?? null,
    addTab: add?.querySelector('[role="tab"][aria-selected="true"]')?.textContent?.trim() ?? null,
    fxb: !!q('.fxb'), choice: !!q('.choice'), menu: !!q('.menu'), sheet: !!q('.sheet'), drawer: !!q('.drawer'),
  };
}

// ---------------------------------------------------------------------------------------------
// Hedef durum ve yol bulma
// ---------------------------------------------------------------------------------------------
export interface Goal {
  screen?: 'home' | 'tutorials' | 'editor';
  /** öğretici projesi açık olmalı */
  tutorial?: string;
  /** editörde hiçbir şey açık/seçili değil */
  clean?: boolean;
  /** Katman ekle kartı bu sekmede açık */
  add?: string;
  /** Bu katman seçili olmalı */
  sel?: (l: Layer) => boolean;
  selName?: string;
  /** Seçili katmanda bu panel açık */
  panel?: string;
  fxb?: boolean;
  /** Seçim penceresine (choice) izin ver / iste: içinde bu yazılı düğme olmalı */
  choice?: string;
  time0?: boolean;
  /** seçili katmanda hiçbir panel açık olmamalı */
  noPanel?: boolean;
}
export interface Hint { el: HTMLElement | null; say: string; mood: Mood; recover?: boolean }

const H = (el: HTMLElement | null, say: string, mood: Mood = 'point', recover = true): Hint => ({ el, say, mood, recover });

/** Editörde açık olan her şeyi kapatma yolu (en üstteki önce) */
function closeTop(u: UI, keep: Goal = {}): Hint | null {
  if (u.choice && !keep.choice) {
    const b = find('.choice button', 'Vazgeç') ?? find('.choice .btn');
    return H(b, 'Önce bu pencereyi kapatalım: "Vazgeç"e dokun.', 'think');
  }
  if (u.fxb && !keep.fxb) return H(find('.fxb-top .ib'), 'Efekt tarayıcısından çıkalım: soldaki düğmeye dokun.', 'think');
  if (u.menu) return H(u.sel ? label('Diğer') : label('Proje ayarları'), 'Açık menüyü kapatmak için aynı düğmeye tekrar dokun.', 'think');
  if (u.multi) return H(label('Seçimi bitir'), 'Çoklu seçimdesin. Önce çoklu seçimi bitir.', 'think');
  return null;
}

export function route(g: Goal): Hint | null {
  const u = readUI();
  const st = useStore.getState();
  const needEditor = g.screen === 'editor' || g.tutorial || g.clean || g.add || g.sel || g.panel || g.fxb || g.time0;
  // ---- Ana ekran tarafı ----
  if (u.screen !== 'editor') {
    if (u.drawer) return H(find('.drawer'), 'Ayarlar menüsü açık. Menünün dışına (sağdaki boşluğa) dokunup kapat.', 'think');
    if (u.sheet && !(g.screen === 'home' && !needEditor)) return H(find('.sheet [aria-label="Kapat"]'), 'Yeni proje penceresini kapatalım.', 'think');
    if (g.screen === 'tutorials' && u.screen !== 'tutorials') return H(find('.nav button', 'Öğreticiler'), 'Alttaki "Öğreticiler"e dokun.', 'point', false);
    if (g.screen === 'home' && u.screen !== 'home') return H(find('.nav button', 'Ana Sayfa'), 'Ana sayfaya dön: alttaki "Ana Sayfa"ya dokun.', 'point');
    if (needEditor) {
      if (g.tutorial) {
        const pid = useAssistant.getState().run?.pid;
        if (u.screen === 'tutorials') return H(find('.nav button', 'Ana Sayfa'), 'Öğretici projen ana sayfada duruyor. "Ana Sayfa"ya dokun.', 'point');
        const card = pid ? find(`.pcard[data-pid="${pid}"]`) : null;
        if (card) return H(card, 'Öğreticiden çıktın. Devam etmek için projeye geri dön: buraya dokun.', 'worried');
        return H(null, 'Öğretici projesi bulunamadı. Öğreticiler\'den yeniden başlatabilirsin.', 'sad');
      }
      return H(find('.new-card'), 'Önce bir proje açalım.', 'point', false);
    }
    return null;
  }
  // ---- Editör ----
  if (g.screen === 'home' || g.screen === 'tutorials') {
    const c = closeTop(u);
    if (c) return c;
    if (u.panel && u.panel !== 'add') return H(label('Geri'), 'Bu panelden çıkalım: sol üstteki geri okuna dokun.', 'think');
    if (u.panel === 'add') return H(find('.addcard [aria-label="Kapat"]'), 'Ekleme kartını kapat.', 'think');
    if (u.sel) return H(label('Seçimi kaldır'), 'Önce katmanın seçimini kaldır: sol üstteki ok.', 'think');
    return H(label('Projeden çık'), 'Projeden çıkalım: sol üstteki çıkış düğmesi.', 'point');
  }
  if (g.tutorial && st.project?.tutorial !== g.tutorial) return H(label('Projeden çık') ?? label('Seçimi kaldır') ?? label('Geri'), 'Başka bir projedesin. Öğreticiye dönmek için önce buradan çık.', 'worried');
  const c = closeTop(u, g);
  if (c) return c;
  if (g.add) {
    if (u.panel === 'add') {
      if (u.addTab !== g.add) return H(find('.addcard [role="tab"]', g.add), `Üstten "${g.add}" sekmesine dokun.`, 'point', false);
      return null;
    }
    if (u.panel) return H(label('Geri'), 'Önce bu panelden çık.', 'think');
    if (u.sel) return H(label('Seçimi kaldır'), 'Önce seçimi kaldır (sol üstteki ok), sonra + ile ekleriz.', 'point', false);
    return H(find('.fab-d'), 'Sağ alttaki + düğmesine dokun.', 'point', false);
  }
  if (g.clean) {
    if (u.panel === 'add') return H(find('.addcard [aria-label="Kapat"]'), 'Ekleme kartını kapat.', 'think');
    if (u.panel) return H(label('Geri'), 'Önce bu panelden çık.', 'think');
    if (u.sel) return H(label('Seçimi kaldır'), 'Önce katmanın seçimini kaldır: sol üstteki ok.', 'think');
  }
  if (g.sel) {
    const ok = u.sel && g.sel(u.sel);
    if (!ok) {
      if (u.panel === 'add') return H(find('.addcard [aria-label="Kapat"]'), 'Ekleme kartını kapat.', 'think');
      if (u.sel && u.panel) return H(label('Geri'), 'Yanlış katmandasın. Önce panelden çık.', 'think');
      if (u.sel) return H(label('Seçimi kaldır'), `Şu an "${u.sel.name}" seçili. Önce seçimi kaldır (sol üstteki ok).`, 'point', false);
      const l = [...(st.project?.layers ?? [])].reverse().find(g.sel);
      if (!l) return H(label('Geri al'), 'Gereken katman silinmiş gibi. Geri al ile geri getir.', 'worried');
      const el = find(`.lpill[data-lid="${l.id}"]`) ?? find(`.track[data-lid="${l.id}"]`);
      return H(el, `"${g.selName ?? l.name}" katmanını seç: buna dokun.`, 'point', false);
    }
  }
  if (g.panel) {
    if (u.panel !== g.panel) {
      if (u.panel === 'add') return H(find('.addcard [aria-label="Kapat"]'), 'Ekleme kartını kapat.', 'think');
      if (u.panel) return H(label('Geri'), `Burası "${u.panel}". Geri çıkıp "${g.panel}"ı açalım.`, 'think');
      return H(find('.tbig', g.panel), `Alttan "${g.panel}"a dokun.`, 'point', false);
    }
  }
  if (g.noPanel && u.panel) {
    if (u.panel === 'add') return H(find('.addcard [aria-label="Kapat"]'), 'Ekleme kartını kapat.', 'think');
    return H(label('Geri'), `Yanlış yere girdin: burası "${u.panel}". Önce sol üstteki geri okuyla çık.`, 'worried');
  }
  if (g.fxb && !u.fxb) return H(find('.addfx'), '"Efekt Ekle"ye dokun.', 'point', false);
  if (g.time0 && Math.round(st.time * 1000) !== 0) return H(label('Başa git'), 'Önce zamanı en başa al: bu düğme.', 'point', false);
  if (g.choice && !u.choice) return null; // adımın kendisi seçimi açtıracak
  return null;
}

// ---------------------------------------------------------------------------------------------
// Senaryolar
// ---------------------------------------------------------------------------------------------
export interface Step {
  say: string;
  mood?: Mood;
  need?: Goal;
  /** gösterilecek gerçek öğe */
  target?: () => HTMLElement | null;
  /** tamamlandı mı (verilmezse "İleri" düğmesi çıkar) */
  done?: () => boolean;
  /** "İleri" düğmesinin yazısı */
  btn?: string;
}
export interface Script { id: string; title: string; steps: Step[]; pid?: string }

const proj = () => useStore.getState().project;
const layers = () => proj()?.layers ?? [];
const isCircle = (l: Layer) => l.type === 'shape' && l.shape === 'circle';
const isCBLine = (l: Layer) => !l.parent && /govdeler\/.*-cizgi/.test(l.src ?? '');

const INTRO: Step[] = [
  { say: 'Selam! Ben WardenCB, Warden Motion\'ın asistanıyım. Sana uygulamayı gezdireceğim; öğreticilerde de nereye basacağını ben göstereceğim.', mood: 'wave', need: { screen: 'home' } },
  { say: 'Yeni bir proje buradan açılır: oranı, çözünürlüğü ve kare hızını seçersin.', target: () => find('.new-card'), need: { screen: 'home' } },
  { say: 'Hazır şablonlar burada. Birine dokun, açılsın, istediğin gibi değiştir.', target: () => find('.tpl-row'), need: { screen: 'home' } },
  { say: 'Projelerin burada saklanır, hepsi bu cihazda kalır.', target: () => find('.plist .pcard') ?? find('.empty'), need: { screen: 'home' } },
  { say: 'Adım adım öğreticiler burada: 3 CB, 5 genel animasyon. Onlarda da ben yanındayım.', target: () => find('.nav button', 'Öğreticiler'), need: { screen: 'home' } },
  { say: 'Ayarlar burada: zayıf telefonlar için Lite modu ve beni tekrar çağırmak için "WardenCB ile tanış".', target: () => label('Ayarlar menüsü'), need: { screen: 'home' } },
];
const INTRO_END: Step = { say: 'Hepsi bu kadar! Editöre ilk girdiğinde orayı da gezdireceğim. İyi animasyonlar!', mood: 'joy', btn: 'Bitir' };

/** Her güncellemede "yeni neler var" (en yeni en sonda) */
export const WHATS_NEW: { v: string; items: Step[] }[] = [
  {
    v: '0.9', items: [
      { say: 'Bu güncellemede yeni olan benim: WardenCB! Artık öğreticilerde ekranında nereye basacağını gösteriyorum, yanlış yere girersen çıkış yolunu da.', mood: 'proud' },
      { say: 'CB Araçları\'nda yeni "Pozlar" klasörü: 30 duygu, 30 poz. Projeye bütün gibi gelir ama iç, çizgi, göz ve ushanka ayrı katmanlardır.', mood: 'excited' },
      { say: 'Gövdeler\'e "Basık top", Gözler\'e beyaz göz seti, Şapkalar\'a ushanka (arka kulağı CB\'nin arkasına kendisi geçer) geldi. Bayraklar\'da da benim bayrağım var: "Basık CB olarak ekle" ile beni kurabilirsin.', mood: 'happy' },
    ],
  },
];

const EDITOR_TOUR: Step[] = [
  { say: 'Burası editör! Önizlemede katmanları parmağınla sürükle; iki parmakla büyüt ve döndür.', mood: 'wave', target: () => find('.stage canvas'), need: { screen: 'editor' } },
  { say: 'Oynat / duraklat. Yanındakiler başa ve sona gider.', target: () => label('Oynat') ?? label('Duraklat'), need: { screen: 'editor' } },
  { say: 'Zaman çizelgesi: kaydırınca kare kare ilerler, iki parmakla yakınlaştırırsın. Ortadaki çizgi o anki kare.', target: () => find('.tl'), need: { screen: 'editor' } },
  { say: 'Katman eklemek için +: şekil, medya, metin, CB araçları ve bayraklar.', target: () => find('.fab-d'), need: { clean: true } },
  { say: 'Bir katmanı seçince altta araçlar çıkar: Taşı ve Çevir, Efektler… ◆+ ile keyframe eklersin, ◆− ile silersin.', mood: 'think', target: () => find('.lpill') ?? find('.tl'), need: { screen: 'editor' } },
  { say: 'Bitince videonu buradan dışa aktar. Hadi, sıra sende!', mood: 'joy', target: () => label('Dışa aktar'), need: { clean: true }, btn: 'Bitir' },
];

const tips = (t: string[]): Step[] => t.map((say, i) => ({ say: `Taktik ${i + 1}: ${say}`, mood: 'smug' as Mood }));

const TUT_G1 = (): Step[] => [
  { say: 'Temel Animasyon\'a hoş geldin! Önce bir daire ekleyelim: "Daire"ye dokun.', mood: 'wave', need: { tutorial: 'g1', add: 'Şekil' }, target: () => find('.addcard .cell[aria-label="Daire"]'), done: () => layers().some(isCircle) },
  { say: 'Daire geldi! Şimdi alttan "Taşı ve Çevir"e dokun.', need: { tutorial: 'g1', sel: isCircle, selName: 'Daire', noPanel: true }, target: () => find('.tbig', 'Taşı ve Çevir'), done: () => readUI().panel === 'Taşı ve Çevir' },
  { say: 'Zaman en başta. Elmas + düğmesine bas: ilk keyframe buraya konur.', need: { tutorial: 'g1', sel: isCircle, selName: 'Daire', panel: 'Taşı ve Çevir', time0: true }, target: () => label('Bu ana keyframe ekle'), done: () => layers().some((l) => isCircle(l) && !!l.x.k?.length) },
  { say: 'Şimdi zaman çizelgesini parmağınla sola kaydır ve yaklaşık 1. saniyeye git.', need: { tutorial: 'g1', sel: isCircle, selName: 'Daire', panel: 'Taşı ve Çevir' }, target: () => find('.tl'), done: () => useStore.getState().time >= 0.5 },
  { say: 'Daireyi önizlemede başka bir yere sürükle. İkinci keyframe kendiliğinden oluşur.', mood: 'excited', need: { tutorial: 'g1', sel: isCircle, selName: 'Daire', panel: 'Taşı ve Çevir' }, target: () => find('.stage canvas'), done: () => layers().some((l) => isCircle(l) && ((l.x.k?.length ?? 0) >= 2 || (l.y.k?.length ?? 0) >= 2)) },
  { say: 'Süper! Şimdi ▶ ile oynat ve izle.', need: { tutorial: 'g1' }, target: () => label('Oynat'), done: () => useStore.getState().playing },
  { say: 'Tebrikler, ilk animasyonun hazır!', mood: 'proud' },
];

const TUT_CB1 = (): Step[] => [
  { say: 'Temel CB\'ye hoş geldin! İlk countryball\'unu yapacağız. Bayrak sekmesinden bir ülke seç.', mood: 'wave', need: { tutorial: 'cb1', add: 'Bayrak' }, target: () => find('.flag-scroll'), done: () => !!find('.choice button', 'Yumuşak CB olarak ekle') || layers().some(isCBLine) },
  { say: '"Yumuşak CB olarak ekle"ye dokun: çizgi, beyaz iç, içe kırpılmış bayrak ve gözler kurulur.', need: { tutorial: 'cb1', add: 'Bayrak', choice: 'Yumuşak' }, target: () => find('.choice button', 'Yumuşak CB olarak ekle') ?? find('.flag-scroll'), done: () => layers().some(isCBLine) },
  { say: 'CB hazır! Çizgi katmanı seçili: onu taşıyınca hepsi birlikte gider. Önizlemede biraz sürükleyip dene.', mood: 'happy', target: () => find('.stage canvas') },
  { say: 'Şimdi şapka: CB sekmesinde "Şapkalar" klasörüne dokun.', need: { tutorial: 'cb1', add: 'CB' }, target: () => find('.addcard .chip', 'Şapkalar'), done: () => !!find('.addcard .chip.on', 'Şapkalar') || layers().some((l) => /ushanka/i.test(l.src ?? '') || /sapkalar/.test(l.src ?? '')) },
  { say: 'İstediğin şapkayı seç. Ushanka seçersen arka kulağı CB\'nin arkasına kendisi geçer.', need: { tutorial: 'cb1', add: 'CB' }, target: () => find('.addcard .pager'), done: () => layers().some((l) => /sapkalar/.test(l.src ?? '')) },
  { say: 'Şapkayı önizlemede CB\'nin başına sürükle. Boyut için Taşı ve Çevir → Ölçek.', target: () => find('.stage canvas') },
  { say: 'Biraz hareket katalım: CB\'nin çizgisi seçiliyken alttan "Efektler"e dokun.', need: { tutorial: 'cb1', sel: isCBLine, selName: 'CB Çizgi', noPanel: true }, target: () => find('.tbig', 'Efektler'), done: () => readUI().panel === 'Efektler' },
  { say: '"Efekt Ekle"ye dokun.', need: { tutorial: 'cb1', sel: isCBLine, selName: 'CB Çizgi', panel: 'Efektler' }, target: () => find('.addfx'), done: () => readUI().fxb || layers().some((l) => isCBLine(l) && l.effects.some((e) => e.type === 'sway')) },
  { say: '"Oto-Sallanma"yı seç: CB hafifçe sağa sola sallanır.', need: { tutorial: 'cb1', sel: isCBLine, selName: 'CB Çizgi', panel: 'Efektler', fxb: true }, target: () => find('.fxb-grid button', 'Oto-Sallanma'), done: () => layers().some((l) => isCBLine(l) && l.effects.some((e) => e.type === 'sway')) },
  { say: 'Şimdi ▶ ile oynat!', need: { tutorial: 'cb1' }, target: () => label('Oynat'), done: () => useStore.getState().playing },
  { say: 'Harika! Beğendiysen sağ üstteki düğmeyle videonu dışa aktar.', mood: 'proud', need: { tutorial: 'cb1', clean: true }, target: () => label('Dışa aktar') },
];

export function buildScript(id: string, opts: { existing?: boolean; from?: string; pid?: string; tips?: string[] } = {}): Script | null {
  if (id === 'intro') {
    const news = opts.existing ? WHATS_NEW.filter((w) => !opts.from || w.v > opts.from).flatMap((w) => w.items) : [];
    return { id, title: 'Tanışma', steps: [...INTRO, ...news, INTRO_END] };
  }
  if (id === 'whatsnew') {
    const news = WHATS_NEW.filter((w) => !opts.from || w.v > opts.from).flatMap((w) => w.items);
    return news.length ? { id, title: 'Yeni neler var', steps: [{ say: 'Selam! Uygulama güncellendi, yenilikleri anlatayım.', mood: 'wave' }, ...news, { say: 'Bu kadar, iyi eğlenceler!', mood: 'happy', btn: 'Bitir' }] } : null;
  }
  if (id === 'editor') return { id, title: 'Editör turu', steps: EDITOR_TOUR };
  if (id === 'tut:g1') return { id, pid: opts.pid, title: 'Temel Animasyon', steps: [...TUT_G1(), ...tips(opts.tips ?? []), { say: 'Öğretici bitti. Kendi animasyonunu yapmaya hazırsın!', mood: 'joy', btn: 'Bitir' }] };
  if (id === 'tut:cb1') return { id, pid: opts.pid, title: 'Temel CB', steps: [...TUT_CB1(), ...tips(opts.tips ?? []), { say: 'Öğretici bitti. Artık kendi CB\'lerini yapabilirsin!', mood: 'joy', btn: 'Bitir' }] };
  return null;
}

// ---------------------------------------------------------------------------------------------
// Kalıcı durum + çalışma durumu
// ---------------------------------------------------------------------------------------------
interface Saved { intro?: boolean; ver?: string; editor?: boolean; tut?: Record<string, number> }
const KEY = 'wm-assist';
export const loadSaved = (): Saved => { try { return JSON.parse(localStorage.getItem(KEY) || '{}'); } catch { return {}; } };
export const saveSaved = (s: Saved) => { try { localStorage.setItem(KEY, JSON.stringify(s)); } catch { /* yok */ } };
/** Asistan gelmeden önce uygulamayı kullanmış mı (bu güncellemede hem tanışma hem yenilikler gösterilir) */
export const WAS_EXISTING = (() => { try { return Object.keys(localStorage).some((k) => k.startsWith('wm-') && k !== KEY); } catch { return false; } })();

interface Run { script: Script; step: number; pid?: string }
interface AState {
  run: Run | null;
  min: boolean;
  start: (s: Script, step?: number) => void;
  go: (step: number) => void;
  stop: (finished?: boolean) => void;
  setMin: (b: boolean) => void;
}
export const useAssistant = create<AState>((set, get) => ({
  run: null,
  min: false,
  start: (script, step = 0) => set({ run: { script, step: Math.min(step, script.steps.length - 1), pid: script.pid }, min: false }),
  go: (step) => {
    const r = get().run;
    if (!r) return;
    if (step >= r.script.steps.length) { get().stop(true); return; }
    if (r.pid) { const s = loadSaved(); saveSaved({ ...s, tut: { ...s.tut, [r.pid]: step } }); }
    set({ run: { ...r, step: Math.max(0, step) } });
  },
  stop: (finished = false) => {
    const r = get().run;
    if (r) {
      const s = loadSaved();
      if (r.script.id === 'intro') { s.intro = true; s.ver = APP_VERSION; }
      if (r.script.id === 'whatsnew') s.ver = APP_VERSION;
      if (r.script.id === 'editor') s.editor = true;
      if (r.pid) s.tut = { ...s.tut, [r.pid]: finished ? 999 : r.step };
      saveSaved(s);
    }
    set({ run: null, min: false });
  },
  setMin: (min) => set({ min }),
}));
