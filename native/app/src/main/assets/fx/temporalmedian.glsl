// temporalmedian
INCLUDE(_hist)
uniform float p_karePenc, p_hareketEsig;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 3.0) { o = s; return; } vec4 v[16]; int n = int(N);
  for (int i = 0; i < 16; i++) { if (i >= n) break; v[i] = hist(float(i), v_uv); }
  for (int i = 0; i < 16; i++) { if (i >= n) break; for (int j = i + 1; j < 16; j++) { if (j >= n) break; if (luma(v[j].rgb) < luma(v[i].rgb)) { vec4 t = v[i]; v[i] = v[j]; v[j] = t; } } }
  vec4 m = v[n / 2]; float diff = length(m.rgb - s.rgb); o = mix(m, s, smoothstep(p_hareketEsig / 100.0, p_hareketEsig / 100.0 + 0.1, diff)); }
