// stainedglass
uniform float p_parcaSayi, p_kursunCizg, p_camGeci; uniform vec3 c_birlestiCizgReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = sqrt(boxU().x * boxU().y / max(p_parcaSayi, 4.0)); vec4 v = voronoi(q / cs); vec2 ctr = q - (vec2(0.0)); 
  vec2 g = floor(q / cs); vec2 best = vec2(0.0); float bd = 1e9; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = g + vec2(i, j); vec2 p = (id + hash2(id)) * cs; float d = length(q - p); if (d < bd) { bd = d; best = p; } }
  vec3 c = unpre(texU(best)); c = satAdj(c, 1.4) * (0.85 + 0.3 * p_camGeci / 100.0 * (1.0 - bd / cs)); float lead = 1.0 - smoothstep(p_kursunCizg / cs * 0.04, p_kursunCizg / cs * 0.04 + 0.02, v.y - v.x);
  o = pre(mix(clamp(c, 0.0, 1.0), c_birlestiCizgReng, lead), s.a); }
