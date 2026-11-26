// maskcombine
uniform sampler2D s_ikinciMask; uniform float p_ikinciMaskOn, p_islem, p_tersCevi;
void main() { vec4 s = texture(u_tex, v_uv); float a = s.a; float b = p_ikinciMaskOn > 0.5 ? texture(s_ikinciMask, clamp(boxUV(here()), 0.0, 1.0)).a : 0.0; if (p_tersCevi > 0.5) b = 1.0 - b;
  float m = p_islem < 0.5 ? max(a, b) : p_islem < 1.5 ? min(a, b) : p_islem < 2.5 ? a * (1.0 - b) : abs(a - b); vec3 c = s.a > 0.0 ? s.rgb / s.a : vec3(1.0); o = pre(c, m); }
