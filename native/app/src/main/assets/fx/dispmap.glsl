// dispmap
uniform sampler2D s_haritaKatm; uniform float p_haritaKatmOn;
uniform float p_yatayKana, p_dikeyKana, p_yatayMikt, p_dikeyMikt, p_haritayiTersCevi, p_kenarModu;
float ch(vec4 c, float k) { vec3 u = unpre(c); return k < 0.5 ? u.r : k < 1.5 ? u.g : k < 2.5 ? u.b : k < 3.5 ? c.a : luma(u); }
void main() {
  vec2 b = boxUV(here());
  vec4 m = p_haritaKatmOn > 0.5 ? texture(s_haritaKatm, clamp(b, 0.0, 1.0)) : texPx(here());
  float kx = p_yatayKana; float ky = p_dikeyKana < 0.5 ? 1.0 : p_dikeyKana < 1.5 ? 0.0 : p_dikeyKana;
  vec2 v = vec2(ch(m, kx), ch(m, ky)); if (p_haritayiTersCevi > 0.5) v = 1.0 - v;
  vec2 B = boxU(); float mm = min(B.x, B.y) * 0.25;
  vec2 d = (v - 0.5) * 2.0 * vec2(p_yatayMikt, p_dikeyMikt) / 100.0 * mm;
  if (p_haritaKatmOn < 0.5 && m.a < 0.01) d = vec2(0.0);
  o = texEdge(fromUnit(toUnit(here()) - d), p_kenarModu < 0.5 ? 0.0 : p_kenarModu < 1.5 ? 1.0 : p_kenarModu < 2.5 ? 2.0 : 3.0);
}
