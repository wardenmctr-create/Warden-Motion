// exposure
uniform float p_pozlama, p_gama, p_siyahNokt, p_acikTonlKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 l = srgb2lin(unpre(s)) * exp2(p_pozlama);
  if (p_acikTonlKoru > 0.5) l = l / (1.0 + max(l - 1.0, 0.0) * 0.5);
  vec3 c = lin2srgb(l); c = max(c - p_siyahNokt / 100.0, 0.0) / max(0.01, 1.0 - p_siyahNokt / 100.0);
  c = pow(clamp(c, 0.0, 1.0), vec3(1.0 / max(p_gama, 0.01)));
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
