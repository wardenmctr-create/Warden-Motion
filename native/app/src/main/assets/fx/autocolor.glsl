// autocolor
uniform float p_siyahKirp, p_beyazKirp, p_renkKaymDuze, p_zamanYumu, p_notrTonlKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 mn, mx, av; stats(mn, mx, av); vec3 c = unpre(s);
  vec3 g = c * mix(vec3(1.0), vec3(luma(av)) / max(av, vec3(0.05)), p_renkKaymDuze / 100.0);
  float lo = min(mn.r, min(mn.g, mn.b)) + p_siyahKirp / 100.0, hi = max(mx.r, max(mx.g, mx.b)) - p_beyazKirp / 100.0;
  g = clamp((g - lo) / max(hi - lo, 0.05), 0.0, 1.0);
  o = pre(g, s.a);
}
