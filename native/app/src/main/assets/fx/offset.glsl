// offset
uniform float p_yatayKayd, p_dikeyKayd, p_kenarModu, p_birim;
void main() {
  vec2 b = boxUV(here());
  vec2 d = p_birim < 0.5 ? vec2(p_yatayKayd, p_dikeyKayd) * u_s / u_box.zw : vec2(p_yatayKayd, p_dikeyKayd) / 100.0;
  float m = p_kenarModu < 0.5 ? 2.0 : p_kenarModu < 1.5 ? 1.0 : p_kenarModu < 2.5 ? 3.0 : 0.0;
  o = texEdge(boxPx(b - d), m);
}
