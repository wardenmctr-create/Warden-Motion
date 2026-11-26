// grayscale
uniform float p_guc, p_tonYont, p_kontrast;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float g = p_tonYont < 0.5 ? luma(c) : p_tonYont < 1.5 ? (c.r + c.g + c.b) / 3.0 : max(c.r, max(c.g, c.b));
  g = (g - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5;
  o = pre(clamp(mix(c, vec3(g), p_guc / 100.0), 0.0, 1.0), s.a);
}
