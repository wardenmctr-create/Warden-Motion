// ringcross
uniform float p_halka, p_aci, p_gecikme, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 q = toUnit(here()); float R = length(boxU()) * 0.5; float N = max(floor(p_halka), 1.0); float id = floor(length(q) / R * N); float k = clamp((p - id / N * p_gecikme * N * 0.5) / max(1.0 - p_gecikme * N * 0.5, 0.1), 0.0, 1.0);
  vec2 sq = rot2(p_aci * k * (mod(id, 2.0) > 0.5 ? -1.0 : 1.0)) * q; o = texU(sq) * (1.0 - smoothstep(0.7, 1.0, k)); }
