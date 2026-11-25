// invert
uniform float p_amount;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  c = mix(c, 1.0 - c, clamp(p_amount / 100.0, 0.0, 1.0));
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
