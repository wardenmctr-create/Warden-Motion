// temporaldenoise
INCLUDE(_hist)
uniform float p_kareSayi, p_hareketEsig, p_hareketTela;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 2.0) { o = s; return; } vec4 acc = vec4(0.0); float ws = 0.0;
  for (int i = 0; i < 16; i++) { if (float(i) >= N) break; vec4 h = hist(float(i), v_uv); float w = p_hareketTela > 0.5 ? 1.0 - smoothstep(p_hareketEsig / 100.0 * 0.5, p_hareketEsig / 100.0, length(h - s)) : 1.0; acc += h * w; ws += w; }
  o = ws > 0.0 ? acc / ws : s; }
