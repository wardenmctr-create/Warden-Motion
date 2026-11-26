// 1000 rehberi bölüm 9 (979–1000): kurgu, görüntü akışı ve geçişler
//== perspmatch
uniform sampler2D s_hedef; uniform float p_hedefOn, p_noktaSeti, p_guc, p_ufkuKoru;
// Hedef görüntü, katmanın düzlemine perspektif (yamuk) dönüşümle oturtulur: üst kenar güç oranında daralır; ufuk korunursa dikey ölçek sabit
void main() { vec4 s = texture(u_tex, v_uv); if (p_hedefOn < 0.5) { o = s; return; } vec2 b = boxUV(here()); float k = p_guc / 100.0 * 0.45; float w = mix(1.0 - k * 2.0, 1.0, b.y);
  float u = (b.x - 0.5) / max(w, 0.05) + 0.5; float v = p_ufkuKoru > 0.5 ? b.y : pow(clamp(b.y, 0.0, 1.0), mix(1.0, 1.6, k)); if (u < 0.0 || u > 1.0) { o = s; return; } vec4 t = texture(s_hedef, vec2(u, v)); o = overPre(t, s); }

//== cutbeatpreview
INCLUDE(_hist)
uniform vec4 p_dv4[4]; float dvAt(int i) { return i < 0 || i >= 16 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_arama, p_ritimAgir, p_hareketUyum;
// Alt şerit: ±arama penceresinde vuruşlar (motor: ses başlangıç zamanları, şimdiye göre), hareket miktarı ve önerilen kesme noktası
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); if (b.y < 0.84) { o = s; return; } float x = (b.x - 0.5) * 2.0 * p_arama; vec4 res = overPre(vec4(0.03, 0.04, 0.08, 0.8), s);
  float mot = 0.0; if (histN() >= 2.0) { for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) { vec2 uv = (vec2(i, j) + 0.5) / 4.0; mot += length(hist(0.0, uv).rgb - hist(1.0, uv).rgb); } mot /= 16.0; }
  int N = p_dvN > 0.5 ? int(p_dvN) : 6; float best = 1e9; float bestT = 0.0;
  for (int k = 0; k < 16; k++) { if (k >= N) break; float bt = p_dvN > 0.5 ? dvAt(k) : (float(k) - 2.5) * 0.24 - mod(u_t, 0.24); if (abs(bt) > p_arama) continue; float score = abs(bt) * (1.0 - p_ritimAgir / 100.0 * 0.8); if (score < best) { best = score; bestT = bt; }
    res = overPre(vec4(1.0, 0.8, 0.3, 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.z * 2.0 * p_arama, abs(x - bt))) * step(0.88, b.y), res); }
  if (p_hareketUyum > 0.5) res = overPre(vec4(0.3, 0.8, 1.0, 1.0) * step(b.y, 0.88) * step(abs(b.x - 0.5) * 2.0, clamp(mot * 3.0, 0.0, 1.0)) * 0.7, res);
  res = overPre(vec4(1.0) * (1.0 - smoothstep(0.0, 1.0 / u_box.z * 2.0 * p_arama, abs(x))) * 0.6, res); if (best < 1e8) res = overPre(vec4(0.3, 1.0, 0.4, 1.0) * (1.0 - smoothstep(0.0, 3.0 / u_box.z * 2.0 * p_arama, abs(x - bestT))), res); o = res; }

//== framecheck
INCLUDE(_hist)
uniform sampler2D s_klip; uniform float p_klipOn, p_benzerliEsig, p_donmaAltSini, p_cikti;
// Ardışık karelerin benzerliği: art arda en az N kare neredeyse aynıysa donma (mavi), ani düşüşte kesme (kırmızı) işareti
float sim(float a, float c) { float d = 0.0; for (int j = 0; j < 5; j++) for (int i = 0; i < 5; i++) { vec2 uv = (vec2(i, j) + 0.5) / 5.0; d += length(hist(a, uv).rgb - hist(c, uv).rgb); } return 1.0 - d / 25.0 / 1.732; }
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 2.0) { o = s; return; } float th = p_benzerliEsig / 100.0; float run = 0.0; for (int k = 0; k < 15; k++) { if (float(k + 1) >= n) break; if (sim(float(k), float(k + 1)) >= th) run += 1.0; else break; }
  bool frozen = run + 1.0 >= p_donmaAltSini; bool cut = sim(0.0, 1.0) < 0.55; vec2 b = boxUV(here()); float border = step(min(min(b.x, 1.0 - b.x), min(b.y, 1.0 - b.y)), 0.025); vec4 res = s;
  if (frozen && p_cikti != 1.0) res = mix(res, vec4(0.25, 0.5, 1.0, 1.0), border * 0.9 + 0.12); if (cut && p_cikti != 0.0) res = mix(res, vec4(1.0, 0.25, 0.2, 1.0), border * 0.9 + 0.15); o = res; }

//== texturecut
uniform sampler2D s_hedef; uniform float p_hedefOn, p_dokuOlce, p_ilerleme, p_eslesmeEsig;
// Hedefe geçiş: yerel dokusu (yama ortalaması ve kontrastı) iki görüntüde benzer bölgeler önce değişir
vec2 stat(bool tgt, vec2 b, float r) { float m = 0.0, m2 = 0.0; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 q = b + vec2(i, j) * r; float l = tgt ? (p_hedefOn > 0.5 ? luma(texture(s_hedef, q).rgb) : 1.0 - lumAt(boxPx(q))) : lumAt(boxPx(q)); m += l; m2 += l * l; } m /= 9.0; return vec2(m, sqrt(max(m2 / 9.0 - m * m, 0.0))); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float r = p_dokuOlce * u_s / max(u_box.z, 1.0); vec2 a = stat(false, b, r), c = stat(true, b, r); float simv = 1.0 - clamp(length(a - c) * 3.0, 0.0, 1.0);
  float order = mix(1.0 - simv, hash1(floor(b * 40.0)), 0.15); float th = p_eslesmeEsig / 100.0; order = simv >= th ? order * 0.5 : 0.5 + order * 0.5; float k = smoothstep(order - 0.04, order + 0.04, p_ilerleme / 100.0);
  vec4 t = p_hedefOn > 0.5 ? texture(s_hedef, b) : vec4(1.0 - unpre(s), 1.0) * s.a; o = mix(s, t, k); }

//== behindobject
uniform sampler2D s_onPlanMask, s_hedefKlip; uniform float p_onPlanMaskOn, p_hedefKlipOn, p_ilerleme, p_kenarPayi;
// Silme geçişi ön plan nesnesinin arkasından geçer: hedef klip soldan açılır, maske bölgesi (genişletilmiş) üstte kalır
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec4 t = p_hedefKlipOn > 0.5 ? texture(s_hedefKlip, b) : vec4(hueRotate(unpre(s), 180.0) * s.a, s.a); float e = p_ilerleme / 100.0 * 1.2 - 0.1;
  float wipe = smoothstep(e + 0.02, e - 0.02, b.x); float m = 0.0; if (p_onPlanMaskOn > 0.5) { float r = p_kenarPayi / max(u_box.z, 1.0) * u_s; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) m = max(m, texture(s_onPlanMask, b + vec2(i, j) * r).a); }
  vec4 bg = mix(s, t, wipe); o = mix(bg, s, m); }

//== screeninscreen
uniform sampler2D s_hedefKlip; uniform float p_hedefKlipOn, p_ekranKose, p_ilerleme;
// İlk görüntünün içindeki ekran (merkezde dörtgen) ikinci klibi gösterir; ilerledikçe kamera ekrana yaklaşır ve ekran tuvali doldurur
void main() { vec2 b = boxUV(here()); float k = smoothstep(0.0, 1.0, p_ilerleme / 100.0); vec2 slo = vec2(0.3, 0.32), shi = vec2(0.7, 0.62); vec2 vlo = mix(vec2(0.0), slo, k), vhi = mix(vec2(1.0), shi, k);
  vec2 uv = vlo + b * (vhi - vlo); vec2 sb = (uv - slo) / (shi - slo);
  if (all(greaterThanEqual(sb, vec2(0.0))) && all(lessThanEqual(sb, vec2(1.0)))) { vec4 t = p_hedefKlipOn > 0.5 ? texture(s_hedefKlip, sb) : vec4(vec3(0.2, 0.6, 1.0) * (0.6 + 0.4 * sb.y), 1.0);
    float frame = 1.0 - step(0.015, min(min(sb.x, 1.0 - sb.x), min(sb.y, 1.0 - sb.y))); o = mix(t, vec4(0.05, 0.05, 0.06, 1.0), frame * (1.0 - k)); } else o = texPx(boxPx(uv)); }

//== depthtransition
uniform sampler2D s_hedefKlip, s_derinlik; uniform float p_hedefKlipOn, p_derinlikOn, p_ilerleme, p_katmanGeci, p_sirayiTersCevi;
// Derinlik (kaynak ya da parlaklık; parlak = yakın) sırasıyla açılış: önce yakın yüzeyler, sonra uzaklar hedef kliple değişir
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float d = p_derinlikOn > 0.5 ? luma(texture(s_derinlik, b).rgb) : luma(unpre(s)); float order = p_sirayiTersCevi > 0.5 ? d : 1.0 - d; float g = max(p_katmanGeci / 100.0, 0.01);
  float k = smoothstep(order - g, order + g, p_ilerleme / 100.0 * (1.0 + 2.0 * g) - g); vec4 t = p_hedefKlipOn > 0.5 ? texture(s_hedefKlip, b) : vec4(vec3(0.15, 0.4, 0.9) * (0.5 + 0.5 * b.y), 1.0); o = mix(s, t, k); }

//== hingemosaic
uniform sampler2D s_hedef; uniform float p_hedefOn, p_satir, p_sutun, p_gecikme, p_ilerleme;
// Pano ızgarası: her pano menteşesi (sol kenarı) çevresinde 180° döner; köşegen sırayla gecikmeli; ön yüz katman, arka yüz hedef
void main() { vec2 b = boxUV(here()); vec2 N = vec2(max(floor(p_sutun), 1.0), max(floor(p_satir), 1.0)); vec2 id = floor(b * N); vec2 f = fract(b * N); float order = (id.x + id.y) / (N.x + N.y - 1.0);
  float d = p_gecikme / 100.0; float k = clamp((p_ilerleme / 100.0 * (1.0 + d) - order * d) / 1.0, 0.0, 1.0); float a = k * 3.14159; float w = cos(a); vec4 res = vec4(0.0);
  if (w >= 0.0) { if (f.x <= w) { vec2 uv = (id + vec2(f.x / max(w, 1e-3), f.y)) / N; res = texPx(boxPx(uv)) * (0.75 + 0.25 * w); } }
  else { float ww = -w; if (f.x <= ww) { vec2 uv = (id + vec2(f.x / max(ww, 1e-3), f.y)) / N; res = (p_hedefOn > 0.5 ? texture(s_hedef, uv) : vec4(0.2, 0.55, 1.0, 1.0)) * (0.75 + 0.25 * ww); } }
  o = res; }

//== routewindow
uniform sampler2D s_hedef; uniform vec4 p_dv4[16]; float dvAt(int i) { return i < 0 || i >= 64 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_hedefOn, p_dvN, p_pencereGeni, p_ilerleme, p_iziKaliTut;
// Pencere rota boyunca ilerler (motor: rota şeklinin noktaları), içinde hedef görünür; iz açık kalabilir
vec2 P(float u) { int N = p_dvN > 1.5 ? int(p_dvN / 2.0) : 0; if (N < 2) { float a = u * 6.2832; return vec2(cos(a) * boxU().x * 0.3 * u, sin(a) * boxU().y * 0.3 * u); } float f = u * float(N - 1); int i = int(floor(f)); return mix(vec2(dvAt(i * 2), dvAt(i * 2 + 1)), vec2(dvAt(min(i + 1, N - 1) * 2), dvAt(min(i + 1, N - 1) * 2 + 1)), fract(f)); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = p_pencereGeni * 0.5; float pr = p_ilerleme / 100.0; float m = 0.0;
  if (p_iziKaliTut > 0.5) { for (int k = 0; k <= 40; k++) { float u = float(k) / 40.0 * pr; m = max(m, 1.0 - smoothstep(R - 1.0, R + 1.0, length(q - P(u)))); } } else m = 1.0 - smoothstep(R - 1.0, R + 1.0, length(q - P(pr)));
  vec4 t = p_hedefOn > 0.5 ? texture(s_hedef, boxUV(here())) : vec4(hueRotate(unpre(s), 140.0) * s.a, s.a); o = mix(s, t, m * step(0.001, pr)); }

//== multitimepanel
INCLUDE(_hist)
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_pencere, p_zamanNokt, p_bosluk;
// Pano: N pencere, her biri klibin farklı bir anı (motor: kare şeridi)
void main() { vec2 b = boxUV(here()); float N = clamp(floor(p_pencere), 2.0, 16.0); float n = histN(); float cols = ceil(sqrt(N)); float rows = ceil(N / cols); vec2 id = floor(b * vec2(cols, rows)); vec2 f = fract(b * vec2(cols, rows)); float idx = id.y * cols + id.x;
  float g = p_bosluk * u_s / u_box.z * cols; if (idx >= N || any(lessThan(f, vec2(g))) || any(greaterThan(f, vec2(1.0 - g)))) { o = vec4(0.0); return; } vec2 uv = (f - g) / (1.0 - 2.0 * g);
  o = n >= 1.0 ? hist(min(idx, n - 1.0), uv) : texPx(boxPx(uv)); }

//== frametimes
INCLUDE(_hist)
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_zamanOlce, p_uzunKareIsar, p_uyariEsig;
// Alt şeritte son karelerin süreleri: art arda aynı kalan kareler tek uzun kare sayılır; uyarı eşiğini aşanlar kırmızı
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float n = histN(); if (b.y < 0.86 || n < 2.0) { o = s; return; } vec4 res = overPre(vec4(0.04, 0.05, 0.08, 0.85), s);
  float x = 1.0 - b.x; float idx = floor(x * (n - 1.0)); float run = 1.0; for (int k = 0; k < 15; k++) { if (float(k) >= n - 1.0) break; float d = 0.0; for (int j = 0; j < 3; j++) for (int i = 0; i < 3; i++) { vec2 uv = (vec2(i, j) + 0.5) / 3.0; d += length(hist(float(k), uv).rgb - hist(float(k + 1), uv).rgb); }
    if (float(k) >= idx && d < 0.02) run += 1.0; else if (float(k) >= idx) break; }
  float ms = run * 1000.0 / 30.0; float h = clamp(ms / max(p_uyariEsig * 2.0, 1.0), 0.05, 1.0); bool warn = p_uzunKareIsar > 0.5 && ms > p_uyariEsig; float yb = 0.98 - h * 0.1;
  if (b.y > yb && fract(x * (n - 1.0)) > 0.12) res = vec4(warn ? vec3(1.0, 0.3, 0.25) : vec3(0.35, 0.85, 0.5), 1.0); o = res; }

//== cutcolormatch
uniform sampler2D s_komsuKlip; uniform float p_komsuKlipOn, p_analiz, p_gecis, p_guc;
// Kesimden (katman başı) sonra geçiş süresi içinde, katmanın renk ortalaması/sapması komşu klibe doğru taşınır ve geri bırakılır
void main() { vec4 s = texture(u_tex, v_uv); if (p_komsuKlipOn < 0.5 || s.a <= 0.0) { o = s; return; } vec3 ma = vec3(0.0), mb = vec3(0.0), va = vec3(0.0), vb = vec3(0.0);
  for (int j = 0; j < 6; j++) for (int i = 0; i < 6; i++) { vec2 uv = (vec2(i, j) + 0.5) / 6.0; vec3 a = unpre(texPx(boxPx(uv))), c = unpre(texture(s_komsuKlip, uv)); ma += a; mb += c; va += a * a; vb += c * c; }
  ma /= 36.0; mb /= 36.0; vec3 sa = sqrt(max(va / 36.0 - ma * ma, 1e-5)), sb = sqrt(max(vb / 36.0 - mb * mb, 1e-5)); float k = (1.0 - smoothstep(0.0, max(p_gecis, 0.01), u_t)) * p_guc / 100.0;
  vec3 c = unpre(s); vec3 m = (c - ma) / sa * sb + mb; o = pre(clamp(mix(c, m, k), 0.0, 1.0), s.a); }

//== safeareacheck
uniform sampler2D s_onemliBolg; uniform float p_onemliBolgOn, p_oranlar, p_guvenPayi, p_ihlalUyar;
// 9:16, 1:1 ve 4:5 kırpma kılavuzları (güven payıyla); önemli bölge (kaynak alfa) bir kılavuzun dışına taşıyorsa kırmızı
float frameFor(vec2 b, float ar, float pad) { float W = u_box.z, H = u_box.w; vec2 sz = W / H > ar ? vec2(ar * H / W, 1.0) : vec2(1.0, W / (ar * H)); sz *= 1.0 - pad * 2.0; vec2 d = abs(b - 0.5) - sz * 0.5; return max(d.x, d.y); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float pad = p_guvenPayi / 100.0; vec4 res = s; float imp = p_onemliBolgOn > 0.5 ? texture(s_onemliBolg, b).a : 0.0; float viol = 0.0;
  for (int i = 0; i < 3; i++) { float ar = i == 0 ? 9.0 / 16.0 : (i == 1 ? 1.0 : 0.8); float d = frameFor(b, ar, pad); vec3 c = i == 0 ? vec3(0.3, 0.8, 1.0) : (i == 1 ? vec3(1.0, 0.85, 0.3) : vec3(0.6, 1.0, 0.5));
    res = overPre(vec4(c, 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.z, abs(d))), res); if (d > 0.0 && imp > 0.5) viol = 1.0; }
  if (p_ihlalUyar > 0.5) res = mix(res, vec4(1.0, 0.2, 0.2, 1.0), viol * 0.55); o = res; }

//== seamlessfix
uniform float p_kenarSeri, p_eksen, p_dokuKoru, p_tekrarOniz;
// Döşenebilir doku: kenara yaklaştıkça görüntünün yarım tur kaydırılmış kopyası öne geçer (sarmal sürekli); doku koruma geçişi keskinleştirir; önizlemede 2×2 tekrar
vec4 img(vec2 b) { return texPx(boxPx(fract(b))); }
void main() { vec2 b = boxUV(here()); if (p_tekrarOniz > 0.5) b = fract(b * 2.0); vec2 e = vec2(p_kenarSeri * u_s) / u_box.zw; float sharp = mix(1.0, 3.0, p_dokuKoru / 100.0);
  float wx = p_eksen != 1.0 ? pow(1.0 - smoothstep(0.0, e.x, min(b.x, 1.0 - b.x)), sharp) : 0.0; float wy = p_eksen != 0.0 ? pow(1.0 - smoothstep(0.0, e.y, min(b.y, 1.0 - b.y)), sharp) : 0.0;
  vec4 c = img(b); c = mix(c, img(b + vec2(0.5, 0.0)), wx); vec4 cy = mix(img(b), img(b + vec2(0.0, 0.5)), wy); o = mix(c, cy, wy / max(wx + wy, 1e-4) * step(1e-4, wy)); }

//== flowconsistency
INCLUDE(_hist)
uniform sampler2D s_duzenlemMask; uniform float p_duzenlemMaskOn, p_baglilik, p_komsu, p_okluzyonEsig;
// Düzenlenmiş bölgede (maske ya da tüm katman) şimdiki kare, komşu karelerin ortalamasına bağlılık oranında çekilir; büyük farkta (örtülme) bağlanmaz
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 2.0) { o = s; return; } float m = p_duzenlemMaskOn > 0.5 ? texture(s_duzenlemMask, boxUV(here())).a : 1.0; vec4 acc = vec4(0.0); float w = 0.0;
  for (int k = 1; k < 9; k++) { if (float(k) >= min(n, p_komsu + 1.0)) break; vec4 c = hist(float(k), v_uv); if (length(c.rgb - s.rgb) > p_okluzyonEsig / 100.0 + 0.02) continue; acc += c; w += 1.0; }
  if (w <= 0.0) { o = s; return; } o = mix(s, acc / w, m * p_baglilik / 100.0); }

//== loopscanner
INCLUDE(_hist)
INCLUDE(_chart)
uniform float p_enKisaSure, p_enUzun, p_aday, p_hareketAgir;
// Şimdiki kare ile en kısa…en uzun süre sonraki kareler (motor: kare şeridi) karşılaştırılır; benzerlik çubukları, en iyi aday yeşil, süre etiketi
float simK(float k) { float d = 0.0; for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) { vec2 uv = (vec2(i, j) + 0.5) / 4.0; d += length(hist(0.0, uv).rgb - hist(k, uv).rgb); } return 1.0 - d / 16.0 / 1.732; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float n = histN(); if (n < 2.0 || b.y < 0.7) { o = s; return; } vec4 res = overPre(vec4(0.04, 0.05, 0.08, 0.8), s); float K = n - 1.0; float best = -1.0, bk = 1.0;
  for (int k = 1; k < 16; k++) { if (float(k) > K) break; float v = simK(float(k)); if (v > best) { best = v; bk = float(k); } }
  float k = floor(b.x * K) + 1.0; float v = simK(k); float h = clamp((v - 0.5) * 2.0, 0.02, 1.0); if (b.y > 0.98 - h * 0.2 && fract(b.x * K) > 0.15) res = vec4(k == bk ? vec3(0.3, 1.0, 0.45) : vec3(0.5, 0.6, 0.8), 1.0);
  float dur = p_enKisaSure + (p_enUzun - p_enKisaSure) * (bk - 1.0) / max(K - 1.0, 1.0); vec2 lp = (b - vec2(0.12, 0.75)) / vec2(0.03, 0.035); res = overPre(vec4(1.0) * numAt(lp, dur * 10.0), res); o = res; }

//== multiscreen
INCLUDE(_chart)
uniform float p_ekran, p_duzen, p_cercevePayi, p_ekranNuma;
// Kompozisyon ekranlara bölünür (yatay, dikey ya da ızgara); ekranlar arası çerçeve payı içeriği gerçek koordinatta keser; isteğe bağlı numara
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float N = max(floor(p_ekran), 1.0); vec2 grid = p_duzen < 0.5 ? vec2(ceil(sqrt(N)), ceil(N / ceil(sqrt(N)))) : (p_duzen < 1.5 ? vec2(N, 1.0) : vec2(1.0, N));
  vec2 id = floor(b * grid); vec2 f = fract(b * grid); float idx = id.y * grid.x + id.x; vec2 g = p_cercevePayi * u_s / u_box.zw * grid * 0.5;
  if (idx >= N || any(lessThan(f, g)) || any(greaterThan(f, 1.0 - g))) { o = vec4(0.03, 0.03, 0.04, 1.0); return; } vec4 res = s;
  if (p_ekranNuma > 0.5) { vec2 lp = (f - vec2(0.1, 0.12)) / vec2(0.06, 0.08) / grid.yx * grid.y; res = overPre(vec4(1.0, 0.85, 0.3, 1.0) * numAt((f - vec2(0.12, 0.14)) * vec2(grid.x / grid.y, 1.0) / 0.06, idx + 1.0), res); } o = res; }

//== focustrack
uniform sampler2D s_derinlik; uniform vec4 p_dv4[1]; float dvAt(int i) { return i < 0 || i >= 4 ? 0.0 : p_dv4[0][i]; }
uniform float p_derinlikOn, p_dvN, p_tepki, p_oncelik;
// Odak düzlemi hedefin bulunduğu noktadaki derinlik (motor: hedef konumu); derinlik farkı kadar disk bulanıklığı
float D(vec2 px) { return p_derinlikOn > 0.5 ? luma(texture(s_derinlik, boxUV(px)).rgb) : lumAt(px); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 tg = p_dvN > 1.5 ? fromUnit(vec2(dvAt(0), dvAt(1))) : boxPx(vec2(0.5 + 0.3 * sin(u_t * 0.7), 0.5)); float fd = D(tg); float dd = abs(D(here()) - fd);
  float R = dd * 14.0 * u_s * p_oncelik / 100.0; if (R < 0.6) { o = s; return; } vec4 acc = vec4(0.0); for (int i = 0; i < 16; i++) { float a = float(i) * 2.39996; float r = sqrt((float(i) + 0.5) / 16.0) * R; acc += texPx(here() + vec2(cos(a), sin(a)) * r); } o = acc / 16.0; }

//== edgeextend2
INCLUDE(_hist)
uniform float p_genislet, p_aramaKare, p_kenarGeci, p_yoksaSeffBira;
// Kutunun dışındaki pay: komşu karelerde orada görünen içerik (kare şeridi) yoksa kenardan uzatılmış bulanık renk; kenarda yumuşak geçiş
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 inb = clamp(b, 0.0, 1.0); float out2 = length((b - inb) * u_box.zw); if (out2 <= 0.0) { o = s; return; } if (out2 > p_genislet * u_s) { o = vec4(0.0); return; }
  vec4 acc = vec4(0.0); float w = 0.0; float n = histN(); for (int k = 0; k < 9; k++) { if (float(k) >= n) break; vec4 c = hist(float(k), v_uv); if (c.a > 0.5) { acc += c; w += 1.0; } }
  vec4 ext = vec4(0.0); for (int i = 0; i < 6; i++) ext += texPx(boxPx(inb) - normalize(b - inb + 1e-6) * float(i) * 3.0 * u_s); ext /= 6.0;
  vec4 c = w > 0.0 ? acc / w : (p_yoksaSeffBira > 0.5 ? vec4(0.0) : ext); float fade = 1.0 - smoothstep(0.0, max(p_kenarGeci * u_s, 1.0) + p_genislet * u_s * 0.5, out2) * 0.6; o = c * fade; }

//== stroboscope
INCLUDE(_hist)
uniform sampler2D s_nesneMask; uniform float p_nesneMaskOn, p_poz, p_zamanAral, p_arkaPlanSabi;
// Sabit kamerada nesnenin geçmiş konumları: her eski kare, sabit arka plandan (şeridin medyanına yakın) farklı olduğu yerde üst üste konur
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 2.0) { o = s; return; } vec4 bg = s; if (p_arkaPlanSabi > 0.5) { vec4 a = hist(0.0, v_uv), c = hist(n - 1.0, v_uv), d = hist(floor(n * 0.5), v_uv); bg = (a + c + d) / 3.0; }
  vec4 res = s; for (int k = 1; k < 16; k++) { if (float(k) >= n) break; vec4 c = hist(float(k), v_uv); float m = p_nesneMaskOn > 0.5 ? texture(s_nesneMask, v_uv).a : smoothstep(0.08, 0.2, length(c.rgb - bg.rgb)); float cur = smoothstep(0.08, 0.2, length(s.rgb - bg.rgb));
    res = mix(res, c, m * (1.0 - cur) * (1.0 - float(k) / n * 0.4)); } o = res; }
