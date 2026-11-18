import { Capacitor } from '@capacitor/core';
import { projectDuration } from './anim';
import { preloadImages, renderFrame } from './render';
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

/** Projeyi gerçek zamanlı oynatarak kaydeder. */
export async function exportVideo(p: Project, onProgress: (f: number) => void): Promise<{ blob: Blob; ext: string }> {
  const srcs = p.layers.flatMap((l) => [l.src, l.cb?.eyes]).filter(Boolean) as string[];
  await preloadImages(srcs);
  const canvas = document.createElement('canvas');
  canvas.width = p.width; canvas.height = p.height;
  const ctx = canvas.getContext('2d')!;
  renderFrame(ctx, p, 0);
  const stream = canvas.captureStream(p.fps);
  const { mime, ext } = pickMime();
  const rec = new MediaRecorder(stream, { mimeType: mime || undefined, videoBitsPerSecond: 8_000_000 });
  const chunks: Blob[] = [];
  rec.ondataavailable = (e) => e.data.size && chunks.push(e.data);
  const done = new Promise<void>((res) => (rec.onstop = () => res()));
  const dur = projectDuration(p);
  rec.start(250);
  const t0 = performance.now();
  await new Promise<void>((res) => {
    const tick = () => {
      const t = (performance.now() - t0) / 1000;
      renderFrame(ctx, p, Math.min(t, dur - 0.0001));
      onProgress(Math.min(1, t / dur));
      if (t < dur) requestAnimationFrame(tick); else res();
    };
    requestAnimationFrame(tick);
  });
  rec.stop();
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
