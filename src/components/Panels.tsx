import { useEffect, useMemo, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { Icon } from './Icon';
import { EASES, keyAt, segmentKey, setAnim, setEase, toggleKey, uid, valueAt } from '../anim';
import { addUserFlag, addUserFolder, addUserPackItems, listUserFlags, listUserFolders, listUserPack, putMedia, removeUserPackItem, type UserFlag, type UserPackItem } from '../db';
import { cbBodyLayers, makeLayer, SHAPES } from '../factories';
import { resolveSrc } from '../render';
import { addVertex, fillShape, regularPts, SHAPE_PARAMS, sp as shapeParam } from '../shapes';
import { useStore } from '../store';
import { askText } from '../dialog';
import { errText, Gallery, galleryNative, type GItem, pickInto, pickMedia, readItem } from '../gallery';
import { AudioCard, stopListen, toggleListen, useListening } from './AudioCard';
import { AlbumMenu, albumLabel, listAlbum, Tile } from './MediaSheet';
import { FEATURED, FX, FX_CATS, fxMeta, fxVal, makeEffect, paramKeys, type FxParam } from '../effects';
import type { AnimProp, Effect, FxType, Layer, Project, ShapeKind } from '../types';

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
  return url ? <img src={url} alt={alt} loading="lazy" decoding="async" draggable={false} /> : null;
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


// ---------- Sayfalı ızgara: parmakla sağa-sola kaydırılır, altta sayfa noktaları ----------
function Pager<T>({ items, cols, rows = 2, render, keyOf, empty }: { items: T[]; cols: number; rows?: number; render: (it: T) => React.ReactNode; keyOf: (it: T) => string; empty?: React.ReactNode }) {
  const ref = useRef<HTMLDivElement>(null);
  const [page, setPage] = useState(0);
  const per = cols * rows;
  const pages: T[][] = [];
  for (let i = 0; i < items.length; i += per) pages.push(items.slice(i, i + per));
  const sig = items.length + ':' + (items[0] ? keyOf(items[0]) : '');
  useEffect(() => { ref.current?.scrollTo({ left: 0 }); setPage(0); }, [sig]);
  if (!items.length) return <>{empty}</>;
  const go = (i: number) => ref.current?.scrollTo({ left: i * ref.current.clientWidth, behavior: 'smooth' });
  return (
    <div>
      <div className="pager" ref={ref} onScroll={(e) => { const el = e.currentTarget; setPage(Math.round(el.scrollLeft / Math.max(1, el.clientWidth))); }}>
        {pages.map((pg, i) => (
          <div className="page" key={i} style={{ gridTemplateColumns: `repeat(${cols}, minmax(0, 1fr))` }} aria-label={`Sayfa ${i + 1}/${pages.length}`}>
            {pg.map((it) => <div key={keyOf(it)} style={{ minWidth: 0 }}>{render(it)}</div>)}
          </div>
        ))}
      </div>
      {pages.length > 1 && pages.length <= 8 && (
        <div className="dots">
          {pages.map((_, i) => <button key={i} aria-label={`Sayfa ${i + 1}`} aria-current={i === page} onClick={() => go(i)}><span className={i === page ? 'on' : ''} /></button>)}
          <span className="pcount">{page + 1}/{pages.length}</span>
        </div>
      )}
      {pages.length > 8 && (
        <div className="dots">
          <button aria-label="Önceki sayfa" disabled={page === 0} onClick={() => go(page - 1)} style={{ width: 44, color: 'var(--d-text)' }}><Icon name="back" size={18} /></button>
          <span style={{ fontSize: 12, color: 'var(--d-text2)', minWidth: 56, textAlign: 'center' }}>{page + 1} / {pages.length}</span>
          <button aria-label="Sonraki sayfa" disabled={page === pages.length - 1} onClick={() => go(page + 1)} style={{ width: 44, color: 'var(--d-text)', transform: 'scaleX(-1)' }}><Icon name="back" size={18} /></button>
        </div>
      )}
    </div>
  );
}

// ---------- Ekle paneli ----------
export type AddTab = 'shape' | 'media' | 'audio' | 'text' | 'cb' | 'flags';

interface PackPart { name: string; src: string; back?: boolean; parent?: number }
interface PackItem { name: string; src: string; id?: string; parts?: PackPart[]; root?: number }
interface PackFolder { name: string; items: PackItem[] }

export function AddPanel({ tab, setTab, onClose, toast, replaceFlagOf }: { tab: AddTab | null; setTab: (t: AddTab) => void; onClose: () => void; toast: (m: string) => void; replaceFlagOf: string | null }) {
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

  const addVideo = async (src: string, name: string) => {
    const url = await resolveSrc(src);
    const meta = await new Promise<{ w: number; h: number; d: number }>((res) => {
      const v = document.createElement('video');
      v.preload = 'metadata'; v.muted = true;
      v.onloadedmetadata = () => res({ w: v.videoWidth || 640, h: v.videoHeight || 360, d: isFinite(v.duration) ? v.duration : 5 });
      v.onerror = () => res({ w: 640, h: 360, d: 5 });
      v.src = url;
    });
    const k = Math.min(p.width / meta.w, p.height / meta.h); // proje alanına sığdır
    s.addLayer(makeLayer(p, t, Math.round(meta.d * 100) / 100, { type: 'video', name, src, w: Math.round(meta.w * k), h: Math.round(meta.h * k) }));
    onClose();
  };

  const addAudio = async (src: string, name: string) => {
    const url = await resolveSrc(src);
    const d = await new Promise<number>((res) => {
      const a = document.createElement('audio');
      a.preload = 'metadata';
      a.onloadedmetadata = () => res(isFinite(a.duration) && a.duration > 0 ? a.duration : 5);
      a.onerror = () => res(5);
      a.src = url;
    });
    s.addLayer(makeLayer(p, t, Math.round(d * 100) / 100, { type: 'audio', name, src, w: 0, h: 0, fill: '#2FAE8E' }));
    toast(`"${name}" eklendi. Oynatınca duyulur, dışa aktarınca videoya eklenir.`);
    onClose();
  };

  /**
   * Çok parçalı pack öğesi (ör. WardenCB pozu, ushanka): projeye bütün gibi gelir ama her parça ayrı katmandır.
   * Kök parça dışındakiler kökü takip eder. "back" parçalar (ushankanın arka kulağı) en üstteki CB gövdesinin arkasına konur.
   */
  const addParts = async (it: PackItem) => {
    const parts = it.parts!, root = it.root ?? 0;
    const { w, h } = await loadSize(parts[root].src);
    const k = Math.min(p.width, p.height) * (it.src.includes('wardencb/') ? 0.6 : 0.45) / Math.max(w, h);
    const ids = parts.map(() => uid());
    const made: Layer[] = parts.map((pt, i) => ({
      ...makeLayer(p, t, dur, { type: 'image', name: `${it.name} ${pt.name}`, src: pt.src, w: Math.round(w * k), h: Math.round(h * k) }),
      id: ids[i], ...(i === root ? {} : { parent: ids[pt.parent ?? root], x: { v: 0 }, y: { v: 0 } }),
    }));
    s.update((pp) => {
      const layers = [...pp.layers];
      const backs = made.filter((_, i) => parts[i].back), rest = made.filter((_, i) => !parts[i].back);
      // Arka parçalar: en üstteki gövdenin (ebeveyni olmayan CB/gövde çizgisi ve onu takip edenler) en altına
      let at = layers.length;
      if (backs.length) {
        const isBody = (l: Layer) => !l.parent && (l.type === 'cb' || /govdeler\//.test(l.src ?? '') || layers.some((c) => c.parent === l.id));
        const body = [...layers].reverse().find(isBody);
        if (body) {
          const fam = new Set([body.id]);
          for (let ch = true; ch;) { ch = false; for (const l of layers) if (l.parent && fam.has(l.parent) && !fam.has(l.id)) { fam.add(l.id); ch = true; } }
          at = layers.findIndex((l) => fam.has(l.id));
          // Ushanka basık gövdeye konuyorsa ölçüp tam yerine oturt (gövde tuvali 400, ushanka tuvali 516 birim)
          if (/govdeler\/wardencb-cizgi/.test(body.src ?? '') && /ushanka/.test(it.src)) {
            const u = body.w / 400, r = made[root];
            r.w = Math.round(516 * u); r.h = Math.round(416 * u);
            r.x = { v: Math.round(valueAt(body.x, t) + 28 * u) }; r.y = { v: Math.round(valueAt(body.y, t) - 26 * u) };
            r.scale = { v: valueAt(body.scale, t) };
            for (const b of backs) { b.w = r.w; b.h = r.h; }
          }
        }
      }
      layers.splice(at, 0, ...backs);
      return { ...pp, layers: [...layers, ...rest] };
    });
    s.select(ids[root]);
    pushRecent(it.src);
    toast(`${it.name}: ${parts.length} ayrı katman olarak eklendi${parts.some((x) => x.back) ? ' (arka kulak CB\'nin arkasında)' : ''}.`);
    onClose();
  };

  /** Gövde kur: çizgi (ebeveyn) + beyaz iç (takip eder) [+ bayrak iç'e kırpılmış] [+ gözler] */
  const buildBody = (shape: string, flagSrc?: string, flagName?: string) => {
    const { layers: made, rootId: lineId } = cbBodyLayers(p, t, dur, shape, flagSrc, flagName);
    s.update((pp) => ({ ...pp, layers: [...pp.layers, ...made] }));
    s.select(lineId);
    toast(flagSrc ? 'CB hazır: çizgiyi taşıyınca hepsi birlikte hareket eder.' : 'Gövde kuruldu: iç, çizgiyi takip ediyor.');
    onClose();
  };

  const tabs: { id: AddTab; label: string; icon: string }[] = [
    { id: 'shape', label: 'Şekil', icon: 'shapes' }, { id: 'media', label: 'Medya', icon: 'image' }, { id: 'audio', label: 'Ses', icon: 'music' },
    { id: 'text', label: 'Metin', icon: 'text' }, { id: 'cb', label: 'CB', icon: 'ball' }, { id: 'flags', label: 'Bayrak', icon: 'flag' },
  ];

  return (
    <div className="addcard" role="dialog" aria-label="Katman ekle">
      {replaceFlagOf ? (
        <div className="addtabs"><span style={{ flex: 1, fontWeight: 700, padding: '0 10px' }}>Bayrağı Değiştir</span>
          <button className="ib" aria-label="Kapat" onClick={onClose}><Icon name="close" size={20} stroke={2.2} /></button></div>
      ) : (
        <div className="addtabs" role="tablist">
          {tabs.map((x) => (
            <button key={x.id} role="tab" aria-selected={tab === x.id} className={'atab' + (tab === x.id ? ' on' : '')} onClick={() => setTab(x.id)}>
              <Icon name={x.icon} size={22} />{x.label}
            </button>
          ))}
          <button className="ib" aria-label="Kapat" onClick={onClose}><Icon name="close" size={20} stroke={2.2} /></button>
        </div>
      )}
      {tab && <div className="addbody">
        {tab === 'shape' && (
          <Pager items={SHAPES} cols={7} keyOf={(sh) => sh.kind} render={(sh) => (
            <button className="cell" aria-label={sh.name} onClick={() => { s.addLayer(makeLayer(p, t, dur, { type: 'shape', name: sh.name, shape: sh.kind, w: sh.w ?? 240, h: sh.h ?? 240, ...(sh.sp ? { sp: sh.sp } : {}), ...(sh.pts ? { pts: sh.pts } : {}) })); onClose(); }}>
              <ShapeIcon kind={sh.kind} pts={sh.pts} />
            </button>
          )} />
        )}
        {tab === 'media' && <MediaTab toast={toast} onAudio={() => setTab('audio')} onPick={(src, name, kind) => (kind === 'video' ? addVideo(src, name) : addImage(src, name, 0.7))} />}
        {tab === 'audio' && <AudioTab onPick={addAudio} toast={toast} />}
        {tab === 'text' && <TextTab onAdd={(text) => { s.addLayer(makeLayer(p, t, dur, { type: 'text', name: text.slice(0, 18) || 'Metin', text, fontSize: Math.round(p.height / 12), fill: '#0D1631', w: Math.round(p.width * 0.6), h: Math.round(p.height / 8) })); onClose(); }} />}
        {tab === 'cb' && <CBTab onPick={(it) => (it.parts ? addParts(it) : addImage(it.src, it.name))} onBody={(shape) => buildBody(shape)} toast={toast} />}
        {tab === 'flags' && (
          <FlagsTab
            replace={!!replaceFlagOf}
            onPick={(src, name, mode) => {
              if (replaceFlagOf) { s.updateLayer(replaceFlagOf, (l) => ({ ...l, src })); onClose(); return; }
              if (mode !== 'flat') buildBody(mode === 'cbsoft' ? 'yumusak-top' : mode === 'cbwarden' ? 'wardencb' : 'top', src, name);
              else addImage(src, `${name} Bayrağı`, 0.6);
            }}
            toast={toast}
          />
        )}
      </div>}
    </div>
  );
}

function ShapeIcon({ kind, pts }: { kind: ShapeKind; pts?: [number, number][] }) {
  const ref = useRef<HTMLCanvasElement>(null);
  useEffect(() => {
    const c = ref.current!; c.width = 80; c.height = 80;
    const x = c.getContext('2d')!;
    x.translate(40, 40); x.fillStyle = '#B9C6DC';
    fillShape(x, { shape: kind, w: kind === 'bar' ? 64 : 58, h: kind === 'bar' ? 14 : 56, pts });
  }, [kind]);
  return <canvas ref={ref} style={{ width: 40, height: 40 }} />;
}

const MEDIA_RECENT = 'wm-media-recent';
type RecentMedia = { src: string; kind: 'image' | 'video'; name: string };
const getRecentMedia = (): RecentMedia[] => { try { return JSON.parse(localStorage.getItem(MEDIA_RECENT) || '[]'); } catch { return []; } };
const pushRecentMedia = (m: RecentMedia) => { try { localStorage.setItem(MEDIA_RECENT, JSON.stringify([m, ...getRecentMedia().filter((x) => x.src !== m.src)].slice(0, 20))); } catch { /* yok */ } };

/** Medya sekmesi: telefonda galeri burada açılır (solda Tümünü görüntüle + albüm); tarayıcıda son eklenenler şeridi */
function MediaTab({ onPick, onAudio, toast }: { onPick: (src: string, name: string, kind: 'image' | 'video') => void; onAudio: () => void; toast: (m: string) => void }) {
  const ref = useRef<HTMLInputElement>(null);
  const [recent] = useState(getRecentMedia);
  const native = galleryNative();
  const [access, setAccess] = useState<'loading' | 'ok' | 'none'>('loading');
  const [items, setItems] = useState<GItem[]>([]);
  const [albums, setAlbums] = useState<{ name: string; count: number }[]>([]);
  const [album, setAlbum] = useState('');
  const [albMenu, setAlbMenu] = useState<DOMRect | null>(null);
  const [busy, setBusy] = useState(false);
  const gridRef = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!native) return;
    Gallery.status().then((st) => { setAccess(st.access === 'none' ? 'none' : 'ok'); if (st.access !== 'none') Gallery.albums().then((r) => setAlbums(r.albums)).catch(() => {}); }).catch(() => setAccess('none'));
  }, []);
  useEffect(() => {
    if (native && access === 'ok') listAlbum('any', album, 0, 90).then((r) => setItems(r.items)).catch(() => setItems([]));
  }, [access, album]);
  const pickFile = async (f: File) => {
    const kind = f.type.startsWith('video/') ? 'video' : 'image';
    const src = await putMedia(f);
    const name = f.name.replace(/\.[^.]+$/, '');
    pushRecentMedia({ src, kind, name });
    onPick(src, name, kind);
  };
  const pickFiles = async (fs: File[]) => { setBusy(true); try { for (const f of fs) await pickFile(f); } finally { setBusy(false); } };
  const all = async () => { const fs = await pickMedia({ kind: 'any', multiple: true, title: 'Görsel ya da video ekle' }); if (fs.length) pickFiles(fs); };
  const fromGallery = async (it: GItem) => { if (busy) return; setBusy(true); try { await pickFile(await readItem(it)); } catch (e) { toast('Dosya okunamadı: ' + errText(e)); } setBusy(false); };

  if (native && access !== 'loading') return (
    <div className={'mediatab gal' + (busy ? ' busy' : '')}>
      <div className="mg-grid" ref={gridRef}>
        {/* İlk kare ikiye bölünür: üst yarı bütün galeriyi açar, alt yarı klasör listesini */}
        <div className="mg-first">
          <button className="mg-all" aria-label="Tümünü görüntüle" onClick={all}><Icon name="apps" size={22} /></button>
          {access === 'ok' && <button className="mg-alb" aria-haspopup="listbox" onClick={(e) => setAlbMenu(albMenu ? null : e.currentTarget.getBoundingClientRect())}><span>{albumLabel(album, false)}</span><Icon name="chevD" size={14} /></button>}
        </div>
        {access === 'ok'
          ? items.map((it) => <Tile key={it.uri ?? (it.video ? 'v' : 'i') + it.id} it={it} on={0} root={gridRef.current} onPick={() => fromGallery(it)} />)
          : (
            <div className="audperm mg-perm">
              <span>Projende görsel ve video kullanmak için galerine erişim gerekir.</span>
              <button className="audperm-btn" onClick={() => Gallery.request().then((st) => { setAccess(st.access === 'none' ? 'none' : 'ok'); if (st.access !== 'none') Gallery.albums().then((r) => setAlbums(r.albums)).catch(() => {}); })}>ERİŞİME İZİN VER</button>
            </div>
          )}
      </div>
      {albMenu && createPortal(
        // Telefondaki bütün klasörler: tuvalin üstüne doğru açılır, kaydırılabilir
        <div className="mg-scrim" onClick={() => setAlbMenu(null)}>
          <AlbumMenu albums={albums} album={album} audio={false} className="mg-menu" style={{ left: 8, bottom: innerHeight - albMenu.top + 6, maxHeight: Math.max(160, albMenu.top - 70) }} onPick={(x) => { setAlbum(x); setAlbMenu(null); }} />
        </div>, document.body)}
    </div>
  );
  return (
    <div className="mediatab">
      <div className="mcol">
        <button className="ib on" aria-label="Görsel ve video"><Icon name="image" size={20} /></button>
        <button className="ib" aria-label="Ses" onClick={onAudio}><Icon name="music" size={20} /></button>
      </div>
      <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 6 }}>
        <div className="mstrip">
          <button className="mthumb add" aria-label="Galeriden seç" onClick={all}><Icon name="plus" size={24} /></button>
          {recent.map((m) => (
            <button key={m.src} className="mthumb" aria-label={m.name} onClick={() => onPick(m.src, m.name, m.kind)}>
              {m.kind === 'video' ? <span className="vbadge"><Icon name="play" size={12} /></span> : null}
              {m.kind === 'image' ? <Img src={m.src} alt="" /> : <VideoThumb src={m.src} />}
            </button>
          ))}
        </div>
        <button className="mall" onClick={all}><Icon name="grid" size={16} />Tüm fotoğraf ve videoları görüntüle</button>
      </div>
      <input ref={ref} type="file" accept="image/*,video/*" multiple hidden onChange={async (e) => { const fs = [...(e.target.files ?? [])]; e.target.value = ''; if (fs.length) await pickFiles(fs); }} />
    </div>
  );
}

const AUDIO_RECENT = 'wm-audio-recent';
type RecentAudio = { src: string; name: string; dur: number };
const getRecentAudio = (): RecentAudio[] => { try { return JSON.parse(localStorage.getItem(AUDIO_RECENT) || '[]'); } catch { return []; } };
const pushRecentAudio = (m: RecentAudio) => { try { localStorage.setItem(AUDIO_RECENT, JSON.stringify([m, ...getRecentAudio().filter((x) => x.src !== m.src)].slice(0, 12))); } catch { /* yok */ } };
const fileDur = (f: Blob) => new Promise<number>((res) => {
  const a = document.createElement('audio'), u = URL.createObjectURL(f);
  a.preload = 'metadata';
  a.onloadedmetadata = () => { res(isFinite(a.duration) ? a.duration : 0); URL.revokeObjectURL(u); };
  a.onerror = () => { res(0); URL.revokeObjectURL(u); };
  a.src = u;
});

/** Ses sekmesi: telefondaki sesler kart kart (basınca dinlenir, + ile eklenir); en başta "Tümünü görüntüle" */
function AudioTab({ onPick, toast }: { onPick: (src: string, name: string) => void; toast: (m: string) => void }) {
  const native = galleryNative();
  const [access, setAccess] = useState<'loading' | 'ok' | 'none'>(native ? 'loading' : 'ok');
  const [items, setItems] = useState<GItem[]>([]);
  const [recent] = useState(getRecentAudio);
  const [busy, setBusy] = useState(false);
  const listening = useListening();
  const files = useRef(new Map<number, File>());
  useEffect(() => {
    if (!native) return;
    Gallery.audioStatus().then((r) => setAccess(r.ok ? 'ok' : 'none')).catch(() => setAccess('none'));
  }, []);
  useEffect(() => {
    if (native && access === 'ok') Gallery.audioList({ offset: 0, limit: 15 }).then((r) => setItems(r.items)).catch(() => {});
  }, [access]);
  useEffect(() => () => stopListen(), []);
  const fileOf = async (it: GItem) => { let f = files.current.get(it.id); if (!f) { f = await readItem(it); files.current.set(it.id, f); } return f; };
  const useFile = async (f: File) => {
    const name = f.name.replace(/\.[^.]+$/, '') || 'Ses';
    const [src, dur] = await Promise.all([putMedia(f), fileDur(f)]);
    pushRecentAudio({ src, name, dur });
    onPick(src, name);
  };
  const fromDevice = async (it: GItem) => {
    if (busy) return;
    setBusy(true);
    try { await useFile(await fileOf(it)); } catch (e) { toast('Ses dosyası okunamadı: ' + errText(e)); }
    setBusy(false);
  };
  const all = async () => {
    stopListen();
    const fs = await pickMedia({ kind: 'audio', title: 'Sesler' });
    if (fs[0]) { setBusy(true); try { await useFile(fs[0]); } catch { toast('Ses dosyası okunamadı.'); } setBusy(false); }
  };
  if (access === 'none') return (
    <div className="audperm">
      <span>Projende müzik ve ses kullanmak için seslerine erişim gerekir.</span>
      <button className="audperm-btn" onClick={() => Gallery.audioRequest().then((r) => { setAccess(r.ok ? 'ok' : 'none'); if (!r.ok) toast('İzin verilmedi. İstersen "Dosyalardan seç" ile ekleyebilirsin.'); })}>ERİŞİME İZİN VER</button>
      <button className="audperm-link" onClick={all}>Dosyalardan seç</button>
    </div>
  );
  const seen = new Set(recent.map((r) => r.name));
  return (
    <div className={'audgrid' + (busy ? ' busy' : '')}>
      <button className="acard all" onClick={all}><Icon name="apps" size={26} />Tümünü görüntüle</button>
      {recent.map((r) => <AudioCard key={r.src} name={r.name} dur={r.dur} recent playing={listening === r.src}
        onListen={() => toggleListen(r.src, () => resolveSrc(r.src))} onAdd={() => onPick(r.src, r.name)} />)}
      {items.filter((it) => !seen.has(it.name.replace(/\.[^.]+$/, ''))).map((it) => <AudioCard key={it.id} name={it.name} dur={it.duration / 1000} playing={listening === 'g' + it.id}
        onListen={() => toggleListen('g' + it.id, async () => { try { return URL.createObjectURL(await fileOf(it)); } catch (e) { toast('Ses açılamadı: ' + errText(e)); throw e; } })} onAdd={() => fromDevice(it)} />)}
      {access === 'loading' && <span className="audnote">Yükleniyor…</span>}
      {!native && !recent.length && <span className="audnote">Karta basınca dinlersin, altındaki + ile projeye eklersin. MP3, WAV, M4A, OGG… Videoların kendi sesini katmanın "Ses Düzeyi" bölümünden ayarlarsın.</span>}
    </div>
  );
}

function VideoThumb({ src }: { src: string }) {
  const [url, setUrl] = useState('');
  useEffect(() => { resolveSrc(src).then(setUrl); }, [src]);
  return url ? <video src={url + '#t=0.1'} muted playsInline preload="metadata" /> : null;
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
function CBTab({ onPick, onBody, toast }: { onPick: (it: PackItem) => void; onBody: (shape: string) => void; toast: (m: string) => void }) {
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
  const itemOf = (src: string): PackItem => ready.flatMap((f) => f.items).find((i) => i.src === src) ?? { src, name: mine.find((m) => m.id === src)?.name ?? '' };

  const folders = which === 'ready' ? ready.map((f) => f.name) : myFolders;
  const shown: PackItem[] = folder === 'Son'
    ? recent.map(itemOf)
    : which === 'ready'
      ? ready.filter((f) => folder === 'Tümü' || f.name === folder).flatMap((f) => f.items)
      : mine.filter((m) => folder === 'Tümü' || m.folder === folder).map((m) => ({ src: m.id, name: m.name, id: m.id }));

  return (
    <div>
      <div className="seg" style={{ background: 'var(--d-panel2)', marginBottom: 8 }}>
        <button className={which === 'ready' ? 'on' : ''} style={{ color: which === 'ready' ? undefined : 'var(--d-text)' }} onClick={() => setWhich('ready')}>Hazır Pack</button>
        <button className={which === 'mine' ? 'on' : ''} style={{ color: which === 'mine' ? undefined : 'var(--d-text)' }} onClick={() => setWhich('mine')}>Yüklediğim Pack</button>
      </div>

      <div className="chips">
        {recent.length > 0 && <button className={'chip' + (folder === 'Son' ? ' on' : '')} onClick={() => setFolder('Son')}><Icon name="undo" size={14} />Son kullanılanlar</button>}
        {['Tümü', ...folders].map((f) => (
          <button key={f} className={'chip' + (folder === f ? ' on' : '')} onClick={() => setFolder(f)}>{f !== 'Tümü' && <Icon name="folder" size={14} />}{f}</button>
        ))}
        {which === 'mine' && (
          <>
            <button className="chip" onClick={async () => {
              const n = await askText('Yeni klasör adı', '', 'Oluştur');
              if (n?.trim()) { await addUserFolder(n.trim()); refresh(); setFolder(n.trim()); }
            }}><Icon name="plus" size={14} />Klasör</button>
            {mine.length > 0 && <button className={'chip' + (edit ? ' on' : '')} onClick={() => setEdit(!edit)}>{edit ? 'Bitti' : 'Düzenle'}</button>}
          </>
        )}
      </div>

      {which === 'ready' && folder === 'Gövdeler' && (
        <div className="chips">
          {[['wardencb', 'Basık top'], ['yumusak-top', 'Yumuşak top'], ['yumusak-kup', 'Yumuşak küp'], ['top', 'Top'], ['dikdortgen', 'Dikdörtgen'], ['kup', 'Küp'], ['ucgen', 'Üçgen']].map(([k, n]) => (
            <button key={k} className="chip" style={{ color: 'var(--turq)' }} onClick={() => onBody(k)}><Icon name="ball" size={14} />{n} gövdesi kur</button>
          ))}
        </div>
      )}

      <input ref={fileRef} type="file" accept="image/png,image/*" multiple hidden onChange={async (e) => {
        const files = [...(e.target.files ?? [])];
        if (!files.length) return;
        const ask = folder !== 'Tümü' && folder !== 'Son' ? folder : await askText('Hangi klasöre eklensin?', 'Genel', 'Ekle');
        if (ask === null) { e.target.value = ''; return; }
        const target = ask || 'Genel';
        await addUserPackItems(files, target);
        refresh(); setFolder(target);
        toast(`${files.length} PNG "${target}" klasörüne eklendi.`);
        e.target.value = '';
      }} />

      <Pager
        items={which === 'mine' ? [{ src: '__upload', name: 'PNG Yükle' }, ...shown] : shown}
        cols={5}
        keyOf={(it) => it.src}
        render={(it) => it.src === '__upload' ? (
          <>
            <button className="thumb upl" style={{ width: '100%' }} onClick={() => pickInto(fileRef.current, { kind: 'image', multiple: true, title: 'PNG yükle' })}><Icon name="upload" size={22} /></button>
            <div className="tlabel">Galeriden yükle</div>
          </>
        ) : (
          <>
            <button className="thumb" style={{ width: '100%' }} aria-label={it.name} onClick={() => !edit && onPick(it)}>
              <Img src={it.src} alt="" />
              {edit && it.id && <span className="x" role="button" aria-label={`${it.name} sil`} onClick={async (e) => { e.stopPropagation(); await removeUserPackItem(it.id!); refresh(); }}><Icon name="close" size={14} stroke={2.4} /></span>}
            </button>
            <div className="tlabel">{it.name}</div>
          </>
        )}
      />
      {which === 'mine' && !mine.length && <p style={{ color: 'var(--d-text2)', fontSize: 12, margin: '6px 0 0' }}>Kendi PNG'lerini yükle, klasörlere ayır; burada hızlıca kullan.</p>}
    </div>
  );
}

// ---------- Bayraklar ----------
interface FlagMeta { code: string; en: string; continent: string; iso: boolean }
const CONT: Record<string, string> = { Europe: 'Avrupa', Asia: 'Asya', Africa: 'Afrika', 'North America': 'Kuzey Amerika', 'South America': 'Güney Amerika', Oceania: 'Okyanusya', Antarctica: 'Antarktika' };

function FlagsTab({ onPick, toast, replace }: { onPick: (src: string, name: string, mode: 'cb' | 'cbsoft' | 'cbwarden' | 'flat') => void; toast: (m: string) => void; replace: boolean }) {
  const [all, setAll] = useState<FlagMeta[]>([]);
  const [q, setQ] = useState('');
  const [cont, setCont] = useState('Tümü');
  const [mine, setMine] = useState<UserFlag[]>([]);
  const [ask, setAsk] = useState<{ src: string; name: string } | null>(null);
  const [showN, setShowN] = useState(25);
  useEffect(() => setShowN(25), [q, cont]);
  const fileRef = useRef<HTMLInputElement>(null);
  useEffect(() => { fetch('flags/flags.json').then((r) => r.json()).then(setAll); listUserFlags().then(setMine); }, []);
  const dn = useMemo(() => { try { return new Intl.DisplayNames(['tr'], { type: 'region' }); } catch { return null; } }, []);
  const named = useMemo(() => all.map((f) => {
    let n = f.en;
    if (f.iso && f.code.length === 2) { try { n = dn?.of(f.code.toUpperCase()) ?? f.en; } catch { /* yok */ } }
    return { ...f, name: n };
  }).sort((a, b) => Number(b.code === 'wardencb') - Number(a.code === 'wardencb') || a.name.localeCompare(b.name, 'tr')), [all, dn]);
  const ql = q.toLocaleLowerCase('tr');
  const list = named.filter((f) => (cont === 'Tümü' || CONT[f.continent] === cont) && (!ql || f.name.toLocaleLowerCase('tr').includes(ql) || f.en.toLowerCase().includes(ql) || f.code === ql));
  const choose = (src: string, name: string) => (replace ? onPick(src, name, 'flat') : setAsk({ src, name }));

  return (
    <div>
      <input className="dinput" style={{ height: 36, marginBottom: 8 }} placeholder="Bayrak ara (ör. Türkiye)" value={q} onChange={(e) => setQ(e.target.value)} />
      <div className="chips">
        {['Tümü', ...Object.values(CONT).filter((c) => c !== 'Antarktika')].map((c) => <button key={c} className={'chip' + (cont === c ? ' on' : '')} onClick={() => setCont(c)}>{c}</button>)}
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
      {(() => {
        const flagItems = [
          ...(ql || cont !== 'Tümü' || replace ? [] : [{ key: '__add', src: '', name: 'Bayrak ekle' }]),
          ...mine.filter((m) => !ql || m.name.toLocaleLowerCase('tr').includes(ql)).map((m) => ({ key: m.id, src: m.id, name: m.name })),
          ...list.map((f) => ({ key: f.code, src: `flags/${f.code}.svg`, name: f.name })),
        ];
        if (!flagItems.length) return <p style={{ color: 'var(--d-text2)', fontSize: 13 }}>"{q}" için bayrak bulunamadı.</p>;
        // Bayraklar aşağı kaydırılarak gezilir (arama + kıta filtresi üstte sabit).
        // Zayıf telefonlarda donmasın diye hepsi birden değil, kaydırdıkça parça parça çizilir.
        return (
          <div className="flag-scroll" onScroll={(e) => { const el = e.currentTarget; if (el.scrollTop + el.clientHeight > el.scrollHeight - 160) setShowN((n) => (n < flagItems.length ? n + 25 : n)); }}>
            {flagItems.slice(0, showN).map((f) => f.key === '__add' ? (
              <button key={f.key} className="flag" onClick={() => pickInto(fileRef.current, { kind: 'image', title: 'Bayrak ekle' })}>
                <span style={{ width: '100%', aspectRatio: '4/3', borderRadius: 4, border: '2px dashed var(--d-line)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--turq)' }}><Icon name="plus" /></span>Bayrak ekle
              </button>
            ) : (
              <button key={f.key} className="flag" onClick={() => choose(f.src, f.name)}><Img src={f.src} alt="" /><span className="fname">{f.name}</span></button>
            ))}
          </div>
        );
      })()}

      {ask && (
        <div className="choice" onClick={() => setAsk(null)}>
          <div className="choice-box" onClick={(e) => e.stopPropagation()}>
            <h4>{ask.name}</h4>
            <button className="btn" onClick={() => { onPick(ask.src, ask.name, 'cbsoft'); setAsk(null); }}><Icon name="ball" size={18} />Yumuşak CB olarak ekle</button>
            <button className="btn ghost" onClick={() => { onPick(ask.src, ask.name, 'cb'); setAsk(null); }}><Icon name="ball" size={18} />Yuvarlak CB olarak ekle</button>
            <button className="btn ghost" onClick={() => { onPick(ask.src, ask.name, 'cbwarden'); setAsk(null); }}><Icon name="ball" size={18} />Basık CB olarak ekle</button>
            <span style={{ fontSize: 12, color: 'var(--d-text2)' }}>Top gövdesi kurulur: çizgi + beyaz iç + iç'e kırpılmış bayrak + gözler. Hepsi çizgiyi takip eder.</span>
            <button className="btn ghost" onClick={() => { onPick(ask.src, ask.name, 'flat'); setAsk(null); }}><Icon name="flag" size={18} />Düz bayrak olarak ekle</button>
            <button className="btn ghost" onClick={() => setAsk(null)}>Vazgeç</button>
          </div>
        </div>
      )}
    </div>
  );
}

// ---------- Taşı ve Çevir (videodaki düzen) ----------
type Mode = 'move' | 'rotate' | 'scale';
const MODE_PROPS: Record<Mode, AnimProp[]> = { move: ['x', 'y'], rotate: ['rotation'], scale: ['scale'] };
const fmt2 = (n: number) => n.toFixed(2).replace('.', ',');

export function MovePanel({ layer, onClose }: { layer: Layer; onClose: () => void }) {
  const { s, t } = useNow();
  const [mode, setMode] = useState<Mode>('move');
  useEffect(() => { s.setKfFocus([mode === 'move' ? 'pos' : mode === 'rotate' ? 'rot' : 'scl']); }, [mode]);
  useEffect(() => () => useStore.getState().setKfFocus(null), []);
  const [curve, setCurve] = useState(false);
  const props = MODE_PROPS[mode];
  const hasKey = props.some((pr) => keyAt(layer[pr], t));
  const animated = props.some((pr) => (layer[pr].k?.length ?? 0) > 0);
  const drag = useRef<{ x: number; y: number; v: number[]; cx?: number; cy?: number; lastAng?: number; acc?: number } | null>(null);
  const padRef = useRef<HTMLDivElement>(null);

  const set = (vals: Partial<Record<AnimProp, number>>, commit = true) =>
    s.updateLayer(layer.id, (l) => {
      const n = { ...l };
      for (const [k, v] of Object.entries(vals) as [AnimProp, number][]) n[k] = setAnim(l[k], t, v);
      return n;
    }, commit);

  const toggle = () => s.updateLayer(layer.id, (l) => {
    const n = { ...l };
    const any = props.some((pr) => keyAt(l[pr], t));
    for (const pr of props) { const has = !!keyAt(l[pr], t); if (any ? has : !has) n[pr] = toggleKey(l[pr], t); }
    return n;
  });

  const rot = valueAt(layer.rotation, t), sc = valueAt(layer.scale, t);
  const onPadDown = (e: React.PointerEvent) => {
    try { (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId); } catch { /* yok */ }
    s.checkpoint();
    const r = padRef.current!.getBoundingClientRect();
    drag.current = { x: e.clientX, y: e.clientY, v: props.map((pr) => valueAt(layer[pr], t)), cx: r.left + r.width / 2, cy: r.top + r.height / 2 };
  };
  const onPadMove = (e: React.PointerEvent) => {
    const d = drag.current; if (!d) return;
    const dx = e.clientX - d.x, dy = e.clientY - d.y;
    if (mode === 'move') set({ x: Math.round((d.v[0] + dx * 1.5) * 100) / 100, y: Math.round((d.v[1] + dy * 1.5) * 100) / 100 }, false);
    else if (mode === 'rotate') {
      // Kadran: her hareketteki açı farkı toplanır; kaç tur çevrilirse o kadar döner (sınır yok)
      const ang = Math.atan2(e.clientY - d.cy!, e.clientX - d.cx!) * 180 / Math.PI;
      if (d.lastAng === undefined) { d.lastAng = ang; d.acc = d.v[0]; return; }
      let da = ang - d.lastAng;
      if (da > 180) da -= 360; else if (da < -180) da += 360;
      d.lastAng = ang; d.acc = (d.acc ?? d.v[0]) + da;
      set({ rotation: Math.round(d.acc * 10) / 10 }, false);
    } else set({ scale: Math.max(0.01, Math.round((d.v[0] + dx * 0.004) * 1000) / 1000) }, false);
  };
  const onPadUp = () => { drag.current = null; };

  // Yumuşatma eğrisi: bu modun özelliklerinin, t'deki geçişi
  const segKey = segmentKey(layer[props[0]], t);
  const ease: [number, number, number, number] = segKey?.e ?? [0.25, 0.25, 0.75, 0.75];
  const applyEase = (e: [number, number, number, number] | undefined, commit = true) =>
    s.updateLayer(layer.id, (l) => { const n = { ...l }; for (const pr of props) n[pr] = setEase(l[pr], t, e); return n; }, commit);
  const gref = useRef<SVGSVGElement>(null);
  const gdrag = useRef<0 | 1 | 2>(0);
  const onGMove = (e: React.PointerEvent) => {
    if (!gdrag.current) return;
    const r = gref.current!.getBoundingClientRect();
    const x = Math.min(1, Math.max(0, (e.clientX - r.left - 12) / (r.width - 24)));
    const y = Math.min(1.6, Math.max(-0.6, 1 - (e.clientY - r.top - 12) / (r.height - 24)));
    const n: [number, number, number, number] = [...ease];
    if (gdrag.current === 1) { n[0] = +x.toFixed(3); n[1] = +y.toFixed(3); } else { n[2] = +x.toFixed(3); n[3] = +y.toFixed(3); }
    applyEase(n, false);
  };

  const pos = (px: number, py: number) => [12 + px * 100, 12 + (1 - py) * 100];
  const [p1x, p1y] = pos(ease[0], ease[1]), [p2x, p2y] = pos(ease[2], ease[3]);

  return (
    <div className="dpanel side3" role="dialog" aria-label="Taşı ve Çevir">
      <div className="lcol">
        <button className="ib" aria-label={curve ? 'Eğriden çık' : 'Geri'} onClick={() => (curve ? setCurve(false) : onClose())}><Icon name="back" /></button>
        {!curve && <button className="ib" aria-label={hasKey ? 'Bu anki keyframe\'i sil' : 'Bu ana keyframe ekle'} onClick={toggle} style={{ color: hasKey ? 'var(--turq)' : 'var(--d-text)' }}><KfIcon has={hasKey} /></button>}
        <span style={{ flex: 1 }} />
        {!curve && <button className="ib" aria-label="Yumuşatma eğrisi" onClick={() => setCurve(true)} style={{ color: animated ? 'var(--d-text)' : 'var(--d-dim)' }}><Icon name="curve" size={20} /></button>}
      </div>

      {curve ? (
        <div className="cpad">
          {segKey ? (
            <svg ref={gref} viewBox="0 0 124 124" className="graph" onPointerMove={onGMove} onPointerUp={() => { gdrag.current = 0; }} onPointerLeave={() => { gdrag.current = 0; }}>
              {Array.from({ length: 11 }, (_, i) => <line key={'v' + i} x1={12 + i * 10} y1={12} x2={12 + i * 10} y2={112} className="gl" />)}
              {Array.from({ length: 11 }, (_, i) => <line key={'h' + i} x1={12} y1={12 + i * 10} x2={112} y2={12 + i * 10} className="gl" />)}
              <line x1={62} y1={12} x2={62} y2={112} className="gmid" />
              <line x1={12} y1={112} x2={p1x} y2={p1y} className="garm" />
              <line x1={112} y1={12} x2={p2x} y2={p2y} className="garm" />
              <path d={`M12 112 C${p1x} ${p1y} ${p2x} ${p2y} 112 12`} className="gcurve" />
              <circle cx={12} cy={112} r={2.5} className="gend" /><circle cx={112} cy={12} r={2.5} className="gend" />
              {([1, 2] as const).map((n) => (
                <circle key={n} cx={n === 1 ? p1x : p2x} cy={n === 1 ? p1y : p2y} r={6} className="ghandle"
                  onPointerDown={(e) => { try { (e.currentTarget.ownerSVGElement as SVGSVGElement).setPointerCapture(e.pointerId); } catch { /* yok */ } s.checkpoint(); gdrag.current = n; }} />
              ))}
            </svg>
          ) : (
            <div className="padhint">Yumuşatma için bu özellikte en az iki keyframe olmalı.</div>
          )}
        </div>
      ) : (
        <div className="cpad" ref={padRef} onPointerDown={onPadDown} onPointerMove={onPadMove} onPointerUp={onPadUp} onPointerCancel={onPadUp}>
          <span className="cnr tl" /><span className="cnr tr" /><span className="cnr bl" /><span className="cnr br" />
          {mode === 'move' && (
            <>
              <div className="coords">{fmt2(valueAt(layer.x, t))}, {fmt2(valueAt(layer.y, t))}</div>
              <div className="padhint">Taşımak için kaydırın</div>
            </>
          )}
          {mode === 'rotate' && (
            <div className="dial">
              <div className="ring">
                <span className="deg">
                  {Math.abs(rot) >= 360 && <small className="turns">×{Math.trunc(rot / 360)}</small>}
                  {Math.round(rot - Math.trunc(rot / 360) * 360)}°
                </span>
                <span className="knob" style={{ transform: `rotate(${rot}deg) translateX(var(--r))` }} />
              </div>
            </div>
          )}
          {mode === 'scale' && (
            <>
              <div className="pxrow" onPointerDown={(e) => e.stopPropagation()}>
                <span>{Math.round(layer.w * sc)}px</span><Icon name="link" size={14} /><span>{Math.round(layer.h * sc)}px</span>
              </div>
              <div className="ruler2" style={{ backgroundPositionX: `${(sc * 250) % 12}px` }}><i /></div>
            </>
          )}
        </div>
      )}

      <div className="rcol">
        {curve ? EASES.slice(1).map((x) => (
          <button key={x.id} className="ib" aria-label={x.name} title={x.name} onClick={() => applyEase(x.e)}>
            <svg width="22" height="22" viewBox="0 0 24 24" aria-hidden="true"><path d={`M3 21 C${3 + x.e![0] * 18} ${21 - x.e![1] * 18} ${3 + x.e![2] * 18} ${21 - x.e![3] * 18} 21 3`} fill="none" stroke="currentColor" strokeWidth="1.8" /></svg>
          </button>
        )) : (
          <>
            {([['move', 'move', 'Taşı'], ['rotate', 'rotate', 'Döndür'], ['scale', 'scale', 'Ölçek']] as [Mode, string, string][]).map(([m, ic, lb]) => (
              <button key={m} className={'ib' + (mode === m ? ' on' : '')} aria-label={lb} aria-pressed={mode === m} onClick={() => setMode(m)}><Icon name={ic} size={22} /></button>
            ))}
            <button className="ib" aria-label="Eğ (yakında)" disabled><Icon name="skew" size={22} /></button>
          </>
        )}
      </div>
    </div>
  );
}

// ---------- Renk ve Dolgu (videodaki düzen: solda geri/keyframe, üstte sekmeler, kod çubuğu, renk ızgarası) ----------
const SWATCHES = [
  '#E8333F', '#FF8A1F', '#F2E230', '#8A5A2B', '#7ED957', '#A23BD6', '#2B3BE8',
  '#4A90E2', '#22D3C5', '#B8F28A', '#000000', '#555E6E', '#9AA6B8', '#FFFFFF',
  '#1B2A55', '#2F7BF6', '#0E5A63', '#3FD0F0', '#F5DCA0', '#E84393', '#8F7CF0',
];
const ink = (hex: string) => { const n = parseInt(hex.slice(1, 7), 16); const y = ((n >> 16) & 255) * .299 + ((n >> 8) & 255) * .587 + (n & 255) * .114; return y > 140 ? '#0D1631' : '#EEF4FF'; };

export function ColorPanel({ layer, onClose }: { layer: Layer; onClose: () => void }) {
  const { s } = useNow();
  const grad = !!(layer.fill2 && layer.grad);
  const mode: 'none' | 'solid' | 'grad' = layer.noFill ? 'none' : grad ? 'grad' : 'solid';
  const [slot, setSlot] = useState<1 | 2>(1);
  const [pal, setPal] = useState(false); // geçişte bir uca dokununca renk paleti açılır
  const cur = slot === 2 && grad ? layer.fill2! : layer.fill;
  const setColor = (c: string, commit = true) => s.updateLayer(layer.id, (l) => (slot === 2 && grad ? { ...l, fill2: c } : { ...l, fill: c }), commit);
  const [hex, setHex] = useState(cur.toUpperCase());
  useEffect(() => setHex(cur.toUpperCase()), [cur]);
  const setMode = (m: typeof mode) => {
    setPal(false); setSlot(1);
    s.updateLayer(layer.id, (l) => m === 'none' ? { ...l, noFill: true }
      : m === 'solid' ? { ...l, noFill: false, fill2: undefined, grad: undefined }
      : { ...l, noFill: false, fill2: l.fill2 ?? '#F2C230', grad: l.grad ?? { x1: 0, y1: -0.5, x2: 0, y2: 0.5 }, gtype: l.gtype ?? 'linear' });
  };
  const palette = (
    <div className="cgrid">
      <input className="hexbar" aria-label="Renk kodu" value={hex} style={{ background: cur, color: ink(cur) }}
        onChange={(e) => setHex(e.target.value.toUpperCase())}
        onBlur={() => { if (/^#[0-9A-F]{6}$/.test(hex)) setColor(hex); else setHex(cur.toUpperCase()); }}
        onKeyDown={(e) => e.key === 'Enter' && (e.target as HTMLInputElement).blur()} />
      <div className="swgrid">
        {SWATCHES.map((c) => <button key={c} aria-label={c} className={cur.toUpperCase() === c ? 'on' : ''} style={{ background: c }} onClick={() => setColor(c)} />)}
      </div>
      <label className="pal" aria-label="Özel renk seç">
        <Icon name="bucket" size={20} />
        <input type="color" value={cur.slice(0, 7)} onFocus={() => s.checkpoint()} onChange={(e) => setColor(e.target.value.toUpperCase(), false)} />
      </label>
    </div>
  );
  return (
    <div className="dpanel side2" role="dialog" aria-label="Renk ve Dolgu">
      <div className="lcol">
        <button className="ib" aria-label="Geri" onClick={() => (pal ? setPal(false) : onClose())}><Icon name="back" /></button>
      </div>
      <div className="dbody" style={{ paddingLeft: 4 }}>
        <div className="seg dseg ctabs">
          <button className={mode === 'none' ? 'on' : ''} aria-label="Dolgu yok" onClick={() => setMode('none')}><Icon name="nofill" size={18} /></button>
          <button className={mode === 'solid' ? 'on' : ''} aria-label="Düz renk" onClick={() => setMode('solid')}><Icon name="bucket" size={18} /></button>
          <button className={mode === 'grad' ? 'on' : ''} aria-label="Geçiş" onClick={() => setMode('grad')}><span className="gicon" /></button>
          <button disabled aria-label="Görsel dolgu (yakında)"><Icon name="image" size={18} /></button>
        </div>
        {mode === 'solid' && palette}
        {mode === 'none' && <p style={{ color: 'var(--d-text2)', fontSize: 13, textAlign: 'center', margin: '18px 0' }}>Bu katmanın dolgusu yok.</p>}
        {mode === 'grad' && (pal ? palette : (
          <>
            <div className="gtypes">
              <button className={layer.gtype !== 'radial' ? 'on' : ''} aria-label="Doğrusal geçiş" onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, gtype: 'linear' }))}><span className="gt lin" /></button>
              <button className={layer.gtype === 'radial' ? 'on' : ''} aria-label="Dairesel geçiş" onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, gtype: 'radial' }))}><span className="gt rad" /></button>
            </div>
            <div className="gbar" style={{ background: `linear-gradient(90deg, ${layer.fill}, ${layer.fill2})` }}>
              {([1, 2] as const).map((n) => (
                <button key={n} className={'gknob' + (n === 2 ? ' r' : '')} aria-label={n === 1 ? 'Başlangıç rengi' : 'Bitiş rengi'} style={{ background: n === 1 ? layer.fill : layer.fill2 }} onClick={() => { setSlot(n); setPal(true); }} />
              ))}
            </div>
            <p className="hint" style={{ fontSize: 11, color: 'var(--d-text2)', margin: '8px 2px 0', textAlign: 'center' }}>Uçlara dokunarak renk seç; yönü önizlemedeki noktaları sürükleyerek ayarla.</p>
          </>
        ))}
      </div>
    </div>
  );
}

// ---------- Karıştırma ve Opaklık ----------
const BLENDS: { id: import('../types').BlendMode; name: string }[] = [
  { id: 'normal', name: 'Normal' }, { id: 'multiply', name: 'Çoğalt' }, { id: 'screen', name: 'Ekran' },
  { id: 'overlay', name: 'Kaplama' }, { id: 'darken', name: 'Koyulaştır' }, { id: 'lighten', name: 'Açıklaştır' },
  { id: 'color-dodge', name: 'Renk Soldurma' }, { id: 'difference', name: 'Fark' },
];
export function OpacityPanel({ layer, onClose }: { layer: Layer; onClose: () => void }) {
  const { s, t } = useNow();
  useEffect(() => { s.setKfFocus(['op']); return () => useStore.getState().setKfFocus(null); }, []);
  const v = valueAt(layer.opacity, t);
  const has = !!keyAt(layer.opacity, t);
  const bm = layer.blend ?? 'normal';
  return (
    <div className="dpanel side2" role="dialog" aria-label="Karıştırma ve Opaklık">
      <div className="lcol">
        <button className="ib" aria-label="Geri" onClick={onClose}><Icon name="back" /></button>
        <button className="ib" aria-label={has ? 'Opaklık keyframe\'ini sil' : 'Opaklık keyframe ekle'} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, opacity: toggleKey(l.opacity, t) }))} style={{ color: has ? 'var(--turq)' : 'var(--d-text)' }}><KfIcon has={has} /></button>
      </div>
      <div className="dbody" style={{ paddingLeft: 4 }}>
        <div className="blends">
          {BLENDS.map((b) => (
            <button key={b.id} className={bm === b.id ? 'on' : ''} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, blend: b.id }))}>
              <span className={'bthumb ' + b.id} />{b.name}
            </button>
          ))}
        </div>
        <div className="oprow">
          <Icon name="opacity" size={18} />
          <input className="slider" type="range" min={0} max={1000} value={Math.round(v * 1000)} aria-label="Opaklık" onPointerDown={() => s.checkpoint()} onChange={(e) => s.updateLayer(layer.id, (l) => ({ ...l, opacity: setAnim(l.opacity, t, +e.target.value / 1000) }), false)} />
          <b>{v.toFixed(3)}</b>
        </div>
      </div>
    </div>
  );
}

/** Ses Düzeyi: ses ve video katmanlarının sesi (%0–200) */
export function VolumePanel({ layer, onClose }: { layer: Layer; onClose: () => void }) {
  const { s } = useNow();
  const v = layer.volume ?? 1;
  const muted = !!layer.muted;
  return (
    <div className="dpanel side2" role="dialog" aria-label="Ses Düzeyi">
      <div className="lcol">
        <button className="ib" aria-label="Geri" onClick={onClose}><Icon name="back" /></button>
        <button className="ib" aria-label={muted ? 'Sesi aç' : 'Sessize al'} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, muted: !l.muted }))} style={{ color: muted ? 'var(--turq)' : 'var(--d-text)' }}><Icon name={muted ? 'volOff' : 'music'} /></button>
      </div>
      <div className="dbody" style={{ paddingLeft: 4 }}>
        <div className="oprow">
          <Icon name="music" size={18} />
          <input className="slider" type="range" min={0} max={200} value={Math.round(v * 100)} disabled={muted} aria-label="Ses düzeyi" onPointerDown={() => s.checkpoint()} onChange={(e) => s.updateLayer(layer.id, (l) => ({ ...l, volume: +e.target.value / 100 }), false)} />
          <b>{muted ? 'Sessiz' : `%${Math.round(v * 100)}`}</b>
        </div>
        <div className="volpre">
          {[0.5, 1, 1.5, 2].map((x) => <button key={x} className={!muted && Math.abs(v - x) < 0.005 ? 'on' : ''} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, volume: x, muted: false }))}>%{x * 100}</button>)}
          <button className={muted ? 'on' : ''} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, muted: !l.muted }))}>Sessiz</button>
        </div>
        {layer.type === 'video' && <span className="volnote">Videonun kendi sesi. Önizlemede oynatırken duyulur, dışa aktarınca videoya eklenir.</span>}
      </div>
    </div>
  );
}

// ---------- Efektler: katmanın efekt listesi (videodaki düzen) ----------
const fmtP = (n: number, step: number) => (step >= 1 ? String(Math.round(n)) : n.toFixed(step < 0.01 ? 3 : 2)).replace('.', ',');

/** Parametrenin değerini t anında yazar (keyframe varsa o anda keyframe günceller) */
function setFxParams(l: Layer, fxId: string, vals: Record<string, number>, t: number): Layer {
  return { ...l, effects: l.effects.map((e) => {
    if (e.id !== fxId) return e;
    const v = { ...(e.v ?? {}) };
    for (const [k, n] of Object.entries(vals)) v[k] = setAnim(v[k] ?? { v: fxVal(e, k, t) }, t, n);
    return { ...e, v, ...(vals.amount !== undefined && !(v.amount?.k?.length) ? { amount: vals.amount } : {}) };
  }) };
}

export function EffectsPanel({ layer, onClose }: { layer: Layer; onClose: () => void }) {
  const { s, t } = useNow();
  const [browse, setBrowse] = useState(false);
  const [menuFx, setMenuFx] = useState<string | null>(null);
  const sel = s.fxParam;
  useEffect(() => { s.setKfFocus(sel ? [`fx:${sel.fx}:${sel.key}`] : ['fx:none']); }, [sel?.fx, sel?.key]);
  useEffect(() => () => useStore.getState().setKfFocus(null), []);
  useEffect(() => () => useStore.getState().setFxParam(null), []);
  // Seçili parametre yoksa ilk efektin ilk parametresini seç
  useEffect(() => {
    if (sel && layer.effects.some((e) => e.id === sel.fx)) return;
    const e = layer.effects.find((x) => fxMeta(x.type).params.length);
    s.setFxParam(e ? { fx: e.id, key: fxMeta(e.type).params[0].key } : null);
  }, [layer.effects.length]);

  const selFx = layer.effects.find((e) => e.id === sel?.fx);
  const selPr = selFx ? fxMeta(selFx.type).params.find((p) => p.key === sel!.key) : undefined;
  const selKeys = selPr ? paramKeys(selPr) : [];
  const hasKey = !!selFx && selKeys.some((k) => selFx.v?.[k] && keyAt(selFx.v[k], t));
  const toggleK = () => selFx && s.updateLayer(layer.id, (l) => ({ ...l, effects: l.effects.map((e) => {
    if (e.id !== selFx.id) return e;
    const v = { ...(e.v ?? {}) };
    for (const k of selKeys) {
      const a0 = v[k] ?? { v: fxVal(e, k, t) };
      const on = !!keyAt(a0, t);
      if (on === hasKey) v[k] = toggleKey(a0, t);
    }
    return { ...e, v };
  }) }));

  // Kaydırma cetveli: yatay = değer (2B'de X), dikey = 2B'de Y
  const jog = useRef<{ x: number; y: number; v: number[]; fx: string; pr: FxParam } | null>(null);
  const jogDown = (ev: React.PointerEvent, e: Effect, pr: FxParam) => {
    try { (ev.currentTarget as HTMLElement).setPointerCapture(ev.pointerId); } catch { /* yok */ }
    s.setFxParam({ fx: e.id, key: pr.key });
    s.checkpoint();
    jog.current = { x: ev.clientX, y: ev.clientY, v: paramKeys(pr).map((k) => fxVal(e, k, t)), fx: e.id, pr };
  };
  const jogMove = (ev: React.PointerEvent) => {
    const j = jog.current; if (!j) return;
    const clamp = (n: number) => Math.min(j.pr.max, Math.max(j.pr.min, Math.round(n / j.pr.step) * j.pr.step));
    const vals: Record<string, number> = j.pr.two
      ? { [j.pr.key + 'X']: clamp(j.v[0] + (ev.clientX - j.x) * j.pr.jog), [j.pr.key + 'Y']: clamp(j.v[1] + (ev.clientY - j.y) * j.pr.jog) }
      : { [j.pr.key]: clamp(j.v[0] + (ev.clientX - j.x) * j.pr.jog) };
    s.updateLayer(layer.id, (l) => setFxParams(l, j.fx, vals, t), false);
  };
  const jogUp = () => { jog.current = null; };

  return (
    <div className="dpanel side2 fxpanel" role="dialog" aria-label="Efektler">
      <div className="lcol">
        <button className="ib" aria-label="Geri" onClick={onClose}><Icon name="back" /></button>
        <button className="ib" aria-label={hasKey ? 'Keyframe sil' : 'Keyframe ekle'} disabled={!selPr} onClick={toggleK} style={{ color: hasKey ? 'var(--turq)' : 'var(--d-text)' }}><KfIcon has={hasKey} /></button>
        <span style={{ flex: 1 }} />
      </div>
      <div className="dbody fxlist">
        {layer.effects.map((e) => {
          const m = fxMeta(e.type);
          return (
            <div key={e.id} className="fxcard">
              <div className="fxhead">
                <button className="fxname" aria-expanded={!e.closed} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, effects: l.effects.map((x) => (x.id === e.id ? { ...x, closed: !x.closed } : x)) }))}>
                  <span className={'tri' + (e.closed ? ' shut' : '')}>▼</span>{m.name}
                </button>
                <button className="ib" aria-label={`${m.name} seçenekleri`} onClick={() => setMenuFx(menuFx === e.id ? null : e.id)}><Icon name="more" size={20} stroke={3} /></button>
                <button className="ib" aria-label={`${m.name} kaldır`} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, effects: l.effects.filter((x) => x.id !== e.id) }))}><Icon name="trash" size={18} /></button>
              </div>
              {menuFx === e.id && (
                <div className="fxmenu">
                  <button onClick={() => { s.updateLayer(layer.id, (l) => { const i = l.effects.findIndex((x) => x.id === e.id); const ef = [...l.effects]; if (i > 0) [ef[i - 1], ef[i]] = [ef[i], ef[i - 1]]; return { ...l, effects: ef }; }); setMenuFx(null); }}>Yukarı taşı</button>
                  <button onClick={() => { s.updateLayer(layer.id, (l) => { const i = l.effects.findIndex((x) => x.id === e.id); const ef = [...l.effects]; if (i < ef.length - 1) [ef[i + 1], ef[i]] = [ef[i], ef[i + 1]]; return { ...l, effects: ef }; }); setMenuFx(null); }}>Aşağı taşı</button>
                  <button onClick={() => { s.updateLayer(layer.id, (l) => ({ ...l, effects: [...l.effects, { ...structuredClone(e), id: Math.random().toString(36).slice(2, 10) }] })); setMenuFx(null); }}>Çoğalt</button>
                  <button onClick={() => { s.updateLayer(layer.id, (l) => ({ ...l, effects: l.effects.map((x) => (x.id === e.id ? { ...makeEffect(e.type), id: e.id, color: e.color } : x)) })); setMenuFx(null); }}>Sıfırla</button>
                </div>
              )}
              {!e.closed && m.info && <div className="fxinfo"><Icon name="info" size={14} />{m.info}</div>}
              {!e.closed && m.params.map((pr) => {
                const keys = paramKeys(pr);
                if (pr.kind === 'toggle') {
                  const v = fxVal(e, pr.key, t) >= 0.5;
                  return (
                    <div key={pr.key} className="prow">
                      <span className="tlabel2">{pr.label}</span>
                      <button className={'sw2' + (v ? ' on' : '')} role="switch" aria-checked={v} aria-label={pr.label} onClick={() => s.updateLayer(layer.id, (l) => setFxParams(l, e.id, { [pr.key]: v ? 0 : 1 }, t))} />
                    </div>
                  );
                }
                if (pr.kind === 'slider') {
                  const on = sel?.fx === e.id && sel.key === pr.key;
                  const v = fxVal(e, pr.key, t);
                  return (
                    <div key={pr.key} className={'prow' + (on ? ' on' : '')}>
                      <button className="plabel" onClick={() => s.setFxParam({ fx: e.id, key: pr.key })}>{pr.label}{(e.v?.[pr.key]?.k?.length ?? 0) > 0 && <i className="kdot" />}</button>
                      <input className="pslider" type="range" aria-label={pr.label} min={pr.min} max={pr.max} step={pr.step} value={v}
                        onPointerDown={() => { s.checkpoint(); s.setFxParam({ fx: e.id, key: pr.key }); }}
                        onChange={(ev) => s.updateLayer(layer.id, (l) => setFxParams(l, e.id, { [pr.key]: +ev.target.value }, t), false)} />
                      <div className="pvals"><span>{fmtP(v, pr.step)}</span></div>
                    </div>
                  );
                }
                const on = sel?.fx === e.id && sel.key === pr.key;
                const animated = keys.some((k) => (e.v?.[k]?.k?.length ?? 0) > 0);
                return (
                  <div key={pr.key} className={'prow' + (on ? ' on' : '')}>
                    <button className="plabel" onClick={() => s.setFxParam({ fx: e.id, key: pr.key })}>{pr.label}{animated && <i className="kdot" />}</button>
                    <div className="pjog" role="slider" aria-label={pr.label} aria-valuenow={fxVal(e, keys[0], t)}
                      onPointerDown={(ev) => jogDown(ev, e, pr)} onPointerMove={jogMove} onPointerUp={jogUp} onPointerCancel={jogUp}
                      style={{ backgroundPositionX: `${(fxVal(e, keys[0], t) / pr.jog) % 10}px` }}><i /></div>
                    <div className="pvals">
                      {keys.map((k, i) => (
                        <span key={k}>{pr.two && <small>{i ? 'y' : 'x'}</small>}{fmtP(fxVal(e, k, t), pr.step)}</span>
                      ))}
                    </div>
                  </div>
                );
              })}
              {!e.closed && m.color && (
                <div className="prow"><span className="plabel">Renk</span><span style={{ flex: 1 }} />
                  <input type="color" aria-label="Efekt rengi" value={e.color} onChange={(ev) => s.updateLayer(layer.id, (l) => ({ ...l, effects: l.effects.map((x) => (x.id === e.id ? { ...x, color: ev.target.value } : x)) }), false)} /></div>
              )}
            </div>
          );
        })}
        <button className="addfx" onClick={() => setBrowse(true)}><Icon name="plus" size={18} stroke={2.2} />Efekt Ekle</button>
      </div>
      {browse && <EffectBrowser onClose={() => setBrowse(false)} onPick={(ty) => { const ne = makeEffect(ty); s.updateLayer(layer.id, (l) => ({ ...l, effects: [...l.effects, ne] })); const pr0 = fxMeta(ty).params[0]; s.setFxParam(pr0 ? { fx: ne.id, key: pr0.key } : null); setBrowse(false); }} />}
    </div>
  );
}

/** Efekt küçük resmi: örnek görsele efektin kendisi CSS ile uygulanır */
function FxThumb({ t, big = false }: { t: FxType; big?: boolean }) {
  return (
    <span className={'fxthumb' + (big ? ' big' : '')}>
      <span className="fxs" style={Object.fromEntries(fxMeta(t).css.split(';').filter(Boolean).map((d) => { const [k, ...v] = d.split(':'); return [k.trim().replace(/-([a-z])/g, (_, c) => c.toUpperCase()), v.join(':').trim()]; }))}>
        <i className="c" /><i className="tri" />
      </span>
    </span>
  );
}

/** Tam ekran Efekt Tarayıcısı (öne çıkanlar, efekt ızgarası, kategoriler) */
export function EffectBrowser({ onClose, onPick }: { onClose: () => void; onPick: (t: FxType) => void }) {
  const [q, setQ] = useState('');
  const [search, setSearch] = useState(false);
  const [cat, setCat] = useState<string | null>(null);
  useEffect(() => {
    const fn = (e: Event) => { e.preventDefault(); if (cat) setCat(null); else onClose(); };
    addEventListener('wm-back', fn);
    return () => removeEventListener('wm-back', fn);
  }, [cat, onClose]);
  const ql = q.toLocaleLowerCase('tr');
  const list = FX.filter((f) => (!cat || f.cat === cat) && (!ql || f.name.toLocaleLowerCase('tr').includes(ql)));
  return (
    <div className="fxb" role="dialog" aria-label="Efekt Tarayıcısı">
      <header className="fxb-top">
        <button className="ib" aria-label={cat ? 'Kategorilerden çık' : 'Kapat'} onClick={() => (cat ? setCat(null) : onClose())}><Icon name={cat ? 'back' : 'close'} size={26} stroke={2} /></button>
        {search
          ? <input className="dinput" autoFocus placeholder="Efekt ara" value={q} onChange={(e) => setQ(e.target.value)} style={{ flex: 1, height: 38 }} />
          : <h2>{cat ?? 'Efekt Tarayıcısı'}</h2>}
        <button className="ib" aria-label="Efekt ara" onClick={() => { setSearch(!search); setQ(''); }}><Icon name={search ? 'close' : 'search'} size={24} stroke={2} /></button>
      </header>
      <div className="fxb-body">
        {!cat && !q && (
          <div className="fxb-feat">
            {FEATURED.map((t) => (
              <button key={t} onClick={() => onPick(t)}><FxThumb t={t} big /><span>{fxMeta(t).name}</span></button>
            ))}
          </div>
        )}
        <div className="fxb-grid">
          {list.map((f) => (
            <button key={f.type} onClick={() => onPick(f.type)}><FxThumb t={f.type} /><span>{f.name}</span></button>
          ))}
          {!list.length && <p style={{ gridColumn: '1 / -1', color: 'var(--d-text2)' }}>"{q}" için efekt bulunamadı.</p>}
        </div>
        {!cat && !q && (
          <div className="fxb-cats">
            {FX_CATS.map((c) => (
              <button key={c.name} style={{ background: c.bg }} onClick={() => setCat(c.name)}>{c.name}</button>
            ))}
          </div>
        )}
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

/** Keyframe düğmesi: bu karede işaret yoksa içinde + (ekle), varsa içinde − (sil) olan elmas */
function KfIcon({ has }: { has: boolean }) {
  return (
    <svg width="26" height="26" viewBox="0 0 26 26" aria-hidden="true">
      <path d="M13 2 24 13 13 24 2 13Z" fill="currentColor" />
      <path d={has ? 'M8.5 13h9' : 'M8.5 13h9M13 8.5v9'} stroke="#0B1430" strokeWidth="2.4" strokeLinecap="round" />
    </svg>
  );
}

// ---------- Şekli Düzenle (uygulamanın kendi şekilleri) ----------
const SHAPE_HELP: Partial<Record<ShapeKind, string>> = {
  bar: 'Önizlemede uçtaki tutamaç uzunluğu, üstteki kalınlığı ayarlar.',
  crescent: 'Önizlemede içteki turkuaz tutamacı kaydır: dışarı çekersen tam top, içeri itersen ince hilal olur. Kesiği büyütüp kenara alırsan yarım daire olur.',
  star: 'Önizlemede turkuaz tutamaçla yıldızın içini derinleştir.',
  roundrect: 'Önizlemede turkuaz tutamaçla köşeleri yuvarla.',
  custom: 'Önizlemede her köşeyi (turkuaz noktalar) istediğin yere sürükle.',
};
export function ShapeEditPanel({ layer, onClose }: { layer: Layer; onClose: () => void }) {
  const { s } = useNow();
  const kind = layer.shape!;
  const params = SHAPE_PARAMS[kind] ?? [];
  const set = (key: string, v: number, commit = false) => s.updateLayer(layer.id, (l) => ({ ...l, sp: { ...l.sp, [key]: v } }), commit);
  const pts = layer.pts ?? regularPts(5);
  const halfMoon = () => s.updateLayer(layer.id, (l) => ({ ...l, sp: { ...l.sp, cx: 0, cy: -4.5, r: 9 } }));
  return (
    <div className="dpanel side2" role="dialog" aria-label="Şekli Düzenle">
      <Head title="Şekli Düzenle" onClose={onClose} back />
      <div className="dbody shapeed">
        {SHAPE_HELP[kind] && <p className="shint">{SHAPE_HELP[kind]}</p>}
        {params.map((pr) => {
          const v = shapeParam(layer, pr.key);
          if (pr.int && pr.max - pr.min <= 1) return (
            <div key={pr.key} className="prop row"><span>{pr.label}</span>
              <button className={'sw2' + (v ? ' on' : '')} role="switch" aria-checked={!!v} aria-label={pr.label} onClick={() => set(pr.key, v ? 0 : 1, true)} /></div>
          );
          if (pr.int) return (
            <div key={pr.key} className="prop row"><span>{pr.label}</span>
              <div className="stepper">
                <button aria-label={`${pr.label} azalt`} disabled={v <= pr.min} onClick={() => set(pr.key, v - 1, true)}>−</button>
                <b>{v}</b>
                <button aria-label={`${pr.label} arttır`} disabled={v >= pr.max} onClick={() => set(pr.key, v + 1, true)}>+</button>
              </div></div>
          );
          return (
            <label key={pr.key} className="prop"><span className="top">{pr.label}<b>{v.toFixed(2).replace('.', ',')}</b></span>
              <input className="slider" type="range" min={pr.min} max={pr.max} step={pr.step} value={v} aria-label={pr.label} onPointerDown={() => s.checkpoint()} onChange={(e) => set(pr.key, +e.target.value)} /></label>
          );
        })}
        {kind === 'crescent' && (
          <div className="chips" style={{ marginTop: 6 }}>
            <button className="chip" onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, sp: { ...l.sp, cx: 0.3, cy: -0.1, r: 0.9 } }))}>Hilal</button>
            <button className="chip" onClick={halfMoon}>Yarım daire</button>
            <button className="chip" onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, sp: { ...l.sp, cx: 1.5, cy: 0, r: 0.5 } }))}>Tam top</button>
          </div>
        )}
        {kind === 'custom' && (
          <>
            <div className="prop row"><span>Köşe sayısı</span>
              <div className="stepper">
                <button aria-label="Köşe çıkar" disabled={pts.length <= 3} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, pts: pts.slice(0, -1) }))}>−</button>
                <b>{pts.length}</b>
                <button aria-label="Köşe ekle" disabled={pts.length >= 40} onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, pts: addVertex(pts) }))}>+</button>
              </div></div>
            <button className="btn ghost" onClick={() => s.updateLayer(layer.id, (l) => ({ ...l, pts: regularPts(pts.length) }))}>Düzgün çokgene çevir</button>
          </>
        )}
        {!params.length && kind !== 'custom' && <p className="shint">Bu şeklin ayarı yok. Önizlemede köşelerden büyütüp kenarlardan genişlet/daralt.</p>}
      </div>
    </div>
  );
}
