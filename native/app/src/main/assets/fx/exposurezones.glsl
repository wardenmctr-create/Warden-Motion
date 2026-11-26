// exposurezones
uniform float p_altEsik, p_ustEsik, p_gosterim, p_yalnizAnalOniz; uniform vec3 c_isaretRenk;
void main() { vec4 s = texture(u_tex, v_uv); if (p_yalnizAnalOniz > 0.5 && u_export > 0.5) { o = s; return; } vec3 c = unpre(s); float L = luma(c) * 100.0;
  float lo = step(L, p_altEsik), hi = step(p_ustEsik, L); if (lo + hi <= 0.0) { o = s; return; }
  if (p_gosterim < 0.5) { float z = step(0.5, fract((here().x - here().y) / (8.0 * u_s) + u_t)); o = overPre(vec4(hi > 0.5 ? vec3(1.0, 0.4, 0.0) : c_isaretRenk, 1.0) * z * s.a, s); return; }
  if (p_gosterim < 1.5) { vec3 fc = hi > 0.5 ? mix(vec3(1.0, 0.8, 0.0), vec3(1.0, 0.0, 0.0), clamp((L - p_ustEsik) / max(100.0 - p_ustEsik, 1.0), 0.0, 1.0)) : mix(vec3(0.0, 0.0, 0.6), c_isaretRenk, clamp(L / max(p_altEsik, 1.0), 0.0, 1.0)); o = pre(fc, s.a); return; }
  o = pre(vec3(1.0), s.a); }
