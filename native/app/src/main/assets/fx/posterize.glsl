// posterize
uniform float p_tonSevi, p_kanal, p_titresimDagi, p_gurultu;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float n = max(2.0, floor(p_tonSevi)) - 1.0;
  float dz = p_titresimDagi > 0.5 ? (hash1(floor(here())) - 0.5) / n : 0.0;
  dz += (hash1(here() + 7.0) - 0.5) * p_gurultu / 100.0 * 0.3;
  if (p_kanal < 0.5) c = floor((c + dz) * n + 0.5) / n;
  else { float l = luma(c); float q = floor((l + dz) * n + 0.5) / n; c *= q / max(l, 1e-3); }
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
