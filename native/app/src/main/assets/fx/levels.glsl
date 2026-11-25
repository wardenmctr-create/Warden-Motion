// levels
uniform float p_lo; uniform float p_hi; uniform float p_mid;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  c = clamp((c - p_lo / 255.0) / max(0.004, (p_hi - p_lo) / 255.0), 0.0, 1.0); c = pow(c, vec3(1.0 / max(0.01, p_mid)));
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
