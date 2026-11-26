// vibrance
uniform float p_doygunlu, p_canlilik, p_acikligiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l0 = luma(c);
  c = satAdj(c, 1.0 + p_doygunlu / 100.0);
  float sat = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b));
  c = satAdj(c, 1.0 + p_canlilik / 100.0 * (1.0 - sat) * 1.5);
  if (p_acikligiKoru > 0.5) c += l0 - luma(c);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
