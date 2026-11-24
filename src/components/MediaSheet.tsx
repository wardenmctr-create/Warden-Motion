import { useEffect, useRef, useState } from 'react';
import { Icon } from './Icon';
import { addFolder, fileSrc, Gallery, galleryNative, getFolders, type GItem, isDir, readItem, setFolders, toFile, useMediaSheet, type Kind } from '../gallery';
import { AudioCard, stopListen, toggleListen, useListening } from './AudioCard';

const thumbs = new Map<string, string>(); // küçük resim önbelleği (oturum boyunca)
const PAGE = 60;
const fmtDur = (ms: number) => { const s = Math.round(ms / 1000); return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`; };

export const thumbOf = async (it: GItem) => {
  const key = it.uri ?? `${it.video ? 'v' : 'i'}${it.id}`;
  const c = thumbs.get(key);
  if (c) return c;
  const u = fileSrc((it.uri ? await Gallery.thumbUri({ uri: it.uri, video: it.video }) : await Gallery.thumb({ id: it.id, video: it.video })).path);
  thumbs.set(key, u);
  return u;
};

/** Galeri karesi. Basılı tutunca onLong (çoklu seçim) */
export function Tile({ it, on, cur, onPick, onLong, root }: { it: GItem; on: number; cur?: boolean; onPick: () => void; onLong?: () => void; root: HTMLElement | null }) {
  const key = it.uri ?? `${it.video ? 'v' : 'i'}${it.id}`;
  const [src, setSrc] = useState(thumbs.get(key) ?? '');
  const ref = useRef<HTMLButtonElement>(null);
  const timer = useRef(0), longed = useRef(false), start = useRef({ x: 0, y: 0 });
  useEffect(() => {
    if (src || !ref.current) return;
    const ob = new IntersectionObserver((es) => {
      if (!es[0].isIntersecting) return;
      ob.disconnect();
      thumbOf(it).then(setSrc).catch(() => setSrc('x'));
    }, { root, rootMargin: '300px' });
    ob.observe(ref.current);
    return () => ob.disconnect();
  }, [root]);
  return (
    <button ref={ref} className={'ms-tile' + (on ? ' on' : '') + (cur ? ' cur' : '')} aria-label={it.name}
      onPointerDown={(e) => { longed.current = false; start.current = { x: e.clientX, y: e.clientY }; clearTimeout(timer.current); if (onLong) timer.current = window.setTimeout(() => { longed.current = true; navigator.vibrate?.(20); onLong(); }, 450); }}
      onPointerMove={(e) => { if (Math.hypot(e.clientX - start.current.x, e.clientY - start.current.y) > 10) clearTimeout(timer.current); }}
      onPointerUp={() => clearTimeout(timer.current)} onPointerCancel={() => clearTimeout(timer.current)}
      onContextMenu={(e) => e.preventDefault()}
      onClick={() => { if (longed.current) { longed.current = false; return; } onPick(); }}>
      {src && src !== 'x' ? <img src={src} alt="" draggable={false} /> : <span className="ms-ph" />}
      {it.video && <span className="ms-dur"><Icon name="play" size={10} />{fmtDur(it.duration)}</span>}
      {on > 0 && <span className="ms-num">{on}</span>}
    </button>
  );
}

/** Albüm/klasör listesinden sayfa getirir ('dir:' ile başlayan = kullanıcının eklediği klasör) */
export function listAlbum(kind: Kind, album: string, offset: number, limit: number) {
  if (isDir(album)) return Gallery.listFolder({ uri: album.slice(4), kind, offset, limit });
  if (kind === 'audio') return Gallery.audioList({ offset, limit, album: album || undefined });
  return Gallery.list({ offset, limit, kind, album: album || undefined });
}
export const albumLabel = (album: string, audio: boolean) => (!album ? (audio ? 'Bütün sesler' : 'Her şey') : isDir(album) ? getFolders(audio).find((f) => 'dir:' + f.uri === album)?.name ?? 'Klasör' : album);

/** Telefondaki klasörler + kendi eklediğin klasörler; en altta "+ Klasör ekle" */
export function AlbumMenu({ albums, album, audio, onPick, className, style }: { albums: { name: string; count: number }[]; album: string; audio: boolean; onPick: (a: string) => void; className?: string; style?: React.CSSProperties }) {
  const [mine, setMine] = useState(() => getFolders(audio));
  const add = async () => { try { const f = await addFolder(audio); if (f) { setMine(getFolders(audio)); onPick('dir:' + f.uri); } } catch { /* vazgeçti */ } };
  const remove = (uri: string) => { const n = mine.filter((f) => f.uri !== uri); setFolders(audio, n); setMine(n); if (album === 'dir:' + uri) onPick(''); };
  return (
    <div className={'ms-albmenu ' + (className ?? '')} role="listbox" style={style} onClick={(e) => e.stopPropagation()}>
      {[{ name: '', count: 0 }, ...albums].map((a) => (
        <button key={a.name || '*'} role="option" aria-selected={album === a.name} className={album === a.name ? 'on' : ''} onClick={() => onPick(a.name)}>
          {a.name || (audio ? 'Bütün sesler' : 'Her şey')}{a.count ? <i>{a.count}</i> : null}
        </button>
      ))}
      {mine.map((f) => (
        <div key={f.uri} className={'ms-albmine' + (album === 'dir:' + f.uri ? ' on' : '')}>
          <button role="option" aria-selected={album === 'dir:' + f.uri} onClick={() => onPick('dir:' + f.uri)}><Icon name="folder" size={18} />{f.name}</button>
          <button className="x" aria-label={`${f.name} klasörünü listeden kaldır`} onClick={() => remove(f.uri)}><Icon name="close" size={16} /></button>
        </div>
      ))}
      <button className="ms-albadd" onClick={add}><Icon name="plus" size={20} stroke={2.4} />Klasör ekle</button>
    </div>
  );
}

/** Üstteki önizleme: görsel büyük hâliyle, video oynatılabilir */
function Preview({ it, getFile }: { it: GItem; getFile: (it: GItem) => Promise<File> }) {
  const [thumb, setThumb] = useState('');
  const [url, setUrl] = useState('');
  const [loading, setLoading] = useState(false);
  useEffect(() => {
    let on = true, made = '';
    setUrl(''); setThumb(''); setLoading(false);
    thumbOf(it).then((u) => on && setThumb(u)).catch(() => {});
    if (!it.video) getFile(it).then((f) => { if (on) { made = URL.createObjectURL(f); setUrl(made); } }).catch(() => {});
    return () => { on = false; if (made) URL.revokeObjectURL(made); };
  }, [it.uri ?? it.id]);
  const playVideo = async () => {
    setLoading(true);
    try { setUrl(URL.createObjectURL(await getFile(it))); } catch { /* yok */ }
    setLoading(false);
  };
  return (
    <div className="ms-prev">
      <span className="ms-prev-name"><Icon name="info" size={16} />{it.name}</span>
      {it.video && url ? <video src={url} controls autoPlay playsInline />
        : url ? <img src={url} alt="" /> : thumb ? <img src={thumb} alt="" /> : null}
      {it.video && !url && <button className="ms-prev-play" aria-label="Videoyu oynat" onClick={playVideo}>{loading ? <span className="ms-spin" /> : <Icon name="play" size={30} />}</button>}
    </div>
  );
}

/** Ekranın 3/4'ünü kaplayan galeri: uygulamadan çıkmadan fotoğraf/video/ses seçilir */
export function MediaSheet() {
  const { req, set } = useMediaSheet();
  const [access, setAccess] = useState<'loading' | 'full' | 'partial' | 'none' | 'web'>('loading');
  const [hasPhotos, setHasPhotos] = useState(false);
  const [items, setItems] = useState<GItem[]>([]);
  const [albums, setAlbums] = useState<{ name: string; count: number }[]>([]);
  const [album, setAlbum] = useState('');
  const [albMenu, setAlbMenu] = useState(false);
  const [end, setEnd] = useState(false);
  const [sel, setSel] = useState<GItem[]>([]);
  const [multi, setMulti] = useState(false);
  const [prev, setPrev] = useState<GItem | null>(null);
  const [busy, setBusy] = useState('');
  const [err, setErr] = useState('');
  const gridRef = useRef<HTMLDivElement>(null);
  const fileRef = useRef<HTMLInputElement>(null);
  const loading = useRef(false);
  const files = useRef(new Map<string, Promise<File>>());
  const listening = useListening();

  const fkey = (it: GItem) => it.uri ?? `${it.audio ? 'a' : it.video ? 'v' : 'i'}${it.id}`;
  /** Dosyayı bir kez okur (önizleme ve ekleme aynı kopyayı kullanır) */
  const getFile = (it: GItem) => {
    let f = files.current.get(fkey(it));
    if (!f) { f = readItem(it); f.catch(() => files.current.delete(fkey(it))); files.current.set(fkey(it), f); }
    return f;
  };
  const close = (out: File[] = []) => { stopListen(); req?.resolve(out); set(null); };
  const load = async (reset = false) => {
    if (!req || loading.current || (!reset && end)) return;
    loading.current = true;
    try {
      const off = reset ? 0 : items.length;
      const r = await listAlbum(req.kind, album, off, PAGE);
      setItems((x) => (reset ? r.items : [...x, ...r.items]));
      if (reset && req.kind !== 'audio') setPrev(r.items[0] ?? null);
      setEnd(r.items.length < PAGE);
    } catch { setErr('Galeri okunamadı.'); }
    loading.current = false;
  };
  const refreshAccess = async (ask: boolean, again = false) => {
    if (!galleryNative()) { setAccess('web'); return; }
    if (req?.kind === 'audio') {
      const a = ask ? await Gallery.audioRequest() : await Gallery.audioStatus();
      setAccess(a.ok ? 'full' : 'none');
      if (a.ok) Gallery.audioAlbums().then((r) => setAlbums(r.albums)).catch(() => {});
      return;
    }
    const st = ask ? await Gallery.request({ again }) : await Gallery.status();
    setHasPhotos(st.photos);
    setAccess(st.access);
    if (st.access !== 'none') Gallery.albums().then((a) => setAlbums(a.albums)).catch(() => {});
  };

  useEffect(() => {
    if (!req) return;
    setItems([]); setSel([]); setMulti(false); setPrev(null); setEnd(false); setAlbum(''); setAlbMenu(false); setErr(''); setBusy(''); setAccess('loading');
    files.current.clear();
    refreshAccess(false).then(() => undefined);
    const back = (e: Event) => { e.preventDefault(); close(); };
    addEventListener('wm-back', back);
    return () => removeEventListener('wm-back', back);
  }, [req]);
  useEffect(() => { if (req && (access === 'full' || access === 'partial')) { setEnd(false); load(true); } }, [access, album, req]);

  if (!req) return null;

  const pick = async (list: GItem[]) => {
    setBusy(list.length > 1 ? `${list.length} dosya hazırlanıyor…` : 'Hazırlanıyor…');
    try { close(await Promise.all(list.map(getFile))); }
    catch { setBusy(''); setErr('Dosya okunamadı.'); }
  };
  const toggleSel = (it: GItem) => setSel((s) => (s.some((x) => fkey(x) === fkey(it)) ? s.filter((x) => fkey(x) !== fkey(it)) : [...s, it]));
  // Dokununca üstte önizlenir; çoklu seçimdeyken seçime de eklenir/çıkarılır
  const tap = (it: GItem) => { setPrev(it); if (multi) toggleSel(it); };
  const long = (it: GItem) => { if (!req.multiple) { setPrev(it); return; } setMulti(true); setPrev(it); if (!sel.some((x) => fkey(x) === fkey(it))) setSel((s) => [...s, it]); };
  const add = () => { if (multi && sel.length) pick(sel); else if (prev) pick([prev]); };
  const photos = async () => {
    try {
      const r = await Gallery.photos({ kind: req.kind, multiple: req.multiple });
      if (!r.files.length) return;
      setBusy('Hazırlanıyor…');
      close(await Promise.all(r.files.map(toFile)));
    } catch { setBusy(''); setErr('Google Fotoğraflar açılamadı.'); }
  };
  const accept = req.kind === 'image' ? 'image/*' : req.kind === 'video' ? 'video/*' : req.kind === 'audio' ? 'audio/*' : 'image/*,video/*';
  const aud = req.kind === 'audio';
  const ok = access === 'full' || access === 'partial';

  return (
    <div className="ms-scrim" onClick={() => close()}>
      <div className="ms" role="dialog" aria-label={req.title} onClick={(e) => e.stopPropagation()}>
        <div className="ms-grab" />
        <header className="ms-head">
          <button className="ib" aria-label="Kapat" onClick={() => close()}><Icon name="close" size={24} /></button>
          {ok ? (
            <button className="ms-album" aria-haspopup="listbox" aria-expanded={albMenu} onClick={() => setAlbMenu(!albMenu)}>{albumLabel(album, aud)}<Icon name="chevD" size={18} /></button>
          ) : <b>{req.title}</b>}
          <span style={{ flex: 1 }} />
          {!aud && ok && req.multiple && (
            <button className={'ib' + (multi ? ' on' : '')} aria-label={multi ? 'Çoklu seçimi kapat' : 'Çoklu seç'} aria-pressed={multi} onClick={() => { setMulti(!multi); setSel([]); }}><Icon name="copy" size={22} /></button>
          )}
          {!aud && ok && <button className="ib ms-plus" aria-label={multi && sel.length ? `Seçilen ${sel.length} dosyayı ekle` : 'Ekle'} disabled={!(multi ? sel.length : prev)} onClick={add}><Icon name="plus" size={26} stroke={2.4} />{multi && sel.length > 0 && <span className="ms-cnt">{sel.length}</span>}</button>}
        </header>
        {albMenu && <AlbumMenu albums={albums} album={album} audio={aud} onPick={(x) => { setAlbum(x); setAlbMenu(false); }} />}
        {!aud && ok && prev && <Preview it={prev} getFile={getFile} />}
        <div className="ms-btns">
          <button onClick={() => fileRef.current?.click()}><Icon name="folder" size={20} />Dosyalar</button>
          {!aud && (hasPhotos || access === 'web') && galleryNative() && <button onClick={photos}><span className="ms-gp" aria-hidden="true" />Google Fotoğraflar</button>}
        </div>
        {aud && ok && <div className="ms-hint">Karta basınca dinlersin, <b>+</b> ile projeye eklersin.</div>}
        {!aud && ok && req.multiple && !multi && <div className="ms-hint">Dokun: üstte önizle · <b>+</b>: ekle · Basılı tut: çoklu seç</div>}
        <input ref={fileRef} type="file" accept={accept} multiple={req.multiple} hidden onChange={(e) => { const fs = [...(e.target.files ?? [])]; e.target.value = ''; if (fs.length) close(fs); }} />

        {access === 'none' && (
          <div className="ms-perm">
            <Icon name={aud ? 'music' : 'image'} size={36} />
            <b>{aud ? 'Seslerini burada göster' : 'Galerini burada göster'}</b>
            <span>{aud ? 'Müziklerini ve ses kayıtlarını Warden Motion\'dan çıkmadan seçebilmek için izin ver.' : 'Fotoğraf ve videolarını Warden Motion\'dan çıkmadan seçebilmek için izin ver. İstersen sadece seçtiklerini de paylaşabilirsin.'}</span>
            <button className="btn" onClick={() => refreshAccess(true)}>İzin ver</button>
          </div>
        )}
        {access === 'web' && <div className="ms-perm"><span>{aud ? 'Telefondaki sesler' : 'Telefon galerisi'} uygulamada burada görünür. Şimdilik "Dosyalar" ile seç.</span></div>}
        {access === 'partial' && (
          <div className="ms-partial"><span>Sadece izin verdiğin fotoğraflar görünüyor.</span><button onClick={() => refreshAccess(true, true)}>Daha fazla seç</button></div>
        )}
        {ok && (
          <div className={'ms-grid' + (aud ? ' aud' : '')} ref={gridRef} onScroll={(e) => { const el = e.currentTarget; if (el.scrollTop + el.clientHeight > el.scrollHeight - 400) load(); }}>
            {items.map((it) => aud
              ? <AudioCard key={fkey(it)} name={it.name} dur={it.duration / 1000} playing={listening === 'g' + fkey(it)}
                  onListen={() => toggleListen('g' + fkey(it), async () => URL.createObjectURL(await getFile(it)))}
                  onAdd={() => pick([it])} />
              : <Tile key={fkey(it)} it={it} root={gridRef.current} cur={!!prev && fkey(prev) === fkey(it)} on={multi ? sel.findIndex((x) => fkey(x) === fkey(it)) + 1 : 0} onPick={() => tap(it)} onLong={() => long(it)} />)}
            {!items.length && end && <p className="ms-empty">{aud ? 'Telefonda ses dosyası bulunamadı.' : 'Burada fotoğraf yok.'}</p>}
          </div>
        )}
        {err && <div className="ms-err">{err}</div>}
        {busy && <div className="ms-busy"><span className="ms-spin" />{busy}</div>}
      </div>
    </div>
  );
}
