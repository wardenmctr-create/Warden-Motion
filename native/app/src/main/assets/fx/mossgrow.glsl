// mossgrow
uniform sampler2D s_yuzeyMask; uniform float p_yuzeyMaskOn, p_koloniYogu, p_buyume; uniform vec3 c_palet;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float m = p_yuzeyMaskOn > 0.5 ? texture(s_yuzeyMask, clamp(boxUV(here()), 0.0, 1.0)).a : s.a; float f = fbm01(q * 0.02, 5.0) + fbm01(q * 0.15, 3.0) * 0.3;
  float cov = smoothstep(1.2 - p_koloniYogu / 100.0 * p_buyume / 100.0 * 0.9, 1.25 - p_koloniYogu / 100.0 * p_buyume / 100.0 * 0.9, f + 0.3); vec3 c = c_palet * (0.7 + 0.6 * vnoise(q * 0.6)); o = overPre(vec4(c, 1.0) * cov * m, s); }
