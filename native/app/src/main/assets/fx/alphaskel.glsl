// alphaskel
uniform float p_dalBuda, p_cizgiKali; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = s; return; } float R = 80.0 * u_s; float d0 = innerDist(here(), R); float st = max(1.0, d0 * 0.15);
  float mx = 0.0; float cnt = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; float dn = innerDist(here() + vec2(cos(a), sin(a)) * st, R); cnt += step(dn, d0 + 0.01 * u_s); }
  float ridge = step(5.5, cnt) * step(p_dalBuda * u_s * 0.25, d0); float w = max(p_cizgiKali * u_s * 0.5, 0.6);
  float line = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; vec2 p = here() + vec2(cos(a), sin(a)) * w; float dp = innerDist(p, R); float c2 = 0.0; for (int k = 0; k < 8; k++) { float b = float(k) * 0.785; c2 += step(innerDist(p + vec2(cos(b), sin(b)) * max(1.0, dp * 0.15), R), dp + 0.01 * u_s); } line = max(line, step(5.5, c2) * step(p_dalBuda * u_s * 0.25, dp)); }
  o = overPre(vec4(c_renk, 1.0) * max(ridge, line * 0.8), s); }
