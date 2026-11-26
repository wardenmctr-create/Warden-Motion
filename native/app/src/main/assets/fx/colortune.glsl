// colortune
uniform float p_kirmizi, p_yesil, p_mavi, p_parlakliKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l0 = luma(c);
  c *= 1.0 + vec3(p_kirmizi, p_yesil, p_mavi) / 100.0;
  if (p_parlakliKoru > 0.5) c *= l0 / max(luma(c), 1e-3);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
