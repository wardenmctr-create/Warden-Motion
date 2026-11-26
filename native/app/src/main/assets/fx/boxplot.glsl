// boxplot
INCLUDE(_chart)
uniform float p_biyikKats, p_ucNoktGost, p_kutuGeni;
// Her sütun bir seri: çeyrekler (sıra sayımıyla), medyan, bıyıklar (katsayı × IQR, veriyle sınırlı) ve uç değer noktaları
float qv(int c, float q, int N) { float target = q * float(N - 1); float best = 0.0; float bd = 1e9; for (int r = 0; r < 64; r++) { if (r >= N) break; float v = dat(float(r), float(c)); float below = 0.0, eq = 0.0;
    for (int k = 0; k < 64; k++) { if (k >= N) break; float w = dat(float(k), float(c)); below += step(w, v - 1e-9); eq += step(abs(w - v), 1e-9); } float d = target < below ? below - target : (target > below + eq - 1.0 ? target - (below + eq - 1.0) : 0.0); if (d < bd) { bd = d; best = v; } } return best; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); int C = int(min(dC(), 6.0)); int N = int(min(dR(), 64.0)); float mn = 1e9, mx = -1e9; for (int c = 0; c < 6; c++) { if (c >= C) break; for (int r = 0; r < 64; r++) { if (r >= N) break; float v = dat(float(r), float(c)); mn = min(mn, v); mx = max(mx, v); } }
  float rng = max(mx - mn, 1e-6); int ci = int(floor(b.x * float(C))); if (ci < 0 || ci >= C) { o = s; return; } float cx = (float(ci) + 0.5) / float(C); float hw = p_kutuGeni * u_s / u_box.z * 0.5;
  float q1 = qv(ci, 0.25, N), md = qv(ci, 0.5, N), q3 = qv(ci, 0.75, N); float iqr = q3 - q1; float lo = q1 - p_biyikKats * iqr, hi = q3 + p_biyikKats * iqr; float wl = 1e9, wh = -1e9;
  for (int r = 0; r < 64; r++) { if (r >= N) break; float v = dat(float(r), float(ci)); if (v >= lo) wl = min(wl, v); if (v <= hi) wh = max(wh, v); }
  float px = 1.0 / u_box.z, py = 1.0 / u_box.w; vec4 res = s; vec3 col = serCol(float(ci), vec3(0.25, 0.55, 1.0));
  float y1 = 0.9 - (q1 - mn) / rng * 0.8, y3 = 0.9 - (q3 - mn) / rng * 0.8, ym = 0.9 - (md - mn) / rng * 0.8, yl = 0.9 - (wl - mn) / rng * 0.8, yh = 0.9 - (wh - mn) / rng * 0.8;
  if (abs(b.x - cx) < hw && b.y > y3 && b.y < y1) res = vec4(col * 0.85, 1.0); if (abs(b.x - cx) < hw && abs(b.y - ym) < py * 1.5) res = vec4(1.0);
  if (abs(b.x - cx) < px * 1.2 && ((b.y > yh && b.y < y3) || (b.y > y1 && b.y < yl))) res = vec4(col, 1.0); if (abs(b.x - cx) < hw * 0.5 && (abs(b.y - yl) < py * 1.2 || abs(b.y - yh) < py * 1.2)) res = vec4(col, 1.0);
  if (p_ucNoktGost > 0.5) for (int r = 0; r < 64; r++) { if (r >= N) break; float v = dat(float(r), float(ci)); if (v >= lo && v <= hi) continue; float yy = 0.9 - (v - mn) / rng * 0.8; if (length(vec2((b.x - cx) * u_box.z, (b.y - yy) * u_box.w)) < 3.0 * u_s) res = vec4(1.0, 0.4, 0.3, 1.0); }
  o = res; }
