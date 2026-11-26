// animchart
INCLUDE(_chart)
uniform float p_grafikTuru, p_sifirdanBasl, p_degerEtik, p_izgaraCizg, p_yaziBoyu, p_belirmeIler; uniform vec3 c_anaRenk;
void main() { vec2 b = boxUV(here()); vec2 q = vec2(b.x, 1.0 - b.y); float R = dR(); float M = dMax(); float g = p_belirmeIler / 100.0; vec4 col = vec4(0.04, 0.06, 0.12, 0.85); int k = int(p_grafikTuru + 0.5);
  if (p_izgaraCizg > 0.5 && k < 3) for (int i = 1; i <= 4; i++) col = overPre(vec4(0.3, 0.35, 0.45, 1.0) * (1.0 - smoothstep(0.0, 0.003, abs((k == 1 ? q.x : q.y) - 0.1 - float(i) * 0.2))), col);
  if (k == 0 || k == 1) { float ax = k == 0 ? q.x : 1.0 - q.y; float ay = k == 0 ? q.y : q.x; float id = floor(ax * R); float f = fract(ax * R); float v = dat(id, 0.0) / M * 0.85 * clamp(g * R - id, 0.0, 1.0);
    if (f > 0.15 && f < 0.85 && ay > 0.05 && ay < 0.05 + v) col = vec4(serCol(id * 0.15, c_anaRenk), 1.0);
    if (p_degerEtik > 0.5) { vec2 lp = vec2((f - 0.5), ay - 0.08 - v) * boxU() / max(p_yaziBoyu * 0.5, 4.0); if (k == 1) lp = vec2(ay - 0.08 - v, f - 0.5) * boxU().yx / max(p_yaziBoyu * 0.5, 4.0); col = overPre(vec4(1.0) * numAt(lp, dat(id, 0.0)), col); } }
  else if (k == 2) { float best = 1e9; vec2 prev = vec2(0.05, 0.1 + dat(0.0, 0.0) / M * 0.8); for (int r = 1; r < 64; r++) { if (float(r) >= R) break; float x = 0.05 + float(r) / (R - 1.0) * 0.9; if (x > 0.05 + g * 0.9 + 1e-3) break; vec2 p = vec2(x, 0.1 + dat(float(r), 0.0) / M * 0.8);
      vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); best = min(best, length((q - prev - ab * u) * boxU())); prev = p; } col = overPre(vec4(c_anaRenk, 1.0) * (1.0 - smoothstep(2.0, 3.5, best)), col); }
  else { vec2 c = (q - 0.5) * boxU() / min(boxU().x, boxU().y); float r = length(c); float a = fract(atan(c.x, c.y) / TAU + 1.0); float tot = 0.0; for (int i = 0; i < 64; i++) { if (float(i) >= R) break; tot += max(dat(float(i), 0.0), 0.0); }
    float acc = 0.0; for (int i = 0; i < 64; i++) { if (float(i) >= R) break; float v = max(dat(float(i), 0.0), 0.0) / tot; if (a >= acc && a < acc + v && r < 0.42 && a < g) col = vec4(serCol(float(i), c_anaRenk) * (0.9 + 0.1 * step(0.4, r)), 1.0); acc += v; } }
  o = col; }
