import { useEffect, useMemo, useRef, useState } from 'react';
import { Icon } from './Icon';
import { keyAt, setAnim, toggleKey, uid, valueAt } from '../anim';
import { addUserFlag, addUserFolder, addUserPackItems, listUserFlags, listUserFolders, listUserPack, putMedia, removeUserPackItem, type UserFlag, type UserPackItem } from '../db';
import { makeLayer, SHAPES } from '../factories';
import { resolveSrc, shapePath } from '../render';
import { useStore } from '../store';
import { askText } from '../dialog';
import type { AnimProp, Effect, Layer, Project } from '../types';

// ---------- Ortak ----------
function Head({ title, onClose, back = false }: { title: string; onClose: () => void; back?: boolean }) {
  return (
    <div className="dhead">
      <button className="ib" aria-label={back ? 'Geri' : 'Kapat'} onClick={onClose}><Icon name={back ? 'back' : 'close'} /></button>
      <h3>{title}</h3>
    </div>
  );
}

const useNow = () => {
  const s = useStore();
  return { s, p: s.project as Project, t: s.time };
};

/** Pack görseli (yol ya da media:id) için önizleme adresi */
function Img({ src, alt }: { src: string; alt: string }) {
  const [url, setUrl] = useState(src.startsWith('media:') ? '' : src);
  useEffect(() => { if (src.startsWith('media:')) resolveSrc(src).then(setUrl); }, [src]);
  return url ? <img src={url} alt={alt} loading="lazy" draggable={false} /> : null;
}

function loadSize(src: string): Promise<{ w: number; h: number }> {
  return resolveSrc(src).then((u) => new Promise((res) => {
    const i = new Image();
    i.onload = () => res({ w: i.naturalWidth || 512, h: i.naturalHeight || 512 });
    i.onerror = () => res({ w: 512, h: 512 });
    i.src = u;
  }));
}

const RECENT = 'wm-recent';
const pushRecent = (src: string) => {
  try {
    const r: string[] = JSON.parse(localStorage.getItem(RECENT) || '[]');
    localStorage.setItem(RECENT, JSON.stringify([src, ...r.filter((x) => x !== src)].slice(0, 12)));
  } catch { /* depolama kapalı olabilir */ }
};
const getRecent = (): string[] => { try { return JSON.parse(localStorage.getItem(RECENT) || '[]'); } catch { return []; } };

// ---------- Ekle paneli ----------
export type AddTab = 'shape' | 'media' | 'text' | 'cb' | 'flags';

interface PackFolder { name: string; items: { name: string; src: string }[] }

export function AddPanel({ tab, setTab, onClose, toast, replaceFlagOf }: { tab: AddTab; setTab: (t: AddTab) => void; onClose: () => void; toast: (m: string) => void; replaceFlagOf: string | null }) {
  const { s, p, t } = useNow();
  const dur = s.settings.defaultDuration;

  const addImage = async (src: string, name: string, frac = 0.45) => {
    const { w, h } = await loadSize(src);
    const base = Math.min(p.width, p.height) * frac;
    const k = base / Math.max(w, h);
    s.addLayer(makeLayer(p, t, dur, { type: 'image', name, src, w: Math.round(w * k), h: Math.round(h * k) }));
    pushRecent(src);
    onClose();
  };

  /** Gövde kur: çizgi (ebeveyn) + beyaz iç (takip eder) [+ bayrak iç'e kırpılmış] [+ gözler] */
  const buildBody = (shape: string, flagSrc?: string, flagName?: string) => {
    const size = Math.round(Math.min(p.width, p.height) * 0.5);
    const lineId = uid(), innerId = uid();
    const line = { ...makeLayer(p, t, dur, { type: 'image', name: `${flagName ?? 'Gövde'} Çizgi`, src: `packs/hazir/govdeler/${shape}-cizgi.png`, w: size, h: size }), id: lineId };
    const inner = { ...makeLayer(p, t, dur, { type: 'image', name: `${flagName ?? 'Gövde'} İç`, src: `packs/hazir/govdeler/${shape}-ic.png`, w: size, h: size }), id: innerId, parent: lineId, x: { v: 0 }, y: { v: 0 } };
    const extra: Layer[] = [];
    if (flagSrc) {
      extra.push({ ...makeLayer(p, t, dur, { type: 'image', name: `${flagName} Bayrak`, src: flagSrc, w: Math.round(size * 1.34), h: size }), id: uid(), parent: lineId, mask: innerId, x: { v: 0 }, y: { v: 0 } });
      extra.push({ ...makeLayer(p, t, dur, { type: 'image', name: `${flagName} Gözler`, src: 'packs/hazir/gozler/normal.png', w: Math.round(size * 0.62), h: Math.round(size * 0.62) }), id: uid(), parent: lineId, x: { v: 0 }, y: { v: -Math.round(size * 0.06) } });
    }
    s.update((pp) => ({ ...pp, layers: [...pp.layers, inner, ...extra.slice(0, 1), line, ...extra.slice(1)] }));
    s.select(lineId);
    toast(flagSrc ? 'CB hazır: çizgiyi taşıyınca hepsi birlikte hareket eder.' : 'Gövde kuruldu: iç, çizgiyi takip ediyor.');
    onClose();
  };

  const tabs: { id: AddTab; label: string; icon: string }[] = [
    { id: 'shape', label: 'Şekil', icon: 'shapes' }, { id: 'media', label: 'Medya', icon: 'image' },
    { id: 'text', label: 'Metin', icon: 'text' }, { id: 'cb', label: 'CB Araçları', icon: 'ball' }, { id: 'flags', label: 'Bayraklar', icon: 'flag' },
  ];

  return (
    <div className="dpanel" role="dialog" aria-label="Katman ekle">
      <Head title={replaceFlagOf ? 'Bayrağı Değiştir' : 'Ekle'} onClose={onClose} />
      {!replaceFlagOf && (
        <div className="cats" role="tablist">
          {tabs.map((x) => (
            <button key={x.id} role="tab" aria-selected={tab === x.id} className={'cat' + (tab === x.id ? ' on' : '')} onClick={() => setTab(x.id)}>
              <Icon name={x.icon} size={26} />{x.label}
            </button>
          ))}
        </div>
      )}
      <div className="dbody">
        {tab === 'shape' && (
          <div className="shape-grid">
            {SHAPES.map((sh) => (
              <button key={sh.kind} aria-label={sh.name} onClick={() => { s.addLayer(makeLayer(p, t, dur, { type: 'shape', name: sh.name, shape: sh.kind, w: sh.kind === 'rect' || sh.kind === 'roundrect' ? 260 : 240, h: 240 })); onClose(); }}>
                <ShapeIcon kind={sh.kind} />
              </button>
            ))}
          </div>
        )}
        {tab === 'media' && <MediaTab onPick={(src, name) => addImage(src, name, 0.7)} />}
        {tab === 'text' && <TextTab onAdd={(text) => { s.addLayer(makeLayer(p, t, dur, { type: 'text', name: text.slice(0, 18) || 'Metin', text, fontSize: Math.round(p.height / 12), fill: '#0D1631', w: Math.round(p.width * 0.6), h: Math.round(p.height / 8) })); onClose(); }} />}
        {tab === 'cb' && <CBTab onPick={(src, name) => addImage(src, name)} onBody={(shape) => buildBody(shape)} toast={toast} />}
        {tab === 'flags' && (
          <FlagsTab
            replace={!!replaceFlagOf}
            onPick={(src, name, mode) => {
              if (replaceFlagOf) { s.updateLayer(replaceFlagOf, (l) => ({ ...l, src })); onClose(); return; }
              if (mode === 'cb') buildBody('top', src, name);
              else addImage(src, `${name} Bayrağı`, 0.6);
            }}
            toast={toast}
          />
        )}
      </div>
    </div>
  );
}

function ShapeIcon({ kind }: { kind: Parameters<typeof shapePath>[0] }) {
  const ref = useRef<HTMLCanvasElement>(null);
  useEffect(() => {
    const c = ref.current!; c.width = 80; c.height = 80;
    const x = c.getContext('2d')!;
    x.translate(40, 40); x.fillStyle = '#B9C6DC';
    x.fill(shapePath(kind, kind === 'rect' || kind === 'roundrect' ? 56 : 58, 56));
  }, [kind]);
  return <canvas ref={ref} style={{ width: 40, height: 40 }} />;
}

function MediaTab({ onPick }: { onPick: (src: string, name: string) => void }) {
  const ref = useRef<HTMLInputElement>(null);
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12, alignItems: 'flex-start' }}>
      <button className="btn" onClick={() => ref.current?.click()}><Icon name="image" size={18} />Galeriden Görsel Seç</button>
      <span style={{ fontSize: 13, color: 'var(--d-text2)' }}>PNG, JPG ve GIF desteklenir. Video ve ses sonraki sürümde.</span>
      <input ref={ref} type="file" accept="image/*" hidden onChange={async (e) => {
        const f = e.target.files?.[0];
        if (f) onPick(await putMedia(f), f.name.replace(/\.[^.]+$/, ''));
      }} />
    </div>
  );
}

function TextTab({ onAdd }: { onAdd: (t: string) => void }) {
  const [v, setV] = useState('');
  return (
    <div style={{ display: 'flex', gap: 8 }}>
      <input className="dinput" placeholder="Yazını gir" value={v} onChange={(e) => setV(e.target.value)} onKeyDown={(e) => e.key === 'Enter' && v && onAdd(v)} autoFocus />
      <button className="btn" disabled={!v} onClick={() => onAdd(v)}>Ekle</button>
    </div>
  );
}

// ---------- CB Araçları ----------
function CBTab({ onPick, onBody, toast }: { onPick: (src: string, name: string) => void; onBody: (shape: string) => void; toast: (m: string) => void }) {
  const [which, setWhich] = useState<'ready' | 'mine'>(() => (localStorage.getItem('wm-pack-tab') as 'ready' | 'mine') || 'ready');
  const [ready, setReady] = useState<PackFolder[]>([]);
  const [folder, setFolder] = useState('Tümü');
  const [mine, setMine] = useState<UserPackItem[]>([]);
  const [myFolders, setMyFolders] = useState<string[]>([]);
  const [edit, setEdit] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);
  const refresh = () => { listUserPack().then(setMine); listUserFolders().then(setMyFolders); };
  useEffect(() => { fetch('packs/hazir/manifest.json').then((r) => r.json()).then((m) => setReady(m.folders)); refresh(); }, []);
  useEffect(() => { localStorage.setItem('wm-pack-tab', which); setFolder('Tümü'); setEdit(false); }, [which]);

  const recent = getRecent().filter((r) => r.startsWith('packs/') || mine.some((m) => m.id === r));
  const nameOf = (src: string) => ready.flatMap((f) => f.items).find((i) => i.src === src)?.name ?? mine.find((m) => m.id === src)?.name ?? '';

  const folders = which === 'ready' ? ready.map((f) => f.name) : myFolders;
  const items: { src: string; name: string; id?: string }[] = which === 'ready'
    ? ready.filter((f) => folder === 'Tümü' || f.name === folder).flatMap((f) => f.items)
    : mine.filter((m) => folder === 'Tümü' || m.folder === folder).map((m) => ({ src: m.id, name: m.name, id: m.id }));

  return (
    <div>
      <div className="seg" style={{ background: 'var(--d-panel2)', marginBottom: 12 }}>
        <button className={which === 'ready' ? 'on' : ''} style={{ color: which === 'ready' ? undefined : 'var(--d-text)' }} onClick={() => setWhich('ready')}>Hazır Pack</button>
        <button className={which === 'mine' ? 'on' : ''} style={{ color: which === 'mine' ? undefined : 'var(--d-text)' }} onClick={() => setWhich('mine')}>Yüklediğim Pack</button>
      </div>

      {recent.length > 0 && (
        <>
          <div className="sub" style={{ marginTop: 0 }}>SON KULLANILANLAR</div>
          <div className="chips" style={{ gap: 8 }}>
            {recent.map((r) => (
              <button key={r} className="thumb" style={{ width: 58, flexShrink: 0 }} aria-label={nameOf(r)} onClick={() => onPick(r, nameOf(r))}><Img src={r} alt="" /></button>
            ))}
          </div>
        </>
      )}

      <div className="chips">
        {['Tümü', ...folders].map((f) => (
          <button key={f} className={'chip' + (folder === f ? ' on' : '')} onClick={() => setFolder(f)}>{f !== 'Tümü' && <Icon name="folder" size={14} />}{f}</button>
        ))}
        {which === 'mine' && (
          <button className="chip" onClick={async () => {
            const n = await askText('Yeni klasör adı', '', 'Oluştur');
            if (n?.trim()) { await addUserFolder(n.trim()); refresh(); setFolder(n.trim()); }
          }}><Icon name="plus" size={14} />Klasör</button>
        )}
      </div>

      {which === 'ready' && (folder === 'Tümü' || folder === 'Gövdeler') && (
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 12 }}>
          {[['top', 'Top'], ['dikdortgen', 'Dikdörtgen'], ['kup', 'Küp'], ['ucgen', 'Üçgen']].map(([k, n]) => (
            <button key={k} className="btn ghost" style={{ height: 36, fontSize: 13 }} onClick={() => onBody(k)}><Icon name="ball" size={16} />{n} gövdesi kur</button>
          ))}
        </div>
      )}

      {which === 'mine' && (
        <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
          <button className="btn" onClick={() => fileRef.current?.click()}><Icon name="upload" size={18} />Galeriden PNG Yükle</button>
          {mine.length > 0 && <button className="btn ghost" onClick={() => setEdit(!edit)}>{edit ? 'Bitti' : 'Düzenle'}</button>}
          <input ref={fileRef} type="file" accept="image/png,image/*" multiple hidden onChange={async (e) => {
            const files = [...(e.target.files ?? [])];
            if (!files.length) return;
            const ask = folder !== 'Tümü' ? folder : await askText('Hangi klasöre eklensin?', 'Genel', 'Ekle');
            if (ask === null) { e.target.value = ''; return; }
            const target = ask || 'Genel';
            await addUserPackItems(files, target);
            refresh(); setFolder(target);
            toast(`${files.length} PNG "${target}" klasörüne eklendi.`);
            e.target.value = '';
          }} />
        </div>
      )}

      {which === 'mine' && !mine.length ? (
        <p style={{ color: 'var(--d-text2)', fontSize: 14 }}>Henüz kendi pack'in yok. Galeriden PNG'lerini yükle; klasörlere ayırıp burada hızlıca kullanabilirsin.</p>
      ) : (
        <div className="thumbs">
          {items.map((it) => (
            <div key={it.src}>
              <button className="thumb" style={{ width: '100%' }} aria-label={it.name} onClick={() => !edit && onPick(it.src, it.name)}>
                <Img src={it.src} alt="" />
                {edit && it.id && <span className="x" role="button" aria-label={`${it.name} sil`} onClick={async (e) => { e.stopPropagation(); await removeUserPackItem(it.id!); refresh(); }}><Icon name="close" size={14} stroke={2.4} /></span>}
              </button>
              <div className="tlabel">{it.name}</div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ---------- Bayraklar ----------
interface FlagMeta { code: string; en: string; continent: string; iso: boolean }
const CONT: Record<string, string> = { Europe: 'Avrupa', Asia: 'Asya', Africa: 'Afrika', 'North America': 'Kuzey Amerika', 'South America': 'Güney Amerika', Oceania: 'Okyanusya', Antarctica: 'Antarktika' };

function FlagsTab({ onPick, toast, replace }: { onPick: (src: string, name: string, mode: 'cb' | 'flat') => void; toast: (m: string) => void; replace: boolean }) {
  const [all, setAll] = useState<FlagMeta[]>([]);
  const [q, setQ] = useState('');
  const [cont, setCont] = useState('Tümü');
  const [mine, setMine] = useState<UserFlag[]>([]);
  const [ask, setAsk] = useState<{ src: string; name: string } | null>(null);
  const fileRef = useRef<HTMLInputElement>(null);
  useEffect(() => { fetch('flags/flags.json').then((r) => r.json()).then(setAll); listUserFlags().then(setMine); }, []);
  const dn = useMemo(() => { try { return new Intl.DisplayNames(['tr'], { type: 'region' }); } catch { return null; } }, []);
  const named = useMemo(() => all.map((f) => {
    let n = f.en;
    if (f.iso && f.code.length === 2) { try { n = dn?.of(f.code.toUpperCase()) ?? f.en; } catch { /* yok */ } }
    return { ...f, name: n };
  }).sort((a, b) => a.name.localeCompare(b.name, 'tr')), [all, dn]);
  const ql = q.toLocaleLowerCase('tr');
  const list = named.filter((f) => (cont === 'Tümü' || CONT[f.continent] === cont) && (!ql || f.name.toLocaleLowerCase('tr').includes(ql) || f.en.toLowerCase().includes(ql) || f.code === ql));
  const choose = (src: string, name: string) => (replace ? onPick(src, name, 'flat') : setAsk({ src, name }));

  return (
    <div>
      <div style={{ display: 'flex', gap: 8, marginBottom: 10 }}>
        <input className="dinput" placeholder="Bayrak ara (ör. Türkiye)" value={q} onChange={(e) => setQ(e.target.value)} />
      </div>
      <div className="chips">
        {['Tümü', ...Object.values(CONT).filter((c) => c !== 'Antarktika')].map((c) => <button key={c} className={'chip' + (cont === c ? ' on' : '')} onClick={() => setCont(c)}>{c}</button>)}
      </div>

      <div className="sub">BAYRAKLARIM</div>
      <div className="flags">
        <button className="flag" onClick={() => fileRef.current?.click()}>
          <span style={{ width: '100%', aspectRatio: '4/3', borderRadius: 4, border: '2px dashed var(--d-line)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--turq)' }}><Icon name="plus" /></span>Bayrak ekle
        </button>
        {mine.map((f) => <button key={f.id} className="flag" onClick={() => choose(f.id, f.name)}><Img src={f.id} alt="" />{f.name}</button>)}
      </div>
      <input ref={fileRef} type="file" accept="image/*" hidden onChange={async (e) => {
        const f = e.target.files?.[0];
        if (!f) return;
        const asked = await askText('Bayrağın adı', f.name.replace(/\.[^.]+$/, ''), 'Ekle');
        if (asked === null) { e.target.value = ''; return; }
        const name = asked || 'Bayrağım';
        await addUserFlag(f, name);
        setMine(await listUserFlags());
        toast(`"${name}" Bayraklarım'a eklendi.`);
        e.target.value = '';
      }} />

      <div className="sub">TÜM BAYRAKLAR · {list.length}</div>
      <div className="flags">
        {list.map((f) => <button key={f.code} className="flag" onClick={() => choose(`flags/${f.code}.svg`, f.name)}><img src={`flags/${f.code}.svg`} alt="" loading="lazy" />{f.name}</button>)}
      </div>

      {ask && (
        <div className="choice" onClick={() => setAsk(null)}>
          <div className="choice-box" onClick={(e) => e.stopPropagation()}>
            <h4>{ask.name}</h4>
            <button className="btn" onClick={() => { onPick(ask.src, ask.name, 'cb'); setAsk(null); }}><Icon name="ball" size={18} />CB olarak ekle</button>
            <span style={{ fontSize: 12, color: 'var(--d-text2)' }}>Top gövdesi kurulur: çizgi + beyaz iç + iç'e kırpılmış bayrak + gözler. Hepsi çizgiyi takip eder.</span>
            <button className="btn ghost" onClick={() => { onPick(ask.src, ask.name, 'flat'); setAsk(null); }}><Icon name="flag" size={18} />Düz bayrak olarak ekle</button>
            <button className="btn ghost" onClick={() => setAsk(null)}>Vazgeç</button>
          </div>
        </div>
      )}
    </div>
  );
}

// ---------- Taşı ve Çevir ----------
type Mode = 'move' | 'rotate' | 'scale';
const MODE_PROPS: Record<Mode, AnimProp[]> = { move: ['x', 'y'], rotate: ['rotation'], scale: ['scale'] };

export function MovePanel({ layer, onClose }: { layer: Layer; onClose: () => void }) {
  const { s, t } = useNow();
  const [mode, setMode] = useState<Mode>('move');
  const props = MODE_PROPS[mode];
  const hasKey = props.some((pr) => keyAt(layer[pr], t));
  const animated = props.some((pr) => layer[pr].k?.length);
  const drag = useRef<{ x: number; y: number; v: number[] } | null>(null);

  const set = (vals: Partial<Record<AnimProp, number>>, commit = true) =>
    s.updateLayer(layer.id, (l) => {
      const n = { ...l };
      for (const [k, v] of Object.entries(vals) as [AnimProp, number][]) n[k] = setAnim(l[k], t, v);
      return n;
    }, commit);

  const toggle = () => s.updateLayer(layer.id, (l) => {
    const n = { ...l };
    const any = props.some((pr) => keyAt(l[pr], t));
    for (const pr of props) {
      const has = !!keyAt(l[pr], t);
      if (any ? has : !has) n[pr] = toggleKey(l[pr], t);
    }
    return n;
  });

  const fields = mode === 'move'
    ? [{ k: 'x' as AnimProp, label: 'X', step: 1 }, { k: 'y' as AnimProp, label: 'Y', step: 1 }]
    : mode === 'rotate' ? [{ k: 'rotation' as AnimProp, label: 'DERECE', step: 1 }] : [{ k: 'scale' as AnimProp, label: 'ÖLÇEK %', step: 1 }];
  const show = (k: AnimProp) => { const v = valueAt(layer[k], t); return k === 'scale' ? Math.round(v * 1000) / 10 : Math.round(v * 100) / 100; };

  return (
    <div className="dpanel" role="dialog" aria-label="Taşı ve Çevir">
      <Head title="Taşı ve Çevir" onClose={onClose} back />
      <div className="movep">
        <div className="side">
          <button className="ib" aria-label={hasKey ? 'Bu anki keyframe\'i sil' : 'Bu ana keyframe ekle'} onClick={toggle} style={{ color: hasKey ? 'var(--turq)' : animated ? 'var(--d-text)' : 'var(--d-text2)' }}>
            <Icon name="key" size={22} fill={hasKey} />
          </button>
          <span style={{ fontSize: 9, color: 'var(--d-text2)', textAlign: 'center' }}>{hasKey ? 'Keyframe' : animated ? 'Animasyonlu' : 'Sabit'}</span>
        </div>
        <div className="pad"
          onPointerDown={(e) => { (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId); s.checkpoint(); drag.current = { x: e.clientX, y: e.clientY, v: props.map((pr) => valueAt(layer[pr], t)) }; }}
          onPointerMove={(e) => {
            const d = drag.current; if (!d) return;
            const dx = e.clientX - d.x, dy = e.clientY - d.y;
            if (mode === 'move') set({ x: Math.round(d.v[0] + dx * 1.5), y: Math.round(d.v[1] + dy * 1.5) }, false);
            else if (mode === 'rotate') set({ rotation: Math.round(d.v[0] + dx * 0.6) }, false);
            else set({ scale: Math.max(0.01, Math.round((d.v[0] + dx * 0.005) * 1000) / 1000) }, false);
          }}
          onPointerUp={() => { drag.current = null; }}>
          <div className="vals" onPointerDown={(e) => e.stopPropagation()}>
            {fields.map((f) => (
              <label key={f.k} className="val">
                <input className={animated ? '' : 'nk'} type="number" step={f.step} value={show(f.k)} onChange={(e) => {
                  const v = parseFloat(e.target.value.replace(',', '.'));
                  if (!Number.isNaN(v)) set({ [f.k]: f.k === 'scale' ? v / 100 : v });
                }} />{f.label}
              </label>
            ))}
          </div>
          <div className="padhint">{mode === 'move' ? 'Katmanı taşımak için buraya kaydırın' : mode === 'rotate' ? 'Döndürmek için sağa-sola kaydırın' : 'Ölçeklemek için sağa-sola kaydırın'}</div>
        </div>
        <div className="side">
          {([['move', 'move', 'Taşı'], ['rotate', 'rotate', 'Döndür'], ['scale', 'scale', 'Ölçek']] as [Mode, string, string][]).map(([m, ic, lb]) => (
            <button key={m} className={'ib' + (mode === m ? ' on' : '')} aria-label={lb} aria-pressed={mode === m} onClick={() => setMode(m)}><Icon name={ic} size={24} /></button>
          ))}
        </div>
      </div>
    </div>
  );
}

// ---------- Renk ----------
const SWATCHES = ['#8F7CF0', '#2F7BF6', '#22D3C5', '#3FD0F0', '#E8333F', '#FF8A1F', '#F2C230', '#2DBE60', '#0D1631', '#FFFFFF', '#000000', '#9AA6B8'];
export function ColorPanel({ layer, onClose }: { layer: Layer; onClose: () => void }) {
  const { s } = useNow();
  return (
    <div className="dpanel" role="dialog" aria-label="Renk ve Dolgu">
      <Head title="Renk ve Dolgu" onClose={onClose} back />
      <div className="dbody">
        <div className="swatches">
          {SWATCHES.map((c) => <button key={c} aria-label={c} className={layer.fill.toUpperCase() === c ? 'on' : ''} style={{ background: c }} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, fill: c }))} />)}
        </div>
        <label className="prop" style={{ marginTop: 16 }}><span className="top">Özel renk<input type="color" value={layer.fill} onFocus={() => s.checkpoint()} onChange={(e) => s.updateLayer(layer.id, (l) => ({ ...l, fill: e.target.value }), false)} /></span></label>
      </div>
    </div>
  );
}

// ---------- Opaklık ----------
export function OpacityPanel({ layer, onClose }: { layer: Layer; onClose: () => void }) {
  const { s, t } = useNow();
  const v = valueAt(layer.opacity, t);
  const has = !!keyAt(layer.opacity, t);
  return (
    <div className="dpanel" role="dialog" aria-label="Karıştırma ve Opaklık">
      <Head title="Karıştırma ve Opaklık" onClose={onClose} back />
      <div className="dbody">
        <div className="prop">
          <span className="top">Opaklık<b>%{Math.round(v * 100)}</b></span>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <button className="ib" aria-label="Opaklık keyframe" onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, opacity: toggleKey(l.opacity, t) }))} style={{ color: has ? 'var(--turq)' : 'var(--d-text2)' }}><Icon name="key" fill={has} /></button>
            <input className="slider" type="range" min={0} max={100} value={Math.round(v * 100)} onPointerDown={() => s.checkpoint()} onChange={(e) => s.updateLayer(layer.id, (l) => ({ ...l, opacity: setAnim(l.opacity, t, +e.target.value / 100) }), false)} />
          </div>
        </div>
        <p style={{ fontSize: 12, color: 'var(--d-text2)' }}>İpucu: ◆ ile iki farklı anda keyframe koyarak "belirme / kaybolma" animasyonu yapabilirsin.</p>
      </div>
    </div>
  );
}

// ---------- Efektler ----------
const FX: { type: Effect['type']; name: string; make: () => Effect }[] = [
  { type: 'blur', name: 'Gauss Bulanıklığı', make: () => ({ id: uid(), type: 'blur', amount: 8 }) },
  { type: 'sway', name: 'Oto-Sallanma', make: () => ({ id: uid(), type: 'sway', amount: 6, speed: 0.8 }) },
  { type: 'shake', name: 'Rastgele Titreşim', make: () => ({ id: uid(), type: 'shake', amount: 8, speed: 1.5 }) },
  { type: 'glow', name: 'Parlama', make: () => ({ id: uid(), type: 'glow', amount: 16, color: '#3FD0F0' }) },
];

export function EffectsPanel({ layer, onClose }: { layer: Layer; onClose: () => void }) {
  const { s } = useNow();
  const upd = (id: string, patch: Partial<Effect>, commit = false) =>
    s.updateLayer(layer.id, (l) => ({ ...l, effects: l.effects.map((e) => (e.id === id ? ({ ...e, ...patch } as Effect) : e)) }), commit);
  return (
    <div className="dpanel" role="dialog" aria-label="Efektler">
      <Head title="Efektler" onClose={onClose} back />
      <div className="dbody">
        {layer.effects.map((e) => {
          const meta = FX.find((f) => f.type === e.type)!;
          return (
            <div key={e.id} className="fx" style={{ flexDirection: 'column', alignItems: 'stretch' }}>
              <div style={{ display: 'flex', alignItems: 'center' }}>
                <span className="n">{meta.name}</span>
                <button className="ib" aria-label={`${meta.name} kaldır`} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, effects: l.effects.filter((x) => x.id !== e.id) }))}><Icon name="trash" size={18} /></button>
              </div>
              <label className="prop"><span className="top">{e.type === 'sway' ? 'Açı (°)' : e.type === 'blur' || e.type === 'glow' ? 'Miktar' : 'Mesafe'}<b>{e.amount}</b></span>
                <input className="slider" type="range" min={0} max={e.type === 'sway' ? 45 : 60} value={e.amount} onPointerDown={() => s.checkpoint()} onChange={(ev) => upd(e.id, { amount: +ev.target.value })} /></label>
              {(e.type === 'sway' || e.type === 'shake') && (
                <label className="prop"><span className="top">Hız<b>{e.speed}</b></span>
                  <input className="slider" type="range" min={0.1} max={5} step={0.1} value={e.speed} onPointerDown={() => s.checkpoint()} onChange={(ev) => upd(e.id, { speed: +ev.target.value })} /></label>
              )}
              {e.type === 'glow' && <label className="prop"><span className="top">Renk<input type="color" value={e.color} onChange={(ev) => upd(e.id, { color: ev.target.value })} /></span></label>}
            </div>
          );
        })}
        <div className="sub">EFEKT EKLE</div>
        <div className="fx-grid">
          {FX.map((f) => (
            <button key={f.type} className="fx-card" onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, effects: [...l.effects, f.make()] }))}>
              <Icon name="sparkle" size={26} />{f.name}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

// ---------- Metin ----------
export function TextPanel({ layer, onClose }: { layer: Layer; onClose: () => void }) {
  const { s } = useNow();
  return (
    <div className="dpanel" role="dialog" aria-label="Metni Düzenle">
      <Head title="Metni Düzenle" onClose={onClose} back />
      <div className="dbody">
        <textarea className="dinput" style={{ height: 80, padding: 10 }} value={layer.text} onFocus={() => s.checkpoint()} onChange={(e) => s.updateLayer(layer.id, (l) => ({ ...l, text: e.target.value }), false)} />
        <label className="prop" style={{ marginTop: 12 }}><span className="top">Yazı boyutu<b>{layer.fontSize}</b></span>
          <input className="slider" type="range" min={12} max={300} value={layer.fontSize} onPointerDown={() => s.checkpoint()} onChange={(e) => s.updateLayer(layer.id, (l) => ({ ...l, fontSize: +e.target.value, h: Math.round(+e.target.value * 1.3) }), false)} /></label>
        <div className="swatches">
          {SWATCHES.map((c) => <button key={c} aria-label={c} className={layer.fill.toUpperCase() === c ? 'on' : ''} style={{ background: c }} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, fill: c }))} />)}
        </div>
      </div>
    </div>
  );
}

// ---------- CB katmanı ayarları (şablondaki tek parça CB için) ----------
export function CBPanel({ layer, onClose, onChangeFlag }: { layer: Layer; onClose: () => void; onChangeFlag: () => void }) {
  const { s } = useNow();
  const [eyes, setEyes] = useState<{ name: string; src: string }[]>([]);
  useEffect(() => { fetch('packs/hazir/manifest.json').then((r) => r.json()).then((m) => setEyes(m.folders.find((f: PackFolder) => f.name === 'Gözler')?.items ?? [])); }, []);
  return (
    <div className="dpanel" role="dialog" aria-label="CB Ayarları">
      <Head title="CB Ayarları" onClose={onClose} back />
      <div className="dbody">
        <button className="btn ghost" onClick={onChangeFlag}><Icon name="flag" size={18} />Bayrağı Değiştir</button>
        <label className="prop" style={{ marginTop: 14 }}><span className="top">Kontur kalınlığı<b>{layer.cb?.outline ?? 0}</b></span>
          <input className="slider" type="range" min={0} max={30} value={layer.cb?.outline ?? 0} onPointerDown={() => s.checkpoint()} onChange={(e) => s.updateLayer(layer.id, (l) => ({ ...l, cb: { ...l.cb, outline: +e.target.value } }), false)} /></label>
        <div className="sub">GÖZLER</div>
        <div className="thumbs">
          <div><button className="thumb" style={{ width: '100%', color: '#56657E' }} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, cb: { outline: l.cb?.outline ?? 6, eyes: undefined } }))}>Yok</button></div>
          {eyes.map((e) => (
            <div key={e.src}>
              <button className="thumb" style={{ width: '100%', outline: layer.cb?.eyes === e.src ? '2px solid var(--turq)' : undefined }} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, cb: { outline: l.cb?.outline ?? 6, eyes: e.src } }))}><img src={e.src} alt="" /></button>
              <div className="tlabel">{e.name}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
