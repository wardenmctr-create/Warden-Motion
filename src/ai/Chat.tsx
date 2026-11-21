import { useEffect, useRef, useState } from 'react';
import { create } from 'zustand';
import { WardenCB, POSES, type Mood } from '../components/WardenCB';
import { Icon } from '../components/Icon';
import { useStore } from '../store';
import { AI_ENABLED } from '../features';
import { AiError, aiConfigured, askAI, DEFAULT_MODEL, KEY_URL, loadAi, type Msg, type Provider, saveAi } from './client';
import { brainStatus, brainSupported, openBrain, type BrainStatus } from './brain';
import { systemPrompt } from './prompt';
import { type Act, runActions } from './actions';

interface ChatMsg { role: 'user' | 'model'; text: string; raw?: string; mood?: Mood; note?: string; err?: boolean }
interface ChatState { open: boolean; msgs: ChatMsg[]; busy: boolean; partial: number; setPartial: (n: number) => void; setOpen: (b: boolean) => void; push: (m: ChatMsg) => void; setBusy: (b: boolean) => void; clear: () => void }
export const useChat = create<ChatState>((set) => ({
  open: false, msgs: [], busy: false, partial: 0,
  setPartial: (partial) => set({ partial }),
  setOpen: (open) => set({ open }),
  push: (m) => set((s) => ({ msgs: [...s.msgs, m].slice(-40) })),
  setBusy: (busy) => set({ busy }),
  clear: () => set({ msgs: [] }),
}));

/** Yapay zekânın JSON cevabını ayıkla (``` içinde gelse bile) */
function parse(text: string): { say: string; mood: Mood; actions: Act[] } {
  let t = text.trim().replace(/^```(?:json)?/i, '').replace(/```$/, '').trim();
  const a = t.indexOf('{'), b = t.lastIndexOf('}');
  if (a >= 0 && b > a) t = t.slice(a, b + 1);
  try {
    const j = JSON.parse(t);
    const mood = (typeof j.mood === 'string' && j.mood in POSES ? j.mood : 'happy') as Mood;
    const actions = Array.isArray(j.actions) ? j.actions.filter((x: unknown) => x && typeof x === 'object' && typeof (x as Act).do === 'string') : [];
    return { say: typeof j.say === 'string' && j.say ? j.say : 'Tamamdır!', mood, actions };
  } catch {
    return { say: text.slice(0, 600), mood: 'confused', actions: [] };
  }
}

const EXAMPLES = [
  'Zıplayan bir top animasyonu yap',
  'Türkiye ve Almanya CB konuşma şablonu yap',
  'Ekranda dönen yıldızlarla "Hoş geldin" yazısı yap',
  'Bayrağı nasıl kırparım?',
  'Keyframe nasıl eklenir?',
];

export async function sendToAI(text: string) {
  const c = useChat.getState();
  if (c.busy || !text.trim()) return;
  c.push({ role: 'user', text: text.trim() });
  c.setBusy(true);
  try {
    const hist: Msg[] = useChat.getState().msgs.filter((m) => !m.err).slice(-12).map((m) => ({ role: m.role, text: m.role === 'model' ? m.raw ?? m.text : m.text }));
    const ai = loadAi();
    useChat.getState().setPartial(0);
    const raw = await askAI(await systemPrompt(ai.provider === 'offline'), hist, ai, (t) => useChat.getState().setPartial(t.length));
    const r = parse(raw);
    let note = '';
    if (r.actions.length) {
      const res = await runActions(r.actions, r.say);
      const made = res.done.length;
      note = [made ? `${made} iş yapıldı${res.created ? ', yeni proje açıldı' : ''}` : '', res.skipped.length ? `yapılamayan: ${res.skipped.slice(0, 3).join(', ')}` : ''].filter(Boolean).join(' · ');
      // Yapılanı görsün diye pencereyi kapat (proje değiştiyse ya da ekranda gösterilecekse)
      if (made || res.show) setTimeout(() => useChat.getState().setOpen(false), 600);
    }
    useChat.getState().push({ role: 'model', text: r.say, raw, mood: r.mood, note });
  } catch (e) {
    useChat.getState().push({ role: 'model', text: e instanceof AiError ? e.message : 'Bir şeyler ters gitti. Tekrar dener misin?', mood: 'worried', err: true });
  } finally {
    useChat.getState().setBusy(false);
  }
}

function OfflineInfo() {
  const [st, setSt] = useState<BrainStatus | null>(null);
  useEffect(() => {
    let on = true;
    const tick = () => brainStatus().then((x) => on && setSt(x));
    tick();
    const id = setInterval(tick, 3000);
    return () => { on = false; clearInterval(id); };
  }, []);
  if (!brainSupported()) return <p className="aic-help">İnternetsiz WardenCB sadece Android uygulamasında çalışır.</p>;
  if (!st) return <p className="aic-help">WardenCB Beyin aranıyor…</p>;
  if (!st.installed) return (
    <p className="aic-help">WardenCB Beyin bu telefonda yüklü değil. Sana verdiğim <b>WardenCB-Beyin.apk</b> dosyasını yükle, sonra buraya dön. Warden Motion'ın boyutu büyümez; model ayrı uygulamada durur.</p>
  );
  return (
    <div className="aic-brain">
      <span className={'aic-dot ' + (st.downloaded ? 'ok' : 'wait')} />
      <div>
        <b>{st.downloaded ? 'WardenCB Beyin hazır' : 'Model indirilmedi'}</b>
        <span>{st.downloaded ? `${st.model}${st.loaded ? ` · bellekte (${st.backend})` : ' · ilk soruda belleğe yüklenir'}` : 'Beyin uygulamasını açıp "Modeli indir"e dokun (yaklaşık 1,6 GB, Wi‑Fi önerilir).'}</span>
      </div>
      <button className="btn ghost" onClick={() => openBrain()}>WardenCB Beyin'i aç</button>
    </div>
  );
}

function Settings({ onDone }: { onDone: () => void }) {
  const [s, setS] = useState(loadAi);
  return (
    <div className="aic-set">
      <div className="aic-bub model"><WardenCB size={54} mood="think" /><p>Konuşabilmem için ya internetsiz beynimi (WardenCB Beyin uygulaması) ya da ücretsiz bir yapay zekâ anahtarını seç.</p></div>
      <label className="aic-field"><span>Servis</span>
        <select className="sel" value={s.provider} onChange={(e) => { const provider = e.target.value as Provider; setS({ ...s, provider, model: DEFAULT_MODEL[provider] }); }}>
          <option value="gemini">Google Gemini (ücretsiz kota)</option>
          <option value="groq">Groq (ücretsiz kota)</option>
          <option value="offline">İnternetsiz (WardenCB Beyin)</option>
        </select>
      </label>
      {s.provider === 'offline' ? <OfflineInfo /> : <>
      <p className="aic-help">1) Şu adrese gir ve ücretsiz anahtar oluştur:<br /><a href={KEY_URL[s.provider]} target="_blank" rel="noreferrer">{KEY_URL[s.provider].replace('https://', '')}</a><br />2) Anahtarı kopyalayıp aşağıya yapıştır.</p>
      <label className="aic-field"><span>Anahtar</span>
        <input className="dinput" type="password" autoComplete="off" placeholder="Anahtarı yapıştır" value={s.key} onChange={(e) => setS({ ...s, key: e.target.value.trim() })} />
      </label>
      <label className="aic-field"><span>Model</span>
        <input className="dinput" value={s.model} onChange={(e) => setS({ ...s, model: e.target.value.trim() })} />
      </label>
      <p className="aic-help small">Ücretsiz kotada yazdıkların servis tarafından incelenebilir; kişisel bilgi yazma. İnternet yoksa öğreticiler yine çalışır.</p>
      </>}
      <div className="aic-row">
        {s.key && s.provider !== 'offline' && <button className="btn ghost" onClick={() => { saveAi({ ...s, key: '' }); setS({ ...s, key: '' }); }}>Anahtarı sil</button>}
        <span style={{ flex: 1 }} />
        <button className="btn" disabled={!aiConfigured(s)} onClick={() => { saveAi({ ...s, model: s.model || DEFAULT_MODEL[s.provider] }); onDone(); }}>Kaydet</button>
      </div>
    </div>
  );
}

export function AiChat() {
  if (!AI_ENABLED) return null;
  return <AiChatInner />;
}

function AiChatInner() {
  const { open, msgs, busy, partial, setOpen, clear } = useChat();
  const [text, setText] = useState('');
  const [settings, setSettings] = useState(false);
  const [, setVer] = useState(0);
  const listRef = useRef<HTMLDivElement>(null);
  // Anahtar yoksa ve Beyin hazırsa kendiliğinden internetsiz WardenCB'yi seç
  useEffect(() => {
    if (!open || aiConfigured()) return;
    brainStatus().then((st) => { if (st.installed && st.downloaded) { saveAi({ ...loadAi(), provider: 'offline', model: DEFAULT_MODEL.offline }); setVer((v) => v + 1); } });
  }, [open]);
  useEffect(() => { listRef.current?.scrollTo({ top: 1e6, behavior: 'smooth' }); }, [msgs.length, busy, open]);
  useEffect(() => {
    if (!open) return;
    const fn = (e: Event) => { e.preventDefault(); setOpen(false); };
    addEventListener('wm-back', fn);
    return () => removeEventListener('wm-back', fn);
  }, [open]);
  if (!open) return null;
  const noKey = !aiConfigured();
  const last = [...msgs].reverse().find((m) => m.role === 'model');
  const send = () => { if (text.trim()) { sendToAI(text); setText(''); } };
  return (
    <div className="aic-scrim" onClick={() => setOpen(false)}>
      <div className="aic" role="dialog" aria-label="WardenCB ile konuş" onClick={(e) => e.stopPropagation()}>
        <header className="aic-top">
          <WardenCB size={46} mood={busy ? 'think' : last?.mood ?? 'wave'} />
          <div className="aic-title"><b>WardenCB</b><span>{busy ? 'düşünüyor…' : 'Sor ya da yaptır'}</span></div>
          <span style={{ flex: 1 }} />
          {msgs.length > 0 && !settings && <button className="ib" aria-label="Sohbeti temizle" onClick={clear}><Icon name="trash" size={20} /></button>}
          <button className="ib" aria-label="Yapay zekâ ayarları" onClick={() => setSettings(!settings)}><Icon name="gear" size={20} /></button>
          <button className="ib" aria-label="Kapat" onClick={() => setOpen(false)}><Icon name="close" size={22} /></button>
        </header>
        {settings || noKey ? <Settings onDone={() => { setSettings(false); setVer((v) => v + 1); }} /> : (
          <>
            <div className="aic-list" ref={listRef}>
              {!msgs.length && (
                <>
                  <div className="aic-bub model"><WardenCB size={54} mood="happy" /><p>Selam aga! Uygulamayla ilgili ne istersen sor, ya da ne yapmamı istediğini yaz: video, şablon, CB sahnesi… Ben kurarım.</p></div>
                  <div className="aic-ex">{EXAMPLES.map((x) => <button key={x} className="chip" onClick={() => sendToAI(x)}>{x}</button>)}</div>
                </>
              )}
              {msgs.map((m, i) => m.role === 'user'
                ? <div key={i} className="aic-bub user"><p>{m.text}</p></div>
                : <div key={i} className={'aic-bub model' + (m.err ? ' err' : '')}><WardenCB size={54} mood={m.mood ?? 'idle'} autoBlink={i === msgs.length - 1} /><p>{m.text}{m.note && <small>{m.note}</small>}</p></div>)}
              {busy && <div className="aic-bub model"><WardenCB size={54} mood="think" /><p className="aic-dots"><i /><i /><i />{partial > 0 && <small style={{ margin: '0 0 0 6px' }}>{partial} harf</small>}</p></div>}
            </div>
            <div className="aic-in">
              <textarea rows={1} placeholder="WardenCB'ye yaz…" value={text} onChange={(e) => setText(e.target.value)} onKeyDown={(e) => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send(); } }} />
              <button className="aic-send" aria-label="Gönder" disabled={busy || !text.trim()} onClick={send}><Icon name="export" size={20} /></button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

/** WardenCB ile konuşma düğmesi (ana sayfa ve editörün üst çubuğu) */
export function AiButton({ size = 34 }: { size?: number }) {
  if (!AI_ENABLED) return null;
  const setOpen = useChat((s) => s.setOpen);
  return (
    <button className="ib aic-btn" aria-label="WardenCB ile konuş" onClick={() => { useStore.getState().setPlaying(false); setOpen(true); }}>
      <WardenCB size={size} mood="idle" autoBlink={false} look={0} />
    </button>
  );
}
