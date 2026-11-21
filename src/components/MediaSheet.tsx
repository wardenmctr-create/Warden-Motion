import { useEffect, useRef, useState } from 'react';
import { Icon } from './Icon';
import { fileSrc, Gallery, galleryNative, type GItem, toFile, useMediaSheet } from '../gallery';

const thumbs = new Map<string, string>(); // küçük resim önbelleği (oturum boyunca)
const PAGE = 60;
const fmtDur = (ms: number) => { const s = Math.round(ms / 1000); return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`; };

function Tile({ it, on, onPick, root }: { it: GItem; on: number; onPick: () => void; root: HTMLElement | null }) {
  const key = `${it.video ? 'v' : 'i'}${it.id}`;
  const [src, setSrc] = useState(thumbs.get(key) ?? '');
  const ref = useRef<HTMLButtonElement>(null);
  useEffect(() => {
    if (src || !ref.current) return;
    const ob = new IntersectionObserver((es) => {
      if (!es[0].isIntersecting) return;
      ob.disconnect();
      Gallery.thumb({ id: it.id, video: it.video }).then((r) => { const u = fileSrc(r.path); thumbs.set(key, u); setSrc(u); }).catch(() => setSrc('x'));
    }, { root, rootMargin: '300px' });
    ob.observe(ref.current);
    return () => ob.disconnect();
  }, [root]);
  return (
    <button ref={ref} className={'ms-tile' + (on ? ' on' : '')} aria-label={it.name} onClick={onPick}>
      {src && src !== 'x' ? <img src={src} alt="" draggable={false} /> : <span className="ms-ph" />}
      {it.video && <span className="ms-dur"><Icon name="play" size={10} />{fmtDur(it.duration)}</span>}
      {on > 0 && <span className="ms-num">{on}</span>}
    </button>
  );
}

/** Ekranın 3/4'ünü kaplayan galeri: uygulamadan çıkmadan fotoğraf/video seçilir */
export function MediaSheet() {
  const { req, set } = useMediaSheet();
  const [access, setAccess] = useState<'loading' | 'full' | 'partial' | 'none' | 'web'>('loading');
  const [hasPhotos, setHasPhotos] = useState(false);
  const [items, setItems] = useState<GItem[]>([]);
  const [albums, setAlbums] = useState<{ name: string; count: number }[]>([]);
  const [album, setAlbum] = useState('');
  const [end, setEnd] = useState(false);
  const [sel, setSel] = useState<GItem[]>([]);
  const [busy, setBusy] = useState('');
  const [err, setErr] = useState('');
  const gridRef = useRef<HTMLDivElement>(null);
  const fileRef = useRef<HTMLInputElement>(null);
  const loading = useRef(false);

  const close = (files: File[] = []) => { req?.resolve(files); set(null); };
  const load = async (reset = false) => {
    if (!req || loading.current || (!reset && end)) return;
    loading.current = true;
    try {
      const r = await Gallery.list({ offset: reset ? 0 : items.length, limit: PAGE, kind: req.kind, album: album || undefined });
      setItems((x) => (reset ? r.items : [...x, ...r.items]));
      setEnd(r.items.length < PAGE);
    } catch { setErr('Galeri okunamadı.'); }
    loading.current = false;
  };
  const refreshAccess = async (ask: boolean, again = false) => {
    if (!galleryNative()) { setAccess('web'); return; }
    const st = ask ? await Gallery.request({ again }) : await Gallery.status();
    setHasPhotos(st.photos);
    setAccess(st.access);
    if (st.access !== 'none') Gallery.albums().then((a) => setAlbums(a.albums)).catch(() => {});
  };

  useEffect(() => {
    if (!req) return;
    setItems([]); setSel([]); setEnd(false); setAlbum(''); setErr(''); setBusy(''); setAccess('loading');
    refreshAccess(false).then(() => undefined);
    const back = (e: Event) => { e.preventDefault(); close(); };
    addEventListener('wm-back', back);
    return () => removeEventListener('wm-back', back);
  }, [req]);
  useEffect(() => { if (req && (access === 'full' || access === 'partial')) { setEnd(false); load(true); } }, [access, album, req]);

  if (!req) return null;

  const pick = async (list: GItem[]) => {
    setBusy(list.length > 1 ? `${list.length} dosya hazırlanıyor…` : 'Hazırlanıyor…');
    try { close(await Promise.all(list.map(async (it) => toFile(await Gallery.read({ id: it.id, video: it.video }))))); }
    catch { setBusy(''); setErr('Dosya okunamadı.'); }
  };
  const tap = (it: GItem) => {
    if (!req.multiple) { pick([it]); return; }
    setSel((s) => (s.some((x) => x.id === it.id) ? s.filter((x) => x.id !== it.id) : [...s, it]));
  };
  const photos = async () => {
    try {
      const r = await Gallery.photos({ kind: req.kind, multiple: req.multiple });
      if (!r.files.length) return;
      setBusy('Hazırlanıyor…');
      close(await Promise.all(r.files.map(toFile)));
    } catch { setBusy(''); setErr('Google Fotoğraflar açılamadı.'); }
  };
  const accept = req.kind === 'image' ? 'image/*' : req.kind === 'video' ? 'video/*' : 'image/*,video/*';

  return (
    <div className="ms-scrim" onClick={() => close()}>
      <div className="ms" role="dialog" aria-label={req.title} onClick={(e) => e.stopPropagation()}>
        <div className="ms-grab" />
        <header className="ms-head">
          <b>{req.title}</b>
          <span style={{ flex: 1 }} />
          <button className="ib" aria-label="Kapat" onClick={() => close()}><Icon name="close" size={22} /></button>
        </header>
        <div className="ms-btns">
          <button onClick={() => fileRef.current?.click()}><Icon name="folder" size={20} />Dosyalar</button>
          {(hasPhotos || access === 'web') && galleryNative() && <button onClick={photos}><span className="ms-gp" aria-hidden="true" />Google Fotoğraflar</button>}
        </div>
        <input ref={fileRef} type="file" accept={accept} multiple={req.multiple} hidden onChange={(e) => { const fs = [...(e.target.files ?? [])]; e.target.value = ''; if (fs.length) close(fs); }} />

        {access === 'none' && (
          <div className="ms-perm">
            <Icon name="image" size={36} />
            <b>Galerini burada göster</b>
            <span>Fotoğraf ve videolarını Warden Motion'dan çıkmadan seçebilmek için izin ver. İstersen sadece seçtiklerini de paylaşabilirsin.</span>
            <button className="btn" onClick={() => refreshAccess(true)}>İzin ver</button>
          </div>
        )}
        {access === 'web' && <div className="ms-perm"><span>Telefon galerisi uygulamada burada görünür. Şimdilik "Dosyalar" ile seç.</span></div>}
        {access === 'partial' && (
          <div className="ms-partial"><span>Sadece izin verdiğin fotoğraflar görünüyor.</span><button onClick={() => refreshAccess(true, true)}>Daha fazla seç</button></div>
        )}
        {(access === 'full' || access === 'partial') && albums.length > 1 && (
          <div className="ms-albums">
            <button className={album === '' ? 'on' : ''} onClick={() => setAlbum('')}>Tümü</button>
            {albums.map((a) => <button key={a.name} className={album === a.name ? 'on' : ''} onClick={() => setAlbum(a.name)}>{a.name}</button>)}
          </div>
        )}
        {(access === 'full' || access === 'partial') && (
          <div className="ms-grid" ref={gridRef} onScroll={(e) => { const el = e.currentTarget; if (el.scrollTop + el.clientHeight > el.scrollHeight - 400) load(); }}>
            {items.map((it) => <Tile key={`${it.video ? 'v' : 'i'}${it.id}`} it={it} root={gridRef.current} on={sel.findIndex((x) => x.id === it.id) + 1} onPick={() => tap(it)} />)}
            {!items.length && end && <p className="ms-empty">Burada fotoğraf yok.</p>}
          </div>
        )}
        {err && <div className="ms-err">{err}</div>}
        {req.multiple && sel.length > 0 && <button className="btn ms-add" onClick={() => pick(sel)}>Ekle ({sel.length})</button>}
        {busy && <div className="ms-busy"><span className="ms-spin" />{busy}</div>}
      </div>
    </div>
  );
}
