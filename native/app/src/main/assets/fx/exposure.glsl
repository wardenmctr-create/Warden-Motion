// exposure
uniform float p_exp; uniform float p_gamma; uniform float p_off;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  c = max(c + p_off, 0.0) * exp2(p_exp); c = pow(max(c, 0.0), vec3(1.0 / max(0.01, p_gamma)));
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
