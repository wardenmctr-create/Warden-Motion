// directionaltear
uniform float u_rot; uniform float p_yon, p_yonUzay, p_yogunluk, p_siklik, p_kalinlik, p_uzunluk, p_uzunlukDegi, p_duzenlil, p_ucSapm, p_hareketHizi, p_hareketMikt, p_kenarYumu, p_mod, p_ilerleme, p_sekliKoru,
  p_yenilenmKapa, p_kenarDalg, p_alfaGrad, p_gradyanKayn, p_gradyanMesa, p_gradyanGucu, p_tohum;
// Seçilen yöne bakan kenarda üçgenimsi girintiler: taban genişliği kalınlık, derinlik uzunluk (değişkenlik, uç sapması, hareketli titreşim).
// Direnme: girintiler sürekli açılıp kapanır, silüet korunur; Parçalanma: ilerlemeyle derinleşir ve çoğalır; Toparlanma: tersi. İsteğe bağlı dıştan içe gerçek alfa geçişi.
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 q = toUnit(here()); float ang = radians(p_yon) - (p_yonUzay < 0.5 ? radians(u_rot) : 0.0); vec2 d = vec2(cos(ang), sin(ang)); vec2 pp = vec2(-d.y, d.x);
  // kenara (yön boyunca) uzaklık
  float maxL = p_uzunluk * 2.0 + p_gradyanMesa + 4.0; float e = maxL; for (int k = 1; k <= 40; k++) { float r = float(k) / 40.0 * maxL; if (texU(q + d * r).a < 0.5) { e = r; break; } }
  float sAx = dot(q, pp); float wav = sin(sAx * 0.15 + u_t * 2.0) * p_kenarDalg; e += wav;
  float sp = max(p_kalinlik * 1.4, 1.0) / max(p_siklik / 6.0 * (0.4 + p_yogunluk / 100.0 * 1.2), 0.05); float cell = floor(sAx / sp); float jit = (hash1(vec2(cell, p_tohum)) - 0.5) * (1.0 - p_duzenlil / 100.0) * sp;
  float sc = (cell + 0.5) * sp + jit; float on = step(hash1(vec2(cell * 1.7, p_tohum + 2.0)), 0.35 + p_yogunluk / 100.0 * 0.65);
  float L = p_uzunluk * (1.0 + (hash1(vec2(cell * 3.1, p_tohum)) - 0.5) * 2.0 * p_uzunlukDegi / 100.0); float wob = sin(u_t * p_hareketHizi * 6.2832 + cell * 1.3) * p_hareketMikt;
  float amt; float pr = p_ilerleme / 100.0; if (p_mod < 0.5) { float cyc = max(p_yenilenmKapa, 0.02) * 4.0; amt = (0.5 + 0.5 * sin(u_t / cyc * 6.2832 + cell * 2.1)) * (1.0 - p_sekliKoru / 100.0 * 0.6); }
  else if (p_mod < 1.5) amt = pr * 1.5; else amt = (1.0 - pr) * 1.2;
  L = max(L * amt + wob, 0.0); float tipShift = tan(radians(p_ucSapm) * (hash1(vec2(cell, 9.0)) - 0.5) * 2.0) * L;
  float t = clamp(e / max(L, 1e-3), 0.0, 1.0); float hw = p_kalinlik * 0.5 * (1.0 - t); float x = abs(sAx - sc - tipShift * t); float soft = max(p_kenarYumu, 0.3);
  float cut = on * step(e, L) * (1.0 - smoothstep(hw - soft, hw + soft, x)); float a = 1.0 - cut;
  if (p_alfaGrad > 0.5) { float gd = p_gradyanKayn < 0.5 ? (cut > 0.0 ? 0.0 : min(abs(x - hw), e)) : (p_gradyanKayn < 1.5 ? e : min(e, abs(x - hw))); a *= 1.0 - (1.0 - smoothstep(0.0, max(p_gradyanMesa, 0.5), gd)) * p_gradyanGucu / 100.0; }
  o = s * clamp(a, 0.0, 1.0); }
