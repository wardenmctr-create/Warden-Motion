// Proje dosyasını seçilen yere kaydetme: Google Drive, Google Files (kaydetme ekranı) ya da diğer uygulamalar.
import { Capacitor, registerPlugin } from '@capacitor/core';
import { saveFile } from './export';

interface SaveToPlugin {
  available(): Promise<{ drive: boolean }>;
  drive(o: { path: string; name: string }): Promise<void>;
  files(o: { path: string; name: string }): Promise<{ saved: boolean }>;
}
const SaveTo = registerPlugin<SaveToPlugin>('SaveTo');
export type Dest = 'drive' | 'files' | 'other';

export const native = () => Capacitor.isNativePlatform();
export async function driveInstalled(): Promise<boolean> {
  if (!native()) return true;
  try { return (await SaveTo.available()).drive; } catch { return false; }
}

async function toCache(blob: Blob, name: string): Promise<string> {
  const { Filesystem, Directory } = await import('@capacitor/filesystem');
  const data = await new Promise<string>((res) => { const r = new FileReader(); r.onload = () => res(String(r.result).split(',')[1]); r.readAsDataURL(blob); });
  return (await Filesystem.writeFile({ path: name, data, directory: Directory.Cache })).uri;
}

/** Sonuç mesajı döndürür */
export async function saveTo(dest: Dest, blob: Blob, name: string): Promise<string> {
  if (!native() || dest === 'other') return saveFile(blob, name);
  const path = await toCache(blob, name);
  try {
    if (dest === 'drive') { await SaveTo.drive({ path, name }); return 'Drive açıldı: klasörü seçip "Kaydet"e bas.'; }
    const r = await SaveTo.files({ path, name });
    return r.saved ? 'Kaydedildi.' : 'Kaydetme iptal edildi.';
  } catch (e) {
    return e instanceof Error ? e.message : 'Kaydedilemedi.';
  }
}
