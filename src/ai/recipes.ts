// Tarif kütüphanesi: yapay zekâ her şeyi sıfırdan kurmak yerine hazır, düzgün çalışan tarifleri çağırır.
// Küçük (internetsiz) model bile kısa bir seçimle güzel video çıkarabilsin diye.
import type { Act } from './actions';

type P = Record<string, unknown>;
const s = (v: unknown, d = '') => (typeof v === 'string' && v.trim() ? v.trim() : d);
const n = (v: unknown, d: number) => (typeof v === 'number' && Number.isFinite(v) ? v : typeof v === 'string' && Number.isFinite(+v) && v.trim() ? +v : d);
const c = (v: unknown, d: string) => (typeof v === 'string' && /^#[0-9a-f]{3,8}$/i.test(v.trim()) ? v.trim() : d);
const arr = (v: unknown): P[] => (Array.isArray(v) ? v.filter((x) => x && typeof x === 'object') as P[] : []);

export interface RecipeInfo { name: string; desc: string; params: string }
export const RECIPES: RecipeInfo[] = [
  { name: 'cb_sohbet', desc: 'iki countryball karşılıklı konuşur (yeni proje açar)', params: '"sol":"ülke","sag":"ülke","replikler":[{"kim":"sol|sag","yazi":"..."}],"arkaplan":"#RRGGBB"' },
  { name: 'ziplayan_top', desc: 'ezilip zıplayan top (yeni proje açar)', params: '"renk":"#RRGGBB","kez":3,"arkaplan":"#RRGGBB"' },
  { name: 'giris_yazisi', desc: 'büyüyerek gelen başlık + alt yazı + dönen yıldızlar (yeni proje açar)', params: '"yazi":"...","alt_yazi":"...","renk":"#RRGGBB","arkaplan":"#RRGGBB"' },
  { name: 'cb_tanitim', desc: 'tek countryball ortada zıplayıp kendini tanıtır (yeni proje açar)', params: '"ulke":"...","yazi":"...","sapka":"Ushanka|Fes|Taç|Kep|Silindir|Miğfer (isteğe bağlı)"' },
  { name: 'zipla', desc: 'var olan katmanı zıplatır', params: '"id":"katman","yukseklik":120,"kez":2,"baslangic":0' },
  { name: 'don', desc: 'katmanı kendi etrafında döndürür', params: '"id":"katman","tur":1,"sure":2,"baslangic":0' },
  { name: 'belir', desc: 'katman yumuşakça belirir', params: '"id":"katman","t":0,"sure":0.5' },
  { name: 'kaybol', desc: 'katman yumuşakça kaybolur', params: '"id":"katman","t":2,"sure":0.5' },
  { name: 'kay', desc: 'katman bir yerden başka yere kayar', params: '"id":"katman","x1":..,"y1":..,"x2":..,"y2":..,"baslangic":0,"sure":1' },
];

/** Tarifi temel işlere çevirir. pos: var olan katmanın o anki konumu (zipla/kay için) */
export function expandRecipe(a: P, pos: (id: string) => { x: number; y: number; end: number } | null): Act[] {
  const name = s(a.name ?? a.tarif);
  const p: P = { ...(typeof a.params === 'object' && a.params ? a.params as P : {}), ...a };
  const out: Act[] = [];
  switch (name) {
    case 'cb_sohbet': {
      const lines = arr(p.replikler).slice(0, 8);
      if (!lines.length) lines.push({ kim: 'sol', yazi: 'Merhaba!' }, { kim: 'sag', yazi: 'Selam!' });
      const per = 2, total = Math.max(3, lines.length * per + 0.5);
      out.push({ do: 'new_project', name: `${s(p.sol, 'Sol')} ve ${s(p.sag, 'Sağ')}`, ratio: '16:9', background: c(p.arkaplan, '#BFE3FF') });
      out.push({ do: 'add_shape', id: 'zemin', shape: 'rect', x: 640, y: 680, w: 1280, h: 120, color: '#6CC46C', end: total });
      out.push({ do: 'add_cb', id: 'sol', flag: s(p.sol, 'Türkiye'), body: 'yumusak-top', x: 360, y: 500, size: 260, end: total });
      out.push({ do: 'add_cb', id: 'sag', flag: s(p.sag, 'Almanya'), body: 'yumusak-top', x: 920, y: 500, size: 260, end: total });
      const bounces: Record<string, { t: number; v: number; ease?: string }[]> = { sol: [{ t: 0, v: 500 }], sag: [{ t: 0, v: 500 }] };
      lines.forEach((l, i) => {
        const who = s(l.kim) === 'sag' ? 'sag' : 'sol', t0 = 0.3 + i * per;
        out.push({ do: 'add_text', id: `yazi${i}`, text: s(l.yazi, '...').slice(0, 60), x: who === 'sol' ? 360 : 920, y: 270, size: 44, color: '#0D1631', start: t0, end: t0 + per - 0.15 });
        bounces[who].push({ t: t0, v: 500 }, { t: t0 + 0.2, v: 470, ease: 'out' }, { t: t0 + 0.4, v: 500, ease: 'in' });
      });
      for (const id of ['sol', 'sag']) out.push({ do: 'animate', id, prop: 'y', keys: bounces[id] });
      out.push({ do: 'play' });
      break;
    }
    case 'ziplayan_top': {
      const k = Math.max(1, Math.min(8, Math.round(n(p.kez, 3)))), T = 0.8, total = k * T + 0.3, top = 300, floor = 700;
      out.push({ do: 'new_project', name: 'Zıplayan Top', ratio: '4:5', background: c(p.arkaplan, '#EAF4FF') });
      out.push({ do: 'add_shape', id: 'golge', shape: 'circle', x: 360, y: floor + 95, w: 200, h: 34, color: '#0D1631', opacity: 0.2, end: total });
      out.push({ do: 'add_shape', id: 'top', shape: 'circle', x: 360, y: top, w: 180, h: 180, color: c(p.renk, '#3B9BFF'), color2: '#22D3C5', end: total });
      const ys: { t: number; v: number; ease?: string }[] = [], sc: { t: number; v: number; ease?: string }[] = [], sh: { t: number; v: number; ease?: string }[] = [];
      for (let i = 0; i < k; i++) {
        const t = i * T;
        ys.push({ t, v: top, ease: 'in' }, { t: t + T / 2, v: floor, ease: 'out' });
        sc.push({ t: t + T / 2 - 0.05, v: 1 }, { t: t + T / 2, v: 0.85, ease: 'out' }, { t: t + T / 2 + 0.08, v: 1 });
        sh.push({ t, v: 0.6, ease: 'in' }, { t: t + T / 2, v: 1.2, ease: 'out' });
      }
      ys.push({ t: k * T, v: top }); sh.push({ t: k * T, v: 0.6 });
      out.push({ do: 'animate', id: 'top', prop: 'y', keys: ys }, { do: 'animate', id: 'top', prop: 'scale', keys: sc }, { do: 'animate', id: 'golge', prop: 'scale', keys: sh });
      out.push({ do: 'play' });
      break;
    }
    case 'giris_yazisi': {
      out.push({ do: 'new_project', name: s(p.yazi, 'Giriş').slice(0, 30), ratio: '16:9', background: c(p.arkaplan, '#0F1834') });
      const col = c(p.renk, '#22D3C5');
      for (let i = 0; i < 4; i++) {
        const x = [200, 1080, 300, 980][i], y = [160, 180, 560, 540][i];
        out.push({ do: 'add_shape', id: `yildiz${i}`, shape: 'star', x, y, w: 70 + i * 10, h: 70 + i * 10, color: i % 2 ? '#3FD0F0' : '#F2C230', end: 4 });
        out.push({ do: 'animate', id: `yildiz${i}`, prop: 'rotation', keys: [{ t: 0, v: 0, ease: 'linear' }, { t: 4, v: i % 2 ? -360 : 360 }] });
        out.push({ do: 'animate', id: `yildiz${i}`, prop: 'scale', keys: [{ t: 0.1 * i, v: 0, ease: 'back' }, { t: 0.1 * i + 0.5, v: 1 }] });
      }
      out.push({ do: 'add_text', id: 'baslik', text: s(p.yazi, 'Hoş geldin!').slice(0, 40), x: 640, y: 330, size: 96, color: col, end: 4 });
      out.push({ do: 'animate', id: 'baslik', prop: 'scale', keys: [{ t: 0, v: 0, ease: 'back' }, { t: 0.6, v: 1 }] });
      if (s(p.alt_yazi)) {
        out.push({ do: 'add_text', id: 'alt', text: s(p.alt_yazi).slice(0, 60), x: 640, y: 440, size: 44, color: '#DCE9FF', start: 0.5, end: 4 });
        out.push({ do: 'animate', id: 'alt', prop: 'opacity', keys: [{ t: 0.5, v: 0, ease: 'out' }, { t: 1.1, v: 1 }] });
      }
      out.push({ do: 'play' });
      break;
    }
    case 'cb_tanitim': {
      out.push({ do: 'new_project', name: `${s(p.ulke, 'CB')} tanıtım`, ratio: '4:5', background: c(p.arkaplan, '#EAF4FF') });
      out.push({ do: 'add_shape', id: 'zemin', shape: 'rect', x: 360, y: 860, w: 720, h: 120, color: '#6CC46C', end: 4 });
      out.push({ do: 'add_cb', id: 'cb', flag: s(p.ulke, 'Türkiye'), body: 'yumusak-top', x: 360, y: 560, size: 340, end: 4 });
      if (s(p.sapka)) out.push({ do: 'add_pack', id: 'sapka', item: s(p.sapka), folder: 'Şapkalar', on: 'cb', end: 4 });
      out.push({ do: 'animate', id: 'cb', prop: 'y', keys: [{ t: 0, v: 560, ease: 'in' }, { t: 0.3, v: 500, ease: 'out' }, { t: 0.6, v: 560, ease: 'in' }, { t: 0.9, v: 520, ease: 'out' }, { t: 1.2, v: 560 }] });
      out.push({ do: 'add_text', id: 'yazi', text: s(p.yazi, `Ben ${s(p.ulke, 'CB')}!`).slice(0, 50), x: 360, y: 230, size: 60, color: '#0D1631', start: 0.4, end: 4 });
      out.push({ do: 'animate', id: 'yazi', prop: 'scale', keys: [{ t: 0.4, v: 0, ease: 'back' }, { t: 0.9, v: 1 }] });
      out.push({ do: 'effect', id: 'cb', type: 'sway', params: { amount: 5 } });
      out.push({ do: 'play' });
      break;
    }
    case 'zipla': {
      const id = s(p.id), at = pos(id);
      if (!at) break;
      const h = n(p.yukseklik, 120), k = Math.max(1, Math.min(10, Math.round(n(p.kez, 2)))), t0 = n(p.baslangic, 0), T = 0.6;
      const keys: { t: number; v: number; ease?: string }[] = [];
      for (let i = 0; i < k; i++) keys.push({ t: t0 + i * T, v: at.y, ease: 'out' }, { t: t0 + i * T + T / 2, v: at.y - h, ease: 'in' });
      keys.push({ t: t0 + k * T, v: at.y });
      out.push({ do: 'animate', id, prop: 'y', keys });
      break;
    }
    case 'don': {
      const t0 = n(p.baslangic, 0), d = Math.max(0.2, n(p.sure, 2));
      out.push({ do: 'animate', id: s(p.id), prop: 'rotation', keys: [{ t: t0, v: 0, ease: 'inout' }, { t: t0 + d, v: 360 * n(p.tur, 1) }] });
      break;
    }
    case 'belir': { const t = n(p.t, 0); out.push({ do: 'animate', id: s(p.id), prop: 'opacity', keys: [{ t, v: 0, ease: 'out' }, { t: t + n(p.sure, 0.5), v: 1 }] }); break; }
    case 'kaybol': { const t = n(p.t, 2); out.push({ do: 'animate', id: s(p.id), prop: 'opacity', keys: [{ t, v: 1, ease: 'in' }, { t: t + n(p.sure, 0.5), v: 0 }] }); break; }
    case 'kay': {
      const id = s(p.id), at = pos(id);
      if (!at) break;
      const t0 = n(p.baslangic, 0), d = Math.max(0.1, n(p.sure, 1));
      out.push({ do: 'animate', id, prop: 'x', keys: [{ t: t0, v: n(p.x1, at.x), ease: 'inout' }, { t: t0 + d, v: n(p.x2, at.x) }] });
      out.push({ do: 'animate', id, prop: 'y', keys: [{ t: t0, v: n(p.y1, at.y), ease: 'inout' }, { t: t0 + d, v: n(p.y2, at.y) }] });
      break;
    }
  }
  return out;
}
