// scatterplot
INCLUDE(_chart)
uniform float p_eksen, p_noktaBoyu;
void main() { vec2 b = boxUV(here()); vec2 q = vec2(b.x, 1.0 - b.y); float R = dR(); vec2 mn = vec2(1e9), mx = vec2(-1e9);
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; vec2 p = vec2(dat(float(r), 0.0), dat(float(r), 1.0)); if (p_eksen > 0.5) p = log(max(p, vec2(1e-3))); mn = min(mn, p); mx = max(mx, p); }
  vec4 col = vec4(0.04, 0.06, 0.12, 0.85); float ax = 1.0 - smoothstep(0.0, 0.004, min(q.x - 0.06, q.y - 0.06)) * 1.0; col = overPre(vec4(0.6, 0.6, 0.6, 1.0) * step(min(abs(q.x - 0.06), abs(q.y - 0.06)), 0.004), col);
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; vec2 p = vec2(dat(float(r), 0.0), dat(float(r), 1.0)); if (p_eksen > 0.5) p = log(max(p, vec2(1e-3))); vec2 u = 0.08 + (p - mn) / max(mx - mn, vec2(1e-6)) * 0.86;
    float sz = p_noktaBoyu * (dC() >= 3.0 ? 0.5 + dat(float(r), 2.0) / max(dMax(), 1e-6) : 1.0); float d = length((q - u) * boxU()); col = overPre(vec4(serCol(float(r) * 0.3, vec3(0.2, 0.5, 1.0)), 1.0) * (1.0 - smoothstep(sz * 0.5, sz * 0.5 + 1.0, d)), col); }
  o = col; }
