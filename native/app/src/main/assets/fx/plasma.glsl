// plasma
GRADIENT(palet)
uniform float p_olcek, p_hiz, p_faz, p_ayrinti, p_kontrast, p_tohum;
void main() {
  vec2 p = toUnit(here()) / max(p_olcek, 1.0) + seedf(p_tohum); float t = u_t * p_hiz * 2.0 + p_faz / 100.0 * TAU;
  float v = sin(p.x * 3.0 + t) + sin((p.y * 3.0 + t) * 0.8) + sin((p.x + p.y) * 2.5 + t * 1.3) + sin(length(p - vec2(sin(t * 0.3), cos(t * 0.4))) * 4.0) + fbm(p + t * 0.1, p_ayrinti - 1.0) * 2.0;
  float x = fract(v * 0.15 + 0.5); x = clamp((x - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5, 0.0, 1.0);
  o = genOver(vec4(grad_palet(x), 1.0));
}
