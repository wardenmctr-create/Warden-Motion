// underwater
uniform vec3 c_suTonu; uniform float p_derinlik, p_dalgaYuks, p_dalgaBoyu, p_akisHizi, p_isikDese;
void main() {
  vec2 q = toUnit(here()); float wl = max(p_dalgaBoyu, 1.0);
  vec2 d = vec2(sin(q.y / wl * TAU + u_t * p_akisHizi * TAU), cos(q.x / wl * TAU * 0.8 + u_t * p_akisHizi * TAU * 1.3)) * p_dalgaYuks;
  vec4 s = texU(q + d); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float dp = p_derinlik / 100.0;
  c = mix(c, c_suTonu * (0.4 + luma(c)), dp * 0.75); c *= mix(1.0, 0.65, dp * boxUV(here()).y);
  if (p_isikDese > 0.5) { vec2 p = q / (wl * 0.6) + u_t * p_akisHizi * 0.6; float caust = pow(1.0 - abs(pnoise(p) + pnoise(p * 1.7 + 3.0)) * 0.7, 6.0); c += caust * 0.25 * (1.0 - boxUV(here()).y * 0.7); }
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
