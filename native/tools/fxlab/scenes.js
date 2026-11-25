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
function photo(type, vals, extra = {}) { return { size: 240, dur: 2, fps: 12, bg: bgNavy, layers: [{ x: 120, y: 120, w: 240, h: 240, draw: landscape, fx: [{ type, v: vals }], ...extra }] }; }
function on(drawFn, w, h, type, vals, o = {}) { return { size: 240, dur: o.dur || 2, fps: 12, bg: o.bg || bgNavy, layers: [...(o.under || []), { x: o.x ?? 120, y: o.y ?? 120, w, h, draw: drawFn, fx: [{ type, v: vals }], tr: o.tr }, ...(o.over || [])] }; }

const SCENES = {};
const def = (t, sc) => { SCENES[t] = sc; };
// ---- Renk ve Işık (her efekt farklı bir konu) ----
const Sb = SUBJ;
const full = (draw, type, vals, o = {}) => ({ size: 240, dur: o.dur || 2, fps: 12, bg: o.bg || bgNavy, layers: [...(o.under || []), { x: 120, y: 120, w: o.w || 240, h: o.h || 240, draw, fx: [{ type, v: vals }], tr: o.tr }, ...(o.over || [])] });
const cbGroup = (g, w, h) => { Sb.cb('az', 'mutlu')(g, w * 0.3, h * 0.3); g.save(); g.translate(-w * 0.3, h * 0.08); Sb.cb('tr', 'normal', 'fes')(g, w * 0.36, h * 0.36); g.restore(); g.save(); g.translate(w * 0.3, h * 0.1); Sb.cb('jp', 'saskin')(g, w * 0.32, h * 0.32); g.restore(); };
const onCol = (c, fn) => (g, w, h) => { g.fillStyle = c; g.fillRect(-w / 2, -h / 2, w, h); fn(g, w, h); };
const lightBg = (fn) => onCol('#E3EEFC', fn);
def('brightness', full(Sb.laleler, 'brightness', (p) => ({ amount: osc(p, 45, 170) })));
def('contrast', full(Sb.dag, 'contrast', (p) => ({ amount: osc(p, 35, 210) })));
def('bricon', full(Sb.istanbul, 'bricon', (p) => ({ bri: osc(p, -30, 25), con: osc(p, -50, 55) })));
def('exposure', full(Sb.denizalti, 'exposure', (p) => ({ exp: osc(p, -1.8, 1.4), gamma: 1 })));
def('saturate', full(Sb.aycicek, 'saturate', (p) => ({ amount: osc(p, 0, 260) })));
def('vibrance', full(Sb.nar, 'vibrance', (p) => ({ sat: osc(p, -85, 10), vib: osc(p, -60, 100) })));
def('hue', full(Sb.gece, 'hue', (p) => ({ amount: p * 360 })));
def('colortune', full(Sb.cay, 'colortune', (p) => ({ r: osc(p, -40, 45), g: osc(p, 25, -15), b: osc(p, 50, -45), lit: 0 })));
def('temperature', full(Sb.kapadokya, 'temperature', (p) => ({ temp: osc(p, -95, 85), tint: 0 })));
def('colorize', full(lightBg(Sb.wcbPose('mutlu')), 'colorize', (p) => ({ col: ['#22D3C5', '#2F7BF6', '#8F7CF0', '#E84393', '#F2C230'][Math.floor(p * 4.999)], mix: 100 })));
def('duotone', full(Sb.uzay, 'duotone', (p) => ({ c1: p < 0.5 ? '#0B1430' : '#2B0B4A', c2: p < 0.5 ? '#22D3C5' : '#FF8FD1', mix: osc((p * 2) % 1, 25, 100) })));
def('grayscale', full(onCol('#DCE9FF', cbGroup), 'grayscale', (p) => ({ amount: osc(p, 0, 100) })));
def('sepia', full(Sb.kapadokya, 'sepia', (p) => ({ amount: osc(p, 0, 100) })));
def('invert', full(Sb.dag, 'invert', (p) => ({ amount: osc(p, 0, 100) })));
def('threshold', full(lightBg(Sb.cb('tr', 'kizgin', 'fes')), 'threshold', (p) => ({ level: osc(p, 40, 210), soft: 3 }), { w: 200, h: 200 }));
def('posterize', full(Sb.aycicek, 'posterize', (p) => ({ levels: Math.round(osc(p, 2, 7)) })));
def('levels', full(Sb.cay, 'levels', (p) => ({ lo: osc(p, 0, 80), hi: osc(p, 255, 185), mid: osc(p, 0.75, 1.4) })));
def('gradmap', full(Sb.istanbul, 'gradmap', (p) => ({ c1: '#1B2A55', c2: '#F2C230', mix: osc(p, 0, 100) })));
def('palettemap', full(Sb.gece, 'palettemap', (p) => ({ pal: Math.floor(p * 4.999), cycle: 0, mix: 100 })));
def('hotcolor', full(onCol('#0B1430', Sb.wcbPose('heyecanli')), 'hotcolor', (p) => ({ shift: osc(p, -0.25, 0.3), mix: osc(p, 0, 100) })));
def('spectral', full(Sb.nar, 'spectral', (p) => ({ shift: p, rep: 1.2, mix: 100 })));
def('fourcolor', full(Sb.word('RENK', 72, '#FFFFFF'), 'fourcolor', () => ({ speed: 0.42, mix: 100 }), { bg: bgNavy, w: 230, h: 120 }));
def('gradoverlay', full(Sb.kapadokya, 'gradoverlay', (p) => ({ c1: '#2F7BF6', c2: '#E84393', ang: p * 360, gtype: 0, mix: 60 })));
def('highshadow', full(Sb.denizalti, 'highshadow', (p) => ({ hi: osc(p, 0, -70), sh: osc(p, 0, 95) })));
def('replacecolor', full(lightBg(Sb.cb('tr', 'mutlu')), 'replacecolor', (p) => ({ from: '#E30A17', to: ['#2F7BF6', '#22D3C5', '#8F7CF0', '#1E9C3F', '#F2C230'][Math.floor(p * 4.999)], tol: 35, soft: 20 }), { w: 200, h: 200 }));
def('spotcolor', full(Sb.laleler, 'spotcolor', (p) => ({ keep: '#E8333F', tol: osc(p, 0, 40), soft: 15 })));
def('solidcolor', full(Sb.wcbPose('selam-veriyor'), 'solidcolor', (p) => ({ col: '#F7F8FA', mix: osc(p, 0, 100) }), { bg: (g, S) => { g.fillStyle = '#2F7BF6'; g.fillRect(0, 0, S, S); }, w: 220, h: 200 }));
def('longshadow', full(Sb.word('GÖLGE', 60, '#F7F8FA'), 'longshadow', (p) => ({ ang: osc(p, 30, 60), len: osc(p, 20, 130), col: '#0B1430', fade: 40, op: 85 }), { bg: (g, S) => { g.fillStyle = '#22D3C5'; g.fillRect(0, 0, S, S); }, w: 220, h: 90 }));
def('radialshadow', full(Sb.cb('az', 'normal', 'silindir'), 'radialshadow', (p) => ({ lightX: Math.cos(p * Math.PI * 2) * 300, lightY: -220 + Math.sin(p * Math.PI * 2) * 120, dist: 30, blur: 18, col: '#0B1430', op: 55 }), { bg: (g, S) => { g.fillStyle = '#E3EEFC'; g.fillRect(0, 0, S, S); }, w: 130, h: 130 }));
def('lightrays', full(Sb.istanbul, 'lightrays', (p) => ({ centerX: 30 + Math.sin(p * Math.PI * 2) * 25, centerY: 30, len: osc(p, 25, 60), amount: 120, thr: 55 })));
def('vignette', full(Sb.cay, 'vignette', (p) => ({ amount: 92, size: osc(p, 12, 65), soft: 50, col: '#000000', round: 0 })));

// ---- Çizim ve Kenar ----
const dark = (c) => (g, S) => { g.fillStyle = c; g.fillRect(0, 0, S, S); };
const gradBg = (c1, c2) => (g, S) => { const gr = g.createLinearGradient(0, 0, 0, S); gr.addColorStop(0, c1); gr.addColorStop(1, c2); g.fillStyle = gr; g.fillRect(0, 0, S, S); };
const star = (col, r1 = 0.46, r2 = 0.2, n = 5) => (g, w, h) => { const s = Math.min(w, h); g.fillStyle = col; starPath(g, s * r1, s * r2, n); g.fill(); };
const heart = (col) => (g, w, h) => { const s = Math.min(w, h); g.save(); g.translate(0, s * 0.12); g.fillStyle = col; heartPath(g, s * 0.62); g.fill(); g.restore(); };
const card = (fn, r = 14) => (g, w, h) => { g.save(); rr(g, -w / 2, -h / 2, w, h, r); g.clip(); fn(g, w, h); g.restore(); };
def('glow', full(Sb.word('PARLA', 58, '#FFE6A8'), 'glow', (p) => ({ amount: osc(p, 4, 18), col: '#F2C230', str: 130 }), { bg: dark('#0B1430'), w: 220, h: 90 }));
def('shadow', full(Sb.cb('jp', 'mutlu', 'tac'), 'shadow', (p) => ({ amount: 10, dist: 16, ang: p * 360, col: '#0D1631', op: 55 }), { bg: dark('#E3EEFC'), w: 140, h: 140 }));
def('stroke', full(Sb.wcbPose('gururlu'), 'stroke', (p) => ({ width: osc(p, 0, 9), col: '#22D3C5', pos: 0 }), { bg: dark('#16224A'), w: 190, h: 170 }));
def('innerglow', full(heart('#E84393'), 'innerglow', (p) => ({ amount: osc(p, 2, 22), col: '#FFF2F8', str: 160 }), { bg: dark('#0B1430'), w: 190, h: 190 }));
def('innershadow', full(Sb.cb('br', 'saskin'), 'innershadow', (p) => ({ amount: 8, dist: osc(p, 0, 16), ang: 135, col: '#000000', op: 70 }), { bg: dark('#E3EEFC'), w: 160, h: 160 }));
def('edges', full(Sb.istanbul, 'edges', (p) => ({ amount: osc(p, 60, 260), inv: 1, mix: osc(p, 0, 100) })));
def('emboss', full(Sb.cay, 'emboss', (p) => ({ ang: p * 360, height: 3, mix: 100 })));
def('halftone', full(Sb.laleler, 'halftone', (p) => ({ size: osc(p, 4, 12), ang: 45, mode: 0, bg: '#F7F8FA' })));
def('sketch', full(Sb.kapadokya, 'sketch', (p) => ({ amount: 160, detail: 1.2, mix: osc(p, 0, 100) })));
def('neonedge', full(Sb.logo, 'neonedge', (p) => ({ col: ['#22D3C5', '#FF3DCB', '#F2C230', '#3FD0F0'][Math.floor(p * 3.999)], width: 1.4, glow: 160 }), { bg: dark('#06091C'), w: 170, h: 170 }));
def('cartoon', full(Sb.aycicek, 'cartoon', (p) => ({ levels: Math.round(osc(p, 8, 3)), edge: osc(p, 40, 180) })));
def('roughen', full(Sb.word('YIRTIK', 56, '#F7F8FA'), 'roughen', (p) => ({ amount: osc(p, 0, 7), scale: 14, speed: 0 }), { bg: dark('#C8102E'), w: 220, h: 100 }));
// Çizerek Belirme: şeklin kenarı kalemle çiziliyor (uygulamada şekil katmanının kendisi)
SCENES['drawpath'] = { size: 240, dur: 2, fps: 12, bg: dark('#0B1430'), layers: [{ x: 120, y: 120, w: 200, h: 200, fx: [], draw: (g, w, h) => {
  const p = window.PHASE || 0, prog = Math.min(1, p * 1.4); const s = Math.min(w, h);
  g.lineWidth = 7; g.strokeStyle = '#22D3C5'; g.lineJoin = 'round'; g.lineCap = 'round';
  starPath(g, s * 0.46, s * 0.2, 5); const L = 10 * (s * 0.46 + s * 0.2) * 0.98; g.setLineDash([L * prog, L]); g.stroke(); g.setLineDash([]);
  if (p > 0.72) { g.globalAlpha = Math.min(1, (p - 0.72) / 0.18); g.fillStyle = '#22D3C5'; starPath(g, s * 0.46, s * 0.2, 5); g.fill(); g.globalAlpha = 1; }
} }] };
def('frame', full(Sb.wcbPose('selam-veriyor'), 'frame', (p) => ({ width: osc(p, 0, 12), col: '#F2C230', rad: osc(p, 0, 40) }), { bg: dark('#1B2A55'), w: 170, h: 150 }));
def('brushstrokes', full(Sb.dag, 'brushstrokes', (p) => ({ size: osc(p, 1, 7), ang: 45, len: 60, rand: 40 })));
def('glass', full(Sb.gece, 'glass', (p) => ({ amount: osc(p, 0, 14), size: 18, tex: Math.floor(p * 3.999), shine: 40 })));
def('plastic', full(heart('#E8333F'), 'plastic', (p) => ({ height: osc(p, 1, 8), ang: p * 360, gloss: 90, soft: 50 }), { bg: dark('#F3E4CF'), w: 190, h: 190 }));
def('coloremboss', full(Sb.nar, 'coloremboss', (p) => ({ ang: p * 360, height: 3, amount: 160 })));
def('texturize', full(Sb.wcbPose('dusunceli'), 'texturize', (p) => ({ tex: Math.floor(p * 4.999), amount: 80, scale: 60 }), { bg: dark('#E3EEFC'), w: 210, h: 190 }));
def('bevelalpha', full(Sb.logo, 'bevelalpha', (p) => ({ width: osc(p, 1, 8), ang: p * 360, light: 90 }), { bg: dark('#E3EEFC'), w: 170, h: 170 }));
def('beveledges', full(card(Sb.kapadokya, 2), 'beveledges', (p) => ({ width: osc(p, 0, 16), ang: 135, light: 70 }), { bg: dark('#16224A'), w: 180, h: 180 }));
def('spotlight', full((g, w, h) => { g.fillStyle = '#1B2A55'; g.fillRect(-w / 2, -h / 2, w, h); cbGroup(g, w, h); }, 'spotlight', (p) => ({ posX: Math.cos(p * Math.PI * 2) * 70, posY: Math.sin(p * Math.PI * 4) * 25, rad: 70, soft: 40, dark: 85, col: '#FFF2CC' })));
def('anaglyph', full(Sb.denizalti, 'anaglyph', (p) => ({ amount: osc(p, 0, 7) })));
def('lightsweep', full(Sb.word('WARDEN', 52, '#C9A227', { grad: [[0, '#F7E08A'], [1, '#B8860B']] }), 'lightsweep', (p) => ({ pos: -30 + p * 160, ang: 30, width: 24, col: '#FFFFFF', str: 120 }), { bg: dark('#0B1430'), w: 230, h: 80 }));
def('vegas', full(star('#1B2A55'), 'vegas', () => ({ count: 18, width: 3.2, speed: 0.6, col: '#F2C230', on: 0 }), { bg: dark('#0B1430'), w: 210, h: 210 }));
def('scribble', full(heart('#E8333F'), 'scribble', (p) => ({ width: 2.2, space: osc(p, 4, 9), ang: 30, wiggle: 2, col: '#C8102E', keep: 0 }), { bg: dark('#F7F8FA'), w: 200, h: 200 }));
def('watercolor', full(Sb.istanbul, 'watercolor', (p) => ({ amount: osc(p, 0, 100), size: 5 })));
def('oilpaint', full(Sb.aycicek, 'oilpaint', (p) => ({ size: osc(p, 1, 5), shine: 40 })));
def('comic', full(Sb.cb('tr', 'kizgin', 'fes'), 'comic', (p) => ({ dot: osc(p, 3, 7), edge: 160, levels: 4 }), { bg: dark('#F2C230'), w: 180, h: 180 }));
def('stipple', full(Sb.wcbPose('merakli'), 'stipple', (p) => ({ size: osc(p, 2, 4.5), col: '#0B1430', bg: '#F7F8FA' }), { bg: dark('#F7F8FA'), w: 210, h: 190 }));
def('neonsign', full(Sb.word('AÇIK', 70, '#FFFFFF'), 'neonsign', (p) => ({ col: '#FF3DCB', width: 2.5, glow: 180, flick: 60 }), { bg: gradBg('#2A1030', '#120818'), w: 210, h: 110 }));
def('hologram', full(Sb.wcbPose('selam-veriyor'), 'hologram', () => ({ col: '#3FD0F0', lines: 60, flick: 40, speed: 1 }), { bg: gradBg('#0B1430', '#06091C'), w: 200, h: 180 }));
def('thresholdrgb', full(Sb.nar, 'thresholdrgb', (p) => ({ r: osc(p, 60, 190), g: osc(p, 190, 60), b: 128 })));
def('scatterpx', full(Sb.laleler, 'scatterpx', (p) => ({ amount: osc(p, 0, 9), dir: 0, anim: 1 })));
def('repetile', full(Sb.cb('az', 'mutlu'), 'repetile', (p) => ({ l: 90, r: 90, u: 90, d: 90, mode: Math.floor(p * 2.999) }), { bg: dark('#E3EEFC'), w: 70, h: 70 }));
def('burnfilm', full(Sb.kapadokya, 'burnfilm', (p) => ({ prog: osc(p, 0, 42), scale: 90, centerX: 30, centerY: 20 }), { bg: dark('#0B1430') }));
def('blockload', full(Sb.dag, 'blockload', (p) => ({ prog: Math.min(100, p * 130), scan: 1 })));

window.SCENES = SCENES;
// Konu galerisi (efektsiz) — kontrol için
window.TEST_SCENES = {};
for (const [k, fn] of Object.entries({ kapadokya: SUBJ.kapadokya, istanbul: SUBJ.istanbul, cay: SUBJ.cay, laleler: SUBJ.laleler, aycicek: SUBJ.aycicek, nar: SUBJ.nar, denizalti: SUBJ.denizalti, uzay: SUBJ.uzay, gece: SUBJ.gece, dag: SUBJ.dag,
  cbtr: SUBJ.cb('tr', 'mutlu', 'fes'), cbjp: SUBJ.cb('jp', 'normal', 'tac'), wcb: SUBJ.wcbPose('asik'), yazi: SUBJ.word('MERHABA', 46, '#F7F8FA'), kroma: SUBJ.greenCB('br') }))
  TEST_SCENES['_' + k] = { size: 240, dur: 0.05, fps: 20, bg: bgNavy, layers: [{ x: 120, y: 120, w: 240, h: 240, draw: fn, fx: [] }] };
