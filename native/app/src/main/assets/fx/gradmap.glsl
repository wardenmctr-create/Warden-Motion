// gradmap
GRADIENT(renkGeci)
uniform float p_gecisKayd, p_tersCevi, p_duzlesti;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); if (p_tersCevi > 0.5) l = 1.0 - l; l = clamp(l + p_gecisKayd / 100.0, 0.0, 1.0);
  if (p_duzlesti > 0.5) l = floor(l * 6.0 + 0.5) / 6.0;
  o = pre(grad_renkGeci(l), s.a);
}
