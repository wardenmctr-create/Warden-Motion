// smartframe
uniform float p_kenarPayi, p_hedefEnBoy, p_dvN; uniform float p_dv[8];
void main() { vec2 b = boxUV(here()); vec2 tg = p_dvN >= 2.0 ? vec2(p_dv[0], p_dv[1]) : vec2(0.5 + 0.2 * sin(u_t * 0.8), 0.5); float ar = p_hedefEnBoy < 0.5 ? 1.0 : p_hedefEnBoy < 1.5 ? 9.0 / 16.0 : p_hedefEnBoy < 2.5 ? 16.0 / 9.0 : 1.0;
  float boxAr = boxU().x / boxU().y; vec2 win = ar < boxAr ? vec2(ar / boxAr, 1.0) : vec2(1.0, boxAr / ar); win *= 1.0 - p_kenarPayi / 100.0 * 0.5; vec2 c = clamp(tg, win * 0.5, 1.0 - win * 0.5);
  vec2 src = c + (b - 0.5) * win; o = texPx(boxPx(src)); }
