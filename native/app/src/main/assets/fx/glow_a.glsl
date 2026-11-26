// glow_a
uniform sampler2D s_ozelMaske; uniform float p_ozelMaskeOn; uniform float p_yayilim, p_kaynakTur, p_esik, p_esikYumu, p_kaynakRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); float k;
  if (p_kaynakTur < 0.5) k = s.a; else if (p_kaynakTur < 2.5) { vec3 c = unpre(s); float v = p_kaynakTur < 1.5 ? luma(c) : max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)) + luma(c) * 0.3;
    float w = max(p_esikYumu / 100.0 * 0.5, 0.01); k = smoothstep(p_esik / 100.0 - w, p_esik / 100.0 + w, v) * s.a; }
  else k = p_ozelMaskeOn > 0.5 ? texture(s_ozelMaske, clamp(boxUV(here()), 0.0, 1.0)).a : s.a;
  k = min(1.0, k * (1.0 + p_yayilim / 100.0 * 3.0));
  o = p_kaynakRenk > 0.5 ? vec4(unpre(s) * k, k) : vec4(k);
}
