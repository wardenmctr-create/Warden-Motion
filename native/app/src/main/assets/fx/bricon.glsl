// bricon
uniform float p_bri; uniform float p_con;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  c += p_bri / 100.0; float k = p_con >= 0.0 ? 1.0 / max(0.01, 1.0 - p_con / 100.0) : 1.0 + p_con / 100.0; c = (c - 0.5) * k + 0.5;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
