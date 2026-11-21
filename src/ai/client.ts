// WardenCB'nin beyni: ücretsiz kotası olan bulut yapay zekâları (Google Gemini ya da Groq).
// Anahtar sadece bu cihazda saklanır. Cevap her zaman JSON: { say, mood, actions }.
import { Capacitor, CapacitorHttp } from '@capacitor/core';

export type Provider = 'gemini' | 'groq' | 'offline';
export interface AiSettings { provider: Provider; key: string; model: string }
export const DEFAULT_MODEL: Record<Provider, string> = { gemini: 'gemini-2.5-flash', groq: 'llama-3.3-70b-versatile', offline: 'Qwen2.5 1.5B' };
export const KEY_URL: Record<Provider, string> = { gemini: 'https://aistudio.google.com/apikey', groq: 'https://console.groq.com/keys', offline: '' };

const KEY = 'wm-ai';
export function loadAi(): AiSettings {
  try {
    const s = JSON.parse(localStorage.getItem(KEY) || '{}');
    const provider: Provider = s.provider === 'groq' || s.provider === 'offline' ? s.provider : 'gemini';
    return { provider, key: s.key ?? '', model: s.model || DEFAULT_MODEL[provider] };
  } catch { return { provider: 'gemini', key: '', model: DEFAULT_MODEL.gemini }; }
}
export const saveAi = (s: AiSettings) => { try { localStorage.setItem(KEY, JSON.stringify(s)); } catch { /* yok */ } };

export interface Msg { role: 'user' | 'model'; text: string }

export class AiError extends Error {}

async function post(url: string, headers: Record<string, string>, body: unknown): Promise<{ status: number; data: unknown }> {
  if (Capacitor.isNativePlatform()) {
    // Telefonda tarayıcı kısıtlamaları (CORS) olmadan doğrudan istek
    const r = await CapacitorHttp.post({ url, headers: { 'Content-Type': 'application/json', ...headers }, data: body, connectTimeout: 30000, readTimeout: 90000 });
    return { status: r.status, data: typeof r.data === 'string' ? safeJson(r.data) : r.data };
  }
  const r = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json', ...headers }, body: JSON.stringify(body) });
  return { status: r.status, data: safeJson(await r.text()) };
}
const safeJson = (t: string) => { try { return JSON.parse(t); } catch { return t; } };

function explain(status: number, data: unknown): string {
  const msg = JSON.stringify(data ?? '').slice(0, 300);
  if (status === 400 && /API key|API_KEY/i.test(msg)) return 'Anahtar geçersiz görünüyor. Ayarlardan kontrol et.';
  if (status === 401 || status === 403) return 'Anahtar kabul edilmedi. Ayarlardan doğru anahtarı yapıştırdığından emin ol.';
  if (status === 404) return 'Model bulunamadı. Ayarlardaki model adını kontrol et.';
  if (status === 429) return 'Ücretsiz kota şimdilik doldu. Biraz bekleyip tekrar dene.';
  if (status >= 500) return 'Yapay zekâ sunucusu şu an cevap vermiyor. Biraz sonra tekrar dene.';
  return `Bir sorun çıktı (${status}).`;
}

/** Sohbeti gönderir, modelin JSON metnini döndürür */
export async function askAI(system: string, history: Msg[], s: AiSettings = loadAi(), onPartial?: (t: string) => void): Promise<string> {
  if (s.provider === 'offline') {
    // İnternetsiz: telefondaki WardenCB Beyin uygulaması
    const { askBrain, brainStatus, chatml } = await import('./brain');
    const st = await brainStatus();
    if (!st.installed) throw new AiError('WardenCB Beyin uygulaması bu telefonda yüklü değil.');
    if (!st.downloaded) throw new AiError('WardenCB Beyin\'in modeli henüz indirilmedi. Ayarlardan "WardenCB Beyin\'i aç"a dokunup modeli indir.');
    try { return await askBrain(chatml(system, history), onPartial); }
    catch (e) { throw new AiError(e instanceof Error ? e.message : String(e)); }
  }
  if (!s.key) throw new AiError('Önce yapay zekâ anahtarını gir.');
  let res: { status: number; data: unknown };
  try {
    if (s.provider === 'gemini') {
      res = await post(`https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(s.model)}:generateContent`, { 'x-goog-api-key': s.key }, {
        systemInstruction: { parts: [{ text: system }] },
        contents: history.map((m) => ({ role: m.role, parts: [{ text: m.text }] })),
        generationConfig: { responseMimeType: 'application/json', temperature: 0.7, maxOutputTokens: 8192 },
      });
    } else {
      res = await post('https://api.groq.com/openai/v1/chat/completions', { Authorization: `Bearer ${s.key}` }, {
        model: s.model,
        messages: [{ role: 'system', content: system }, ...history.map((m) => ({ role: m.role === 'model' ? 'assistant' : 'user', content: m.text }))],
        response_format: { type: 'json_object' }, temperature: 0.7, max_tokens: 8000,
      });
    }
  } catch {
    throw new AiError('İnternete bağlanılamadı. Bağlantını kontrol et.');
  }
  if (res.status < 200 || res.status >= 300) throw new AiError(explain(res.status, res.data));
  const d = res.data as { candidates?: { content?: { parts?: { text?: string }[] } }[]; choices?: { message?: { content?: string } }[] };
  const text = s.provider === 'gemini'
    ? d.candidates?.[0]?.content?.parts?.map((p) => p.text ?? '').join('') ?? ''
    : d.choices?.[0]?.message?.content ?? '';
  if (!text) throw new AiError('Yapay zekâ boş cevap verdi. Tekrar dene.');
  return text;
}

/** Konuşmaya hazır mı (anahtar ya da internetsiz seçili) */
export const aiConfigured = (s: AiSettings = loadAi()) => s.provider === 'offline' || !!s.key;
