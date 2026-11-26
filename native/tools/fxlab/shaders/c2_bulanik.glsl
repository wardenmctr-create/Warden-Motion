// Bulanıklık (rehberdeki ayarlar). Yarıçap px → sigma ≈ yarıçap/2
//== blur_h
uniform float p_yaricap, p_boyutlar, p_kenarPiksTekr, p_alfayiBula;
void main() { float sg = p_boyutlar > 1.5 ? 0.0 : p_yaricap * u_s * 0.5; vec4 c = gauss1(here(), vec2(1.0, 0.0), sg, p_kenarPiksTekr > 0.5 ? 3.0 : 0.0); o = c; }
//== blur_v
uniform sampler2D u_src; uniform float p_yaricap, p_boyutlar, p_kenarPiksTekr, p_alfayiBula;
void main() { float sg = (p_boyutlar > 0.5 && p_boyutlar < 1.5) ? 0.0 : p_yaricap * u_s * 0.5; vec4 c = gauss1(here(), vec2(0.0, 1.0), sg, p_kenarPiksTekr > 0.5 ? 3.0 : 0.0);
  if (p_alfayiBula < 0.5) { float a = texture(u_src, v_uv).a; c = pre(c.a > 0.0 ? c.rgb / c.a : vec3(0.0), a); } o = c; }
//== boxblur
uniform float p_yaricap, p_yineleme, p_boyutlar, p_kenarUzat;
void main() {
  float r = p_yaricap * u_s; float e = p_kenarUzat > 0.5 ? 3.0 : 0.0; int N = int(clamp(r, 1.0, 12.0));
  vec2 ax = p_boyutlar < 0.5 ? vec2(1.0) : p_boyutlar < 1.5 ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // yineleme arttıkça kutu yumuşar (üçgen → çan): örnek ağırlıkları
  float k = clamp(p_yineleme, 1.0, 8.0); vec4 acc = vec4(0.0); float ws = 0.0;
  for (int i = -12; i <= 12; i++) for (int j = -12; j <= 12; j++) { if (abs(i) > N || abs(j) > N) continue; vec2 f = vec2(float(i), float(j)) / float(N);
    if (ax.x < 0.5 && i != 0) continue; if (ax.y < 0.5 && j != 0) continue;
    float w = pow(max(0.0, 1.0 - abs(f.x)), k - 1.0) * pow(max(0.0, 1.0 - abs(f.y)), k - 1.0); acc += texEdge(here() + f * r, e) * w; ws += w; }
  o = acc / max(ws, 1e-4);
}
//== dirblur
uniform float p_uzunluk, p_aci, p_ornekSayi, p_kenarUzat;
void main() { float a = radians(p_aci); vec2 d = vec2(cos(a), sin(a)) * p_uzunluk * u_s * 0.5; o = lineAvg(here() - d, here() + d, int(clamp(p_ornekSayi, 4.0, 128.0)), p_kenarUzat > 0.5 ? 3.0 : 0.0); }
//== spinblur
uniform vec2 p_merkez; uniform float p_donusMikt, p_ornekSayi, p_disaDogrGuc, p_kenarUzat;
void main() {
  vec2 c = fromUnit(p_merkez); vec2 r = here() - c; float L = length(boxU() * u_s) * 0.5;
  float k = mix(1.0, clamp(length(r) / max(L, 1.0), 0.0, 1.0), p_disaDogrGuc / 100.0);
  int N = int(clamp(p_ornekSayi, 4.0, 128.0)); vec4 acc = vec4(0.0);
  for (int i = 0; i < 128; i++) { if (i >= N) break; float t = (float(i) + 0.5) / float(N) - 0.5; acc += texEdge(c + rot2(p_donusMikt * k * t) * r, p_kenarUzat > 0.5 ? 3.0 : 0.0); }
  o = acc / float(N);
}
//== zoomblur
uniform vec2 p_merkez; uniform float p_yakinlas, p_ornekSayi, p_yon, p_kenarUzat;
void main() {
  vec2 c = fromUnit(p_merkez); vec2 r = here() - c; float z = p_yakinlas / 100.0; int N = int(clamp(p_ornekSayi, 4.0, 128.0)); vec4 acc = vec4(0.0);
  for (int i = 0; i < 128; i++) { if (i >= N) break; float t = (float(i) + 0.5) / float(N); float s = p_yon < 0.5 ? 1.0 - z * t : p_yon < 1.5 ? 1.0 + z * t : 1.0 + z * (t - 0.5); acc += texEdge(c + r * s, p_kenarUzat > 0.5 ? 3.0 : 0.0); }
  o = acc / float(N);
}
//== lensblur
uniform sampler2D s_derinlikKatm; uniform float p_derinlikKatmOn;
uniform float p_yaricap, p_diyaframSekl, p_diyaframAcis, p_kenarYuva, p_parlakNoktEsig, p_parlakNoktKaza;
float aperture(vec2 f) { // f: -1..1, şekil içinde mi
  float n = p_diyaframSekl < 0.5 ? 0.0 : p_diyaframSekl < 1.5 ? 3.0 : p_diyaframSekl < 2.5 ? 5.0 : p_diyaframSekl < 3.5 ? 6.0 : 8.0;
  if (n < 1.0) return step(length(f), 1.0);
  f = rot2(-p_diyaframAcis) * f; float a = atan(f.y, f.x); float seg = TAU / n; float d = cos(PI / n) / cos(mod(a, seg) - seg * 0.5);
  d = mix(d, 1.0, p_kenarYuva / 100.0 * 0.6); return step(length(f), d);
}
void main() {
  float R = p_yaricap * u_s * 0.5; float k = 1.0;
  if (p_derinlikKatmOn > 0.5) { vec4 dm = texture(s_derinlikKatm, clamp(boxUV(here()), 0.0, 1.0)); k = luma(unpre(dm)); }
  R *= k; if (R < 0.5) { o = texture(u_tex, v_uv); return; }
  vec4 acc = vec4(0.0); float ws = 0.0; float th = p_parlakNoktEsig / 100.0; float gain = p_parlakNoktKaza / 100.0 * 6.0;
  for (int j = -6; j <= 6; j++) for (int i = -6; i <= 6; i++) { vec2 f = vec2(float(i), float(j)) / 6.0; if (aperture(f) < 0.5) continue;
    vec4 c = texPx(here() + f * R + (hash2(vec2(float(i), float(j))) - 0.5) * R / 6.0); float l = c.a > 0.0 ? luma(c.rgb / c.a) : 0.0; float w = 1.0 + max(l - th, 0.0) / max(1.0 - th, 0.01) * gain; acc += c * w; ws += w; }
  o = acc / ws;
}
//== tiltshift_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec2 p_odakMerk; uniform float p_aci, p_netBantGeni, p_gecisGeni, p_disAlanDoyg, p_tersMask;
void main() {
  vec2 q = toUnit(here()); float a = radians(p_aci); vec2 n = vec2(-sin(a), cos(a)); float H = abs(dot(boxU(), abs(n)));
  float d = abs(dot(q - p_odakMerk, n)) / max(H, 1.0); float b = p_netBantGeni / 200.0, g = max(p_gecisGeni / 100.0, 0.01);
  float m = smoothstep(b, b + g, d); if (p_tersMask > 0.5) m = 1.0 - m;
  vec4 s = texture(u_src, v_uv), bl = texture(u_aux, v_uv); vec4 c = mix(s, bl, m);
  if (c.a > 0.0) c = pre(satAdj(c.rgb / c.a, 1.0 + p_disAlanDoyg / 100.0 * m), c.a);
  o = c;
}
//== streaks
uniform float p_esik, p_uzunluk, p_isinSayi, p_aci, p_yogunluk, p_kaynakRengKull; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); float th = p_esik / 100.0; int R = int(clamp(p_isinSayi, 2.0, 16.0)); vec3 acc = vec3(0.0);
  for (int k = 0; k < 16; k++) { if (k >= R) break; float a = radians(p_aci) + float(k) * PI / float(R) * (R > 2 ? 2.0 : 1.0); vec2 d = vec2(cos(a), sin(a)) * p_uzunluk * u_s;
    for (int i = 1; i <= 16; i++) { float t = float(i) / 16.0; vec4 x = texPx(here() + d * t); vec3 c = x.a > 0.0 ? x.rgb / x.a : vec3(0.0); float b = max(luma(c) - th, 0.0) / max(1.0 - th, 0.01);
      acc += (p_kaynakRengKull > 0.5 ? c : c_renk) * b * x.a * pow(1.0 - t, 2.0); } }
  acc *= p_yogunluk / 100.0 * 0.35;
  o = vec4(s.rgb + acc * (1.0 - s.rgb * 0.5), max(s.a, min(1.0, max(acc.r, max(acc.g, acc.b)))));
}
//== sharpen
uniform float p_keskinli, p_yaricap, p_gurultuEsig, p_alfayiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); float r = max(p_yaricap * u_s, 0.7); vec4 b = vec4(0.0);
  for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; b += texPx(here() + vec2(cos(a), sin(a)) * r); } b /= 8.0;
  vec4 d = s - b; float m = step(p_gurultuEsig / 100.0 * 0.2, length(d.rgb));
  vec4 c = s + d * p_keskinli / 100.0 * 3.0 * m; if (p_alfayiKoru > 0.5) c.a = s.a;
  c.rgb = clamp(c.rgb, 0.0, c.a); o = c;
}
//== bilateral
uniform float p_uzamsalYari, p_renkTole, p_yineleme, p_kenarKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float R = max(p_uzamsalYari * u_s, 0.5); float tol = max(p_renkTole / 100.0, 0.01) * mix(1.6, 0.6, p_kenarKoru / 100.0);
  vec4 acc = vec4(0.0); float ws = 0.0; float it = clamp(p_yineleme, 1.0, 8.0);
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec2 f = vec2(float(i), float(j)) / 4.0; vec4 x = texPx(here() + f * R * sqrt(it) * 0.7); vec3 c = unpre(x);
    float w = exp(-dot(f, f) * 2.0) * exp(-dot(c - c0, c - c0) / (tol * tol)) * (x.a > 0.01 ? 1.0 : 0.05); acc += x * w; ws += w; }
  o = acc / max(ws, 1e-4);
}
//== chanblur_h
uniform float p_kirmiziYari, p_yesilYari, p_maviYari, p_alfaYari, p_eksen, p_kenarUzat;
void main() { float on = p_eksen > 1.5 ? 0.0 : 1.0; float e = p_kenarUzat > 0.5 ? 3.0 : 0.0; vec2 d = vec2(1.0, 0.0);
  o = vec4(gauss1(here(), d, p_kirmiziYari * u_s * 0.5 * on, e).r, gauss1(here(), d, p_yesilYari * u_s * 0.5 * on, e).g, gauss1(here(), d, p_maviYari * u_s * 0.5 * on, e).b, gauss1(here(), d, p_alfaYari * u_s * 0.5 * on, e).a); }
//== chanblur_v
uniform float p_kirmiziYari, p_yesilYari, p_maviYari, p_alfaYari, p_eksen, p_kenarUzat;
void main() { float on = (p_eksen > 0.5 && p_eksen < 1.5) ? 0.0 : 1.0; float e = p_kenarUzat > 0.5 ? 3.0 : 0.0; vec2 d = vec2(0.0, 1.0);
  vec4 c = vec4(gauss1(here(), d, p_kirmiziYari * u_s * 0.5 * on, e).r, gauss1(here(), d, p_yesilYari * u_s * 0.5 * on, e).g, gauss1(here(), d, p_maviYari * u_s * 0.5 * on, e).b, gauss1(here(), d, p_alfaYari * u_s * 0.5 * on, e).a);
  c.rgb = min(c.rgb, vec3(max(c.a, max(c.r, max(c.g, c.b))))); o = c; }
//== crossblur_h
uniform float p_yatayYari, p_bagla, p_kenarUzat;
void main() { o = gauss1(here(), vec2(1.0, 0.0), p_yatayYari * u_s * 0.5, p_kenarUzat > 0.5 ? 3.0 : 0.0); }
//== crossblur_v
uniform float p_yatayYari, p_dikeyYari, p_bagla, p_kenarUzat;
void main() { o = gauss1(here(), vec2(0.0, 1.0), (p_bagla > 0.5 ? p_yatayYari : p_dikeyYari) * u_s * 0.5, p_kenarUzat > 0.5 ? 3.0 : 0.0); }
//== vectorblur
uniform sampler2D s_yonKatm; uniform float p_yonKatmOn; uniform float p_akisUzun, p_yonKayn, p_yonAcis, p_ornekSayi, p_ciftYon;
void main() {
  vec2 p = here(); int N = int(clamp(p_ornekSayi, 4.0, 64.0)); float L = p_akisUzun * u_s; vec4 acc = vec4(0.0);
  for (int i = 0; i < 64; i++) { if (i >= N) break;
    vec2 g; if (p_yonKayn > 0.5 && p_yonKatmOn > 0.5) { vec3 m = unpre(texture(s_yonKatm, clamp(boxUV(p), 0.0, 1.0))); g = (m.rg - 0.5); g = vec2(-g.y, g.x); } else g = lumGrad(p, 2.0);
    vec2 d = length(g) > 1e-5 ? normalize(vec2(-g.y, g.x)) : vec2(1.0, 0.0); d = rot2(p_yonAcis) * d;
    acc += texPx(p); p += d * L / float(N) * (p_ciftYon > 0.5 && i % 2 == 1 ? -1.0 : 1.0); }
  o = acc / float(N);
}
//== median
uniform float p_yaricap, p_kanal, p_yineleme, p_kenarKoru;
void main() {
  // 3x3 (ölçekli) ortanca: 9 örnekten parlaklığa göre ortanca
  float r = max(p_yaricap * u_s * 0.6, 0.7); vec4 v[9]; float l[9]; int k = 0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec4 c = texPx(here() + vec2(float(i), float(j)) * r); v[k] = c; l[k] = p_kanal > 1.5 ? c.a : luma(unpre(c)) + c.a * 0.001; k++; }
  for (int a = 0; a < 5; a++) { int mi = a; for (int b = a + 1; b < 9; b++) if (l[b] < l[mi]) mi = b; float tl = l[a]; l[a] = l[mi]; l[mi] = tl; vec4 tv = v[a]; v[a] = v[mi]; v[mi] = tv; }
  vec4 m = v[4]; vec4 s = texture(u_tex, v_uv);
  if (p_kanal > 0.5 && p_kanal < 1.5) m = pre(unpre(s) * (luma(unpre(m)) / max(luma(unpre(s)), 1e-3)), s.a);
  float e = clamp(sobel(here(), 1.0), 0.0, 1.0) * p_kenarKoru / 100.0;
  o = mix(m, s, e * 0.7);
}
//== dustscratch
uniform float p_yaricap, p_esik, p_inceAyriKoru, p_kanal, p_zamanFilt;
void main() {
  vec4 s = texture(u_tex, v_uv); float r = max(p_yaricap * u_s * 0.6, 0.7); vec4 v[9]; float l[9]; int k = 0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec4 c = texPx(here() + vec2(float(i), float(j)) * r); v[k] = c; l[k] = luma(unpre(c)); k++; }
  for (int a = 0; a < 5; a++) { int mi = a; for (int b = a + 1; b < 9; b++) if (l[b] < l[mi]) mi = b; float tl = l[a]; l[a] = l[mi]; l[mi] = tl; vec4 tv = v[a]; v[a] = v[mi]; v[mi] = tv; }
  float diff = abs(luma(unpre(s)) - l[4]); float m = smoothstep(p_esik / 100.0 * 0.5, p_esik / 100.0 * 0.5 + 0.05, diff) * (1.0 - p_inceAyriKoru / 100.0 * 0.3);
  o = mix(s, v[4], m);
}
//== unsharp
uniform float p_miktar, p_yaricap, p_esik, p_yalnizParl;
void main() {
  vec4 s = texture(u_tex, v_uv); float sg = max(p_yaricap * u_s * 0.5, 0.5); vec4 b = vec4(0.0); float ws = 0.0;
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 f = vec2(float(i), float(j)); float w = exp(-dot(f, f) / 4.5); b += texPx(here() + f * sg * 0.7) * w; ws += w; } b /= ws;
  vec3 c = unpre(s), bc = unpre(b); vec3 d = c - bc; float m = step(p_esik / 100.0 * 0.3, abs(luma(c) - luma(bc)));
  vec3 r = p_yalnizParl > 0.5 ? c + (luma(c) - luma(bc)) * p_miktar / 100.0 * m : c + d * p_miktar / 100.0 * m;
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
//== compoundblur
uniform sampler2D s_bulaniklHari; uniform float p_bulaniklHariOn; uniform float p_haritaKana, p_maksimumYari, p_tersHari, p_haritayiOlce, p_kenarUzat;
void main() {
  vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec4 m = p_bulaniklHariOn > 0.5 ? texture(s_bulaniklHari, b) : texture(u_tex, v_uv);
  vec3 mc = unpre(m); float v = p_haritaKana < 0.5 ? luma(mc) : p_haritaKana < 1.5 ? m.a : p_haritaKana < 2.5 ? mc.r : p_haritaKana < 3.5 ? mc.g : mc.b;
  if (p_bulaniklHariOn < 0.5) v = length(b - 0.5) * 1.4; // harita yoksa: kenarlara doğru artar
  if (p_tersHari > 0.5) v = 1.0 - v;
  float R = p_maksimumYari * u_s * 0.5 * v; vec4 acc = vec4(0.0); float ws = 0.0;
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec2 f = vec2(float(i), float(j)) / 4.0; float w = exp(-dot(f, f) * 2.0); acc += texEdge(here() + f * R * 1.5, p_kenarUzat > 0.5 ? 3.0 : 0.0) * w; ws += w; }
  o = acc / ws;
}
//== deblur
uniform float p_hareketAcis, p_izUzun, p_duzeltmeGucu, p_gurultuBast, p_otomatikAnal;
void main() {
  vec4 s = texture(u_tex, v_uv); float a = radians(p_hareketAcis); vec2 d = vec2(cos(a), sin(a)) * p_izUzun * u_s * 0.5;
  vec4 b = lineAvg(here() - d, here() + d, 12, 3.0); vec4 c = s + (s - b) * p_duzeltmeGucu / 100.0 * 2.0;
  vec4 n = vec4(0.0); for (int i = 0; i < 4; i++) { float aa = float(i) * PI * 0.5; n += texPx(here() + vec2(cos(aa), sin(aa))); } n /= 4.0;
  c = mix(c, (c + n) * 0.5, p_gurultuBast / 100.0 * 0.5); c.a = s.a; c.rgb = clamp(c.rgb, 0.0, c.a); o = c;
}
//== upscale
uniform float p_olcek, p_ayrinti, p_gurultuAzal, p_kenarKesk, p_yontem, p_oraniKoru;
void main() {
  // katman ölçeğinde merkezden büyütür; kenar uyarlamalı keskinleştirme ile
  vec2 q = toUnit(here()) / max(p_olcek / 100.0, 0.01); vec2 p = fromUnit(q);
  vec4 c;
  if (p_yontem > 1.5) { vec2 g = floor((p - u_box.xy) / u_s) + 0.5; c = texPx(u_box.xy + g * u_s); }
  else { c = texPx(p); vec4 b = (texPx(p + vec2(1.0, 0.0)) + texPx(p - vec2(1.0, 0.0)) + texPx(p + vec2(0.0, 1.0)) + texPx(p - vec2(0.0, 1.0))) * 0.25;
    float k = (p_yontem < 0.5 ? (p_ayrinti / 100.0 + p_kenarKesk / 100.0) : p_ayrinti / 100.0 * 0.6) * (p_olcek / 100.0) * 0.6; c = c + (c - b) * k; c = mix(c, b, p_gurultuAzal / 100.0 * 0.4); }
  c.rgb = clamp(c.rgb, 0.0, max(c.a, 0.0)); o = c;
}
//== depthblur
uniform sampler2D s_derinlikHari; uniform float p_derinlikHariOn; uniform sampler2D u_depth;
uniform float p_odakUzak, p_netAlan, p_bulanikl, p_diyafram, p_haritayiTersCevi; uniform vec2 p_odakNoktSec;
void main() {
  vec2 b = clamp(boxUV(here()), 0.0, 1.0);
  float d = p_derinlikHariOn > 0.5 ? luma(unpre(texture(s_derinlikHari, b))) : luma(unpre(texture(u_depth, v_uv)));
  if (p_haritayiTersCevi > 0.5) d = 1.0 - d;
  float f = p_odakUzak / 100.0; float k = smoothstep(p_netAlan / 200.0, p_netAlan / 200.0 + 0.25, abs(d - f));
  float R = p_bulanikl * u_s * 0.5 * k; if (R < 0.5) { o = texture(u_tex, v_uv); return; }
  vec4 acc = vec4(0.0); float ws = 0.0;
  for (int j = -5; j <= 5; j++) for (int i = -5; i <= 5; i++) { vec2 g = vec2(float(i), float(j)) / 5.0; if (length(g) > 1.0) continue; vec4 c = texPx(here() + g * R); float w = 1.0 + max(luma(unpre(c)) - 0.8, 0.0) * 4.0; acc += c * w; ws += w; }
  o = acc / ws;
}
//== chromvortex
uniform vec2 p_merkez; uniform float p_donusAcis, p_kanalAyri, p_ornekSayi, p_renkSira, p_kenarUzat;
void main() {
  vec2 c = fromUnit(p_merkez); vec2 r = here() - c; int N = int(clamp(p_ornekSayi, 4.0, 64.0)); vec3 acc = vec3(0.0); float aa = 0.0;
  float e = p_kenarUzat > 0.5 ? 3.0 : 0.0; float sep = p_kanalAyri / max(length(r) / u_s, 10.0) * 57.3;
  for (int i = 0; i < 64; i++) { if (i >= N) break; float t = (float(i) + 0.5) / float(N) - 0.5;
    vec4 xr = texEdge(c + rot2(p_donusAcis * t - sep) * r, e), xg = texEdge(c + rot2(p_donusAcis * t) * r, e), xb = texEdge(c + rot2(p_donusAcis * t + sep) * r, e);
    acc += p_renkSira < 0.5 ? vec3(xr.r, xg.g, xb.b) : vec3(xb.r, xg.g, xr.b); aa += max(xr.a, max(xg.a, xb.a)); }
  o = vec4(acc / float(N), aa / float(N));
}
//== chromzoom
uniform vec2 p_merkez; uniform float p_yakinlas, p_kanalAyri, p_ornekSayi, p_yon, p_kenarUzat;
void main() {
  vec2 c = fromUnit(p_merkez); vec2 r = here() - c; int N = int(clamp(p_ornekSayi, 4.0, 64.0)); vec3 acc = vec3(0.0); float aa = 0.0;
  float e = p_kenarUzat > 0.5 ? 3.0 : 0.0; float z = p_yakinlas / 100.0 * (p_yon > 0.5 ? -1.0 : 1.0); float sep = p_kanalAyri * u_s / max(length(r), 10.0) * 0.5;
  for (int i = 0; i < 64; i++) { if (i >= N) break; float t = (float(i) + 0.5) / float(N); float s = 1.0 - z * t;
    vec4 xr = texEdge(c + r * (s - sep), e), xg = texEdge(c + r * s, e), xb = texEdge(c + r * (s + sep), e); acc += vec3(xr.r, xg.g, xb.b); aa += max(xr.a, max(xg.a, xb.a)); }
  o = vec4(acc / float(N), aa / float(N));
}
//== innerblur
uniform float p_icYari, p_kenarKoru, p_gecis, p_alfayiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float R = max(p_icYari * u_s * 0.5, 0.5); vec4 acc = vec4(0.0); float ws = 0.0;
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec2 f = vec2(float(i), float(j)) / 4.0; vec4 c = texPx(here() + f * R * 1.5); if (c.a < 0.5) continue; float w = exp(-dot(f, f) * 2.0); acc += c * w; ws += w; }
  vec4 b = ws > 0.0 ? acc / ws : s;
  float d = innerDist(here(), (p_kenarKoru + p_gecis) * u_s + 1.0); float m = smoothstep(p_kenarKoru * u_s, (p_kenarKoru + p_gecis) * u_s + 0.5, d);
  vec4 c = mix(s, b, m); if (p_alfayiKoru > 0.5) c = pre(unpre(c), s.a);
  o = c;
}
//== linstreaks
uniform float p_aci, p_izUzun, p_yogunluk, p_esik, p_azalma, p_yalnizIz;
void main() {
  vec4 s = texture(u_tex, v_uv); float a = radians(p_aci); vec2 d = -vec2(cos(a), sin(a)) * p_izUzun * u_s; vec4 acc = vec4(0.0); float th = p_esik / 100.0;
  for (int i = 1; i <= 24; i++) { float t = float(i) / 24.0; vec4 x = texPx(here() + d * t); float l = x.a > 0.0 ? luma(x.rgb / x.a) : 0.0; float w = smoothstep(th, th + 0.1, l) * pow(1.0 - t, 1.0 + p_azalma / 25.0); acc = max(acc, x * w); }
  acc *= p_yogunluk / 100.0;
  o = p_yalnizIz > 0.5 ? acc : vec4(max(s.rgb, acc.rgb), max(s.a, acc.a));
}
//== maskblur
uniform sampler2D s_maskeKatm; uniform float p_maskeKatmOn; uniform float p_yaricap, p_maskeGeci, p_maskeKana, p_tersMask, p_kenarUzat;
void main() {
  vec2 b = clamp(boxUV(here()), 0.0, 1.0); float m;
  if (p_maskeKatmOn > 0.5) { vec4 mm = texture(s_maskeKatm, b); m = p_maskeKana < 0.5 ? mm.a : luma(unpre(mm)); } else m = 1.0 - smoothstep(0.22, 0.22 + p_maskeGeci / max(boxU().x, 1.0), length(b - 0.5));
  if (p_tersMask > 0.5) m = 1.0 - m;
  float R = p_yaricap * u_s * 0.5 * m; vec4 acc = vec4(0.0); float ws = 0.0;
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec2 f = vec2(float(i), float(j)) / 4.0; float w = exp(-dot(f, f) * 2.0); acc += texEdge(here() + f * R * 1.5, p_kenarUzat > 0.5 ? 3.0 : 0.0) * w; ws += w; }
  o = acc / ws;
}
//== spinstreaks
uniform vec2 p_merkez; uniform float p_donmeAcis, p_esik, p_yogunluk, p_izAzal, p_yalnizIz;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 c = fromUnit(p_merkez); vec2 r = here() - c; vec4 acc = vec4(0.0); float th = p_esik / 100.0;
  for (int i = 1; i <= 32; i++) { float t = float(i) / 32.0; vec4 x = texPx(c + rot2(-p_donmeAcis * t) * r); float l = x.a > 0.0 ? luma(x.rgb / x.a) : 0.0; acc = max(acc, x * smoothstep(th, th + 0.1, l) * pow(1.0 - t, 1.0 + p_izAzal / 25.0)); }
  acc *= p_yogunluk / 100.0;
  o = p_yalnizIz > 0.5 ? acc : vec4(max(s.rgb, acc.rgb), max(s.a, acc.a));
}
//== streakstrips
uniform float p_seritKali, p_aci, p_azamiIz, p_rastgele, p_faz, p_tohum, p_ikiYon;
void main() {
  vec2 q = rot2(-p_aci) * toUnit(here()); float w = max(p_seritKali, 0.5); float id = floor(q.y / w);
  float r = mix(1.0, hash1(vec2(id, seedf(p_tohum))), p_rastgele / 100.0); float L = p_azamiIz * r * (0.6 + 0.4 * cos(p_faz / 100.0 * TAU + id));
  float dir = p_ikiYon > 0.5 && mod(id, 2.0) > 0.5 ? -1.0 : 1.0; vec4 acc = vec4(0.0);
  for (int i = 0; i < 16; i++) { float t = float(i) / 15.0; acc += texU(rot2(p_aci) * (q - vec2(L * t * dir, 0.0))); }
  o = acc / 16.0;
}
//== swirlblur
uniform vec2 p_merkez; uniform float p_girdapAcis, p_yaricap, p_bulanikl, p_dusus, p_ornekSayi;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float R = max(p_yaricap, 1.0); float t = clamp(1.0 - length(r) / R, 0.0, 1.0);
  float f = pow(t, mix(0.5, 2.5, p_dusus / 100.0)); int N = int(clamp(p_ornekSayi, 4.0, 64.0)); vec4 acc = vec4(0.0);
  float span = p_bulanikl / max(length(r), 5.0) * 57.3 * f + p_girdapAcis * f * 0.3;
  for (int i = 0; i < 64; i++) { if (i >= N) break; float u = (float(i) + 0.5) / float(N) - 0.5; acc += texU(p_merkez + rot2(-p_girdapAcis * f + span * u) * r); }
  o = acc / float(N);
}
//== warpblur
uniform float p_bukmeMikt, p_gurultuOlce, p_ayrinti, p_evrim, p_bulaniklUzun, p_tohum;
void main() {
  vec2 q = toUnit(here()); vec2 p = q; vec4 acc = vec4(0.0);
  for (int i = 0; i < 16; i++) { vec2 n = p / max(p_gurultuOlce, 1.0) + seedf(p_tohum); float a = fbm(n + p_evrim * 0.05, p_ayrinti - 1.0) * TAU * 1.5;
    vec2 d = vec2(cos(a), sin(a)); acc += texU(p + d * p_bukmeMikt * 0.5); p += d * p_bulaniklUzun / 16.0; }
  o = acc / 16.0;
}
//== zoomstreaks
uniform vec2 p_merkez; uniform float p_izUzun, p_esik, p_yogunluk, p_azalma, p_yalnizIz;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 c = fromUnit(p_merkez); vec2 r = here() - c; float L = length(r); vec2 d = L > 0.001 ? r / L : vec2(0.0); vec4 acc = vec4(0.0); float th = p_esik / 100.0;
  for (int i = 1; i <= 24; i++) { float t = float(i) / 24.0; vec4 x = texPx(here() - d * p_izUzun * u_s * t); float l = x.a > 0.0 ? luma(x.rgb / x.a) : 0.0; acc = max(acc, x * smoothstep(th, th + 0.1, l) * pow(1.0 - t, 1.0 + p_azalma / 25.0)); }
  acc *= p_yogunluk / 100.0;
  o = p_yalnizIz > 0.5 ? acc : vec4(max(s.rgb, acc.rgb), max(s.a, acc.a));
}
