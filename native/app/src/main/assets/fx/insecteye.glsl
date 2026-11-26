// insecteye
uniform float p_mercekSayi, p_odak, p_mercekAral;
void main() { vec2 q = toUnit(here()); float cs = max(boxU().x, boxU().y) / max(p_mercekSayi, 1.0); vec4 h = hexGrid(q / cs, 1.0); vec2 local = h.xy * cs; vec2 ctr = q - local; float r = length(h.xy);
  vec2 sq = ctr + local * mix(2.0, 0.3, p_odak / 100.0); vec4 c = texU(sq); float edge = 1.0 - smoothstep(0.5 - p_mercekAral / 200.0 - 0.03, 0.5 - p_mercekAral / 200.0, hexDist(h.xy)); o = c * edge * (1.0 - r * 0.3); }
