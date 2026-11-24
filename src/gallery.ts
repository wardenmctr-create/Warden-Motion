// Uygulama içi galeri: fotoğraf/video seçerken Warden Motion'dan çıkmadan seçim yapılır.
import { Capacitor, registerPlugin } from '@capacitor/core';
import { create } from 'zustand';

export interface GItem { id: number; video: boolean; audio?: boolean; mime: string; name: string; album: string; duration: number }
interface GalleryPlugin {
  status(): Promise<{ access: 'full' | 'partial' | 'none'; photos: boolean }>;
  request(o?: { again?: boolean }): Promise<{ access: 'full' | 'partial' | 'none'; photos: boolean }>;
  list(o: { offset: number; limit: number; kind: Kind; album?: string }): Promise<{ items: GItem[] }>;
  albums(): Promise<{ albums: { name: string; count: number }[] }>;
  thumb(o: { id: number; video: boolean }): Promise<{ path: string }>;
  read(o: { id: number; video: boolean }): Promise<{ path: string; mime: string; name: string }>;
  photos(o: { kind: Kind; multiple: boolean }): Promise<{ files: { path: string; mime: string; name: string }[] }>;
  audioStatus(): Promise<{ ok: boolean }>;
  audioRequest(): Promise<{ ok: boolean }>;
  audioList(o: { offset: number; limit: number; album?: string }): Promise<{ items: GItem[] }>;
  audioAlbums(): Promise<{ albums: { name: string; count: number }[] }>;
  readAudio(o: { id: number }): Promise<{ path: string; mime: string; name: string }>;
}
// Testlerde sahte galeri verilebilir (window.__wmGalleryMock)
const mock = (globalThis as { __wmGalleryMock?: GalleryPlugin }).__wmGalleryMock;
export const Gallery = mock ?? registerPlugin<GalleryPlugin>('Gallery');
export type Kind = 'image' | 'video' | 'any' | 'audio';
export const galleryNative = () => !!mock || (Capacitor.isNativePlatform() && Capacitor.getPlatform() === 'android');
export const fileSrc = (path: string) => (mock ? path : Capacitor.convertFileSrc(path));

/** Önbellekteki dosyayı File'a çevirir */
export async function toFile(f: { path: string; mime: string; name: string }): Promise<File> {
  const blob = await (await fetch(fileSrc(f.path))).blob();
  return new File([blob], f.name, { type: f.mime || blob.type });
}

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
  return toFile(it.audio ? await Gallery.readAudio({ id: it.id }) : await Gallery.read({ id: it.id, video: it.video }));
}
