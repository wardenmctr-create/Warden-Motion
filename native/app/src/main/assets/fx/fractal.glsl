// fractal
uniform float p_bukmeMikt, p_olcek, p_ayrinti, p_evrim, p_akisHizi, p_tohum, p_kenarlarSabi;
void main() {
  vec2 q = toUnit(here()); float sc = max(p_olcek, 1.0); vec2 sd = vec2(seedf(p_tohum), seedf(p_tohum + 7.0));
  float ev = p_evrim * 0.03 + u_t * p_akisHizi;
  vec2 n = q / sc + sd;
  vec2 d = vec2(fbm(n + vec2(ev, 0.0), p_ayrinti - 1.0), fbm(n + vec2(5.2, 1.3) - vec2(0.0, ev), p_ayrinti - 1.0));
  float w = p_kenarlarSabi > 0.5 ? pinW(1.0, boxUV(here())) : 1.0;
  o = texU(q + d * p_bukmeMikt * w);
}
