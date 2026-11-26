// iridescence
GRADIENT(renkPale)
uniform float p_olcek, p_faz, p_hiz, p_yansimaGucu, p_kontrast;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 p = toUnit(here()) / max(p_olcek, 1.0);
  float n = fbm(p + vec2(u_t * p_hiz, -u_t * p_hiz * 0.7), 3.0); float th = fract(n * 1.5 + luma(unpre(s)) * 0.6 + p_faz / 100.0 + u_t * p_hiz * 0.3);
  vec3 ir = grad_renkPale(th); ir = conAdj(ir, 1.0 + p_kontrast / 100.0, 0.5);
  vec3 c = mix(unpre(s), screenB(unpre(s), ir), p_yansimaGucu / 100.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
