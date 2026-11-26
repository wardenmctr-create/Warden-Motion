// Malzeme kütüphanesini kullanan efektler: Dokulandır (güncel), Kesim Altlığı, Karton Kukla
//== texturize
INCLUDE(_mat)
uniform sampler2D s_ozelDoku; uniform float p_ozelDokuOn;
uniform float p_dokuTuru, p_dokuTohum, p_dokuGucu, p_dokuOlcek, p_dokuAci, p_kaydirX, p_kaydirY, p_tekrar, p_dikisGizle, p_kabartma, p_kabartmaAci, p_kabartmaYogun, p_lif, p_buruskluk,
  p_renkleBirles, p_dokuOpak, p_tersDoku, p_sadeceAydin, p_sadeceGolge; uniform vec3 c_dokuRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  const int MAP[14] = int[14](18, 1, 3, 4, 6, 5, 7, 19, 20, 12, 10, 11, 21, 17); int id = MAP[int(clamp(p_dokuTuru, 0.0, 13.0))];
  vec2 p = rot2(-p_dokuAci) * (toUnit(here()) - vec2(p_kaydirX, p_kaydirY)) / max(p_dokuOlcek / 100.0, 0.05); float sd = seedf(p_dokuTohum);
  vec4 sp = vec4(0.3, 0.6, 0.0, 0.5); float fib = p_lif / 100.0, cr = p_buruskluk / 100.0;
  vec3 mc; float h;
  if (id == 17) { vec2 tuv = p / 200.0; if (p_tekrar > 0.5) tuv = fract(tuv); else tuv = clamp(tuv + 0.5, 0.0, 1.0); vec4 t = p_ozelDokuOn > 0.5 ? texture(s_ozelDoku, tuv) : vec4(0.8); mc = unpre(t); h = luma(mc); }
  else { vec4 m = matSample(id, p, sd, sp, fib, cr); mc = m.rgb; h = m.a; }
  if (p_tersDoku > 0.5) h = 1.0 - h;
  float light = id == 17 ? 1.0 + (h - 0.5) * p_kabartma * 0.1 : matLight(id, p, sd, sp, fib, cr, p_kabartma * (0.3 + p_kabartmaYogun / 100.0 * 2.0), p_kabartmaAci);
  vec3 c = unpre(s); float l = luma(c);
  float w = p_dokuGucu / 100.0 * p_dokuOpak / 100.0; if (p_sadeceAydin > 0.5) w *= smoothstep(0.3, 0.8, l); if (p_sadeceGolge > 0.5) w *= 1.0 - smoothstep(0.2, 0.7, l);
  vec3 tint = mc / max(matBase(id), vec3(0.05)) * c_dokuRenk; // doku açık-koyu değişimi (doğal renk 1'e yakın)
  vec3 r = p_renkleBirles > 0.5 ? c * mix(vec3(1.0), tint * light, w) : mix(c, mc * c_dokuRenk * light, w);
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
//== cutback
INCLUDE(_mat)
uniform sampler2D s_ozelDoku; uniform float p_ozelDokuOn; uniform float u_rot;
uniform float p_kalinlik, p_disaBuyut, p_alfaYorum, p_alfaEsik, p_kusursuz, p_basitles, p_delikKapat, p_inceKoru, p_ofsX, p_ofsY, p_birlikteDondur, p_birlikteOlcek,
  p_kenarStili, p_kenarSert, p_koseYumu, p_kenarGurultu, p_cokgen, p_dolguTuru, p_dokuGucu, p_dokuOlcek, p_dokuAci, p_dogalRenk, p_malzOpak, p_yuzeyYuks, p_puruz, p_parlak, p_lif, p_kenarAsin, p_malzKalin, p_sekleSabit,
  p_olukGeni, p_olukDerin, p_olukYon, p_kirisBuyu, p_kirisDerin, p_kirisYogun, p_yirtikDerin, p_lifUzun, p_damarGeni, p_damarYon, p_tuyUzun, p_tuyYogun, p_yansimaGuc, p_metalik, p_eskime, p_sararma, p_leke,
  p_golgeAcik, p_golgeAci, p_golgeUzak, p_golgeYumu, p_golgeOpak, p_sekliTakip, p_donusumTakip, p_kenarDavr, p_yenilenme, p_kenarDegis, p_kenarKarars, p_bicimHafiza, p_takipGecik, p_esneklik, p_kenarTohum, p_tohumCanl;
uniform vec2 p_dokuKonum; uniform vec3 c_malzRenk, c_ikinciRenk, c_golgeRenk; uniform float p_golgeTasma;
uniform float p_agAcik, p_agAci, p_agUzak, p_agYumu, p_agOpak; uniform vec3 c_agRenk;

float silA(vec2 px) { float a = texPx(px).a; if (p_alfaYorum < 0.5) return step(0.5, a); if (p_alfaYorum < 1.5) return a; if (p_alfaYorum < 2.5) return smoothstep(0.08, 0.55, a); return step(p_alfaEsik / 100.0, a); }
float edgeSeed() { float base = seedf(p_kenarTohum); if (p_kenarDavr < 0.5 || p_tohumCanl < 0.5) return base; float tick = floor(u_t * 30.0 / max(p_yenilenme, 1.0)); return base + tick * 7.13 * (1.0 - p_bicimHafiza / 100.0 * 0.85); }
vec2 edgeWarp(vec2 q, float R) {
  float sd0 = seedf(p_kenarTohum), sd1 = edgeSeed(); float imp = 1.0 - p_kusursuz / 100.0;
  float st = p_kenarStili; float f = st < 2.5 ? 1.0 / max(R * 4.0, 4.0) : st < 3.5 ? 1.0 / max(R * 3.0, 4.0) : st < 4.5 ? 1.0 / max(R * 0.6, 1.5) : 1.0 / max(R * 6.0, 6.0);
  float amp = R * (imp * (st < 0.5 ? 0.0 : st < 2.5 ? 0.25 : st < 3.5 ? 0.6 : st < 4.5 ? 0.7 : 0.8) + (p_kusursuz < 99.95 ? p_kenarGurultu / 100.0 * 0.5 : 0.0));
  vec2 n0 = vec2(pnoise(q * f + sd0), pnoise(q * f + sd0 + 17.3)); vec2 n1 = vec2(pnoise(q * f + sd1), pnoise(q * f + sd1 + 17.3));
  vec2 n = mix(n0, n1, p_kenarDavr > 0.5 && p_kusursuz < 99.95 ? p_kenarDegis / 100.0 * 2.0 : 0.0); // %100 kusursuzlukta dinamik bozulma yok
  n += (hash2(floor(q / max(R * 0.6, 1.0)) + floor(u_t * 30.0 / max(p_yenilenme, 1.0))) - 0.5) * p_kenarKarars / 100.0 * 0.6 * step(0.5, p_kenarDavr);
  if (st > 3.5 && st < 4.5) n += vec2(pnoise(q * f * 3.0 + sd1 + 5.0), pnoise(q * f * 3.0 + sd1 + 9.0)) * 0.5;
  return n * amp;
}
float backMask(vec2 px, float Rpx) {
  vec2 q = toUnit(px); float R = Rpx / u_s;
  vec2 pd = px + edgeWarp(q, max(R, 1.0)) * u_s;
  float poly = p_kenarStili > 1.5 && p_kenarStili < 2.5 ? max(0.6, p_cokgen / 100.0) : p_cokgen / 100.0 * (p_kenarStili > 2.5 && p_kenarStili < 3.5 ? 0.6 : 0.0);
  if (poly > 0.01) { float cell = max(Rpx * 1.5, 3.0); vec2 sn = (floor(pd / cell) + 0.5) * cell; pd = mix(pd, sn, poly * 0.5); }
  float m = silA(pd); float rr = Rpx * (1.0 + p_basitles / 100.0 * 0.3);
  for (int k = 1; k <= 3; k++) { float r = rr * float(k) / 3.0; for (int i = 0; i < 16; i++) { float a = float(i) * TAU / 16.0 + float(k) * 0.37; m = max(m, silA(pd + vec2(cos(a), sin(a)) * r)); } }
  float soft = mix(0.5, 0.02, p_kenarSert / 100.0) + p_koseYumu / 100.0 * 0.2 + (p_kenarStili > 0.5 && p_kenarStili < 1.5 ? 0.25 : 0.0);
  return smoothstep(0.5 - soft, 0.5 + soft, m);
}
vec4 backShadowAt(vec2 bp, float R) { if (p_agAcik < 0.5) return vec4(0.0); float a = radians(p_agAci); vec2 so = vec2(cos(a), sin(a)) * p_agUzak * u_s;
  float sm = backMask(bp - so, R + p_agYumu * u_s * 0.6); float core = backMask(bp - so, max(R - p_agYumu * u_s * 0.3, 0.0)); float k = mix(sm, core, 0.5);
  return vec4(c_agRenk, 1.0) * k * p_agOpak / 100.0; }
vec4 spFor(int id) {
  if (id == 4) return vec4(p_olukGeni / 40.0, p_olukDerin / 100.0, p_olukYon / 180.0, 0.0); if (id == 7) return vec4(p_kirisBuyu / 200.0, p_kirisDerin / 100.0, p_kirisYogun / 100.0, 0.0);
  if (id == 12) return vec4(p_damarGeni / 40.0, p_damarYon / 180.0, 0.0, 0.0); if (id == 10) return vec4(p_tuyUzun / 20.0, p_tuyYogun / 100.0, 0.0, 0.0);
  if (id == 14) return vec4(p_yansimaGuc / 100.0, p_metalik / 100.0, 0.0, 0.0); if (id == 9) return vec4(p_eskime / 100.0, p_sararma / 100.0, p_leke / 100.0, 0.0); return vec4(0.3, 0.6, 0.5, 0.0); }
void main() {
  vec4 s = texture(u_tex, v_uv);
  const int MAP[19] = int[19](0, 22, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17); int id = MAP[int(clamp(p_dolguTuru, 0.0, 18.0))];
  vec2 ofs = vec2(p_ofsX, p_ofsY); if (p_birlikteDondur < 0.5 || p_donusumTakip < 0.5) ofs = rot2(-u_rot) * ofs;
  float R = p_kalinlik * u_s; vec2 bp = here() - ofs * u_s;
  float m = backMask(bp, R); vec4 bsh = backShadowAt(bp, R); if (m <= 0.001 && p_malzKalin < 0.5 && (p_golgeTasma > 0.5 || p_golgeAcik < 0.5)) { o = overPre(s, bsh); return; }
  // malzeme
  vec2 q = toUnit(bp); vec2 tp = rot2(-p_dokuAci) * (q - p_dokuKonum) / max(p_dokuOlcek / 100.0, 0.05); if (p_sekleSabit < 0.5) tp += vec2(u_t * 0.0);
  vec4 sp = spFor(id); float fib = p_lif / 100.0; vec3 base; float lit = 1.0;
  if (id == 22) base = mix(c_malzRenk, c_ikinciRenk, clamp(boxUV(bp).y, 0.0, 1.0));
  else if (id == 17) { vec4 t = p_ozelDokuOn > 0.5 ? texture(s_ozelDoku, fract(tp / 200.0)) : vec4(0.8); base = unpre(t); }
  else { vec4 mt = matSample(id, tp, seedf(p_kenarTohum) * 0.0 + 3.0, sp, fib, 0.0); vec3 nat = mt.rgb;
    vec3 tinted = c_malzRenk * (nat / max(matBase(id), vec3(0.05)));
    base = id == 0 ? c_malzRenk : mix(p_dogalRenk > 0.5 ? matBase(id) : c_malzRenk, p_dogalRenk > 0.5 ? nat : tinted, p_dokuGucu / 100.0);
    if (id != 0) lit = matLight(id, tp, 3.0, sp, fib, 0.0, p_yuzeyYuks * (0.4 + p_puruz / 100.0 * 1.6), 135.0); }
  if (id == 14) base += vec3(0.25) * sp.x * pow(max(0.0, sin(tp.y * 0.03 + tp.x * 0.01)), 8.0);
  vec3 col = base * lit + vec3(p_parlak / 100.0 * 0.25) * pow(max(lit - 1.0, 0.0), 1.0) * 2.0;
  // kenar aşınması ve yırtık kenar lifleri
  float inner = backMask(bp, R * 0.82); float band = clamp(m - inner, 0.0, 1.0);
  col = mix(col, mix(col, vec3(0.97, 0.95, 0.9), 0.6), band * p_kenarAsin / 100.0 * (0.5 + hash1(floor(q * 2.0))));
  if (id == 8) col = mix(col, vec3(0.98, 0.97, 0.94), band * 0.8);
  // içerik gölgesi
  if (p_golgeAcik > 0.5) { float a = radians(p_golgeAci); vec2 so = vec2(cos(a), sin(a)) * p_golgeUzak * u_s; float sh = 0.0; float rr = max(p_golgeYumu * u_s, 0.5);
    for (int i = 0; i < 12; i++) { float an = float(i) * TAU / 12.0; sh += texPx(here() - so + vec2(cos(an), sin(an)) * rr * (0.4 + 0.6 * fract(float(i) * 0.618))).a; } sh = sh / 12.0 * p_golgeOpak / 100.0;
    col = mix(col, col * c_golgeRenk * 1.4, sh); if (p_golgeTasma < 0.5) bsh = overPre(vec4(c_golgeRenk, 1.0) * sh * (1.0 - m), bsh); }
  vec4 back = pre(clamp(col, 0.0, 1.0), m * p_malzOpak / 100.0);
  // malzeme kalınlığı: altlığın yan yüzü
  if (p_malzKalin > 0.1) { float side = backMask(bp - vec2(0.0, p_malzKalin) * u_s * 0.7 - vec2(p_malzKalin) * u_s * 0.3, R); back = overPre(back, pre(base * 0.62, side * (1.0 - m) * p_malzOpak / 100.0)); }
  o = overPre(s, overPre(back, bsh));
}
//== cardpuppet
INCLUDE(_mat)
uniform sampler2D s_ozelDoku, s_altlikOzel; uniform float p_ozelDokuOn, p_altlikOzelOn; uniform float u_rot;
uniform float p_orijKoru, p_dokuTuru, p_dokuGucu, p_dokuOlcek, p_dokuAci, p_dokuOpak, p_dokuKontrast, p_dokuParlak, p_kabarti, p_lif, p_renkleBirles,
  p_altlikAcik, p_kalinlik, p_ofsX, p_ofsY, p_altlikDoku, p_altlikDokuGuc, p_altlikKabarti, p_disaBuyut, p_kenarStili, p_kusursuz, p_takipSadakat, p_kenarSert, p_koseYumu,
  p_kenarDavr, p_yenilenme, p_kenarDegis, p_kenarKarars, p_bicimHafiza, p_kenarTohum, p_tohumCanl, p_golgeAcik, p_golgeAci, p_golgeUzak, p_golgeYumu, p_golgeOpak;
uniform vec3 c_altlikRenk, c_golgeRenk;
uniform float p_agAcik, p_agAci, p_agUzak, p_agYumu, p_agOpak; uniform vec3 c_agRenk;

float edgeSeed() { float base = seedf(p_kenarTohum); if (p_kenarDavr < 0.5 || p_tohumCanl < 0.5) return base; float tick = floor(u_t * 30.0 / max(p_yenilenme, 1.0)); return base + tick * 7.13 * (1.0 - p_bicimHafiza / 100.0 * 0.85); }
float backMask(vec2 px, float Rpx) {
  vec2 q = toUnit(px); float R = max(Rpx / u_s, 1.0); float imp = 1.0 - p_kusursuz / 100.0; float st = p_kenarStili;
  float f = st < 2.5 ? 1.0 / (R * 4.0) : st < 3.5 ? 1.0 / (R * 3.0) : st < 4.5 ? 1.0 / max(R * 0.6, 1.5) : 1.0 / (R * 6.0);
  float amp = R * imp * (st < 0.5 ? 0.0 : st < 2.5 ? 0.25 : st < 3.5 ? 0.6 : st < 4.5 ? 0.7 : 0.8) * mix(1.3, 0.7, p_takipSadakat / 100.0);
  float sd0 = seedf(p_kenarTohum), sd1 = edgeSeed();
  vec2 n = mix(vec2(pnoise(q * f + sd0), pnoise(q * f + sd0 + 17.3)), vec2(pnoise(q * f + sd1), pnoise(q * f + sd1 + 17.3)), p_kenarDavr > 0.5 ? p_kenarDegis / 100.0 * 2.0 : 0.0);
  n += (hash2(floor(q / max(R * 0.6, 1.0)) + floor(u_t * 30.0 / max(p_yenilenme, 1.0))) - 0.5) * p_kenarKarars / 100.0 * 0.6 * step(0.5, p_kenarDavr);
  vec2 pd = px + n * amp * u_s;
  if (st > 1.5 && st < 3.5) { float cell = max(Rpx * 1.5, 3.0); pd = mix(pd, (floor(pd / cell) + 0.5) * cell, st < 2.5 ? 0.35 : 0.15); }
  float m = smoothstep(0.08, 0.55, texPx(pd).a);
  for (int k = 1; k <= 3; k++) { float r = Rpx * float(k) / 3.0; for (int i = 0; i < 16; i++) { float a = float(i) * TAU / 16.0 + float(k) * 0.37; m = max(m, smoothstep(0.08, 0.55, texPx(pd + vec2(cos(a), sin(a)) * r).a)); } }
  float soft = mix(0.5, 0.02, p_kenarSert / 100.0) + p_koseYumu / 100.0 * 0.2 + (st > 0.5 && st < 1.5 ? 0.25 : 0.0);
  return smoothstep(0.5 - soft, 0.5 + soft, m);
}
vec4 backShadowAt(vec2 bp, float R) { if (p_agAcik < 0.5) return vec4(0.0); float a = radians(p_agAci); vec2 so = vec2(cos(a), sin(a)) * p_agUzak * u_s;
  float sm = backMask(bp - so, R + p_agYumu * u_s * 0.6); float core = backMask(bp - so, max(R - p_agYumu * u_s * 0.3, 0.0)); float k = mix(sm, core, 0.5);
  return vec4(c_agRenk, 1.0) * k * p_agOpak / 100.0; }
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here());
  // üst doku
  const int TOP[8] = int[8](3, 4, 6, 5, 7, 1, 17, 10); int id = TOP[int(clamp(p_dokuTuru, 0.0, 7.0))];
  vec2 tp = rot2(-p_dokuAci) * q / max(p_dokuOlcek / 100.0, 0.05); vec4 sp = vec4(0.3, 0.6, 0.0, 0.0); float fib = p_lif / 100.0;
  vec4 obj = s;
  if (s.a > 0.0) {
    vec3 mc; float lit;
    if (id == 17) { vec4 t = p_ozelDokuOn > 0.5 ? texture(s_ozelDoku, fract(tp / 200.0)) : vec4(0.8); mc = unpre(t); lit = 1.0 + (luma(mc) - 0.5) * p_kabarti * 0.08; }
    else { mc = matSample(id, tp, 2.0, sp, fib, 0.0).rgb; lit = matLight(id, tp, 2.0, sp, fib, 0.0, p_kabarti * 0.8, 135.0); }
    vec3 tex = (mc / max(matBase(id), vec3(0.05)) - 1.0) * (1.0 + p_dokuKontrast / 100.0) + 1.0 + p_dokuParlak / 100.0 * 0.5;
    vec3 c = unpre(s); float w = p_dokuGucu / 100.0 * (p_dokuOpak / 100.0) * 1.4;
    vec3 r = p_renkleBirles > 0.5 ? c * mix(vec3(1.0), tex * lit, clamp(w, 0.0, 1.0)) : mix(c, mc * lit, clamp(w, 0.0, 1.0));
    obj = pre(clamp(mix(r, c, p_orijKoru / 100.0), 0.0, 1.0), s.a);
  }
  if (p_altlikAcik < 0.5) { o = obj; return; }
  vec2 ofs = vec2(p_ofsX, p_ofsY); vec2 bp = here() - ofs * u_s; float m = backMask(bp, p_kalinlik * u_s); vec4 bsh = backShadowAt(bp, p_kalinlik * u_s); if (m <= 0.001) { o = overPre(obj, bsh); return; }
  const int BK[8] = int[8](3, 4, 6, 5, 7, 0, 17, 10); int bid = BK[int(clamp(p_altlikDoku, 0.0, 7.0))]; vec2 bq = toUnit(bp) / max(p_dokuOlcek / 100.0, 0.05);
  vec3 bc; float bl = 1.0;
  if (bid == 0) bc = c_altlikRenk; else if (bid == 17) { vec4 t = p_altlikOzelOn > 0.5 ? texture(s_altlikOzel, fract(bq / 200.0)) : vec4(0.8); bc = unpre(t); }
  else { vec3 nat = matSample(bid, bq, 5.0, sp, fib, 0.0).rgb; bc = mix(c_altlikRenk, c_altlikRenk * (nat / max(matBase(bid), vec3(0.05))), p_altlikDokuGuc / 100.0); bl = matLight(bid, bq, 5.0, sp, fib, 0.0, p_altlikKabarti * 0.8, 135.0); }
  vec3 col = bc * bl;
  if (p_golgeAcik > 0.5) { float a = radians(p_golgeAci); vec2 so = vec2(cos(a), sin(a)) * p_golgeUzak * u_s; float sh = 0.0; float rr = max(p_golgeYumu * u_s, 0.5);
    for (int i = 0; i < 12; i++) { float an = float(i) * TAU / 12.0; sh += texPx(here() - so + vec2(cos(an), sin(an)) * rr * (0.4 + 0.6 * fract(float(i) * 0.618))).a; } sh = sh / 12.0 * p_golgeOpak / 100.0;
    col = mix(col, col * c_golgeRenk * 1.4, sh); }
  o = overPre(obj, overPre(pre(clamp(col, 0.0, 1.0), m), bsh));
}
