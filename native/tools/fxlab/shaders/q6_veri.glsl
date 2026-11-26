// 1000 rehberi bölüm 6 (913–934): metin, harita ve veri grafikleri (veri: metin katmanındaki satırlar → p_dv; yoksa örnek tablo)
//== glyphsplit
uniform sampler2D s_palet; uniform float p_paletOn, p_bolme, p_aci, p_bolmeBosl;
// Harfler açılı iç çizgilerle şeritlere bölünür; her şerit paletten (ya da ton döngüsünden) renk alır; şerit arası boşluk saydam
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float a = radians(p_aci); vec2 d = vec2(cos(a), sin(a)); float H = u_box.w / max(p_bolme, 2.0); float x = dot(here() - boxCenter(), d) / H;
  float k = floor(x); float f = fract(x); float N = max(p_bolme, 2.0); float idx = mod(k, N); vec3 c = p_paletOn > 0.5 ? texture(s_palet, vec2((idx + 0.5) / N, 0.5)).rgb : hsv2rgb(vec3(idx / N * 0.8 + 0.55, 0.65, 1.0));
  float gap = p_bolmeBosl * u_s / H; float m = gap > 0.0 ? smoothstep(0.0, 0.02, f - gap * 0.5) * smoothstep(0.0, 0.02, 1.0 - gap * 0.5 - f) : 1.0; o = vec4(c * s.a, s.a) * m; }

//== strokewrite
uniform float p_sira, p_ilerleme, p_kalemKali, p_orijinalGlifBirl;
// Harf iskeleti: iç uzaklığın tepe çizgisi; kalem kalınlığında iz, yazılma sırası (soldan sağa ya da yukarıdan aşağı) ilerlemeyle; sonda asıl harf belirir
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = vec4(0.0); return; } vec2 p = here(); float R = u_box.w * 0.25; float d = innerDist(p, R); float m = d;
  for (int i = 0; i < 8; i++) { float a = float(i) / 8.0 * TAU; m = max(m, innerDist(p + vec2(cos(a), sin(a)) * max(d * 0.7, 1.0), R)); }
  float pen = step(m - p_kalemKali * u_s * 0.5, d); vec2 b = boxUV(p); float ord = p_sira < 0.5 ? b.x * 0.85 + b.y * 0.15 : b.y * 0.85 + b.x * 0.15; float pr = p_ilerleme / 100.0;
  float shown = pen * smoothstep(pr + 0.01, pr - 0.01, ord); float glyph = p_orijinalGlifBirl > 0.5 ? smoothstep(0.85, 1.0, pr) : 0.0; o = s * max(shown, glyph); }

//== propsymbols
INCLUDE(_chart)
uniform float p_enKucuSimg, p_enBuyu, p_olcek, p_cakismayOnle;
// Satır: x %, y %, değer → orantılı daire (alan ya da yarıçap); küçükler üstte
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float M = 1e-6; int N = int(min(dR(), 64.0)); for (int r = 0; r < 64; r++) { if (r >= N) break; M = max(M, abs(dat(float(r), 2.0))); }
  vec4 res = s; float bestR = 1e9; for (int r = 0; r < 64; r++) { if (r >= N) break; vec2 c = vec2(dat(float(r), 0.0), dat(float(r), 1.0)) / 100.0; float k = abs(dat(float(r), 2.0)) / M; k = p_olcek < 0.5 ? sqrt(k) : k;
    float R = mix(p_enKucuSimg, p_enBuyu, k) * u_s; float d = length((b - c) * u_box.zw); if (d > R + 1.5) continue; if (p_cakismayOnle > 0.5 && R > bestR) continue; bestR = R;
    float a = 1.0 - smoothstep(R - 1.0, R + 0.5, d); float rim = 1.0 - smoothstep(0.8, 2.0, abs(d - R + 1.0)); res = overPre(vec4(mix(vec3(1.0, 0.45, 0.25) * 0.75, vec3(1.0), rim), 1.0) * max(a * 0.75, rim), res); }
  o = res; }

//== flowlines
INCLUDE(_chart)
uniform float p_kalinlik, p_okHizi, p_bagEgri, p_ciftYon;
// Satır: x1 %, y1 %, x2 %, y2 %, değer → yay (jeodezik) ya da düz çizgi; kalınlık değerle, üzerinde akan ok işaretleri
vec2 bez(vec2 a, vec2 c, vec2 b, float t) { return mix(mix(a, c, t), mix(c, b, t), t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = here(); int N = int(min(dR(), 32.0)); float M = 1e-6; for (int r = 0; r < 32; r++) { if (r >= N) break; M = max(M, abs(dat(float(r), 4.0))); } vec4 res = s;
  for (int r = 0; r < 32; r++) { if (r >= N) break; vec2 A = boxPx(vec2(dat(float(r), 0.0), dat(float(r), 1.0)) / 100.0), B = boxPx(vec2(dat(float(r), 2.0), dat(float(r), 3.0)) / 100.0); if (dC() < 5.0) { A = boxPx(vec2(0.15 + 0.1 * float(r), 0.75)); B = boxPx(vec2(0.85 - 0.08 * float(r), 0.3)); }
    vec2 C = (A + B) * 0.5 + (p_bagEgri < 0.5 ? vec2(-(B - A).y, (B - A).x) * 0.25 : vec2(0.0)); float w = max(abs(dat(float(r), 4.0)) / M * p_kalinlik * u_s, 1.0) * 0.5; float bd = 1e5, bt = 0.0; vec2 pv = A;
    for (int k = 1; k <= 20; k++) { float t = float(k) / 20.0; vec2 pt = bez(A, C, B, t); vec2 ab = pt - pv; float tt = clamp(dot(q - pv, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); float d = length(q - pv - ab * tt); if (d < bd) { bd = d; bt = (float(k - 1) + tt) / 20.0; } pv = pt; }
    if (bd > w + 1.5) continue; float L = length(B - A); float ph = fract(bt * L / max(24.0 * u_s, 1.0) - u_t * p_okHizi / 24.0); float ph2 = fract(bt * L / max(24.0 * u_s, 1.0) + u_t * p_okHizi / 24.0 + 0.5);
    float arrow = smoothstep(0.55, 0.6, ph) * (1.0 - smoothstep(0.85, 0.9, ph)); if (p_ciftYon > 0.5) arrow = max(arrow, smoothstep(0.55, 0.6, ph2) * (1.0 - smoothstep(0.85, 0.9, ph2)) * 0.8);
    float a = 1.0 - smoothstep(w - 0.8, w + 0.8, bd); res = overPre(vec4(mix(vec3(0.25, 0.65, 1.0), vec3(1.0), arrow * 0.8), 0.85) * a, res); }
  o = res; }

//== regionmerge
uniform sampler2D s_bolgeGeom; uniform float p_bolgeGeomOn, p_tolerans, p_icSiniSakl;
// Bölge haritasındaki iç sınır çizgileri (dolgunun içindeki ince koyu çizgiler) komşu dolgu rengiyle kapatılır; dış sınır korunur
vec4 G(vec2 px) { return p_bolgeGeomOn > 0.5 ? texture(s_bolgeGeom, boxUV(px)) : texPx(px); }
float line(vec4 c, vec4 ref) { return c.a > 0.5 && luma(unpre(c)) < luma(unpre(ref)) - 0.18 - p_tolerans * 0.02 ? 1.0 : 0.0; }
void main() { vec4 s = G(here()); if (s.a < 0.5) { o = s; return; } vec4 best = s; float bl = 9.0; vec4 avg = vec4(0.0); float n = 0.0; bool inside = true;
  for (int i = 0; i < 8; i++) { float a = float(i) / 8.0 * TAU; vec2 d = vec2(cos(a), sin(a)); for (int k = 1; k <= 6; k++) { vec4 c = G(here() + d * float(k) * u_s); if (c.a < 0.5) { inside = false; break; } float l = luma(unpre(c)); if (l > luma(unpre(s)) + 0.15) { avg += c; n += 1.0; break; } } }
  if (!inside || n < 2.0 || luma(unpre(s)) > 0.45) { o = s; return; } vec4 fill = avg / n; o = p_icSiniSakl > 0.5 ? mix(fill, s, 0.25 * step(0.5, fract((here().x + here().y) / (6.0 * u_s)))) : fill; }

//== coastbands
uniform sampler2D s_kiyiVekt; uniform vec3 c_denizReng; uniform float p_kiyiVektOn, p_bant, p_aralik, p_karaBand;
// Kara (kaynak alfa ya da katmanın kendi alfası) çevresinde denize doğru eşit aralıklı kıyı bantları; isteğe bağlı karada da
float land(vec2 px) { return p_kiyiVektOn > 0.5 ? texture(s_kiyiVekt, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float G = p_aralik * u_s; float M = G * p_bant; bool L = land(p) > 0.5; float d = 1e5;
  for (int i = 0; i < 16; i++) { float a = float(i) / 16.0 * TAU; for (int k = 1; k <= 24; k++) { float r = float(k) / 24.0 * M; if ((land(p + vec2(cos(a), sin(a)) * r) > 0.5) != L) { d = min(d, r); break; } } }
  if (d > M) { o = L ? s : vec4(c_denizReng * 0.8, 1.0) * (p_kiyiVektOn > 0.5 ? 1.0 : 0.0) + s * (1.0 - (p_kiyiVektOn > 0.5 ? 1.0 : 0.0)); return; }
  float band = floor(d / G); float edge = 1.0 - smoothstep(0.0, 1.2 * u_s, abs(fract(d / G) - 0.0) * G);
  if (!L) { vec3 c = mix(c_denizReng * 1.5, c_denizReng * 0.8, band / max(p_bant, 1.0)); o = vec4(mix(c, vec3(1.0), edge * 0.35), 1.0); }
  else if (p_karaBand > 0.5) { o = vec4(mix(unpre(s), vec3(0.85, 0.82, 0.6), (1.0 - band / max(p_bant, 1.0)) * 0.35) * s.a, s.a); } else o = s; }

//== watershed
uniform sampler2D s_yuksekli; uniform vec2 p_cikis; uniform vec3 c_havza; uniform float p_yuksekliOn, p_akisEsig;
// Yükseklik (kaynak ya da parlaklık): her piksel eğim boyunca aşağı yürür; ulaştığı çukura göre havza rengi; çıkış noktasına akan havza vurgulanır; vadilerde akarsu
float E(vec2 px) { return p_yuksekliOn > 0.5 ? luma(texture(s_yuksekli, boxUV(px)).rgb) : lumAt(px); }
vec2 sink(vec2 px) { vec2 p = px; float st = 3.0 * u_s; for (int k = 0; k < 40; k++) { vec2 g = vec2(E(p + vec2(st, 0.0)) - E(p - vec2(st, 0.0)), E(p + vec2(0.0, st)) - E(p - vec2(0.0, st))); if (length(g) < 1e-4) break; p -= normalize(g) * st; } return p; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); vec2 sk = floor(sink(p) / (24.0 * u_s)); vec2 so = floor(sink(fromUnit(p_cikis)) / (24.0 * u_s));
  vec3 bc = hsv2rgb(vec3(hash1(sk), 0.35, 0.9)); bool mine = sk == so; vec3 base = unpre(s); float e = E(p); float lap = E(p + vec2(4.0 * u_s, 0.0)) + E(p - vec2(4.0 * u_s, 0.0)) + E(p + vec2(0.0, 4.0 * u_s)) + E(p - vec2(0.0, 4.0 * u_s)) - 4.0 * e;
  float river = smoothstep(0.02, 0.06, lap * (100.0 / max(p_akisEsig, 1.0)) * 2.0 + lap); vec3 c = mix(base, mine ? c_havza : bc, mine ? 0.55 : 0.3); c = mix(c, vec3(0.15, 0.45, 0.95), river * 0.8); o = pre(c, max(s.a, 0.0)); }

//== cartogram
INCLUDE(_chart)
uniform float p_yineleme, p_kenarKoru, p_ilerleme;
// Satır: x %, y %, değer → merkez çevresinde alan değerle (√oran) büyür/küçülür; yumuşak ağırlıklı yer değiştirme alanı, kenarlar korunur
void main() { vec2 b = boxUV(here()); int N = int(min(dR(), 32.0)); float mean = 0.0; for (int r = 0; r < 32; r++) { if (r >= N) break; mean += abs(dat(float(r), 2.0)); } mean = max(mean / float(max(N, 1)), 1e-6);
  vec2 off = vec2(0.0); for (int r = 0; r < 32; r++) { if (r >= N) break; vec2 c = vec2(dat(float(r), 0.0), dat(float(r), 1.0)) / 100.0; float k = sqrt(abs(dat(float(r), 2.0)) / mean) - 1.0; vec2 d = b - c; float w = exp(-dot(d, d) / 0.02); off -= d * k * w * 0.6; }
  float edge = min(min(b.x, 1.0 - b.x), min(b.y, 1.0 - b.y)); off *= mix(1.0, smoothstep(0.0, 0.2, edge), p_kenarKoru / 100.0); o = texPx(boxPx(b + off * p_ilerleme / 100.0)); }

//== daynight
uniform float p_tarih[3]; uniform float p_tarihN, p_utcSaat, p_alacakar, p_geceOpak;
// Eşdikdörtgen dünya haritası: tarih → güneş sapması, UTC saat → güneş altı boylam; güneş yüksekliğine göre gece ve alacakaranlık
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float lon = (b.x - 0.5) * 360.0, lat = (0.5 - b.y) * 180.0; float Y = p_tarihN > 0.5 ? abs(p_tarih[0]) : 2026.0; float Mo = p_tarihN > 1.5 ? abs(p_tarih[1]) : 1.0; float D = p_tarihN > 2.5 ? abs(p_tarih[2]) : 1.0;
  float doy = floor(275.0 * Mo / 9.0) - (Mo > 2.0 ? (mod(Y, 4.0) == 0.0 ? 1.0 : 2.0) : 0.0) * floor((Mo + 9.0) / 12.0) + D - 30.0; float dec = -23.44 * cos(6.28318 / 365.0 * (doy + 10.0)); float slon = (12.0 - p_utcSaat) * 15.0;
  float alt = degrees(asin(clamp(sin(radians(lat)) * sin(radians(dec)) + cos(radians(lat)) * cos(radians(dec)) * cos(radians(lon - slon)), -1.0, 1.0)));
  float night = smoothstep(0.0, -max(p_alacakar, 0.1), alt); float term = 1.0 - smoothstep(0.0, 0.8, abs(alt)); vec3 c = mix(s.rgb, s.rgb * vec3(0.25, 0.3, 0.55), night * p_geceOpak / 100.0); c += vec3(1.0, 0.7, 0.3) * term * 0.25 * s.a; o = vec4(c, s.a); }

//== distcircles
INCLUDE(_chart)
uniform vec2 p_merkez; uniform float p_mesafe, p_cember, p_mesafeEtik;
// Eşdikdörtgen harita üzerinde gerçek büyük çember uzaklığı (km) ile eş uzaklık halkaları; halka üstünde mesafe etiketi
float gc(vec2 a, vec2 b) { vec2 r1 = radians(a), r2 = radians(b); float h = pow(sin((r2.y - r1.y) * 0.5), 2.0) + cos(r1.y) * cos(r2.y) * pow(sin((r2.x - r1.x) * 0.5), 2.0); return 2.0 * 6371.0 * asin(min(1.0, sqrt(h))); }
vec2 ll(vec2 b) { return vec2((b.x - 0.5) * 360.0, (0.5 - b.y) * 180.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 c = ll(boxUV(fromUnit(p_merkez))); float d = gc(c, ll(b)); float step2 = max(p_mesafe, 1.0) * 10.0; float k = d / step2; float res2 = 0.0; vec4 res = s;
  if (k < p_cember + 0.5) { float fw = fwidth(k) + 1e-5; res2 = 1.0 - smoothstep(0.0, fw * 1.5, abs(k - floor(k + 0.5))); res2 *= step(0.5, k); }
  res = overPre(vec4(1.0, 0.85, 0.3, 1.0) * res2, res); res = overPre(vec4(1.0, 0.3, 0.25, 1.0) * (1.0 - smoothstep(3.0, 4.5, length((b - boxUV(fromUnit(p_merkez))) * u_box.zw))), res);
  if (p_mesafeEtik > 0.5) for (int i = 1; i <= 20; i++) { if (float(i) > p_cember) break; float latN = c.y + degrees(float(i) * step2 / 6371.0); if (latN > 89.0) break; vec2 lb = vec2(c.x / 360.0 + 0.5, 0.5 - latN / 180.0);
    vec2 lp = (b - lb - vec2(0.0, -0.025)) * u_box.zw / (8.0 * u_s); res = overPre(vec4(1.0) * numAt(lp, float(i) * step2), res); }
  o = res; }

//== mapswipe
uniform sampler2D s_haritaSuru, s_haritaSuru_1, s_haritaSuru_2; uniform float p_haritaSuruOn, p_haritaSuru_1On, p_haritaSuru_2On, p_kesit, p_sinirCizg, p_koordinaKili;
// Aynı koordinattaki harita sürümleri dikey kesitlerle yan yana: katmanın kendisi ilk sürüm, seçilenler sonrakiler
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float n = 1.0 + p_haritaSuruOn + p_haritaSuru_1On + p_haritaSuru_2On; if (n < 1.5) { o = s; return; }
  float k = p_kesit / 100.0; float x = n < 2.5 ? (b.x < k ? 0.0 : 1.0) : floor(clamp(b.x + (k - 0.5) / n, 0.0, 0.999) * n); vec4 c = s;
  if (x > 0.5 && x < 1.5) c = texture(s_haritaSuru, b); else if (x > 1.5 && x < 2.5) c = texture(s_haritaSuru_1, b); else if (x > 2.5) c = texture(s_haritaSuru_2, b);
  float bx = n < 2.5 ? abs(b.x - k) : abs(fract(b.x * n + (k - 0.5)) - 0.0) / n; float line = 1.0 - smoothstep(p_sinirCizg * u_s * 0.5 / u_box.z, p_sinirCizg * u_s * 0.5 / u_box.z + 1.0 / u_box.z, bx); o = overPre(vec4(1.0) * line * step(0.1, p_sinirCizg), c); }

//== waterfall
INCLUDE(_chart)
uniform vec3 c_arti, c_eksi; uniform float p_bosluk, p_toplamSutu;
// İlk sütun değişimler: her çubuk önceki birikimden yeni birikime; artı/eksi renkli; sonda toplam sütunu
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); int N = int(min(dR(), 40.0)); float slots = float(N) + (p_toplamSutu > 0.5 ? 1.0 : 0.0); float cum = 0.0, mn = 0.0, mx = 0.0;
  for (int r = 0; r < 40; r++) { if (r >= N) break; cum += dat(float(r), 0.0); mn = min(mn, cum); mx = max(mx, cum); } float rng = max(mx - mn, 1e-6); float x = (b.x - 0.05) / 0.9 * slots; int i = int(floor(x)); float f = fract(x);
  float gap = p_bosluk / 200.0; vec4 res = s; float y0 = 0.9 - (0.0 - mn) / rng * 0.8; res = overPre(vec4(vec3(0.7), 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.w, abs(b.y - y0))), res);
  if (b.x < 0.05 || b.x > 0.95 || f < gap || f > 1.0 - gap) { o = res; return; } float a = 0.0, c2 = 0.0; cum = 0.0; vec3 col = c_arti;
  for (int r = 0; r < 40; r++) { if (r >= N) break; float v = dat(float(r), 0.0); if (r == i) { a = cum; c2 = cum + v; col = v >= 0.0 ? c_arti : c_eksi; } cum += v; }
  if (i == N && p_toplamSutu > 0.5) { a = 0.0; c2 = cum; col = vec3(0.3, 0.55, 1.0); } if (i > N || (i == N && p_toplamSutu < 0.5)) { o = res; return; }
  float ya = 0.9 - (a - mn) / rng * 0.8, yb = 0.9 - (c2 - mn) / rng * 0.8; o = (b.y >= min(ya, yb) && b.y <= max(ya, yb)) ? vec4(col, 1.0) : res; }

//== boxplot
INCLUDE(_chart)
uniform float p_biyikKats, p_ucNoktGost, p_kutuGeni;
// Her sütun bir seri: çeyrekler (sıra sayımıyla), medyan, bıyıklar (katsayı × IQR, veriyle sınırlı) ve uç değer noktaları
float qv(int c, float q, int N) { float target = q * float(N - 1); float best = 0.0; float bd = 1e9; for (int r = 0; r < 64; r++) { if (r >= N) break; float v = dat(float(r), float(c)); float below = 0.0, eq = 0.0;
    for (int k = 0; k < 64; k++) { if (k >= N) break; float w = dat(float(k), float(c)); below += step(w, v - 1e-9); eq += step(abs(w - v), 1e-9); } float d = target < below ? below - target : (target > below + eq - 1.0 ? target - (below + eq - 1.0) : 0.0); if (d < bd) { bd = d; best = v; } } return best; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); int C = int(min(dC(), 6.0)); int N = int(min(dR(), 64.0)); float mn = 1e9, mx = -1e9; for (int c = 0; c < 6; c++) { if (c >= C) break; for (int r = 0; r < 64; r++) { if (r >= N) break; float v = dat(float(r), float(c)); mn = min(mn, v); mx = max(mx, v); } }
  float rng = max(mx - mn, 1e-6); int ci = int(floor(b.x * float(C))); if (ci < 0 || ci >= C) { o = s; return; } float cx = (float(ci) + 0.5) / float(C); float hw = p_kutuGeni * u_s / u_box.z * 0.5;
  float q1 = qv(ci, 0.25, N), md = qv(ci, 0.5, N), q3 = qv(ci, 0.75, N); float iqr = q3 - q1; float lo = q1 - p_biyikKats * iqr, hi = q3 + p_biyikKats * iqr; float wl = 1e9, wh = -1e9;
  for (int r = 0; r < 64; r++) { if (r >= N) break; float v = dat(float(r), float(ci)); if (v >= lo) wl = min(wl, v); if (v <= hi) wh = max(wh, v); }
  float px = 1.0 / u_box.z, py = 1.0 / u_box.w; vec4 res = s; vec3 col = serCol(float(ci), vec3(0.25, 0.55, 1.0));
  float y1 = 0.9 - (q1 - mn) / rng * 0.8, y3 = 0.9 - (q3 - mn) / rng * 0.8, ym = 0.9 - (md - mn) / rng * 0.8, yl = 0.9 - (wl - mn) / rng * 0.8, yh = 0.9 - (wh - mn) / rng * 0.8;
  if (abs(b.x - cx) < hw && b.y > y3 && b.y < y1) res = vec4(col * 0.85, 1.0); if (abs(b.x - cx) < hw && abs(b.y - ym) < py * 1.5) res = vec4(1.0);
  if (abs(b.x - cx) < px * 1.2 && ((b.y > yh && b.y < y3) || (b.y > y1 && b.y < yl))) res = vec4(col, 1.0); if (abs(b.x - cx) < hw * 0.5 && (abs(b.y - yl) < py * 1.2 || abs(b.y - yh) < py * 1.2)) res = vec4(col, 1.0);
  if (p_ucNoktGost > 0.5) for (int r = 0; r < 64; r++) { if (r >= N) break; float v = dat(float(r), float(ci)); if (v >= lo && v <= hi) continue; float yy = 0.9 - (v - mn) / rng * 0.8; if (length(vec2((b.x - cx) * u_box.z, (b.y - yy) * u_box.w)) < 3.0 * u_s) res = vec4(1.0, 0.4, 0.3, 1.0); }
  o = res; }

//== sunburst
INCLUDE(_chart)
uniform float p_icYari, p_derinlik, p_bosluk, p_etiket;
// İçten dışa halkalar: halka d = veri sütunu d; satırların değerleri açıyı böler; renk satırdan, dışa doğru açılır
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R0 = p_icYari; float Rm = min(boxU().x, boxU().y) * 0.46; int D = int(min(min(dC(), p_derinlik), 12.0)); float th = (Rm - R0) / float(max(D, 1)); float r = length(q);
  if (r < R0 || r > Rm) { o = s; return; } int d = int(floor((r - R0) / th)); if (d >= D) { o = s; return; } float ang = mod(atan(q.y, q.x) + 6.2832, 6.2832); int N = int(min(dR(), 32.0)); float tot = 0.0;
  for (int i = 0; i < 32; i++) { if (i >= N) break; tot += abs(dat(float(i), float(d))); } float acc = 0.0; int hit = -1; float a0 = 0.0, a1 = 0.0;
  for (int i = 0; i < 32; i++) { if (i >= N) break; float w = abs(dat(float(i), float(d))) / max(tot, 1e-6) * 6.2832; if (ang >= acc && ang < acc + w) { hit = i; a0 = acc; a1 = acc + w; } acc += w; }
  if (hit < 0) { o = s; return; } float gap = radians(p_bosluk) * 0.5; float rgap = 1.0 / u_s; if (ang < a0 + gap || ang > a1 - gap || fract((r - R0) / th) * th < rgap) { o = s; return; }
  vec3 c = serCol(float(hit), vec3(0.25, 0.55, 1.0)); c = mix(c, vec3(1.0), float(d) / float(max(D, 1)) * 0.45); vec4 res = vec4(c, 1.0);
  if (p_etiket > 0.5 && d == 0) { float am = (a0 + a1) * 0.5; vec2 lp = (q - vec2(cos(am), sin(am)) * (R0 + th * 0.5)) / (th * 0.18); res = overPre(vec4(1.0) * numAt(lp, (a1 - a0) / 6.2832 * 100.0), res); } o = res; }

//== gantt
INCLUDE(_chart)
uniform float p_satirYuks, p_ilerleme, p_bagimlilCizg;
// Satır: başlangıç, bitiş, [bağlı olduğu satır no] → çubuklar; zaman ekseni ilerlemeyle açılır; bağımlılık okları
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); int N = int(min(dR(), 24.0)); float t0 = 1e9, t1 = -1e9; for (int r = 0; r < 24; r++) { if (r >= N) break; t0 = min(t0, dat(float(r), 0.0)); t1 = max(t1, dat(float(r), 1.0)); }
  float span = max(t1 - t0, 1e-6); float H = p_satirYuks * u_s / u_box.w; float now = t0 + span * p_ilerleme / 100.0; vec4 res = s;
  float xn = 0.08 + (now - t0) / span * 0.86; res = overPre(vec4(1.0, 0.3, 0.3, 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.z, abs(b.x - xn))) * 0.8, res);
  int r = int(floor((b.y - 0.06) / H)); if (r >= 0 && r < N) { float fy = fract((b.y - 0.06) / H); float a = dat(float(r), 0.0), e = min(dat(float(r), 1.0), now); float xa = 0.08 + (a - t0) / span * 0.86, xe = 0.08 + (e - t0) / span * 0.86;
    if (fy > 0.18 && fy < 0.82 && b.x >= xa && b.x <= xe) res = vec4(serCol(float(r), vec3(0.25, 0.55, 1.0)), 1.0); }
  if (p_bagimlilCizg > 0.5 && dC() > 2.5) for (int i = 0; i < 24; i++) { if (i >= N) break; float dep = dat(float(i), 2.0) - 1.0; if (dep < 0.0 || dep >= float(N) || dep == float(i)) continue; float xe = 0.08 + (dat(dep, 1.0) - t0) / span * 0.86, xs = 0.08 + (dat(float(i), 0.0) - t0) / span * 0.86;
    float ye = 0.06 + (dep + 0.5) * H, ys = 0.06 + (float(i) + 0.5) * H; float vline = step(abs(b.x - xe), 1.0 / u_box.z) * step(min(ye, ys), b.y) * step(b.y, max(ye, ys)); float hline = step(abs(b.y - ys), 1.0 / u_box.w) * step(min(xe, xs), b.x) * step(b.x, max(xe, xs));
    res = overPre(vec4(vec3(0.85), 1.0) * max(vline, hline), res); }
  o = res; }

//== dotdensity
INCLUDE(_chart)
uniform float p_noktaDege, p_noktaCapi, p_tohum;
// Satır: x %, y %, değer → değer / nokta değeri kadar eşit nokta, konum çevresinde diske tohumlu dağılır (katmanın alfası içinde)
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = here(); int N = int(min(dR(), 32.0)); float sp = max(p_noktaCapi * 2.5, 4.0) * u_s; vec2 id = floor(q / sp); float v = 0.0;
  for (int r = 0; r < 32; r++) { if (r >= N) break; vec2 c = boxPx(vec2(dat(float(r), 0.0), dat(float(r), 1.0)) / 100.0); float cnt = min(abs(dat(float(r), 2.0)) / max(p_noktaDege, 1e-6) * 1000.0, 2000.0); float R = sqrt(cnt) * sp * 0.6;
    if (length(q - c) > R + sp) continue; float dens = cnt / max(3.14159 * R * R / (sp * sp), 1.0);
    for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 cell = id + vec2(i, j); vec2 pt = (cell + 0.2 + hash2(cell + p_tohum + float(r) * 7.1) * 0.6) * sp; if (length(pt - c) > R || hash1(cell * 1.3 + float(r) + p_tohum) > dens) continue;
      if (texPx(pt).a < 0.3 && s.a > 0.0) continue; v = max(v, 1.0 - smoothstep(p_noktaCapi * u_s * 0.5 - 0.7, p_noktaCapi * u_s * 0.5 + 0.7, length(q - pt))); } }
  o = overPre(vec4(0.95, 0.35, 0.25, 1.0) * v, s); }
