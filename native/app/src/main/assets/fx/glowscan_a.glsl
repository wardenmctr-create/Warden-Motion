// glowscan_a
uniform float p_altParl, p_ustParl, p_gecis, p_taramaHizi;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = s.a > 0.0 ? s.rgb / s.a : vec3(0.0); float l = luma(c); float sh = fract(u_t * p_taramaHizi * 0.25) * (p_taramaHizi > 0.0 ? 1.0 : 0.0);
  float lo = fract(p_altParl / 100.0 + sh), hi = lo + (p_ustParl - p_altParl) / 100.0; float w = max(p_gecis / 100.0, 0.01);
  float k = smoothstep(lo - w, lo, l) * (1.0 - smoothstep(hi, hi + w, l)); o = vec4(c * k, k) * s.a; }
