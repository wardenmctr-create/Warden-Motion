// radrepeat
uniform float p_kopyaSayi, p_yaricap, p_baslangiAcis, p_yay, p_kopyaOlce, p_radyalDond, p_orijinalGost; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec4 res = p_orijinalGost > 0.5 ? texU(q) : vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 64.0)); float sc = max(p_kopyaOlce / 100.0, 0.01);
  float full = abs(abs(p_yay) - 360.0) < 0.5 ? 1.0 : 0.0;
  for (int i = 0; i < 64; i++) { if (i >= N) break; float a = p_baslangiAcis + p_yay * float(i) / max(float(N) - full, 1.0) ; vec2 c = p_merkez + vec2(cos(radians(a)), sin(radians(a))) * p_yaricap;
    vec2 l = (q - c); if (p_radyalDond > 0.5) l = rot2(-(a + 90.0)) * l; l /= sc; res = overPre(texU(l), res); }
  o = res;
}
