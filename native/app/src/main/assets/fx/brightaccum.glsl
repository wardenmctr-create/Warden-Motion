// brightaccum
INCLUDE(_hist)
uniform float p_kareSayi, p_azalma, p_renkleriBirlAl;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); vec4 best = s; float bl = luma(s.rgb);
  for (int i = 1; i < 16; i++) { if (float(i) >= N) break; vec4 h = hist(float(i), v_uv) * pow(1.0 - p_azalma / 100.0, float(i)); if (p_renkleriBirlAl > 0.5) best = max(best, h); else if (luma(h.rgb) > bl) { best = h; bl = luma(h.rgb); } }
  o = best; }
