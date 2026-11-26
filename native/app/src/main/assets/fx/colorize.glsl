// colorize
uniform vec3 c_renk; uniform float p_doygunlu, p_aciklik, p_golgeyiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c);
  vec3 hs = rgb2hsl(c_renk); vec3 t = hsl2rgb(vec3(hs.x, hs.y * p_doygunlu / 100.0, clamp(l + p_aciklik / 100.0 * 0.5, 0.0, 1.0)));
  if (p_golgeyiKoru < 0.5) t = mix(c_renk, t, 0.35);
  o = pre(clamp(t, 0.0, 1.0), s.a);
}
