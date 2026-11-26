// maskblur
uniform sampler2D s_maskeKatm; uniform float p_maskeKatmOn; uniform float p_yaricap, p_maskeGeci, p_maskeKana, p_tersMask, p_kenarUzat;
void main() {
  vec2 b = clamp(boxUV(here()), 0.0, 1.0); float m;
  if (p_maskeKatmOn > 0.5) { vec4 mm = texture(s_maskeKatm, b); m = p_maskeKana < 0.5 ? mm.a : luma(unpre(mm)); } else m = 1.0 - smoothstep(0.22, 0.22 + p_maskeGeci / max(boxU().x, 1.0), length(b - 0.5));
  if (p_tersMask > 0.5) m = 1.0 - m;
  float R = p_yaricap * u_s * 0.5 * m; vec4 acc = vec4(0.0); float ws = 0.0;
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec2 f = vec2(float(i), float(j)) / 4.0; float w = exp(-dot(f, f) * 2.0); acc += texEdge(here() + f * R * 1.5, p_kenarUzat > 0.5 ? 3.0 : 0.0) * w; ws += w; }
  o = acc / ws;
}
