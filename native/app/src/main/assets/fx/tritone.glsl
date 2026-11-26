// tritone
uniform vec3 c_golgeReng, c_ortaTon, c_acikTon; uniform float p_ortaNokt, p_gecis;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); float m = clamp(p_ortaNokt / 100.0, 0.05, 0.95); float w = max(p_gecis / 100.0, 0.02);
  vec3 a = mix(c_golgeReng, c_ortaTon, smoothstep(0.0, m * (1.0 + w) , l)); vec3 c = mix(a, c_acikTon, smoothstep(m * (1.0 - w * 0.5), 1.0, l));
  o = pre(c, s.a);
}
