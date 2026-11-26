// autolevels
uniform float p_siyahKirp, p_beyazKirp, p_zamanYumu, p_kanallarAyriIsle, p_guc;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 mn, mx, av; stats(mn, mx, av); vec3 c = unpre(s);
  if (p_kanallarAyriIsle < 0.5) { mn = vec3(min(mn.r, min(mn.g, mn.b))); mx = vec3(max(mx.r, max(mx.g, mx.b))); }
  mn += p_siyahKirp / 100.0; mx -= p_beyazKirp / 100.0;
  vec3 r = clamp((c - mn) / max(mx - mn, vec3(0.05)), 0.0, 1.0);
  o = pre(mix(c, r, p_guc / 100.0), s.a);
}
