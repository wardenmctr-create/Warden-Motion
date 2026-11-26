// arithmetic
uniform float p_islem, p_kirmizi, p_yesil, p_mavi, p_alfa, p_tasmayiSini;
void main() { vec4 s = texture(u_tex, v_uv); vec4 c = vec4(unpre(s), s.a); vec4 v = vec4(p_kirmizi, p_yesil, p_mavi, p_alfa) / 100.0; vec4 r;
  if (p_islem < 0.5) r = c + v; else if (p_islem < 1.5) r = c - v; else if (p_islem < 2.5) r = c * (1.0 + v); else if (p_islem < 3.5) r = abs(c - v); else if (p_islem < 4.5) r = min(c, v + 0.5); else r = max(c, v + 0.5);
  if (p_tasmayiSini > 0.5) r = clamp(r, 0.0, 1.0); r.a = clamp(r.a, 0.0, 1.0); o = pre(r.rgb, r.a); }
