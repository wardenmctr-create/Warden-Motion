// foamcells
uniform float p_hucre, p_buyume, p_filmCizg;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = sqrt(boxU().x * boxU().y / max(p_hucre, 2.0)) * (0.5 + p_buyume / 200.0); vec4 v = voronoi(q / cs + u_t * 0.05);
  float film = 1.0 - smoothstep(p_filmCizg * 0.02, p_filmCizg * 0.02 + 0.03, v.y - v.x); vec3 irid = hsv2rgb(vec3(fract(v.x * 2.0 + u_t * 0.1), 0.4, 1.0)); vec3 c = mix(vec3(0.9, 0.95, 1.0) * 0.15 + irid * 0.15, vec3(1.0), film);
  o = overPre(vec4(c, 1.0) * (0.3 + film * 0.7), s); }
