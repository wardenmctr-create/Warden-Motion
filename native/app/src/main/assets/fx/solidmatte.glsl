// solidmatte
uniform vec3 c_matReng; uniform float p_opaklik, p_yalnizSaydAlan, p_mevcutAlfaKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float inBox = step(0.0, b.x) * step(b.x, 1.0) * step(0.0, b.y) * step(b.y, 1.0);
  vec4 m = vec4(c_matReng, 1.0) * p_opaklik / 100.0 * inBox; vec4 r = p_yalnizSaydAlan > 0.5 ? overPre(s, m) : mix(s, m, p_opaklik / 100.0);
  if (p_mevcutAlfaKoru > 0.5) r = pre(unpre(r), s.a); o = r; }
