// temperature
uniform float p_temp; uniform float p_tint;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  float t = p_temp / 100.0, g = p_tint / 100.0;
  c *= vec3(1.0 + 0.22 * t, 1.0 + 0.03 * t - 0.12 * g, 1.0 - 0.28 * t); c.g += 0.06 * -g * 0.5; c.rb += 0.04 * g;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
