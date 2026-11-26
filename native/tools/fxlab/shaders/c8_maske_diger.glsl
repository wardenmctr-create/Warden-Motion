// Maske ve Anahtar, Opaklık, Diğer (rehberdeki ayarlar)
//== vignette
uniform vec2 p_merkez; uniform float p_yaricap, p_yumusakl, p_guc, p_bicim, p_enBoy, p_ters; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 r = (toUnit(here()) - p_merkez) / (boxU() * 0.5); float d;
  if (p_bicim < 0.5) d = length(r); else if (p_bicim < 1.5) d = length(r * vec2(boxU().x / boxU().y, 1.0) * vec2(1.0 / max(p_enBoy, 0.1), 1.0)); else d = max(abs(r.x), abs(r.y));
  float R = p_yaricap / 100.0 * 1.2; float k = smoothstep(R * (1.0 - p_yumusakl / 100.0), R + 0.05, d); if (p_ters > 0.5) k = 1.0 - k;
  o = pre(mix(unpre(s), c_renk, k * p_guc / 100.0), s.a);
}
//== chromakey
uniform vec3 c_anahtarReng; uniform float p_tolerans, p_yumusakl, p_renkTasm, p_kenarDara, p_matiGost, p_ters;
float keyA(vec2 px) { vec4 s = texPx(px); vec3 c = unpre(s); vec3 k = c_anahtarReng;
  vec2 cc = vec2(dot(c, vec3(-0.169, -0.331, 0.5)), dot(c, vec3(0.5, -0.419, -0.081))), kc = vec2(dot(k, vec3(-0.169, -0.331, 0.5)), dot(k, vec3(0.5, -0.419, -0.081)));
  float d = distance(cc, kc); float tol = p_tolerans / 100.0 * 0.4; float a = smoothstep(tol, tol + p_yumusakl / 100.0 * 0.3 + 0.005, d); if (p_ters > 0.5) a = 1.0 - a; return a * s.a; }
void main() {
  vec4 s = texture(u_tex, v_uv); float a = keyA(here());
  if (abs(p_kenarDara) > 0.1) { float r = abs(p_kenarDara) * u_s; float m = a; for (int i = 0; i < 8; i++) { float an = float(i) * TAU / 8.0; float x = keyA(here() + vec2(cos(an), sin(an)) * r); m = p_kenarDara < 0.0 ? min(m, x) : max(m, x); } a = m; }
  if (p_matiGost > 0.5) { o = vec4(vec3(a), 1.0) * step(0.001, s.a + 1.0); return; }
  vec3 c = unpre(s); vec3 k = normalize(c_anahtarReng + 1e-3);
  float spill = max(0.0, dot(c, k) - dot(c, vec3(1.0) - k) * 0.5) * p_renkTasm / 100.0; c -= k * spill * 0.6; c += vec3(spill * 0.3);
  o = pre(clamp(c, 0.0, 1.0), a);
}
//== lumakey
uniform float p_esik, p_yumusakl, p_yontem, p_alfaylaCarp, p_matiGost;
void main() { vec4 s = texture(u_tex, v_uv); float l = luma(unpre(s)); float w = max(p_yumusakl / 200.0, 0.002);
  float a = smoothstep(p_esik / 100.0 - w, p_esik / 100.0 + w, l); if (p_yontem > 0.5) a = 1.0 - a; if (p_alfaylaCarp > 0.5) a *= s.a;
  if (p_matiGost > 0.5) { o = vec4(vec3(a), 1.0); return; } o = pre(unpre(s), a); }
//== solidmatte
uniform vec3 c_matReng; uniform float p_opaklik, p_yalnizSaydAlan, p_mevcutAlfaKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float inBox = step(0.0, b.x) * step(b.x, 1.0) * step(0.0, b.y) * step(b.y, 1.0);
  vec4 m = vec4(c_matReng, 1.0) * p_opaklik / 100.0 * inBox; vec4 r = p_yalnizSaydAlan > 0.5 ? overPre(s, m) : mix(s, m, p_opaklik / 100.0);
  if (p_mevcutAlfaKoru > 0.5) r = pre(unpre(r), s.a); o = r; }
//== choke
uniform float p_kenarDegi, p_yumusatm, p_yineleme, p_kanal, p_matiGost;
void main() {
  vec4 s = texture(u_tex, v_uv); float r = abs(p_kenarDegi) * u_s * clamp(p_yineleme, 1.0, 8.0) * 0.5 + 0.0;
  float a = p_kenarDegi < 0.0 ? erodeA(here(), r) : dilateA(here(), r);
  float sm = p_yumusatm * u_s; if (sm > 0.3) { float acc = 0.0; for (int i = 0; i < 8; i++) { float an = float(i) * TAU / 8.0; acc += p_kenarDegi < 0.0 ? erodeA(here() + vec2(cos(an), sin(an)) * sm, r) : dilateA(here() + vec2(cos(an), sin(an)) * sm, r); } a = (a + acc) / 9.0; }
  if (p_matiGost > 0.5) { o = vec4(vec3(a), 1.0); return; }
  vec3 c = s.a > 0.01 ? unpre(s) : unpre(texPx(here() + normalize(-alphaGrad(here(), 2.0) + 1e-5) * r));
  o = pre(c, a);
}
//== feather
uniform float p_yaricap, p_icDisDeng, p_xEkse, p_yEkse, p_kenarBici, p_ters;
void main() {
  vec4 s = texture(u_tex, v_uv); float R = max(p_yaricap * u_s, 0.5); float acc = 0.0, ws = 0.0; vec2 ax = vec2(p_xEkse > 0.5 ? 1.0 : 0.0, p_yEkse > 0.5 ? 1.0 : 0.0);
  vec2 off = normalize(alphaGrad(here(), 2.0) + 1e-5) * R * p_icDisDeng / 100.0 * 0.5;
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec2 f = vec2(float(i), float(j)) / 4.0 * ax; float w = p_kenarBici < 0.5 ? exp(-dot(f, f) * 2.0) : max(0.0, 1.0 - length(f)); acc += texPx(here() - off + f * R).a * w; ws += w; }
  float a = acc / max(ws, 1e-4); if (p_ters > 0.5) a = s.a * (1.0 - a);
  vec3 c = s.a > 0.0 ? unpre(s) : unpre(texPx(here() - alphaGrad(here(), 2.0) * R)); o = pre(c, min(a, max(s.a, a)));
}
//== alphathr
uniform float p_esik, p_gecis, p_ters, p_saydamRgbTemi;
void main() { vec4 s = texture(u_tex, v_uv); float w = max(p_gecis / 200.0, 0.002); float a = smoothstep(p_esik / 100.0 - w, p_esik / 100.0 + w, s.a); if (p_ters > 0.5) a = 1.0 - a;
  vec3 c = s.a > 0.0 ? unpre(s) : vec3(0.0); if (p_saydamRgbTemi > 0.5 && a < 0.01) c = vec3(0.0); o = pre(c, a); }
//== gradfade
uniform vec2 p_baslangi, p_bitis; uniform float p_baslangiOpak, p_bitisOpak, p_bicim, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 ab = p_bitis - p_baslangi; float t;
  if (p_bicim < 0.5) t = clamp(dot(q - p_baslangi, ab) / max(dot(ab, ab), 1.0), 0.0, 1.0); else t = clamp(length(q - p_baslangi) / max(length(ab), 1.0), 0.0, 1.0);
  if (p_ters > 0.5) t = 1.0 - t; float k = mix(p_baslangiOpak, p_bitisOpak, smoothstep(0.0, 1.0, t)) / 100.0; o = s * k; }
//== roundcorners
uniform float p_yaricap, p_solUst, p_sagUst, p_solAlt, p_sagAlt, p_koseleriBagl, p_yumusatm;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU() * 0.5;
  vec4 r4 = p_koseleriBagl > 0.5 ? vec4(p_yaricap) : vec4(p_sagUst, p_sagAlt, p_solUst, p_solAlt);
  float r = q.x > 0.0 ? (q.y > 0.0 ? r4.y : r4.x) : (q.y > 0.0 ? r4.w : r4.z); r = min(r, min(B.x, B.y));
  vec2 d2 = abs(q) - B + r; float d = length(max(d2, 0.0)) + min(max(d2.x, d2.y), 0.0) - r; float w = max(p_yumusatm, 0.5 / u_s);
  o = s * (1.0 - smoothstep(-w, w, d));
}
//== shapemask
uniform float p_sekil, p_boyutX, p_boyutY, p_aci, p_yumusatm, p_ters; uniform vec2 p_merkez;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 B = boxU() * 0.5; vec2 sz = vec2(p_boyutX, p_sekil < 0.5 || p_sekil > 2.5 ? p_boyutX : p_boyutY) / 100.0 * min(B.x, B.y);
  if (p_sekil > 0.5 && p_sekil < 2.5) sz = vec2(p_boyutX, p_boyutY) / 100.0 * B;
  vec2 p = rot2(-p_aci) * (toUnit(here()) - p_merkez); float d;
  if (p_sekil < 1.5) d = (length(p / max(sz, vec2(1.0))) - 1.0) * min(sz.x, sz.y);
  else if (p_sekil < 2.5) { vec2 q = abs(p) - sz; d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0); }
  else if (p_sekil < 3.5) d = heartSDF(p / max(sz.x, 1.0)) * sz.x;
  else { float n = 5.0; float a = atan(p.x, -p.y); float rr = length(p) / max(sz.x, 1.0); float k = cos(PI / n) / cos(mod(a + PI / n, TAU / n) - PI / n); float sp = mix(0.45, 1.0, pow(abs(cos(a * n * 0.5)), 3.0)); d = (rr - sp) * sz.x * 0.6; }
  float w = max(p_yumusatm, 0.5 / u_s); float m = 1.0 - smoothstep(-w, w, d); if (p_ters > 0.5) m = 1.0 - m;
  o = s * m;
}
//== copybg
uniform sampler2D s_kaynakKatm, s_bgsrc; uniform float p_kaynakKatmOn, p_bgsrcOn; uniform float p_kaynak, p_opaklik, p_alfaylaKirp, p_yalnizArkaPlan; uniform vec2 p_kayma;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here() - p_kayma * u_s);
  vec4 bg = (p_kaynak > 0.5 && p_kaynakKatmOn > 0.5) ? texture(s_kaynakKatm, clamp(b, 0.0, 1.0)) : (p_bgsrcOn > 0.5 ? texture(s_bgsrc, clamp(b, 0.0, 1.0)) : vec4(0.5, 0.5, 0.5, 1.0) * 0.0 + s);
  bg *= p_opaklik / 100.0; if (p_alfaylaKirp > 0.5) bg *= s.a;
  o = p_yalnizArkaPlan > 0.5 ? bg : overPre(s, bg);
}
//== scanlines
uniform float p_cizgiAral, p_kalinlik, p_aci, p_opaklik, p_kayma, p_hiz; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 p = rot2(-p_aci) * toUnit(here()); float sp = max(p_cizgiAral, 0.5);
  float y = mod(p.y + p_kayma + u_t * p_hiz, sp); float l = 1.0 - smoothstep(p_kalinlik - 0.6 / u_s, p_kalinlik + 0.6 / u_s, y);
  o = pre(mix(unpre(s), c_renk, l * p_opaklik / 100.0), s.a); }
//== vhs
uniform float p_renkKaym, p_yatayBozu, p_gren, p_taramaCizg, p_renkSolm, p_tohum, p_zamanEtik;
void main() {
  vec2 px = here(); float y = (px.y - u_box.y) / u_s; float t = u_t; float sd = seedf(p_tohum);
  float jit = (vnoise(vec2(y * 0.05, t * 3.0 + sd)) - 0.5) * p_yatayBozu * 2.0 + step(0.97, hash1(vec2(floor(y / 3.0), floor(t * 15.0) + sd))) * p_yatayBozu * 3.0;
  vec2 p = px + vec2(jit * u_s, 0.0); float ca = p_renkKaym * u_s;
  vec4 g = texPx(p); vec4 c = vec4(texPx(p + vec2(ca, 0.0)).r, g.g, texPx(p - vec2(ca, 0.0)).b, max(g.a, max(texPx(p + vec2(ca, 0.0)).a, texPx(p - vec2(ca, 0.0)).a)));
  if (c.a <= 0.0) { o = c; return; } vec3 col = c.rgb / c.a; col = mix(col, vec3(luma(col)), p_renkSolm / 100.0 * 0.6); col = mix(col, col * vec3(1.05, 0.95, 1.1), 0.5);
  col += (hash1(floor(px) + floor(t * 30.0)) - 0.5) * p_gren / 100.0 * 0.5; col *= 1.0 - p_taramaCizg / 100.0 * 0.35 * step(0.5, fract(px.y / max(u_s * 2.0, 2.0)));
  o = pre(clamp(col, 0.0, 1.0), c.a);
}
//== oldfilm
uniform float p_gren, p_cizikSayi, p_toz, p_kareTitr, p_solma, p_titresim, p_tohum; uniform vec3 c_renkTonu;
void main() {
  float fr = floor(u_t * 24.0); float sd = seedf(p_tohum); vec2 jit = (hash2(vec2(fr, sd)) - 0.5) * p_kareTitr * u_s;
  vec4 s = texPx(here() + jit); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); vec2 b = boxUV(here());
  float l = luma(c); c = mix(c, c_renkTonu * (l * 1.3), 0.7); c = mix(c, vec3(0.92, 0.88, 0.78), p_solma / 100.0 * 0.4);
  c += (hash1(floor(here() / max(u_s, 1.0)) + fr) - 0.5) * p_gren / 100.0 * 0.5;
  for (int i = 0; i < 12; i++) { if (float(i) >= p_cizikSayi) break; float x = hash1(vec2(float(i), floor(fr / 3.0) + sd)); c *= 1.0 - 0.5 * (1.0 - smoothstep(0.0, 0.0025, abs(b.x - x - sin(b.y * 5.0 + float(i)) * 0.004))); }
  float dust = step(1.0 - p_toz / 100.0 * 0.01, hash1(floor(here() / max(u_s * 2.0, 1.0)) + fr * 3.1)); c *= 1.0 - dust * 0.8;
  c *= 1.0 - p_titresim / 100.0 * 0.3 * hash1(vec2(fr, 7.0)); vec2 v = b - 0.5; c *= 1.0 - smoothstep(0.35, 0.75, length(v)) * 0.45;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== crt
uniform float p_ekranKavi, p_taramaCizg, p_rgbMask, p_parlama, p_koseKara, p_renkKaym, p_kenarKirp;
void main() {
  vec2 b = boxUV(here()) - 0.5; float k = p_ekranKavi / 100.0 * 0.5; vec2 cb = b * (1.0 + k * dot(b, b)); vec2 px = boxPx(cb + 0.5);
  if (p_kenarKirp > 0.5 && (abs(cb.x) > 0.5 || abs(cb.y) > 0.5)) { o = vec4(0.0); return; }
  float ca = p_renkKaym * u_s; vec4 g = texPx(px); vec3 c = vec3(texPx(px + vec2(ca, 0.0)).r, g.g, texPx(px - vec2(ca, 0.0)).b); float a = g.a; if (a <= 0.0) { o = vec4(0.0); return; } c /= max(a, 1e-3);
  float sl = 0.5 + 0.5 * sin((cb.y + 0.5) * u_box.w / max(u_s * 1.5, 1.5) * PI); c *= mix(1.0, sl, p_taramaCizg / 100.0);
  float m = mod(floor(here().x / max(u_s, 1.0)), 3.0); vec3 mask = m < 0.5 ? vec3(1.0, 0.7, 0.7) : m < 1.5 ? vec3(0.7, 1.0, 0.7) : vec3(0.7, 0.7, 1.0); c *= mix(vec3(1.0), mask, p_rgbMask / 100.0);
  c += c * c * p_parlama / 100.0; c *= 1.0 - smoothstep(0.3, 0.75, length(cb) * 1.2) * p_koseKara / 100.0;
  o = pre(clamp(c, 0.0, 1.0), a);
}
//== pixelsort
uniform float p_yon, p_altEsik, p_ustEsik, p_maksimumIz, p_siralama, p_tersSira, p_tohum;
float key(vec4 x) { vec3 c = unpre(x); vec3 h = rgb2hsv(c); return p_siralama < 0.5 ? luma(c) : p_siralama < 1.5 ? h.x : h.y; }
void main() {
  vec4 s = texture(u_tex, v_uv); float a = radians(p_yon); vec2 d = vec2(cos(a), sin(a)); float L = p_maksimumIz * u_s * (0.4 + 0.6 * hash1(vec2(floor(dot(here(), vec2(-d.y, d.x)) / max(u_s, 1.0)), seedf(p_tohum))));
  vec4 best = s; float bk = p_tersSira > 0.5 ? 1e9 : -1e9; float lo = p_altEsik / 100.0, hi = p_ustEsik / 100.0;
  for (int i = 0; i <= 24; i++) { float t = float(i) / 24.0; vec4 x = texPx(here() - d * L * t); float k = key(x); if (k < lo || k > hi) break;
    if ((p_tersSira < 0.5 && k > bk) || (p_tersSira > 0.5 && k < bk)) { bk = k; best = x; } }
  float ks = key(s); o = (ks >= lo && ks <= hi) ? best : s;
}
//== ascii
uniform float p_hucreBoyu, p_kaynakRenkKull, p_ters; uniform vec3 c_yaziReng, c_arkaPlanReng;
float glyphA(vec2 f, float lev) { // 0..1 yoğunluğa göre basit karakter desenleri (. : - = + * # % @)
  vec2 g = floor(f * vec2(5.0, 7.0)); float x = g.x, y = g.y; float on = 0.0; int l = int(lev * 8.99);
  if (l == 0) on = 0.0; else if (l == 1) on = float(x == 2.0 && y == 5.0); else if (l == 2) on = float(x == 2.0 && (y == 2.0 || y == 5.0));
  else if (l == 3) on = float(y == 3.0 && x > 0.0 && x < 4.0); else if (l == 4) on = float((y == 2.0 || y == 4.0) && x > 0.0 && x < 4.0);
  else if (l == 5) on = float((x == 2.0 && y > 0.0 && y < 6.0) || (y == 3.0 && x > 0.0 && x < 4.0)); else if (l == 6) on = float(abs(x - 2.0) == abs(y - 3.0) || x == 2.0 || y == 3.0) * float(y > 0.0 && y < 6.0);
  else if (l == 7) on = float((x == 1.0 || x == 3.0) || (y == 2.0 || y == 4.0)) * float(y > 0.0 && y < 6.0); else on = float(y > 0.0 && y < 6.0 && x < 5.0) * float(!(x == 2.0 && y == 3.0));
  return on; }
void main() {
  vec4 s = texture(u_tex, v_uv); float cs = max(p_hucreBoyu * u_s, 3.0); vec2 id = floor((here() - u_box.xy) / cs); vec2 f = fract((here() - u_box.xy) / cs);
  vec4 x = texPx(u_box.xy + (id + 0.5) * cs); if (s.a <= 0.0 && x.a <= 0.0) { o = vec4(0.0); return; }
  float l = luma(unpre(x)); if (p_ters > 0.5) l = 1.0 - l; float on = glyphA(f, l);
  vec3 col = p_kaynakRenkKull > 0.5 ? unpre(x) : c_yaziReng; o = pre(mix(c_arkaPlanReng, col, on), max(s.a, x.a));
}
//== colorrange
uniform float p_altTon, p_ustTon, p_altDoyg, p_ustDoyg, p_altParl, p_ustParl, p_yumusakl, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec3 h = rgb2hsv(unpre(s)); float hue = h.x * 360.0; float lo = mod(p_altTon, 360.0), hi = mod(p_ustTon, 360.0);
  float inH = lo <= hi ? step(lo, hue) * step(hue, hi) : max(step(lo, hue), step(hue, hi)); float w = p_yumusakl / 100.0 * 0.2 + 0.001;
  float inS = smoothstep(p_altDoyg / 100.0 - w, p_altDoyg / 100.0, h.y) * (1.0 - smoothstep(p_ustDoyg / 100.0, p_ustDoyg / 100.0 + w, h.y));
  float inV = smoothstep(p_altParl / 100.0 - w, p_altParl / 100.0, h.z) * (1.0 - smoothstep(p_ustParl / 100.0, p_ustParl / 100.0 + w, h.z));
  float m = inH * inS * inV; if (p_ters > 0.5) m = 1.0 - m; o = s * (1.0 - m); }
//== lincolorkey
uniform vec3 c_anahtarReng; uniform float p_benzerli, p_karisim, p_islem, p_alfaOniz;
void main() { vec4 s = texture(u_tex, v_uv); float d = distance(unpre(s), c_anahtarReng); float t = p_benzerli / 100.0 * 0.8; float m = 1.0 - smoothstep(t, t + p_karisim / 100.0 * 0.5 + 0.001, d);
  float a = p_islem < 0.5 ? s.a * (1.0 - m) : s.a * m; if (p_alfaOniz > 0.5) { o = vec4(vec3(a), 1.0); return; } o = pre(unpre(s), a); }
//== spill
uniform vec3 c_perdeReng, c_duzeltmeReng; uniform float p_bastirma, p_yontem, p_parlakliKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); vec3 k = c_perdeReng; int ch = k.g >= k.r && k.g >= k.b ? 1 : (k.b >= k.r ? 2 : 0);
  float ex = p_yontem < 0.5 ? (ch == 1 ? c.g - max(c.r, c.b) : ch == 2 ? c.b - max(c.r, c.g) : c.r - max(c.g, c.b)) : max(0.0, 0.6 - distance(c, k));
  ex = max(ex, 0.0) * p_bastirma / 100.0; vec3 r = c; if (ch == 1) r.g -= ex; else if (ch == 2) r.b -= ex; else r.r -= ex; r += (c_duzeltmeReng - 0.5) * ex;
  if (p_parlakliKoru > 0.5) r *= luma(c) / max(luma(r), 1e-3); o = pre(clamp(r, 0.0, 1.0), s.a); }
//== noisealpha
uniform float p_gurultuOlce, p_esik, p_yumusakl, p_evrim, p_tohum, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); float n = fbm(toUnit(here()) / max(p_gurultuOlce, 0.5) * 0.25 + seedf(p_tohum) + vec2(cos(radians(p_evrim)), sin(radians(p_evrim))) * 0.6, 3.0) * 0.5 + 0.5;
  float w = p_yumusakl / 200.0 + 0.005; float k = smoothstep(p_esik / 100.0 - w, p_esik / 100.0 + w, n); if (p_ters > 0.5) k = 1.0 - k; o = s * k; }
//== strobelight
uniform vec3 c_renk; uniform float p_guc, p_frekans, p_acikKalm, p_faz, p_yumusakGeci, p_kareyiKapl;
void main() { vec4 s = texture(u_tex, v_uv); float ph = fract(u_t * p_frekans + p_faz / 360.0); float d = p_acikKalm / 100.0;
  float k = p_yumusakGeci > 0.5 ? (ph < d ? sin(ph / max(d, 1e-3) * PI) : 0.0) : step(ph, d); k *= p_guc / 100.0;
  if (p_kareyiKapl > 0.5) { o = overPre(vec4(c_renk, 1.0) * k, s); return; } o = pre(mix(unpre(s), c_renk, k), s.a); }
//== fractalnoise
uniform float p_fraktalTuru, p_olcek, p_kontrast, p_parlakli, p_karmasik, p_evrim, p_tohum, p_ters; uniform vec2 p_kayma;
void main() { vec2 p = (toUnit(here()) + p_kayma) / max(p_olcek, 1.0) + seedf(p_tohum); vec2 ev = vec2(cos(radians(p_evrim)), sin(radians(p_evrim))) * 0.8;
  float s = 0.0, a = 0.5, n = 0.0; vec2 q = p;
  for (int i = 0; i < 10; i++) { if (float(i) >= p_karmasik) break; float v = pnoise(q + ev * float(i + 1)); v = p_fraktalTuru < 0.5 ? v * 0.5 + 0.5 : p_fraktalTuru < 1.5 ? abs(v) : pow(1.0 - abs(v), 3.0); s += v * a; n += a; q = q * 2.03 + 7.7; a *= 0.5; }
  float v = s / n; v = (v - 0.5) * p_kontrast / 100.0 + 0.5 + p_parlakli / 100.0; v = clamp(v, 0.0, 1.0); if (p_ters > 0.5) v = 1.0 - v;
  o = genOver(vec4(vec3(v), 1.0)); }
//== noisehls
uniform float p_tonGuru, p_aciklikGuru, p_doygunluGuru, p_tohum, p_animasyo, p_tekRenk;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 g = floor(here() / max(u_s, 1.0)); float tk = p_animasyo > 0.5 ? floor(u_t * 24.0) : 0.0; float sd = seedf(p_tohum);
  vec3 h = rgb2hsl(unpre(s)); float n1 = hash1(g + sd + tk) - 0.5, n2 = (p_tekRenk > 0.5 ? n1 : hash1(g + sd + tk + 17.0) - 0.5), n3 = (p_tekRenk > 0.5 ? n1 : hash1(g + sd + tk + 41.0) - 0.5);
  h.x = fract(h.x + n1 * p_tonGuru / 100.0); h.z = clamp(h.z + n2 * p_aciklikGuru / 100.0, 0.0, 1.0); h.y = clamp(h.y + n3 * p_doygunluGuru / 100.0, 0.0, 1.0); o = pre(hsl2rgb(h), s.a); }
//== denoise
uniform float p_gurultuAzal, p_ayrintiKoru, p_renkGuru, p_mekansalYari, p_zamansalKare, p_hareketTela;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float R = max(p_mekansalYari * u_s, 0.7); float tol = mix(0.25, 0.03, p_ayrintiKoru / 100.0); vec4 acc = vec4(0.0); float ws = 0.0;
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 f = vec2(float(i), float(j)) / 3.0; vec4 x = texPx(here() + f * R); vec3 c = unpre(x); float w = exp(-dot(f, f)) * exp(-dot(c - c0, c - c0) / (tol * tol)); acc += x * w; ws += w; }
  vec4 b = acc / ws; vec3 bc = unpre(b); vec3 r = mix(c0, bc, p_gurultuAzal / 100.0); r = mix(r, vec3(luma(r)) + (bc - vec3(luma(bc))), p_renkGuru / 100.0 * 0.5); o = pre(clamp(r, 0.0, 1.0), s.a); }
//== arithmetic
uniform float p_islem, p_kirmizi, p_yesil, p_mavi, p_alfa, p_tasmayiSini;
void main() { vec4 s = texture(u_tex, v_uv); vec4 c = vec4(unpre(s), s.a); vec4 v = vec4(p_kirmizi, p_yesil, p_mavi, p_alfa) / 100.0; vec4 r;
  if (p_islem < 0.5) r = c + v; else if (p_islem < 1.5) r = c - v; else if (p_islem < 2.5) r = c * (1.0 + v); else if (p_islem < 3.5) r = abs(c - v); else if (p_islem < 4.5) r = min(c, v + 0.5); else r = max(c, v + 0.5);
  if (p_tasmayiSini > 0.5) r = clamp(r, 0.0, 1.0); r.a = clamp(r.a, 0.0, 1.0); o = pre(r.rgb, r.a); }
//== minimax
uniform float p_islem, p_yaricap, p_kanal, p_yon;
vec4 mm(vec2 px, float R, bool mx) { vec4 best = texPx(px); float bk = mx ? -1.0 : 2.0; vec2 ax = p_yon < 0.5 ? vec2(1.0) : p_yon < 1.5 ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 f = vec2(float(i), float(j)) / 3.0 * ax; if (length(f) > 1.0) continue; vec4 x = texPx(px + f * R); float k = p_kanal < 0.5 ? luma(unpre(x)) * x.a : p_kanal < 1.5 ? x.a : luma(unpre(x)); if ((mx && k > bk) || (!mx && k < bk)) { bk = k; best = x; } } return best; }
void main() { float R = max(p_yaricap * u_s, 0.7); vec4 r;
  if (p_islem < 0.5) r = mm(here(), R, false); else if (p_islem < 1.5) r = mm(here(), R, true); else if (p_islem < 2.5) r = mix(mm(here(), R, false), mm(here(), R * 0.6, true), 0.5); else r = mix(mm(here(), R, true), mm(here(), R * 0.6, false), 0.5);
  if (p_kanal > 0.5 && p_kanal < 1.5) { vec4 s = texture(u_tex, v_uv); r = pre(s.a > 0.0 ? unpre(s) : unpre(r), r.a); } o = r; }
//== blendorig
uniform sampler2D u_src; uniform float p_karisim, p_mod, p_kaynak, p_alfaKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec4 orig = texture(u_src, v_uv); vec3 a = unpre(s), b = unpre(orig); vec3 r = p_mod < 0.5 ? b : p_mod < 1.5 ? a * b : p_mod < 2.5 ? screenB(a, b) : p_mod < 3.5 ? overlayB(a, b) : abs(a - b);
  vec3 c = mix(a, r, p_karisim / 100.0); o = pre(c, p_alfaKoru > 0.5 ? s.a : mix(s.a, orig.a, p_karisim / 100.0)); }
//== keylight
uniform vec3 c_perdeReng; uniform float p_perdeKaza, p_perdeDeng, p_siyahKirp, p_beyazKirp, p_kenarDara, p_yumusatm, p_tasmaTemi, p_gorunum;
float km(vec2 px) { vec4 s = texPx(px); vec3 c = unpre(s); vec3 k = c_perdeReng; int ch = k.g >= k.r && k.g >= k.b ? 1 : (k.b >= k.r ? 2 : 0);
  float kc = ch == 1 ? c.g : ch == 2 ? c.b : c.r; float o1 = ch == 1 ? c.r : c.g, o2 = ch == 2 ? c.r : (ch == 1 ? c.b : c.b); float bal = p_perdeDeng / 100.0;
  float diff = kc - (o1 * bal + o2 * (1.0 - bal)); float a = 1.0 - clamp(diff * p_perdeKaza / 100.0 * 3.0, 0.0, 1.0);
  a = clamp((a - p_siyahKirp / 100.0) / max(p_beyazKirp / 100.0 - p_siyahKirp / 100.0, 0.01), 0.0, 1.0); return a * s.a; }
void main() { vec4 s = texture(u_tex, v_uv); float a = km(here());
  if (p_yumusatm > 0.3 || abs(p_kenarDara) > 0.1) { float r = max(p_yumusatm, abs(p_kenarDara)) * u_s; float acc = a, mn = a, mx = a; for (int i = 0; i < 8; i++) { float an = float(i) * TAU / 8.0; float x = km(here() + vec2(cos(an), sin(an)) * r); acc += x; mn = min(mn, x); mx = max(mx, x); }
    a = p_kenarDara < -0.1 ? mn : p_kenarDara > 0.1 ? mx : acc / 9.0; }
  if (p_gorunum > 0.5 && p_gorunum < 1.5) { o = vec4(vec3(a), 1.0); return; }
  vec3 c = unpre(s); vec3 k = c_perdeReng; int ch = k.g >= k.r && k.g >= k.b ? 1 : (k.b >= k.r ? 2 : 0); float lim = ch == 1 ? (c.r + c.b) * 0.5 : ch == 2 ? (c.r + c.g) * 0.5 : (c.g + c.b) * 0.5;
  float t = p_tasmaTemi / 100.0; if (ch == 1) c.g = mix(c.g, min(c.g, lim), t); else if (ch == 2) c.b = mix(c.b, min(c.b, lim), t); else c.r = mix(c.r, min(c.r, lim), t);
  if (p_gorunum > 1.5) { o = vec4(mix(vec3(0.0, 0.0, 0.0), vec3(1.0), a) * vec3(1.0, a > 0.98 ? 1.0 : 0.5, a < 0.02 ? 1.0 : 0.5), 1.0); return; }
  o = pre(c, a); }
//== fog
uniform vec3 c_renk; uniform float p_yogunluk, p_olcek, p_hiz, p_yon, p_yuksekli, p_yumusakl, p_tohum, p_alfayaKirp;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 dir = vec2(cos(radians(p_yon)), sin(radians(p_yon)));
  vec2 p = q / max(p_olcek, 1.0) + seedf(p_tohum) - dir * u_t * p_hiz / max(p_olcek, 1.0); float n = fbm(p, 4.0) * 0.5 + 0.5; n = fbm(p + n * 0.8, 3.0) * 0.5 + 0.5;
  float hgt = clamp(boxUV(here()).y, 0.0, 1.0); float hm = smoothstep(1.0 - p_yuksekli / 100.0 - p_yumusakl / 200.0, 1.0 - p_yuksekli / 100.0 + p_yumusakl / 200.0 + 0.01, hgt);
  float d = clamp(smoothstep(0.3, 0.8, n) * hm * p_yogunluk / 100.0 * 1.6, 0.0, 1.0); vec4 f = vec4(c_renk, 1.0) * d; if (p_alfayaKirp > 0.5) f *= s.a; o = overPre(f, s); }
//== reorient360
uniform float p_yaw, p_pitch, p_roll, p_girdi, p_kutupFilt;
void main() { vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = vec4(0.0); return; }
  float lon = (b.x - 0.5) * TAU, lat = (0.5 - b.y) * PI; vec3 d = vec3(cos(lat) * sin(lon), sin(lat), cos(lat) * cos(lon));
  float ro = radians(p_roll), pi_ = radians(p_pitch), ya = radians(p_yaw); d.xy = mat2(cos(ro), sin(ro), -sin(ro), cos(ro)) * d.xy; d.yz = mat2(cos(pi_), sin(pi_), -sin(pi_), cos(pi_)) * d.yz; d.xz = mat2(cos(ya), -sin(ya), sin(ya), cos(ya)) * d.xz;
  vec2 s = vec2(fract(atan(d.x, d.z) / TAU + 0.5), 0.5 - asin(clamp(d.y, -1.0, 1.0)) / PI); o = texPx(boxPx(clamp(s, 0.001, 0.999))); }
//== tinyplanet
uniform vec2 p_merkez; uniform float p_donus, p_yakinlas, p_ufuk, p_tersGeze, p_kenarSarm;
void main() { vec2 r = (toUnit(here()) - p_merkez) / (min(boxU().x, boxU().y) * 0.5) / max(p_yakinlas / 100.0, 0.01); float d = length(r); float a = atan(r.x, -r.y) + radians(p_donus);
  float v = p_tersGeze > 0.5 ? d / 1.0 : 1.0 - atan(d * 1.2) / (PI * 0.5) * (1.0 + (p_ufuk - 50.0) / 100.0); if (p_tersGeze > 0.5) v = 1.0 - v; v = 1.0 - v;
  vec2 s = vec2(fract(a / TAU + 0.5), clamp(v, 0.0, 1.0)); if (p_kenarSarm < 0.5 && (d > 1.4)) { o = vec4(0.0); return; } o = texPx(boxPx(clamp(s, 0.001, 0.999))); }
//== chromaber
uniform vec2 p_merkez; uniform float p_siddet, p_kirmiziKaym, p_yesilKaym, p_maviKaym, p_kenarYogu, p_alfaKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec2 r = toUnit(here()) - p_merkez; float L = length(boxU()) * 0.5; vec2 dir = r / max(L, 1.0); float k = mix(1.0, length(dir) * 1.4, p_kenarYogu / 100.0) * p_siddet * u_s;
  vec2 d = length(dir) > 1e-4 ? normalize(dir) : vec2(0.0); vec4 R = texPx(here() - d * k * p_kirmiziKaym), G = texPx(here() - d * k * p_yesilKaym), Bc = texPx(here() - d * k * p_maviKaym);
  o = vec4(R.r, G.g, Bc.b, p_alfaKoru > 0.5 ? s.a : max(R.a, max(G.a, Bc.a))); }
//== wireremove
uniform vec2 p_baslangi, p_bitis; uniform float p_cizgiKali, p_ornekUzak, p_yontem, p_kenarYumu;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 ab = p_bitis - p_baslangi; float t = clamp(dot(q - p_baslangi, ab) / max(dot(ab, ab), 1.0), 0.0, 1.0); vec2 c = p_baslangi + ab * t; float d = length(q - c);
  float w = p_cizgiKali * 0.5; float m = 1.0 - smoothstep(w, w + max(p_kenarYumu, 0.3), d); if (m <= 0.0) { o = s; return; }
  vec2 n = normalize(vec2(-ab.y, ab.x) + 1e-5); float off = w + p_ornekUzak; vec4 f = (texU(c + n * off) + texU(c - n * off)) * 0.5;
  if (p_yontem > 0.5) { float k = dot(q - c, n) / max(off, 1.0) * 0.5 + 0.5; f = mix(texU(c - n * off), texU(c + n * off), clamp(k, 0.0, 1.0)); } o = mix(s, f, m); }
//== fringe
uniform vec3 c_eskiFonReng; uniform float p_guc, p_kenarGeni, p_alfaEsig, p_parlakliKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float edge = 1.0 - smoothstep(0.0, max(p_kenarGeni * u_s, 1.0), innerDist(here(), max(p_kenarGeni * u_s, 1.0) + 1.0)); float semi = 1.0 - step(p_alfaEsig / 100.0, s.a);
  float k = max(edge, semi) * p_guc / 100.0; vec3 c = unpre(s); vec3 fixed_ = (c - c_eskiFonReng * (1.0 - s.a)) / max(s.a, 0.05); fixed_ = mix(c, clamp(fixed_, 0.0, 1.0), 0.7);
  vec3 nb = unpre(texPx(here() - normalize(alphaGrad(here(), 2.0) + 1e-5) * p_kenarGeni * u_s * 1.5)); fixed_ = mix(fixed_, nb, 0.5 * edge);
  if (p_parlakliKoru > 0.5) fixed_ *= luma(c) / max(luma(fixed_), 1e-3); o = pre(mix(c, clamp(fixed_, 0.0, 1.0), k), s.a); }
//== depthmatte
uniform sampler2D u_depth; uniform float p_yakinSini, p_uzakSini, p_gecis, p_derinligTersCevi, p_matiGost;
void main() { vec4 s = texture(u_tex, v_uv); float d = luma(unpre(texture(u_depth, v_uv))); if (p_derinligTersCevi > 0.5) d = 1.0 - d; float w = p_gecis / 100.0 + 0.001;
  float m = smoothstep(p_yakinSini / 100.0 - w, p_yakinSini / 100.0, d) * (1.0 - smoothstep(p_uzakSini / 100.0, p_uzakSini / 100.0 + w, d)); if (p_matiGost > 0.5) { o = vec4(vec3(m), 1.0); return; } o = s * m; }
//== depthfog
uniform sampler2D u_depth; uniform vec3 c_sisReng; uniform float p_baslangi, p_bitis, p_yogunluk, p_dagilim, p_derinligTersCevi;
void main() { vec4 s = texture(u_tex, v_uv); float d = luma(unpre(texture(u_depth, v_uv))); if (p_derinligTersCevi < 0.5) d = 1.0 - d;
  float k = clamp((d - p_baslangi / 100.0) / max((p_bitis - p_baslangi) / 100.0, 0.01), 0.0, 1.0); if (p_dagilim > 0.5) k = 1.0 - exp(-k * 3.0); k *= p_yogunluk / 100.0; o = pre(mix(unpre(s), c_sisReng, k), s.a); }
//== lumastamp
uniform float p_siyahNokt, p_beyazNokt, p_gama, p_mevcutAlfaCarp, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); float l = luma(unpre(s)); l = clamp((l - p_siyahNokt / 100.0) / max((p_beyazNokt - p_siyahNokt) / 100.0, 0.01), 0.0, 1.0); l = pow(l, 1.0 / max(p_gama, 0.01)); if (p_ters > 0.5) l = 1.0 - l;
  float a = p_mevcutAlfaCarp > 0.5 ? l * s.a : l; o = pre(unpre(s), a); }
//== remaphsv
uniform float p_tonKayn, p_doygunluKayn, p_degerKayn, p_sabitTon, p_sabitDoyg, p_sabitDege, p_alfaKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec3 h = rgb2hsv(unpre(s));
  float H = p_tonKayn < 0.5 ? h.x : p_tonKayn < 1.5 ? h.y : p_tonKayn < 2.5 ? h.z : fract(p_sabitTon / 360.0);
  float S = p_doygunluKayn < 0.5 ? h.y : p_doygunluKayn < 1.5 ? h.x : p_doygunluKayn < 2.5 ? h.z : p_sabitDoyg / 100.0;
  float V = p_degerKayn < 0.5 ? h.z : p_degerKayn < 1.5 ? h.x : p_degerKayn < 2.5 ? h.y : p_sabitDege / 100.0;
  o = pre(hsv2rgb(vec3(H, S, V)), p_alfaKoru > 0.5 ? s.a : 1.0); }
//== magnifybg
uniform sampler2D s_bgsrc; uniform float p_bgsrcOn; uniform float p_buyutme, p_kenarYumu, p_sinir, p_alfaylaKirp; uniform vec2 p_merkez, p_kayma;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 c = boxUV(fromUnit(p_merkez)); vec2 sb = c + (b - c) / max(p_buyutme / 100.0, 0.1) - p_kayma * u_s / u_box.zw;
  if (p_sinir > 1.5) sb = 1.0 - abs(1.0 - mod(sb, 2.0)); else if (p_sinir > 0.5) sb = clamp(sb, 0.0, 1.0);
  vec4 bg = p_bgsrcOn > 0.5 ? texture(s_bgsrc, sb) : texPx(boxPx(sb)); if (p_sinir < 0.5 && (any(lessThan(sb, vec2(0.0))) || any(greaterThan(sb, vec2(1.0))))) bg = vec4(0.0);
  o = p_alfaylaKirp > 0.5 ? bg * s.a : bg; }
