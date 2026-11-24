import { useEffect } from 'react';
import { Capacitor } from '@capacitor/core';
import { Editor } from './screens/Editor';
import { Home } from './screens/Home';
import { perfOf, useStore } from './store';
import { setMediaMax } from './db';
import { Assistant } from './assistant/Assistant';
import { MediaSheet } from './components/MediaSheet';

export function App() {
  const screen = useStore((s) => s.screen);
  const hasProject = useStore((s) => !!s.project);
  const media = useStore((s) => perfOf(s.settings).media);
  useEffect(() => setMediaMax(media), [media]);

  // Android geri tuşu: önce açık paneli/menüyü kapatır, sonra editörden çıkar, en son uygulamadan.
  useEffect(() => {
    if (!Capacitor.isNativePlatform()) return;
    let remove: (() => void) | undefined;
    import('@capacitor/app').then(({ App: CapApp }) => {
      CapApp.addListener('backButton', () => {
        const ev = new Event('wm-back', { cancelable: true });
        if (!dispatchEvent(ev)) return;
        const st = useStore.getState();
        if (st.screen === 'editor') st.close();
        else if (st.screen === 'tutorials' || st.screen === 'account') st.go('home');
        else CapApp.exitApp();
      }).then((h) => { remove = () => h.remove(); });
    });
    return () => remove?.();
  }, []);

  return <>{screen === 'editor' && hasProject ? <Editor /> : <Home />}<Assistant /><MediaSheet /></>;
}
