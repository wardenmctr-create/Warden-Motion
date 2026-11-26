// spinstreaks
uniform vec2 p_merkez; uniform float p_donmeAcis, p_esik, p_yogunluk, p_izAzal, p_yalnizIz;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 c = fromUnit(p_merkez); vec2 r = here() - c; vec4 acc = vec4(0.0); float th = p_esik / 100.0;
  for (int i = 1; i <= 32; i++) { float t = float(i) / 32.0; vec4 x = texPx(c + rot2(-p_donmeAcis * t) * r); float l = x.a > 0.0 ? luma(x.rgb / x.a) : 0.0; acc = max(acc, x * smoothstep(th, th + 0.1, l) * pow(1.0 - t, 1.0 + p_izAzal / 25.0)); }
  acc *= p_yogunluk / 100.0;
  o = p_yalnizIz > 0.5 ? acc : vec4(max(s.rgb, acc.rgb), max(s.a, acc.a));
}
