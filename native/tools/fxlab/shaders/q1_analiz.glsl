// 1000 rehberi bölüm 1 (803–824): renk, kompozit ve piksel analizi
//== holefill
uniform vec3 c_tekRenk; uniform float p_enBuyuDeli, p_dolguAlfa, p_dolguReng;
// Saydam piksel: 16 yönde ışın; hepsi delik çapı içinde opak kenara çarparsa kapalı deliktir
void main() { vec4 s = texture(u_tex, v_uv); if (s.a > 0.5) { o = s; return; }
  float R = 2.0 * sqrt(max(p_enBuyuDeli, 1.0) / PI) * u_s; float st = max(R / 32.0, 1.0); vec2 p = here(); float hits = 0.0; vec4 near = vec4(0.0); float nd = 1e9;
  for (int i = 0; i < 16; i++) { float a = float(i) / 16.0 * TAU; vec2 d = vec2(cos(a), sin(a)); bool hit = false;
    for (int k = 1; k <= 32; k++) { float r = float(k) * st; if (r > R) break; vec4 q = texPx(p + d * r); if (q.a > 0.5) { hit = true; if (r < nd) { nd = r; near = q; } break; } }
    if (hit) hits += 1.0; else break; }
  if (hits < 16.0) { o = s; return; }
  vec3 col = p_dolguReng < 0.5 ? unpre(near) : c_tekRenk; float a = p_dolguAlfa / 100.0; o = overPre(s, vec4(col * a, a)); }

//== convexhull
uniform vec3 c_dolgu; uniform float p_gruplama, p_yumusakl, p_cikti;
// Dışbükey zarf: 32 yöndeki ışınlardan isabet alanların arasındaki en büyük açı boşluğu 180°'den küçükse nokta zarfın içindedir
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float L = p_gruplama < 0.5 ? length(u_res) : max(u_box.z, u_box.w) * 0.3; float st = max(L / 40.0, 1.0);
  float last = -1.0, first = -1.0, gap = 0.0;
  for (int i = 0; i < 32; i++) { float a = float(i) / 32.0 * TAU; vec2 d = vec2(cos(a), sin(a)); bool hit = s.a > 0.5;
    for (int k = 1; k <= 40; k++) { if (hit) break; float r = float(k) * st; if (r > L) break; vec2 q = p + d * r; if (q.x < 0.0 || q.y < 0.0 || q.x > u_res.x || q.y > u_res.y) break; if (texPx(q).a > 0.5) hit = true; }
    if (hit) { if (first < 0.0) first = float(i); if (last >= 0.0) gap = max(gap, float(i) - last); last = float(i); } }
  if (first >= 0.0) gap = max(gap, first + 32.0 - last); else gap = 32.0;
  float soft = max(p_yumusakl * u_s / max(L, 1.0) * 32.0, 0.35); float h = 1.0 - smoothstep(16.0 - soft, 16.0 + soft, gap); h = max(h, s.a);
  o = p_cikti < 0.5 ? vec4(vec3(h), h) : overPre(s, vec4(c_dolgu * h, h)); }

//== geodesiccolor
uniform sampler2D s_baslangiMask, s_bitisMask; uniform float p_baslangiMaskOn, p_bitisMaskOn; uniform vec3 c_baslangi, c_bitis;
// İç uzaklık yaklaşık: silüet dışına çıkmayan ışınlarla iki maskeye en kısa uzaklık; renk oranla karışır
float maskA(sampler2D t, float on, vec2 b, float side) { if (on > 0.5) return texture(t, b).a; return side < 0.5 ? step(b.x, 0.12) : step(0.88, b.x); }
float reach(sampler2D t, float on, float side) { vec2 p = here(); float best = 1e5; float st = max(length(u_box.zw) / 48.0, 1.0);
  for (int i = 0; i < 16; i++) { float a = float(i) / 16.0 * TAU; vec2 d = vec2(cos(a), sin(a));
    for (int k = 0; k <= 48; k++) { vec2 q = p + d * float(k) * st; if (texPx(q).a < 0.3) break; if (maskA(t, on, boxUV(q), side) > 0.5) { best = min(best, float(k) * st); break; } } }
  return best; }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float a = reach(s_baslangiMask, p_baslangiMaskOn, 0.0), b = reach(s_bitisMask, p_bitisMaskOn, 1.0);
  float k = (a > 9e4 && b > 9e4) ? boxUV(here()).x : a / max(a + b, 1e-3); vec3 c = mix(c_baslangi, c_bitis, clamp(k, 0.0, 1.0)); o = pre(c * mix(0.75, 1.0, luma(unpre(s))) + unpre(s) * 0.0, s.a); }

//== linebridge
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

//== linejunction
uniform vec3 c_ucReng, c_kavsakReng; uniform float p_algilamaEsig, p_isaretCapi;
// İskelet komşuluğu: çevre halkasındaki çizgi geçişi sayısı 1 = uç, ≥3 = kavşak
float on(vec2 p) { vec4 c = texPx(p); return step(1.0 - p_algilamaEsig / 100.0, c.a * (0.4 + 0.6 * (1.0 - luma(unpre(c))))); }
float crossings(vec2 c, float r) { float n = 0.0; float prev = on(c + vec2(r, 0.0)); for (int i = 1; i <= 24; i++) { float a = float(i) / 24.0 * TAU; float cur = on(c + vec2(cos(a), sin(a)) * r); if (cur > 0.5 && prev < 0.5) n += 1.0; prev = cur; } return n; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float R = max(p_isaretCapi * u_s * 0.5, 1.5); vec4 res = s;
  // işaret: yakın 3×3 adaydan en güçlüsü
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = floor((p + vec2(i, j) * R * 2.0) / (R * 2.0)) * R * 2.0 + R; if (on(c) < 0.5) continue; float n = crossings(c, R * 1.6);
    float d = length(p - c); float a = 1.0 - smoothstep(R - 1.0, R, d); if (a <= 0.0) continue;
    if (n < 1.5 && n > 0.5) res = overPre(vec4(c_ucReng, 1.0) * a, res); else if (n > 2.5) res = overPre(vec4(c_kavsakReng, 1.0) * a, res); }
  o = res; }

//== curvaturemap
uniform vec3 c_icbukey, c_disbukey; uniform float p_olcumYari, p_notrEsik;
// Eğrilik: yarıçap içindeki alfa ortalaması (0.5 düz, >0.5 içbükey köşe, <0.5 dışbükey çıkıntı); yalnız kenar bandında
float avgA(vec2 p, float r) { float a = 0.0; for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 o2 = vec2(i, j) / 3.0; if (length(o2) > 1.0) continue; a += step(0.5, texPx(p + o2 * r).a); } return a / 29.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float r = max(p_olcumYari * u_s, 1.5); float e = length(alphaGrad(p, 1.0)); if (s.a <= 0.0 || e < 0.05) { o = s; return; }
  float k = (avgA(p, r) - 0.5) * 2.0; float th = p_notrEsik / 100.0; vec3 base = unpre(s); vec3 c = abs(k) < th ? base : (k > 0.0 ? c_icbukey : c_disbukey); float w = smoothstep(th, th + 0.15, abs(k));
  o = pre(mix(base, c, w), s.a); }

//== repeatdetect
INCLUDE(_chart)
uniform sampler2D s_motifOrne; uniform float p_motifOrneOn, p_benzerli, p_azamiEsle, p_olcekDegiIzin;
// Motif: kaynak katman (yoksa kutunun sol üst çeyreği) 6×6 tanımlayıcı; her ızgara hücresinde karşılaştırılır, benzer hücreler kutuyla işaretlenir
vec3 mot(vec2 u) { if (p_motifOrneOn > 0.5) return unpre(texture(s_motifOrne, u)); return unpre(texPx(boxPx(vec2(0.04, 0.04) + u * 0.22))); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float cell = 0.22; vec2 g = floor(b / cell); vec2 f = fract(b / cell);
  float best = 0.0; for (int sc = 0; sc < 2; sc++) { if (sc == 1 && p_olcekDegiIzin < 0.5) break; float k = sc == 0 ? 1.0 : 0.75; float err = 0.0;
    for (int j = 0; j < 6; j++) for (int i = 0; i < 6; i++) { vec2 u = (vec2(i, j) + 0.5) / 6.0; vec3 a = mot(u); vec3 c = unpre(texPx(boxPx((g + 0.5 - k * 0.5 + u * k) * cell))); err += length(a - c); }
    best = max(best, 1.0 - err / 36.0 / 0.6); }
  float idx = g.y * floor(1.0 / cell + 1.0) + g.x; bool hit = best * 100.0 >= p_benzerli && idx < p_azamiEsle;
  if (!hit || any(greaterThan(g * cell, vec2(1.0)))) { o = s; return; }
  float edge = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)) * cell * min(u_box.z, u_box.w); float line = 1.0 - smoothstep(1.0, 2.0, edge);
  vec2 lp = (f - vec2(0.2, 0.15)) / vec2(0.12, 0.09); float num = (lp.x > -0.6 && lp.x < 2.6 && abs(lp.y) < 1.0) ? numAt(lp - vec2(1.0, 0.0), best * 100.0) : 0.0;
  o = overPre(vec4(1.0, 0.8, 0.2, 1.0) * max(line, num), s); }

//== illumsplit
uniform float p_isikOlce, p_kenarKoru, p_cikti, p_guc;
// Çarpımsal model: görüntü = yansıtım × aydınlatma; aydınlatma = kenar duyarlı geniş ortalama parlaklık
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); float l0 = luma(c); float R = p_isikOlce * u_s; float acc = 0.0, w = 0.0; float ek = p_kenarKoru / 100.0;
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec4 q = texPx(here() + vec2(i, j) / 4.0 * R); if (q.a <= 0.0) continue; float l = luma(unpre(q)); float ww = exp(-dot(vec2(i, j), vec2(i, j)) / 16.0) * exp(-abs(l - l0) * ek * 8.0); acc += l * ww; w += ww; }
  float L = max(acc / max(w, 1e-4), 0.02); vec3 refl = clamp(c / L * 0.5, 0.0, 1.0); vec3 r = p_cikti < 0.5 ? refl : (p_cikti < 1.5 ? vec3(L) : clamp(refl * 2.0 * mix(L, 0.5, 0.6), 0.0, 1.0));
  o = pre(mix(c, r, p_guc / 100.0), s.a); }

//== paletteextract
INCLUDE(_chart)
uniform float p_renkSayi, p_siralama, p_seffafiDisl, p_yuzdeEtik;
// 12×12 örnek; renkler ton/parlaklık kutularına toplanır, en dolu N kutu palet kartında oranla gösterilir
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); int N = int(clamp(p_renkSayi, 2.0, 32.0)); vec4 acc[32]; for (int i = 0; i < 32; i++) acc[i] = vec4(0.0);
  float tot = 0.0;
  for (int j = 0; j < 12; j++) for (int i = 0; i < 12; i++) { vec4 q = texPx(boxPx((vec2(i, j) + 0.5) / 12.0)); if (p_seffafiDisl > 0.5 && q.a < 0.5) continue; vec3 c = q.a > 0.0 ? unpre(q) : vec3(0.0); vec3 h = rgb2hsv(c);
    int bin = h.y < 0.18 ? int(clamp(h.z * 4.0, 0.0, 3.0)) : 4 + int(floor(h.x * 14.0)) * 2 + int(step(0.55, h.z)); bin = bin % 32; acc[bin] += vec4(c, 1.0); tot += 1.0; }
  // en dolu N kutuyu seç (seçim sırası: alan)
  float used[32]; for (int i = 0; i < 32; i++) used[i] = 0.0; vec4 pal[32]; float frac[32]; for (int i = 0; i < 32; i++) { pal[i] = vec4(0.0); frac[i] = 0.0; }
  for (int n = 0; n < 32; n++) { if (n >= N) break; float bc = 0.0; int bi = -1; for (int i = 0; i < 32; i++) if (used[i] < 0.5 && acc[i].w > bc) { bc = acc[i].w; bi = i; } if (bi < 0) break; used[bi] = 1.0; pal[n] = vec4(acc[bi].rgb / acc[bi].w, 1.0); frac[n] = acc[bi].w / max(tot, 1.0); }
  if (p_siralama > 0.5) for (int a = 0; a < 32; a++) for (int i = 0; i < 31; i++) { if (i + 1 >= N) break; float ka = p_siralama < 1.5 ? rgb2hsv(pal[i].rgb).x : luma(pal[i].rgb); float kb = p_siralama < 1.5 ? rgb2hsv(pal[i + 1].rgb).x : luma(pal[i + 1].rgb);
    if (pal[i + 1].a > 0.0 && ka > kb) { vec4 t = pal[i]; pal[i] = pal[i + 1]; pal[i + 1] = t; float f = frac[i]; frac[i] = frac[i + 1]; frac[i + 1] = f; } }
  // kart: kutunun alt %22'si
  if (b.y < 0.78 || b.y > 1.0 || b.x < 0.0 || b.x > 1.0) { o = s; return; } float x = 0.0; vec4 col = vec4(0.1, 0.1, 0.12, 1.0); float x0 = 0.0, fw = 0.0, pct = 0.0;
  for (int i = 0; i < 32; i++) { if (i >= N || pal[i].a <= 0.0) break; float w = frac[i]; if (b.x >= x && b.x < x + w) { col = pal[i]; x0 = x; fw = w; pct = w * 100.0; } x += w; }
  if (p_yuzdeEtik > 0.5 && fw > 0.06) { vec2 lp = vec2((b.x - x0 - fw * 0.5) / 0.03, (b.y - 0.89) / 0.04); float nm = numAt(lp, pct); col.rgb = mix(col.rgb, luma(col.rgb) > 0.5 ? vec3(0.0) : vec3(1.0), nm); }
  o = col; }

//== gradpath
uniform vec2 p_baslangi, p_bitis; uniform float p_durakSayi, p_ornekGeni;
// A→B doğrusundan örnek; durak sayısı kadar basamaklı gradyan şeridi kutunun altında, ölçüm çizgisi görüntü üstünde
vec3 sampleAt(float u) { vec2 q = mix(p_baslangi, p_bitis, u); vec2 n = normalize(vec2(-(p_bitis - p_baslangi).y, (p_bitis - p_baslangi).x) + 1e-5); vec3 a = vec3(0.0); for (int i = -2; i <= 2; i++) a += unpre(texU(q + n * float(i) * p_ornekGeni / 4.0)); return a / 5.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 q = toUnit(here()); float N = clamp(floor(p_durakSayi), 2.0, 64.0);
  vec2 ab = p_bitis - p_baslangi; float u = clamp(dot(q - p_baslangi, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(q - p_baslangi - ab * u);
  vec4 res = s; float lw = 1.0 / u_s; res = overPre(vec4(1.0) * (1.0 - smoothstep(lw, lw * 2.0, d)), res);
  if (b.y > 0.86 && b.y < 0.98 && b.x > 0.04 && b.x < 0.96) { float x = (b.x - 0.04) / 0.92; float k = floor(x * N) / (N - 1.0); vec3 c = mix(sampleAt(floor(x * N) / N), sampleAt(min(1.0, (floor(x * N) + 1.0) / N)), 0.0); c = sampleAt(k); res = vec4(c, 1.0); }
  o = res; }

//== edgedirextend
uniform float p_uzama, p_yonYumu, p_alfayiGeni, p_karisim;
// Kenar teğeti boyunca rengi uzatır (çizgi akışı): teğet yönünde ileri-geri ortalama
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); vec2 g = vec2(0.0); float R = max(p_yonYumu * u_s, 1.0);
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 q = p + vec2(i, j) * R * 0.5; vec2 gg = lumGrad(q, 1.0) + alphaGrad(q, 1.0); g += vec2(gg.x * gg.x - gg.y * gg.y, 2.0 * gg.x * gg.y); }
  float ang = 0.5 * atan(g.y, g.x); vec2 t = vec2(-sin(ang), cos(ang)); float L = p_uzama * u_s; vec4 acc = s; float w = 1.0;
  for (int k = 1; k <= 16; k++) { float r = float(k) / 16.0 * L; float ww = 1.0 - float(k) / 17.0; acc += (texPx(p + t * r) + texPx(p - t * r)) * ww; w += 2.0 * ww; }
  vec4 e = acc / w; if (p_alfayiGeni < 0.5) e = e.a > 0.0 ? vec4(unpre(e) * s.a, s.a) : vec4(0.0); o = mix(s, e, p_karisim / 100.0); }

//== medianbg
INCLUDE(_hist)
uniform float p_analizSure, p_ornek, p_hareketEsig, p_sonucuOnbe;
// Kare şeridindeki karelerin piksel bazlı medyanı (parlaklığa göre sıralı orta değer); hareket eşiği aykırıları dışlar
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 3.0) { o = s; return; } vec4 c[16]; float l[16]; int m = int(min(n, 16.0));
  for (int i = 0; i < 16; i++) { if (i >= m) break; c[i] = hist(float(i), v_uv); l[i] = luma(c[i].rgb) + c[i].a * 0.001; }
  for (int a = 0; a < 16; a++) for (int i = 0; i < 15; i++) { if (i + 1 >= m) break; if (l[i] > l[i + 1]) { float t = l[i]; l[i] = l[i + 1]; l[i + 1] = t; vec4 tc = c[i]; c[i] = c[i + 1]; c[i + 1] = tc; } }
  vec4 med = c[m / 2]; vec4 acc = vec4(0.0); float w = 0.0; float th = p_hareketEsig / 100.0 + 0.02;
  for (int i = 0; i < 16; i++) { if (i >= m) break; if (abs(l[i] - l[m / 2]) <= th) { acc += c[i]; w += 1.0; } }
  o = w > 0.0 ? acc / w : med; }

//== ssimmap
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

//== satlumplane
uniform float p_bolme, p_olcek, p_kaynakRenk, p_grafikOpak;
// Grafik: x = doygunluk, y = parlaklık; yoğunluk 20×20 örnekten pencere yakınlığıyla; kutunun sağ alt köşesinde
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 g = (b - vec2(0.55, 0.55)) / 0.42; if (any(lessThan(g, vec2(0.0))) || any(greaterThan(g, vec2(1.0)))) { o = s; return; }
  float N = clamp(p_bolme, 16.0, 256.0); vec2 cell = floor(g * N) / N; float cnt = 0.0; vec3 col = vec3(0.0);
  for (int j = 0; j < 20; j++) for (int i = 0; i < 20; i++) { vec4 q = texPx(boxPx((vec2(i, j) + 0.5) / 20.0)); if (q.a < 0.2) continue; vec3 h = rgb2hsv(unpre(q)); vec2 pt = vec2(h.y, 1.0 - h.z);
    if (floor(pt * N) == floor(g * N)) { cnt += 1.0; col += unpre(q); } }
  float d = p_olcek > 0.5 ? log(1.0 + cnt) / log(1.0 + 40.0) : cnt / 12.0; vec3 dot2 = p_kaynakRenk > 0.5 && cnt > 0.0 ? col / cnt : vec3(1.0);
  vec4 bg = vec4(0.06, 0.07, 0.1, 0.85); float grid = (fract(g.x * 4.0) < 0.02 || fract(g.y * 4.0) < 0.02) ? 0.15 : 0.0; bg.rgb += grid;
  vec4 gr = overPre(vec4(dot2 * clamp(d, 0.0, 1.0), clamp(d, 0.0, 1.0)), bg) * (p_grafikOpak / 100.0); o = overPre(gr, s); }

//== colorslice
uniform float p_uzay, p_eksen, p_kesit, p_kaynakNoktGost;
// Kutunun içi bir renk uzayı dilimi: iki serbest eksen x-y, üçüncü eksen = kesit; kaynak pikselleri dilime yakınsa nokta
vec3 fromSpace(vec3 v) { if (p_uzay < 0.5) { float L = v.x * 100.0, A = (v.y - 0.5) * 200.0, B = (v.z - 0.5) * 200.0; float fy = (L + 16.0) / 116.0, fx = fy + A / 500.0, fz = fy - B / 200.0;
    vec3 f = vec3(fx, fy, fz); vec3 r = mix((f - 16.0 / 116.0) / 7.787, f * f * f, step(0.2069, f)); vec3 xyz = r * vec3(0.9505, 1.0, 1.089);
    vec3 lin = mat3(3.2406, -0.9689, 0.0557, -1.5372, 1.8758, -0.2040, -0.4986, 0.0415, 1.0570) * xyz; return clamp(lin2srgb(lin), 0.0, 1.0); }
  if (p_uzay < 1.5) return hsv2rgb(v); return v; }
vec3 toSpace(vec3 c) { if (p_uzay < 0.5) { vec3 lin = srgb2lin(c); vec3 xyz = mat3(0.4124, 0.2126, 0.0193, 0.3576, 0.7152, 0.1192, 0.1805, 0.0722, 0.9505) * lin / vec3(0.9505, 1.0, 1.089);
    vec3 f = mix(7.787 * xyz + 16.0 / 116.0, pow(max(xyz, 1e-6), vec3(1.0 / 3.0)), step(0.008856, xyz)); return vec3((116.0 * f.y - 16.0) / 100.0, (500.0 * (f.x - f.y)) / 200.0 + 0.5, (200.0 * (f.y - f.z)) / 200.0 + 0.5); }
  if (p_uzay < 1.5) return rgb2hsv(c); return c; }
vec3 compose(vec2 xy, float z) { int e = int(p_eksen + 0.5); return e == 0 ? vec3(z, xy) : (e == 1 ? vec3(xy.x, z, xy.y) : vec3(xy, z)); }
vec2 project(vec3 v, out float z) { int e = int(p_eksen + 0.5); if (e == 0) { z = v.x; return v.yz; } if (e == 1) { z = v.y; return v.xz; } z = v.z; return v.xy; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = s; return; }
  vec2 xy = vec2(b.x, 1.0 - b.y); vec3 c = fromSpace(compose(xy, p_kesit / 100.0)); vec4 res = vec4(c, 1.0);
  if (p_kaynakNoktGost > 0.5) for (int j = 0; j < 14; j++) for (int i = 0; i < 14; i++) { vec4 q = texPx(boxPx((vec2(i, j) + 0.5) / 14.0)); if (q.a < 0.3) continue; float z; vec2 pp = project(toSpace(unpre(q)), z);
    if (abs(z - p_kesit / 100.0) > 0.12) continue; float d = length((pp - xy) * u_box.zw); res = mix(res, vec4(1.0), (1.0 - smoothstep(2.0, 3.5, d)) * 0.9); }
  o = res; }

//== curvmatte
uniform float p_secim, p_olcumOlce, p_esik, p_matYumu;
float avgA2(vec2 p, float r) { float a = 0.0; for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 o2 = vec2(i, j) / 3.0; if (length(o2) > 1.0) continue; a += step(0.5, texPx(p + o2 * r).a); } return a / 29.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float r = max(p_olcumOlce * u_s, 1.5); float k = (avgA2(p, r) - 0.5) * 2.0; float th = p_esik / 100.0; float sw = max(p_matYumu / max(p_olcumOlce, 1.0), 0.02);
  float m = p_secim < 0.5 ? smoothstep(th, th + sw, k) : (p_secim < 1.5 ? smoothstep(th, th + sw, -k) : smoothstep(th, th + sw, abs(k)));
  float band = 1.0 - smoothstep(r * 0.6, r * 1.2, s.a > 0.5 ? innerDist(p, r * 1.2) : outerDist(p, r * 1.2)); m *= band; o = vec4(vec3(m), m); }

//== areameter
INCLUDE(_chart)
uniform vec3 c_etiket; uniform float p_alfaEsig, p_olcu, p_izCizg;
// 32×32 örnekle alan (%), çevre (kenar hücre sayısı) ve ağırlık merkezi; sayaç kutunun sol üstünde, merkez artı işaretiyle
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float th = p_alfaEsig / 100.0; float area = 0.0, per = 0.0; vec2 cen = vec2(0.0);
  for (int j = 0; j < 32; j++) for (int i = 0; i < 32; i++) { vec2 u = (vec2(i, j) + 0.5) / 32.0; float a = step(th, texPx(boxPx(u)).a); area += a; cen += u * a;
    if (a > 0.5) { float nb = step(th, texPx(boxPx(u + vec2(1.0 / 32.0, 0.0))).a) * step(th, texPx(boxPx(u - vec2(1.0 / 32.0, 0.0))).a) * step(th, texPx(boxPx(u + vec2(0.0, 1.0 / 32.0))).a) * step(th, texPx(boxPx(u - vec2(0.0, 1.0 / 32.0))).a); per += 1.0 - nb; } }
  cen /= max(area, 1.0); float val = p_olcu < 0.5 ? area / 1024.0 * 100.0 : (p_olcu < 1.5 ? per * (u_box.z / u_s) / 32.0 : cen.x * 100.0);
  vec4 res = s; vec2 lp = (b - vec2(0.12, 0.08)) / vec2(0.035, 0.045); float nm = numAt(lp, val); res = overPre(vec4(c_etiket, 1.0) * nm, res);
  vec2 d = abs((b - cen) * u_box.zw); float cross2 = (d.x < 1.2 && d.y < 8.0) || (d.y < 1.2 && d.x < 8.0) ? 1.0 : 0.0; if (area > 0.0) res = overPre(vec4(c_etiket, 1.0) * cross2, res); o = res; }

//== flowconfidence
INCLUDE(_hist)
uniform float p_ileriGeriHata, p_dokuEsig, p_cikti, p_yumusatm;
// Lucas-Kanade akışı kare t→t+1 ve t+1→t; ileri-geri hata ve doku (gradyan enerjisi) güveni belirler
vec2 lk(float a, float b2, vec2 uv) { vec2 px = 1.0 / u_res; mat2 A = mat2(0.0); vec2 bb = vec2(0.0); float r = max(p_yumusatm, 1.0);
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 q = uv + vec2(i, j) * px * r; float Ix = (luma(hist(a, q + vec2(px.x, 0.0)).rgb) - luma(hist(a, q - vec2(px.x, 0.0)).rgb)) * 0.5;
    float Iy = (luma(hist(a, q + vec2(0.0, px.y)).rgb) - luma(hist(a, q - vec2(0.0, px.y)).rgb)) * 0.5; float It = luma(hist(b2, q).rgb) - luma(hist(a, q).rgb); A += mat2(Ix * Ix, Ix * Iy, Ix * Iy, Iy * Iy); bb += vec2(Ix * It, Iy * It); }
  float det = A[0][0] * A[1][1] - A[0][1] * A[1][0]; return abs(det) > 1e-7 ? -inverse(A) * bb : vec2(0.0); }
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 3.0) { o = s; return; } vec2 f = lk(0.0, 2.0, v_uv); vec2 bk = lk(2.0, 0.0, v_uv + f / u_res); float err = length(f + bk);
  float tex2 = length(lumGrad(here(), 1.0)) * 4.0; float conf = (1.0 - smoothstep(p_ileriGeriHata * 0.5, p_ileriGeriHata * 1.5, err)) * smoothstep(p_dokuEsig / 100.0 * 0.5, p_dokuEsig / 100.0, tex2);
  float v = p_cikti < 0.5 ? conf : 1.0 - conf; o = vec4(vec3(v) * s.a, s.a); }

//== lightfieldfix
uniform sampler2D s_referans; uniform float p_referansOn, p_alanOlce, p_zamansalYumu, p_guc;
// Geniş ölçekli ışık alanı: kendi ve referansın büyük pencere ortalama parlaklığı oranı ile kazanç
float wide(vec2 px, bool ref) { float R = p_alanOlce * u_s; float a = 0.0, w = 0.0; for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 q = px + vec2(i, j) / 3.0 * R; vec4 c = ref ? texture(s_referans, boxUV(q)) : texPx(q); if (c.a <= 0.0) continue; a += luma(unpre(c)); w += 1.0; } return w > 0.0 ? a / w : 0.5; }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float me = max(wide(here(), false), 0.02); float target = p_referansOn > 0.5 ? wide(here(), true) : 0.5;
  float g = clamp(target / me, 0.25, 4.0); vec3 c = unpre(s); o = pre(clamp(mix(c, c * g, p_guc / 100.0), 0.0, 1.0), s.a); }

//== chanalpha
uniform float p_cikti, p_normaliz, p_kenarEsig, p_tersCevi;
// R, G, B kanalları ayrı mat: "Üç mat" kutuyu üç şeride böler (R | G | B), "Tek kanal" en baskın kanalın matını verir
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); vec2 b = boxUV(here()); vec3 m = c;
  if (p_normaliz > 0.5) { vec3 mx = vec3(1e-3); for (int j = 0; j < 8; j++) for (int i = 0; i < 8; i++) mx = max(mx, unpre(texPx(boxPx((vec2(i, j) + 0.5) / 8.0)))); m = c / mx; }
  m = smoothstep(vec3(p_kenarEsig / 100.0), vec3(p_kenarEsig / 100.0 + 0.05 + 1e-3), m) * (p_kenarEsig > 0.0 ? 1.0 : 0.0) + (p_kenarEsig > 0.0 ? vec3(0.0) : m); if (p_tersCevi > 0.5) m = 1.0 - m; m *= s.a;
  if (p_cikti < 0.5) { int k = int(clamp(floor(b.x * 3.0), 0.0, 2.0)); float v = k == 0 ? m.r : (k == 1 ? m.g : m.b); vec3 tint = k == 0 ? vec3(1.0, 0.3, 0.3) : (k == 1 ? vec3(0.3, 1.0, 0.4) : vec3(0.35, 0.55, 1.0)); o = vec4(mix(vec3(v), tint * v, 0.25), max(v, 0.0) > 0.0 ? 1.0 : s.a); }
  else { float v = max(m.r, max(m.g, m.b)); o = vec4(vec3(v), v); } }

//== thicknessmap
uniform float p_enBuyuOlcu, p_cikti, p_detay, p_siluetiKoru;
// Yerel kalınlık: çevredeki iç uzaklık tepelerinin (medial eksen) en büyüğünün iki katı
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = p_siluetiKoru > 0.5 ? vec4(0.0) : s; return; } vec2 p = here(); float M = p_enBuyuOlcu * u_s * 0.5; float d0 = innerDist(p, M);
  float best = d0; float R = d0 * (1.0 + (1.0 - p_detay / 100.0)); for (int i = 0; i < 8; i++) { float a = float(i) / 8.0 * TAU; for (int k = 1; k <= 3; k++) { vec2 q = p + vec2(cos(a), sin(a)) * R * float(k) / 3.0; if (texPx(q).a < 0.5) break; best = max(best, innerDist(q, M)); } }
  float th = clamp(best * 2.0 / max(M * 2.0, 1.0), 0.0, 1.0); vec3 c = p_cikti < 0.5 ? vec3(th) : hsv2rgb(vec3(0.66 - th * 0.66, 0.85, 0.95)); o = pre(c, s.a); }

//== roughmeter
uniform vec3 c_isaret; uniform float p_pencere, p_olcu, p_kontrast;
// Yapı tensörü: pürüz = gradyan enerjisi, yön tutarlılığı = (λ1−λ2)/(λ1+λ2)
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float R = max(p_pencere * u_s * 0.5, 1.0); float jxx = 0.0, jyy = 0.0, jxy = 0.0;
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 g = lumGrad(p + vec2(i, j) / 3.0 * R, 1.0); jxx += g.x * g.x; jyy += g.y * g.y; jxy += g.x * g.y; }
  jxx /= 49.0; jyy /= 49.0; jxy /= 49.0; float tr = jxx + jyy; float dt = sqrt(max((jxx - jyy) * (jxx - jyy) + 4.0 * jxy * jxy, 0.0)); float coh = tr > 1e-6 ? dt / tr : 0.0;
  float v = p_olcu < 0.5 ? sqrt(tr) * 6.0 : coh; v = clamp((v - 0.5) * (0.5 + p_kontrast / 50.0) + 0.5, 0.0, 1.0);
  vec3 c = mix(unpre(s) * 0.35, c_isaret, v); o = pre(c, max(s.a, 0.0)); }
