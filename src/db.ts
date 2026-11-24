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

/** Galeriden eklenen görsel/videolar: ASIL hâliyle saklanır (düzenlerken küçük kopyası kullanılır, bkz. proxy.ts) */
export async function putMedia(blob: Blob): Promise<string> {
  const id = uid();
  // Çok büyük fotoğraflar (ör. 50 MP) yine de makul bir üst sınıra indirilir; videolar olduğu gibi
  await set(id, await downscale(blob, Math.max(mediaMax, 4096)), mediaStore);
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

// ---------- Yedekleme (hesap) ----------
const blobToData = (b: Blob) => new Promise<string>((res) => { const r = new FileReader(); r.onload = () => res(String(r.result)); r.readAsDataURL(b); });
const dataToBlob = async (d: string) => (await fetch(d)).blob();

export interface BackupInfo { projects: number; media: number; pack: number; flags: number }
/** Bütün projeler, galeriden eklenenler, yüklediğim pack ve bayraklar tek dosyada */
export async function exportBackup(extra: Record<string, unknown> = {}, onlyIds?: string[]): Promise<{ blob: Blob; info: BackupInfo }> {
  const projects = (await listProjects()).filter((p) => !onlyIds || onlyIds.includes(p.id));
  // Sadece seçilen projeler yedekleniyorsa yalnızca onların kullandığı görseller eklenir
  const used = onlyIds ? new Set(projects.flatMap((p) => p.layers.map((l) => l.src ?? '')).filter((s) => s.startsWith('media:')).map((s) => s.slice(6))) : null;
  const media: Record<string, string> = {};
  for (const k of await keys(mediaStore)) { if (used && !used.has(String(k))) continue; const b = await get<Blob>(k, mediaStore); if (b) media[String(k)] = await blobToData(b); }
  const pack = onlyIds ? { index: [], folders: [] } : { index: await listUserPack(), folders: (await get<string[]>('folders', packStore)) ?? [] };
  const flags = onlyIds ? [] : await listUserFlags();
  const data = { app: 'warden-motion', v: 1, date: Date.now(), projects, media, pack, flags, ...extra };
  return { blob: new Blob([JSON.stringify(data)], { type: 'application/json' }), info: { projects: projects.length, media: Object.keys(media).length, pack: pack.index.length, flags: flags.length } };
}
/** Yedeği geri yükler: var olanlar silinmez, aynı projeler yedekteki hâliyle güncellenir */
/** keepBoth: aynı proje zaten varsa üstüne yazmak yerine yanına kopya olarak eklenir (proje dosyası açarken) */
export async function importBackup(file: Blob, keepBoth = false): Promise<BackupInfo & { extra: Record<string, unknown>; names: string[] }> {
  const d = JSON.parse(await file.text());
  if (d?.app !== 'warden-motion') throw new Error('Bu bir Warden Motion yedeği değil.');
  for (const [k, v] of Object.entries((d.media ?? {}) as Record<string, string>)) await set(k, await dataToBlob(v), mediaStore);
  const have = keepBoth ? new Set((await listProjects()).map((p) => p.id)) : null;
  const names: string[] = [];
  for (const p of (d.projects ?? []) as Project[]) {
    if (have?.has(p.id)) await saveProject({ ...p, id: uid(), name: `${p.name} (dosyadan)`.slice(0, 40), updatedAt: Date.now() });
    else await saveProject(p);
    names.push(p.name);
  }
  const idx = await listUserPack();
  const newItems = ((d.pack?.index ?? []) as UserPackItem[]).filter((i) => !idx.some((x) => x.id === i.id));
  await set('index', [...idx, ...newItems], packStore);
  const folders = (await get<string[]>('folders', packStore)) ?? [];
  await set('folders', [...new Set([...folders, ...((d.pack?.folders ?? []) as string[])])], packStore);
  const fl = await listUserFlags();
  await set('index', [...fl, ...((d.flags ?? []) as UserFlag[]).filter((f) => !fl.some((x) => x.id === f.id))], flagStore);
  const { app: _a, v: _v, date: _d, projects, media, pack, flags, ...extra } = d;
  return { projects: projects?.length ?? 0, media: Object.keys(media ?? {}).length, pack: pack?.index?.length ?? 0, flags: flags?.length ?? 0, extra, names };
}
