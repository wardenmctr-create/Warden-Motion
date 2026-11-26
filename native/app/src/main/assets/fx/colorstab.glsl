// colorstab
uniform float p_referansZama, p_zamanPenc, p_parlakliDuze, p_renkDuze, p_sahneDegiAlgi;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 mn, mx, av; stats(mn, mx, av); vec3 c = unpre(s);
  float tl = 0.45; vec3 g = c * mix(1.0, tl / max(luma(av), 0.05), p_parlakliDuze / 100.0);
  g *= mix(vec3(1.0), vec3(luma(av)) / max(av, vec3(0.05)), p_renkDuze / 100.0);
  o = pre(clamp(g, 0.0, 1.0), s.a);
}
