// linstreaks
uniform float p_aci, p_izUzun, p_yogunluk, p_esik, p_azalma, p_yalnizIz;
void main() {
  vec4 s = texture(u_tex, v_uv); float a = radians(p_aci); vec2 d = -vec2(cos(a), sin(a)) * p_izUzun * u_s; vec4 acc = vec4(0.0); float th = p_esik / 100.0;
  for (int i = 1; i <= 24; i++) { float t = float(i) / 24.0; vec4 x = texPx(here() + d * t); float l = x.a > 0.0 ? luma(x.rgb / x.a) : 0.0; float w = smoothstep(th, th + 0.1, l) * pow(1.0 - t, 1.0 + p_azalma / 25.0); acc = max(acc, x * w); }
  acc *= p_yogunluk / 100.0;
  o = p_yalnizIz > 0.5 ? acc : vec4(max(s.rgb, acc.rgb), max(s.a, acc.a));
}
