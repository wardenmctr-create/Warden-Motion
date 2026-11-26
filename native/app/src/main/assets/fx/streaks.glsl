// streaks
uniform float p_esik, p_uzunluk, p_isinSayi, p_aci, p_yogunluk, p_kaynakRengKull; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); float th = p_esik / 100.0; int R = int(clamp(p_isinSayi, 2.0, 16.0)); vec3 acc = vec3(0.0);
  for (int k = 0; k < 16; k++) { if (k >= R) break; float a = radians(p_aci) + float(k) * PI / float(R) * (R > 2 ? 2.0 : 1.0); vec2 d = vec2(cos(a), sin(a)) * p_uzunluk * u_s;
    for (int i = 1; i <= 16; i++) { float t = float(i) / 16.0; vec4 x = texPx(here() + d * t); vec3 c = x.a > 0.0 ? x.rgb / x.a : vec3(0.0); float b = max(luma(c) - th, 0.0) / max(1.0 - th, 0.01);
      acc += (p_kaynakRengKull > 0.5 ? c : c_renk) * b * x.a * pow(1.0 - t, 2.0); } }
  acc *= p_yogunluk / 100.0 * 0.35;
  o = vec4(s.rgb + acc * (1.0 - s.rgb * 0.5), max(s.a, min(1.0, max(acc.r, max(acc.g, acc.b)))));
}
