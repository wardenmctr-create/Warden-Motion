// 1000 rehberi 801–802: Savrulan Glitch ve Yönlü Yırtılma
//== scatterglitch
uniform float u_rot; uniform float p_yon, p_yonUzay, p_hiz, p_blokBoyu, p_boyutRast, p_yogunluk, p_dogumSikl, p_omur, p_azamiUzak, p_yayilim, p_savrulmaBici, p_isinlanmSikl, p_isinlanmAdim, p_kaymaIvme, p_karmaKaymOran,
  p_hareketSapm, p_donus, p_hareketBula, p_etkiBolg, p_etkiGeni, p_kaynakSeklKoru, p_kaynaktaKopuAlfa, p_kaynakTopa, p_rgbDagi, p_rgbKanaUzak, p_rgbYonu, p_parazit, p_blokOran, p_tohum;
// Kaynak blokları seçilen yönde dijital rüzgârla savrulur. Her blok tohumla kararlı: doğum anı, ömür, sapma ve Azami uzaklık içindeki kendi mesafesi (Yayılım).
// Işınlanma kesikli adımlarla, kayma sürekli (ivmeli) ilerler; koptuğu yerde saydam boşluk kalır ve toparlanma süresince kapanır.
vec2 cellSize() { float w = max(p_blokBoyu, 1.0); float r = max(p_blokOran, 0.1); return vec2(w * sqrt(r), w / sqrt(r)); }
float region(vec2 c, vec2 d) { if (p_etkiBolg < 0.5 || p_etkiBolg > 1.5) return 1.0; vec2 B = boxU() * 0.5; float ext = abs(d.x) * B.x + abs(d.y) * B.y; return step(ext * (1.0 - 2.0 * p_etkiGeni / 100.0), dot(c, d)); }
// blok kimliği → (yaş, uçuş mesafesi, sapma açısı, etkin)
vec4 blockState(vec2 id, vec2 dir) { float h0 = hash1(id + p_tohum * 0.71); if (h0 > p_yogunluk / 100.0) return vec4(-1.0); float rate = max(p_dogumSikl, 0.01) * 0.25;
  float per = 1.0 / rate; float ph = hash1(id * 1.3 + 7.0 + p_tohum) * per; float cyc = floor((u_t + ph) / per); float age = u_t + ph - cyc * per; float life = max(p_omur, 0.02);
  float h1v = hash1(id + cyc * 13.7 + p_tohum); if (h1v > 0.6 + p_yogunluk / 250.0) return vec4(-1.0);
  vec2 C = (id + 0.5) * cellSize(); if (region(C, dir) < 0.5) return vec4(-1.0);
  float maxD = p_azamiUzak * (1.0 - p_yayilim / 100.0 * hash1(id * 2.7 + cyc + p_tohum * 3.3)); float slide = p_savrulmaBici < 0.5 ? 0.0 : (p_savrulmaBici < 1.5 ? 1.0 : step(hash1(id + cyc * 5.1), p_karmaKaymOran / 100.0));
  float dTele = floor(age * max(p_isinlanmSikl, 0.01)) * p_isinlanmAdim; float dSlide = p_hiz * age + 0.5 * p_kaymaIvme * age * age; float d = clamp(mix(dTele, dSlide, slide), 0.0, maxD);
  float dev = (hash1(id * 4.1 + cyc) - 0.5) * 2.0 * radians(p_hareketSapm); return vec4(age, d, dev, age <= life ? 1.0 : 0.0); }
void main() { vec2 q = toUnit(here()); float ang = radians(p_yon) - (p_yonUzay < 0.5 ? radians(u_rot) : 0.0); vec2 dir = vec2(cos(ang), sin(ang)); vec2 cs = cellSize();
  // kaynak: koptuğu yer saydam (şekil koruma payına kadar), toparlanma süresinde kapanır
  vec2 sid = floor(q / cs); vec4 base = texU(q); vec4 st0 = blockState(sid, dir);
  if (p_kaynaktaKopuAlfa > 0.5 && st0.x >= 0.0 && hash1(sid * 9.1 + p_tohum) > p_kaynakSeklKoru / 100.0) { float life = max(p_omur, 0.02); float close = st0.x <= life ? 1.0 : 1.0 - clamp((st0.x - life) / max(p_kaynakTopa, 0.001), 0.0, 1.0); base *= 1.0 - close; }
  vec4 res = base; float Lmax = p_azamiUzak + max(cs.x, cs.y);
  // uçan bloklar: geriye doğru yol boyunca aday kaynak hücreleri
  for (int k = 0; k <= 48; k++) { float s = float(k) / 48.0 * Lmax; for (int sd = -1; sd <= 1; sd++) { vec2 dd = vec2(dir.x, dir.y); float a = float(sd) * radians(p_hareketSapm) * 0.5; dd = vec2(dd.x * cos(a) - dd.y * sin(a), dd.x * sin(a) + dd.y * cos(a));
      vec2 id = floor((q - dd * s) / cs); vec4 st = blockState(id, dir); if (st.w < 0.5) continue; float a2 = st.z; vec2 fd = vec2(dir.x * cos(a2) - dir.y * sin(a2), dir.x * sin(a2) + dir.y * cos(a2));
      vec2 C = (id + 0.5) * cs; float sz = 1.0 - p_boyutRast / 100.0 * hash1(id * 3.9 + p_tohum); vec2 P = C + fd * st.y; vec2 lq = q - P; float rot = radians(p_donus) * st.x; lq = mat2(cos(rot), sin(rot), -sin(rot), cos(rot)) * lq;
      if (abs(lq.x) > cs.x * 0.5 * sz || abs(lq.y) > cs.y * 0.5 * sz) continue; vec2 src = C + lq / sz; vec4 c = texU(src); if (c.a <= 0.01) continue;
      float fade = 1.0 - smoothstep(0.6, 1.0, st.x / max(p_omur, 0.02)) * 0.9 - smoothstep(0.85, 1.0, st.y / max(p_azamiUzak, 1.0)) * 0.6 * step(1e-3, p_azamiUzak);
      if (p_rgbDagi > 0.5) { float ra = radians(p_rgbYonu); vec2 ro = vec2(cos(ra), sin(ra)) * p_rgbKanaUzak; c = vec4(texU(src + ro).r, c.g, texU(src - ro).b, max(c.a, max(texU(src + ro).a, texU(src - ro).a))); }
      if (p_parazit > 0.0) { float nz = step(1.0 - p_parazit / 100.0 * 0.5, hash1(vec2(floor(lq.y / max(cs.y * 0.12, 0.5)), floor(u_t * 24.0)) + id)); c.rgb = mix(c.rgb, vec3(c.a), nz * 0.6); }
      res = overPre(c * clamp(fade, 0.0, 1.0), res); } }
  o = res; }

//== directionaltear
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
