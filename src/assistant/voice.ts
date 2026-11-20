// WardenCB'nin konuşma sesi: yazı harf harf çıkarken kısa "blip"ler (oyunlardaki diyalog sesi gibi).
// Ses dosyası yok: Web Audio ile üretilir. Kapatılabilir (ayar kalıcı).
let ac: AudioContext | null = null;
const KEY = 'wm-assist-voice';
export const voiceOn = () => { try { return localStorage.getItem(KEY) !== '0'; } catch { return true; } };
export const setVoice = (on: boolean) => { try { localStorage.setItem(KEY, on ? '1' : '0'); } catch { /* yok */ } };

function ctx(): AudioContext | null {
  if (!ac) {
    const C = window.AudioContext ?? (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;
    if (!C) return null;
    try { ac = new C(); } catch { return null; }
  }
  if (ac.state === 'suspended') ac.resume().catch(() => {});
  return ac;
}
/** İlk dokunuşta sesi aç (tarayıcılar kullanıcı hareketi olmadan ses çalmaz) */
export const unlockVoice = () => { ctx(); };

/** Tek harf sesi. WardenCB'nin sesi: kare dalga, hafif değişen perde */
export function blip(ch: string) {
  if (!voiceOn() || !/[\p{L}\p{N}]/u.test(ch)) return;
  const a = ctx();
  if (!a || a.state !== 'running') return;
  const t = a.currentTime;
  const o = a.createOscillator(), g = a.createGain(), f = a.createBiquadFilter();
  o.type = 'square';
  const code = ch.toLocaleLowerCase('tr').charCodeAt(0);
  o.frequency.setValueAtTime(330 + (code % 6) * 18, t);
  f.type = 'lowpass'; f.frequency.value = 2400;
  g.gain.setValueAtTime(0.0001, t);
  g.gain.exponentialRampToValueAtTime(0.05, t + 0.005);
  g.gain.exponentialRampToValueAtTime(0.0001, t + 0.055);
  o.connect(f).connect(g).connect(a.destination);
  o.start(t); o.stop(t + 0.06);
}
