// ssimmap
INCLUDE(_chart)
uniform sampler2D s_referans; uniform float p_referansOn, p_pencere, p_hataEsig, p_cikti;
// Yapısal benzerlik (SSIM) penceresi: ortalama, varyans ve kovaryans; düşük benzerlik ısı rengiyle
vec4 refAt(vec2 px) { return p_referansOn > 0.5 ? texture(s_referans, boxUV(px)) : texPx(px + vec2(3.0, 0.0)); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float R = max(p_pencere * u_s * 0.5, 1.0); float ma = 0.0, mb = 0.0, va = 0.0, vb = 0.0, cv = 0.0;
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 q = p + vec2(i, j) / 3.0 * R; float a = luma(unpre(texPx(q))), b2 = luma(unpre(refAt(q))); ma += a; mb += b2; va += a * a; vb += b2 * b2; cv += a * b2; }
  float n = 49.0; ma /= n; mb /= n; va = va / n - ma * ma; vb = vb / n - mb * mb; cv = cv / n - ma * mb; float C1 = 0.0001, C2 = 0.0009;
  float ss = ((2.0 * ma * mb + C1) * (2.0 * cv + C2)) / ((ma * ma + mb * mb + C1) * (va + vb + C2)); float err = clamp(1.0 - ss, 0.0, 1.0);
  float e = smoothstep(p_hataEsig / 100.0 * 0.5, p_hataEsig / 100.0 * 0.5 + 0.25, err); vec3 heat = mix(vec3(0.1, 0.2, 0.9), vec3(1.0, 0.15, 0.1), e);
  vec4 res = p_cikti == 1.0 ? s : mix(s, vec4(heat * max(s.a, 0.6), max(s.a, 0.6)), 0.75 * smoothstep(0.0, 0.05, err));
  if (p_cikti > 0.5) { vec2 b = boxUV(here()); vec2 lp = (b - vec2(0.82, 0.08)) / vec2(0.04, 0.05); float tot = 0.0; for (int j = 0; j < 6; j++) for (int i = 0; i < 6; i++) { vec2 q = boxPx((vec2(i, j) + 0.5) / 6.0); float a = luma(unpre(texPx(q))), c = luma(unpre(refAt(q))); tot += abs(a - c); }
    res = overPre(vec4(1.0, 1.0, 0.3, 1.0) * numAt(lp, (1.0 - tot / 36.0) * 100.0), res); }
  o = res; }
