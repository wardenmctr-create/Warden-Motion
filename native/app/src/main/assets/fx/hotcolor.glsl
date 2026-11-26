// hotcolor
GRADIENT(isiPale)
uniform float p_altEsik, p_ustEsik, p_tersCevi;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); l = clamp((l - p_altEsik / 100.0) / max(0.01, (p_ustEsik - p_altEsik) / 100.0), 0.0, 1.0);
  if (p_tersCevi > 0.5) l = 1.0 - l;
  o = pre(grad_isiPale(l), s.a);
}
