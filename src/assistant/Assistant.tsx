import { useEffect, useLayoutEffect, useRef, useState } from 'react';
import { WardenCB, type Mood } from '../components/WardenCB';
import { Icon } from '../components/Icon';
import { useStore } from '../store';
import { TUTORIALS } from '../factories';
import { APP_VERSION, buildScript, loadSaved, route, saveSaved, useAssistant, WAS_EXISTING } from './engine';

interface View { key: string; sub: string; rect: { x: number; y: number; w: number; h: number } | null; say: string; mood: Mood; recover: boolean; action: boolean }

const TUT_IDS = ['g1', 'cb1'];

/** Ayarlar menüsünden tanışmayı yeniden başlatır */
export function replayIntro() {
  const s = loadSaved();
  saveSaved({ ...s, editor: false });
  const sc = buildScript('intro', { existing: false });
  if (sc) useAssistant.getState().start(sc);
}

export function Assistant() {
  const { run, min, go, stop, setMin, start } = useAssistant();
  const screen = useStore((s) => s.screen);
  const pid = useStore((s) => s.project?.id);
  const tut = useStore((s) => s.project?.tutorial);
  const [view, setView] = useState<View | null>(null);
  const cardRef = useRef<HTMLDivElement>(null);
  const [cardH, setCardH] = useState(150);
  const scrolled = useRef(new WeakSet<Element>());
  const [, setVw] = useState(0);

  // ---- Ne zaman gelir ----
  useEffect(() => {
    const saved = loadSaved();
    const st = useStore.getState();
    // Öğretici projesi açıldı: kaldığı adımdan devam
    if (screen === 'editor' && st.project?.tutorial && TUT_IDS.includes(st.project.tutorial)) {
      if (run?.pid === st.project.id) return;
      const at = saved.tut?.[st.project.id] ?? 0;
      if (at >= 999) return;
      const t = TUTORIALS.find((x) => x.id === st.project!.tutorial);
      const sc = buildScript('tut:' + st.project.tutorial, { pid: st.project.id, tips: t?.tips });
      if (sc) start(sc, at);
      return;
    }
    if (run) return;
    const t = setTimeout(() => {
      if (useAssistant.getState().run) return;
      const s2 = loadSaved();
      const cur = useStore.getState();
      if (cur.screen === 'home' && !s2.intro) { const sc = buildScript('intro', { existing: WAS_EXISTING, from: s2.ver }); if (sc) start(sc); }
      else if (cur.screen === 'home' && s2.ver !== APP_VERSION) {
        const sc = buildScript('whatsnew', { from: s2.ver });
        if (sc) start(sc); else saveSaved({ ...s2, ver: APP_VERSION });
      } else if (cur.screen === 'editor' && cur.project && !cur.project.tutorial && s2.intro && !s2.editor) {
        const sc = buildScript('editor');
        if (sc) start(sc);
      }
    }, 700);
    return () => clearTimeout(t);
  }, [screen, pid, tut, !!run]);

  // ---- Canlı izleme: her an gerçek ekrana bakar ----
  useEffect(() => {
    if (!run || min) { setView(null); return; }
    let doneAt = 0;
    const tick = () => {
      const r = useAssistant.getState().run;
      if (!r) return;
      const step = r.script.steps[r.step];
      if (step.done && step.done()) {
        if (!doneAt) doneAt = performance.now();
        else if (performance.now() - doneAt > 350) { doneAt = 0; go(r.step + 1); }
        return;
      }
      doneAt = 0;
      const hint = step.need ? route(step.need) : null;
      const el = hint ? hint.el : step.target?.() ?? null;
      if (el && !scrolled.current.has(el) && !el.closest('.tl')) {
        scrolled.current.add(el);
        const b = el.getBoundingClientRect();
        if (b.bottom > innerHeight || b.top < 0 || b.right > innerWidth || b.left < 0) el.scrollIntoView({ block: 'nearest', inline: 'nearest' });
      }
      const b = el?.getBoundingClientRect();
      const v: View = {
        key: `${r.script.id}:${r.step}`,
        rect: b && b.width > 0 ? { x: b.left, y: b.top, w: b.width, h: b.height } : null,
        say: hint?.recover ? hint.say : step.say,
        sub: hint && !hint.recover ? hint.say : '',
        mood: hint ? hint.mood : step.mood ?? (el ? 'point' : 'idle'),
        recover: !!hint?.recover,
        action: !!step.done || !!hint,
      };
      setView((old) => (old && JSON.stringify(old) === JSON.stringify(v) ? old : v));
    };
    tick();
    const id = setInterval(tick, 120);
    const onR = () => setVw(innerWidth);
    addEventListener('resize', onR);
    return () => { clearInterval(id); removeEventListener('resize', onR); };
  }, [run?.script.id, run?.step, min]);

  useLayoutEffect(() => { if (cardRef.current) setCardH(cardRef.current.offsetHeight); });

  if (!run) return null;
  if (min) {
    return (
      <button className="wa-min" aria-label="WardenCB'yi aç" onClick={() => setMin(false)}>
        <WardenCB size={58} mood="idle" />
      </button>
    );
  }
  if (!view) return null;

  // ---- Yerleşim: hedefin karşı tarafı ----
  const vw = innerWidth, vh = innerHeight;
  const cw = Math.min(380, vw - 20);
  const r = view.rect;
  const topY = screen === 'editor' ? 58 : 66, botY = vh - cardH - (screen === 'editor' ? 14 : 78);
  const overlap = (y: number) => (r ? Math.max(0, Math.min(y + cardH, r.y + r.h) - Math.max(y, r.y)) : 0);
  const atTop = r ? (overlap(topY) === overlap(botY) ? r.y + r.h / 2 > vh / 2 : overlap(topY) < overlap(botY)) : false;
  const cy = atTop ? topY : botY;
  // WardenCB normalde sola (ekrana) bakar; hedef sağdaysa soldan çıkar ve aynalanır
  const tx = r ? r.x + r.w / 2 : vw / 2, ty = r ? r.y + r.h / 2 : vh / 2;
  const onLeft = r ? tx > vw / 2 : false;
  const cx = (vw - cw) / 2;
  const ms = 84;
  const mx = onLeft ? cx + 4 : cx + cw - ms - 4, my = cy + cardH / 2 - ms * 0.42;
  const mcx = mx + ms / 2, mcy = my + ms * 0.42;
  const clamp = (n: number) => Math.max(-1, Math.min(1, n));
  const lx = clamp((tx - mcx) / 140), ly = clamp((ty - mcy) / 220);
  // Ok: WardenCB'den hedefin kenarına
  let arrow: string | null = null;
  if (r && r.w * r.h < vw * vh * 0.35) {
    const dx = tx - mcx, dy = ty - (atTop ? cy + cardH : cy);
    const sx = mcx + (onLeft ? 14 : -14), sy = atTop ? cy + cardH + 4 : cy - 4;
    const ddx = tx - sx, ddy = ty - sy;
    const t = Math.min(Math.abs(ddx) > 0.1 ? (r.w / 2 + 12) / Math.abs(ddx) : 9, Math.abs(ddy) > 0.1 ? (r.h / 2 + 12) / Math.abs(ddy) : 9);
    if (t < 0.92 && Math.hypot(dx, dy) > 30) {
      const ex = tx - ddx * t, ey = ty - ddy * t;
      const mxp = (sx + ex) / 2 + (onLeft ? -1 : 1) * Math.min(60, Math.abs(ey - sy) * 0.25), myp = (sy + ey) / 2;
      arrow = `M${sx.toFixed(1)} ${sy.toFixed(1)} Q${mxp.toFixed(1)} ${myp.toFixed(1)} ${ex.toFixed(1)} ${ey.toFixed(1)}`;
    }
  }
  const step = run.script.steps[run.step];
  const n = run.script.steps.length;

  return (
    <div className="wa" aria-live="polite">
      {r && <div className={'wa-ring' + (view.recover ? ' warn' : '')} style={{ left: r.x - 6, top: r.y - 6, width: r.w + 12, height: r.h + 12 }} />}
      {arrow && (
        <svg className="wa-arrow" width={vw} height={vh} aria-hidden="true">
          <defs><marker id="wa-head" viewBox="0 0 10 10" refX="6" refY="5" markerWidth="5" markerHeight="5" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 Z" fill={view.recover ? '#F2C230' : '#22D3E6'} /></marker></defs>
          <path d={arrow} className={view.recover ? 'warn' : ''} markerEnd="url(#wa-head)" />
        </svg>
      )}
      <div ref={cardRef} key={run.script.id} className={'wa-card' + (onLeft ? ' l' : ' r')} role="dialog" aria-label="WardenCB" style={{ left: cx, top: cy, width: cw }}>
        <div className="wa-head">
          <span>{run.script.title} · {Math.min(run.step + 1, n)}/{n}</span>
          <span style={{ flex: 1 }} />
          <button className="ib" aria-label="WardenCB'yi küçült" onClick={() => setMin(true)}><Icon name="chevD" size={18} /></button>
          <button className="ib" aria-label="WardenCB'yi kapat" onClick={() => stop(false)}><Icon name="close" size={18} /></button>
        </div>
        <p className={view.recover ? 'warn' : ''}>{view.say}</p>
        {view.sub && <p className="wa-sub">👉 {view.sub}</p>}
        <div className="wa-btns">
          {run.step > 0 && !view.recover && <button className="wa-b ghost" onClick={() => go(run.step - 1)}>Geri</button>}
          <span style={{ flex: 1 }} />
          {view.action
            ? <button className="wa-b ghost" onClick={() => go(run.step + 1)}>Atla</button>
            : <button className="wa-b" onClick={() => go(run.step + 1)}>{step.btn ?? 'İleri'}</button>}
        </div>
      </div>
      <div className={'wa-mascot' + (onLeft ? ' l' : ' r')} key={'m' + run.script.id} style={{ left: mx, top: my, width: ms }}>
        <WardenCB size={ms} mood={view.mood} look={onLeft ? -lx : lx} lookY={ly} flip={onLeft} />
      </div>
    </div>
  );
}
