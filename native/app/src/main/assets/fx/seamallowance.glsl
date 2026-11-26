// seamallowance
uniform vec3 c_iplik; uniform float p_pay, p_dikisAral, p_sokulme, p_ipUzun;
// İçe ofsetli kesik dikiş çizgisi; sökülme oranı kadar bölgede dikiş yok ve kopuk iplik uçları sarkar
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = s; return; } vec2 p = here(); float P = max(p_pay * u_s, 1.0); float d = innerDist(p, P * 2.0);
  vec2 q = toUnit(p); float ang = atan(q.y, q.x); float along = ang * length(q); float sp = max(p_dikisAral, 1.0); float seg = fract(along / sp);
  float broken = step(fract(ang / 6.28318 + 0.5), p_sokulme / 100.0); float line = 1.0 - smoothstep(0.6 * u_s, 1.4 * u_s, abs(d - P));
  float stitch = line * step(seg, 0.6) * (1.0 - broken); float dang = broken * step(fract(along / (sp * 3.0)), 0.12) * step(P, d) * step(d, P + p_ipUzun * u_s) * (1.0 - smoothstep(0.5 * u_s, 1.2 * u_s, abs(fract(along / (sp * 3.0)) * sp * 3.0 - sp * 0.15)));
  o = overPre(vec4(c_iplik, 1.0) * max(stitch, dang * 0.9), s); }
