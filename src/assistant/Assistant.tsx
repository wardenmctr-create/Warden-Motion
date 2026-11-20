import { useEffect, useLayoutEffect, useRef, useState } from 'react';
import { WardenCB, type Mood } from '../components/WardenCB';
import { Icon } from '../components/Icon';
import { useStore } from '../store';
import { TUTORIALS } from '../factories';
import { APP_VERSION, buildScript, clearPendingDemo, type HandApi, loadSaved, pendingDemo, route, saveSaved, useAssistant, WAS_EXISTING } from './engine';
import { blip, setVoice, unlockVoice, voiceOn } from './voice';

const wait = (ms: number) => new Promise<void>((r) => setTimeout(r, ms));
interface HandPos { x: number; y: number; press: boolean; drag: boolean }

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
      if (at >= 999 && pendingDemo !== st.project.id) return;
      const t = TUTORIALS.find((x) => x.id === st.project!.tutorial);
      const sc = buildScript('tut:' + st.project.tutorial, { pid: st.project.id, tips: t?.tips });
      const demo = pendingDemo === st.project.id;
      if (demo) clearPendingDemo();
      if (sc) start(sc, demo ? 0 : at, demo);
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

  // ---- Konuşma: yazı harf harf çıkar, her harfte kısa ses ----
  const full = view ? view.say + (view.sub ? '\n' + view.sub : '') : '';
  const [shown, setShown] = useState(0);
  const [voice, setVoiceS] = useState(voiceOn);
  useEffect(() => {
    setShown(0);
    if (!full) return;
    let i = 0;
    const id = setInterval(() => {
      i++;
      if (i % 2) blip(full[i - 1] ?? '');
      setShown(i);
      if (i >= full.length) clearInterval(id);
    }, 26);
    return () => clearInterval(id);
  }, [full]);
  useEffect(() => {
    const fn = () => unlockVoice();
    addEventListener('pointerdown', fn, { once: true });
    return () => removeEventListener('pointerdown', fn);
  }, []);

  // ---- Asistanın eli: "Anlamadım" ya da gösterimde adımı kendisi yapar ----
  const [hand, setHand] = useState<HandPos | null>(null);
  const [autoReq, setAutoReq] = useState(false);
  const token = useRef(0);
  const handApi: HandApi = {
    wait,
    tap: async (el, act) => {
      const b = el.getBoundingClientRect();
      setHand({ x: b.left + b.width / 2, y: b.top + b.height / 2, press: false, drag: false });
      await wait(650);
      setHand((h) => h && { ...h, press: true });
      await wait(170);
      (act ?? (() => el.click()))();
      setHand((h) => h && { ...h, press: false });
      await wait(260);
    },
    drag: async (from, to, onMove, ms = 900) => {
      setHand({ ...from, press: false, drag: false });
      await wait(650);
      setHand({ ...from, press: true, drag: true });
      const t0 = performance.now();
      await new Promise<void>((res) => {
        const f = () => {
          const k = Math.min(1, (performance.now() - t0) / ms), e = k < 0.5 ? 2 * k * k : 1 - (-2 * k + 2) ** 2 / 2;
          setHand({ x: from.x + (to.x - from.x) * e, y: from.y + (to.y - from.y) * e, press: true, drag: true });
          onMove(e);
          if (k < 1) requestAnimationFrame(f); else res();
        };
        requestAnimationFrame(f);
      });
      setHand((h) => h && { ...h, press: false, drag: false });
      useStore.getState().checkpoint();
      await wait(250);
    },
  };
  useEffect(() => { setAutoReq(false); }, [run?.script, run?.step]);
  useEffect(() => {
    const r = useAssistant.getState().run;
    if (!r || !(r.demo || autoReq)) { setHand(null); return; }
    const my = ++token.current;
    const alive = () => { const c = useAssistant.getState().run; return token.current === my && !!c && c.script === r.script && c.step === r.step; };
    const step = r.script.steps[r.step];
    (async () => {
      if (step.choices) { useAssistant.getState().setDemo(false); return; }
      await wait(r.demo ? Math.min(4200, 700 + step.say.length * 30) : 250);
      for (let i = 0; i < 14 && alive(); i++) {
        if (step.done?.()) break;
        const hint = step.need ? route(step.need) : null;
        if (hint) { if (hint.el) await handApi.tap(hint.el, hint.act); else await wait(500); await wait(400); continue; }
        if (step.auto) { await step.auto(handApi); await wait(500); if (!step.done) break; continue; }
        const el = step.target?.();
        if (step.done && el) { await handApi.tap(el); await wait(500); continue; }
        break;
      }
      if (!alive()) return;
      setHand(null);
      if (!step.done && r.demo) { await wait(700); if (alive()) go(r.step + 1); }
    })();
    return () => { token.current++; };
  }, [run?.script, run?.step, run?.demo, autoReq]);

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
          <button className="ib" aria-label={voice ? 'Sesi kapat' : 'Sesi aç'} onClick={() => { setVoice(!voice); setVoiceS(!voice); unlockVoice(); }}>{voice ? '🔊' : '🔇'}</button>
          <button className="ib" aria-label="WardenCB'yi küçült" onClick={() => setMin(true)}><Icon name="chevD" size={18} /></button>
          <button className="ib" aria-label="WardenCB'yi kapat" onClick={() => stop(false)}><Icon name="close" size={18} /></button>
        </div>
        <p className={view.recover ? 'warn' : ''} onClick={() => setShown(full.length)}>{view.say.slice(0, shown)}<span className="wa-ghost">{view.say.slice(shown)}</span></p>
        {view.sub && <p className="wa-sub" onClick={() => setShown(full.length)}>👉 {view.sub.slice(0, Math.max(0, shown - view.say.length - 1))}<span className="wa-ghost">{view.sub.slice(Math.max(0, shown - view.say.length - 1))}</span></p>}
        {step.choices && !view.recover && !view.sub ? (
          <div className="wa-choices">
            {step.choices.map((c) => <button key={c.label} className="wa-ch" onClick={c.act}>{c.label}</button>)}
          </div>
        ) : null}
        <div className="wa-btns">
          {run.step > 0 && !view.recover && !run.demo && <button className="wa-b ghost" onClick={() => go(run.step - 1)}>Geri</button>}
          <span style={{ flex: 1 }} />
          {run.demo
            ? <button className="wa-b ghost" onClick={() => useAssistant.getState().setDemo(false)}>Durdur</button>
            : (step.done || step.auto) && !autoReq && <button className="wa-b ghost" onClick={() => setAutoReq(true)}>Anlamadım</button>}
          {!step.choices && <button className="wa-b" onClick={() => (step.end ? stop(true) : go(run.step + 1))}>{step.btn ?? 'Geç'}</button>}
        </div>
      </div>
      {hand && (
        <div className={'wa-hand' + (hand.press ? ' press' : '') + (hand.drag ? ' drag' : '')} style={{ left: hand.x, top: hand.y }} aria-hidden="true">
          <svg width="34" height="40" viewBox="0 0 34 40"><path d="M4 2 L4 30 L11 23 L16 35 L21 33 L16 21 L26 21 Z" fill="#22D3E6" stroke="#0B1430" strokeWidth="2.5" strokeLinejoin="round" /></svg>
          <i />
        </div>
      )}
      <div className={'wa-mascot' + (onLeft ? ' l' : ' r')} key={'m' + run.script.id} style={{ left: mx, top: my, width: ms }}>
        <WardenCB size={ms} mood={view.mood} look={onLeft ? -lx : lx} lookY={ly} flip={onLeft} />
      </div>
    </div>
  );
}
