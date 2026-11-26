// compoundblur
uniform sampler2D s_bulaniklHari; uniform float p_bulaniklHariOn; uniform float p_haritaKana, p_maksimumYari, p_tersHari, p_haritayiOlce, p_kenarUzat;
void main() {
  vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec4 m = p_bulaniklHariOn > 0.5 ? texture(s_bulaniklHari, b) : texture(u_tex, v_uv);
  vec3 mc = unpre(m); float v = p_haritaKana < 0.5 ? luma(mc) : p_haritaKana < 1.5 ? m.a : p_haritaKana < 2.5 ? mc.r : p_haritaKana < 3.5 ? mc.g : mc.b;
  if (p_bulaniklHariOn < 0.5) v = length(b - 0.5) * 1.4; // harita yoksa: kenarlara doğru artar
  if (p_tersHari > 0.5) v = 1.0 - v;
  float R = p_maksimumYari * u_s * 0.5 * v; vec4 acc = vec4(0.0); float ws = 0.0;
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec2 f = vec2(float(i), float(j)) / 4.0; float w = exp(-dot(f, f) * 2.0); acc += texEdge(here() + f * R * 1.5, p_kenarUzat > 0.5 ? 3.0 : 0.0) * w; ws += w; }
  o = acc / ws;
}
