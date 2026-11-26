// motioncomposite
INCLUDE(_hist)
uniform sampler2D s_nesneMati; uniform float p_nesneMatiOn, p_ornek, p_ortusme;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 2.0) { o = s; return; } vec4 acc = vec4(0.0);
  for (int i = 0; i < 16; i++) { if (float(i) >= N) break; vec4 h = hist(float(i), v_uv); acc = overPre(h * mix(0.5, 1.0, float(i) / max(N - 1.0, 1.0)) * mix(1.0, p_ortusme / 100.0 + 0.3, 0.5), acc); } o = overPre(s, acc); }
