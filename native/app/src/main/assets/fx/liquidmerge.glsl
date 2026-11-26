// liquidmerge
uniform float p_gerilim, p_viskozit, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 q = toUnit(here()); float n = fbm(q * 0.01 + vec2(0.0, u_t * 0.2), 4.0); vec2 w = vec2(fbm(q * 0.008 + 3.0, 3.0), fbm(q * 0.008 + 7.0, 3.0)) * p * (1.0 - p_viskozit / 200.0) * 120.0;
  vec4 c = texU(q + w); float th = p * 1.4 - 0.2; float m = smoothstep(th - (1.0 - p_gerilim / 100.0) * 0.2 - 0.02, th + 0.02, n * 0.5 + 0.5); o = c * m; }
