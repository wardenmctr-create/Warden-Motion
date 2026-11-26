// lightrays
uniform vec2 p_isikMerk; uniform float p_esik, p_uzunluk, p_yogunluk, p_ornekSayi, p_yalnizIsin; uniform vec3 c_isikReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 c = fromUnit(p_isikMerk); vec2 px = here(); vec2 d = px - c;
  float span = clamp(p_uzunluk * u_s / max(length(d), 1.0), 0.0, 1.0);
  int N = int(clamp(p_ornekSayi, 4.0, 64.0)); vec3 acc = vec3(0.0); float th = p_esik / 100.0;
  for (int i = 0; i < 64; i++) { if (i >= N) break; float t = float(i) / float(N); vec4 x = texPx(c + d * (1.0 - span * t));
    vec3 col = x.a > 0.0 ? x.rgb / x.a : vec3(0.0); float b = max(luma(col) - th, 0.0) / max(1.0 - th, 0.01); acc += col * b * x.a * (1.0 - t); }
  acc = acc / float(N) * p_yogunluk / 100.0 * 3.0 * c_isikReng;
  vec4 r = vec4(acc, max(acc.r, max(acc.g, acc.b)));
  o = p_yalnizIsin > 0.5 ? r : vec4(s.rgb + r.rgb * (1.0 - s.rgb), max(s.a, r.a));
}
