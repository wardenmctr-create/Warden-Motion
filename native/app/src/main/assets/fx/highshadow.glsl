// highshadow
uniform float p_hi; uniform float p_sh;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  float l = luma(c); float ws = 1.0 - smoothstep(0.0, 0.55, l), wh = smoothstep(0.45, 1.0, l);
  c += c * ws * p_sh / 100.0 + (1.0 - c) * ws * max(0.0, p_sh) / 200.0; c += (p_hi / 100.0) * wh * (p_hi > 0.0 ? (1.0 - c) : c);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
