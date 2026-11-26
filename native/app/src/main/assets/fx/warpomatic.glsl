// warpomatic
uniform float p_ilerleme, p_bukmeGucu, p_gurultuOlce, p_evrim, p_yumusatm, p_tohum, p_ters;
void main() { vec2 q = toUnit(here()); float pr = p_ilerleme / 100.0; if (p_ters > 0.5) pr = 1.0 - pr; vec2 p = q / max(p_gurultuOlce, 1.0) + seedf(p_tohum) + radians(p_evrim) * 0.3;
  vec2 d = vec2(fbm(p, 3.0), fbm(p + 5.0, 3.0)); vec4 c = texU(q + d * p_bukmeGucu * pr); float n = fbm(p * 2.0, 3.0) * 0.5 + 0.5; float w = p_yumusatm / 100.0 * 0.5 + 0.01;
  o = c * (1.0 - smoothstep(n - w, n + w, pr)); }
