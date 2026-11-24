// Ses motoru: ses katmanları ve videoların kendi sesleri.
// Önizlemede (Lite ayarındaki kalitede) senkron çalar; dışa aktarmada asıl kalitede karıştırılıp videoya eklenir.
import { getMedia } from './db';
import type { Layer, Project } from './types';

/** Sesi olan katman mı (ses katmanı ya da video), sessize alınmamış */
export const hasAudio = (l: Layer) => (l.type === 'audio' || l.type === 'video') && !!l.src && !l.hidden && !l.muted && (l.volume ?? 1) > 0;

let ctx: AudioContext | null = null;
let previewRate = 0; // 0 = cihazın varsayılanı (asıl kalite)
const cache = new Map<string, Promise<AudioBuffer | null>>();

/** Lite ayarı: düzenlerken seslerin örnekleme hızı (düşükse bellek az dolar) */
export function setAudioRate(rate: number) {
  if (rate === previewRate) return;
  previewRate = rate;
  stopAudio();
  ctx?.close().catch(() => {});
  ctx = null;
  cache.clear();
}
function ac(): AudioContext {
  if (!ctx) {
    try { ctx = previewRate ? new AudioContext({ sampleRate: previewRate }) : new AudioContext(); }
    catch { ctx = new AudioContext(); }
  }
  return ctx;
}

async function blobOf(src: string): Promise<Blob | undefined> {
  if (src.startsWith('media:')) return getMedia(src.slice(6));
  try { return await (await fetch(src)).blob(); } catch { return undefined; }
}
/** Dosyanın sesini çözer (videonun sesi de olur). Sesi yoksa null. */
async function decode(c: BaseAudioContext, src: string): Promise<AudioBuffer | null> {
  const b = await blobOf(src);
  if (!b) return null;
  try { return await c.decodeAudioData(await b.arrayBuffer()); } catch { return null; }
}
function previewBuf(src: string) {
  let p = cache.get(src);
  if (!p) { p = decode(ac(), src); cache.set(src, p); }
  return p;
}
/** Proje açılınca sesleri önceden çöz (oynatınca gecikme olmasın) */
export function warmAudio(p: Project) { for (const l of p.layers) if (hasAudio(l)) previewBuf(l.src!); }
/** Dalga şekli için ses (önizleme kalitesinde) */
export const audioBuffer = (src: string) => previewBuf(src);

let nodes: AudioBufferSourceNode[] = [];
let token = 0;

/** Önizlemede t anından itibaren çal */
export async function playAudio(p: Project, t: number) {
  stopAudio();
  const my = ++token;
  const c = ac();
  if (c.state === 'suspended') { try { await c.resume(); } catch { /* yok */ } }
  const c0 = c.currentTime, t0 = t;
  for (const l of p.layers) {
    if (!hasAudio(l) || l.end <= t0) continue;
    const buf = await previewBuf(l.src!);
    if (my !== token) return;
    if (!buf) continue;
    // Çözme sürerken geçen zamanı da hesaba kat (senkron kalsın)
    const now = t0 + (c.currentTime - c0);
    if (l.end <= now) continue;
    const off = Math.max(0, now - l.start), wait = Math.max(0, l.start - now);
    if (off >= buf.duration) continue;
    const s = c.createBufferSource(), g = c.createGain();
    s.buffer = buf;
    g.gain.value = l.volume ?? 1;
    s.connect(g).connect(c.destination);
    s.start(c.currentTime + wait, off, Math.max(0, l.end - Math.max(now, l.start)));
    nodes.push(s);
  }
}
export function stopAudio() {
  token++;
  for (const n of nodes) { try { n.stop(); } catch { /* zaten durdu */ } }
  nodes = [];
}

/** Dışa aktarma: bütün sesler asıl kalitede tek bir stereo sese karıştırılır */
export async function mixAudio(p: Project, dur: number, rate = 48000): Promise<AudioBuffer | null> {
  const ls = p.layers.filter(hasAudio);
  if (!ls.length || typeof OfflineAudioContext === 'undefined') return null;
  const oc = new OfflineAudioContext(2, Math.max(1, Math.ceil(dur * rate)), rate);
  let any = false;
  for (const l of ls) {
    const buf = await decode(oc, l.src!);
    if (!buf) continue;
    any = true;
    const s = oc.createBufferSource(), g = oc.createGain();
    s.buffer = buf;
    g.gain.value = l.volume ?? 1;
    s.connect(g).connect(oc.destination);
    s.start(l.start, 0, Math.max(0, l.end - l.start));
  }
  return any ? oc.startRendering() : null;
}

/** Ses kodlayıcı: önce AAC (MP4 için en uyumlu), olmazsa Opus */
export async function pickAudioEncoder(rate: number): Promise<{ config: AudioEncoderConfig; mux: 'aac' | 'opus' } | null> {
  if (typeof AudioEncoder === 'undefined') return null;
  for (const [codec, mux] of [['mp4a.40.2', 'aac'], ['opus', 'opus']] as const) {
    const config: AudioEncoderConfig = { codec, sampleRate: rate, numberOfChannels: 2, bitrate: 160000 };
    try { if ((await AudioEncoder.isConfigSupported(config)).supported) return { config, mux }; } catch { /* sonraki */ }
  }
  return null;
}

/** Karışık sesi parça parça kodlayıp muxer'a ekler */
export async function encodeAudio(buf: AudioBuffer, config: AudioEncoderConfig, add: (c: EncodedAudioChunk, m?: EncodedAudioChunkMetadata) => void) {
  let err: unknown = null;
  const enc = new AudioEncoder({ output: add, error: (e) => { err = e; } });
  enc.configure(config);
  const rate = buf.sampleRate, ch = Math.min(2, buf.numberOfChannels), N = buf.length, step = 4096;
  const L = buf.getChannelData(0), R = ch > 1 ? buf.getChannelData(1) : L;
  for (let i = 0; i < N; i += step) {
    const n = Math.min(step, N - i);
    const data = new Float32Array(n * 2);
    data.set(L.subarray(i, i + n), 0);
    data.set(R.subarray(i, i + n), n);
    const ad = new AudioData({ format: 'f32-planar', sampleRate: rate, numberOfFrames: n, numberOfChannels: 2, timestamp: Math.round(i / rate * 1e6), data });
    enc.encode(ad);
    ad.close();
    if (err) throw err;
    while (enc.encodeQueueSize > 16) await new Promise((r) => setTimeout(r, 2));
  }
  await enc.flush();
  enc.close();
  if (err) throw err;
}
