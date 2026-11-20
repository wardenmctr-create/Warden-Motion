import { useEffect, useRef, useState } from 'react';
import { Icon } from '../components/Icon';
import { downscale, exportBackup, importBackup, listProjects, listUserFlags, listUserPack } from '../db';
import { saveFile } from '../export';
import { askConfirm } from '../dialog';

// ---------- Profil (bu cihazda) ----------
export interface Profile { name: string; photo?: string; lastBackup?: number }
const KEY = 'wm-profile';
export const loadProfile = (): Profile => { try { return { name: '', ...JSON.parse(localStorage.getItem(KEY) || '{}') }; } catch { return { name: '' }; } };
const saveProfile = (p: Profile) => { try { localStorage.setItem(KEY, JSON.stringify(p)); } catch { /* yok */ } dispatchEvent(new Event('wm-profile')); };

export function useProfile(): [Profile, (p: Partial<Profile>) => void] {
  const [p, setP] = useState(loadProfile);
  useEffect(() => { const fn = () => setP(loadProfile()); addEventListener('wm-profile', fn); return () => removeEventListener('wm-profile', fn); }, []);
  return [p, (x) => saveProfile({ ...loadProfile(), ...x })];
}

/** Hesap simgesi: profil fotoğrafının çevresinde parlayan, dönen camgöbeği/lacivert şerit */
export function AccountAvatar({ size = 30, profile }: { size?: number; profile?: Profile }) {
  const [p0] = useProfile();
  const p = profile ?? p0;
  const letter = (p.name.trim()[0] ?? 'W').toLocaleUpperCase('tr');
  return (
    <span className="acc-av" style={{ width: size, height: size }}>
      <span className="acc-ring" />
      <span className="acc-in">{p.photo ? <img src={p.photo} alt="" /> : <b style={{ fontSize: size * 0.42 }}>{letter}</b>}</span>
    </span>
  );
}

const fmtDate = (t?: number) => (t ? new Date(t).toLocaleString('tr-TR', { day: 'numeric', month: 'long', hour: '2-digit', minute: '2-digit' }) : 'hiç yedeklenmedi');

export function AccountScreen() {
  const [p, setP] = useProfile();
  const [name, setName] = useState(p.name);
  const [stats, setStats] = useState({ projects: 0, pack: 0, flags: 0 });
  const [busy, setBusy] = useState('');
  const [msg, setMsg] = useState('');
  const photoRef = useRef<HTMLInputElement>(null);
  const restoreRef = useRef<HTMLInputElement>(null);
  const refresh = async () => setStats({ projects: (await listProjects()).length, pack: (await listUserPack()).length, flags: (await listUserFlags()).length });
  useEffect(() => { refresh(); }, []);

  const backup = async () => {
    setBusy('Yedek hazırlanıyor…'); setMsg('');
    try {
      const { blob, info } = await exportBackup({ profile: { name: p.name, photo: p.photo } });
      const d = new Date();
      const fn = `WardenMotion-yedek-${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}.json`;
      const r = await saveFile(blob, fn);
      setP({ lastBackup: Date.now() });
      setMsg(`${info.projects} proje, ${info.pack} pack öğesi, ${info.flags} bayrak yedeklendi. ${r.includes('Paylaşım') ? 'Açılan menüden "Drive\'a kaydet"i seç.' : r}`);
    } catch { setMsg('Yedek alınamadı. Tekrar dene.'); }
    setBusy('');
  };
  const restore = async (f: File) => {
    if (!(await askConfirm('Yedekten geri yüklensin mi?', 'Yedekteki projeler, pack ve bayraklar bu cihaza eklenir. Aynı projeler yedekteki hâliyle güncellenir; diğerleri silinmez.', 'Geri yükle'))) return;
    setBusy('Geri yükleniyor…'); setMsg('');
    try {
      const r = await importBackup(f);
      const prof = r.extra.profile as Partial<{ name: string; photo: string }> | undefined;
      if (prof && !p.name && prof.name) { setP({ name: prof.name, photo: prof.photo }); setName(prof.name); }
      setMsg(`${r.projects} proje, ${r.pack} pack öğesi, ${r.flags} bayrak geri yüklendi.`);
      refresh();
    } catch (e) { setMsg(e instanceof Error && e.message.includes('Warden') ? e.message : 'Bu dosya okunamadı.'); }
    setBusy('');
  };

  return (
    <div className="acc">
      <div className="acc-head">
        <button className="acc-photo" aria-label="Profil fotoğrafını değiştir" onClick={() => photoRef.current?.click()}>
          <AccountAvatar size={104} profile={p} />
          <span className="acc-cam"><Icon name="image" size={16} /></span>
        </button>
        <input className="acc-name" aria-label="Adın" placeholder="Adını yaz" value={name} maxLength={30}
          onChange={(e) => setName(e.target.value)} onBlur={() => setP({ name: name.trim() })} onKeyDown={(e) => e.key === 'Enter' && (e.target as HTMLInputElement).blur()} />
        <span className="acc-sub">{stats.projects} proje · {stats.pack} pack öğesi · {stats.flags} bayrak</span>
        <input ref={photoRef} type="file" accept="image/*" hidden onChange={async (e) => {
          const f = e.target.files?.[0];
          if (f) {
            const small = await downscale(f, 256);
            const data = await new Promise<string>((res) => { const r = new FileReader(); r.onload = () => res(String(r.result)); r.readAsDataURL(small); });
            setP({ photo: data });
          }
          e.target.value = '';
        }} />
      </div>

      <div className="acc-card">
        <div className="acc-row"><Icon name="export" size={22} /><div><b>Google Drive'a yedekle</b><span>Bütün projelerin, yüklediğin pack ve bayraklar tek dosyada. Açılan menüden "Drive'a kaydet"i seç.</span></div></div>
        <button className="btn" disabled={!!busy} onClick={backup}>{busy || 'Şimdi yedekle'}</button>
        <span className="acc-note">Son yedek: {fmtDate(p.lastBackup)}</span>
      </div>

      <div className="acc-card">
        <div className="acc-row"><Icon name="undo" size={22} /><div><b>Yedekten geri yükle</b><span>Yeni telefona geçince ya da uygulamayı silip yükleyince yedeğini Drive'dan seç.</span></div></div>
        <button className="btn ghost" disabled={!!busy} onClick={() => restoreRef.current?.click()}>Yedek dosyası seç</button>
        <input ref={restoreRef} type="file" accept="application/json,.json" hidden onChange={(e) => { const f = e.target.files?.[0]; if (f) restore(f); e.target.value = ''; }} />
      </div>

      {msg && <div className="acc-msg" role="status">{msg}</div>}

      <div className="acc-card soft">
        <div className="acc-row"><span className="acc-g">G</span><div><b>Google ile giriş</b><span>Yakında: giriş yapınca Gmail fotoğrafın otomatik gelecek, projelerin Google hesabında kendiliğinden saklanacak. Şimdilik yukarıdan elle yedekleyebilirsin.</span></div></div>
      </div>
      {p.photo && <button className="acc-link" onClick={() => setP({ photo: undefined })}>Profil fotoğrafını kaldır</button>}
    </div>
  );
}
