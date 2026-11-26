// bricon
uniform float p_parlakli, p_kontrast, p_kontrastMerk, p_alfaKanaKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s) + p_parlakli / 100.0 * 0.6;
  float k = p_kontrast >= 0.0 ? 1.0 / max(0.02, 1.0 - p_kontrast / 100.0 * 0.98) : 1.0 + p_kontrast / 100.0;
  c = conAdj(c, k, p_kontrastMerk / 100.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
