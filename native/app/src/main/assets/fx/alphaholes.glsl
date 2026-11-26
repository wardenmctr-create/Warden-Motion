// alphaholes
uniform float p_enKucuDeli, p_disBoslDisl; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a > 0.5) { o = vec4(0.0); return; } float R = max(boxU().x, boxU().y) * u_s; int hits = 0; float near = 1e9;
  for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; vec2 d = vec2(cos(a), sin(a)); for (int k = 1; k <= 48; k++) { float t = R * float(k) / 48.0; if (texPx(here() + d * t).a > 0.5) { hits++; near = min(near, t); break; } } }
  bool hole = hits == 12 || p_disBoslDisl < 0.5; float sz = near / u_s; o = hole && sz * 2.0 >= sqrt(p_enKucuDeli) * 0.5 ? vec4(c_renk, 1.0) : vec4(0.0); }
