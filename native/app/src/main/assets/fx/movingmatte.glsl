// movingmatte
INCLUDE(_hist)
uniform float p_gecmis, p_hareketEsig, p_golgeBast;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 3.0) { o = s; return; } vec3 bg = vec3(0.0); float ws = 0.0;
  for (int i = 1; i < 16; i++) { if (float(i) >= N) break; vec4 h = hist(float(i), v_uv); bg += unpre(h); ws += 1.0; } bg /= max(ws, 1.0); vec3 c = unpre(s); float d = length(c - bg);
  float sh = (luma(c) < luma(bg) && length((c / max(luma(c), 0.02)) - (bg / max(luma(bg), 0.02))) < 0.3) ? p_golgeBast / 100.0 : 0.0; float m = smoothstep(p_hareketEsig / 100.0 * 0.5, p_hareketEsig / 100.0 + 0.05, d) * (1.0 - sh);
  o = pre(c, s.a * m); }
