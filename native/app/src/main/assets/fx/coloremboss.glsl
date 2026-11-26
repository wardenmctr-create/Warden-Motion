// coloremboss
uniform float p_kabartmaYuks, p_isikAcis, p_guc, p_renkKoru, p_kontrast;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float a = radians(p_isikAcis); vec2 d = vec2(cos(a), sin(a)) * max(p_kabartmaYuks * u_s, 0.5);
  vec3 e = (unpre(texPx(here() + d)) - unpre(texPx(here() - d))) * p_guc / 100.0;
  vec3 c = mix(vec3(0.5), unpre(s), p_renkKoru / 100.0) + e; c = conAdj(c, 1.0 + p_kontrast / 100.0, 0.5);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
