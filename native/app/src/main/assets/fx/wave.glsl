// wave
uniform float p_dalgaYuks, p_dalgaBoyu, p_dalgaYonu, p_faz, p_hiz, p_dalgaTipi, p_sabitKena, p_kenarIsle;
void main() {
  vec2 q = toUnit(here()); float a = radians(p_dalgaYonu);
  vec2 d = vec2(cos(a), sin(a)), n = vec2(-d.y, d.x);
  float ph = TAU * (dot(q, d) / max(p_dalgaBoyu, 1.0) - p_hiz * u_t) + p_faz * TAU / 100.0;
  float off = wavef(p_dalgaTipi, ph) * p_dalgaYuks * pinW(p_sabitKena, boxUV(here()));
  o = texEdge(fromUnit(q - n * off), p_kenarIsle);
}
