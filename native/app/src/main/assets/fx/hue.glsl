// hue
uniform float p_amount;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  c = hueRotate(c, p_amount);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
