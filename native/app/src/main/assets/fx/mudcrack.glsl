// mudcrack
uniform float p_kuruma, p_catlakKali, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec4 v = voronoi(q / 30.0 + seedf(p_tohum)); vec4 v2 = voronoi(q / 12.0 + seedf(p_tohum) + 3.0); float w = p_catlakKali * 0.01 * p_kuruma / 60.0;
  float crack = (1.0 - smoothstep(w, w + 0.02, v.y - v.x)) + (1.0 - smoothstep(w * 0.5, w * 0.5 + 0.02, v2.y - v2.x)) * step(0.6, p_kuruma / 100.0) * 0.6; vec3 mud = mix(vec3(0.45, 0.33, 0.22), vec3(0.72, 0.6, 0.45), p_kuruma / 100.0) * (0.9 + 0.2 * vnoise(q * 0.3));
  o = pre(mix(mud, vec3(0.15, 0.1, 0.06), clamp(crack, 0.0, 1.0)), s.a); }
