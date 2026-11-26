// chipcollage
uniform float p_parcaBoyu, p_bosluk, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float P = max(p_parcaBoyu, 1.0); vec4 v = voronoi(q / P + seedf(p_tohum)); vec2 g = floor(q / P); vec2 best = q; float bd = 1e9;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = g + vec2(i, j); vec2 p = (id + hash2(id + seedf(p_tohum))) * P; float d = length(q - p); if (d < bd) { bd = d; best = p; } }
  vec4 c = texU(best); float gap = smoothstep(p_bosluk / P * 0.1, p_bosluk / P * 0.1 + 0.02, v.y - v.x); vec3 col = (c.a > 0.0 ? c.rgb / c.a : vec3(0.0)) * (0.9 + 0.2 * hash1(floor(best))); o = pre(col, c.a * gap * step(0.3, s.a + c.a)); }
