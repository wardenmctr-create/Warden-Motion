// 1000 rehberi bölüm 4 (869–890): geometri, desen ve matematiksel çizim
//== celticknot
uniform vec3 c_renk; uniform float p_tekrar, p_ipGeni, p_kesisimBosl, p_dugum;
// Köşegen iki iplik ailesi; her kesişimde dama düzenine göre üst/alt; alttaki iplik, üstün kenarında boşluk alır. Bölge kare ya da daire, kenarda döngü
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()) - 0.5; float N = max(p_tekrar, 2.0); vec2 g = b * N; vec2 r = vec2(g.x + g.y, g.x - g.y) * 0.70710678;
  float cellPx = min(u_box.z, u_box.w) / N * 0.7071; float w = p_ipGeni * u_s / max(cellPx, 1.0) * 0.5; float gap = p_kesisimBosl * u_s / max(cellPx, 1.0);
  float du = abs(fract(r.x) - 0.5), dv = abs(fract(r.y) - 0.5); float onU = 1.0 - smoothstep(w - 0.03, w, du), onV = 1.0 - smoothstep(w - 0.03, w, dv);
  float over = mod(floor(r.x) + floor(r.y), 2.0); float a = 0.0; vec3 col = c_renk;
  if (onU > 0.0 && onV > 0.0) { // kesişim: üstteki iplik tam, alttaki boşluk
    float topD = over > 0.5 ? du : dv; a = 1.0 - smoothstep(w - 0.03, w, topD); col *= 1.0 - 0.35 * smoothstep(w * 0.4, w, topD); }
  else if (onU > 0.0) { a = onU * (over < 0.5 ? smoothstep(w + gap * 0.0, w + gap + 0.04, dv) : 1.0); col *= 1.0 - 0.35 * smoothstep(w * 0.4, w, du); }
  else if (onV > 0.0) { a = onV * (over > 0.5 ? smoothstep(w, w + gap + 0.04, du) : 1.0); col *= 1.0 - 0.35 * smoothstep(w * 0.4, w, dv); }
  float bound = p_dugum < 0.5 ? max(abs(b.x), abs(b.y)) : length(b) * 1.15; a *= 1.0 - smoothstep(0.43, 0.45, bound);
  float rim = (1.0 - smoothstep(w * 0.5 / N, w / N, abs(bound - 0.44))) * step(0.0, 1.0); a = max(a, rim * 0.0); o = overPre(vec4(col, 1.0) * a, s); }

//== fourierdraw
uniform vec4 p_dv4[44]; float dvAt(int i) { return i < 0 || i >= 176 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_harmonik, p_ilerleme, p_dairelerGost, p_cizgi;
// Motor: harmoniklerle yeniden kurulmuş eğri (64 nokta) ve dönen dairelerin merkez/yarıçapları; veri yoksa örnek epicycle
vec2 P(int i) { if (p_dvN > 1.5) return vec2(dvAt(i * 2), dvAt(i * 2 + 1)); float u = float(i) / 63.0 * max(p_ilerleme / 100.0, 0.02) * 6.2832; return vec2(cos(u) * 50.0 + cos(3.0 * u) * 18.0, sin(u) * 50.0 - sin(3.0 * u) * 18.0); }
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float lw = max(p_cizgi, 0.2) * 0.5; float aa = 0.8 / u_s; float d = 1e5;
  for (int i = 0; i < 63; i++) d = min(d, seg(q, P(i), P(i + 1))); float v = 1.0 - smoothstep(lw - aa, lw + aa, d); vec4 res = overPre(vec4(1.0, 0.85, 0.3, 1.0) * v, s);
  if (p_dairelerGost > 0.5) { float c = 0.0; if (p_dvN > 1.5) { for (int k = 0; k < 16; k++) { vec2 cc = vec2(dvAt(128 + k * 3), dvAt(129 + k * 3)); float r = dvAt(130 + k * 3); if (r <= 0.0) continue; c = max(c, (1.0 - smoothstep(0.4, 0.4 + aa * 2.0, abs(length(q - cc) - r))) * 0.55); } }
    else { c = (1.0 - smoothstep(0.4, 0.4 + aa * 2.0, abs(length(q) - 50.0))) * 0.55; } res = overPre(vec4(0.6, 0.8, 1.0, 1.0) * c, res); }
  o = res; }

//== superformula
uniform float p_simetri, p_yuvarlak, p_koseUssu, p_yaricap, p_dolgu;
// Gielis süperformülü r(φ) = (|cos(mφ/4)|^n2 + |sin(mφ/4)|^n3)^(−1/n1); dolgu açıkken katman şeklin içinde görünür, kapalıyken kontur
float sf(float ph) { float m = p_simetri; float n1 = max(p_yuvarlak, 0.05), n2 = max(p_koseUssu, 0.05); float a = pow(abs(cos(m * ph / 4.0)), n2) + pow(abs(sin(m * ph / 4.0)), n2); return pow(max(a, 1e-6), -1.0 / n1); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float ph = atan(q.y, q.x); float mx = 0.0; for (int i = 0; i < 32; i++) mx = max(mx, sf(float(i) / 32.0 * 6.2832)); float R = sf(ph) / max(mx, 1e-4) * p_yaricap;
  float d = length(q) - R; float aa = 1.0 / u_s; vec4 inside = s.a > 0.0 ? s : vec4(0.2, 0.55, 1.0, 1.0);
  if (p_dolgu > 0.5) o = inside * (1.0 - smoothstep(-aa, aa, d)); else o = vec4(1.0) * (1.0 - smoothstep(1.0, 1.0 + aa * 2.0, abs(d))); }

//== evolute
uniform vec4 p_dv4[64]; float dvAt(int i) { return i < 0 || i >= 256 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_tur, p_ilerleme, p_cizgi;
// Motor: temel eğri (soluk) + evolüt/involüt eğrisi, ilerlemeye kadar
vec2 A(int i) { if (p_dvN > 1.5) return vec2(dvAt(i * 2), dvAt(i * 2 + 1)); float u = float(i) / 64.0 * 6.2832; return vec2(cos(u) * 70.0, sin(u) * 40.0); }
vec2 B(int i) { if (p_dvN > 1.5) return vec2(dvAt(128 + i * 2), dvAt(129 + i * 2)); float u = float(i) / 64.0 * 6.2832; float c = 70.0 * 70.0 - 40.0 * 40.0; return p_tur < 0.5 ? vec2(c / 70.0 * pow(cos(u), 3.0), -c / 40.0 * pow(sin(u), 3.0)) : A(i) - vec2(-sin(u), cos(u)) * u * 12.0; }
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float lw = max(p_cizgi, 0.2) * 0.5; float aa = 0.8 / u_s; float d0 = 1e5, d1 = 1e5; int lim = int(p_ilerleme / 100.0 * 63.0);
  for (int i = 0; i < 64; i++) { d0 = min(d0, seg(q, A(i), A((i + 1) % 64))); if (i < lim) d1 = min(d1, seg(q, B(i), B(i + 1))); }
  vec4 res = overPre(vec4(0.7, 0.75, 0.85, 1.0) * (1.0 - smoothstep(lw * 0.6 - aa, lw * 0.6 + aa, d0)) * 0.6, s); o = overPre(vec4(1.0, 0.5, 0.3, 1.0) * (1.0 - smoothstep(lw - aa, lw + aa, d1)), res); }

//== offsetfamily
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_ofsetSayi, p_aralik, p_kose, p_kesisimiTemi;
// Kaynak (ya da katman) silüetinin dışına eşit aralıklı paralel konturlar; yuvarlak köşe = öklid, keskin = sonsuz norm
float A(vec2 px) { return p_kaynakOn > 0.5 ? texture(s_kaynak, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); if (A(p) > 0.5) { o = s; return; } float G = p_aralik * u_s; float M = G * min(p_ofsetSayi, 64.0) + G; float d = 1e5;
  for (int i = 0; i < 24; i++) { float a = float(i) / 24.0 * TAU; vec2 dd = vec2(cos(a), sin(a)); if (p_kose > 0.5) dd /= max(abs(dd.x), abs(dd.y)); for (int k = 1; k <= 40; k++) { float r = float(k) / 40.0 * M; if (A(p + dd * r) > 0.5) { d = min(d, r * (p_kose > 0.5 ? 1.0 : 1.0)); break; } } }
  if (d > M - G * 0.5) { o = s; return; } float f = d / G; float line = 1.0 - smoothstep(0.06, 0.06 + 1.5 * u_s / G, abs(f - floor(f + 0.5))); line *= step(0.5, f);
  o = overPre(vec4(0.2, 0.55, 1.0, 1.0) * line, s); }

//== envelope
uniform float p_dogru, p_aciDegi, p_zarfCizg, p_yardimciDogr;
// Doğru ailesi n(φ)·x = h(φ), h(φ) = R(0.6 + 0.4 cos kφ); zarf E(φ) = h n + h' n⊥. Yardımcı doğrular soluk
float hF(float ph, float R, float k) { return R * (0.6 + 0.4 * cos(k * ph)); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = min(boxU().x, boxU().y) * 0.38; float k = max(p_aciDegi / 60.0, 0.0) + 1.0; float aa = 0.8 / u_s; vec4 res = s;
  if (p_yardimciDogr > 0.5) { float N = max(p_dogru, 4.0); float ln = 0.0; for (int i = 0; i < 400; i++) { if (float(i) >= N) break; float ph = float(i) / N * 6.2832 + u_t * 0.1; vec2 n = vec2(cos(ph), sin(ph)); ln = max(ln, 1.0 - smoothstep(0.3, 0.3 + aa, abs(dot(q, n) - hF(ph, R, k)))); } res = overPre(vec4(0.6, 0.7, 0.9, 1.0) * ln * 0.35, res); }
  float d = 1e5; vec2 prev = vec2(0.0); for (int i = 0; i <= 128; i++) { float ph = float(i) / 128.0 * 6.2832 + u_t * 0.1; vec2 n = vec2(cos(ph), sin(ph)), tn = vec2(-n.y, n.x); float h = hF(ph, R, k), dh = -R * 0.4 * k * sin(k * ph); vec2 e = h * n + dh * tn;
    if (i > 0) { vec2 ab = e - prev; float t = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); d = min(d, length(q - prev - ab * t)); } prev = e; }
  o = overPre(vec4(1.0, 0.75, 0.3, 1.0) * (1.0 - smoothstep(p_zarfCizg * 0.5 - aa, p_zarfCizg * 0.5 + aa, d)), res); }

//== rotsym
uniform vec2 p_merkez; uniform float p_sektor, p_simetri, p_kaynakSektGost;
// Tek sektör (0..2π/N) döndürülerek (ya da yansıtılarak) tüm daireye çoğaltılır
void main() { vec2 q = toUnit(here()) - p_merkez; float N = max(floor(p_sektor), 2.0); float a = atan(q.y, q.x); float W = 6.2832 / N; float k = floor(a / W); float f = a - k * W;
  if (p_simetri > 0.5 && mod(k, 2.0) > 0.5) f = W - f; vec2 src = vec2(cos(f), sin(f)) * length(q) + p_merkez; vec4 c = texU(src);
  if (p_kaynakSektGost > 0.5) { float e = min(abs(a), abs(a - W)) * length(q); c = mix(c, vec4(1.0, 0.8, 0.2, 1.0), (1.0 - smoothstep(0.5, 1.5, e * u_s)) * step(-0.01, a) * step(a, W + 0.01)); } o = c; }

//== aperiodicplace
uniform sampler2D s_sekiller; uniform float p_sekillerOn, p_adet, p_bosluk, p_boyutDegi, p_tohum;
// Seyrek ızgara (adete göre) + hücre içi rastgele konum; hücre başına tek şekil → çakışma yok; boyut değişkenliği ve dönme tohumlu
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cell = sqrt(boxU().x * boxU().y / max(p_adet, 1.0)); vec2 id0 = floor(q / cell); vec4 res = s;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = id0 + vec2(i, j); vec2 h = hash2(id + p_tohum * 0.137); float sz = cell * 0.5 * (1.0 - p_boyutDegi / 100.0 * hash1(id + 9.1 + p_tohum)) - p_bosluk;
    if (sz <= 0.5) continue; vec2 c = (id + 0.5 + (h - 0.5) * (1.0 - 2.0 * sz / cell) ) * cell; vec2 d = rot2(h.x * 360.0) * (q - c) / sz;
    if (any(greaterThan(abs(d), vec2(1.0)))) continue; vec4 sh = p_sekillerOn > 0.5 ? texture(s_sekiller, d * 0.5 + 0.5) : vec4(hsv2rgb(vec3(hash1(id + 2.2), 0.55, 0.95)), 1.0) * (1.0 - smoothstep(0.92, 1.0, length(d)));
    res = overPre(sh, res); } o = res; }

//== weightedstipple
uniform sampler2D s_yogunlukKayn; uniform float p_yogunlukKaynOn, p_nokta, p_yineleme, p_noktaCapi;
// Koyuluğa göre nokta: ince ızgara + tohumlu titreme; yineleme arttıkça titreme azalır (daha düzenli aralık)
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0 && p_yogunlukKaynOn < 0.5) { o = s; return; } vec2 q = toUnit(here()); float cell = sqrt(boxU().x * boxU().y / max(p_nokta, 10.0)) * 0.5; vec2 id0 = floor(q / cell);
  float jit = 0.45 / sqrt(max(p_yineleme, 1.0)) + 0.05; float v = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = id0 + vec2(i, j); vec2 c = (id + 0.5 + (hash2(id) - 0.5) * jit * 2.0) * cell; vec4 src = p_yogunlukKaynOn > 0.5 ? texture(s_yogunlukKayn, boxUV(fromUnit(c))) : texU(c);
    float dark = 1.0 - luma(unpre(src)); if (hash1(id + 3.3) > dark * 1.1) continue; v = max(v, 1.0 - smoothstep(p_noktaCapi * 0.5 - 0.6 / u_s, p_noktaCapi * 0.5 + 0.6 / u_s, length(q - c))); }
  vec3 paper = vec3(0.97, 0.96, 0.93); o = vec4(mix(paper, vec3(0.06), v), 1.0) * max(s.a, p_yogunlukKaynOn); }

//== circlepack
uniform sampler2D s_sinir; uniform float p_sinirOn, p_enKucuYari, p_enBuyu, p_doluluk, p_tohum;
// Üç ölçekte çember: büyükler önce, küçükler yalnız büyüklerin örtmediği yerde; sınır içinde ve kenara taşmadan; renk katmandan
float B(vec2 u) { return p_sinirOn > 0.5 ? texture(s_sinir, boxUV(fromUnit(u))).a : texU(u).a; }
vec3 cand(vec2 id, float L, float R) { vec2 h = hash2(id + L * 17.0 + p_tohum * 0.31); float cellS = R * 2.2; vec2 c = (id + 0.5 + (h - 0.5) * 0.25) * cellS; float r = R * (0.75 + 0.25 * hash1(id + L + 5.0));
  float ok = step(hash1(id * 1.7 + L + p_tohum), p_doluluk / 100.0) * step(0.5, B(c)) * step(0.5, B(c + vec2(r, 0.0))) * step(0.5, B(c - vec2(r, 0.0))) * step(0.5, B(c + vec2(0.0, r))) * step(0.5, B(c - vec2(0.0, r)));
  return vec3(c, ok > 0.5 ? r : -1.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R0 = p_enBuyu, R2 = max(p_enKucuYari, 1.0), R1 = sqrt(R0 * R2); vec4 res = vec4(0.0); float covered = 0.0;
  for (int L = 0; L < 3; L++) { float R = L == 0 ? R0 : (L == 1 ? R1 : R2); vec2 id0 = floor(q / (R * 2.2));
    for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec3 c = cand(id0 + vec2(i, j), float(L), R); if (c.z <= 0.0) continue;
      // daha büyük ölçekteki çemberlerle çakışıyorsa atla
      bool hit = false; for (int P = 0; P < 2; P++) { if (P >= L) break; float RP = P == 0 ? R0 : R1; vec2 pid = floor(c.xy / (RP * 2.2)); for (int jj = -1; jj <= 1; jj++) for (int ii = -1; ii <= 1; ii++) { vec3 pc = cand(pid + vec2(ii, jj), float(P), RP); if (pc.z > 0.0 && length(pc.xy - c.xy) < pc.z + c.z + 1.0) hit = true; } }
      if (hit) continue; float d = length(q - c.xy) - c.z; float a = 1.0 - smoothstep(-0.8 / u_s, 0.8 / u_s, d); if (a <= 0.0) continue; vec4 col = texU(c.xy); res = vec4(unpre(col) * (0.85 + 0.15 * (1.0 - length(q - c.xy) / c.z)), 1.0) * a; covered = 1.0; } }
  o = covered > 0.0 ? res : vec4(0.0); }

//== cellnetwork
uniform sampler2D s_kaynakHucrAgi; uniform float p_kaynakHucrAgiOn, p_kenarKali, p_kavsakYuva, p_kapaliDisCevr;
// Hücre ağı çizgileri (kaynak katman, koyu çizgiler ya da üretilmiş Voronoi) kalınlaştırılır; kavşaklarda yuvarlatma
float L(vec2 px) { if (p_kaynakHucrAgiOn > 0.5) return texture(s_kaynakHucrAgi, boxUV(px)).a; vec4 c = texPx(px); if (c.a > 0.5 && luma(unpre(c)) < 0.3) return 1.0; vec4 v = voronoi(toUnit(px) / 40.0); return step(v.y - v.x, 0.03); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float W = p_kenarKali * u_s * 0.5; float J = p_kavsakYuva * u_s; float d = 1e5; float cnt = 0.0;
  for (int i = 0; i < 16; i++) { float a = float(i) / 16.0 * TAU; for (int k = 0; k <= 10; k++) { float r = float(k) / 10.0 * (W + J); if (L(p + vec2(cos(a), sin(a)) * r) > 0.5) { d = min(d, r); if (r < W + J) cnt += 1.0; break; } } }
  float jw = W + J * smoothstep(8.0, 14.0, cnt); float a = 1.0 - smoothstep(jw - 0.8, jw + 0.8, d); vec2 b = boxUV(p); if (p_kapaliDisCevr > 0.5) a = max(a, 1.0 - smoothstep(W / u_box.z * 2.0, W / u_box.z * 2.0 + 0.004, min(min(b.x, 1.0 - b.x), min(b.y, 1.0 - b.y))));
  o = overPre(vec4(0.08, 0.1, 0.14, 1.0) * a, s); }

//== streamlines
uniform sampler2D s_vektorAlan; uniform float p_vektorAlanOn, p_cizgiAral, p_uzunluk, p_adim;
// Vektör alanı (kaynak RG ya da parlaklık eğiminin dikine) boyunca seyrek tohum noktalarının integral eğrileri → eşit aralıklı akış çizgileri (LIC)
vec2 F(vec2 px) { if (p_vektorAlanOn > 0.5) { vec2 r = texture(s_vektorAlan, boxUV(px)).rg * 2.0 - 1.0; return length(r) > 0.02 ? normalize(r) : vec2(1.0, 0.0); } vec2 g = lumGrad(px, 3.0); return length(g) > 1e-4 ? normalize(vec2(-g.y, g.x)) : normalize(vec2(1.0, 0.3)); }
float seed(vec2 px) { float G = max(p_cizgiAral * u_s, 2.0); vec2 c = floor(px / G); vec2 h = hash2(c); vec2 sp = (c + 0.2 + h * 0.6) * G; return 1.0 - smoothstep(0.6, 1.4, length(px - sp)); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float st = max(p_adim * u_s, 0.5); int n = int(min(p_uzunluk * u_s / st, 48.0)); float v = seed(p); vec2 a = p, b = p;
  for (int k = 0; k < 48; k++) { if (k >= n) break; a += F(a) * st; b -= F(b) * st; v = max(v, max(seed(a), seed(b)) * (1.0 - float(k) / float(n) * 0.3)); }
  o = overPre(vec4(vec3(0.95), 1.0) * v, vec4(s.rgb * 0.55, s.a)); }

//== densitycontour
uniform sampler2D s_yogunluk; uniform float p_yogunlukOn, p_seviye, p_yumusatm, p_dolguBant;
// Yumuşatılmış yoğunluk (kaynak alfa ya da koyuluk) eş değer eğrileri; isteğe bağlı renkli bantlar
float D(vec2 px) { if (p_yogunlukOn > 0.5) return texture(s_yogunluk, boxUV(px)).a; vec4 c = texPx(px); return (1.0 - luma(unpre(c))) * c.a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float R = max(p_yumusatm * u_s, 1.0); float d = 0.0, w = 0.0; for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { float g = exp(-float(i * i + j * j) / 8.0); d += D(p + vec2(i, j) / 3.0 * R) * g; w += g; } d /= w;
  float N = max(p_seviye, 2.0); float f = d * N; float fw = fwidth(f) + 1e-4; float line = 1.0 - smoothstep(0.0, fw * 1.5, abs(fract(f + 0.5) - 0.5));
  vec4 res = s; if (p_dolguBant > 0.5) res = vec4(hsv2rgb(vec3(0.66 - floor(f) / N * 0.66, 0.6, 0.95)), 1.0); o = overPre(vec4(0.05, 0.05, 0.08, 1.0) * line, res); }

//== forceflow
uniform vec2 p_kaynak, p_hedef; uniform float p_guc, p_akisNokt, p_hiz;
// Kaynak–kuyu potansiyel akışı: akım fonksiyonu ψ = θ1 − θ2 (akım çizgileri), potansiyel φ = ln(r1/r2); noktalar φ boyunca akar
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 d1 = q - p_kaynak, d2 = q - p_hedef; float psi = atan(d1.y, d1.x) - atan(d2.y, d2.x); float phi = log(max(length(d1), 0.5) / max(length(d2), 0.5)) * sign(p_guc + 1e-6);
  float N = clamp(p_akisNokt / 6.0, 2.0, 120.0); float lane = psi / 6.2832 * N; float ln = abs(fract(lane) - 0.5); float spd = p_hiz * abs(p_guc) * 0.01;
  float pos = fract(phi * 2.0 - u_t * spd + hash1(vec2(floor(lane), 1.0))); float dotv = (1.0 - smoothstep(0.06, 0.12, ln)) * (1.0 - smoothstep(0.04, 0.12, abs(pos - 0.5)));
  float guide = (1.0 - smoothstep(0.02, 0.05, ln)) * 0.18; float src = 1.0 - smoothstep(3.0, 4.0, min(length(d1), length(d2)));
  o = overPre(vec4(vec3(0.6, 0.85, 1.0), 1.0) * clamp(dotv + guide + src, 0.0, 1.0), s); }

//== plotfunc
uniform vec4 p_dv4[33]; float dvAt(int i) { return i < 0 || i >= 132 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_xOlce, p_ilerleme, p_teget;
// Motor: ifadenin 128 örneği (x ∈ [−2π·ölçek, 2π·ölçek]) ve en büyük |f|; eksenler, ilerlemeye kadar eğri, uçta teğet
float fy(float u) { if (p_dvN > 1.5) { float f = clamp(u, 0.0, 1.0) * 127.0; int i = int(floor(f)); return mix(dvAt(i), dvAt(min(i + 1, 127)), fract(f)) / max(dvAt(128), 1e-6); } float x = (u * 2.0 - 1.0) * 6.2832 * p_xOlce; return sin(x); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 g = vec2(b.x, 0.5 - b.y) ; float aa = 1.5 / u_box.w; vec4 res = s;
  float axes = (1.0 - smoothstep(0.0, aa, abs(g.y))) + (1.0 - smoothstep(0.0, aa * u_box.w / u_box.z, abs(b.x - 0.5))); res = overPre(vec4(vec3(0.7), 1.0) * clamp(axes, 0.0, 1.0) * 0.6, res);
  float lim = p_ilerleme / 100.0; float y = fy(b.x) * 0.42; float du = 1.0 / u_box.z; float sl = (fy(b.x + du) - fy(b.x - du)) * 0.42 / (2.0 * du) * u_box.z / u_box.w; float d = abs(g.y - y) / sqrt(1.0 + sl * sl);
  float c = (1.0 - smoothstep(aa, aa * 2.5, d)) * step(b.x, lim); res = overPre(vec4(1.0, 0.75, 0.3, 1.0) * c, res);
  if (p_teget > 0.5 && lim > 0.0) { float y0 = fy(lim) * 0.42; float s0 = (fy(lim + du) - fy(lim - du)) * 0.42 / (2.0 * du); float ly = y0 + s0 * (b.x - lim); float td = abs(g.y - ly) / sqrt(1.0 + s0 * s0 * u_box.z * u_box.z / (u_box.w * u_box.w));
    res = overPre(vec4(0.4, 0.8, 1.0, 1.0) * (1.0 - smoothstep(aa * 0.6, aa * 1.6, td)) * step(abs(b.x - lim), 0.15), res); res = overPre(vec4(1.0) * (1.0 - smoothstep(aa * 2.0, aa * 3.5, length((vec2(b.x, g.y) - vec2(lim, y0)) * vec2(u_box.z / u_box.w, 1.0)))), res); }
  o = res; }

//== escapepath
uniform vec2 p_baslangi; uniform float p_yineleme, p_kacisSini, p_cizgi;
// c başlangıç noktası (kutu → karmaşık düzlem [−2,1]×[−1.5,1.5]); z ← z² + c yolunun noktaları ve çizgileri; arkada soluk Mandelbrot
vec2 toC(vec2 u) { vec2 b = u / boxU() + 0.5; return vec2(-2.0 + b.x * 3.0, (0.5 - b.y) * 3.0); }
vec2 toU(vec2 c) { vec2 b = vec2((c.x + 2.0) / 3.0, 0.5 - c.y / 3.0); return (b - 0.5) * boxU(); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 cp = toC(q); vec2 z = vec2(0.0); float it = 0.0; for (int i = 0; i < 48; i++) { z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + cp; if (dot(z, z) > 4.0) break; it += 1.0; }
  vec4 res = overPre(vec4(vec3(0.25, 0.35, 0.6) * (it >= 48.0 ? 0.6 : it / 48.0), 1.0) * 0.55, s); vec2 c = toC(p_baslangi); z = vec2(0.0); vec2 prev = toU(z); float d = 1e5, dd = 1e5; float esc = p_kacisSini * p_kacisSini;
  for (int i = 0; i < 200; i++) { if (float(i) >= p_yineleme) break; z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c; vec2 cur = toU(z); vec2 ab = cur - prev; float t = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); d = min(d, length(q - prev - ab * t)); dd = min(dd, length(q - cur)); prev = cur; if (dot(z, z) > esc) break; }
  float aa = 0.8 / u_s; res = overPre(vec4(1.0, 0.8, 0.3, 1.0) * (1.0 - smoothstep(p_cizgi * 0.5 - aa, p_cizgi * 0.5 + aa, d)) * 0.8, res); res = overPre(vec4(1.0) * (1.0 - smoothstep(p_cizgi * 1.2 - aa, p_cizgi * 1.2 + aa, dd)), res);
  o = overPre(vec4(1.0, 0.3, 0.3, 1.0) * (1.0 - smoothstep(p_cizgi * 1.8 - aa, p_cizgi * 1.8 + aa, length(q - p_baslangi))), res); }

//== lightvoronoi
uniform sampler2D s_engelMask; uniform vec4 p_dv4[4]; float dvAt(int i) { return i < 0 || i >= 16 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_engelMaskOn, p_dvN, p_cozunurl, p_kenarGeni, p_bolgelerRenk;
// Işık kaynakları (motor: seçili katmanların konumları); her piksel, engel kesmeden gördüğü en yakın ışığın bölgesi; bölge sınırları çizgi
vec2 Lp(int i) { if (p_dvN > 1.5) return vec2(dvAt(i * 2), dvAt(i * 2 + 1)); vec2 bu = boxU(); return vec2(i == 0 ? -0.3 : (i == 1 ? 0.3 : 0.0), i == 2 ? 0.3 : -0.2) * bu; }
float occ(vec2 u) { return p_engelMaskOn > 0.5 ? texture(s_engelMask, boxUV(fromUnit(u))).a : 0.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = p_dvN > 1.5 ? int(p_dvN / 2.0) : 3; float b1 = 1e9, b2 = 1e9; int bi = -1;
  if (occ(q) > 0.5) { o = vec4(0.1, 0.1, 0.12, 1.0); return; }
  for (int i = 0; i < 8; i++) { if (i >= N) break; vec2 L = Lp(i); float D = length(q - L); bool vis = true; for (int k = 1; k < 24; k++) { if (occ(mix(q, L, float(k) / 24.0)) > 0.5) { vis = false; break; } }
    if (!vis) D += 1e5; if (D < b1) { b2 = b1; b1 = D; bi = i; } else if (D < b2) b2 = D; }
  vec4 res = s; if (bi >= 0 && b1 < 1e5) { vec3 c = hsv2rgb(vec3(float(bi) * 0.17 + 0.05, 0.55, 1.0)); if (p_bolgelerRenk > 0.5) res = vec4(mix(s.rgb, c * max(s.a, 0.3), 0.5), max(s.a, 0.3)); float edge = 1.0 - smoothstep(p_kenarGeni * 0.5, p_kenarGeni * 0.5 + 1.0 / u_s, (b2 - b1) * 0.5);
    res = overPre(vec4(1.0, 1.0, 0.85, 1.0) * edge * step(b2, 1e5), res); } else res = vec4(s.rgb * 0.25, s.a);
  for (int i = 0; i < 8; i++) { if (i >= N) break; res = overPre(vec4(1.0, 0.9, 0.4, 1.0) * (1.0 - smoothstep(3.0, 4.0, length(q - Lp(i)))), res); } o = res; }

//== hexpath
uniform sampler2D s_engelMask; uniform vec2 p_baslangi, p_hedef; uniform float p_engelMaskOn, p_hucre, p_ilerleme;
// Altıgen ızgarada açgözlü + engel çevresinden dolanan yol (her pikselde aynı deterministik yol); engeller kaynak maske ya da koyu bölgeler
vec2 hexC(vec2 h, float S) { return vec2(S * 1.5 * h.x, S * 1.7320508 * (h.y + 0.5 * mod(h.x, 2.0))); }
vec2 toHex(vec2 p, float S) { float x = floor(p.x / (S * 1.5) + 0.5); float y = floor(p.y / (S * 1.7320508) - 0.5 * mod(x, 2.0) + 0.5); vec2 best = vec2(x, y); float bd = 1e9; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 h = vec2(x + float(i), y + float(j)); float d = length(p - hexC(h, S)); if (d < bd) { bd = d; best = h; } } return best; }
bool blocked(vec2 h, float S) { vec2 c = hexC(h, S); if (p_engelMaskOn > 0.5) return texture(s_engelMask, boxUV(fromUnit(c))).a > 0.5; vec4 col = texU(c); return col.a > 0.5 && luma(unpre(col)) < 0.25; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float S = max(p_hucre, 4.0) * 0.5; vec2 me = toHex(q, S); vec2 goal = toHex(p_hedef, S); vec2 cur = toHex(p_baslangi, S);
  float onPath = 0.0; float steps = 0.0; float total = 1.0; vec2 prev = cur + vec2(99.0); for (int k = 0; k < 96; k++) { if (cur == goal) break; vec2 best = cur; float bd = 1e9;
    for (int n = 0; n < 6; n++) { vec2 nb; bool odd = mod(cur.x, 2.0) > 0.5; if (n == 0) nb = cur + vec2(0.0, 1.0); else if (n == 1) nb = cur + vec2(0.0, -1.0); else if (n == 2) nb = cur + vec2(1.0, odd ? 0.0 : -1.0); else if (n == 3) nb = cur + vec2(1.0, odd ? 1.0 : 0.0); else if (n == 4) nb = cur + vec2(-1.0, odd ? 0.0 : -1.0); else nb = cur + vec2(-1.0, odd ? 1.0 : 0.0);
      if (blocked(nb, S) || nb == prev) continue; float d = length(hexC(nb, S) - hexC(goal, S)) + hash1(nb) * 0.01; if (d < bd) { bd = d; best = nb; } }
    prev = cur; cur = best; steps += 1.0; if (cur == me) onPath = steps; }
  total = max(steps, 1.0); float lit = onPath > 0.0 && onPath / total <= p_ilerleme / 100.0 ? 1.0 : 0.0; vec2 c = hexC(me, S); float hd = hexDist(rot2(0.0) * (q - c) / (S * 1.7320508)); float edge = smoothstep(0.42, 0.48, hd);
  vec4 res = s; if (blocked(me, S)) res = mix(res, vec4(0.15, 0.15, 0.18, 1.0), 0.6); res = mix(res, vec4(1.0, 0.75, 0.25, 1.0), lit * 0.75); res = overPre(vec4(1.0) * edge * 0.25, res);
  if (me == toHex(p_baslangi, S)) res = mix(res, vec4(0.3, 0.9, 0.4, 1.0), 0.8); if (me == goal) res = mix(res, vec4(0.95, 0.3, 0.3, 1.0), 0.8); o = res; }

//== arrowfield
uniform sampler2D s_alan; uniform vec3 c_renk; uniform float p_alanOn, p_aralik, p_okBoyu, p_hizaGoreBoyu;
// Izgara üzerinde oklar: gövde alan yönünde (orta noktada bükülür), uzunluk isteğe bağlı büyüklükle; uçta üçgen baş
vec2 F(vec2 px) { if (p_alanOn > 0.5) return texture(s_alan, boxUV(px)).rg * 2.0 - 1.0; vec2 g = lumGrad(px, 3.0); return vec2(-g.y, g.x) * 8.0 + vec2(0.15, 0.0); }
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float G = max(p_aralik * u_s, 4.0); vec2 c = (floor(p / G) + 0.5) * G; vec2 f0 = F(c); float m = length(f0); if (m < 1e-4) { o = s; return; }
  float L = p_okBoyu * u_s * (p_hizaGoreBoyu > 0.5 ? clamp(m, 0.25, 1.5) : 1.0); vec2 d0 = f0 / m; vec2 a = c - d0 * L * 0.5; vec2 mid = c; vec2 f1 = F(c + d0 * L * 0.25); vec2 d1 = length(f1) > 1e-4 ? normalize(f1) : d0; vec2 e = mid + d1 * L * 0.5;
  float w = max(u_s * 0.8, 0.8); float sh = min(seg(p, a, mid), seg(p, mid, e - d1 * w * 2.0)); vec2 lp = p - e; vec2 tn = vec2(-d1.y, d1.x); float hx = dot(lp, -d1), hy = abs(dot(lp, tn));
  float head = step(0.0, hx) * step(hx, w * 5.0) * step(hy, (w * 5.0 - hx) * 0.55); float v = max(1.0 - smoothstep(w * 0.5, w * 0.5 + 0.8, sh), head); o = overPre(vec4(c_renk, 1.0) * v, s); }

//== chorddiagram
INCLUDE(_chart)
uniform float p_icYari, p_seritEgim, p_bosluk, p_etiketle;
// Grup yayları (satır toplamlarıyla orantılı, aralarında boşluk) ve gruplar arası şeritler (değerle orantılı genişlik, merkeze doğru eğik)
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = int(min(dR(), 8.0)); float R = p_icYari; float gap = radians(p_bosluk); float tot = 0.0; float rs[8];
  for (int i = 0; i < 8; i++) { rs[i] = 0.0; if (i >= N) break; for (int j = 0; j < 8; j++) { if (j >= N) break; rs[i] += abs(dat(float(i), float(min(j, int(dC()) - 1)))) ; } tot += rs[i]; }
  float span = 6.2832 - gap * float(N); float a0[8]; float acc = 0.0; for (int i = 0; i < 8; i++) { a0[i] = acc; if (i < N) acc += rs[i] / max(tot, 1e-6) * span + gap; }
  float r = length(q); float ang = mod(atan(q.y, q.x) + 6.2832, 6.2832); vec4 res = s; float aa = 1.0 / u_s;
  for (int i = 0; i < 8; i++) { if (i >= N) break; float a1 = a0[i] + rs[i] / max(tot, 1e-6) * span; vec3 c = serCol(float(i), vec3(0.2, 0.55, 1.0));
    float ring = step(R, r) * step(r, R * 1.08) * step(a0[i], ang) * step(ang, a1); res = mix(res, vec4(c, 1.0), ring);
    if (p_etiketle > 0.5) { float am = (a0[i] + a1) * 0.5; vec2 lp = (q - vec2(cos(am), sin(am)) * R * 1.18) / (R * 0.06); res = overPre(vec4(1.0) * numAt(lp, rs[i]), res); } }
  if (r < R) for (int i = 0; i < 8; i++) { if (i >= N) break; float ai = a0[i]; for (int j = 0; j < 8; j++) { if (j >= N || j == i) continue; float v = abs(dat(float(i), float(min(j, int(dC()) - 1)))); if (v <= 0.0) continue;
      float wi = v / max(tot, 1e-6) * span; float pa = ai + wi * 0.5; ai += wi; float pb = a0[j] + rs[j] / max(tot, 1e-6) * span * 0.5; vec2 A = vec2(cos(pa), sin(pa)) * R, B = vec2(cos(pb), sin(pb)) * R; vec2 C = (A + B) * 0.5 * (1.0 - p_seritEgim / 100.0);
      float d = 1e5; vec2 pv = A; for (int k = 1; k <= 12; k++) { float t = float(k) / 12.0; vec2 pt = mix(mix(A, C, t), mix(C, B, t), t); vec2 ab = pt - pv; float tt = clamp(dot(q - pv, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); d = min(d, length(q - pv - ab * tt)); pv = pt; }
      float w = max(wi * R * 0.5, 1.0); res = overPre(vec4(serCol(float(i), vec3(0.2, 0.55, 1.0)), 1.0) * (1.0 - smoothstep(w - aa, w + aa, d)) * 0.55, res); } }
  o = res; }

//== capillary
uniform vec2 p_merkez; uniform float p_cizgi, p_bukulme, p_icYari, p_kalinlik;
// Dış çemberden içe uzanan, yarıçapla bükülen ince eğriler: θ(r) = θi + bükülme·(1 − r/R)²
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_merkez; float R = min(boxU().x, boxU().y) * 0.48; float r = length(q); if (r > R || r < p_icYari) { o = s; return; }
  float N = max(floor(p_cizgi), 4.0); float bend = radians(p_bukulme) * pow(1.0 - r / R, 2.0) * 3.0; float th = atan(q.y, q.x) - bend; float k = th / 6.2832 * N; float dAng = abs(fract(k) - 0.5) * 6.2832 / N;
  float d = dAng * r; float v = (1.0 - smoothstep(p_kalinlik * 0.5 - 0.6 / u_s, p_kalinlik * 0.5 + 0.6 / u_s, d)) * smoothstep(p_icYari, p_icYari + 6.0, r); o = overPre(vec4(0.95, 0.9, 0.8, 1.0) * v, s); }

//== edgecrystal
uniform sampler2D s_baslangiMask; uniform vec3 c_renk; uniform float p_baslangiMaskOn, p_buyume, p_fasetBoyu, p_yonlilik;
// Maske kenarından dışa büyüyen fasetli kristaller: Voronoi hücresi başına düz gölgelenmiş yüzey; hücrenin büyüme payı tohumlu
float M(vec2 px) { return p_baslangiMaskOn > 0.5 ? texture(s_baslangiMask, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); if (M(p) > 0.5) { o = s; return; } float F = max(p_fasetBoyu * u_s, 2.0); float G = p_buyume / 100.0 * F * 6.0; if (G <= 0.0) { o = s; return; }
  float d = outerDist(p, G * 1.1); if (d <= 0.0 || d > G) { o = s; return; } vec2 g = alphaGrad(p, 2.0); vec2 n = length(g) > 1e-5 ? -normalize(g) : vec2(0.0, -1.0);
  vec2 qq = p / F; qq = mix(qq, vec2(dot(qq, vec2(n.y, -n.x)), dot(qq, n) * 0.5), p_yonlilik / 100.0); vec4 v = voronoi(qq); float hgt = 0.35 + 0.65 * hash1(v.zw); if (d > G * hgt) { o = s; return; }
  vec3 fn = normalize(vec3(hash2(v.zw + 3.0) - 0.5, 0.6)); float sh = clamp(dot(fn, normalize(vec3(-0.4, -0.6, 0.8))), 0.0, 1.0); float edge = smoothstep(0.0, 0.04, v.y - v.x);
  vec3 c = c_renk * (0.55 + 0.6 * sh) * mix(1.25, 1.0, edge); o = overPre(vec4(c, 0.88), s); }
