// radialshadow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_opaklik, p_yalnizGolg;
void main() {
  vec4 s = texture(u_src, v_uv); float sh = texture(u_aux, v_uv).a * p_opaklik / 100.0;
  vec4 shc = vec4(c_renk, 1.0) * sh;
  o = p_yalnizGolg > 0.5 ? shc * (1.0 - s.a) : overPre(s, shc);
}
