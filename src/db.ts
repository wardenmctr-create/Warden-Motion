import { get, set, del, keys, createStore } from 'idb-keyval';
import type { Project } from './types';
import { uid } from './anim';

const projectStore = createStore('wm-projects', 'projects');
const mediaStore = createStore('wm-media', 'media');
const packStore = createStore('wm-pack', 'items');
const flagStore = createStore('wm-flags', 'items');

export async function listProjects(): Promise<Project[]> {
  const ks = await keys(projectStore);
  const all = await Promise.all(ks.map((k) => get<Project>(k, projectStore)));
  return (all.filter(Boolean) as Project[]).sort((a, b) => b.updatedAt - a.updatedAt);
}
export const saveProject = (p: Project) => set(p.id, p, projectStore);
export const deleteProject = (id: string) => del(id, projectStore);

/** Büyük fotoğrafı en uzun kenarı `max` olacak şekilde küçültür (şeffaflık korunur). */
export async function downscale(blob: Blob, max: number): Promise<Blob> {
  if (!blob.type.startsWith('image/') || blob.type === 'image/gif' || blob.type === 'image/svg+xml') return blob;
  try {
    const bmp = await createImageBitmap(blob);
    const k = max / Math.max(bmp.width, bmp.height);
    if (k >= 1) { bmp.close(); return blob; }
    const c = document.createElement('canvas');
    c.width = Math.round(bmp.width * k); c.height = Math.round(bmp.height * k);
    c.getContext('2d')!.drawImage(bmp, 0, 0, c.width, c.height);
    bmp.close();
    const png = blob.type === 'image/png' || blob.type === 'image/webp';
    return await new Promise<Blob>((res) => c.toBlob((b) => res(b ?? blob), png ? 'image/png' : 'image/jpeg', 0.9));
  } catch { return blob; }
}

let mediaMax = 2048;
/** Lite modda içe aktarılan görseller daha çok küçültülür */
export const setMediaMax = (n: number) => { mediaMax = n; };

/** Galeriden eklenen görseller */
export async function putMedia(blob: Blob): Promise<string> {
  const id = uid();
  await set(id, await downscale(blob, mediaMax), mediaStore);
  return 'media:' + id;
}
export const getMedia = (id: string) => get<Blob>(id, mediaStore);

/** Kullanıcının kendi pack'i: klasör + PNG */
export interface UserPackItem { id: string; folder: string; name: string; created: number }
export async function listUserPack(): Promise<UserPackItem[]> {
  return (await get<UserPackItem[]>('index', packStore)) ?? [];
}
export async function addUserPackItems(files: File[], folder: string): Promise<void> {
  const index = await listUserPack();
  for (const f of files) {
    const src = await putMedia(f);
    index.push({ id: src, folder, name: f.name.replace(/\.[^.]+$/, ''), created: Date.now() });
  }
  await set('index', index, packStore);
}
export async function removeUserPackItem(id: string): Promise<void> {
  await set('index', (await listUserPack()).filter((i) => i.id !== id), packStore);
}
export async function listUserFolders(): Promise<string[]> {
  const extra = (await get<string[]>('folders', packStore)) ?? [];
  const fromItems = (await listUserPack()).map((i) => i.folder);
  return [...new Set([...extra, ...fromItems])];
}
export async function addUserFolder(name: string): Promise<void> {
  const f = (await get<string[]>('folders', packStore)) ?? [];
  if (!f.includes(name)) await set('folders', [...f, name], packStore);
}

/** Kullanıcının eklediği bayraklar */
export interface UserFlag { id: string; name: string }
export const listUserFlags = async () => (await get<UserFlag[]>('index', flagStore)) ?? [];
export async function addUserFlag(file: File, name: string) {
  const id = await putMedia(file);
  await set('index', [...(await listUserFlags()), { id, name }], flagStore);
}
