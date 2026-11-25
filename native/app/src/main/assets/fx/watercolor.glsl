// watercolor
uniform float p_amount; uniform float p_size;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 px = v_uv * u_res; float sz = p_size * u_s; vec2 w = vec2(fbm(px / (sz * 6.0), 3.0), fbm(px / (sz * 6.0) + 9.0, 3.0)) * sz;
  vec4 acc = vec4(0.0); for (int i = 0; i < 9; i++) { vec2 o2 = vec2(float(i % 3) - 1.0, float(i / 3) - 1.0) * sz * 0.8; acc += tex((px + w + o2) / u_res); } acc /= 9.0;
  vec3 c = unpre(acc); c = mix(c, vec3(1.0), 0.15); float edge = smoothstep(0.0, 0.6, abs(fbm(px / (sz * 3.0), 2.0))) * 0.15;
  float paper = 0.94 + vnoise(px / 2.0) * 0.06; c = c * paper - edge * 0.3;
  o = pre(mix(unpre(s), clamp(c, 0.0, 1.0), p_amount / 100.0), s.a);
}
