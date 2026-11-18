import { useCallback, useEffect, useLayoutEffect, useRef, useState } from 'react';
import { Icon } from '../components/Icon';
import { AddPanel, type AddTab, ColorPanel, CBPanel, EffectsPanel, MovePanel, OpacityPanel, TextPanel } from '../components/Panels';
import { fmtTime, layerKeyTimes, projectDuration, setAnim } from '../anim';
import { exportVideo, saveFile } from '../export';
import { TUTORIALS } from '../factories';
import { hitTest, parentWorld, renderFrame, setImageLoadedHandler, toLocal, worldTransform, type TR } from '../render';
import { useStore } from '../store';
import type { Project } from '../types';

export type Panel = null | 'add' | 'move' | 'color' | 'opacity' | 'effects' | 'cb' | 'text';

const PPS = 100; // zaman çizelgesi: saniye başına piksel

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
  const [addTab, setAddTab] = useState<AddTab>('shape');
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
  const fit = Math.min((box.w - 16) / p.width, (box.h - 16) / p.height);
  const dispW = Math.max(10, Math.floor(p.width * fit)), dispH = Math.max(10, Math.floor(p.height * fit));
  const dpr = Math.min(2, window.devicePixelRatio || 1) * (s.settings.lowQuality ? 0.5 : 1);

  useEffect(() => {
    const c = canvasRef.current;
    if (!c) return;
    c.width = Math.round(dispW * dpr); c.height = Math.round(dispH * dpr);
    renderFrame(c.getContext('2d')!, p, s.time, { selectedId: s.playing ? null : s.selectedId, quality: c.width / p.width });
  });

  // ---------- Oynatma ----------
  useEffect(() => {
    if (!s.playing) return;
    let raf = 0, last = performance.now();
    const tick = (now: number) => {
      const st = useStore.getState();
      let t = st.time + (now - last) / 1000;
      last = now;
      if (t >= dur) t = 0;
      st.setTime(t);
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [s.playing, dur]);

  // ---------- Önizlemede sürükleme ----------
  const drag = useRef<{ id: string; px: number; py: number; w: TR; pw: TR } | null>(null);
  const toProj = (e: React.PointerEvent) => {
    const r = canvasRef.current!.getBoundingClientRect();
    return { x: (e.clientX - r.left) / r.width * p.width, y: (e.clientY - r.top) / r.height * p.height };
  };
  const onDown = (e: React.PointerEvent) => {
    if (s.playing) s.setPlaying(false);
    const pt = toProj(e);
    const hit = hitTest(p, s.time, pt.x, pt.y);
    const keepSel = !!sel && hitTest(p, s.time, pt.x, pt.y, sel.id) !== null;
    const target = keepSel ? sel : hit;
    s.select(target?.id ?? null);
    if (!target) return;
    (e.target as HTMLElement).setPointerCapture(e.pointerId);
    s.checkpoint();
    drag.current = { id: target.id, px: pt.x, py: pt.y, w: worldTransform(p, target, s.time), pw: parentWorld(p, target, s.time) };
  };
  const onMove = (e: React.PointerEvent) => {
    const d = drag.current;
    if (!d) return;
    const pt = toProj(e);
    const loc = toLocal(d.pw, { ...d.w, x: d.w.x + pt.x - d.px, y: d.w.y + pt.y - d.py });
    s.updateLayer(d.id, (l) => ({ ...l, x: setAnim(l.x, s.time, Math.round(loc.x)), y: setAnim(l.y, s.time, Math.round(loc.y)) }), false);
  };
  const onUp = () => { drag.current = null; };

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
    const want = s.time * PPS;
    if (Math.abs(el.scrollLeft - want) > 1) { programmatic.current = true; el.scrollLeft = want; }
  }, [s.time, tlW]);
  const onTlScroll = () => {
    const el = tlRef.current!;
    if (programmatic.current) { programmatic.current = false; return; }
    if (s.playing) s.setPlaying(false);
    s.setTime(Math.min(el.scrollLeft / PPS, dur + 2));
  };
  const half = tlW / 2;
  const totalW = (dur + 2) * PPS;

  // ---------- Geri tuşu (Android) ----------
  const backRef = useRef<() => boolean>(() => false);
  backRef.current = () => {
    if (exporting !== null) return true;
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

  const openAdd = (tab: AddTab) => { setAddTab(tab); setReplaceFlagOf(null); setPanel('add'); s.setPlaying(false); };

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

  const tools = sel ? (
    <div className="tools">
      <div className="trim-row">
        <button className="tbtn" onClick={() => trim('start')}><Icon name="trimL" />Başı buraya</button>
        <button className="tbtn" onClick={() => trim('split')}><Icon name="split" />Böl</button>
        <button className="tbtn" onClick={() => trim('end')}><Icon name="trimR" />Sonu buraya</button>
        <button className="tbtn" onClick={() => s.updateLayer(sel.id, (l) => ({ ...l, hidden: !l.hidden }))}><Icon name={sel.hidden ? 'eyeOff' : 'eye'} />{sel.hidden ? 'Göster' : 'Gizle'}</button>
      </div>
      <div className="tgrid">
        {sel.type === 'cb' && <button className="tbtn hl" onClick={() => setPanel('cb')}><Icon name="ball" size={26} />CB Ayarları</button>}
        {sel.type === 'text' && <button className="tbtn hl" onClick={() => setPanel('text')}><Icon name="text" size={26} />Metni Düzenle</button>}
        {(sel.type === 'shape' || sel.type === 'text') && <button className="tbtn" onClick={() => setPanel('color')}><Icon name="bucket" size={26} />Renk ve Dolgu</button>}
        <button className="tbtn" onClick={() => setPanel('opacity')}><Icon name="opacity" size={26} />Karıştırma ve Opaklık</button>
        <button className="tbtn" onClick={() => setPanel('move')}><Icon name="move" size={26} />Taşı ve Çevir</button>
        <button className="tbtn" onClick={() => setPanel('effects')}><Icon name="sparkle" size={26} />Efektler</button>
      </div>
    </div>
  ) : (
    <div className="tools" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--d-text2)', fontSize: 14, textAlign: 'center' }}>
      {p.layers.length ? 'Düzenlemek için önizlemede ya da zaman çizelgesinde bir katmana dokun.' : 'Katman eklemek için + butonuna bas.'}
    </div>
  );

  const tut = p.tutorial ? TUTORIALS.find((t) => t.id === p.tutorial) : undefined;

  return (
    <div className="ed">
      <header className="ed-top">
        {sel ? (
          <>
            <button className="ib" aria-label="Seçimi kaldır" onClick={() => { s.select(null); setPanel(null); }}><Icon name="back" /></button>
            <input className="ed-title" aria-label="Katman adı" value={sel.name} onChange={(e) => s.updateLayer(sel.id, (l) => ({ ...l, name: e.target.value }), false)} />
            <button className="ib" aria-label="Çoğalt" onClick={() => s.duplicateLayer(sel.id)}><Icon name="copy" /></button>
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
        <button className="ib" aria-label="Başa git" onClick={() => s.setTime(0)}><Icon name="toStart" /></button>
        <button className="ib" aria-label={s.playing ? 'Duraklat' : 'Oynat'} onClick={() => s.setPlaying(!s.playing)} style={{ color: 'var(--turq)' }}><Icon name={s.playing ? 'pause' : 'play'} size={26} /></button>
        <button className="ib" aria-label="Sona git" onClick={() => s.setTime(dur)}><Icon name="toEnd" /></button>
        <button className="ib" aria-label="Dışa aktar" onClick={doExport}><Icon name="export" /></button>
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
              {p.layers.map((l, i) => (
                <button key={l.id} className={'track' + (l.id === s.selectedId ? '' : ' off')}
                  style={{ left: half + l.start * PPS, width: Math.max(8, (l.end - l.start) * PPS), top: 56 + i * 34, opacity: l.hidden ? 0.45 : 1 }}
                  onClick={() => { s.select(l.id); }}>
                  {l.name}
                  {l.id === s.selectedId && layerKeyTimes(l).map((kt) => <span key={kt} className="kf" style={{ left: (kt - l.start) * PPS }} />)}
                </button>
              ))}
              <div style={{ position: 'absolute', top: 56 + p.layers.length * 34 + 60, height: 1, width: 1 }} />
            </div>
          </div>
          <div className="playhead" />
          <div className="timecode">{fmtTime(s.time, p.fps)}</div>
        </div>
        {!wide && tools}
        {!wide && panelEl}
      </div>

      {wide && <div className="side-col">{tools}{panelEl}</div>}

      {!panel && <button className="fab-d" aria-label="Katman ekle" onClick={() => openAdd(sel?.type === 'cb' ? 'cb' : 'shape')}><Icon name="plus" size={28} stroke={2} /></button>}

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
