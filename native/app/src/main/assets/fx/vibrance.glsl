// vibrance
uniform float p_sat; uniform float p_vib;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  float l = luma(c); float mx = max(c.r, max(c.g, c.b)), mn = min(c.r, min(c.g, c.b)); float sat0 = mx - mn;
  float v = p_vib / 100.0 * (1.0 - sat0); c = mix(vec3(l), c, 1.0 + p_sat / 100.0 + v);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
