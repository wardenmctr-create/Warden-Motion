// Önizleme sahneleri: bizim nesnelerimiz, Türkçe yazılar, bizim renklerimiz
const NAVY = '#0B1430', BLUE = '#2F7BF6', TURQ = '#22D3C5', CYAN = '#3FD0F0', WHITE = '#F7F8FA', RED = '#E30A17', GOLD = '#F2C230', PURP = '#8F7CF0', PINK = '#E84393';
const osc = (p, lo, hi) => lo + (hi - lo) * (0.5 - 0.5 * Math.cos(p * Math.PI * 2));
function rr(g, x, y, w, h, r) { g.beginPath(); g.moveTo(x + r, y); g.arcTo(x + w, y, x + w, y + h, r); g.arcTo(x + w, y + h, x, y + h, r); g.arcTo(x, y + h, x, y, r); g.arcTo(x, y, x + w, y, r); g.closePath(); }
// Manzara: gök, güneş, bulutlar, tepeler, bayrak (fotoğraf yerine)
function landscape(g, w, h) {
  g.save(); g.translate(-w / 2, -h / 2);
  const gr = g.createLinearGradient(0, 0, 0, h * 0.7); gr.addColorStop(0, '#1F5FD6'); gr.addColorStop(0.55, '#5FB2F2'); gr.addColorStop(1, '#BFE6FF'); g.fillStyle = gr; g.fillRect(0, 0, w, h);
  const sx = w * 0.74, sy = h * 0.3; const sg = g.createRadialGradient(sx, sy, 0, sx, sy, w * 0.22); sg.addColorStop(0, 'rgba(255,240,180,1)'); sg.addColorStop(0.25, 'rgba(255,214,102,0.95)'); sg.addColorStop(1, 'rgba(255,214,102,0)'); g.fillStyle = sg; g.fillRect(0, 0, w, h);
  g.fillStyle = '#FFE9A6'; g.beginPath(); g.arc(sx, sy, w * 0.07, 0, 7); g.fill();
  g.fillStyle = 'rgba(255,255,255,0.92)';
  for (const [cx, cy, s] of [[0.22, 0.2, 1], [0.5, 0.12, 0.7], [0.9, 0.18, 0.6]]) for (const [dx, dy, r] of [[-0.06, 0.01, 0.045], [0, -0.015, 0.06], [0.065, 0.005, 0.045], [0.02, 0.025, 0.05]]) { g.beginPath(); g.arc((cx + dx * s) * w, (cy + dy * s) * h, r * s * w, 0, 7); g.fill(); }
  const hill = (y0, amp, col, ph) => { g.fillStyle = col; g.beginPath(); g.moveTo(0, h); for (let x = 0; x <= w; x += 4) g.lineTo(x, h * y0 + Math.sin(x / w * 5 + ph) * amp * h + Math.sin(x / w * 13 + ph * 2) * amp * 0.3 * h); g.lineTo(w, h); g.fill(); };
  hill(0.6, 0.05, '#3A6FD0', 1); hill(0.7, 0.04, '#1E9C8F', 2.5);
  const fx = w * 0.27, fy = h * 0.5;
  g.fillStyle = '#E9EEF6'; g.fillRect(fx - 1.2, fy - h * 0.2, 2.4, h * 0.22);
  if (IMG.tr) g.drawImage(IMG.tr, fx + 1, fy - h * 0.2, w * 0.17, w * 0.113);
  hill(0.8, 0.03, '#15705F', 4); hill(0.9, 0.02, '#0D4F47', 6);
  g.restore();
}
function flag(g, w, h) { if (IMG.tr) g.drawImage(IMG.tr, -w / 2, -h / 2, w, h); }
function wcb(g, w, h) { for (const k of ['a', 'e', 'h']) if (IMG['wcb' + k]) g.drawImage(IMG['wcb' + k], -w / 2, -h / 2, w, h); }
function txt(str, size, col, font = 'InterX') { return (g) => { g.font = `800 ${size}px ${font}`; g.textAlign = 'center'; g.textBaseline = 'middle'; g.fillStyle = col; g.fillText(str, 0, 0); }; }
function starPath(g, r1, r2, n = 5) { g.beginPath(); for (let i = 0; i < n * 2; i++) { const a = -Math.PI / 2 + i * Math.PI / n, r = i % 2 ? r2 : r1; g.lineTo(Math.cos(a) * r, Math.sin(a) * r); } g.closePath(); }
function heartPath(g, s) { g.beginPath(); g.moveTo(0, s * 0.35); g.bezierCurveTo(-s * 0.95, -s * 0.25, -s * 0.45, -s * 0.85, 0, -s * 0.38); g.bezierCurveTo(s * 0.45, -s * 0.85, s * 0.95, -s * 0.25, 0, s * 0.35); g.closePath(); }
const shapeFill = (path, col) => (g, w, h) => { g.fillStyle = col; path(g, w, h); g.fill(); };
function watermelon(g, w, h) { // karpuz dilimi (videodaki limon yerine)
  const r = Math.min(w, h) * 0.46; g.save(); g.translate(0, -r * 0.25);
  g.fillStyle = '#1E8E3E'; g.beginPath(); g.arc(0, 0, r, 0, Math.PI); g.fill();
  g.fillStyle = '#B9F2B0'; g.beginPath(); g.arc(0, 0, r * 0.9, 0, Math.PI); g.fill();
  const gr = g.createRadialGradient(0, 0, 0, 0, 0, r * 0.85); gr.addColorStop(0, '#FF5A6E'); gr.addColorStop(1, '#E8333F'); g.fillStyle = gr; g.beginPath(); g.arc(0, 0, r * 0.84, 0, Math.PI); g.fill();
  g.fillStyle = '#1B1B22'; for (const [a, d] of [[0.5, 0.45], [0.9, 0.6], [1.3, 0.4], [1.7, 0.62], [2.2, 0.48], [2.6, 0.6], [1.15, 0.25], [2.0, 0.28]]) { g.save(); g.translate(Math.cos(a) * r * d, Math.sin(a) * r * d); g.rotate(a); g.beginPath(); g.ellipse(0, 0, r * 0.035, r * 0.06, 0, 0, 7); g.fill(); g.restore(); }
  g.restore();
}
const bgNavy = (g, S) => { const gr = g.createLinearGradient(0, 0, 0, S); gr.addColorStop(0, '#16224A'); gr.addColorStop(1, NAVY); g.fillStyle = gr; g.fillRect(0, 0, S, S); };
const bgLight = (g, S) => { g.fillStyle = '#E3EEFC'; g.fillRect(0, 0, S, S); };
const bgCol = (c) => (g, S) => { g.fillStyle = c; g.fillRect(0, 0, S, S); };
const checkerBg = (g, S) => { for (let y = 0; y < S; y += 12) for (let x = 0; x < S; x += 12) { g.fillStyle = ((x + y) / 12) % 2 ? '#C9D3E3' : '#E3E9F2'; g.fillRect(x, y, 12, 12); } };

// Sahne kalıpları
function photo(type, vals, extra = {}) { return { size: 240, dur: 2.4, fps: 20, bg: bgNavy, layers: [{ x: 120, y: 120, w: 240, h: 240, draw: landscape, fx: [{ type, v: vals }], ...extra }] }; }
function on(drawFn, w, h, type, vals, o = {}) { return { size: 240, dur: o.dur || 2.4, fps: 20, bg: o.bg || bgNavy, layers: [...(o.under || []), { x: o.x ?? 120, y: o.y ?? 120, w, h, draw: drawFn, fx: [{ type, v: vals }], tr: o.tr }, ...(o.over || [])] }; }

const SCENES = {};
const def = (t, sc) => { SCENES[t] = sc; };
// ---- Renk ve Işık ----
def('brightness', photo('brightness', (p) => ({ amount: osc(p, 45, 170) })));
def('contrast', photo('contrast', (p) => ({ amount: osc(p, 40, 210) })));
def('bricon', photo('bricon', (p) => ({ bri: osc(p, -35, 25), con: osc(p, -45, 50) })));
def('exposure', photo('exposure', (p) => ({ exp: osc(p, -1.6, 1.4), gamma: 1 })));
def('saturate', photo('saturate', (p) => ({ amount: osc(p, 0, 260) })));
def('vibrance', photo('vibrance', (p) => ({ sat: osc(p, -80, 10), vib: osc(p, -60, 90) })));
def('hue', photo('hue', (p) => ({ amount: p * 360 })));
def('colortune', photo('colortune', (p) => ({ r: osc(p, -40, 45), g: osc(p, 20, -15), b: osc(p, 45, -40), lit: 0 })));
def('temperature', photo('temperature', (p) => ({ temp: osc(p, -90, 90), tint: 0 })));
def('colorize', photo('colorize', (p) => ({ col: ['#22D3C5', '#2F7BF6', '#8F7CF0', '#E84393', '#F2C230'][Math.floor(p * 4.999)], mix: 100 })));
def('duotone', photo('duotone', (p) => ({ c1: '#0B1430', c2: p < 0.5 ? '#22D3C5' : '#FF5BA7', mix: osc((p * 2) % 1, 30, 100) })));
def('grayscale', photo('grayscale', (p) => ({ amount: osc(p, 0, 100) })));
def('sepia', photo('sepia', (p) => ({ amount: osc(p, 0, 100) })));
def('invert', photo('invert', (p) => ({ amount: osc(p, 0, 100) })));
def('threshold', photo('threshold', (p) => ({ level: osc(p, 60, 200), soft: 4 })));
def('posterize', photo('posterize', (p) => ({ levels: Math.round(osc(p, 2, 8)) })));
def('levels', photo('levels', (p) => ({ lo: osc(p, 0, 70), hi: osc(p, 255, 190), mid: osc(p, 0.8, 1.4) })));
def('gradmap', photo('gradmap', (p) => ({ c1: '#1B2A55', c2: '#F2C230', mix: osc(p, 0, 100) })));
def('palettemap', photo('palettemap', (p) => ({ pal: Math.floor(p * 4.999), cycle: 0, mix: 100 })));
def('hotcolor', photo('hotcolor', (p) => ({ shift: osc(p, -0.3, 0.3), mix: 100 })));
def('spectral', photo('spectral', (p) => ({ shift: p, rep: 1, mix: 100 })));
def('fourcolor', on(wcb, 220, 220, 'fourcolor', () => ({ speed: 0.42, mix: 85 })));
def('gradoverlay', photo('gradoverlay', (p) => ({ c1: '#2F7BF6', c2: '#E84393', ang: p * 360, gtype: 0, mix: 65 })));
def('highshadow', photo('highshadow', (p) => ({ hi: osc(p, 0, -70), sh: osc(p, 0, 90) })));
def('replacecolor', on(flag, 210, 140, 'replacecolor', (p) => ({ from: '#E30A17', to: ['#2F7BF6', '#22D3C5', '#8F7CF0', '#1E9C3F', '#F2C230'][Math.floor(p * 4.999)], tol: 35, soft: 20 }), { bg: bgLight }));
def('spotcolor', photo('spotcolor', (p) => ({ keep: '#E30A17', tol: osc(p, 0, 45), soft: 15 })));
def('solidcolor', on(wcb, 220, 220, 'solidcolor', (p) => ({ col: '#F7F8FA', mix: osc(p, 0, 100) })));
def('longshadow', on(txt('WM', 92, WHITE), 200, 120, 'longshadow', (p) => ({ ang: osc(p, 30, 60), len: osc(p, 20, 140), col: '#0B1430', fade: 40, op: 85 }), { bg: bgCol(TURQ) }));
def('radialshadow', on(wcb, 150, 150, 'radialshadow', (p) => ({ lightX: Math.cos(p * Math.PI * 2) * 300, lightY: -200 + Math.sin(p * Math.PI * 2) * 120, dist: 30, blur: 18, col: '#0B1430', op: 55 }), { bg: bgLight }));
def('lightrays', photo('lightrays', (p) => ({ centerX: 60 + Math.sin(p * Math.PI * 2) * 30, centerY: -60, len: osc(p, 25, 60), amount: 110, thr: 55 })));
def('vignette', photo('vignette', (p) => ({ amount: 90, size: osc(p, 15, 70), soft: 50, col: '#000000', round: 0 })));
window.SCENES = SCENES;
