// polardisp
uniform sampler2D s_haritaKatm; uniform float p_haritaKatmOn;
uniform vec2 p_merkez; uniform float p_radyalMikt, p_acisalMikt, p_haritaKana, p_tersCevi, p_kenarModu;
void main() {
  vec2 q = toUnit(here()); vec4 m = p_haritaKatmOn > 0.5 ? texture(s_haritaKatm, clamp(boxUV(here()), 0.0, 1.0)) : texU(q);
  float v = p_haritaKana < 0.5 ? luma(unpre(m)) : p_haritaKana < 1.5 ? m.a : unpre(m).r; if (p_tersCevi > 0.5) v = 1.0 - v;
  if (p_haritaKatmOn < 0.5 && m.a < 0.01) { o = m; return; }
  vec2 r = q - p_merkez; float k = (v - 0.5) * 2.0;
  vec2 s = p_merkez + rot2(-p_acisalMikt * k) * r / max(0.05, 1.0 + p_radyalMikt / 100.0 * k * 0.5);
  o = texEdge(fromUnit(s), p_kenarModu < 0.5 ? 2.0 : p_kenarModu < 1.5 ? 0.0 : 1.0);
}
