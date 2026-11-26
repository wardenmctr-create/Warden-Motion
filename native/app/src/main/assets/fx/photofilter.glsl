// photofilter
uniform vec3 c_filtreReng; uniform float p_yogunluk, p_parlakliKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 f = c * mix(vec3(1.0), c_filtreReng * 1.4, p_yogunluk / 100.0);
  if (p_parlakliKoru > 0.5) f *= luma(c) / max(luma(f), 1e-3);
  o = pre(clamp(f, 0.0, 1.0), s.a);
}
