// emboss
uniform float p_isikAcis, p_yuksekli, p_kabartmaGucu, p_isikSevi, p_rengiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float a = radians(p_isikAcis); vec2 d = vec2(cos(a), sin(a)) * max(p_yuksekli * u_s, 0.5);
  float e = (lumAt(here() + d) - lumAt(here() - d)) * p_kabartmaGucu / 100.0 * 2.0 + (texPx(here() + d).a - texPx(here() - d).a) * 0.5 * p_kabartmaGucu / 100.0;
  float g = clamp(p_isikSevi / 100.0 + e, 0.0, 1.0);
  vec3 r = p_rengiKoru > 0.5 ? clamp(unpre(s) + (g - p_isikSevi / 100.0), 0.0, 1.0) : vec3(g);
  o = pre(r, s.a);
}
