// Önizleme konuları: her efekt kendine uygun, birbirinden farklı bir konu kullanır.
// Hepsi (0,0) merkezli, w×h kutuya çizilir. Gradyanlı, temiz vektör çizimler + uygulamanın kendi paketleri.
const L = (g, x0, y0, x1, y1, stops) => { const gr = g.createLinearGradient(x0, y0, x1, y1); stops.forEach(([o, c]) => gr.addColorStop(o, c)); return gr; };
const R = (g, x, y, r0, r1, stops) => { const gr = g.createRadialGradient(x, y, r0, x, y, r1); stops.forEach(([o, c]) => gr.addColorStop(o, c)); return gr; };
const box = (fn) => (g, w, h, a) => { g.save(); g.translate(-w / 2, -h / 2); fn(g, w, h, typeof a === 'number' ? a : (window.PHASE || 0)); g.restore(); };
function circle(g, x, y, r) { g.beginPath(); g.arc(x, y, r, 0, Math.PI * 2); }
function seeded(s) { return () => { s = (s * 16807) % 2147483647; return s / 2147483647; }; }

// ---------- Kapadokya: şafakta balonlar, peri bacaları ----------
const kapadokya = box((g, w, h, a) => {
  g.fillStyle = L(g, 0, 0, 0, h, [[0, '#2B3F8C'], [0.45, '#E58AA8'], [0.75, '#FFC98A'], [1, '#FFE2B0']]); g.fillRect(0, 0, w, h);
  g.fillStyle = R(g, w * 0.5, h * 0.78, 0, w * 0.5, [[0, 'rgba(255,236,190,0.9)'], [1, 'rgba(255,236,190,0)']]); g.fillRect(0, 0, w, h);
  const balloon = (x, y, s, c1, c2) => {
    g.save(); g.translate(x, y); g.scale(s, s);
    g.fillStyle = L(g, -30, 0, 30, 0, [[0, c1], [0.5, c2], [1, c1]]);
    g.beginPath(); g.moveTo(0, -38); g.bezierCurveTo(30, -38, 34, -8, 18, 12); g.lineTo(7, 26); g.lineTo(-7, 26); g.lineTo(-18, 12); g.bezierCurveTo(-34, -8, -30, -38, 0, -38); g.fill();
    g.strokeStyle = 'rgba(0,0,0,0.25)'; g.lineWidth = 1.2; for (const k of [-12, 0, 12]) { g.beginPath(); g.moveTo(k * 0.6, -37); g.quadraticCurveTo(k * 1.6, -6, k * 0.5, 25); g.stroke(); }
    g.strokeStyle = '#5A3B23'; g.lineWidth = 1; g.beginPath(); g.moveTo(-6, 26); g.lineTo(-5, 33); g.moveTo(6, 26); g.lineTo(5, 33); g.stroke();
    g.fillStyle = '#7A4A26'; g.fillRect(-6, 32, 12, 8); g.restore();
  };
  balloon(w * 0.28, h * 0.36 - a * 6, 0.9, '#E8333F', '#FF8A5C'); balloon(w * 0.7, h * 0.24 - a * 4, 0.6, '#2F7BF6', '#8FD3FF');
  balloon(w * 0.53, h * 0.5 - a * 8, 1.15, '#F2C230', '#FFE680'); balloon(w * 0.86, h * 0.46, 0.45, '#22D3C5', '#C9FFF6'); balloon(w * 0.12, h * 0.18, 0.4, '#8F7CF0', '#E2D8FF');
  const chim = (x, base, wd, ht, c) => { g.fillStyle = c; g.beginPath(); g.moveTo(x - wd, base); g.quadraticCurveTo(x - wd * 0.6, base - ht * 0.6, x - wd * 0.25, base - ht); g.quadraticCurveTo(x, base - ht * 1.12, x + wd * 0.25, base - ht); g.quadraticCurveTo(x + wd * 0.6, base - ht * 0.6, x + wd, base); g.fill();
    g.fillStyle = 'rgba(60,30,20,0.55)'; g.beginPath(); g.ellipse(x, base - ht * 0.98, wd * 0.42, ht * 0.08, 0, 0, 7); g.fill(); };
  chim(w * 0.12, h, w * 0.1, h * 0.3, '#C98A63'); chim(w * 0.3, h, w * 0.08, h * 0.22, '#D9A07A'); chim(w * 0.78, h, w * 0.11, h * 0.34, '#BE7D58'); chim(w * 0.95, h, w * 0.08, h * 0.2, '#D9A07A');
  g.fillStyle = L(g, 0, h * 0.85, 0, h, [[0, '#B7744F'], [1, '#8F5638']]); g.beginPath(); g.moveTo(0, h); for (let x = 0; x <= w; x += 6) g.lineTo(x, h * 0.9 + Math.sin(x / w * 9) * h * 0.02); g.lineTo(w, h); g.fill();
});

// ---------- İstanbul: gün batımı, Galata Kulesi, cami, martılar ----------
const istanbul = box((g, w, h, a) => {
  g.fillStyle = L(g, 0, 0, 0, h * 0.68, [[0, '#2A1F5C'], [0.45, '#C3427A'], [0.8, '#FF8A4C'], [1, '#FFD27A']]); g.fillRect(0, 0, w, h);
  g.fillStyle = R(g, w * 0.62, h * 0.62, 0, w * 0.35, [[0, 'rgba(255,240,180,1)'], [0.18, 'rgba(255,200,110,0.95)'], [1, 'rgba(255,160,90,0)']]); g.fillRect(0, 0, w, h);
  g.fillStyle = '#FFE7A8'; circle(g, w * 0.62, h * 0.62, w * 0.07); g.fill();
  const sil = '#1B1238';
  g.fillStyle = sil; g.beginPath(); g.moveTo(0, h * 0.68);
  for (const [x, y] of [[0.05, 0.64], [0.12, 0.66], [0.18, 0.62], [0.24, 0.65], [0.86, 0.64], [0.93, 0.6], [1, 0.63]]) g.lineTo(x * w, y * h);
  g.lineTo(w, h * 0.7); g.lineTo(0, h * 0.7); g.fill();
  // Galata Kulesi
  const gx = w * 0.3; g.fillRect(gx - w * 0.035, h * 0.38, w * 0.07, h * 0.3); g.beginPath(); g.moveTo(gx - w * 0.045, h * 0.39); g.lineTo(gx, h * 0.27); g.lineTo(gx + w * 0.045, h * 0.39); g.fill();
  g.fillRect(gx - w * 0.045, h * 0.39, w * 0.09, h * 0.025);
  g.fillStyle = 'rgba(255,200,120,0.85)'; for (let i = 0; i < 3; i++) g.fillRect(gx - w * 0.024 + i * w * 0.018, h * 0.425, w * 0.008, h * 0.02);
  // Cami: kubbe + minareler
  g.fillStyle = sil; const cx = w * 0.8; g.beginPath(); g.arc(cx, h * 0.58, w * 0.09, Math.PI, 0); g.fill(); g.fillRect(cx - w * 0.12, h * 0.58, w * 0.24, h * 0.1);
  g.beginPath(); g.arc(cx - w * 0.09, h * 0.61, w * 0.04, Math.PI, 0); g.arc(cx + w * 0.09, h * 0.61, w * 0.04, Math.PI, 0); g.fill();
  for (const mx of [cx - w * 0.15, cx + w * 0.15]) { g.fillRect(mx - w * 0.008, h * 0.4, w * 0.016, h * 0.28); g.beginPath(); g.moveTo(mx - w * 0.012, h * 0.41); g.lineTo(mx, h * 0.34); g.lineTo(mx + w * 0.012, h * 0.41); g.fill(); }
  g.fillRect(cx - w * 0.003, h * 0.47, w * 0.006, h * 0.03);
  // deniz + yansıma
  g.fillStyle = L(g, 0, h * 0.68, 0, h, [[0, '#4A2F6E'], [1, '#1E1440']]); g.fillRect(0, h * 0.68, w, h * 0.32);
  for (let i = 0; i < 14; i++) { const y = h * 0.7 + i * h * 0.022; const ww = w * (0.18 - i * 0.008) * (1 + 0.2 * Math.sin(i + a * 6)); g.fillStyle = `rgba(255,${190 - i * 4},120,${0.6 - i * 0.035})`; g.fillRect(w * 0.62 - ww / 2 + Math.sin(i * 1.7 + a * 6) * 3, y, ww, h * 0.006); }
  g.strokeStyle = '#1B1238'; g.lineWidth = 1.6; g.lineCap = 'round';
  for (const [x, y, s] of [[0.2, 0.2, 1], [0.27, 0.16, 0.8], [0.45, 0.25, 0.7]]) { const X = (x + a * 0.05) * w, Y = y * h; g.beginPath(); g.moveTo(X - 7 * s, Y); g.quadraticCurveTo(X - 3 * s, Y - 4 * s, X, Y); g.quadraticCurveTo(X + 3 * s, Y - 4 * s, X + 7 * s, Y); g.stroke(); }
});

// ---------- Türk çayı + simit ----------
const cay = box((g, w, h, a) => {
  g.fillStyle = L(g, 0, 0, 0, h, [[0, '#F3E4CF'], [1, '#E2C9A6']]); g.fillRect(0, 0, w, h);
  g.fillStyle = L(g, 0, h * 0.72, 0, h, [[0, '#8A5A3A'], [1, '#6B4229']]); g.fillRect(0, h * 0.72, w, h * 0.28);
  g.strokeStyle = 'rgba(255,255,255,0.08)'; g.lineWidth = 2; for (let i = 0; i < 6; i++) { g.beginPath(); g.moveTo(0, h * (0.76 + i * 0.04)); g.lineTo(w, h * (0.75 + i * 0.04)); g.stroke(); }
  // simit
  const sx = w * 0.27, sy = h * 0.74, sr = w * 0.17;
  g.fillStyle = 'rgba(0,0,0,0.18)'; g.beginPath(); g.ellipse(sx, sy + sr * 0.35, sr * 1.05, sr * 0.3, 0, 0, 7); g.fill();
  g.fillStyle = L(g, sx, sy - sr * 0.4, sx, sy + sr * 0.4, [[0, '#D98C3E'], [0.5, '#B8692A'], [1, '#8A4A1C']]); g.beginPath(); g.ellipse(sx, sy, sr, sr * 0.42, 0, 0, 7); g.fill();
  g.fillStyle = '#E3C9A6'; g.beginPath(); g.ellipse(sx, sy - sr * 0.04, sr * 0.38, sr * 0.14, 0, 0, 7); g.fill();
  const rnd = seeded(7); g.fillStyle = '#FFF1D6'; for (let i = 0; i < 70; i++) { const t = rnd() * Math.PI * 2, rr2 = sr * (0.55 + rnd() * 0.4); const x = sx + Math.cos(t) * rr2, y = sy + Math.sin(t) * rr2 * 0.42; if (Math.sin(t) > 0.6) continue; g.beginPath(); g.ellipse(x, y, 1.6, 0.9, t, 0, 7); g.fill(); }
  // ince belli bardak + tabak
  const cx = w * 0.66, by = h * 0.8;
  g.fillStyle = 'rgba(0,0,0,0.2)'; g.beginPath(); g.ellipse(cx, by + 4, w * 0.2, h * 0.035, 0, 0, 7); g.fill();
  g.fillStyle = L(g, cx - w * 0.2, 0, cx + w * 0.2, 0, [[0, '#C8102E'], [0.5, '#F04A5B'], [1, '#B00E28']]); g.beginPath(); g.ellipse(cx, by, w * 0.19, h * 0.04, 0, 0, 7); g.fill();
  g.fillStyle = '#FFFFFF'; g.beginPath(); g.ellipse(cx, by - 2, w * 0.13, h * 0.022, 0, 0, 7); g.fill();
  const top = h * 0.36, wTop = w * 0.11, wMid = w * 0.075, wBot = w * 0.095;
  const glass = () => { g.beginPath(); g.moveTo(cx - wTop, top); g.bezierCurveTo(cx - wTop, top + h * 0.12, cx - wMid, top + h * 0.17, cx - wMid, top + h * 0.22); g.bezierCurveTo(cx - wMid, top + h * 0.3, cx - wBot, top + h * 0.38, cx - wBot * 0.9, by - 4);
    g.lineTo(cx + wBot * 0.9, by - 4); g.bezierCurveTo(cx + wBot, top + h * 0.38, cx + wMid, top + h * 0.3, cx + wMid, top + h * 0.22); g.bezierCurveTo(cx + wMid, top + h * 0.17, cx + wTop, top + h * 0.12, cx + wTop, top); g.closePath(); };
  g.save(); glass(); g.clip();
  g.fillStyle = L(g, cx - wTop, 0, cx + wTop, 0, [[0, '#7A1405'], [0.35, '#C33A0E'], [0.6, '#E0581A'], [1, '#8A1A06']]); g.fillRect(cx - wTop, top + h * 0.04, wTop * 2, by);
  g.fillStyle = 'rgba(255,255,255,0.35)'; g.fillRect(cx - wTop * 0.7, top, wTop * 0.18, by);
  g.restore();
  g.strokeStyle = 'rgba(255,255,255,0.8)'; g.lineWidth = 1.4; glass(); g.stroke();
  g.strokeStyle = 'rgba(255,255,255,0.55)'; g.lineWidth = 1.6; for (let i = 0; i < 3; i++) { const x0 = cx - 8 + i * 8; g.beginPath(); g.moveTo(x0, top - 4); g.bezierCurveTo(x0 + 6 + Math.sin(a * 6 + i) * 3, top - 16, x0 - 6, top - 26, x0 + Math.sin(a * 6 + i) * 4, top - 38); g.stroke(); }
});

// ---------- Laleler (vazoda) ----------
const laleler = box((g, w, h, a) => {
  g.fillStyle = L(g, 0, 0, w, h, [[0, '#DCEBFF'], [1, '#B8D2F5']]); g.fillRect(0, 0, w, h);
  g.fillStyle = 'rgba(255,255,255,0.5)'; g.fillRect(w * 0.08, 0, w * 0.04, h); g.fillRect(w * 0.15, 0, w * 0.015, h);
  const vx = w * 0.5, vy = h * 0.92;
  const tulip = (x, y, ang, c1, c2, s) => {
    g.save(); g.strokeStyle = '#2E8B57'; g.lineWidth = 3 * s; g.beginPath(); g.moveTo(vx, vy - h * 0.25); g.quadraticCurveTo((vx + x) / 2, (vy - h * 0.25 + y) / 2 + 10, x, y + 12 * s); g.stroke();
    g.translate(x, y); g.rotate(ang); g.scale(s, s);
    g.fillStyle = L(g, -14, 0, 14, 0, [[0, c2], [0.5, c1], [1, c2]]);
    g.beginPath(); g.moveTo(0, 16); g.bezierCurveTo(-16, 14, -17, -6, -12, -20); g.lineTo(-6, -10); g.lineTo(0, -22); g.lineTo(6, -10); g.lineTo(12, -20); g.bezierCurveTo(17, -6, 16, 14, 0, 16); g.fill();
    g.fillStyle = 'rgba(255,255,255,0.25)'; g.beginPath(); g.ellipse(-5, -2, 3, 9, 0.2, 0, 7); g.fill(); g.restore();
  };
  g.fillStyle = '#2E8B57'; for (const [x, r] of [[-0.12, -0.5], [0.13, 0.5]]) { g.save(); g.translate(vx + x * w, vy - h * 0.3); g.rotate(r); g.beginPath(); g.ellipse(0, 0, w * 0.03, h * 0.14, 0, 0, 7); g.fill(); g.restore(); }
  tulip(w * 0.32, h * 0.3, -0.3, '#E8333F', '#A3101E', 1.25); tulip(w * 0.5, h * 0.2, 0, '#FF5BA7', '#C21E6E', 1.35); tulip(w * 0.68, h * 0.3, 0.3, '#F2C230', '#C78F12', 1.25);
  tulip(w * 0.4, h * 0.42, -0.15, '#8F7CF0', '#5B44C8', 1.05); tulip(w * 0.6, h * 0.43, 0.18, '#FF8A3D', '#C8521A', 1.05);
  g.fillStyle = L(g, vx - w * 0.16, 0, vx + w * 0.16, 0, [[0, '#1F5FD6'], [0.45, '#5FB2F2'], [1, '#1B47A8']]);
  g.beginPath(); g.moveTo(vx - w * 0.09, vy - h * 0.3); g.bezierCurveTo(vx - w * 0.2, vy - h * 0.2, vx - w * 0.18, vy - h * 0.03, vx - w * 0.1, vy); g.lineTo(vx + w * 0.1, vy); g.bezierCurveTo(vx + w * 0.18, vy - h * 0.03, vx + w * 0.2, vy - h * 0.2, vx + w * 0.09, vy - h * 0.3); g.fill();
  g.strokeStyle = 'rgba(255,255,255,0.9)'; g.lineWidth = 2; g.beginPath(); for (let i = 0; i <= 8; i++) { const x = vx - w * 0.12 + i * w * 0.03; g.lineTo(x, vy - h * 0.15 + (i % 2) * 8); } g.stroke();
  g.fillStyle = 'rgba(255,255,255,0.35)'; g.beginPath(); g.ellipse(vx - w * 0.07, vy - h * 0.16, w * 0.015, h * 0.08, 0.1, 0, 7); g.fill();
  g.fillStyle = 'rgba(0,0,0,0.15)'; g.fillRect(0, vy, w, h - vy);
});

// ---------- Ayçiçekleri ----------
const aycicek = box((g, w, h, a) => {
  g.fillStyle = L(g, 0, 0, 0, h, [[0, '#3E8EF7'], [0.6, '#9FD6FF'], [1, '#D8F0FF']]); g.fillRect(0, 0, w, h);
  const flower = (x, y, r, rot) => {
    g.save(); g.translate(x, y); g.rotate(rot);
    for (let k = 0; k < 2; k++) for (let i = 0; i < 18; i++) { g.save(); g.rotate(i * Math.PI * 2 / 18 + k * 0.17); g.fillStyle = L(g, 0, 0, 0, -r * 1.8, [[0, '#E89B0C'], [1, k ? '#FFD23F' : '#F7B500']]); g.beginPath(); g.ellipse(0, -r * 1.15, r * 0.22, r * 0.62, 0, 0, 7); g.fill(); g.restore(); }
    g.fillStyle = R(g, 0, 0, 0, r, [[0, '#3A2211'], [0.7, '#5C3316'], [1, '#7A4A1E']]); circle(g, 0, 0, r * 0.75); g.fill();
    g.fillStyle = 'rgba(255,200,80,0.3)'; for (let i = 0; i < 40; i++) { const t = i * 2.4, d = Math.sqrt(i / 40) * r * 0.68; circle(g, Math.cos(t) * d, Math.sin(t) * d, r * 0.04); g.fill(); }
    g.restore();
  };
  g.strokeStyle = '#2E7D32'; g.lineWidth = 5;
  for (const [x, y] of [[0.3, 0.42], [0.72, 0.3], [0.55, 0.68]]) { g.beginPath(); g.moveTo(x * w, y * h); g.quadraticCurveTo(x * w + 10, (y + 0.3) * h, x * w, h); g.stroke(); }
  g.fillStyle = '#3A9D40'; for (const [x, y, r] of [[0.36, 0.62, 0.6], [0.65, 0.5, -0.6], [0.5, 0.86, 0.5]]) { g.save(); g.translate(x * w, y * h); g.rotate(r); g.beginPath(); g.ellipse(0, 0, w * 0.08, w * 0.035, 0, 0, 7); g.fill(); g.restore(); }
  flower(w * 0.3, h * 0.42, w * 0.11, a * 0.3); flower(w * 0.72, h * 0.3, w * 0.09, -a * 0.3); flower(w * 0.55, h * 0.68, w * 0.13, 0.2);
});

// ---------- Nar ----------
const nar = box((g, w, h) => {
  g.fillStyle = L(g, 0, 0, w, h, [[0, '#2A1B3D'], [1, '#14102A']]); g.fillRect(0, 0, w, h);
  g.fillStyle = 'rgba(255,255,255,0.04)'; circle(g, w * 0.5, h * 0.5, w * 0.45); g.fill();
  // bütün nar
  const nx = w * 0.32, ny = h * 0.48, r = w * 0.2;
  g.fillStyle = R(g, nx - r * 0.3, ny - r * 0.3, 0, r * 1.2, [[0, '#FF5B5B'], [0.6, '#C2162B'], [1, '#6E0A18']]); circle(g, nx, ny, r); g.fill();
  g.fillStyle = '#8A1022'; g.beginPath(); g.moveTo(nx - r * 0.18, ny - r * 0.92); for (let i = 0; i < 6; i++) { const t = -Math.PI / 2 + (i - 2.5) * 0.25; g.lineTo(nx + Math.cos(t) * r * 0.5, ny - r * 1.15 + (i % 2) * r * 0.12); } g.lineTo(nx + r * 0.18, ny - r * 0.92); g.fill();
  g.fillStyle = 'rgba(255,255,255,0.35)'; g.beginPath(); g.ellipse(nx - r * 0.45, ny - r * 0.35, r * 0.15, r * 0.28, -0.6, 0, 7); g.fill();
  // yarım nar
  const hx = w * 0.66, hy = h * 0.62, hr = w * 0.22;
  g.fillStyle = '#8A1022'; circle(g, hx, hy, hr); g.fill();
  g.fillStyle = '#F4D7C2'; circle(g, hx, hy, hr * 0.9); g.fill();
  const rnd = seeded(3);
  for (let i = 0; i < 220; i++) { const t = rnd() * Math.PI * 2, d = Math.sqrt(rnd()) * hr * 0.82; const x = hx + Math.cos(t) * d, y = hy + Math.sin(t) * d; if (Math.abs(Math.cos(t * 3)) < 0.12 && d > hr * 0.2) continue;
    g.fillStyle = R(g, x - 1.5, y - 1.5, 0, 5, [[0, '#FFB3B3'], [0.4, '#E5162F'], [1, '#8E0A1C']]); g.beginPath(); g.ellipse(x, y, 3.4, 4.2, t, 0, 7); g.fill(); }
  g.fillStyle = '#3B8E3B'; g.save(); g.translate(nx + r * 0.75, ny - r * 1.0); g.rotate(-0.6); g.beginPath(); g.ellipse(0, 0, r * 0.35, r * 0.12, 0, 0, 7); g.fill(); g.restore();
});

// ---------- Deniz altı ----------
const denizalti = box((g, w, h, a) => {
  g.fillStyle = L(g, 0, 0, 0, h, [[0, '#3FD0F0'], [0.5, '#1E7FC8'], [1, '#0B2A6B']]); g.fillRect(0, 0, w, h);
  g.globalAlpha = 0.18; g.fillStyle = '#FFFFFF'; for (let i = 0; i < 5; i++) { const x = w * (0.1 + i * 0.2) + Math.sin(a * 6 + i) * 6; g.beginPath(); g.moveTo(x, 0); g.lineTo(x + w * 0.08, 0); g.lineTo(x + w * 0.2, h); g.lineTo(x + w * 0.12, h); g.fill(); } g.globalAlpha = 1;
  g.fillStyle = '#E9D29A'; g.beginPath(); g.moveTo(0, h); for (let x = 0; x <= w; x += 6) g.lineTo(x, h * 0.86 + Math.sin(x / w * 7) * h * 0.02); g.lineTo(w, h); g.fill();
  const coral = (x, c) => { g.strokeStyle = c; g.lineCap = 'round'; const br = (x0, y0, ang, len, d) => { if (d > 4) return; const x1 = x0 + Math.cos(ang) * len, y1 = y0 + Math.sin(ang) * len; g.lineWidth = 7 - d * 1.3; g.beginPath(); g.moveTo(x0, y0); g.lineTo(x1, y1); g.stroke(); br(x1, y1, ang - 0.45, len * 0.75, d + 1); br(x1, y1, ang + 0.4, len * 0.7, d + 1); }; br(x, h * 0.9, -Math.PI / 2, h * 0.1, 0); };
  coral(w * 0.15, '#FF6F91'); coral(w * 0.85, '#F2C230'); coral(w * 0.7, '#8F7CF0');
  const fish = (x, y, s, c1, c2, dir) => { g.save(); g.translate(x, y); g.scale(s * dir, s);
    g.fillStyle = c2; g.beginPath(); g.moveTo(-14, 0); g.lineTo(-26, -9); g.lineTo(-24, 0); g.lineTo(-26, 9); g.fill();
    g.fillStyle = L(g, 0, -10, 0, 10, [[0, c1], [1, c2]]); g.beginPath(); g.ellipse(0, 0, 18, 11, 0, 0, 7); g.fill();
    g.fillStyle = '#FFFFFF'; g.fillRect(-4, -10, 4, 20); g.fillRect(6, -8, 3, 16);
    g.fillStyle = '#FFFFFF'; circle(g, 10, -3, 3.2); g.fill(); g.fillStyle = '#0B1430'; circle(g, 10.8, -3, 1.6); g.fill(); g.restore(); };
  fish(w * (0.3 + a * 0.15), h * 0.35, 1.3, '#FF9F1C', '#E8590C', 1); fish(w * (0.75 - a * 0.1), h * 0.55, 1, '#3FD0F0', '#2F7BF6', -1); fish(w * 0.5, h * 0.7, 0.8, '#F2C230', '#E8590C', 1);
  g.strokeStyle = 'rgba(255,255,255,0.7)'; g.lineWidth = 1.2; for (let i = 0; i < 9; i++) { const y = (h * (0.8 - i * 0.09) - a * h * 0.3 + h) % h; circle(g, w * 0.2 + Math.sin(i * 2.1) * 10, y, 2 + (i % 3)); g.stroke(); }
});

// ---------- Uzay: halkalı gezegen ----------
const uzay = box((g, w, h, a) => {
  g.fillStyle = L(g, 0, 0, w, h, [[0, '#0B0F2E'], [1, '#1B0B3A']]); g.fillRect(0, 0, w, h);
  g.fillStyle = R(g, w * 0.2, h * 0.8, 0, w * 0.6, [[0, 'rgba(143,124,240,0.35)'], [1, 'rgba(143,124,240,0)']]); g.fillRect(0, 0, w, h);
  const rnd = seeded(11); for (let i = 0; i < 90; i++) { const x = rnd() * w, y = rnd() * h, s = rnd() * 1.4 + 0.3; g.fillStyle = `rgba(255,255,255,${0.4 + 0.6 * Math.abs(Math.sin(i + a * 6))})`; circle(g, x, y, s); g.fill(); }
  const px = w * 0.52, py = h * 0.52, pr = w * 0.22;
  g.save(); g.translate(px, py); g.rotate(-0.35);
  g.strokeStyle = 'rgba(242,194,48,0.85)'; g.lineWidth = w * 0.025; g.beginPath(); g.ellipse(0, 0, pr * 1.75, pr * 0.42, 0, Math.PI, Math.PI * 2); g.stroke();
  g.restore();
  g.fillStyle = R(g, px - pr * 0.4, py - pr * 0.4, 0, pr * 1.4, [[0, '#FFD08A'], [0.5, '#E58A3C'], [1, '#7A2E12']]); circle(g, px, py, pr); g.fill();
  g.save(); circle(g, px, py, pr); g.clip(); g.fillStyle = 'rgba(122,46,18,0.35)'; for (let i = -3; i < 4; i++) g.fillRect(px - pr, py + i * pr * 0.25, pr * 2, pr * 0.08); g.restore();
  g.save(); g.translate(px, py); g.rotate(-0.35); g.strokeStyle = 'rgba(255,214,102,0.95)'; g.lineWidth = w * 0.025; g.beginPath(); g.ellipse(0, 0, pr * 1.75, pr * 0.42, 0, 0, Math.PI); g.stroke(); g.restore();
  g.fillStyle = R(g, w * 0.82, h * 0.2, 0, w * 0.06, [[0, '#F7F8FA'], [1, '#8FA6D6']]); circle(g, w * 0.82, h * 0.2, w * 0.05); g.fill();
});

// ---------- Gece şehri (neon) ----------
const gece = box((g, w, h, a) => {
  g.fillStyle = L(g, 0, 0, 0, h, [[0, '#0B0F2E'], [0.6, '#2B1B5C'], [1, '#5C1F6E']]); g.fillRect(0, 0, w, h);
  g.fillStyle = '#F7F8FA'; circle(g, w * 0.8, h * 0.18, w * 0.06); g.fill(); g.fillStyle = '#2B1B5C'; circle(g, w * 0.83, h * 0.16, w * 0.055); g.fill();
  const rnd = seeded(5); let x = 0;
  while (x < w) { const bw = w * (0.08 + rnd() * 0.1), bh = h * (0.3 + rnd() * 0.45); g.fillStyle = `hsl(${235 + rnd() * 25},40%,${12 + rnd() * 8}%)`; g.fillRect(x, h - bh, bw - 2, bh);
    for (let yy = h - bh + 6; yy < h - 6; yy += 9) for (let xx = x + 4; xx < x + bw - 6; xx += 7) if (rnd() > 0.45) { g.fillStyle = rnd() > 0.5 ? 'rgba(255,214,102,0.9)' : 'rgba(63,208,240,0.8)'; g.fillRect(xx, yy, 3, 4); }
    x += bw; }
  g.font = `800 ${w * 0.11}px InterX`; g.textAlign = 'center'; g.shadowColor = '#FF3DCB'; g.shadowBlur = 14; g.fillStyle = '#FFB3EE'; g.fillText('GECE', w * 0.5, h * 0.42); g.shadowBlur = 0;
});

// ---------- Karlı dağ ----------
const dag = box((g, w, h) => {
  g.fillStyle = L(g, 0, 0, 0, h, [[0, '#7FB6F5'], [1, '#E8F3FF']]); g.fillRect(0, 0, w, h);
  const mt = (pts, c1, c2) => { g.fillStyle = L(g, 0, h * 0.2, 0, h, [[0, c1], [1, c2]]); g.beginPath(); g.moveTo(0, h); pts.forEach(([x, y]) => g.lineTo(x * w, y * h)); g.lineTo(w, h); g.fill(); };
  mt([[0, 0.6], [0.2, 0.45], [0.35, 0.55], [0.55, 0.38], [0.8, 0.5], [1, 0.42]], '#9DB8E6', '#6E8FC8');
  mt([[0, 0.75], [0.15, 0.62], [0.48, 0.2], [0.62, 0.3], [0.78, 0.48], [1, 0.62]], '#3A5FA8', '#1E3A78');
  g.fillStyle = '#F7F8FA'; g.beginPath(); g.moveTo(w * 0.48, h * 0.2); g.lineTo(w * 0.38, h * 0.36); g.lineTo(w * 0.43, h * 0.34); g.lineTo(w * 0.47, h * 0.39); g.lineTo(w * 0.52, h * 0.33); g.lineTo(w * 0.57, h * 0.37); g.lineTo(w * 0.62, h * 0.3); g.closePath(); g.fill();
  g.fillStyle = '#0D4F47'; for (let i = 0; i < 12; i++) { const x = w * (0.05 + i * 0.085), y = h * (0.82 + (i % 3) * 0.03), s = w * 0.05; g.beginPath(); g.moveTo(x, y - s * 1.6); g.lineTo(x - s * 0.6, y); g.lineTo(x + s * 0.6, y); g.fill(); }
  g.fillStyle = '#E9F2FF'; g.fillRect(0, h * 0.9, w, h * 0.1);
  g.font = `800 ${w * 0.12}px InterX`; g.textAlign = 'center'; g.fillStyle = '#FFFFFF'; g.shadowColor = 'rgba(11,20,48,0.5)'; g.shadowBlur = 6; g.fillText('ZİRVE', w * 0.5, h * 0.14); g.shadowBlur = 0;
});

// ---------- Countryball (uygulamanın paketlerinden) ----------
function cb(flagKey, eyes = 'normal', hat = null, body = 'top') {
  return (g, w, h) => {
    const s = Math.min(w, h); const c = document.createElement('canvas'); c.width = c.height = 512; const x = c.getContext('2d');
    x.drawImage(IMG['body_' + body], 0, 0, 512, 512); x.globalCompositeOperation = 'source-atop';
    const f = IMG['flag_' + flagKey]; if (f) x.drawImage(f, -60, 20, 632, 472);
    x.globalCompositeOperation = 'source-over'; x.drawImage(IMG['line_' + body], 0, 0, 512, 512);
    if (eyes) x.drawImage(IMG['eyes_' + eyes], 0, 0, 512, 512);
    g.drawImage(c, -s / 2, -s / 2, s, s);
    if (hat) g.drawImage(IMG['hat_' + hat], -s * 0.36, -s * 0.86, s * 0.72, s * 0.72);
  };
}
function wcbPose(pose) { return (g, w, h) => { const im = IMG['pose_' + pose]; if (!im) return; const k = Math.min(w / im.width, h / im.height); g.drawImage(im, -im.width * k / 2, -im.height * k / 2, im.width * k, im.height * k); }; }
function word(str, size, fill, o = {}) {
  return (g, w, h) => {
    g.font = `800 ${size}px InterX`; g.textAlign = 'center'; g.textBaseline = 'middle';
    if (o.grad) g.fillStyle = L(g, 0, -size / 2, 0, size / 2, o.grad); else g.fillStyle = fill;
    if (o.stroke) { g.lineWidth = o.stroke[1]; g.strokeStyle = o.stroke[0]; g.lineJoin = 'round'; g.strokeText(str, 0, 0); }
    g.fillText(str, 0, 0);
  };
}
// WM logosu
function logo(g, w, h) { const im = IMG.logo; if (im) { const k = Math.min(w / im.width, h / im.height); g.drawImage(im, -im.width * k / 2, -im.height * k / 2, im.width * k, im.height * k); } }
// Yeşil perde önünde CB (kroma için)
const greenCB = (flagKey) => (g, w, h) => { g.fillStyle = '#22B14C'; g.fillRect(-w / 2, -h / 2, w, h); g.fillStyle = 'rgba(0,0,0,0.06)'; g.fillRect(-w / 2, h * 0.3, w, h * 0.2); cb(flagKey, 'mutlu')(g, w * 0.75, h * 0.75); };

const SUBJECT_IMAGES = {
  body_top: '/public/packs/hazir/govdeler/top-ic.png', line_top: '/public/packs/hazir/govdeler/top-cizgi.png',
  body_kup: '/public/packs/hazir/govdeler/yumusak-kup-ic.png', line_kup: '/public/packs/hazir/govdeler/yumusak-kup-cizgi.png',
  eyes_normal: '/public/packs/hazir/gozler/normal.png', eyes_mutlu: '/public/packs/hazir/gozler/mutlu.png', eyes_kizgin: '/public/packs/hazir/gozler/kizgin.png', eyes_saskin: '/public/packs/hazir/gozler/saskin.png', eyes_uzgun: '/public/packs/hazir/gozler/uzgun.png', eyes_aglayan: '/public/packs/hazir/gozler/aglayan.png', eyes_kapali: '/public/packs/hazir/gozler/kapali.png',
  hat_fes: '/public/packs/hazir/sapkalar/fes.png', hat_tac: '/public/packs/hazir/sapkalar/tac.png', hat_silindir: '/public/packs/hazir/sapkalar/silindir.png', hat_kep: '/public/packs/hazir/sapkalar/kep.png',
  flag_tr: '/public/flags/tr.svg', flag_jp: '/public/flags/jp.svg', flag_br: '/public/flags/br.svg', flag_de: '/public/flags/de.svg', flag_az: '/public/flags/az.svg', flag_kr: '/public/flags/kr.svg', flag_it: '/public/flags/it.svg', flag_gb: '/public/flags/gb.svg', flag_fr: '/public/flags/fr.svg', flag_ua: '/public/flags/ua.svg', flag_se: '/public/flags/se.svg', flag_ca: '/public/flags/ca.svg',
  logo: '/public/logo-mark.png',
};
for (const p of ['mutlu', 'asik', 'heyecanli', 'saskin', 'kizgin', 'guluyor', 'selam-veriyor', 'dusunceli', 'neseli', 'gururlu', 'uykulu', 'sok', 'merakli', 'utangac']) SUBJECT_IMAGES['pose_' + p] = `/public/packs/hazir/wardencb/pozlar-${p}.png`;
window.SUBJ = { kapadokya, istanbul, cay, laleler, aycicek, nar, denizalti, uzay, gece, dag, cb, wcbPose, word, logo, greenCB, SUBJECT_IMAGES };
