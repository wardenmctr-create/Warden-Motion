// flash
uniform vec3 c_renk; uniform float p_sure, p_tepeGucu, p_gecikme, p_egri, p_tumKare;
void main() { vec4 s = texture(u_tex, v_uv); float x = (u_t - p_gecikme) / max(p_sure, 1e-3); float k = 0.0;
  if (x >= 0.0 && x <= 1.0) { float tri = x < 0.2 ? x / 0.2 : 1.0 - (x - 0.2) / 0.8; k = p_egri < 0.5 ? tri * tri * (3.0 - 2.0 * tri) : tri; }
  k *= p_tepeGucu / 100.0;
  if (p_tumKare > 0.5) { vec2 b = boxUV(here()); float inside = step(0.0, b.x) * step(b.x, 1.0) * step(0.0, b.y) * step(b.y, 1.0); o = mix(s, vec4(c_renk, 1.0), k * inside); }
  else o = vec4(mix(s.rgb, c_renk * s.a, k), s.a); }
