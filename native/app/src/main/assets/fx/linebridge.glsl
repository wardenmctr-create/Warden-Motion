// linebridge
uniform float p_boslukSini, p_aciTole, p_kopruKali, p_onizlemeIsar;
// Kopuk uç: koyu/opak çizgi pikselinin komşularından yalnız bir yönde devam eden uç; boşluk bu yönde aranır ve karşı uç bulunursa köprü çizilir
float ink(vec2 p) { vec4 c = texPx(p); return c.a > 0.5 && luma(unpre(c)) < 0.3 ? 1.0 : 0.0; }
float paper(vec2 p) { vec4 c = texPx(p); return c.a < 0.5 || luma(unpre(c)) > 0.6 ? 1.0 : 0.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); if (paper(p) < 0.5) { o = s; return; } float G = p_boslukSini * u_s; float th = max(p_kopruKali * u_s * 0.5, 0.75); float best = 0.0;
  for (int i = 0; i < 12; i++) { float a = float(i) / 12.0 * PI; vec2 d = vec2(cos(a), sin(a)); float l1 = -1.0, l2 = -1.0;
    for (int k = 1; k <= 24; k++) { float r = float(k) / 24.0 * G; if (l1 < 0.0 && ink(p + d * r) > 0.5) l1 = r; if (l2 < 0.0 && ink(p - d * r) > 0.5) l2 = r; }
    if (l1 > 0.0 && l2 > 0.0 && l1 + l2 <= G) { // iki uç da bu doğrultuda devam ediyor mu (açı toleransı)
      float tol = radians(p_aciTole); float ok1 = 0.0, ok2 = 0.0;
      for (int j = -2; j <= 2; j++) { float b = a + float(j) * tol * 0.5; vec2 e = vec2(cos(b), sin(b)); ok1 = max(ok1, ink(p + d * l1 + e * G * 0.5)); ok2 = max(ok2, ink(p - d * l2 - e * G * 0.5)); }
      if (ok1 * ok2 > 0.5) { float w = 1.0; for (int j = 1; j <= 3; j++) { vec2 n = vec2(-d.y, d.x) * th * float(j) / 3.0 * 1.6; w = min(w, 1.0); } best = 1.0; } } }
  if (best < 0.5) { o = s; return; } vec4 lc = vec4(0.06, 0.06, 0.08, 1.0); if (p_onizlemeIsar > 0.5) lc = vec4(1.0, 0.2, 0.3, 1.0); o = overPre(lc, s); }
