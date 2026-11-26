// dissolve
uniform float p_ilerleme, p_pikselBoyu, p_tohum, p_yumusatm, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); float n = hash1(floor(toUnit(here()) / max(p_pikselBoyu, 0.3)) + seedf(p_tohum)); float w = p_yumusatm / 100.0 * 0.5 + 1e-4;
  float k = smoothstep(p_ilerleme / 100.0 - w, p_ilerleme / 100.0 + w, n * (1.0 + 2.0 * w) - w); if (p_ters > 0.5) k = 1.0 - k; o = s * k; }
