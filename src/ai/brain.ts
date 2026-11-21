// İnternetsiz WardenCB: telefonda ayrı yüklü "WardenCB Beyin" uygulamasına köprü.
import { Capacitor, registerPlugin, type PluginListenerHandle } from '@capacitor/core';

export interface BrainStatus { installed: boolean; downloaded?: boolean; loaded?: boolean; loading?: boolean; busy?: boolean; model?: string; backend?: string }
interface BrainPlugin {
  status(): Promise<BrainStatus>;
  ask(o: { prompt: string; temperature?: number }): Promise<{ text: string }>;
  cancel(): Promise<void>;
  open(): Promise<void>;
  addListener(ev: 'partial', fn: (d: { text: string }) => void): Promise<PluginListenerHandle>;
}
const Brain = registerPlugin<BrainPlugin>('WardenBrain');

export const brainSupported = () => Capacitor.isNativePlatform() && Capacitor.getPlatform() === 'android';

export async function brainStatus(): Promise<BrainStatus> {
  if (!brainSupported()) return { installed: false };
  try { return await Promise.race([Brain.status(), new Promise<BrainStatus>((_, rej) => setTimeout(() => rej(new Error('zaman aşımı')), 6000))]); }
  catch { return { installed: false }; }
}

export const openBrain = () => Brain.open().catch(() => undefined);

/** Qwen sohbet biçimi (ChatML) */
export function chatml(system: string, history: { role: 'user' | 'model'; text: string }[]): string {
  let s = `<|im_start|>system\n${system}<|im_end|>\n`;
  for (const m of history) s += `<|im_start|>${m.role === 'model' ? 'assistant' : 'user'}\n${m.text}<|im_end|>\n`;
  return s + '<|im_start|>assistant\n';
}

export async function askBrain(prompt: string, onPartial?: (t: string) => void): Promise<string> {
  const h = onPartial ? await Brain.addListener('partial', (d) => onPartial(d.text)) : null;
  try { return (await Brain.ask({ prompt, temperature: 0.5 })).text; }
  finally { h?.remove(); }
}
