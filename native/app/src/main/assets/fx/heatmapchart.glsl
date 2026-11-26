// heatmapchart
INCLUDE(_chart)
uniform float p_hucreAral; uniform vec3 c_renkAral;
void main() { vec2 b = boxUV(here()); float R = dR(), C = dC(); vec2 g = vec2(b.x * C, b.y * R); vec2 id = floor(g), f = fract(g); vec2 gap = p_hucreAral / (boxU() / vec2(C, R)) * 0.5;
  if (any(lessThan(f, gap)) || any(greaterThan(f, 1.0 - gap))) { o = vec4(0.0); return; } float v = dat(id.y, id.x) / dMax(); vec3 c = mix(vec3(0.95, 0.97, 1.0), c_renkAral, clamp(v, 0.0, 1.0));
  float n = numAt((f - 0.5) * boxU() / vec2(C, R) / 7.0, dat(id.y, id.x)); o = vec4(mix(c, v > 0.5 ? vec3(1.0) : vec3(0.1), n), 1.0); }
