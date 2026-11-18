import { useCallback, useEffect, useLayoutEffect, useRef, useState } from 'react';
import { Icon } from '../components/Icon';
import { AddPanel, type AddTab, ColorPanel, CBPanel, EffectsPanel, MovePanel, OpacityPanel, TextPanel } from '../components/Panels';
import { fmtTime, layerKeyTimes, projectDuration, setAnim, valueAt } from '../anim';
import { exportVideo, saveFile } from '../export';
import { TUTORIALS } from '../factories';
import { hitTest, parentWorld, pauseAllVideos, renderFrame, setImageLoadedHandler, toLocal, worldTransform, type TR } from '../render';
import { useStore } from '../store';
import type { Project } from '../types';

export type Panel = null | 'add' | 'move' | 'color' | 'opacity' | 'effects' | 'cb' | 'text';
const PANEL_TITLE: Record<string, string> = { move: 'Taşı ve Çevir', color: 'Renk ve Dolgu', opacity: 'Karıştırma ve Opaklık', effects: 'Efektler', text: 'Metni Düzenle', cb: 'CB Ayarları' };

const PPS = 100; // zaman çizelgesi: saniye başına piksel
const TOP = 44, ROW = 26; // katman şeritlerinin başladığı yer ve satır aralığı

export function useWide() {
  const q = '(min-width: 900px)';
  const [w, setW] = useState(() => matchMedia(q).matches);
  useEffect(() => {
    const m = matchMedia(q);
    const fn = () => setW(m.matches);
    m.addEventListener('change', fn);
    return () => m.removeEventListener('change', fn);
  }, []);
  return w;
}

export function Editor() {
  const s = useStore();
  const p = s.project as Project;
  const wide = useWide();
  const sel = p.layers.find((l) => l.id === s.selectedId) ?? null;
  const dur = projectDuration(p);
  const [panel, setPanel] = useState<Panel>(null);
  const [addTab, setAddTab] = useState<AddTab | null>(null);
  const [loop, setLoop] = useState(true);
  const [replaceFlagOf, setReplaceFlagOf] = useState<string | null>(null);
  const [menu, setMenu] = useState(false);
  const [pick, setPick] = useState<null | 'parent' | 'mask'>(null);
  const [projMenu, setProjMenu] = useState(false);
  const [toast, setToast] = useState('');
  const [exporting, setExporting] = useState<number | null>(null);
  const [, force] = useState(0);
  const show = (m: string) => { setToast(m); setTimeout(() => setToast(''), 2600); };

  useEffect(() => setImageLoadedHandler(() => force((x) => x + 1)), []);

  // ---------- Önizleme ----------
  const stageRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [box, setBox] = useState({ w: 300, h: 300 });
  useLayoutEffect(() => {
    const el = stageRef.current!;
    const ro = new ResizeObserver(() => setBox({ w: el.clientWidth, h: el.clientHeight }));
    ro.observe(el);
    return () => ro.disconnect();
  }, []);
  const fit = Math.min(box.w / p.width, box.h / p.height);
  const dispW = Math.max(10, Math.floor(p.width * fit)), dispH = Math.max(10, Math.floor(p.height * fit));
  const lite = s.settings.lite;
  const dpr = lite ? Math.min(1, window.devicePixelRatio || 1) * 0.75 : Math.min(2, window.devicePixelRatio || 1);
  // Oynatma sırasında zaman React'e her karede yazılmaz; bu ref'te tutulur (kasmayı önler)
  const timeRef = useRef(s.time);
  if (!s.playing) timeRef.current = s.time;
  const timecodeRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const c = canvasRef.current;
    if (!c) return;
    const W = Math.round(dispW * dpr), H = Math.round(dispH * dpr);
    if (c.width !== W || c.height !== H) { c.width = W; c.height = H; }
    renderFrame(c.getContext('2d')!, p, timeRef.current, { selectedId: s.playing ? null : s.selectedId, quality: c.width / p.width, fast: s.playing && lite, gradHandles: panel === 'color', motionPath: panel === 'move' });
  });

  const loopRef = useRef(loop);
  loopRef.current = loop;
  // ---------- Oynatma ----------
  // Tuval, zaman çizelgesi ve zaman göstergesi doğrudan güncellenir; editörün geri kalanı yeniden çizilmez.
  useEffect(() => {
    if (!s.playing) return;
    let raf = 0, last = performance.now();
    const tick = (now: number) => {
      const st = { ...useStore.getState(), loopOn: loopRef.current };
      const pr = st.project!;
      const d = projectDuration(pr);
      let t = timeRef.current + (now - last) / 1000;
      last = now;
      if (t >= d) { if (st.loopOn) t = 0; else { timeRef.current = d; st.setPlaying(false); return; } }
      timeRef.current = t;
      const c = canvasRef.current;
      if (c) renderFrame(c.getContext('2d')!, pr, t, { quality: c.width / pr.width, fast: st.settings.lite, playing: true });
      const el = tlRef.current;
      if (el) { programmatic.current = true; el.scrollLeft = t * PPS; }
      if (timecodeRef.current) timecodeRef.current.textContent = fmtTime(t, pr.fps);
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => { cancelAnimationFrame(raf); pauseAllVideos(); useStore.getState().setTime(timeRef.current); };
  }, [s.playing]);

  // ---------- Önizlemede sürükleme ----------
  const drag = useRef<{ id: string; px: number; py: number; w: TR; pw: TR } | null>(null);
  const pts = useRef(new Map<number, { x: number; y: number }>());
  const pinch = useRef<{ id: string; d0: number; a0: number; s0: number; r0: number } | null>(null);
  const gdrag = useRef<{ id: string; which: 1 | 2 } | null>(null);
  const toProj = (e: { clientX: number; clientY: number }) => {
    const r = canvasRef.current!.getBoundingClientRect();
    return { x: (e.clientX - r.left) / r.width * p.width, y: (e.clientY - r.top) / r.height * p.height };
  };
  // Sahnedeki noktayı katmanın kendi (döndürülmemiş, ölçeksiz) koordinatına çevirir
  const toLayerLocal = (l: typeof sel, pt: { x: number; y: number }) => {
    const w = worldTransform(p, l!, s.time);
    const a = -w.rot * Math.PI / 180, dx = pt.x - w.x, dy = pt.y - w.y;
    return { x: (dx * Math.cos(a) - dy * Math.sin(a)) / w.scale, y: (dx * Math.sin(a) + dy * Math.cos(a)) / w.scale };
  };
  const pinchInfo = () => {
    const [a, b] = [...pts.current.values()];
    return { d: Math.hypot(b.x - a.x, b.y - a.y) || 1, a: Math.atan2(b.y - a.y, b.x - a.x) * 180 / Math.PI };
  };
  const onDown = (e: React.PointerEvent) => {
    if (s.playing) s.setPlaying(false);
    try { (e.target as HTMLElement).setPointerCapture(e.pointerId); } catch { /* bazı tarayıcılarda olmayabilir */ }
    pts.current.set(e.pointerId, { x: e.clientX, y: e.clientY });
    // İkinci parmak: iki parmakla büyütme/döndürme
    if (pts.current.size === 2) {
      const id = drag.current?.id ?? s.selectedId;
      const l = p.layers.find((x) => x.id === id);
      drag.current = null;
      if (l) { const pi = pinchInfo(); pinch.current = { id: l.id, d0: pi.d, a0: pi.a, s0: valueAt(l.scale, s.time), r0: valueAt(l.rotation, s.time) }; }
      return;
    }
    const pt = toProj(e);
    // Renk panelinde: geçiş noktalarını sürükle
    if (panel === 'color' && sel?.grad && sel.fill2) {
      const lp = toLayerLocal(sel, pt);
      const tol = 40 / worldTransform(p, sel, s.time).scale;
      for (const which of [1, 2] as const) {
        const gx = (which === 1 ? sel.grad.x1 : sel.grad.x2) * sel.w, gy = (which === 1 ? sel.grad.y1 : sel.grad.y2) * sel.h;
        if (Math.hypot(lp.x - gx, lp.y - gy) < tol) { s.checkpoint(); gdrag.current = { id: sel.id, which }; return; }
      }
    }
    const hit = hitTest(p, s.time, pt.x, pt.y);
    const keepSel = !!sel && hitTest(p, s.time, pt.x, pt.y, sel.id) !== null;
    const target = keepSel ? sel : hit;
    s.select(target?.id ?? null);
    if (!target) { if (panel && panel !== 'add') setPanel(null); return; }
    s.checkpoint();
    drag.current = { id: target.id, px: pt.x, py: pt.y, w: worldTransform(p, target, s.time), pw: parentWorld(p, target, s.time) };
  };
  const onMove = (e: React.PointerEvent) => {
    if (pts.current.has(e.pointerId)) pts.current.set(e.pointerId, { x: e.clientX, y: e.clientY });
    const pc = pinch.current;
    if (pc && pts.current.size >= 2) {
      const pi = pinchInfo();
      const sc = Math.max(0.02, Math.round(pc.s0 * pi.d / pc.d0 * 1000) / 1000);
      const rot = Math.round((pc.r0 + pi.a - pc.a0) * 10) / 10;
      s.updateLayer(pc.id, (l) => ({ ...l, scale: setAnim(l.scale, s.time, sc), rotation: setAnim(l.rotation, s.time, rot) }), false);
      return;
    }
    const g = gdrag.current;
    if (g && sel) {
      const lp = toLayerLocal(sel, toProj(e));
      const nx = Math.round(lp.x / sel.w * 1000) / 1000, ny = Math.round(lp.y / sel.h * 1000) / 1000;
      s.updateLayer(g.id, (l) => ({ ...l, grad: g.which === 1 ? { ...l.grad!, x1: nx, y1: ny } : { ...l.grad!, x2: nx, y2: ny } }), false);
      return;
    }
    const d = drag.current;
    if (!d) return;
    const pt = toProj(e);
    const loc = toLocal(d.pw, { ...d.w, x: d.w.x + pt.x - d.px, y: d.w.y + pt.y - d.py });
    s.updateLayer(d.id, (l) => ({ ...l, x: setAnim(l.x, s.time, Math.round(loc.x)), y: setAnim(l.y, s.time, Math.round(loc.y)) }), false);
  };
  const onUp = (e: React.PointerEvent) => {
    pts.current.delete(e.pointerId);
    if (pts.current.size < 2) pinch.current = null;
    if (!pts.current.size) { drag.current = null; gdrag.current = null; }
  };

  // ---------- Zaman çizelgesi ----------
  const tlRef = useRef<HTMLDivElement>(null);
  const programmatic = useRef(false);
  const [tlW, setTlW] = useState(360);
  useLayoutEffect(() => {
    const el = tlRef.current!;
    const ro = new ResizeObserver(() => setTlW(el.clientWidth));
    ro.observe(el);
    return () => ro.disconnect();
  }, []);
  useEffect(() => {
    const el = tlRef.current;
    if (!el) return;
    if (s.playing) return;
    const want = s.time * PPS;
    if (Math.abs(el.scrollLeft - want) > 1) { programmatic.current = true; el.scrollLeft = want; }
  }, [s.time, tlW, s.playing]);
  const pillsRef = useRef<HTMLDivElement>(null);
  const onTlScroll = () => {
    const el = tlRef.current!;
    if (pillsRef.current) pillsRef.current.style.transform = `translateY(${-el.scrollTop}px)`;
    if (programmatic.current) { programmatic.current = false; return; }
    if (s.playing) return;
    s.setTime(Math.min(el.scrollLeft / PPS, dur + 2));
  };
  const half = tlW / 2;
  const totalW = (dur + 2) * PPS;

  // ---------- Geri tuşu (Android) ----------
  const backRef = useRef<() => boolean>(() => false);
  backRef.current = () => {
    if (exporting !== null) return true;
    if (mmenu) { setMmenu(false); return true; }
    if (useStore.getState().multi) { useStore.getState().setMulti(null); return true; }
    if (pick) { setPick(null); return true; }
    if (menu || projMenu) { setMenu(false); setProjMenu(false); return true; }
    if (panel) { setPanel(null); return true; }
    if (s.selectedId) { s.select(null); return true; }
    return false;
  };
  useEffect(() => {
    const fn = (e: Event) => { if (backRef.current()) e.preventDefault(); };
    addEventListener('wm-back', fn);
    return () => removeEventListener('wm-back', fn);
  }, []);

  // ---------- Klavye (PC) ----------
  useEffect(() => {
    const fn = (e: KeyboardEvent) => {
      if ((e.target as HTMLElement).closest('input,textarea,select')) return;
      const st = useStore.getState();
      if (e.code === 'Space') { e.preventDefault(); st.setPlaying(!st.playing); }
      else if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'z') { e.preventDefault(); e.shiftKey ? st.redo() : st.undo(); }
      else if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'y') { e.preventDefault(); st.redo(); }
      else if ((e.key === 'Delete' || e.key === 'Backspace') && st.selectedId) st.removeLayer(st.selectedId);
    };
    addEventListener('keydown', fn);
    return () => removeEventListener('keydown', fn);
  }, []);

  const doExport = useCallback(async () => {
    s.setPlaying(false); s.select(null); setProjMenu(false);
    if (!p.layers.length) { show('Önce bir katman ekle.'); return; }
    setExporting(0);
    try {
      const { blob, ext } = await exportVideo(p, (f) => setExporting(f));
      const msg = await saveFile(blob, `${p.name.replace(/[^\p{L}\p{N} _-]/gu, '') || 'warden'}.${ext}`);
      show(msg);
    } catch (err) {
      show('Dışa aktarma başarısız: ' + (err as Error).message);
    }
    setExporting(null);
  }, [p]);

  // Takip et: katmanın sahnedeki yeri değişmeden ebeveyne bağlanır
  const linkParent = (childId: string, parentId: string | undefined) => {
    s.update((pp) => {
      const child = pp.layers.find((l) => l.id === childId)!;
      const w = worldTransform(pp, child, s.time);
      let pw: TR = { x: 0, y: 0, rot: 0, scale: 1, opacity: 1 };
      if (parentId) pw = worldTransform(pp, pp.layers.find((l) => l.id === parentId)!, s.time);
      const loc = toLocal(pw, w);
      return { ...pp, layers: pp.layers.map((l) => l.id === childId ? { ...l, parent: parentId, x: { v: loc.x }, y: { v: loc.y }, rotation: { v: loc.rot }, scale: { v: loc.scale } } : l) };
    });
    show(parentId ? 'Artık takip ediyor. Ebeveyni hareket ettirince bu da hareket eder.' : 'Takip bırakıldı.');
  };
  const isAncestor = (maybeAnc: string, id: string): boolean => {
    let cur = p.layers.find((l) => l.id === id);
    for (let i = 0; cur?.parent && i < 10; i++) { if (cur.parent === maybeAnc) return true; cur = p.layers.find((l) => l.id === cur!.parent); }
    return false;
  };

  // Uzun basma: çoklu seçim modunu açar; mod açıkken dokunma seçime ekler/çıkarır
  const press = useRef<{ t: ReturnType<typeof setTimeout>; long: boolean } | null>(null);
  const pressHandlers = (id: string) => ({
    onPointerDown: () => {
      const pr = { long: false, t: setTimeout(() => { pr.long = true; useStore.getState().setMulti([id]); navigator.vibrate?.(20); }, 450) };
      press.current = pr;
    },
    onPointerUp: () => { if (press.current) clearTimeout(press.current.t); },
    onPointerLeave: () => { if (press.current) clearTimeout(press.current.t); },
    onContextMenu: (e: React.MouseEvent) => e.preventDefault(),
    onClick: () => {
      if (press.current?.long) { press.current = null; return; }
      const m = useStore.getState().multi;
      if (m) { const n = m.includes(id) ? m.filter((x) => x !== id) : [...m, id]; s.setMulti(n.length ? n : null); }
      else s.select(id);
    },
  });

  // Seçili katmanların sahnedeki konumunu yazar (zaman t'de)
  const placeWorld = (ids: string[], fn: (l: import('../types').Layer, i: number, w: TR) => { x?: number; y?: number }) => {
    s.update((pp) => {
      const ls = ids.map((id) => pp.layers.find((l) => l.id === id)!).filter(Boolean);
      const ws = ls.map((l) => worldTransform(pp, l, s.time));
      const out = new Map<string, { x?: number; y?: number }>();
      ls.forEach((l, i) => out.set(l.id, fn(l, i, ws[i])));
      return { ...pp, layers: pp.layers.map((l) => {
        const o = out.get(l.id); if (!o) return l;
        const w = worldTransform(pp, l, s.time), pw = parentWorld(pp, l, s.time);
        const loc = toLocal(pw, { ...w, x: o.x ?? w.x, y: o.y ?? w.y });
        return { ...l, x: setAnim(l.x, s.time, Math.round(loc.x)), y: setAnim(l.y, s.time, Math.round(loc.y)) };
      }) };
    });
  };
  const multiAction = (kind: string) => {
    const ids = multi ?? [];
    setMmenu(false);
    if (kind === 'mask' || kind === 'exclude') {
      if (ids.length < 2) { show('En az iki katman seç.'); return; }
      // En üstteki seçili katman maske olur; diğerleri onun şekline kırpılır
      const order = p.layers.map((l) => l.id).filter((id) => ids.includes(id));
      const top = order[order.length - 1];
      s.update((pp) => ({ ...pp, layers: pp.layers.map((l) => l.id === top ? { ...l, hidden: true, name: l.name.includes('Maske') ? l.name : `${l.name} (Maske)` } : ids.includes(l.id) ? { ...l, mask: top, maskInvert: kind === 'exclude' } : l) }));
      s.setMulti(null);
      show(kind === 'mask' ? 'Maskeleme grubu oluşturuldu.' : 'Hariç tutma grubu oluşturuldu.');
    } else if (kind === 'cv') placeWorld(ids, () => ({ y: p.height / 2 }));
    else if (kind === 'ch') placeWorld(ids, () => ({ x: p.width / 2 }));
    else if (kind === 'dv' || kind === 'dh') {
      const key = kind === 'dv' ? 'y' : 'x';
      const ws = ids.map((id) => ({ id, w: worldTransform(p, p.layers.find((l) => l.id === id)!, s.time) })).sort((a, b) => a.w[key] - b.w[key]);
      const lo = ws[0].w[key], hi = ws[ws.length - 1].w[key];
      const pos = new Map(ws.map((x, i) => [x.id, lo + (hi - lo) * i / Math.max(1, ws.length - 1)]));
      placeWorld(ids, (l) => ({ [key]: pos.get(l.id) }));
    } else if (kind === 'dt') {
      const order = rows.map((l) => l.id).filter((id) => ids.includes(id));
      s.update((pp) => {
        let t0 = Math.min(...order.map((id) => pp.layers.find((l) => l.id === id)!.start));
        const starts = new Map<string, number>();
        for (const id of order) { const l = pp.layers.find((x) => x.id === id)!; starts.set(id, t0); t0 += l.end - l.start; }
        return { ...pp, layers: pp.layers.map((l) => (starts.has(l.id) ? { ...l, start: starts.get(l.id)!, end: starts.get(l.id)! + (l.end - l.start) } : l)) };
      });
    }
  };

  // Kırpma tutamaçları: seçili katmanın başını/sonunu sürükle
  const trim0 = useRef<{ id: string; side: 'start' | 'end'; x: number; v: number } | null>(null);
  const trimDown = (e: React.PointerEvent, id: string, side: 'start' | 'end') => {
    e.stopPropagation();
    try { (e.target as HTMLElement).setPointerCapture(e.pointerId); } catch { /* yok */ }
    const l = p.layers.find((x) => x.id === id)!;
    s.checkpoint();
    trim0.current = { id, side, x: e.clientX, v: side === 'start' ? l.start : l.end };
  };
  const trimMove = (e: React.PointerEvent) => {
    const d = trim0.current; if (!d) return;
    e.stopPropagation();
    const v = Math.round((d.v + (e.clientX - d.x) / PPS) * p.fps) / p.fps;
    s.updateLayer(d.id, (l) => (d.side === 'start' ? { ...l, start: Math.max(0, Math.min(v, l.end - 0.1)) } : { ...l, end: Math.max(l.start + 0.1, v) }), false);
  };
  const trimUp = () => { trim0.current = null; };

  const openAdd = (tab: AddTab | null) => { setAddTab(tab); setReplaceFlagOf(null); setPanel('add'); s.setPlaying(false); };

  // ---------- Paneller ----------
  const panelEl = panel === 'add' ? (
    <AddPanel tab={addTab} setTab={setAddTab} replaceFlagOf={replaceFlagOf} onClose={() => { setPanel(null); setReplaceFlagOf(null); }} toast={show} />
  ) : sel && panel === 'move' ? <MovePanel layer={sel} onClose={() => setPanel(null)} />
    : sel && panel === 'color' ? <ColorPanel layer={sel} onClose={() => setPanel(null)} />
    : sel && panel === 'opacity' ? <OpacityPanel layer={sel} onClose={() => setPanel(null)} />
    : sel && panel === 'effects' ? <EffectsPanel layer={sel} onClose={() => setPanel(null)} />
    : sel && panel === 'text' ? <TextPanel layer={sel} onClose={() => setPanel(null)} />
    : sel && panel === 'cb' ? <CBPanel layer={sel} onClose={() => setPanel(null)} onChangeFlag={() => { setAddTab('flags'); setReplaceFlagOf(sel.id); setPanel('add'); }} />
    : null;

  const trim = (kind: 'start' | 'end' | 'split') => {
    if (!sel) return;
    const t = s.time;
    if (t <= sel.start || t >= sel.end) { show('Oynatma çizgisini katmanın üstüne getir.'); return; }
    if (kind === 'start') s.updateLayer(sel.id, (l) => ({ ...l, start: t }));
    else if (kind === 'end') s.updateLayer(sel.id, (l) => ({ ...l, end: t }));
    else {
      s.update((pp) => {
        const i = pp.layers.findIndex((l) => l.id === sel.id);
        const a = { ...sel, end: t };
        const b = { ...structuredClone(sel), id: Math.random().toString(36).slice(2, 10), start: t, name: sel.name + ' (2)' };
        const layers = [...pp.layers];
        layers.splice(i, 1, a, b);
        return { ...pp, layers };
      });
    }
  };

  const big = (icon: string, label: string, on: (() => void) | null) => (
    <button className={'tbig' + (on ? '' : ' off')} disabled={!on} onClick={on ?? undefined}><Icon name={icon} size={24} />{label}</button>
  );
  const tools = sel ? (
    <div className="tools">
      <div className="tsmall">
        <button aria-label="Başlangıcı oynatma çizgisine çek" onClick={() => trim('start')}><Icon name="trimL" size={20} /></button>
        <button aria-label="Oynatma çizgisinden böl" onClick={() => trim('split')}><Icon name="split" size={20} /></button>
        <button aria-label="Sonu oynatma çizgisine çek" onClick={() => trim('end')}><Icon name="trimR" size={20} /></button>
        <button aria-label="Çoğalt" onClick={() => s.duplicateLayer(sel.id)}><Icon name="copy" size={20} /></button>
        <button aria-label={sel.hidden ? 'Göster' : 'Gizle'} onClick={() => s.updateLayer(sel.id, (l) => ({ ...l, hidden: !l.hidden }))}><Icon name={sel.hidden ? 'eyeOff' : 'eye'} size={20} /></button>
      </div>
      <div className="tbigs">
        {big('bucket', 'Renk ve Dolgu', sel.type === 'shape' || sel.type === 'text' ? () => setPanel('color') : null)}
        {sel.type === 'cb' ? big('ball', 'CB Ayarları', () => setPanel('cb')) : big('border', 'Kenarlık ve Gölge', null)}
        {big('layers', 'Karıştırma ve Opaklık', () => setPanel('opacity'))}
        {big('move', 'Taşı ve Çevir', () => setPanel('move'))}
        {sel.type === 'text' ? big('text', 'Metni Düzenle', () => setPanel('text')) : big('pen', 'Şekli Düzenle', null)}
        {big('sparkle', 'Efektler', () => setPanel('effects'))}
      </div>
    </div>
  ) : null

  const tut = p.tutorial ? TUTORIALS.find((t) => t.id === p.tutorial) : undefined;
  const rows = [...p.layers].reverse(); // en üstteki katman zaman çizelgesinde en üstte
  const multi = s.multi;
  const [mmenu, setMmenu] = useState(false);

  return (
    <div className="ed">
      <header className="ed-top">
        {multi ? (
          <div className="mbar">
            <button className="ib" aria-label="Seçimi bitir" onClick={() => s.setMulti(null)}><Icon name="close" /></button>
            <span className="ed-ptitle">{multi.length} katman seçildi</span>
            <button className="ib" aria-label="Seçilenleri çoğalt" onClick={() => { multi.forEach((id) => s.duplicateLayer(id)); s.setMulti(null); }}><Icon name="copy" /></button>
            <button className="ib" aria-label="Seçilenleri sil" onClick={() => { s.update((pp) => ({ ...pp, layers: pp.layers.filter((l) => !multi.includes(l.id)) })); s.setMulti(null); }}><Icon name="trash" /></button>
            <button className="ib" aria-label="Diğer" onClick={() => setMmenu(!mmenu)}><Icon name="more" size={26} stroke={3} /></button>
          </div>
        ) : sel && panel && panel !== 'add' ? (
          <>
            <button className="ib" aria-label="Geri" onClick={() => setPanel(null)}><Icon name="back" /></button>
            <span className="ed-ptitle">{PANEL_TITLE[panel]}</span>
          </>
        ) : sel ? (
          <>
            <button className="ib" aria-label="Seçimi kaldır" onClick={() => { s.select(null); setPanel(null); }}><Icon name="back" /></button>
            <input className="ed-title" aria-label="Katman adı" value={sel.name} onChange={(e) => s.updateLayer(sel.id, (l) => ({ ...l, name: e.target.value }), false)} />
            <button className="ib" aria-label="Sil" onClick={() => { s.removeLayer(sel.id); setPanel(null); }}><Icon name="trash" /></button>
            <button className="ib" aria-label="Diğer" onClick={() => setMenu(!menu)}><Icon name="more" size={26} stroke={3} /></button>
          </>
        ) : (
          <>
            <button className="ib" aria-label="Projeden çık" onClick={() => s.close()}><Icon name="exit" /></button>
            <input className="ed-title" aria-label="Proje adı" value={p.name} onChange={(e) => s.update((pp) => ({ ...pp, name: e.target.value }), false)} />
            <button className="ib" aria-label="Proje ayarları" onClick={() => setProjMenu(!projMenu)}><Icon name="gear" /></button>
            <button className="ib" aria-label="Dışa aktar" onClick={doExport}><Icon name="export" /></button>
          </>
        )}
      </header>

      <div className="stage" ref={stageRef}>
        <canvas ref={canvasRef} style={{ width: dispW, height: dispH }} onPointerDown={onDown} onPointerMove={onMove} onPointerUp={onUp} onPointerCancel={onUp} />
      </div>

      <div className="transport">
        <button className="ib" aria-label="Geri al" disabled={!s.past.length} onClick={s.undo}><Icon name="undo" /></button>
        <button className="ib" aria-label="Yinele" disabled={!s.future.length} onClick={s.redo}><Icon name="redo" /></button>
        <span className="tsp" />
        <button className="ib" aria-label="Başa git" onClick={() => s.setTime(0)}><Icon name="toStart" /></button>
        <button className="ib" aria-label={s.playing ? 'Duraklat' : 'Oynat'} onClick={() => s.setPlaying(!s.playing)}><Icon name={s.playing ? 'pause' : 'play'} size={26} /></button>
        <button className="ib" aria-label="Sona git" onClick={() => s.setTime(dur)}><Icon name="toEnd" /></button>
        <span className="tsp" />
        <button className="ib" aria-label="Tam ekran önizleme" onClick={() => { s.select(null); setPanel(null); s.setTime(0); s.setPlaying(true); }}><Icon name="fit" /></button>
        <button className={'ib loop' + (loop ? ' on' : '')} aria-label="Tekrarla" aria-pressed={loop} onClick={() => setLoop(!loop)}><Icon name="loop" /></button>
      </div>

      <div className="lower">
        <div className="tl">
          <div className="tl-scroll" ref={tlRef} onScroll={onTlScroll}>
            <div className="tl-inner" style={{ width: totalW + tlW }}>
              <div className="ruler" style={{ left: half, width: totalW }}>
                {Array.from({ length: Math.ceil((dur + 2) * 4) }, (_, i) => (
                  <i key={i} className={i % 4 === 0 ? 's' : ''} style={{ left: i * PPS / 4 }} />
                ))}
                {Array.from({ length: Math.ceil(dur + 2) }, (_, i) => <b key={i} style={{ left: i * PPS }}>{i}s</b>)}
              </div>
              {(sel ? [sel] : rows).map((l, i) => (
                <button key={l.id} className={'track' + (l.id === s.selectedId ? ' sel' : multi?.includes(l.id) ? ' msel' : ' off')}
                  style={{ left: half + l.start * PPS, width: Math.max(8, (l.end - l.start) * PPS), top: TOP + i * ROW, opacity: l.hidden ? 0.45 : 1 }}
                  {...pressHandlers(l.id)}>
                  <span className="tname">{l.mask ? '◐ ' : ''}{l.name}</span>
                  {l.id === s.selectedId && layerKeyTimes(l).map((kt) => <span key={kt} className="kf" style={{ left: (kt - l.start) * PPS }} />)}
                  {l.id === s.selectedId && (
                    <>
                      <span className="th l" role="slider" aria-label="Katmanın başlangıcı" aria-valuenow={l.start} onPointerDown={(e) => trimDown(e, l.id, 'start')} onPointerMove={trimMove} onPointerUp={trimUp} onClick={(e) => e.stopPropagation()} />
                      <span className="th r" role="slider" aria-label="Katmanın sonu" aria-valuenow={l.end} onPointerDown={(e) => trimDown(e, l.id, 'end')} onPointerMove={trimMove} onPointerUp={trimUp} onClick={(e) => e.stopPropagation()} />
                    </>
                  )}
                </button>
              ))}
              <div style={{ position: 'absolute', top: TOP + rows.length * ROW + 70, height: 1, width: 1 }} />
            </div>
          </div>
          {!p.layers.length && <div className="tl-empty">Katman eklemek için + butonuna bas.</div>}
          {!sel && p.layers.length > 0 && (
            <div className="pills" ref={pillsRef}>
              {rows.map((l, i) => (
                <button key={l.id} className={'lpill' + (multi?.includes(l.id) ? ' on' : '')} style={{ top: TOP + i * ROW }} aria-label={l.name} {...pressHandlers(l.id)}>
                  <LayerDot l={l} />
                </button>
              ))}
            </div>
          )}
          <div className="playhead" />
          <div className="timecode" ref={timecodeRef}>{fmtTime(s.time, p.fps)}</div>
        </div>
        {!wide && tools}
        {!wide && panelEl}
      </div>

      {wide && <div className="side-col">{tools}{panelEl}</div>}

      {!panel && !sel && <button className="fab-d" aria-label="Katman ekle" onClick={() => openAdd(null)}><Icon name="plus" size={28} stroke={2.4} /></button>}

      {mmenu && multi && (
        <div className="menu" role="menu">
          <button onClick={() => multiAction('mask')}>Maskeleme Grubu Oluştur</button>
          <button onClick={() => multiAction('exclude')}>Hariç Tutma Grubu Oluştur</button>
          <hr />
          <button onClick={() => multiAction('cv')}>Dikey Ortala</button>
          <button onClick={() => multiAction('ch')}>Yatay Ortala</button>
          <button disabled={multi.length < 3} onClick={() => multiAction('dv')}>Dikey Dağıt</button>
          <button disabled={multi.length < 3} onClick={() => multiAction('dh')}>Yatay Dağıt</button>
          <button onClick={() => multiAction('dt')}>Zaman Çizelgesine Dağıt</button>
        </div>
      )}

      {menu && sel && (
        <div className="menu" role="menu">
          <button onClick={() => { s.update((pp) => { const ls = pp.layers.filter((l) => l.id !== sel.id); return { ...pp, layers: [...ls, sel] }; }); setMenu(false); }}>Öne Getir</button>
          <button onClick={() => { s.update((pp) => { const ls = pp.layers.filter((l) => l.id !== sel.id); return { ...pp, layers: [sel, ...ls] }; }); setMenu(false); }}>Arkaya Gönder</button>
          <button onClick={() => { const r = sel.w / sel.h, cover = Math.max(p.width / sel.w, p.height / sel.h); s.updateLayer(sel.id, (l) => ({ ...l, w: Math.round(l.w * cover), h: Math.round(l.w * cover / r), x: { v: p.width / 2 }, y: { v: p.height / 2 }, scale: { v: 1 } })); setMenu(false); }}>Kompozisyon Alanını Doldur</button>
          <button onClick={() => { s.updateLayer(sel.id, (l) => ({ ...l, x: { v: p.width / 2 }, y: { v: p.height / 2 } })); setMenu(false); }}>Ortaya Hizala</button>
          <hr />
          {sel.parent
            ? <button onClick={() => { linkParent(sel.id, undefined); setMenu(false); }}>Takibi Bırak ({p.layers.find((l) => l.id === sel.parent)?.name})</button>
            : <button disabled={p.layers.length < 2} onClick={() => { setPick('parent'); setMenu(false); }}>Takip Et (çocuk yap)…</button>}
          {sel.mask
            ? <button onClick={() => { s.updateLayer(sel.id, (l) => ({ ...l, mask: undefined })); setMenu(false); }}>Kırpma Maskesini Kaldır</button>
            : <button disabled={p.layers.length < 2} onClick={() => { setPick('mask'); setMenu(false); }}>Kırpma Maskesi Oluştur…</button>}
          <hr />
          <button onClick={() => { s.updateLayer(sel.id, (l) => ({ ...l, start: 0, end: Math.max(l.end, dur) })); setMenu(false); }}>Tüm Süreye Yay</button>
        </div>
      )}

      {pick && sel && (
        <div className="choice" onClick={() => setPick(null)}>
          <div className="choice-box" onClick={(e) => e.stopPropagation()}>
            <h4>{pick === 'parent' ? `"${sel.name}" hangi katmanı takip etsin?` : `"${sel.name}" hangi katmanın şekline kırpılsın?`}</h4>
            <span style={{ fontSize: 12, color: 'var(--d-text2)' }}>{pick === 'parent' ? 'Seçtiğin katman ebeveyn olur; onu taşıyınca bu da taşınır.' : 'Örn. bayrağı gövdenin beyaz içine kırp.'}</span>
            {p.layers.filter((l) => l.id !== sel.id && !(pick === 'parent' && isAncestor(sel.id, l.id))).map((l) => (
              <button key={l.id} className="btn ghost" style={{ justifyContent: 'flex-start' }} onClick={() => {
                if (pick === 'parent') linkParent(sel.id, l.id);
                else { s.updateLayer(sel.id, (x) => ({ ...x, mask: l.id })); show('Kırpma maskesi oluşturuldu.'); }
                setPick(null);
              }}>{l.name}</button>
            ))}
            <button className="btn" onClick={() => setPick(null)}>Vazgeç</button>
          </div>
        </div>
      )}

      {projMenu && !sel && (
        <div className="menu" role="dialog" aria-label="Proje ayarları" style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <b>Proje Ayarları</b>
          <span style={{ fontSize: 13, color: 'var(--d-text2)' }}>{p.width} × {p.height} · {p.fps} fps · {fmtTime(dur, p.fps)}</span>
          <label style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>Arka Fon
            <input type="color" value={p.background} onChange={(e) => s.update((pp) => ({ ...pp, background: e.target.value }), false)} onBlur={() => s.checkpoint()} />
          </label>
          <button className="btn" onClick={doExport}><Icon name="export" size={18} />Videoyu Dışa Aktar</button>
        </div>
      )}

      {tut && (
        <TutorialBox title={tut.title} steps={tut.steps} tips={tut.tips} />
      )}

      {exporting !== null && (
        <div className="progress" role="status">
          <b>Video hazırlanıyor… %{Math.round(exporting * 100)}</b>
          <div className="bar"><i style={{ width: `${exporting * 100}%` }} /></div>
          <span style={{ fontSize: 12, color: 'var(--d-text2)' }}>Video gerçek süresinde kaydedilir.</span>
        </div>
      )}
      {toast && <div className="toast" role="status">{toast}</div>}
    </div>
  );
}

function TutorialBox({ title, steps, tips }: { title: string; steps: string[]; tips: string[] }) {
  const { tutorialStep: i, setTutorialStep } = useStore();
  const [min, setMin] = useState(false);
  if (min) return <button className="btn tutmin" onClick={() => setMin(false)}><Icon name="cap" size={18} />Öğretici</button>;
  const done = i >= steps.length;
  return (
    <div className="tutbox" role="region" aria-label="Öğretici">
      <div className="h"><Icon name="cap" size={16} />{title} · {done ? 'Taktikler' : `Adım ${i + 1}/${steps.length}`}
        <span style={{ flex: 1 }} /><button className="ib" style={{ width: 32, height: 32 }} aria-label="Küçült" onClick={() => setMin(true)}><Icon name="chevD" size={18} /></button></div>
      {done ? <ul style={{ margin: 0, paddingLeft: 18, display: 'flex', flexDirection: 'column', gap: 4 }}>{tips.map((t) => <li key={t}>{t}</li>)}</ul> : <div>{steps[i]}</div>}
      <div className="nav2">
        <button className="btn ghost" disabled={i === 0} onClick={() => setTutorialStep(i - 1)}>Geri</button>
        {!done && <button className="btn" onClick={() => setTutorialStep(i + 1)}>{i === steps.length - 1 ? 'Taktiklere geç' : 'İleri'}</button>}
        {done && <button className="btn" onClick={() => setMin(true)}><Icon name="check" size={16} />Bitir</button>}
      </div>
    </div>
  );
}

/** Zaman çizelgesinin solundaki küçük katman simgesi */
function LayerDot({ l }: { l: import('../types').Layer }) {
  if (l.type === 'shape') return <span className="dot" style={{ background: l.fill2 ? `linear-gradient(135deg, ${l.fill}, ${l.fill2})` : l.fill }} />;
  if (l.type === 'text') return <span className="dot txt">T</span>;
  if (l.src && !l.src.startsWith('media:')) return <img className="dot" src={l.src} alt="" />;
  return <span className="dot img"><Icon name="image" size={12} /></span>;
}
