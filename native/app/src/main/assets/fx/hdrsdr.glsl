// hdrsdr
uniform float p_girisAkta, p_kaynakTepeParl, p_cikisTepeParl, p_tonEsle, p_renkSiki;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 l = srgb2lin(c) * (p_kaynakTepeParl / max(p_cikisTepeParl, 1.0)) * 0.25;
  vec3 m;
  if (p_tonEsle < 1.5 && p_tonEsle > 0.5) m = l / (1.0 + l);
  else if (p_tonEsle > 1.5) { vec3 x = l * 2.0; m = ((x * (0.15 * x + 0.05) + 0.004) / (x * (0.15 * x + 0.5) + 0.06) - 0.0667) / 0.81; }
  else m = l * (1.0 + l / 16.0) / (1.0 + l);
  float lm = luma(m); m = mix(vec3(lm), m, p_renkSiki / 100.0 * 0.5 + 0.5);
  o = pre(clamp(lin2srgb(m) * 1.08, 0.0, 1.0), s.a);
}
