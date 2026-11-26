// spotcolor
uniform vec3 c_korunacaRenk; uniform float p_tolerans, p_gecis, p_disDoyg, p_secimiTersCevi;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 h = rgb2hsv(c), k = rgb2hsv(c_korunacaRenk);
  float d = min(abs(h.x - k.x), 1.0 - abs(h.x - k.x)) * 2.0 + (1.0 - smoothstep(0.08, 0.3, h.y)) * 0.6;
  float tol = p_tolerans / 100.0 * 0.5; float m = 1.0 - smoothstep(tol, tol + p_gecis / 100.0 * 0.3 + 0.001, d);
  if (p_secimiTersCevi > 0.5) m = 1.0 - m;
  o = pre(mix(satAdj(c, p_disDoyg / 100.0), c, m), s.a);
}
