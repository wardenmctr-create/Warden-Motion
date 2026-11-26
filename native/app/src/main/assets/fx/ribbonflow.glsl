// ribbonflow
uniform float p_serit, p_akis; uniform vec3 c_palet;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float N = max(floor(p_serit), 2.0); float y = b.y + sin(b.x * 6.0 + u_t * p_akis / 30.0) * 0.05 * p_akis / 30.0 + sin(b.x * 2.0 + b.y * 3.0) * 0.08;
  float id = floor(y * N); float f = fract(y * N); vec3 c = hsv2rgb(vec3(fract(rgb2hsv(c_palet).x + id / N * 0.5), 0.6, 0.55 + 0.4 * hash1(vec2(id, 1.0)))); c *= 0.8 + 0.2 * sin(f * PI); o = pre(c, s.a); }
