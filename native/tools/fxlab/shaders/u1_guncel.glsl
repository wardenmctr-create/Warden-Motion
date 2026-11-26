// Güncelleme talimatı Bölüm A: genişletilmiş mevcut efektler (eski ayarlar aynen çalışır; yeni ayarlar varsayılanda etkisiz)
//== colortune
uniform float p_kirmizi, p_yesil, p_mavi, p_parlakliKoru, p_duzenMod, p_golgeYon, p_golgeGuc, p_golgeParlak, p_ortaYon, p_ortaGuc, p_ortaParlak, p_acikYon, p_acikGuc, p_acikParlak,
  p_genelYon, p_genelGuc, p_genelParlak, p_parlakKoruG, p_tasmaSinir;
vec3 wheel(float yon, float guc) { return (hsv2rgb(vec3(fract(yon / 360.0), 1.0, 1.0)) - 0.5) * guc / 100.0 * 0.6; } // merkez nötr
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l0 = luma(c);
  c *= 1.0 + vec3(p_kirmizi, p_yesil, p_mavi) / 100.0;
  if (p_parlakliKoru > 0.5) c *= l0 / max(luma(c), 1e-3);
  if (p_duzenMod > 0.5) {
    float l = luma(c); float wS = 1.0 - smoothstep(0.0, 0.5, l), wH = smoothstep(0.5, 1.0, l), wM = 1.0 - wS - wH;
    c += wheel(p_golgeYon, p_golgeGuc) * wS + wheel(p_ortaYon, p_ortaGuc) * wM + wheel(p_acikYon, p_acikGuc) * wH + wheel(p_genelYon, p_genelGuc);
    c += (p_golgeParlak * wS + p_ortaParlak * wM + p_acikParlak * wH + p_genelParlak) / 100.0 * 0.5;
    if (p_parlakKoruG > 0.5) c *= l0 / max(luma(c), 1e-3);
    if (p_tasmaSinir > 0.5) { float m = max(c.r, max(c.g, c.b)); if (m > 1.0) c = mix(vec3(luma(c)), c, 1.0 / m); }
  }
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== gradmap
GRADIENT(renkGeci)
uniform float p_gecisKayd, p_tersCevi, p_duzlesti, p_gecisBicim, p_haritaKayn, p_gecisKontrast, p_parlakKoru, p_alfaKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); if (s.a <= 0.0 && p_alfaKoru > 0.5) { o = s; return; }
  float l = p_haritaKayn < 0.5 ? luma(c0) : p_haritaKayn < 1.5 ? c0.r : p_haritaKayn < 2.5 ? c0.g : p_haritaKayn < 3.5 ? c0.b : s.a;
  l = (l - 0.5) * p_gecisKontrast / 100.0 + 0.5;
  if (p_tersCevi > 0.5) l = 1.0 - l; l = clamp(l + p_gecisKayd / 100.0, 0.0, 1.0);
  if (p_duzlesti > 0.5 || p_gecisBicim > 1.5) { int n = paln_renkGeci(); float m = float(n - 1); l = floor(l * m + 0.5) / max(m, 1.0); }
  else if (p_gecisBicim > 0.5) l = smoothstep(0.0, 1.0, l);
  vec3 g = grad_renkGeci(l); if (p_parlakKoru > 0.5) g *= luma(c0) / max(luma(g), 1e-3);
  o = pre(clamp(g, 0.0, 1.0), p_alfaKoru > 0.5 ? s.a : 1.0);
}
//== glow_a
uniform sampler2D s_ozelMaske; uniform float p_ozelMaskeOn; uniform float p_yayilim, p_kaynakTur, p_esik, p_esikYumu, p_kaynakRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); float k;
  if (p_kaynakTur < 0.5) k = s.a; else if (p_kaynakTur < 2.5) { vec3 c = unpre(s); float v = p_kaynakTur < 1.5 ? luma(c) : max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)) + luma(c) * 0.3;
    float w = max(p_esikYumu / 100.0 * 0.5, 0.01); k = smoothstep(p_esik / 100.0 - w, p_esik / 100.0 + w, v) * s.a; }
  else k = p_ozelMaskeOn > 0.5 ? texture(s_ozelMaske, clamp(boxUV(here()), 0.0, 1.0)).a : s.a;
  k = min(1.0, k * (1.0 + p_yayilim / 100.0 * 3.0));
  o = p_kaynakRenk > 0.5 ? vec4(unpre(s) * k, k) : vec4(k);
}
//== glow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk, c_icRenk, c_disRenk; uniform float p_yogunluk, p_karistir, p_yalnizParl, p_icBuyu, p_disBuyu, p_icGuc, p_disGuc, p_kaynakRenk;
float haloA(float r) { if (r < 0.5) return 0.0; float a = 0.0; for (int i = 0; i < 12; i++) { float an = float(i) * TAU / 12.0; a += texPx(here() + vec2(cos(an), sin(an)) * r).a * 0.7 + texPx(here() + vec2(cos(an), sin(an)) * r * 0.5).a * 0.3; } return a / 12.0; }
void main() {
  vec4 s = texture(u_src, v_uv); vec4 bl = texture(u_aux, v_uv);
  vec3 col = p_kaynakRenk > 0.5 && bl.a > 0.0 ? bl.rgb / bl.a : c_renk;
  float g = clamp(bl.a * p_yogunluk / 100.0 * 1.8, 0.0, 1.0); vec4 gc = vec4(col, 1.0) * g;
  // iki katmanlı hale (iç ve dış)
  float ih = p_icBuyu > 0.0 ? haloA(p_icBuyu * u_s) * p_icGuc / 100.0 : 0.0; float dh = p_disBuyu > 0.0 ? haloA(p_disBuyu * u_s) * p_disGuc / 100.0 : 0.0;
  gc = overPre(vec4(c_icRenk, 1.0) * clamp(ih, 0.0, 1.0), overPre(gc, vec4(c_disRenk, 1.0) * clamp(dh, 0.0, 1.0)));
  float ga = gc.a;
  if (p_yalnizParl > 0.5) { o = gc * (1.0 - s.a); return; }
  if (p_karistir < 0.5) o = vec4(s.rgb + gc.rgb * (1.0 - s.rgb) * (1.0 - s.a * 0.7), max(s.a, ga));
  else if (p_karistir < 1.5) o = vec4(min(s.rgb + gc.rgb * (1.0 - s.a * 0.6), vec3(1.0)), max(s.a, ga));
  else o = overPre(s, gc);
}
//== stroke
uniform float p_kalinlik, p_konum, p_opaklik, p_birlesim, p_yalnizCizg, p_dolgu, p_ikinciKalin, p_cizgiBicim, p_kesikUzun, p_kesikBosluk, p_cizgiFaz, p_alfaYorum, p_alfaEsik, p_delikKontur, p_ekranSabit;
uniform vec3 c_renk, c_renk2g, c_ikinciRenk;
float sA(vec2 px) { float a = texPx(px).a; if (p_alfaYorum < 0.5) return step(0.5, a); if (p_alfaYorum < 1.5) return a; if (p_alfaYorum < 2.5) return smoothstep(0.08, 0.6, a); return step(p_alfaEsik / 100.0, a); }
float dil(vec2 px, float r) { float m = sA(px); if (r < 0.5) return m; for (int k = 1; k <= 3; k++) { float rr = r * float(k) / 3.0; for (int i = 0; i < 16; i++) { float a = float(i) * TAU / 16.0 + float(k) * 0.4; m = max(m, sA(px + vec2(cos(a), sin(a)) * rr)); } } return m; }
float ero(vec2 px, float r) { float m = sA(px); if (r < 0.5) return m; for (int k = 1; k <= 3; k++) { float rr = r * float(k) / 3.0; for (int i = 0; i < 16; i++) { float a = float(i) * TAU / 16.0 + float(k) * 0.4; m = min(m, sA(px + vec2(cos(a), sin(a)) * rr)); } } return m; }
float dashMask() { if (p_cizgiBicim < 0.5) return 1.0; vec2 q = toUnit(here()); float per = max(p_kesikUzun + p_kesikBosluk, 1.0);
  float t = atan(q.y, q.x) * length(boxU()) * 0.35 + p_cizgiFaz; float f = mod(t, per);
  if (p_cizgiBicim > 1.5) { float c = abs(f - per * 0.5); return 1.0 - smoothstep(p_kesikUzun * 0.25, p_kesikUzun * 0.25 + 0.8, c); } return step(f, p_kesikUzun); }
void main() {
  vec4 s = texture(u_tex, v_uv); float sc = p_ekranSabit > 0.5 ? 1.0 : u_s; float w = p_kalinlik * sc; float a0 = sA(here()); float ring;
  if (p_konum < 0.5) ring = clamp(dil(here(), w) - a0, 0.0, 1.0); else if (p_konum < 1.5) ring = clamp(a0 - ero(here(), w), 0.0, 1.0); else ring = clamp(dil(here(), w * 0.5) - ero(here(), w * 0.5), 0.0, 1.0);
  if (p_delikKontur < 0.5) { float outer = 1.0 - step(0.5, dil(here(), w * 2.5 + 4.0)); ring *= 1.0; }
  ring *= dashMask();
  vec3 col = c_renk; if (p_dolgu > 0.5 && p_dolgu < 1.5) col = mix(c_renk, c_renk2g, clamp(boxUV(here()).y, 0.0, 1.0)); else if (p_dolgu > 1.5) col = c_renk * (0.8 + 0.4 * vnoise(toUnit(here()) * 0.3));
  vec4 st = vec4(col, 1.0) * ring * p_opaklik / 100.0;
  if (p_ikinciKalin > 0.0) { float w2 = (p_kalinlik + p_ikinciKalin) * sc; float r2 = clamp(dil(here(), w2) - max(a0, dil(here(), w)), 0.0, 1.0); st = overPre(st, vec4(c_ikinciRenk, 1.0) * r2 * p_opaklik / 100.0); }
  if (p_yalnizCizg > 0.5) { o = st; return; }
  o = p_konum < 0.5 ? overPre(s, st) : overPre(st, s * (1.0 - ring * p_opaklik / 100.0));
}
//== roughen
uniform float p_kenarMikt, p_dokuOlce, p_ayrinti, p_evrim, p_tohum, p_kenarYumu, p_kenarBicim, p_cokgen, p_koseYumu, p_kenarSert, p_dinamik, p_yenilenme, p_degisim, p_hafiza, p_anaSiluet;
void main() {
  vec2 q = toUnit(here()); float sd0 = seedf(p_tohum); float sd = sd0;
  if (p_dinamik > 0.5) { float tick = floor(u_t * 30.0 / max(p_yenilenme, 1.0)); sd = mix(sd0, sd0 + tick * 7.31, (1.0 - p_hafiza / 100.0) + p_degisim / 100.0 * 0.5); }
  float sc = max(p_dokuOlce, 1.0); float st = p_kenarBicim;
  if (st > 0.5 && st < 1.5) sc *= 3.0; if (st > 2.5 && st < 3.5) sc *= 2.0; if (st > 4.5) sc *= 4.0;
  vec2 n = q / sc + sd; float oc = st > 3.5 && st < 4.5 ? p_ayrinti : (st < 0.5 ? p_ayrinti + 1.0 : max(p_ayrinti - 1.0, 1.0));
  vec2 d = vec2(fbm(n + vec2(p_evrim * 0.05, 0.0), oc - 1.0), fbm(n + vec2(3.7, -p_evrim * 0.05), oc - 1.0));
  if (st > 2.5 && st < 3.5) d = vec2(sin(q.y / sc * TAU * 2.0 + sd), sin(q.x / sc * TAU * 2.0 + sd)) * 0.6;
  vec2 pd = q + d * p_kenarMikt;
  float poly = st > 1.5 && st < 2.5 ? max(p_cokgen / 100.0, 0.5) : p_cokgen / 100.0 * 0.5;
  if (poly > 0.01) { float cell = max(p_kenarMikt * 1.5, 2.0); pd = mix(pd, (floor(pd / cell) + 0.5) * cell, poly); }
  vec4 s = texU(q); vec4 w = texU(pd);
  float soft = max(p_kenarYumu, 0.3) * 0.1 + (1.0 - p_kenarSert / 100.0) * 0.25 + p_koseYumu / 100.0 * 0.1;
  float a = smoothstep(0.5 - soft, 0.5 + soft, w.a);
  if (p_anaSiluet > 0.5) a = mix(a, s.a, 0.0);
  o = pre(s.a > 0.01 ? unpre(s) : unpre(w), a);
}
//== texturize
INCLUDE(_mat)
uniform sampler2D s_ozelDoku; uniform float p_ozelDokuOn;
uniform float p_dokuTuru, p_dokuTohum, p_dokuGucu, p_dokuOlcek, p_dokuAci, p_kaydirX, p_kaydirY, p_tekrar, p_dikisGizle, p_kabartma, p_kabartmaAci, p_kabartmaYogun, p_lif, p_buruskluk,
  p_renkleBirles, p_dokuOpak, p_tersDoku, p_sadeceAydin, p_sadeceGolge, p_dokuKontrast, p_dokuParlak, p_puruzluluk, p_yuzeyParlak, p_alfaKoru, p_nesneSabit, p_esnet, p_dogalRenk,
  p_olukGeni, p_olukDerin, p_olukYon, p_kirisBuyu, p_kirisYogun, p_damarGeni; uniform vec2 p_dokuKaydir; uniform vec3 c_dokuRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if ((s.a <= 0.0 && p_alfaKoru > 0.5) || p_dokuGucu <= 0.0) { o = s; return; }
  // eski 14 + yeni 10 malzeme
  const int MAP[24] = int[24](18, 1, 3, 4, 6, 5, 7, 19, 20, 12, 10, 11, 21, 17, 1, 2, 8, 9, 11, 20, 14, 13, 10, 20);
  int i0 = int(clamp(p_dokuTuru, 0.0, 23.0)); int id = MAP[i0];
  vec2 base = p_nesneSabit > 0.5 ? (p_esnet > 0.5 ? (boxUV(here()) - 0.5) * 600.0 : toUnit(here())) : here() / max(u_s, 0.01);
  vec2 p = rot2(-p_dokuAci) * (base - vec2(p_kaydirX, p_kaydirY) - p_dokuKaydir) / max(p_dokuOlcek / 100.0, 0.05); float sd = seedf(p_dokuTohum);
  vec4 sp = id == 4 ? vec4(p_olukGeni / 40.0, p_olukDerin / 100.0, p_olukYon / 180.0, 0.0) : id == 7 ? vec4(p_kirisBuyu / 200.0, 0.6, p_kirisYogun / 100.0, 0.0) : id == 12 ? vec4(p_damarGeni / 40.0, 0.0, 0.0, 0.0) : vec4(0.3, 0.6, 0.0, 0.5);
  float fib = p_lif / 100.0, cr = p_buruskluk / 100.0;
  vec3 mc; float h;
  if (id == 17) { vec2 tuv = p / 200.0; tuv = p_tekrar > 0.5 ? fract(tuv) : clamp(tuv + 0.5, 0.0, 1.0); vec4 t = p_ozelDokuOn > 0.5 ? texture(s_ozelDoku, tuv) : vec4(0.8);
    if (p_tekrar > 0.5 && p_dikisGizle > 0.0) { vec2 f = fract(p / 200.0); float e = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)); vec4 t2 = p_ozelDokuOn > 0.5 ? texture(s_ozelDoku, fract(p / 200.0 + 0.5)) : t; t = mix(t2, t, smoothstep(0.0, p_dikisGizle / 100.0 * 0.25 + 1e-3, e)); }
    mc = unpre(t); h = luma(mc); }
  else { vec4 m = matSample(id, p, sd, sp, fib, cr); mc = m.rgb; h = m.a;
    if (i0 == 22) { mc = vec3(0.45, 0.28, 0.18) * (0.85 + 0.3 * fbm(p / 10.0, 3.0)); h = 0.5 + fbm(p / 4.0 + sd, 4.0) * 0.3; }      // deri
    if (i0 == 23) { mc = vec3(0.86, 0.76, 0.55) * (0.9 + hash1(floor(p * 1.5)) * 0.2); h = 0.5 + (hash1(floor(p * 1.5) + sd) - 0.5) * 0.5; } } // kum
  if (p_tersDoku > 0.5) h = 1.0 - h;
  float light = id == 17 ? 1.0 + (h - 0.5) * p_kabartma * 0.1 : matLight(id, p, sd, sp, fib, cr, p_kabartma * (0.3 + p_kabartmaYogun / 100.0 * 2.0) * (0.5 + p_puruzluluk / 100.0), p_kabartmaAci);
  light += pow(max(light - 1.0, 0.0), 2.0) * p_yuzeyParlak / 100.0 * 2.0;
  vec3 c = unpre(s); float l = luma(c);
  float w = p_dokuGucu / 100.0 * p_dokuOpak / 100.0; if (p_sadeceAydin > 0.5) w *= smoothstep(0.3, 0.8, l); if (p_sadeceGolge > 0.5) w *= 1.0 - smoothstep(0.2, 0.7, l);
  vec3 tint = mc / max(matBase(id), vec3(0.05)); tint = (tint - 1.0) * (1.0 + p_dokuKontrast / 100.0) + 1.0 + p_dokuParlak / 100.0 * 0.5;
  vec3 natural = p_dogalRenk > 0.5 ? mc : tint;
  vec3 r = p_renkleBirles > 0.5 ? c * mix(vec3(1.0), tint * light * c_dokuRenk, w) : mix(c, natural * c_dokuRenk * light, w);
  if (p_dogalRenk > 0.5 && p_renkleBirles > 0.5) r = mix(c, mc * light * c_dokuRenk * (0.5 + l), w);
  o = pre(clamp(r, 0.0, 1.0), p_alfaKoru > 0.5 ? s.a : max(s.a, w));
}
//== blur_h
uniform float p_yaricap, p_boyutlar, p_kenarPiksTekr, p_alfayiBula, p_eksenBagla, p_kalite; uniform vec2 p_xyYari;
float rx() { return (p_xyYari.x > 0.0 || p_xyYari.y > 0.0) ? p_xyYari.x : p_yaricap; }
void main() { float sg = p_boyutlar > 1.5 ? 0.0 : rx() * u_s * 0.5; o = gauss1(here(), vec2(1.0, 0.0), sg, p_kenarPiksTekr > 0.5 ? 3.0 : 0.0); }
//== blur_v
uniform sampler2D u_src; uniform sampler2D s_maske; uniform float p_maskeOn;
uniform float p_yaricap, p_boyutlar, p_kenarPiksTekr, p_alfayiBula, p_eksenBagla, p_alan, p_maskeTers, p_koyuKenarOnle; uniform vec2 p_xyYari;
float ry() { return (p_xyYari.x > 0.0 || p_xyYari.y > 0.0) ? (p_eksenBagla > 0.5 ? p_xyYari.x : p_xyYari.y) : p_yaricap; }
void main() {
  float sg = (p_boyutlar > 0.5 && p_boyutlar < 1.5) ? 0.0 : ry() * u_s * 0.5; vec4 c = gauss1(here(), vec2(0.0, 1.0), sg, p_kenarPiksTekr > 0.5 ? 3.0 : 0.0);
  vec4 src = texture(u_src, v_uv);
  if (p_alfayiBula < 0.5) c = pre(c.a > 0.0 ? c.rgb / c.a : vec3(0.0), src.a);
  if (p_koyuKenarOnle > 0.5 && c.a > 0.0) c.rgb = min(c.rgb, vec3(c.a));
  float m = 1.0;
  if (p_alan > 0.5 && p_alan < 1.5) m = src.a; else if (p_alan > 1.5 && p_alan < 2.5) m = p_maskeOn > 0.5 ? texture(s_maske, clamp(boxUV(here()), 0.0, 1.0)).a : 1.0; else if (p_alan > 2.5) m = luma(unpre(src));
  if (p_maskeTers > 0.5) m = 1.0 - m;
  o = mix(src, c, m);
}
//== wave
uniform float p_dalgaYuks, p_dalgaBoyu, p_dalgaYonu, p_faz, p_hiz, p_dalgaTipi, p_sabitKena, p_kenarIsle, p_yayilim, p_konumaGore, p_ikinciGuc, p_ikinciBoy, p_ikinciHiz, p_sonum, p_dongu, p_donguSure;
float wv(float k, float a, vec2 q) { if (k < 2.5) return wavef(k, a); if (k < 3.5) return fract(a / TAU) * 2.0 - 1.0; if (k < 4.5) return pnoise(vec2(a / TAU, 3.1)) * 1.4; return sin(a) * 0.7 + sin(a * 2.0) * 0.3; }
void main() {
  vec2 q = toUnit(here()); float a = radians(p_dalgaYonu); vec2 d = vec2(cos(a), sin(a)), n = vec2(-d.y, d.x);
  float f = p_hiz, f2 = p_ikinciHiz; if (p_dongu > 0.5) { float T = max(p_donguSure, 0.1); f = floor(f * T + 0.5) / T; f2 = floor(f2 * T + 0.5) / T; }
  float along = dot(q, d); float ph = TAU * (along / max(p_dalgaBoyu, 1.0) - f * u_t) + p_faz * TAU / 100.0;
  float h = wv(p_dalgaTipi, ph, q) + p_ikinciGuc / 100.0 * sin(TAU * (along / max(p_ikinciBoy, 1.0) - f2 * u_t));
  vec2 b = boxUV(here()); float span = abs(dot(b - 0.5, d)) * 2.0;
  float amp = p_dalgaYuks * pinW(p_sabitKena, b) * mix(1.0, step(span, p_yayilim / 100.0 + 1e-3), 1.0) * exp(-p_sonum / 100.0 * 3.0 * clamp(dot(b, abs(d)), 0.0, 1.0));
  if (p_konumaGore > 0.5) amp *= clamp(dot(b, abs(d)), 0.0, 1.0);
  o = texEdge(fromUnit(q - n * h * amp), p_kenarIsle);
}
//== tiles
uniform float p_karoBoyu, p_karoAcis, p_aralik, p_kirpma, p_siraKayd, p_ayna, p_dikeyKayd, p_bicim, p_izgaraAci, p_alanT, p_yAyna, p_dAyna, p_disPiksel, p_dikisGizle, p_dikisYumu; uniform vec2 p_ofset, p_karoOran;
void main() {
  vec2 B = boxU(); vec2 q = rot2(-p_izgaraAci) * toUnit(here()) + p_ofset / 100.0 * B; vec2 p = q + 0.5 * B;
  vec2 cell = vec2(max(p_karoBoyu, 2.0)); cell.y *= B.y / B.x; cell *= max(p_karoOran, vec2(1.0)) / 100.0; if (p_bicim > 0.5 && p_bicim < 1.5) cell.y *= 0.6;
  float sk = p_siraKayd / 100.0; if (p_bicim > 1.5 && p_bicim < 2.5 && abs(sk) < 1e-3) sk = 0.5;
  if (p_bicim > 2.5) { vec2 r = rot2(45.0) * p; p = r; }
  if (p_dikeyKayd > 0.5) { float col = floor(p.x / cell.x); p.y += col * cell.y * sk; } else { float row = floor(p.y / cell.y); p.x += row * cell.x * sk; }
  vec2 id = floor(p / cell); vec2 f = fract(p / cell);
  if (p_alanT < 0.5) { vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = vec4(0.0); return; } }
  if (p_kirpma > 0.0 && p_alanT > 1.5) { vec2 lim = ceil(B / cell * 0.5 * (1.0 + 2.0 * p_kirpma)); vec2 cid = id - floor(B / cell * 0.5); if (abs(cid.x) > lim.x || abs(cid.y) > lim.y) { o = vec4(0.0); return; } }
  if (p_ayna > 0.5 || p_yAyna > 0.5) { if (mod(id.x, 2.0) > 0.5) f.x = 1.0 - f.x; } if (p_ayna > 0.5 || p_dAyna > 0.5) { if (mod(id.y, 2.0) > 0.5) f.y = 1.0 - f.y; }
  vec2 g = p_aralik / cell; vec2 f2 = (f - g * 0.5) / max(vec2(0.01), 1.0 - g);
  if (any(lessThan(f2, vec2(0.0))) || any(greaterThan(f2, vec2(1.0)))) { o = vec4(0.0); return; }
  // karo içeriği kendi açısıyla döner (ızgara açısından bağımsız)
  f2 = rot2(-p_karoAcis) * (f2 - 0.5) + 0.5; if (p_disPiksel < 0.5) f2 = clamp(f2, 0.0, 1.0);
  vec4 c = texEdge(boxPx(f2), p_disPiksel > 0.5 ? 0.0 : 3.0);
  if (p_dikisGizle > 0.5 && p_dikisYumu > 0.0) { float e = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)) * min(cell.x, cell.y); c = mix(texPx(boxPx(clamp(f2 + 0.5 * sign(0.5 - f2) * 0.0, 0.0, 1.0))), c, smoothstep(0.0, p_dikisYumu, e)); }
  o = c;
}
//== rgbsplit
uniform vec2 p_kirmiziOfse, p_yesilOfse, p_maviOfse, p_radMerkez; uniform float p_ayrim, p_aci, p_kenarModu, p_alfayiBirl, p_ayrBicim, p_uzakAyr, p_rOpak, p_gOpak, p_bOpak, p_alfaSinir;
void main() {
  mat2 R = rot2(p_aci); float k = p_ayrim * u_s; float m = p_kenarModu < 0.5 ? 0.0 : p_kenarModu < 1.5 ? 3.0 : 1.0;
  vec2 dr = R * p_kirmiziOfse * k, dg = R * p_yesilOfse * k, db = R * p_maviOfse * k;
  if (p_ayrBicim > 0.5) { vec2 rel = here() - fromUnit(p_radMerkez); float L = length(boxU() * u_s) * 0.5; float f = clamp(length(rel) / max(L, 1.0), 0.0, 2.0) * p_uzakAyr / 100.0; vec2 dir = length(rel) > 0.01 ? normalize(rel) : vec2(0.0);
    if (p_ayrBicim > 1.5) dir = vec2(-dir.y, dir.x); dr = dir * p_kirmiziOfse.x * k * f; dg = dir * p_yesilOfse.x * k * f; db = dir * p_maviOfse.x * k * f; }
  vec4 r = texEdge(here() - dr, m), g = texEdge(here() - dg, m), b = texEdge(here() - db, m); vec4 s = texPx(here());
  vec3 rgb = vec3(r.r * p_rOpak, g.g * p_gOpak, b.b * p_bOpak) / 100.0;
  float a = p_alfayiBirl > 0.5 ? max(r.a * p_rOpak, max(g.a * p_gOpak, b.a * p_bOpak)) / 100.0 : s.a; if (p_alfaSinir > 0.5) a = s.a;
  o = vec4(min(rgb, vec3(a)), a);
}
//== glitch
uniform float p_blokMikt, p_blokBoyu, p_kayma, p_rgbAyri, p_taramaCizg, p_tekrarla, p_tohum, p_kareTut, p_tur, p_yatayOran, p_dikeyOran, p_siklik, p_sure, p_renkKayip, p_elle, p_tetikGuc, p_parlakSinir;
void main() {
  vec2 px = here(); float tq = p_kareTut > 0.5 ? floor(u_t * max(p_tekrarla, 0.01)) : u_t * p_tekrarla; float sd = seedf(p_tohum);
  // sıklık/süre: bozulma yalnız belirli anlarda; elle tetiklemede güç
  float act = 1.0; if (p_siklik > 0.0) { float per = 1.0 / p_siklik; float k = floor(u_t / per); float st = hash1(vec2(k, sd)) * max(per - p_sure, 0.0); act = step(st, mod(u_t, per)) * step(mod(u_t, per), st + p_sure); }
  if (p_elle > 0.5) act = p_tetikGuc / 100.0;
  float bw = max(p_blokBoyu, 1.0) * u_s; vec2 bs = vec2(bw * 3.0 * p_yatayOran / 100.0, bw * p_dikeyOran / 100.0);
  float by = floor((px.y - u_box.y) / bs.y); float r = hash1(vec2(by, tq + sd)), r2 = hash1(vec2(by * 1.7, tq * 1.3 + sd + 5.0));
  float on = step(r, p_blokMikt / 100.0) * act; float bx = floor((px.x - u_box.x) / bs.x); float on2 = step(hash1(vec2(bx, by + tq * 7.0 + sd)), p_blokMikt / 250.0) * act;
  float sh = (on * (r2 * 2.0 - 1.0) + on2 * (hash1(vec2(bx, by)) - 0.5)) * p_kayma * u_s;
  if (p_tur > 0.5 && p_tur < 1.5) sh = sin(px.y * 0.05 + u_t * 10.0) * p_kayma * u_s * 0.3 * act + sh * 0.3;
  if (p_tur > 2.5 && p_tur < 3.5) sh *= step(0.5, fract(px.y / max(u_s * 3.0, 2.0)));
  float ca = (on + on2 * 0.5) * p_rgbAyri * u_s + p_rgbAyri * u_s * 0.15 * act; vec2 p = px + vec2(sh, 0.0);
  if (p_tur > 1.5 && p_tur < 2.5 && (on + on2) > 0.0) p = floor(p / bs) * bs + bs * 0.5;
  if (p_tur > 3.5 && (on + on2) > 0.0) p += vec2(hash1(vec2(bx, tq)) - 0.5, hash1(vec2(by, tq)) - 0.5) * bs * 2.0;
  vec4 g = texPx(p); vec4 c = vec4(texPx(p + vec2(ca, 0.0)).r, g.g, texPx(p - vec2(ca, 0.0)).b, 0.0); c.a = max(g.a, max(texPx(p + vec2(ca, 0.0)).a, texPx(p - vec2(ca, 0.0)).a));
  if (p_renkKayip > 0.0) { vec2 cp = floor(p / (2.0 + p_renkKayip * 0.2)) * (2.0 + p_renkKayip * 0.2); vec3 lo = unpre(texPx(cp)); vec3 cc = c.a > 0.0 ? c.rgb / c.a : vec3(0.0); cc = mix(cc, vec3(luma(cc)) + (lo - vec3(luma(lo))), p_renkKayip / 100.0); c = pre(cc, c.a); }
  c.rgb *= 1.0 - p_taramaCizg / 100.0 * 0.6 * step(0.5, fract(px.y / max(2.0, u_s * 2.0)));
  if (p_parlakSinir > 0.5) c.rgb = min(c.rgb, vec3(c.a));
  o = c;
}
//== displace
uniform float p_miktar, p_olcek, p_karmasik, p_evrim, p_bozulmaTipi, p_sabitKena, p_tohum, p_eksenBagla, p_turbYon, p_kenarKoru, p_evrimHiz, p_dongu, p_donguSure;
uniform vec2 p_ofset, p_turbOlcek, p_paralaks;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 so = max(p_turbOlcek, vec2(1.0)) / 100.0; if (p_eksenBagla > 0.5) so = vec2(so.x);
  vec2 qq = rot2(-p_turbYon) * q; vec2 n = (qq + p_ofset / 100.0 * B + p_paralaks) / (max(p_olcek, 1.0) * so) + vec2(seedf(p_tohum));
  float evo = p_evrim * 0.05 + radians(p_evrimHiz) * u_t * 0.3; float oc = p_karmasik - 1.0; vec2 d;
  if (p_dongu > 0.5) { float a = TAU * fract(u_t / max(p_donguSure, 0.1)); vec2 c = vec2(cos(a), sin(a)) * 0.8; d = vec2(fbm(n + c, oc), fbm(n + c + 4.3, oc)); }
  else d = vec2(fbm(n + vec2(evo, 1.7), oc), fbm(n + vec2(4.3, -evo), oc));
  if (p_bozulmaTipi > 0.5 && p_bozulmaTipi < 1.5) { vec2 r = normalize(q + 1e-4); d = r * d.x; } else if (p_bozulmaTipi > 1.5 && p_bozulmaTipi < 2.5) { vec2 r = normalize(q + 1e-4); d = vec2(-r.y, r.x) * d.x; }
  else if (p_bozulmaTipi > 2.5 && p_bozulmaTipi < 3.5) d.y = 0.0; else if (p_bozulmaTipi > 3.5) d.x = 0.0;
  d = rot2(p_turbYon) * d;
  float w = pinW(p_sabitKena, boxUV(here())); if (p_kenarKoru > 0.0) w *= mix(1.0, pinW(1.0, boxUV(here())), p_kenarKoru / 100.0);
  o = texU(q + d * p_miktar * w);
}
//== dispmap
uniform sampler2D s_haritaKatm, s_hedefKatm, s_bgsrc; uniform float p_haritaKatmOn, p_hedefKatmOn, p_bgsrcOn;
uniform float p_yatayKana, p_dikeyKana, p_yatayMikt, p_dikeyMikt, p_haritayiTersCevi, p_kenarModu, p_etkiAlan, p_haritaGorunur, p_merkezden, p_notr, p_birim, p_haritaYumu, p_haritaKontrast, p_hedefUyar, p_yerlesim;
float ch(vec4 c, float k) { vec3 u = unpre(c); return k < 0.5 ? u.r : k < 1.5 ? u.g : k < 2.5 ? u.b : k < 3.5 ? c.a : luma(u); }
vec2 mapUV(vec2 b) { if (p_yerlesim > 1.5 && p_yerlesim < 2.5) return fract(b * 2.0); if (p_yerlesim > 2.5) return (b - 0.5) * 1.5 + 0.5; return b; }
vec4 mapAt(vec2 b) { if (p_haritaKatmOn < 0.5) return texPx(boxPx(b)); vec4 a = texture(s_haritaKatm, clamp(mapUV(b), 0.0, 1.0));
  if (p_haritaYumu > 0.0) { float r = p_haritaYumu / max(boxU().x, 1.0); for (int i = 0; i < 6; i++) { float an = float(i) * TAU / 6.0; a += texture(s_haritaKatm, clamp(mapUV(b + vec2(cos(an), sin(an)) * r), 0.0, 1.0)); } a /= 7.0; } return a; }
vec4 target(vec2 px) { vec2 b = boxUV(px); if (p_etkiAlan > 0.5 && p_etkiAlan < 1.5 && p_bgsrcOn > 0.5) return texture(s_bgsrc, clamp(b, 0.0, 1.0));
  if (p_etkiAlan > 1.5 && p_hedefKatmOn > 0.5) return texture(s_hedefKatm, clamp(b, 0.0, 1.0)); return texEdge(px, p_kenarModu < 0.5 ? 0.0 : p_kenarModu < 1.5 ? 1.0 : p_kenarModu < 2.5 ? 2.0 : 3.0); }
void main() {
  vec2 b = boxUV(here()); vec4 m = mapAt(clamp(b, 0.0, 1.0)); float kx = p_yatayKana; float ky = p_dikeyKana < 0.5 ? 1.0 : p_dikeyKana < 1.5 ? 0.0 : p_dikeyKana;
  vec2 v = vec2(ch(m, kx), ch(m, ky)); if (p_haritayiTersCevi > 0.5) v = 1.0 - v;
  float nt = p_merkezden > 0.5 ? 0.5 : p_notr / 100.0; vec2 dv = (v - nt) * p_haritaKontrast / 100.0;
  vec2 B = boxU(); vec2 d = p_birim > 0.5 ? dv * 2.0 * vec2(p_yatayMikt, p_dikeyMikt) : dv * 2.0 * vec2(p_yatayMikt, p_dikeyMikt) / 100.0 * min(B.x, B.y) * 0.25;
  if (p_haritaKatmOn < 0.5 && m.a < 0.01) d = vec2(0.0);
  vec4 r = target(fromUnit(toUnit(here()) - d));
  if (p_etkiAlan > 0.5) { vec4 own = texture(u_tex, v_uv); r = p_haritaGorunur > 0.5 ? overPre(own, r * step(0.001, own.a + 1.0)) : r * own.a; }
  o = r;
}
//== ominoglass
uniform sampler2D s_dokuKatm; uniform float p_dokuKatmOn;
uniform float p_kirilma, p_prizmaAyri, p_dokuOlce, p_camKali, p_kenarYumu, p_tersHari, p_yukKayn, p_pah, p_puruz, p_puruzOlcek, p_puruzEvrim, p_ornek, p_renkGuc,
  p_isikTur, p_isikYuk, p_isikGuc, p_ortam, p_yParlak, p_keskin; uniform vec2 p_isikKonum; uniform vec3 c_camRenk, c_isikRenk;
float hgt(vec2 q) {
  if (p_yukKayn > 0.5 && p_yukKayn < 1.5) return luma(unpre(texU(q))); if (p_yukKayn > 1.5 && p_yukKayn < 2.5) return texU(q).a;
  if (p_yukKayn > 2.5 && p_dokuKatmOn > 0.5) return luma(unpre(texture(s_dokuKatm, clamp(boxUV(fromUnit(q)), 0.0, 1.0))));
  float s = max(p_dokuOlce, 2.0); vec2 id = floor(q / s); float big = step(0.6, hash1(floor(id / 2.0) + 3.1)); vec2 cid = big > 0.5 ? floor(id / 2.0) * 2.0 : id; vec2 cs = vec2(big > 0.5 ? 2.0 * s : s);
  vec2 f = (q - cid * s) / cs; vec2 r = hash2(cid + 11.0) - 0.5; float e = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y));
  return 0.5 + dot(r, f - 0.5) * 0.8 + smoothstep(0.0, max(p_pah / 100.0, 0.02) + max(p_camKali, 0.5) / cs.x * 0.0, e) * 0.3; }
void main() {
  vec2 q = toUnit(here()); float e = 1.0;
  vec2 nrm = vec2(hgt(q + vec2(e, 0.0)) - hgt(q - vec2(e, 0.0)), hgt(q + vec2(0.0, e)) - hgt(q - vec2(0.0, e))) * (p_yukKayn < 0.5 ? 12.0 : 25.0);
  if (p_dokuKatmOn > 0.5 && p_yukKayn < 0.5) { vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec2 ee = 2.0 / u_box.zw;
    nrm = vec2(luma(unpre(texture(s_dokuKatm, b + vec2(ee.x, 0.0)))) - luma(unpre(texture(s_dokuKatm, b - vec2(ee.x, 0.0)))), luma(unpre(texture(s_dokuKatm, b + vec2(0.0, ee.y)))) - luma(unpre(texture(s_dokuKatm, b - vec2(0.0, ee.y))))) * 4.0; }
  if (p_puruz > 0.0) { vec2 pp = q / max(p_puruzOlcek / 100.0 * 6.0, 0.1) + radians(p_puruzEvrim); nrm += vec2(pnoise(pp), pnoise(pp + 7.0)) * p_puruz / 100.0 * 0.8; }
  if (p_tersHari > 0.5) nrm = -nrm;
  vec2 dd = nrm * p_kirilma; vec2 pa = nrm * p_prizmaAyri; int N = int(clamp(p_ornek, 1.0, 8.0)); vec4 g = vec4(0.0); float rr = 0.0, bb = 0.0;
  for (int i = 0; i < 8; i++) { if (i >= N) break; vec2 j = (hash2(vec2(float(i), 3.0)) - 0.5) * 1.2 * step(1.5, float(N)); vec4 x = texU(q + dd + j); g += x; rr += texU(q + dd + pa + j).r; bb += texU(q + dd - pa + j).b; }
  g /= float(N); rr /= float(N); bb /= float(N);
  vec4 c = vec4(rr, g.g, bb, g.a); vec3 cc = c.a > 0.0 ? c.rgb / c.a : vec3(0.0); cc = mix(cc, cc * c_camRenk, p_renkGuc / 100.0);
  if (p_isikTur > 0.5) { vec3 n3 = normalize(vec3(-nrm * 0.5, 1.0)); vec3 L = p_isikTur < 1.5 ? normalize(vec3(p_isikKonum - q, p_isikYuk)) : normalize(vec3(cos(radians(-45.0)), sin(radians(-45.0)), 0.8));
    float dif = max(dot(n3, L), 0.0); float sp = pow(max(dot(reflect(-L, n3), vec3(0, 0, 1)), 0.0), max(p_keskin, 1.0)) * p_yParlak / 100.0;
    cc = cc * (p_ortam / 100.0 + (1.0 - p_ortam / 100.0) * mix(1.0, dif, 0.5) * p_isikGuc / 100.0) + c_isikRenk * sp * p_isikGuc / 100.0; }
  o = pre(clamp(cc, 0.0, 1.0), c.a);
}
//== noise
uniform float p_miktar, p_grenBoyu, p_tur, p_kontrast, p_tohum, p_zamanaBagl, p_alfayiEtki, p_dondur, p_yenilenme, p_golgeYog, p_ortaYog, p_acikYog; uniform vec2 p_grenOran;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 gs = max(p_grenBoyu, 0.3) * max(p_grenOran, vec2(1.0)) / 100.0; vec2 g = floor(toUnit(here()) / gs);
  bool anim = p_zamanaBagl > 0.5 && p_dondur < 0.5; float tk = anim ? floor(u_t * 30.0 / max(p_yenilenme, 1.0)) : 0.0; float sd = seedf(p_tohum);
  vec3 n;
  if (p_tur < 0.5) n = vec3(hash1(g + sd + tk), hash1(g + sd + tk + 31.0), hash1(g + sd + tk + 67.0));
  else if (p_tur < 1.5) n = vec3(hash1(g + sd + tk));
  else if (p_tur < 2.5) n = vec3(0.5 + (vnoise(g * 0.7 + tk * 13.0) - 0.5) * 1.4);
  else if (p_tur < 3.5) n = vec3(vnoise(g * 0.35 + tk * 3.7 + sd));
  else n = vec3(hash1(floor(g / 4.0) + sd + tk));
  n = (n - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5;
  vec3 c = unpre(s); float l = luma(c); float tone = (1.0 - smoothstep(0.0, 0.4, l)) * p_golgeYog + (1.0 - abs(l - 0.5) * 2.0) * p_ortaYog + smoothstep(0.6, 1.0, l) * p_acikYog;
  float tw = tone / max(1.0 - smoothstep(0.0, 0.4, l) + (1.0 - abs(l - 0.5) * 2.0) + smoothstep(0.6, 1.0, l), 1e-3) / 100.0;
  float k = p_miktar / 100.0 * tw; vec3 r = mix(c, p_tur > 1.5 && p_tur < 2.5 ? overlayB(c, n) : n, clamp(k, 0.0, 1.0));
  float a = p_alfayiEtki > 0.5 ? max(s.a, k * n.r) : s.a; o = pre(clamp(r, 0.0, 1.0), a);
}
//== blocknoise
uniform float p_blokBoyu, p_renkCesi, p_yogunluk, p_yenilenm, p_tohum, p_tekRenk, p_guc, p_dondur, p_ucDeger, p_parlakUst, p_karistir, p_tohumAK; uniform vec2 p_esnet, p_kaydir;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 bs = max(p_blokBoyu, 1.0) * max(p_esnet, vec2(1.0)) / 100.0; vec2 id = floor((toUnit(here()) - p_kaydir) / bs);
  float tk = p_dondur > 0.5 ? 0.0 : floor(u_t * p_yenilenm); float sd = seedf(p_tohumAK > 0.5 ? floor(p_tohum) : p_tohum);
  float on = step(hash1(id + tk * 7.1 + sd), p_yogunluk / 100.0);
  float v = hash1(id + tk + sd + 3.0); if (p_ucDeger > 0.5) v = step(0.5, v);
  vec3 c = p_tekRenk > 0.5 ? vec3(v) : mix(vec3(hash1(id + tk + 1.0)), hsv2rgb(vec3(hash1(id + tk + 5.0 + sd), 0.9, 0.95)), p_renkCesi / 100.0);
  if (p_ucDeger > 0.5 && p_tekRenk < 0.5) c = step(0.5, c); c = min(c * p_parlakUst / 100.0, vec3(2.0));
  vec3 b = unpre(s); vec3 r = p_karistir < 0.5 ? c : p_karistir < 1.5 ? b * c : p_karistir < 2.5 ? screenB(b, c) : b + c;
  float k = on * p_guc / 100.0; o = pre(clamp(mix(b, r, k), 0.0, 1.0), p_karistir < 0.5 ? max(s.a, k) * step(0.001, s.a + (p_karistir < 0.5 ? 1.0 : 0.0)) * s.a + 0.0 : s.a);
  if (p_karistir < 0.5) o = overPre(vec4(c, 1.0) * k * s.a, s * (1.0 - k));
}
//== cellpattern
uniform float p_hucreBoyu, p_desen, p_kenarKali, p_evrim, p_tohum, p_kenarYumu, p_duzensiz, p_esneklik, p_bosluk, p_kabartma, p_renklendir, p_merkezGoster; uniform vec2 p_oran; uniform vec3 c_renk1, c_renk2;
vec4 vor(vec2 p, float jit) { vec2 i = floor(p), f = fract(p); float d1 = 8.0, d2 = 8.0; vec2 id = vec2(0.0), cpos = vec2(0.0);
  for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) { vec2 g = vec2(float(x), float(y)); vec2 o2 = mix(vec2(0.5), hash2(i + g), jit); o2 += (vec2(sin(p_evrim * 0.05 + hash1(i + g) * 6.0), cos(p_evrim * 0.05 + hash1(i + g + 1.0) * 6.0))) * 0.15 * p_esneklik / 100.0;
    vec2 r = g + o2 - f; float d = dot(r, r); if (d < d1) { d2 = d1; d1 = d; id = i + g; cpos = r; } else if (d < d2) d2 = d; }
  return vec4(sqrt(d1), sqrt(d2), id); }
void main() {
  vec2 p = toUnit(here()) / (max(p_hucreBoyu, 1.0) * max(p_oran, vec2(1.0)) / 100.0) + seedf(p_tohum);
  vec4 v = vor(p, p_duzensiz / 100.0); float edge = v.y - v.x; float w = p_kenarKali / max(p_hucreBoyu, 1.0) + p_bosluk / max(p_hucreBoyu, 1.0); float aa = p_kenarYumu > 0.5 ? 0.04 : 0.005;
  float k; if (p_desen < 0.5) k = smoothstep(w - aa, w + aa, edge); else if (p_desen < 1.5) k = 1.0 - smoothstep(0.0, 0.7, v.x); else if (p_desen < 2.5) k = mix(0.3, 1.0, hash1(v.zw)) * smoothstep(w - aa, w + aa, edge); else k = step(0.5, hash1(v.zw)) * 0.6 + 0.4 * smoothstep(w - aa, w + aa, edge);
  vec3 cell = c_renk2;
  if (p_renklendir > 0.5 && p_renklendir < 1.5) cell = hsv2rgb(vec3(hash1(v.zw), 0.6, 0.9)); else if (p_renklendir > 1.5 && p_renklendir < 2.5) cell = unpre(texU((v.zw + 0.5 - seedf(p_tohum)) * max(p_hucreBoyu, 1.0))); else if (p_renklendir > 2.5) cell = mix(c_renk1, c_renk2, hash1(v.zw));
  vec3 col = mix(c_renk1, cell, k); col *= 1.0 + (0.5 - v.x) * p_kabartma / 100.0 * 0.8;
  if (p_bosluk > 0.0) { float gap = 1.0 - smoothstep(0.0, p_bosluk / max(p_hucreBoyu, 1.0) + 0.01, edge); col = mix(col, c_renk1, gap); }
  if (p_merkezGoster > 0.5) col = mix(col, vec3(1.0), 1.0 - smoothstep(0.03, 0.06, v.x));
  o = genOver(vec4(col, 1.0));
}
//== chromakey
uniform vec3 c_anahtarReng, c_anahtar2, c_anahtar3; uniform float p_tolerans, p_yumusakl, p_renkTasm, p_kenarDara, p_matiGost, p_ters, p_yontem, p_siyahAlfa, p_beyazAlfa, p_yariSaydam, p_kenarTemiz, p_ayrintiKoru, p_cokluAnahtar, p_anahtar3Acik, p_onizleme;
float dist1(vec3 c, vec3 k) {
  if (p_yontem > 0.5 && p_yontem < 1.5) return distance(c, k) * 0.6;
  if (p_yontem > 1.5) { vec3 a = rgb2hsv(c), b = rgb2hsv(k); return length(vec3(min(abs(a.x - b.x), 1.0 - abs(a.x - b.x)) * 2.0, (a.y - b.y) * 0.5, (a.z - b.z) * 0.25)) * 0.6; }
  vec2 cc = vec2(dot(c, vec3(-0.169, -0.331, 0.5)), dot(c, vec3(0.5, -0.419, -0.081))), kc = vec2(dot(k, vec3(-0.169, -0.331, 0.5)), dot(k, vec3(0.5, -0.419, -0.081))); return distance(cc, kc); }
float keyA(vec2 px) { vec4 s = texPx(px); vec3 c = unpre(s); float d = dist1(c, c_anahtarReng);
  if (p_cokluAnahtar > 0.5) { d = min(d, dist1(c, c_anahtar2)); if (p_anahtar3Acik > 0.5) d = min(d, dist1(c, c_anahtar3)); }
  float tol = p_tolerans / 100.0 * 0.4; float a = smoothstep(tol, tol + p_yumusakl / 100.0 * 0.3 + 0.005, d);
  a = clamp((a - p_siyahAlfa / 100.0) / max((p_beyazAlfa - p_siyahAlfa) / 100.0, 0.01), 0.0, 1.0); a = mix(step(0.5, a), a, p_yariSaydam / 100.0 * 2.0 > 1.0 ? 1.0 : p_yariSaydam / 50.0);
  if (p_ters > 0.5) a = 1.0 - a; return a * s.a; }
void main() {
  vec4 s = texture(u_tex, v_uv); float a = keyA(here());
  if (abs(p_kenarDara) > 0.1 || p_kenarTemiz > 0.0) { float r = max(abs(p_kenarDara), p_kenarTemiz * 0.05) * u_s; float m = a, mn = a; for (int i = 0; i < 8; i++) { float an = float(i) * TAU / 8.0; float x = keyA(here() + vec2(cos(an), sin(an)) * r); m = p_kenarDara < 0.0 ? min(m, x) : max(m, x); mn = min(mn, x); }
    a = abs(p_kenarDara) > 0.1 ? m : a; if (p_kenarTemiz > 0.0) a = mix(a, mn, p_kenarTemiz / 100.0 * (p_ayrintiKoru > 0.5 ? 0.5 : 1.0)); }
  if (p_matiGost > 0.5 || (p_onizleme > 0.5 && p_onizleme < 1.5)) { o = vec4(vec3(a), 1.0); return; }
  vec3 c = unpre(s); vec3 k = normalize(c_anahtarReng + 1e-3); float spill = max(0.0, dot(c, k) - dot(c, vec3(1.0) - k) * 0.5) * p_renkTasm / 100.0; c -= k * spill * 0.6; c += vec3(spill * 0.3);
  vec4 r = pre(clamp(c, 0.0, 1.0), a);
  if (p_onizleme > 1.5) r = overPre(r, p_onizleme < 2.5 ? vec4(0.0, 0.0, 0.0, 1.0) : vec4(1.0));
  o = r;
}
//== solidmatte
uniform sampler2D s_ozelGorsel; uniform float p_ozelGorselOn;
uniform vec3 c_matReng, c_renk2, c_renklendirRenk; uniform float p_opaklik, p_yalnizSaydAlan, p_mevcutAlfaKoru, p_dolguMod, p_bgBulanik, p_bgDoyg, p_bgParlak, p_bgGama, p_bgRenklendir, p_onYumu, p_onOpak, p_onOlcek, p_bgOlcek, p_taramaGuc, p_taramaSayi;
uniform vec2 p_onKay, p_bgKay;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float inBox = step(0.0, b.x) * step(b.x, 1.0) * step(0.0, b.y) * step(b.y, 1.0);
  if (p_dolguMod < 1.5) { vec3 bc = p_dolguMod < 0.5 ? c_matReng : mix(c_matReng, c_renk2, clamp(b.y, 0.0, 1.0)); vec4 m = vec4(bc, 1.0) * p_opaklik / 100.0 * inBox;
    vec4 r = p_yalnizSaydAlan > 0.5 ? overPre(s, m) : mix(s, m, p_opaklik / 100.0); if (p_mevcutAlfaKoru > 0.5) r = pre(unpre(r), s.a); o = r; return; }
  // Arka plan doldurma: katmanın bulanık kopyası (ya da özel görsel) kutuyu doldurur, ön plan üstte
  vec2 cb = (b - 0.5 - p_bgKay / boxU()) / max(p_bgOlcek / 100.0, 0.01) + 0.5;
  vec4 bg;
  if (p_dolguMod > 2.5 && p_ozelGorselOn > 0.5) bg = texture(s_ozelGorsel, clamp(cb, 0.0, 1.0));
  else { // içerik kutusunun dolu kısmından örnek: kenarlara uzatılmış, büyütülmüş ve bulanık
    vec2 cc = (cb - 0.5) * 0.7 + 0.5; float R = p_bgBulanik / max(boxU().x, 1.0); vec4 acc = vec4(0.0); float ws = 0.0;
    for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 f = vec2(float(i), float(j)) / 3.0; float w = exp(-dot(f, f) * 2.0); acc += texPx(boxPx(clamp(cc + f * R, 0.0, 1.0))) * w; ws += w; } bg = acc / ws; }
  vec3 bc = bg.a > 0.0 ? bg.rgb / bg.a : c_matReng; bc = satAdj(bc, 1.0 + p_bgDoyg / 100.0); bc += p_bgParlak / 100.0 * 0.5; bc = pow(clamp(bc, 0.0, 1.0), vec3(1.0 / max(p_bgGama, 0.01)));
  bc = mix(bc, c_renklendirRenk * luma(bc) * 1.5, p_bgRenklendir / 100.0); bc *= 1.0 - p_taramaGuc / 100.0 * 0.5 * step(0.5, fract(b.y * p_taramaSayi * 0.5));
  vec2 fb = (b - 0.5 - p_onKay / boxU()) / max(p_onOlcek / 100.0, 0.01) + 0.5; vec4 fg = texPx(boxPx(fb)) * step(0.0, fb.x) * step(fb.x, 1.0) * step(0.0, fb.y) * step(fb.y, 1.0);
  if (p_onYumu > 0.0) { float e = min(min(fb.x, 1.0 - fb.x), min(fb.y, 1.0 - fb.y)) * boxU().x; fg *= smoothstep(0.0, p_onYumu, e); }
  o = overPre(fg * p_onOpak / 100.0, vec4(clamp(bc, 0.0, 1.0), 1.0) * inBox * p_opaklik / 100.0);
}
//== fractalnoise
uniform float p_fraktalTuru, p_olcek, p_kontrast, p_parlakli, p_karmasik, p_evrim, p_tohum, p_ters, p_orantili, p_altOlcek, p_altEtki, p_altDonus, p_evrimHiz, p_dongu, p_donguSure, p_gorunum;
uniform vec2 p_kayma, p_olcekXY, p_altKayma; uniform vec3 c_koyuRenk, c_acikRenk;
void main() {
  vec2 so = max(p_olcekXY, vec2(1.0)) / 100.0; if (p_orantili > 0.5) so = vec2(so.x);
  vec2 p = (toUnit(here()) + p_kayma) / (max(p_olcek, 1.0) * so) + seedf(p_tohum); float ev = radians(p_evrim + p_evrimHiz * u_t);
  if (p_dongu > 0.5) ev = TAU * fract(u_t / max(p_donguSure, 0.1)) + radians(p_evrim);
  vec2 evv = vec2(cos(ev), sin(ev)) * 0.8; float s = 0.0, a = 0.5, n = 0.0; vec2 q = p; float sub = max(p_altOlcek, 1.0) / 100.0; float inf = p_altEtki / 100.0 * 2.0;
  for (int i = 0; i < 10; i++) { if (float(i) >= p_karmasik) break; float v;
    if (p_gorunum < 0.5 && p_fraktalTuru < 0.5) v = pnoise(q + evv * float(i + 1)) * 0.5 + 0.5; else if (p_gorunum > 2.5 && p_gorunum < 3.5 || p_fraktalTuru > 1.5) v = pow(1.0 - abs(pnoise(q + evv)), 3.0);
    else if (p_gorunum > 1.5 && p_gorunum < 2.5) v = hash1(floor(q * 2.0) + float(i)); else if (p_gorunum > 3.5) v = voronoi(q + evv).x; else v = abs(pnoise(q + evv * float(i + 1)));
    if (p_gorunum > 0.5 && p_gorunum < 1.5) v = smoothstep(0.35, 0.65, v);
    s += v * a; n += a; q = rot2(p_altDonus) * q / sub + 7.7 + p_altKayma * 0.01; a *= 0.5 * inf; }
  float v = s / max(n, 1e-4); v = (v - 0.5) * p_kontrast / 100.0 + 0.5 + p_parlakli / 100.0; v = clamp(v, 0.0, 1.0); if (p_ters > 0.5) v = 1.0 - v;
  o = genOver(vec4(mix(c_koyuRenk, c_acikRenk, v), 1.0));
}
//== linwipe
uniform float p_ilerleme, p_aci, p_yumusatm, p_ters, p_mod, p_basSinir, p_bitSinir, p_sinirBagla, p_kenarCizgi, p_kenarKalin, p_kenarParla, p_parlaBuyu; uniform vec3 c_kenarRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 d = vec2(cos(radians(p_aci)), sin(radians(p_aci))); vec2 B = boxU(); float span = abs(d.x) * B.x + abs(d.y) * B.y + p_yumusatm * 2.0;
  float x = dot(toUnit(here()), d) / span + 0.5; float lo = p_basSinir / 100.0, hi = p_sinirBagla > 0.5 ? 1.0 - lo : p_bitSinir / 100.0;
  float e = mix(lo, hi, p_ilerleme / 100.0); float w = p_yumusatm / span * 0.5 + 1e-4; float k, dist;
  if (p_mod < 0.5) { k = smoothstep(e - w, e + w, x); dist = abs(x - e); }
  else if (p_mod < 1.5) { float h = (e - lo) * 0.5; k = smoothstep(lo + h - w, lo + h + w, x) * (1.0 - smoothstep(hi - h - w, hi - h + w, x)); dist = min(abs(x - lo - h), abs(x - hi + h)); }
  else { float c = (lo + hi) * 0.5; float h = (e - lo) * 0.5; k = smoothstep(h - w, h + w, abs(x - c)); dist = abs(abs(x - c) - h); }
  if (p_ters > 0.5) k = 1.0 - k;
  vec4 c = s * k; float px = dist * span; bool moving = p_ilerleme > 0.1 && p_ilerleme < 99.9;
  if (p_kenarCizgi > 0.5 && moving) c = overPre(vec4(c_kenarRenk, 1.0) * (1.0 - smoothstep(p_kenarKalin * 0.5, p_kenarKalin * 0.5 + 0.8, px)) * s.a, c);
  if (p_kenarParla > 0.5 && moving) { float g = exp(-px / max(p_parlaBuyu * 0.4, 0.5)) * s.a; c.rgb += c_kenarRenk * g * 0.8; c.a = max(c.a, g * 0.8); }
  o = c;
}
