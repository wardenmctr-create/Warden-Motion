// apollonian
uniform float p_derinlik, p_enKucuCap; uniform vec3 c_palet;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) / (min(boxU().x, boxU().y) * 0.48); float scale = 1.0; float best = 1e9; int D = int(clamp(p_derinlik, 1.0, 10.0)); float lvl = 0.0;
  vec2 p = q; for (int i = 0; i < 10; i++) { if (i >= D) break; p = -1.0 + 2.0 * fract(0.5 * p + 0.5); float r2 = dot(p, p); float k = 1.2 / max(r2, 1e-4); p *= k; scale *= k; lvl += 1.0; }
  float d = 0.25 * abs(p.y) / scale; float line = 1.0 - smoothstep(0.0, 0.004 * max(p_enKucuCap / 3.0, 0.3), d); float inside = step(length(q), 1.0);
  vec3 c = mix(c_palet, vec3(1.0), line) * (0.7 + 0.3 * fract(log(scale) * 0.3)); o = pre(c, s.a * inside); }
