// colorama
GRADIENT(palet)
uniform float p_giris, p_faz, p_donguSayi, p_hiz, p_renkleriAraDege;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float v = p_giris < 0.5 ? luma(c) : p_giris < 1.5 ? rgb2hsv(c).x : p_giris < 2.5 ? c.r : p_giris < 3.5 ? c.g : c.b;
  float x = fract(v * p_donguSayi + p_faz / 100.0 + u_t * p_hiz);
  if (p_renkleriAraDege < 0.5) x = floor(x * float(paln_palet())) / float(paln_palet());
  o = pre(grad_palet(x), s.a);
}
