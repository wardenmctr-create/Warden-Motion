// marbling
uniform float p_renkSayi, p_taramaAral, p_akisGucu; uniform vec3 c_boyaPale;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float N = max(floor(p_renkSayi), 2.0); vec2 p = q;
  for (int i = 0; i < 3; i++) { p.x += sin(p.y / max(p_taramaAral, 1.0) * 3.0 + float(i)) * p_akisGucu * 0.3; p.y += sin(p.x / max(p_taramaAral, 1.0) * 2.0 + float(i) * 1.7) * p_akisGucu * 0.2; }
  p += vec2(fbm(q * 0.01, 3.0), fbm(q * 0.01 + 5.0, 3.0)) * p_akisGucu; float band = fract(p.y / (p_taramaAral * 1.5)); float id = floor(band * N);
  vec3 c = hsv2rgb(vec3(fract(rgb2hsv(c_boyaPale).x + id / N * 0.6), 0.65, 0.5 + 0.5 * hash1(vec2(id, 2.0)))); c = mix(c, c_boyaPale, step(0.5, mod(id, 2.0)) * 0.6); o = pre(c, s.a); }
