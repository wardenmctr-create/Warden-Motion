// Önizleme kopyaları: içe aktarılan dosyanın asıl hâli saklanır; düzenlerken küçük kopyası kullanılır,
// dışa aktarırken asıl hâli. Küçültme oranı Lite ayarlarından (görsel ve video ayrı).
import { createStore, get, set } from 'idb-keyval';
import { ArrayBufferTarget, Muxer } from 'mp4-muxer';
import { downscale, getMedia } from './db';
import { pickEncoder } from './export';

const proxyStore = createStore('wm-proxy', 'items');
/** img: görsellerin en uzun kenarı (px), vid: videoların kısa kenarı (px); 0 = asıl hâli */
let level = { img: 0, vid: 0 };
export const setProxyLevel = (img: number, vid: number) => {
  if (level.img === img && level.vid === vid) return;
  level = { img, vid };
  dispatchEvent(new Event('wm-proxy-ready'));
};
/** Önbellek anahtarı (seviye değişince yeni kopyalar yüklenir) */
export const proxyTag = () => `${level.img}/${level.vid}`;

const pending = new Map<string, Promise<void>>();

/** Önizleme için dosya: varsa küçük kopya, yoksa asıl hâli (video kopyası arka planda hazırlanır) */
export async function getPreviewMedia(id: string): Promise<Blob | undefined> {
  const orig = await getMedia(id);
  if (!orig) return undefined;
  if (!/^(image|video)\//.test(orig.type)) return orig; // ses vb. olduğu gibi
  const isVid = orig.type.startsWith('video/');
  const L = isVid ? level.vid : level.img;
  if (!L) return orig;
  const key = `${id}@${isVid ? 'v' : 'i'}${L}`;
  const c = await get<Blob | 'same'>(key, proxyStore);
  if (c === 'same') return orig;
  if (c) return c;
  if (!isVid) {
    const small = await downscale(orig, L);
    await set(key, small === orig ? 'same' : small, proxyStore);
    return small;
  }
  if (!pending.has(key)) {
    pending.set(key, makeVideoProxy(orig, L)
      .then((b) => set(key, b ?? 'same', proxyStore))
      .catch(() => set(key, 'same', proxyStore))
      .then(() => { dispatchEvent(new Event('wm-proxy-ready')); }));
  }
  return orig;
}

/** Videonun küçük kopyası: sessiz ve hızlı oynatılıp kareleri küçültülerek H.264'e kodlanır (arka planda) */
async function makeVideoProxy(blob: Blob, shortSide: number): Promise<Blob | null> {
  if (typeof VideoEncoder === 'undefined' || typeof VideoFrame === 'undefined') return null;
  const v = document.createElement('video') as HTMLVideoElement & { requestVideoFrameCallback?: (cb: (now: number, meta: { mediaTime: number }) => void) => number };
  if (!v.requestVideoFrameCallback) return null;
  const url = URL.createObjectURL(blob);
  try {
    v.muted = true; v.playsInline = true; v.preload = 'auto'; v.src = url;
    await new Promise<void>((res, rej) => { v.onloadedmetadata = () => res(); v.onerror = () => rej(new Error('video')); });
    const W0 = v.videoWidth, H0 = v.videoHeight;
    if (!W0 || !H0 || Math.min(W0, H0) <= shortSide) return null; // zaten küçük
    const k = shortSide / Math.min(W0, H0);
    const w = Math.max(2, Math.round(W0 * k / 2) * 2), h = Math.max(2, Math.round(H0 * k / 2) * 2);
    const enc = await pickEncoder(w, h, 30);
    if (!enc) return null;
    const target = new ArrayBufferTarget();
    const muxer = new Muxer({ target, video: { codec: enc.mux, width: w, height: h, frameRate: 30 }, fastStart: 'in-memory', firstTimestampBehavior: 'offset' });
    let encErr: unknown = null;
    const encoder = new VideoEncoder({ output: (chunk, meta) => muxer.addVideoChunk(chunk, meta), error: (e) => { encErr = e; } });
    encoder.configure({ ...enc.config, width: w, height: h, bitrate: Math.round(Math.max(4e5, w * h * 30 * 0.08)) });
    const cv = document.createElement('canvas'); cv.width = w; cv.height = h;
    const cx = cv.getContext('2d')!;
    let frames = 0, lastT = -1;
    await new Promise<void>((res, rej) => {
      const cb = (_now: number, meta: { mediaTime: number }) => {
        if (meta.mediaTime > lastT) {
          lastT = meta.mediaTime;
          cx.drawImage(v, 0, 0, w, h);
          const f = new VideoFrame(cv, { timestamp: Math.round(meta.mediaTime * 1e6) });
          encoder.encode(f, { keyFrame: frames % 60 === 0 });
          f.close();
          frames++;
        }
        if (!v.ended && !encErr) v.requestVideoFrameCallback!(cb); else res();
      };
      v.requestVideoFrameCallback!(cb);
      v.onended = () => res();
      v.onerror = () => rej(new Error('video'));
      v.playbackRate = 2;
      v.play().catch(rej);
    });
    await encoder.flush();
    encoder.close();
    if (encErr || frames < 2) return null;
    muxer.finalize();
    return new Blob([target.buffer], { type: 'video/mp4' });
  } finally {
    v.pause(); v.removeAttribute('src'); v.load();
    URL.revokeObjectURL(url);
  }
}
