// wave
uniform float p_dalgaYuks, p_dalgaBoyu, p_dalgaYonu, p_faz, p_hiz, p_dalgaTipi, p_sabitKena, p_kenarIsle, p_yayilim, p_konumaGore, p_ikinciGuc, p_ikinciBoy, p_ikinciHiz, p_sonum, p_dongu, p_donguSure;
float wv(float k, float a, vec2 q) { if (k < 2.5) return wavef(k, a); if (k < 3.5) return fract(a / TAU) * 2.0 - 1.0; if (k < 4.5) return pnoise(vec2(a / TAU, 3.1)) * 1.4; return sin(a) * 0.7 + sin(a * 2.0) * 0.3; }
void main() {
  vec2 q = toUnit(here()); float a = radians(p_dalgaYonu); vec2 d = vec2(cos(a), sin(a)), n = vec2(-d.y, d.x);
  float f = p_hiz, f2 = p_ikinciHiz; if (p_dongu > 0.5) { float T = max(p_donguSure, 0.1); f = floor(f * T + 0.5) / T; f2 = floor(f2 * T + 0.5) / T; }
  float along = dot(q, d); float ph = TAU * (along / max(p_dalgaBoyu, 1.0) - f * u_t) + p_faz * TAU / 100.0;
  float h = wv(p_dalgaTipi, ph, q) + p_ikinciGuc / 100.0 * sin(TAU * (along / max(p_ikinciBoy, 1.0) - f2 * u_t));
  vec2 b = boxUV(here()); float span = abs(dot(b - 0.5, d)) * 2.0;
  float amp = p_dalgaYuks * pinW(p_sabitKena, b) * mix(1.0, step(span, p_yayilim / 100.0 + 1e-3), 1.0) * exp(-p_sonum / 100.0 * 3.0 * clamp(dot(b, abs(d)), 0.0, 1.0));
  if (p_konumaGore > 0.5) amp *= clamp(dot(b, abs(d)), 0.0, 1.0);
  o = texEdge(fromUnit(q - n * h * amp), p_kenarIsle);
}
