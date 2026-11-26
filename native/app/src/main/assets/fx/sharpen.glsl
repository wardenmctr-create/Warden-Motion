// sharpen
uniform float p_keskinli, p_yaricap, p_gurultuEsig, p_alfayiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); float r = max(p_yaricap * u_s, 0.7); vec4 b = vec4(0.0);
  for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; b += texPx(here() + vec2(cos(a), sin(a)) * r); } b /= 8.0;
  vec4 d = s - b; float m = step(p_gurultuEsig / 100.0 * 0.2, length(d.rgb));
  vec4 c = s + d * p_keskinli / 100.0 * 3.0 * m; if (p_alfayiKoru > 0.5) c.a = s.a;
  c.rgb = clamp(c.rgb, 0.0, c.a); o = c;
}
