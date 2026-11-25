// gradmap
uniform vec3 c_c1; uniform vec3 c_c2; uniform float p_mix;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  c = mix(c, mix(c_c1, c_c2, luma(c)), p_mix / 100.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
