// electricedges
uniform vec3 c_elektrikReng; uniform float p_cizgiKali, p_dalgalan, p_ayrinti, p_hiz, p_hale, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here());
  vec2 jit = vec2(fbm(q / 18.0 + vec2(u_t * p_hiz, seedf(p_tohum)), p_ayrinti - 1.0), fbm(q / 18.0 + vec2(7.0, u_t * p_hiz * 1.3), p_ayrinti - 1.0)) * p_dalgalan;
  vec2 p = fromUnit(q + jit); float w = max(p_cizgiKali * u_s, 1.0);
  float ring = clamp(dilateA(p, w * 0.5) - erodeA(p, w * 0.5), 0.0, 1.0);
  float g = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; g += clamp(dilateA(p + vec2(cos(a), sin(a)) * p_hale * u_s * 0.6, w) - erodeA(p + vec2(cos(a), sin(a)) * p_hale * u_s * 0.6, w), 0.0, 1.0); } g /= 8.0;
  vec4 L = vec4(mix(c_elektrikReng, vec3(1.0), ring * 0.6), 1.0) * clamp(ring + g * 0.8, 0.0, 1.0);
  o = vec4(s.rgb + L.rgb * (1.0 - s.a * 0.5), max(s.a, L.a));
}
