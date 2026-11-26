// colorbal
uniform float p_tonBolg, p_camgobeg, p_macentay, p_sarimavi, p_parlakliKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c);
  float w = p_tonBolg < 0.5 ? 1.0 - smoothstep(0.0, 0.5, l) : p_tonBolg < 1.5 ? 1.0 - abs(l - 0.5) * 2.0 : smoothstep(0.5, 1.0, l);
  vec3 sh = vec3(p_camgobeg, p_macentay, p_sarimavi) / 100.0 * 0.35 * w; vec3 r = c + sh;
  if (p_parlakliKoru > 0.5) r *= l / max(luma(r), 1e-3);
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
