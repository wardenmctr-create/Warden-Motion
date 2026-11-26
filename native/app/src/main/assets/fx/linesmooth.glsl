// linesmooth
uniform float p_uyumTole, p_koseKoru, p_cikti, p_cizgiKali;
// Alfa konturu düzleştirilir (bulanıklaştırıp eşikleme); köşelerde daha az yumuşatma; isteğe bağlı kontur çizgisi
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float R = max(p_uyumTole * u_s, 0.75); float a = 0.0, w = 0.0;
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { float g = exp(-float(i * i + j * j) / 6.0); a += texPx(p + vec2(i, j) / 3.0 * R).a * g; w += g; } a /= w;
  float corner = abs(a - s.a); float k = mix(1.0, 0.25, p_koseKoru / 100.0 * smoothstep(0.1, 0.4, corner)); a = mix(s.a, a, k);
  float aa = p_cikti < 0.5 ? smoothstep(0.5 - 0.5 / R, 0.5 + 0.5 / R, a) : step(0.5, a); vec3 base = s.a > 0.0 ? unpre(s) : unpre(texPx(p + alphaGrad(p, 2.0) * -4.0));
  float edge = 1.0 - smoothstep(0.0, p_cizgiKali * u_s * 0.08 + 0.02, abs(a - 0.5)) ; vec3 c = mix(base, vec3(0.05), edge * step(0.1, p_cizgiKali)); o = pre(c, max(aa, edge * step(0.1, p_cizgiKali))); }
