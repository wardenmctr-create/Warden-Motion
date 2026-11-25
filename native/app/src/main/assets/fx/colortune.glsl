// colortune
uniform float p_r; uniform float p_g; uniform float p_b; uniform float p_lit;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  c += vec3(p_r, p_g, p_b) / 250.0; c *= 1.0 + p_lit / 100.0;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
