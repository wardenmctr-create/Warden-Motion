// threshold
uniform float p_esik, p_yumusakl, p_tersCevi; uniform vec3 c_dusukRenk, c_yuksekRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); float w = max(p_yumusakl / 100.0 * 0.5, 0.002); float k = smoothstep(p_esik / 100.0 - w, p_esik / 100.0 + w, l);
  if (p_tersCevi > 0.5) k = 1.0 - k;
  o = pre(mix(c_dusukRenk, c_yuksekRenk, k), s.a);
}
