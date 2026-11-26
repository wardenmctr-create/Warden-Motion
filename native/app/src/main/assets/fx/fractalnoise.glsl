// fractalnoise
uniform float p_fraktalTuru, p_olcek, p_kontrast, p_parlakli, p_karmasik, p_evrim, p_tohum, p_ters; uniform vec2 p_kayma;
void main() { vec2 p = (toUnit(here()) + p_kayma) / max(p_olcek, 1.0) + seedf(p_tohum); vec2 ev = vec2(cos(radians(p_evrim)), sin(radians(p_evrim))) * 0.8;
  float s = 0.0, a = 0.5, n = 0.0; vec2 q = p;
  for (int i = 0; i < 10; i++) { if (float(i) >= p_karmasik) break; float v = pnoise(q + ev * float(i + 1)); v = p_fraktalTuru < 0.5 ? v * 0.5 + 0.5 : p_fraktalTuru < 1.5 ? abs(v) : pow(1.0 - abs(v), 3.0); s += v * a; n += a; q = q * 2.03 + 7.7; a *= 0.5; }
  float v = s / n; v = (v - 0.5) * p_kontrast / 100.0 + 0.5 + p_parlakli / 100.0; v = clamp(v, 0.0, 1.0); if (p_ters > 0.5) v = 1.0 - v;
  o = genOver(vec4(vec3(v), 1.0)); }
