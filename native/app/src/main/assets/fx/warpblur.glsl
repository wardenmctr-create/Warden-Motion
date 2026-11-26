// warpblur
uniform float p_bukmeMikt, p_gurultuOlce, p_ayrinti, p_evrim, p_bulaniklUzun, p_tohum;
void main() {
  vec2 q = toUnit(here()); vec2 p = q; vec4 acc = vec4(0.0);
  for (int i = 0; i < 16; i++) { vec2 n = p / max(p_gurultuOlce, 1.0) + seedf(p_tohum); float a = fbm(n + p_evrim * 0.05, p_ayrinti - 1.0) * TAU * 1.5;
    vec2 d = vec2(cos(a), sin(a)); acc += texU(p + d * p_bukmeMikt * 0.5); p += d * p_bulaniklUzun / 16.0; }
  o = acc / 16.0;
}
