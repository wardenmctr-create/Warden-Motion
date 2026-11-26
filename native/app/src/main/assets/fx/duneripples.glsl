// duneripples
uniform float p_ruzgarYonu, p_sirtAral, p_yuksekli;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_ruzgarYonu) * toUnit(here()); float x = q.x / max(p_sirtAral, 2.0) + fbm(q * 0.01, 3.0) * 0.8; float saw = fract(x); float h = saw < 0.7 ? saw / 0.7 : (1.0 - saw) / 0.3;
  vec3 c = vec3(0.86, 0.72, 0.5) * (0.75 + 0.35 * mix(h, 1.0 - h, step(0.7, saw)) * p_yuksekli / 10.0); o = pre(clamp(c, 0.0, 1.0), s.a); }
