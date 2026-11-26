// zoomstreaks
uniform vec2 p_merkez; uniform float p_izUzun, p_esik, p_yogunluk, p_azalma, p_yalnizIz;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 c = fromUnit(p_merkez); vec2 r = here() - c; float L = length(r); vec2 d = L > 0.001 ? r / L : vec2(0.0); vec4 acc = vec4(0.0); float th = p_esik / 100.0;
  for (int i = 1; i <= 24; i++) { float t = float(i) / 24.0; vec4 x = texPx(here() - d * p_izUzun * u_s * t); float l = x.a > 0.0 ? luma(x.rgb / x.a) : 0.0; acc = max(acc, x * smoothstep(th, th + 0.1, l) * pow(1.0 - t, 1.0 + p_azalma / 25.0)); }
  acc *= p_yogunluk / 100.0;
  o = p_yalnizIz > 0.5 ? acc : vec4(max(s.rgb, acc.rgb), max(s.a, acc.a));
}
