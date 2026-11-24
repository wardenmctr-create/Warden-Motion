// Uygulama içi galeri: fotoğraf/video seçerken Warden Motion'dan çıkmadan seçim yapılır.
import { Capacitor, registerPlugin } from '@capacitor/core';
import { create } from 'zustand';

export interface GItem { id: number; video: boolean; audio?: boolean; uri?: string; mime: string; name: string; album: string; duration: number }
interface GalleryPlugin {
  status(): Promise<{ access: 'full' | 'partial' | 'none'; photos: boolean }>;
  request(o?: { again?: boolean }): Promise<{ access: 'full' | 'partial' | 'none'; photos: boolean }>;
  list(o: { offset: number; limit: number; kind: Kind; album?: string }): Promise<{ items: GItem[] }>;
  albums(): Promise<{ albums: { name: string; count: number }[] }>;
  thumb(o: { id: number; video: boolean }): Promise<{ path: string; data?: string }>;
  readChunk(o: { path: string; offset: number; length: number }): Promise<{ data: string; size: number }>;
  read(o: { id: number; video: boolean }): Promise<{ path: string; mime: string; name: string }>;
  photos(o: { kind: Kind; multiple: boolean }): Promise<{ files: { path: string; mime: string; name: string }[] }>;
  audioStatus(): Promise<{ ok: boolean }>;
  audioRequest(): Promise<{ ok: boolean }>;
  audioList(o: { offset: number; limit: number; album?: string }): Promise<{ items: GItem[] }>;
  audioAlbums(): Promise<{ albums: { name: string; count: number }[] }>;
  readAudio(o: { id: number }): Promise<{ path: string; mime: string; name: string }>;
  pickFolder(): Promise<{ uri?: string; name?: string }>;
  listFolder(o: { uri: string; kind: Kind; offset: number; limit: number }): Promise<{ items: GItem[] }>;
  thumbUri(o: { uri: string; video: boolean }): Promise<{ path: string; data?: string }>;
  readUri(o: { uri: string }): Promise<{ path: string; mime: string; name: string }>;
}
// Testlerde sahte galeri verilebilir (window.__wmGalleryMock)
const mock = (globalThis as { __wmGalleryMock?: GalleryPlugin }).__wmGalleryMock;
export const Gallery = mock ?? registerPlugin<GalleryPlugin>('Gallery');
export type Kind = 'image' | 'video' | 'any' | 'audio';
export const galleryNative = () => !!mock || (Capacitor.isNativePlatform() && Capacitor.getPlatform() === 'android');
export const fileSrc = (path: string) => (mock ? path : Capacitor.convertFileSrc(path));

/** Önbellekteki dosyayı File'a çevirir: önce uygulamanın dosya sunucusundan, olmazsa parça parça doğrudan okuyarak */
export async function toFile(f: { path: string; mime: string; name: string; size?: number }): Promise<File> {
  let blob: Blob | null = null;
  try {
    const r = await fetch(fileSrc(f.path));
    if (r.ok) { blob = await r.blob(); if (f.size && blob.size !== f.size) blob = null; }
  } catch { blob = null; }
  if (!blob) {
    const parts: BlobPart[] = [];
    const CH = 1 << 20;
    for (let off = 0; ; off += CH) {
      const c = await Gallery.readChunk({ path: f.path, offset: off, length: CH });
      const bin = atob(c.data), u = new Uint8Array(bin.length);
      for (let i = 0; i < bin.length; i++) u[i] = bin.charCodeAt(i);
      parts.push(u);
      if (off + CH >= c.size || !bin.length) break;
    }
    blob = new Blob(parts, { type: f.mime });
  }
  return new File([blob], f.name, { type: f.mime || blob.type });
}
/** Hata mesajı (ekranda gösterilir, sorunu bulmak için) */
export const errText = (e: unknown) => (e instanceof Error ? e.message : typeof e === 'object' && e && 'message' in e ? String((e as { message: unknown }).message) : String(e));

interface Req { kind: Kind; multiple: boolean; title: string; resolve: (f: File[]) => void }
export const useMediaSheet = create<{ req: Req | null; set: (r: Req | null) => void }>((set) => ({ req: null, set: (req) => set({ req }) }));

/** Galeri sayfasını açar; seçilen dosyaları döndürür (vazgeçilirse boş) */
export function pickMedia(o: { kind?: Kind; multiple?: boolean; title?: string } = {}): Promise<File[]> {
  return new Promise((resolve) => {
    useMediaSheet.getState().req?.resolve([]);
    useMediaSheet.getState().set({ kind: o.kind ?? 'any', multiple: !!o.multiple, title: o.title ?? 'Galeri', resolve });
  });
}

/** Galeriyi açar; seçilenleri mevcut dosya kutusuna koyup onun "change" olayını tetikler (eski işleme kodu aynen çalışır) */
export async function pickInto(input: HTMLInputElement | null, o: { kind?: Kind; multiple?: boolean; title?: string } = {}) {
  if (!input) return;
  const files = await pickMedia(o);
  if (!files.length) return;
  const dt = new DataTransfer();
  for (const f of o.multiple ? files : files.slice(0, 1)) dt.items.add(f);
  input.files = dt.files;
  input.dispatchEvent(new Event('change', { bubbles: true }));
}

/** Galerideki bir öğeyi File olarak okur (ses de olur) */
export async function readItem(it: GItem): Promise<File> {
  return toFile(it.uri ? await Gallery.readUri({ uri: it.uri }) : it.audio ? await Gallery.readAudio({ id: it.id }) : await Gallery.read({ id: it.id, video: it.video }));
}

// ---------- Kullanıcının eklediği klasörler (albüm listesinde "+ Klasör ekle") ----------
export interface UserFolder { uri: string; name: string }
const FKEY = (audio: boolean) => (audio ? 'wm-folders-audio' : 'wm-folders-media');
export const getFolders = (audio: boolean): UserFolder[] => { try { return JSON.parse(localStorage.getItem(FKEY(audio)) || '[]'); } catch { return []; } };
export const setFolders = (audio: boolean, f: UserFolder[]) => { try { localStorage.setItem(FKEY(audio), JSON.stringify(f)); } catch { /* yok */ } };
/** Klasör seçtirip listeye ekler; eklenen klasörü döndürür */
export async function addFolder(audio: boolean): Promise<UserFolder | null> {
  const r = await Gallery.pickFolder();
  if (!r.uri) return null;
  const f = { uri: r.uri, name: r.name || 'Klasör' };
  setFolders(audio, [...getFolders(audio).filter((x) => x.uri !== f.uri), f]);
  return f;
}
/** Albüm anahtarı: 'dir:<uri>' ise eklenen klasör, değilse telefondaki albüm adı */
export const isDir = (a: string) => a.startsWith('dir:');
