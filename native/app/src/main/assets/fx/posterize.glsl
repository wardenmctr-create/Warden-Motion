// posterize
uniform float p_levels;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  float n = max(2.0, floor(p_levels)) - 1.0; c = floor(c * n + 0.5) / n;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
