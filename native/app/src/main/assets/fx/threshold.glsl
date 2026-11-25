// threshold
uniform float p_level; uniform float p_soft;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  float l = luma(c), th = p_level / 255.0, w = max(0.001, p_soft / 200.0); c = vec3(smoothstep(th - w, th + w, l));
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
