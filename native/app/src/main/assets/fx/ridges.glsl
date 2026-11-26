// ridges
GRADIENT(renkGeci)
uniform float p_olcek, p_ayrinti, p_sirtKesk, p_kontrast, p_evrim, p_tohum;
void main() {
  vec2 p = toUnit(here()) / max(p_olcek, 1.0) + seedf(p_tohum) + p_evrim * 0.02; float s = 0.0, a = 0.5, n = 0.0;
  for (int i = 0; i < 10; i++) { if (float(i) >= p_ayrinti) break; float r = 1.0 - abs(pnoise(p)); r = pow(r, mix(1.0, 4.0, p_sirtKesk / 100.0)); s += r * a; n += a; p = p * 2.03 + 11.0; a *= 0.5; }
  float v = clamp((s / n - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5, 0.0, 1.0);
  o = genOver(vec4(grad_renkGeci(v), 1.0));
}
