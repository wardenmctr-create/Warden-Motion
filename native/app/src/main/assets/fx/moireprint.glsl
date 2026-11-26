// moireprint
uniform float p_tramFrek, p_aciFark, p_kontrast;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) * p_tramFrek; float a = sin(q.x * TAU) * 0.5 + 0.5; vec2 r = rot2(p_aciFark) * q; float b = sin(r.x * TAU * 1.03) * 0.5 + 0.5;
  float m = a * b; vec3 c = unpre(s); vec3 r3 = c * mix(1.0, 0.5 + m, p_kontrast / 100.0); o = pre(clamp(r3, 0.0, 1.0), s.a); }
