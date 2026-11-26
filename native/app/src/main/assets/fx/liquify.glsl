// liquify
uniform float p_fircaModu, p_fircaBoyu, p_basinc, p_yogunluk, p_sertlik, p_agiDond;
void main() {
  vec2 q = toUnit(here()); float R = max(p_fircaBoyu, 1.0) * 1.6; float x = length(q) / R;
  float f = x < 1.0 ? pow(1.0 - x * x, mix(2.0, 0.6, p_sertlik / 100.0)) * (p_basinc / 100.0) * mix(0.4, 1.4, p_yogunluk / 100.0) : 0.0;
  vec2 s = q;
  if (p_agiDond > 0.5 || p_fircaModu > 4.5) s = q;
  else if (p_fircaModu < 0.5) s = q - vec2(R * 0.6 * f, 0.0);
  else if (p_fircaModu < 1.5) s = q * (1.0 + f * 0.9);
  else if (p_fircaModu < 2.5) s = rot2(-120.0 * f) * q;
  else if (p_fircaModu < 3.5) s = q * (1.0 - f * 0.6);
  else s = q * (1.0 + f * 0.6);
  o = texU(s);
}
