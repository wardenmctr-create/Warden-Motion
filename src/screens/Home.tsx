import { useEffect, useMemo, useRef, useState } from 'react';
import { Icon } from '../components/Icon';
import { deleteProject, exportBackup, listProjects, saveProject } from '../db';
import { uid } from '../anim';
import { saveFile } from '../export';
import { newProject, TEMPLATES, TUTORIALS, type Tutorial } from '../factories';
import { fmtTime, projectDuration } from '../anim';
import { renderFrame, setImageLoadedHandler } from '../render';
import { detectWeakDevice, useStore } from '../store';
import { askConfirm } from '../dialog';
import { replayIntro } from '../assistant/Assistant';
import { APP_VERSION } from '../assistant/engine';
import { WardenCB } from '../components/WardenCB';
import { AccountAvatar, AccountScreen } from './Account';
import type { Project } from '../types';

export function Thumb({ p, size = 80, t = 0.6, round = false }: { p: Project; size?: number; t?: number; round?: boolean }) {
  const ref = useRef<HTMLCanvasElement>(null);
  const [tick, setTick] = useState(0);
  useEffect(() => {
    const c = ref.current;
    if (!c) return;
    const s = size / Math.max(p.width, p.height) * (round ? Math.max(p.width, p.height) / Math.min(p.width, p.height) : 1);
    c.width = Math.round(p.width * s * 2); c.height = Math.round(p.height * s * 2);
    const ctx = c.getContext('2d')!;
    renderFrame(ctx, p, Math.min(t, projectDuration(p) - 0.01), { quality: s * 2 });
    const id = setTimeout(() => setTick((x) => x + 1), 500);
    return () => clearTimeout(id);
  }, [p, size, t, round, tick < 3 ? tick : 3]);
  return <canvas ref={ref} style={{ width: round ? '100%' : undefined, height: round ? '100%' : undefined, objectFit: 'cover' }} />;
}

export function Home() {
  const { go, open, screen } = useStore();
  const lite = useStore((x) => x.settings.lite);
  const [projects, setProjects] = useState<Project[]>([]);
  const [sheet, setSheet] = useState(false);
  const [drawer, setDrawer] = useState(false);
  const tpls = useMemo(() => TEMPLATES.map((t) => ({ t, p: t.make() })), []);
  const refresh = () => listProjects().then(setProjects);
  useEffect(() => { refresh(); setImageLoadedHandler(() => setProjects((x) => [...x])); }, []);
  useEffect(() => { if (screen === 'home') refresh(); }, [screen]);
  // Android geri tuşu: açık panel/çekmeceyi kapat
  const open2 = useRef({ sheet, drawer });
  open2.current = { sheet, drawer };
  useEffect(() => {
    const fn = (e: Event) => {
      if (open2.current.sheet) { setSheet(false); e.preventDefault(); }
      else if (open2.current.drawer) { setDrawer(false); e.preventDefault(); }
    };
    addEventListener('wm-back', fn);
    return () => removeEventListener('wm-back', fn);
  }, []);

  const startTutorial = (tu: Tutorial) => {
    const p = { ...newProject(tu.title, tu.ratio[0], tu.ratio[1], 30, tu.bg), tutorial: tu.id };
    open(p);
  };

  return (
    <div className="home">
      <header className="home-top">
        <button className="ib" aria-label="Ayarlar menüsü" onClick={() => setDrawer(true)}><Icon name="menu" size={26} stroke={2} /></button>
        <div className="brand">Warden Motion{lite && <span className="badge" style={{ fontSize: 11 }}>Lite</span>}<img src="logo.png" alt="" /></div>
        <button className="ib" aria-label="Hesap" onClick={() => go('account')} style={{ width: 44, height: 44 }}><AccountAvatar size={34} /></button>
      </header>

      <main className="home-body">
        {screen === 'account' ? <AccountScreen /> : screen === 'tutorials' ? (
          <>
            <div className="sec-head"><h2>Öğreticiler</h2><span>8 proje · 3 CB · 5 genel</span></div>
            <div className="tut-grid">
              {TUTORIALS.map((tu) => {
                const lvls = ['Temel', 'Temel-Orta', 'Orta', 'Orta-Ayrıntılı', 'Ayrıntılı'];
                const n = lvls.indexOf(tu.level) + 1;
                return (
                  <button key={tu.id} className="tut" disabled={!tu.ready} onClick={() => tu.ready && startTutorial(tu)} style={{ opacity: tu.ready ? 1 : 0.75 }}>
                    <div className="badges">
                      <span className={'badge' + (tu.kind === 'CB' ? ' cb' : '')}>{tu.kind}</span>
                      {!tu.ready && <span className="badge soon">Yakında</span>}
                    </div>
                    <h3>{tu.title}</h3>
                    <div className="lv" aria-label={`Seviye ${n}/5`}>{lvls.map((_, i) => <i key={i} className={i < n ? 'on' : ''} />)}</div>
                    <p>{tu.summary}</p>
                  </button>
                );
              })}
            </div>
          </>
        ) : (
          <>
            <div className="sec-head"><h2>Yeni Şablonlar</h2><span>Dokun ve aç</span></div>
            <div className="tpl-row">
              {tpls.map(({ t, p }) => {
                return (
                  <button key={t.id} className="tpl" onClick={() => open(t.make())}>
                    <div className="ring"><Thumb p={p} size={64} t={1.6} round /></div>{t.name}
                  </button>
                );
              })}
              {TUTORIALS.filter((t) => t.ready).map((tu) => (
                <button key={tu.id} className="tpl" onClick={() => startTutorial(tu)}>
                  <div className="ring" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#DCE6F5', color: '#1F68E0' }}><Icon name="cap" size={30} /></div>{tu.title}
                </button>
              ))}
            </div>

            <div className="sec-head"><h2>Son projeler</h2><span>{projects.length} proje</span></div>
            <button className="new-card" onClick={() => setSheet(true)}><span className="dot-plus"><Icon name="plus" size={18} stroke={2.4} /></span>Yeni Proje Oluştur</button>
            <ProjectList projects={projects} refresh={refresh} />
            {!projects.length && <p className="empty">Henüz proje yok. Yukarıdaki şablonlardan birini aç ya da yeni proje oluştur.</p>}
          </>
        )}
      </main>

      <nav className="nav" aria-label="Ana menü">
        <button className={screen === 'home' ? 'on' : ''} onClick={() => go('home')}><Icon name="home" size={24} fill={screen === 'home'} />Ana Sayfa</button>
        <button className={screen === 'tutorials' ? 'on' : ''} onClick={() => go('tutorials')}><Icon name="cap" size={24} />Öğreticiler</button>
        <span style={{ minWidth: 64 }} />
        <button className={'accbtn' + (screen === 'account' ? ' on' : '')} onClick={() => go('account')}><AccountAvatar size={28} />Hesap</button>
        <button onClick={() => go('home')}><Icon name="grid" size={24} />Şablonlar</button>
        <button className="fab" aria-label="Yeni proje" onClick={() => setSheet(true)}><Icon name="plus" size={28} stroke={2.2} /></button>
      </nav>

      {sheet && <NewProjectSheet onClose={() => setSheet(false)} count={projects.length} />}
      {drawer && <SettingsDrawer onClose={() => setDrawer(false)} />}
    </div>
  );
}

const RATIOS: { k: string; w: number; h: number; bw: number; bh: number }[] = [
  { k: '16:9', w: 16, h: 9, bw: 56, bh: 30 }, { k: '9:16', w: 9, h: 16, bw: 31, bh: 54 }, { k: '4:5', w: 4, h: 5, bw: 31, bh: 38 },
  { k: '1:1', w: 1, h: 1, bw: 31, bh: 31 }, { k: '4:3', w: 4, h: 3, bw: 41, bh: 31 },
];

function NewProjectSheet({ onClose, count }: { onClose: () => void; count: number }) {
  const open = useStore((s) => s.open);
  const [name, setName] = useState(`Yeni Proje ${count + 1}`);
  const [ratio, setRatio] = useState('4:5');
  const [res, setRes] = useState(720);
  const [fps, setFps] = useState(30);
  const [bg, setBg] = useState('#FFFFFF');
  const r = RATIOS.find((x) => x.k === ratio)!;
  // Kısa kenar = seçilen çözünürlük
  const dims = r.w >= r.h ? [Math.round(res * r.w / r.h / 2) * 2, res] : [res, Math.round(res * r.h / r.w / 2) * 2];
  return (
    <div className="scrim" onClick={onClose}>
      <div className="sheet" role="dialog" aria-label="Yeni proje" onClick={(e) => e.stopPropagation()}>
        <div className="seg"><button className="on">PROJE</button><button disabled title="Yakında">ELEMENT</button></div>
        <label className="field">
          <span style={{ position: 'absolute', width: 1, height: 1, overflow: 'hidden' }}>Proje adı</span>
          <input value={name} onChange={(e) => setName(e.target.value)} />
          <button className="ib" aria-label="Adı temizle" onClick={() => setName('')} style={{ width: 32, height: 32 }}><Icon name="close" size={16} /></button>
        </label>
        <div className="ratios">
          {RATIOS.map((x) => (
            <button key={x.k} className={'ratio' + (x.k === ratio ? ' on' : '')} style={{ width: x.bw, height: x.bh }} onClick={() => setRatio(x.k)}>{x.k}</button>
          ))}
        </div>
        <div className="rows">
          <div>Çözünürlük<small>Kompozisyon Boyutu</small><small>{dims[0]} × {dims[1]}</small></div>
          <select className="sel" value={res} onChange={(e) => setRes(+e.target.value)}>
            <option value={480}>480p</option><option value={720}>720p (HD)</option><option value={1080}>1080p (Full HD)</option>
          </select>
          <div>Kare Hızı</div>
          <select className="sel" value={fps} onChange={(e) => setFps(+e.target.value)}>
            <option value={24}>24 fps</option><option value={30}>30 fps</option><option value={60}>60 fps</option>
          </select>
          <div>Arka Fon</div>
          <label className="colorpick"><input type="color" value={bg} onChange={(e) => setBg(e.target.value.toUpperCase())} /><span style={{ flex: 1 }}>{bg === '#FFFFFF' ? 'Beyaz' : bg}</span></label>
        </div>
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 22 }}>
          <button className="textbtn" onClick={() => open(newProject(name || 'Adsız Proje', dims[0], dims[1], fps, bg))}>PROJE OLUŞTUR</button>
        </div>
        <div style={{ display: 'flex', justifyContent: 'center', marginTop: 18 }}>
          <button className="ib" aria-label="Kapat" onClick={onClose}><Icon name="close" size={24} stroke={2} /></button>
        </div>
      </div>
    </div>
  );
}

function SettingsDrawer({ onClose }: { onClose: () => void }) {
  const { settings, setSettings } = useStore();
  return (
    <>
      <div className="drawer-scrim" onClick={onClose} />
      <aside className="drawer" aria-label="Ayarlar">
        <h1>Ayarlar</h1>
        <div className="group">
          <div className="row" style={{ alignItems: 'flex-start', paddingTop: 12 }}>
            <span>Warden Motion Lite
              <span style={{ display: 'block', fontSize: 12, fontWeight: 400, color: 'var(--l-text2)', marginTop: 4 }}>
                Zayıf telefonlarda kasmayı önler: önizleme daha düşük çözünürlükte olur, oynatırken bulanıklık/parlama gösterilmez (dışa aktarılan videoda vardır).
                {settings.liteSource === 'auto' ? (settings.lite ? ' Cihazın için otomatik açıldı.' : ' Cihazın güçlü görünüyor, otomatik kapalı.') : ''}
              </span>
            </span>
            <button className={'switch' + (settings.lite ? ' on' : '')} role="switch" aria-checked={settings.lite} aria-label="Warden Motion Lite" onClick={() => setSettings({ lite: !settings.lite, liteSource: 'user' })} style={{ marginTop: 4 }} />
          </div>
          {settings.liteSource === 'user' && (
            <div className="row"><span style={{ fontWeight: 400, fontSize: 13 }}>Lite'ı yine cihaza göre otomatik seç</span>
              <button className="chip" style={{ background: 'var(--l-card)', color: 'var(--l-primary)', height: 32 }} onClick={() => setSettings({ liteSource: 'auto', lite: detectWeakDevice() })}>Otomatik</button>
            </div>
          )}
          <div className="row">Varsayılan Katman Süresi
            <select className="sel" style={{ width: 90, height: 40 }} value={settings.defaultDuration} onChange={(e) => setSettings({ defaultDuration: +e.target.value })}>
              {[1, 2, 3, 5, 10].map((n) => <option key={n} value={n}>{n}s</option>)}
            </select>
          </div>
        </div>
        <button className="linkrow wa-meet" onClick={() => { onClose(); setTimeout(replayIntro, 250); }}>
          <WardenCB size={54} mood="wave" />
          <span><b>WardenCB ile tanış</b><small>Asistanı ve uygulama turunu yeniden başlat</small></span>
        </button>
        <div className="linkrow" style={{ height: 'auto', padding: 14, flexDirection: 'column', alignItems: 'flex-start', gap: 6 }}>
          <b>Hakkında</b>
          <span style={{ fontSize: 13, color: 'var(--l-text2)' }}>Warden Motion v{APP_VERSION} · Deneme sürümü. Projelerin ve yüklediğin pack'ler bu cihazda saklanır.</span>
        </div>
        <div className="linkrow" style={{ height: 'auto', padding: 14, flexDirection: 'column', alignItems: 'flex-start', gap: 6 }}>
          <b>Açık Kaynak Kütüphaneleri</b>
          <span style={{ fontSize: 13, color: 'var(--l-text2)' }}>React, Zustand, Capacitor, idb-keyval, flag-icons (MIT)</span>
        </div>
      </aside>
    </>
  );
}

// ---------- Projeler: ⋯ menüsü ve basılı tutarak çoklu seçim ----------
function ProjectList({ projects, refresh }: { projects: Project[]; refresh: () => void }) {
  const open = useStore((x) => x.open);
  const [sel, setSel] = useState<Set<string> | null>(null);
  const [menu, setMenu] = useState<{ p: Project; x: number; y: number; up: boolean } | null>(null);
  const [note, setNote] = useState('');
  const press = useRef<{ id: string; t: ReturnType<typeof setTimeout>; x: number; y: number; fired: boolean } | null>(null);
  const say = (m: string) => { setNote(m); setTimeout(() => setNote(''), 3200); };
  // Android geri tuşu: önce menü, sonra seçim kapanır
  const st = useRef({ sel, menu }); st.current = { sel, menu };
  useEffect(() => {
    const fn = (e: Event) => {
      if (st.current.menu) { setMenu(null); e.preventDefault(); }
      else if (st.current.sel) { setSel(null); e.preventDefault(); }
    };
    addEventListener('wm-back', fn);
    return () => removeEventListener('wm-back', fn);
  }, []);

  const toggle = (id: string) => setSel((s0) => {
    const s1 = new Set(s0 ?? []);
    if (s1.has(id)) s1.delete(id); else s1.add(id);
    return s1.size ? s1 : null;
  });
  const duplicate = async (ps: Project[]) => {
    for (const p of ps) await saveProject({ ...structuredClone(p), id: uid(), name: `${p.name} (kopya)`.slice(0, 40), updatedAt: Date.now() });
    refresh(); say(ps.length > 1 ? `${ps.length} proje çoğaltıldı.` : 'Proje çoğaltıldı.');
  };
  const remove = async (ps: Project[]) => {
    const one = ps.length === 1;
    if (!(await askConfirm(one ? 'Proje silinsin mi?' : `${ps.length} proje silinsin mi?`, one ? `"${ps[0].name}" kalıcı olarak silinecek.` : 'Seçilen projeler kalıcı olarak silinecek.', 'Sil'))) return;
    for (const p of ps) await deleteProject(p.id);
    setSel(null); refresh();
  };
  const upload = async (ps: Project[]) => {
    say('Hazırlanıyor…');
    const { blob } = await exportBackup({}, ps.map((p) => p.id));
    const safe = (ps.length === 1 ? ps[0].name : `${ps.length}-proje`).replace(/[^\p{L}\p{N}]+/gu, '-').slice(0, 30);
    const r = await saveFile(blob, `WardenMotion-${safe}.json`);
    say(r.includes('Paylaşım') ? 'Açılan menüden "Drive\'a kaydet"i seç.' : r);
  };
  const exportVideo = (p: Project) => { useStore.setState({ autoExport: true }); open(p); };

  const down = (e: React.PointerEvent, p: Project) => {
    const t = setTimeout(() => {
      if (!press.current) return;
      press.current.fired = true;
      navigator.vibrate?.(25);
      toggle(p.id);
    }, 450);
    press.current = { id: p.id, t, x: e.clientX, y: e.clientY, fired: false };
  };
  const move = (e: React.PointerEvent) => { const pr = press.current; if (pr && Math.hypot(e.clientX - pr.x, e.clientY - pr.y) > 10) { clearTimeout(pr.t); press.current = null; } };
  const up = () => { if (press.current && !press.current.fired) clearTimeout(press.current.t); };
  const click = (p: Project) => {
    const pr = press.current; press.current = null;
    if (pr?.fired) return; // basılı tutma seçti, tıklama sayılmaz
    if (sel) toggle(p.id); else open(p);
  };
  const chosen = projects.filter((p) => sel?.has(p.id));
  useEffect(() => { document.body.classList.toggle('psel-on', !!sel); return () => document.body.classList.remove('psel-on'); }, [!!sel]);

  return (
    <>
      {sel && (
        <div className="selbar" role="toolbar" aria-label="Seçili projeler">
          <b>{sel.size} seçildi</b>
          <span style={{ flex: 1 }} />
          <button className="seltxt" onClick={() => setSel(null)}>İptal</button>
        </div>
      )}
      {sel && (
        <div className="selacts" role="toolbar" aria-label="Seçilenlerle yap">
          <button onClick={() => upload(chosen)}><Icon name="share" size={24} stroke={1.7} />Dışa Aktar</button>
          <button onClick={() => duplicate(chosen)}><Icon name="copy" size={24} stroke={1.7} />Çoğalt</button>
          <button onClick={() => remove(chosen)}><Icon name="trash" size={24} stroke={1.7} />Sil</button>
        </div>
      )}
      <div className="plist">
        {projects.map((p) => {
          const on = !!sel?.has(p.id);
          return (
            <div key={p.id} className={'projrow' + (sel ? ' selmode' : '') + (sel && !on ? ' dim' : '')}>
              {sel && <span className={'pradio' + (on ? ' on' : '')} aria-hidden="true" onClick={() => toggle(p.id)} />}
              <button className={'pcard' + (on ? ' sel' : '')} data-pid={p.id} aria-pressed={sel ? on : undefined}
                onPointerDown={(e) => down(e, p)} onPointerMove={move} onPointerUp={up} onPointerCancel={up} onContextMenu={(e) => e.preventDefault()} onClick={() => click(p)}>
                <div className="pthumb"><Thumb p={p} /><span className="dur">{fmtTime(projectDuration(p), p.fps)}</span></div>
                <div className="pmeta">
                  <b>{p.name}</b>
                  <span>{p.width}x{p.height} · {p.fps}fps</span>
                  <span>{p.layers.length} katman · {new Date(p.updatedAt).toLocaleDateString('tr-TR')}</span>
                </div>
              </button>
              {!sel && (
                <button className="ib pmore" aria-label={`${p.name} seçenekleri`} onClick={(e) => {
                  const r = (e.currentTarget as HTMLElement).getBoundingClientRect();
                  setMenu({ p, x: innerWidth - r.right, y: r.bottom, up: r.bottom > innerHeight - 330 });
                }}><Icon name="more" size={24} stroke={3} /></button>
              )}
            </div>
          );
        })}
      </div>
      {menu && (
        <div className="pmenu-scrim" onClick={() => setMenu(null)}>
          <div className="pmenu" role="menu" aria-label={`${menu.p.name} seçenekleri`} onClick={(e) => e.stopPropagation()}
            style={menu.up ? { right: Math.max(12, menu.x), bottom: innerHeight - menu.y + 44 } : { right: Math.max(12, menu.x), top: menu.y + 4 }}>
            {([
              ['Seç', 'hand', () => setSel(new Set([menu.p.id]))],
              ['Dışa Aktar', 'share', () => exportVideo(menu.p)],
              ['Çoğalt', 'copy', () => duplicate([menu.p])],
              ['Buluta Yükle', 'cloudUp', () => upload([menu.p])],
              ['Sil', 'trash', () => remove([menu.p])],
            ] as [string, string, () => void][]).map(([label, icon, fn]) => (
              <button key={label} role="menuitem" onClick={() => { setMenu(null); fn(); }}><span>{label}</span><Icon name={icon} size={26} stroke={1.6} /></button>
            ))}
          </div>
        </div>
      )}
      {note && <div className="hnote" role="status">{note}</div>}
    </>
  );
}
