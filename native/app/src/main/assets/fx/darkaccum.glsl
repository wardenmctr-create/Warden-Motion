// darkaccum
INCLUDE(_hist)
uniform float p_kareSayi, p_azalma, p_alfayiKoru;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); vec4 best = s; float bl = s.a > 0.0 ? luma(s.rgb / s.a) : 2.0;
  for (int i = 1; i < 16; i++) { if (float(i) >= N) break; vec4 h = hist(float(i), v_uv); if (h.a < 0.05) continue; float l = luma(h.rgb / h.a) + p_azalma / 100.0 * float(i) * 0.05; if (l < bl) { bl = l; best = h; } }
  if (p_alfayiKoru > 0.5) best = pre(best.a > 0.0 ? best.rgb / best.a : vec3(0.0), max(s.a, best.a * 0.0 + s.a)); o = best; }
