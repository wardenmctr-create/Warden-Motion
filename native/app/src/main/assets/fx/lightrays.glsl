// lightrays
uniform vec2 p_center; uniform float p_len; uniform float p_amount; uniform float p_thr;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 cpx = fromUnit(p_center); vec2 uv = v_uv; vec2 d = (uv - cpx / u_res) * (p_len / 100.0) / 48.0;
  vec3 acc = vec3(0.0); float w = 1.0; vec2 q = uv;
  for (int i = 0; i < 48; i++) { q -= d; vec4 t = tex(q); vec3 c = unpre(t) * t.a; float l = luma(c); acc += c * smoothstep(p_thr / 100.0, 1.0, l) * w; w *= 0.96; }
  acc *= p_amount / 100.0 / 14.0; vec4 rays = vec4(acc, max(acc.r, max(acc.g, acc.b)));
  o = s + rays * (1.0 - s.a * 0.5);
}
