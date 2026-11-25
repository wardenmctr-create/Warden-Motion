// colorize
uniform vec3 c_col; uniform float p_mix;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  float l = luma(c); vec3 col = l < 0.5 ? mix(vec3(0.0), c_col, l * 2.0) : mix(c_col, vec3(1.0), (l - 0.5) * 2.0); c = mix(c, col, p_mix / 100.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
