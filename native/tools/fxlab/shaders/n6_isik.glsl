// 550 rehberi: profesyonel ışık ve birleştirme (485–495)
//== halation
uniform float p_parlakliEsig, p_esikYumu, p_yayilim, p_guc, p_kenarAgir, p_orijinalParlKoru, p_karisim; uniform vec3 c_haleReng;
float brightAt(vec2 px) { vec3 c = unpre(texPx(px)); float l = luma(c); return smoothstep(p_parlakliEsig / 100.0 - p_esikYumu / 200.0, p_parlakliEsig / 100.0 + p_esikYumu / 200.0, l) * texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); float R = max(p_yayilim, 0.5) * u_s; float acc = 0.0, ws = 0.0;
  for (int i = 0; i < 32; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 32.0); float w = exp(-r * r / (R * R) * 2.0); acc += brightAt(here() + vec2(cos(a), sin(a)) * r) * w; ws += w; }
  float h = acc / ws; float self = brightAt(here()); h = mix(h, max(h - self, 0.0), p_kenarAgir / 100.0); vec3 add = c_haleReng * h * p_guc / 100.0 * 1.5; vec3 c = unpre(s);
  vec3 r = p_karisim < 0.5 ? screenB(c, add) : p_karisim < 1.5 ? c + add : mix(c, c_haleReng, clamp(h * p_guc / 100.0, 0.0, 1.0)); if (p_orijinalParlKoru > 0.5) r = mix(r, c, self * 0.5);
  o = pre(clamp(r, 0.0, 1.0), max(s.a, clamp(h * p_guc / 100.0, 0.0, 1.0) * (1.0 - s.a) * 0.0 + s.a)); }
//== lightwrap
uniform sampler2D s_bgsrc, s_isikKatm; uniform float p_bgsrcOn, p_isikKatmOn;
uniform float p_isikKayn, p_sarmaGeni, p_kaynakBula, p_guc, p_esik, p_alfayiKoru, p_doygunlu;
vec3 bgAt(vec2 px) { vec2 b = clamp(boxUV(px), 0.0, 1.0); if (p_isikKayn > 0.5 && p_isikKatmOn > 0.5) return unpre(texture(s_isikKatm, b)); if (p_bgsrcOn > 0.5) return unpre(texture(s_bgsrc, b)); return vec3(0.5); }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float W = max(p_sarmaGeni, 0.5) * u_s; float d = innerDist(here(), W); float k = 1.0 - smoothstep(0.0, W, d);
  vec3 acc = vec3(0.0); float br = max(p_kaynakBula, 1.0) * u_s; for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; acc += bgAt(here() + vec2(cos(a), sin(a)) * br * (0.3 + 0.7 * fract(float(i) * 0.618))); } acc /= 12.0;
  acc = satAdj(acc, p_doygunlu / 100.0); float lum = smoothstep(p_esik / 100.0, p_esik / 100.0 + 0.2, luma(acc)); vec3 c = unpre(s); c = screenB(c, acc * k * lum * p_guc / 100.0 * 1.5);
  o = pre(clamp(c, 0.0, 1.0), s.a); }
//== lensdirt
uniform sampler2D s_ozelDoku; uniform float p_ozelDokuOn;
uniform float p_lekeTuru, p_yogunluk, p_buyukluk, p_tohum, p_parlakliEsig, p_guc, p_yumusakl, p_ekranaSabi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 q = p_ekranaSabi > 0.5 ? b * vec2(boxU().x / max(boxU().y, 1.0), 1.0) * 400.0 : toUnit(here()); float sd = seedf(p_tohum); float dirt = 0.0;
  if (p_lekeTuru > 2.5 && p_ozelDokuOn > 0.5) dirt = luma(unpre(texture(s_ozelDoku, fract(b))));
  else { float sz = max(p_buyukluk, 1.0); for (int l = 0; l < 3; l++) { float cs = sz * (2.0 + float(l) * 1.5); vec2 g = q / cs; vec2 id = floor(g); vec2 h = hash2(id + sd + float(l) * 9.0);
      if (h.x > p_yogunluk / 100.0) continue; vec2 c = id + 0.2 + h * 0.6; float r = (0.15 + hash1(id + 3.0) * 0.3); float dd = length(g - c);
      float dust = 1.0 - smoothstep(r * 0.5, r * 0.5 + max(p_yumusakl, 0.5) / cs, dd); float oil = (1.0 - smoothstep(r, r + 0.2, dd)) * (0.4 + 0.6 * fbm01(g * 3.0, 3.0));
      float t = p_lekeTuru < 0.5 ? dust : p_lekeTuru < 1.5 ? oil : (hash1(id) > 0.5 ? dust : oil); dirt = max(dirt, t); } }
  vec3 acc = vec3(0.0); float R = 30.0 * u_s; for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; acc += unpre(texPx(here() + vec2(cos(a), sin(a)) * R * fract(float(i) * 0.618 + 0.2))); } acc /= 12.0;
  float light = smoothstep(p_parlakliEsig / 100.0 - 0.1, p_parlakliEsig / 100.0 + 0.1, luma(acc)); vec3 c = unpre(s) + acc * dirt * light * p_guc / 100.0 * 1.2; o = pre(clamp(c, 0.0, 1.0), s.a); }
//== relight
uniform sampler2D s_haritaKatm; uniform float p_haritaKatmOn;
uniform float p_yuzeyKayn, p_yukselti, p_parlakli, p_puruzlul, p_isikGucu, p_ortamIsig; uniform vec3 p_isikKonu, c_isikReng;
float hAt(vec2 px) { if (p_yuzeyKayn < 0.5) return luma(unpre(texPx(px))); if (p_yuzeyKayn < 1.5) return texPx(px).a; if (p_haritaKatmOn > 0.5) return luma(unpre(texture(s_haritaKatm, clamp(boxUV(px), 0.0, 1.0)))); return luma(unpre(texPx(px))); }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 n;
  if (p_yuzeyKayn > 1.5 && p_yuzeyKayn < 2.5 && p_haritaKatmOn > 0.5) n = normalize(unpre(texture(s_haritaKatm, clamp(boxUV(here()), 0.0, 1.0))) * 2.0 - 1.0);
  else { float e = 1.5 * u_s; float hx = hAt(here() + vec2(e, 0.0)) - hAt(here() - vec2(e, 0.0)); float hy = hAt(here() + vec2(0.0, e)) - hAt(here() - vec2(0.0, e)); n = normalize(vec3(-hx, -hy, 0.02 + (1.0 - p_yukselti / 100.0) * 0.5)); }
  vec3 P = vec3(toUnit(here()), 0.0); vec3 Lp = vec3(p_isikKonu.x, p_isikKonu.y, -p_isikKonu.z); vec3 L = normalize(Lp - P); vec3 V = vec3(0.0, 0.0, 1.0);
  float dif = max(dot(n, L), 0.0); float sp = pow(max(dot(reflect(-L, n), V), 0.0), mix(64.0, 4.0, p_puruzlul / 100.0)) * p_parlakli / 100.0;
  vec3 c = unpre(s) * (p_ortamIsig / 100.0 + dif * p_isikGucu / 100.0 * c_isikReng) + c_isikReng * sp; o = pre(clamp(c, 0.0, 1.0), s.a); }
//== normalmap
uniform float p_yuksekliKayn, p_yuksekliTersCevi, p_yukseltiGucu, p_ornekAral, p_yumusatm, p_normalBici, p_alfayiKoru, p_onizleme;
float hAt(vec2 px) { vec4 c = texPx(px); vec3 u = unpre(c); float v = p_yuksekliKayn < 0.5 ? luma(u) : p_yuksekliKayn < 1.5 ? c.a : p_yuksekliKayn < 2.5 ? u.r : p_yuksekliKayn < 3.5 ? u.g : u.b; return p_yuksekliTersCevi > 0.5 ? 1.0 - v : v; }
float hS(vec2 px) { float r = p_yumusatm * u_s; if (r < 0.5) return hAt(px); return (hAt(px) * 2.0 + hAt(px + vec2(r, 0.0)) + hAt(px - vec2(r, 0.0)) + hAt(px + vec2(0.0, r)) + hAt(px - vec2(0.0, r))) / 6.0; }
void main() { vec4 s = texture(u_tex, v_uv); float e = max(p_ornekAral, 0.5) * u_s; float k = p_yukseltiGucu / 10.0; float dx = (hS(here() + vec2(e, 0.0)) - hS(here() - vec2(e, 0.0))) * k; float dy = (hS(here() + vec2(0.0, e)) - hS(here() - vec2(0.0, e))) * k;
  vec3 n = normalize(vec3(-dx, p_normalBici < 0.5 ? dy : -dy, 1.0)); float a = p_alfayiKoru > 0.5 ? s.a : 1.0;
  if (p_onizleme > 0.5) { float l = max(dot(n, normalize(vec3(-0.5, 0.5, 0.8))), 0.0); o = pre(unpre(s) * (0.3 + l), a); return; } o = pre(n * 0.5 + 0.5, a); }
//== uvmap
uniform sampler2D s_uvKatm, s_kaplanacKatm; uniform float p_uvKatmOn, p_kaplanacKatmOn;
uniform float p_dokuDonu, p_tasma, p_orneklem, p_alfayiKoru; uniform vec2 p_dokuOlce, p_dokuKaym;
void main() { vec4 s = texture(u_tex, v_uv); if (p_uvKatmOn < 0.5 || p_kaplanacKatmOn < 0.5) { o = s; return; } vec4 m = texture(s_uvKatm, clamp(boxUV(here()), 0.0, 1.0)); if (m.a <= 0.0) { o = p_alfayiKoru > 0.5 ? vec4(0.0) : s; return; }
  vec2 uv = unpre(m).rg; uv = rot2(-p_dokuDonu) * (uv - 0.5) / max(p_dokuOlce / 100.0, vec2(0.01)) + 0.5 + p_dokuKaym / 100.0;
  bool out_ = any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0))); if (p_tasma > 0.5 && p_tasma < 1.5) uv = fract(uv); else if (p_tasma > 1.5 && p_tasma < 2.5) { uv = abs(mod(uv, 2.0)); uv = mix(uv, 2.0 - uv, step(1.0, uv)); } else uv = clamp(uv, 0.0, 1.0);
  vec4 c = texture(s_kaplanacKatm, uv); if (p_tasma < 0.5 && out_) c = vec4(0.0); o = c * (p_alfayiKoru > 0.5 ? m.a : 1.0); }
//== floorshadow
uniform vec2 p_temasNokt; uniform float p_zeminEgim, p_yon, p_uzunluk, p_opaklik, p_yakinYumu, p_uzakYumu, p_uzakSolm; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 C = p_temasNokt; float ang = radians(p_yon); vec2 dir = vec2(cos(ang), sin(ang)); float ls = p_uzunluk / 100.0; float flat_ = cos(radians(p_zeminEgim));
  // zemindeki nokta → katmandaki karşılığı: temas çizgisinden uzaklık, gölge yönünde ölçeklenir
  vec2 d = q - C; float along = dot(d, dir); float side = dot(d, vec2(-dir.y, dir.x)); if (along < 0.0) { o = s; return; }
  float hgt = along / max(ls * flat_ + 0.05, 0.05); vec2 src = C + vec2(side, -hgt); float t = clamp(hgt / max(boxU().y, 1.0), 0.0, 1.0); float blur = mix(p_yakinYumu, p_uzakYumu, t) * u_s; float a = 0.0;
  for (int i = 0; i < 8; i++) { float an = float(i) * 0.785; a += texU(src + vec2(cos(an), sin(an)) / u_s * blur).a; } a /= 8.0;
  float sh = a * p_opaklik / 100.0 * (1.0 - t * p_uzakSolm / 100.0); o = overPre(s, vec4(c_renk, 1.0) * sh); }
//== floorreflect
uniform vec2 p_temasNokt; uniform float p_zeminEgim, p_uzunluk, p_opaklik, p_uzakSolm, p_bulanikl, p_dalgalan, p_orijinalGost; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 C = p_temasNokt; float dy = q.y - C.y; vec4 base = p_orijinalGost > 0.5 ? s : vec4(0.0); if (dy < 0.0) { o = base; return; }
  float sc = max(p_uzunluk / 100.0 * cos(radians(p_zeminEgim)) + 0.05, 0.05); float sy = C.y - dy / sc; float t = clamp(dy / (boxU().y * 0.5 * sc + 1.0), 0.0, 1.0);
  float wx = p_dalgalan > 0.0 ? sin(dy * 0.15 + u_t * 3.0) * p_dalgalan * 0.3 : 0.0; vec4 r = vec4(0.0); float bl = p_bulanikl * u_s * (0.3 + t);
  for (int i = 0; i < 6; i++) { r += texU(vec2(q.x + wx + (float(i) - 2.5) * bl / u_s * 0.4, sy)); } r /= 6.0; r.rgb *= c_renk;
  r *= p_opaklik / 100.0 * (1.0 - t * p_uzakSolm / 100.0); o = overPre(base, r); }
//== freqsep
uniform float p_filtre, p_ayirmaYari, p_renkDoyg, p_parlakli, p_ayrintiGucu, p_gurultuEsig, p_gorunum, p_alfayiKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float R = max(p_ayirmaYari, 0.5) * u_s; vec3 acc = vec3(0.0); float ws = 0.0;
  for (int i = 0; i < 24; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 24.0); vec3 c = unpre(texPx(here() + vec2(cos(a), sin(a)) * r)); float w = exp(-r * r / (R * R) * 2.0); if (p_filtre > 0.5) w *= exp(-pow(length(c - c0) * 6.0, 2.0)); acc += c * w; ws += w; }
  vec3 low = acc / ws; vec3 high = c0 - low; float hm = length(high); high *= smoothstep(p_gurultuEsig / 100.0 * 0.2, p_gurultuEsig / 100.0 * 0.2 + 0.01, hm) * step(0.0, hm);
  low = satAdj(low, p_renkDoyg / 100.0) + p_parlakli / 100.0; vec3 r = p_gorunum < 0.5 ? low + high * p_ayrintiGucu / 100.0 : p_gorunum < 1.5 ? low : high * p_ayrintiGucu / 100.0 + 0.5;
  o = pre(clamp(r, 0.0, 1.0), p_alfayiKoru > 0.5 ? s.a : 1.0); }
//== colormatch
uniform sampler2D s_referansKatm, s_referansDosy; uniform float p_referansKatmOn, p_referansDosyOn;
uniform float p_yontem, p_guc, p_kontrastKoru, p_alfaBoslYok;
vec4 refAt(vec2 uv) { return p_referansKatmOn > 0.5 ? texture(s_referansKatm, uv) : texture(s_referansDosy, uv); }
void main() { vec4 s = texture(u_tex, v_uv); if ((p_referansKatmOn < 0.5 && p_referansDosyOn < 0.5) || s.a <= 0.0) { o = s; return; }
  vec3 m1 = vec3(0.0), m2 = vec3(0.0), r1 = vec3(0.0), r2 = vec3(0.0); float n1 = 0.0, n2 = 0.0;
  for (int j = 0; j < 8; j++) for (int i = 0; i < 8; i++) { vec2 uv = (vec2(i, j) + 0.5) / 8.0; vec4 a = texPx(boxPx(uv)); vec4 b = refAt(uv);
    if (a.a > 0.1 || p_alfaBoslYok < 0.5) { vec3 c = unpre(a); m1 += c; m2 += c * c; n1 += 1.0; } if (b.a > 0.1 || p_alfaBoslYok < 0.5) { vec3 c = unpre(b); r1 += c; r2 += c * c; n2 += 1.0; } }
  m1 /= max(n1, 1.0); r1 /= max(n2, 1.0); vec3 sd1 = sqrt(max(m2 / max(n1, 1.0) - m1 * m1, 1e-4)), sd2 = sqrt(max(r2 / max(n2, 1.0) - r1 * r1, 1e-4));
  vec3 c = unpre(s); vec3 k = mix(sd2 / sd1, vec3(1.0), p_kontrastKoru / 100.0); vec3 t = (c - m1) * k + r1;
  if (p_yontem > 0.5 && p_yontem < 1.5) t = c + (luma(t) - luma(c)); else if (p_yontem > 1.5) t = luma(c) + (t - luma(t));
  o = pre(clamp(mix(c, t, p_guc / 100.0), 0.0, 1.0), s.a); }
//== exposurefuse
uniform sampler2D s_koyuPozl, s_ortaPozl, s_acikPozl; uniform float p_koyuPozlOn, p_ortaPozlOn, p_acikPozlOn;
uniform float p_pozlamaAgir, p_kontrastAgir, p_doygunluAgir, p_gecisYumu;
float wt(vec3 c, vec3 cx, vec3 cy) { float well = exp(-pow(luma(c) - 0.5, 2.0) / 0.08); float con = abs(luma(cx) + luma(cy) - 2.0 * luma(c)) * 4.0; float sat = length(c - luma(c));
  return 1e-3 + pow(well, p_pozlamaAgir / 50.0) * (1.0 + con * p_kontrastAgir / 50.0) * (1.0 + sat * p_doygunluAgir / 50.0); }
vec4 img(int i, vec2 uv) { if (i == 0) return p_koyuPozlOn > 0.5 ? texture(s_koyuPozl, uv) : vec4(0.0); if (i == 1) return p_ortaPozlOn > 0.5 ? texture(s_ortaPozl, uv) : texPx(boxPx(uv)); return p_acikPozlOn > 0.5 ? texture(s_acikPozl, uv) : vec4(0.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 uv = clamp(boxUV(here()), 0.0, 1.0); vec2 e = vec2(1.0 / max(u_box.z, 1.0), 0.0) * (1.0 + p_gecisYumu / 10.0); vec3 acc = vec3(0.0); float ws = 0.0;
  for (int i = 0; i < 3; i++) { vec4 c = img(i, uv); if (c.a <= 0.0) continue; vec3 u = unpre(c); float w = wt(u, unpre(img(i, uv + e)), unpre(img(i, uv + e.yx)));
    float wb = 0.0; for (int k = 0; k < 4; k++) { vec2 o2 = vec2(cos(float(k) * 1.57), sin(float(k) * 1.57)) * e.x * 6.0; vec3 cc = unpre(img(i, uv + o2)); wb += wt(cc, cc, cc); } w = mix(w, wb / 4.0, p_gecisYumu / 100.0);
    acc += u * w; ws += w; }
  o = ws > 0.0 ? pre(clamp(acc / ws, 0.0, 1.0), s.a) : s; }
