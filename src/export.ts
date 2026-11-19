import { Capacitor } from '@capacitor/core';
import { projectDuration } from './anim';
import { getVideo, pauseAllVideos, preloadImages, renderFrame } from './render';
import type { Project } from './types';

function pickMime(): { mime: string; ext: string } {
  const opts = [
    { mime: 'video/mp4;codecs=avc1', ext: 'mp4' },
    { mime: 'video/mp4', ext: 'mp4' },
    { mime: 'video/webm;codecs=vp9', ext: 'webm' },
    { mime: 'video/webm', ext: 'webm' },
  ];
  return opts.find((o) => MediaRecorder.isTypeSupported(o.mime)) ?? { mime: '', ext: 'webm' };
}

/** Projeyi kare kare, en yüksek kalitede kaydeder. */
export async function exportVideo(p: Project, onProgress: (f: number) => void): Promise<{ blob: Blob; ext: string }> {
  const srcs = p.layers.flatMap((l) => [l.src, l.cb?.eyes]).filter(Boolean) as string[];
  await preloadImages(srcs.filter((s) => !p.layers.some((l) => l.type === 'video' && l.src === s)));
  // Videoların ilk karesi hazır olana kadar bekle (en fazla 8 sn)
  const vids = p.layers.filter((l) => l.type === 'video' && l.src).map((l) => l.src!);
  const t0v = performance.now();
  while (vids.some((v) => !getVideo(v)) && performance.now() - t0v < 8000) await new Promise((r) => setTimeout(r, 100));
  const canvas = document.createElement('canvas');
  canvas.width = p.width; canvas.height = p.height;
  const ctx = canvas.getContext('2d', { willReadFrequently: true })!;
  const dur = projectDuration(p);
  const frames = Math.max(1, Math.round(dur * p.fps));
  // Bir kareyi en yüksek kalitede çizer; video katmanları o kareye gidene kadar bekler
  const drawAt = async (t: number) => {
    renderFrame(ctx, p, t, { exporting: true });
    const t0 = performance.now();
    while (vids.some((v) => getVideo(v)?.seeking) && performance.now() - t0 < 3000) await new Promise((r) => setTimeout(r, 15));
    if (vids.length) renderFrame(ctx, p, t, { exporting: true });
  };
  await drawAt(0);
  // Kare kare kayıt: her kare hazırlanırken kaydedici duraklatılır, sonra tam 1/fps süre açık kalır.
  // Böylece ağır kareler (bulanıklık, fraktal) videoda takılma yapmaz.
  const stream = canvas.captureStream(0);
  const track = stream.getVideoTracks()[0] as MediaStreamTrack & { requestFrame?: () => void };
  const { mime, ext } = pickMime();
  const rec = new MediaRecorder(stream, { mimeType: mime || undefined, videoBitsPerSecond: 8_000_000 });
  const chunks: Blob[] = [];
  rec.ondataavailable = (e) => e.data.size && chunks.push(e.data);
  const done = new Promise<void>((res) => (rec.onstop = () => res()));
  const wait = (ms: number) => new Promise((r) => setTimeout(r, ms));
  rec.start();
  for (let i = 0; i < frames; i++) {
    if (i > 0) {
      if (rec.state === 'recording') rec.pause();
      await drawAt(Math.min(i / p.fps, dur - 0.0001));
      rec.resume();
    }
    track.requestFrame?.();
    await wait(1000 / p.fps);
    onProgress((i + 1) / frames);
  }
  rec.stop();
  pauseAllVideos();
  await done;
  return { blob: new Blob(chunks, { type: mime.split(';')[0] || 'video/webm' }), ext };
}

type Downloads = { save: (r: { filename: string; data: Blob }) => Promise<{ status: string }> };
type ClaudeHost = { use: (n: string) => Promise<unknown> };

export async function saveFile(blob: Blob, filename: string): Promise<string> {
  // Claude sayfası olarak açıldıysa: Claude'un izinli kaydetme özelliği
  const host = (window as unknown as { claude?: ClaudeHost }).claude;
  if (host?.use) {
    const dl = (await host.use('downloads')) as Downloads | null;
    if (dl) {
      try { await dl.save({ filename, data: blob }); return 'Kaydedildi.'; }
      catch (e) { const c = (e as { code?: string }).code; return c === 'declined' ? 'Kaydetme iptal edildi.' : 'Kaydedilemedi (' + (c ?? 'hata') + ').'; }
    }
  }
  if (Capacitor.isNativePlatform()) {
    const { Filesystem, Directory } = await import('@capacitor/filesystem');
    const { Share } = await import('@capacitor/share');
    const data = await new Promise<string>((res) => {
      const r = new FileReader();
      r.onload = () => res(String(r.result).split(',')[1]);
      r.readAsDataURL(blob);
    });
    const w = await Filesystem.writeFile({ path: filename, data, directory: Directory.Cache });
    await Share.share({ title: filename, files: [w.uri] });
    return 'Paylaşım menüsünden kaydedebilirsin.';
  }
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = filename;
  a.click();
  setTimeout(() => URL.revokeObjectURL(a.href), 5000);
  return 'İndirildi.';
}
