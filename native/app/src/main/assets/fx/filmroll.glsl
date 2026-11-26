// filmroll
uniform float p_yon, p_hiz, p_cerceveAral, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 d = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec2 q = toUnit(here()); vec2 B = boxU(); float L = dot(abs(d), B) + p_cerceveAral;
  float off = p * L * (p_hiz / 100.0); vec2 sq = q + d * off; float k = dot(sq, d); float cell = floor((k + dot(abs(d), B) * 0.5) / L); vec2 local = sq - d * cell * L; vec4 c = cell == 0.0 ? texU(local) : vec4(0.0);
  vec2 n = vec2(-d.y, d.x); float side = abs(dot(q, n)) - dot(abs(n), B) * 0.5; float holes = step(0.0, side + 10.0) * step(side, 10.0); vec4 strip = vec4(0.08, 0.07, 0.06, 1.0) * holes * (1.0 - step(0.6, fract(dot(q, d) / 14.0)) * step(abs(side - 0.0), 6.0) * 0.0);
  float gap = abs(fract((k + dot(abs(d), B) * 0.5) / L) * L - dot(abs(d), B) - p_cerceveAral * 0.5) < p_cerceveAral * 0.5 ? 1.0 : 0.0; o = overPre(c, vec4(0.08, 0.07, 0.06, 1.0) * max(gap * 0.0, holes) * step(0.001, p)); }
