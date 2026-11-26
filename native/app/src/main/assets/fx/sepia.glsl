// sepia
uniform vec3 c_sepyaReng; uniform float p_guc, p_solma, p_kontrast;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c); l = (l - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5;
  vec3 t = l < 0.5 ? mix(vec3(0.05, 0.03, 0.02), c_sepyaReng, l * 2.0) : mix(c_sepyaReng, vec3(1.0, 0.97, 0.9), (l - 0.5) * 2.0);
  t = mix(t, vec3(0.92, 0.86, 0.74), p_solma / 100.0 * 0.5);
  o = pre(clamp(mix(c, t, p_guc / 100.0), 0.0, 1.0), s.a);
}
