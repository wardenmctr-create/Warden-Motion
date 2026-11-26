// deblur
uniform float p_hareketAcis, p_izUzun, p_duzeltmeGucu, p_gurultuBast, p_otomatikAnal;
void main() {
  vec4 s = texture(u_tex, v_uv); float a = radians(p_hareketAcis); vec2 d = vec2(cos(a), sin(a)) * p_izUzun * u_s * 0.5;
  vec4 b = lineAvg(here() - d, here() + d, 12, 3.0); vec4 c = s + (s - b) * p_duzeltmeGucu / 100.0 * 2.0;
  vec4 n = vec4(0.0); for (int i = 0; i < 4; i++) { float aa = float(i) * PI * 0.5; n += texPx(here() + vec2(cos(aa), sin(aa))); } n /= 4.0;
  c = mix(c, (c + n) * 0.5, p_gurultuBast / 100.0 * 0.5); c.a = s.a; c.rgb = clamp(c.rgb, 0.0, c.a); o = c;
}
