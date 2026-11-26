// gradmap
GRADIENT(renkGeci)
uniform float p_gecisKayd, p_tersCevi, p_duzlesti, p_gecisBicim, p_haritaKayn, p_gecisKontrast, p_parlakKoru, p_alfaKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); if (s.a <= 0.0 && p_alfaKoru > 0.5) { o = s; return; }
  float l = p_haritaKayn < 0.5 ? luma(c0) : p_haritaKayn < 1.5 ? c0.r : p_haritaKayn < 2.5 ? c0.g : p_haritaKayn < 3.5 ? c0.b : s.a;
  l = (l - 0.5) * p_gecisKontrast / 100.0 + 0.5;
  if (p_tersCevi > 0.5) l = 1.0 - l; l = clamp(l + p_gecisKayd / 100.0, 0.0, 1.0);
  if (p_duzlesti > 0.5 || p_gecisBicim > 1.5) { int n = paln_renkGeci(); float m = float(n - 1); l = floor(l * m + 0.5) / max(m, 1.0); }
  else if (p_gecisBicim > 0.5) l = smoothstep(0.0, 1.0, l);
  vec3 g = grad_renkGeci(l); if (p_parlakKoru > 0.5) g *= luma(c0) / max(luma(g), 1e-3);
  o = pre(clamp(g, 0.0, 1.0), p_alfaKoru > 0.5 ? s.a : 1.0);
}
