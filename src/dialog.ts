// Uygulamanın kendi soru/onay pencereleri (tarayıcının prompt/confirm'i bazı ortamlarda engelli)
function modal(build: (box: HTMLDivElement, close: (v: string | null) => void) => void): Promise<string | null> {
  return new Promise((resolve) => {
    const scrim = document.createElement('div');
    scrim.className = 'wm-dlg';
    const box = document.createElement('div');
    box.className = 'wm-dlg-box';
    box.setAttribute('role', 'dialog');
    scrim.appendChild(box);
    const close = (v: string | null) => { scrim.remove(); removeEventListener('wm-back', onBack); resolve(v); };
    const onBack = (e: Event) => { e.preventDefault(); close(null); };
    addEventListener('wm-back', onBack);
    scrim.addEventListener('click', (e) => { if (e.target === scrim) close(null); });
    build(box, close);
    document.body.appendChild(scrim);
    (box.querySelector('input') ?? box.querySelector('button.ok') as HTMLElement | null)?.focus();
  });
}

function head(box: HTMLElement, title: string, text?: string) {
  const h = document.createElement('h4'); h.textContent = title; box.appendChild(h);
  if (text) { const p = document.createElement('p'); p.textContent = text; box.appendChild(p); }
}
function buttons(box: HTMLElement, okText: string, onOk: () => void, onCancel: () => void, danger = false) {
  const row = document.createElement('div'); row.className = 'wm-dlg-row';
  const c = document.createElement('button'); c.textContent = 'Vazgeç'; c.onclick = onCancel;
  const o = document.createElement('button'); o.textContent = okText; o.className = 'ok' + (danger ? ' danger' : ''); o.onclick = onOk;
  row.append(c, o); box.appendChild(row);
}

/** Metin sorar; Vazgeç → null */
export function askText(title: string, def = '', okText = 'Tamam'): Promise<string | null> {
  return modal((box, close) => {
    head(box, title);
    const inp = document.createElement('input'); inp.value = def; inp.id = 'wm-dlg-input';
    inp.onkeydown = (e) => { if (e.key === 'Enter') close(inp.value.trim()); };
    box.appendChild(inp);
    buttons(box, okText, () => close(inp.value.trim()), () => close(null));
  });
}

/** Onay sorar */
export async function askConfirm(title: string, text: string, okText = 'Evet'): Promise<boolean> {
  const v = await modal((box, close) => { head(box, title, text); buttons(box, okText, () => close('ok'), () => close(null), true); });
  return v === 'ok';
}
