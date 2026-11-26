// Tekrar, Taşı ve Dönüştür (parça efektleri) ve Countryball efektleri
//== gridrepeat
uniform float p_sutun, p_satir, p_aralikX, p_aralikY, p_kopyaOlce, p_kopyaAcis, p_satirKaym, p_aynala; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); vec2 sp = vec2(max(p_aralikX, 1.0), max(p_aralikY, 1.0)); vec4 res = vec4(0.0); float sc = max(p_kopyaOlce / 100.0, 0.01);
  vec2 rel = q - p_merkez; vec2 g0 = floor(rel / sp + (n - 1.0) * 0.5 + 0.5);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = g0 + vec2(float(i), float(j)); if (any(lessThan(id, vec2(0.0))) || any(greaterThanEqual(id, n))) continue;
    vec2 c = p_merkez + (id - (n - 1.0) * 0.5) * sp + vec2(mod(id.y, 2.0) * p_satirKaym, 0.0); vec2 l = rot2(-p_kopyaAcis) * (q - c) / sc;
    if (p_aynala > 0.5 && mod(id.x + id.y, 2.0) > 0.5) l.x = -l.x; res = overPre(res, texU(l)); }
  o = res;
}
//== linrepeat
uniform float p_kopyaSayi, p_adimX, p_adimY, p_olcekAdim, p_donusAdim, p_opaklikAdim, p_orijinalGost;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 64.0));
  for (int i = 63; i >= 0; i--) { if (i >= N) continue; if (i == 0 && p_orijinalGost < 0.5) continue; float k = float(i); float sc = max(1.0 + p_olcekAdim / 100.0 * k, 0.01);
    vec2 c = vec2(p_adimX, p_adimY) * k; vec2 l = rot2(-p_donusAdim * k) * (q - c) / sc; float op = clamp(1.0 + p_opaklikAdim / 100.0 * k, 0.0, 1.0); res = overPre(texU(l) * op, res); }
  o = res;
}
//== radrepeat
uniform float p_kopyaSayi, p_yaricap, p_baslangiAcis, p_yay, p_kopyaOlce, p_radyalDond, p_orijinalGost; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec4 res = p_orijinalGost > 0.5 ? texU(q) : vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 64.0)); float sc = max(p_kopyaOlce / 100.0, 0.01);
  float full = abs(abs(p_yay) - 360.0) < 0.5 ? 1.0 : 0.0;
  for (int i = 0; i < 64; i++) { if (i >= N) break; float a = p_baslangiAcis + p_yay * float(i) / max(float(N) - full, 1.0) ; vec2 c = p_merkez + vec2(cos(radians(a)), sin(radians(a))) * p_yaricap;
    vec2 l = (q - c); if (p_radyalDond > 0.5) l = rot2(-(a + 90.0)) * l; l /= sc; res = overPre(texU(l), res); }
  o = res;
}
//== scatter
uniform float p_kopyaSayi, p_alanX, p_alanY, p_olcekDegi, p_aciDegi, p_tohum, p_cakismayAzal; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 96.0));
  for (int i = 0; i < 96; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum))); vec2 h2 = hash2(vec2(float(i) + 0.3, seedf(p_tohum) + 5.0));
    vec2 c = p_merkez + (h - 0.5) * vec2(p_alanX, p_alanY); float sc = max(1.0 - p_olcekDegi / 100.0 * h2.x, 0.05) * 0.5; vec2 l = rot2(-(h2.y - 0.5) * 2.0 * p_aciDegi) * (q - c) / sc;
    res = overPre(texU(l), res); }
  o = res;
}
//== spiral
uniform float p_kopyaSayi, p_icYari, p_disYari, p_tur, p_olcekAdim, p_yolaDond; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 96.0));
  for (int i = 0; i < 96; i++) { if (i >= N) break; float t = float(i) / max(float(N) - 1.0, 1.0); float a = t * p_tur * TAU; float r = mix(p_icYari, p_disYari, t);
    vec2 c = p_merkez + vec2(cos(a), sin(a)) * r; float sc = max(0.3 * (1.0 + p_olcekAdim / 100.0 * float(i)), 0.01); vec2 l = q - c; if (p_yolaDond > 0.5) l = rot2(-degrees(a) - 90.0) * l; res = overPre(texU(l / sc), res); }
  o = res;
}
//== mirrorrepeat
uniform float p_eksen, p_eksenAcis, p_mesafe, p_kopyaOpak, p_orijinalGost; uniform vec2 p_aynaCizg;
void main() {
  vec2 q = toUnit(here()); float a = p_eksen < 0.5 ? 90.0 : p_eksen < 1.5 ? 0.0 : p_eksenAcis + 90.0; vec2 d = vec2(cos(radians(a)), sin(radians(a))); vec2 n = vec2(-d.y, d.x);
  vec2 L = p_aynaCizg + n * (p_mesafe * 0.5 + boxU().x * 0.0); float s = dot(q - L, n); vec2 m = q - 2.0 * s * n; vec2 shift = n * (dot(L - p_aynaCizg, n)) ;
  vec4 copy = texU(m - n * p_mesafe * 0.0) * p_kopyaOpak / 100.0; vec4 orig = p_orijinalGost > 0.5 ? texU(q) : vec4(0.0); o = overPre(orig, copy);
}
//== repeatpath
uniform float p_yol, p_kopyaSayi, p_boyutX, p_boyutY, p_baslangi, p_bitis, p_yolaDond, p_kapaliYol;
vec2 pathAt(float t) { float a = t * TAU; vec2 S = vec2(p_boyutX, p_boyutY) * 0.5;
  if (p_yol < 0.5 || p_yol > 3.5) return vec2(cos(a), sin(a)) * S; if (p_yol < 1.5) return vec2((t * 2.0 - 1.0), sin(a * 1.5)) * S;
  if (p_yol < 2.5) return vec2(pow(sin(a), 3.0), -(13.0 * cos(a) - 5.0 * cos(2.0 * a) - 2.0 * cos(3.0 * a) - cos(4.0 * a)) / 16.0) * S;
  float k = floor(t * 10.0); float f = fract(t * 10.0); float r0 = mod(k, 2.0) < 0.5 ? 1.0 : 0.45, r1 = mod(k, 2.0) < 0.5 ? 0.45 : 1.0; float a0 = k / 10.0 * TAU - PI * 0.5, a1 = (k + 1.0) / 10.0 * TAU - PI * 0.5;
  return mix(vec2(cos(a0), sin(a0)) * r0, vec2(cos(a1), sin(a1)) * r1, f) * S; }
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 96.0)); float closed = p_kapaliYol > 0.5 && (p_yol < 0.5 || p_yol > 1.5) ? 1.0 : 0.0;
  for (int i = 0; i < 96; i++) { if (i >= N) break; float t = mix(p_baslangi, p_bitis, float(i) / max(float(N) - (closed > 0.5 ? 0.0 : 1.0), 1.0)) / 100.0; vec2 c = pathAt(t);
    vec2 l = q - c; if (p_yolaDond > 0.5) { vec2 tg = pathAt(t + 0.002) - pathAt(t - 0.002); l = rot2(-degrees(atan(tg.y, tg.x))) * l; } res = overPre(texU(l / 0.3), res); }
  o = res;
}
//== scatterfield
uniform float p_yogunluk, p_alanX, p_alanY, p_enKucuOlce, p_enBuyuOlce, p_hiz, p_yon, p_tohum, p_sarmala, p_rastgeleDon;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); vec2 A = vec2(max(p_alanX, 10.0), max(p_alanY, 10.0)); float cell = sqrt(A.x * A.y / max(p_yogunluk, 1.0)); vec2 dir = vec2(cos(radians(p_yon)), sin(radians(p_yon)));
  vec2 p = q - dir * p_hiz * u_t; if (p_sarmala > 0.5) p = mod(p + A * 0.5, A) - A * 0.5; vec2 id = floor(p / cell);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(float(i), float(j)); vec2 h = hash2(c + seedf(p_tohum)); vec2 h2 = hash2(c + 3.7);
    vec2 cp = (c + h) * cell; float sc = mix(p_enKucuOlce, p_enBuyuOlce, h2.x) / 100.0; vec2 l = p - cp; if (p_rastgeleDon > 0.5) l = rot2(-h2.y * 360.0) * l; res = overPre(res, texU(l / max(sc, 0.01))); }
  o = res;
}
//== growparts
uniform float p_parcalam, p_satir, p_sutun, p_ilerleme, p_baslangiOlce, p_parcaGeci, p_sira, p_tohum;
void main() {
  vec2 b = boxUV(here()); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); if (p_parcalam < 1.5) n = vec2(max(1.0, floor(p_sutun * 2.0)), 1.0);
  vec2 id = floor(b * n); vec2 c = (id + 0.5) / n; float ord = p_sira < 0.5 ? id.x / n.x : p_sira < 1.5 ? 1.0 - id.x / n.x : p_sira < 2.5 ? abs(id.x / max(n.x - 1.0, 1.0) - 0.5) * 2.0 : hash1(id + seedf(p_tohum));
  float g = p_parcaGeci / 100.0; float pp = clamp((p_ilerleme / 100.0 - ord * g) / max(1.0 - g, 0.05), 0.0, 1.0); pp = 1.0 - pow(1.0 - pp, 3.0);
  float sc = mix(p_baslangiOlce / 100.0, 1.0, pp); vec2 sb = c + (b - c) / max(sc, 0.001); if (any(greaterThan(abs(sb - c), 0.5 / n))) { o = vec4(0.0); return; } o = texPx(boxPx(sb)) * smoothstep(0.0, 0.2, pp);
}
//== shakeparts
uniform float p_parcaTuru, p_satir, p_sutun, p_konumSidd, p_aciSidd, p_frekans, p_tohum, p_yumusatm;
void main() {
  vec2 b = boxUV(here()); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); if (p_parcaTuru > 0.5) n = vec2(max(1.0, floor(p_sutun * 2.0)), 1.0); vec2 B = boxU();
  vec4 res = vec4(0.0);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = floor(b * n) + vec2(float(i), float(j)); if (any(lessThan(id, vec2(0.0))) || any(greaterThanEqual(id, n))) continue;
    vec2 c = (id + 0.5) / n; float x = u_t * p_frekans; float sd = seedf(p_tohum) + dot(id, vec2(7.1, 3.3)); float sm = p_yumusatm / 100.0;
    vec2 off = vec2(mix(hash1(vec2(floor(x), sd)) - 0.5, vnoise(vec2(x, sd)) - 0.5, sm), mix(hash1(vec2(floor(x), sd + 9.0)) - 0.5, vnoise(vec2(x, sd + 9.0)) - 0.5, sm)) * 2.0 * p_konumSidd;
    float ang = (mix(hash1(vec2(floor(x), sd + 4.0)), vnoise(vec2(x, sd + 4.0)), sm) - 0.5) * 2.0 * p_aciSidd;
    vec2 lu = rot2(-ang) * ((b - c) * B - off) / B + c; if (any(greaterThan(abs(lu - c), 0.5 / n))) continue; res = overPre(res, texPx(boxPx(lu))); }
  o = res;
}
//== flagwave
uniform float p_sabitKena, p_sabitSeriGeni, p_dalgaYuks, p_dalgaBoyu, p_ruzgarHizi, p_ruzgarAcis, p_faz, p_ikinciDalg, p_duzensiz, p_tohum, p_p3bGolg, p_isikAcis, p_golgeGucu, p_kenarlarKoru, p_kusursuzDong, p_donguSure;
uniform vec2 p_ozelSabiCizg, p_ozelSabiCizg2;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 b = boxUV(here());
  // serbest yön ve sabit kenardan normalize uzaklık u
  vec2 fdir; float u;
  if (p_sabitKena < 0.5) { fdir = vec2(1, 0); u = b.x; } else if (p_sabitKena < 1.5) { fdir = vec2(-1, 0); u = 1.0 - b.x; } else if (p_sabitKena < 2.5) { fdir = vec2(0, 1); u = b.y; } else if (p_sabitKena < 3.5) { fdir = vec2(0, -1); u = 1.0 - b.y; }
  else { vec2 a = p_ozelSabiCizg, c = p_ozelSabiCizg2; vec2 d = normalize(c - a + 1e-5); fdir = vec2(d.y, -d.x); if (dot(-a, fdir) < 0.0) fdir = -fdir; u = clamp(dot(q - a, fdir) / max(abs(dot(B, abs(fdir))), 1.0), 0.0, 1.0); }
  float s = p_sabitSeriGeni / 100.0; float w = smoothstep(s, 1.0, u) * smoothstep(s, min(s + 0.35, 1.0), u);
  float dist = u * abs(dot(B, abs(fdir))); float f = p_ruzgarHizi; if (p_kusursuzDong > 0.5) f = max(1.0, floor(f * p_donguSure + 0.5)) / max(p_donguSure, 0.01);
  float ph = TAU * (dist / max(p_dalgaBoyu, 1.0) - f * u_t) + radians(p_faz) + radians(p_ruzgarAcis) * 0.0;
  float irr = (vnoise(vec2(dist / max(p_dalgaBoyu, 1.0) * 1.7 - f * u_t * 0.8, seedf(p_tohum))) - 0.5) * 2.0 * p_duzensiz / 100.0;
  float h = sin(ph) + p_ikinciDalg / 100.0 * sin(ph * 2.13 + 1.3) + irr; float disp = p_dalgaYuks * w * h;
  vec2 perp = vec2(-fdir.y, fdir.x); vec2 sq = q - perp * disp - fdir * disp * 0.15 * cos(ph);
  vec4 c = texU(sq); if (p_kenarlarKoru < 0.5) c = texEdge(fromUnit(sq), 3.0) * step(0.001, texU(sq).a + 0.001);
  if (p_p3bGolg > 0.5 && c.a > 0.0) { float slope = cos(ph) * w; float la = radians(p_isikAcis); float lit = slope * cos(la) * p_golgeGucu / 100.0 * 1.6; c.rgb = clamp(c.rgb * (1.0 + lit), 0.0, c.a); }
  o = c;
}
//== cbshade
uniform vec2 p_isikMerk; uniform vec3 c_isikReng, c_golgeReng; uniform float p_isikGucu, p_golgeGucu, p_kenarKara, p_yumusakl, p_alfayaKirp;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 q = toUnit(here()); vec2 B = boxU(); float R = min(B.x, B.y) * 0.5;
  vec2 r = q / R; float d = length(r); vec3 n = vec3(r, sqrt(max(0.0, 1.0 - min(dot(r, r), 1.0)))); vec2 lp = p_isikMerk / R; vec3 L = normalize(vec3(lp, 0.9));
  float dif = dot(n, L); float hl = pow(max(dif, 0.0), mix(12.0, 2.0, p_yumusakl / 100.0)); float sh = smoothstep(0.2, -0.6, dif);
  vec3 c = unpre(s); c = mix(c, c_golgeReng, sh * p_golgeGucu / 100.0); c = mix(c, c_isikReng, hl * p_isikGucu / 100.0); c *= 1.0 - smoothstep(0.7, 1.0, d) * p_kenarKara / 100.0;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== cbblush
uniform vec2 p_solMerk, p_sagMerk; uniform vec3 c_renk; uniform float p_boyut, p_cizgiSayi, p_aci, p_opaklik, p_yumusakl, p_alfayaKirp;
float marks(vec2 q, vec2 c) { vec2 r = rot2(-p_aci) * (q - c); float n = max(1.0, floor(p_cizgiSayi)); float sp = p_boyut * 0.45; float m = 0.0;
  for (int i = 0; i < 10; i++) { if (float(i) >= n) break; float x = (float(i) - (n - 1.0) * 0.5) * sp; vec2 d = r - vec2(x, 0.0); float L = p_boyut * 0.5;
    float k = 1.0 - smoothstep(p_boyut * 0.08, p_boyut * 0.08 + 1.0 + p_yumusakl * 0.05, length(vec2(d.x - clamp(d.x, -0.0, 0.0), max(abs(d.y) - L, 0.0)) + vec2(abs(d.x), 0.0) * 0.0)); m = max(m, k); }
  float glow = exp(-dot(r, r) / pow(p_boyut * 1.2, 2.0)) * 0.35; return max(m, glow); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float m = max(marks(q, p_solMerk), marks(q, p_sagMerk)) * p_opaklik / 100.0; if (p_alfayaKirp > 0.5) m *= s.a; o = overPre(vec4(c_renk, 1.0) * m, s); }
//== cbsurprise
uniform vec2 p_merkez; uniform float p_bicim, p_boyut, p_kontur, p_donus, p_belirme, p_otomatikYayl; uniform vec3 c_renk, c_konturReng;
float shapeD(vec2 p) { // birim boyda işaret (y aşağı)
  if (p_bicim < 0.5) { float bar = max(abs(p.x) - 0.12, abs(p.y + 0.18) - 0.32); float dot_ = length(p - vec2(0.0, 0.38)) - 0.12; return min(bar, dot_); }
  if (p_bicim < 1.5) { float arc = abs(length(p - vec2(0.0, -0.2)) - 0.25) - 0.09; arc = max(arc, -(p.y + 0.2) - 0.0 + (p.x < 0.0 ? 1.0 : 0.0) * 0.0); float stem = max(abs(p.x) - 0.09, abs(p.y - 0.12) - 0.12); return min(min(arc, stem), length(p - vec2(0.0, 0.4)) - 0.1); }
  if (p_bicim < 2.5) { float d = 1e5; for (int i = -1; i <= 1; i++) { float a = radians(float(i) * 30.0 - 90.0); vec2 dir = vec2(cos(a), sin(a)); vec2 pp = p - dir * 0.15; float t = clamp(dot(pp, dir), 0.0, 0.35); d = min(d, length(pp - dir * t) - 0.07); } return d; }
  float a = atan(p.y, p.x); float r = length(p); float k = mix(0.2, 0.5, pow(abs(cos(a * 2.5)), 2.0)); return r - k; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float pop = p_otomatikYayl > 0.5 ? 1.0 + 0.25 * exp(-u_t * 5.0) * sin(u_t * 25.0) : 1.0; float sc = max(p_boyut, 1.0) * p_belirme / 100.0 * pop;
  vec2 p = rot2(-p_donus) * (q - p_merkez) / max(sc, 0.01); float d = shapeD(p) * sc; float fill = 1.0 - smoothstep(-0.6, 0.6, d); float ring = 1.0 - smoothstep(p_kontur - 0.6, p_kontur + 0.6, d);
  vec4 c = vec4(c_konturReng, 1.0) * ring; c = mix(c, vec4(c_renk, 1.0), fill * step(0.01, p_belirme)); o = overPre(c * step(0.5, p_belirme), s); }
//== cbsweat
uniform vec2 p_baslangi, p_bitis; uniform float p_boyut, p_kontur, p_ilerleme, p_sure, p_otomatik, p_parlakNokt; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float pr = p_otomatik > 0.5 ? fract(u_t / max(p_sure, 0.05)) : p_ilerleme / 100.0; vec2 c = mix(p_baslangi, p_bitis, pr * pr);
  vec2 p = (q - c) / max(p_boyut, 1.0); p.y = -p.y; float d = length(p - vec2(0.0, -0.1)) - 0.3; float tip = max(abs(p.x) - (0.3 - (p.y + 0.1) * 0.5), p.y - 0.45); d = min(d, max(tip, -p.y - 0.1)); d *= p_boyut;
  float fill = 1.0 - smoothstep(-0.6, 0.6, d); float ring = 1.0 - smoothstep(p_kontur - 0.6, p_kontur + 0.6, d); float fade = 1.0 - smoothstep(0.8, 1.0, pr);
  vec4 col = vec4(0.07, 0.1, 0.2, 1.0) * ring; col = mix(col, vec4(c_renk, 1.0), fill); if (p_parlakNokt > 0.5) col = mix(col, vec4(1.0), (1.0 - smoothstep(0.0, 0.08, length(p - vec2(-0.1, 0.0)))) * fill);
  o = overPre(col * fade, s); }
//== cbskin
uniform sampler2D s_bayrakKatm, s_govdeMask; uniform float p_bayrakKatmOn, p_govdeMaskOn; uniform float p_yerlesim, p_olcek, p_aci, p_kureBuku, p_golge, p_konturuKoru; uniform vec2 p_kayma;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float mask = p_govdeMaskOn > 0.5 ? texture(s_govdeMask, clamp(b, 0.0, 1.0)).a : s.a; if (mask <= 0.0) { o = s; return; }
  vec2 r = b - 0.5; float d = length(r) * 2.0; vec2 bulged = r * mix(1.0, 0.75 + 0.25 * sqrt(max(0.0, 1.0 - d * d)), p_kureBuku / 100.0 * 2.0);
  vec2 fb = rot2(-p_aci) * (bulged - p_kayma / boxU()) / max(p_olcek / 100.0, 0.01) + 0.5; vec4 f = p_bayrakKatmOn > 0.5 ? texture(s_bayrakKatm, clamp(fb, 0.0, 1.0)) : s;
  vec3 c = f.a > 0.0 ? f.rgb / f.a : unpre(s); c *= 1.0 - smoothstep(0.5, 1.0, d) * p_golge / 100.0; vec4 res = pre(c, mask);
  if (p_konturuKoru > 0.5) { float dark = 1.0 - smoothstep(0.05, 0.25, luma(unpre(s))); res = mix(res, s, dark * s.a); } o = res; }
//== cboutline
uniform float p_temelKali, p_tepeKali, p_frekans, p_faz, p_yumusakl, p_yalnizDisKena; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); float k = 0.5 + 0.5 * sin(u_t * p_frekans * TAU + radians(p_faz)); k = mix(step(0.5, k), k, p_yumusakl / 100.0);
  float w = mix(p_temelKali, p_tepeKali, k) * u_s; float ring = p_yalnizDisKena > 0.5 ? clamp(dilateA(here(), w) - s.a, 0.0, 1.0) : clamp(dilateA(here(), w * 0.5) - erodeA(here(), w * 0.5), 0.0, 1.0);
  o = overPre(s * (p_yalnizDisKena > 0.5 ? 1.0 : 1.0 - ring), vec4(c_renk, 1.0) * ring); if (p_yalnizDisKena > 0.5) o = overPre(s, vec4(c_renk, 1.0) * ring); }
//== cbmaphl
uniform sampler2D s_bolgeMask; uniform float p_bolgeMaskOn; uniform float p_dolguOpak, p_kontur, p_parlama, p_nabiz, p_nabizAcik, p_sinirlarKoru; uniform vec3 c_dolgu, c_konturReng;
float mAt(vec2 px) { return p_bolgeMaskOn > 0.5 ? texture(s_bolgeMask, clamp(boxUV(px), 0.0, 1.0)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); float m = mAt(here()); float pulse = p_nabizAcik > 0.5 ? 0.7 + 0.3 * sin(u_t * p_nabiz * TAU) : 1.0;
  float w = p_kontur * u_s; float mx = m, mn = m; for (int i = 0; i < 12; i++) { float a = float(i) * TAU / 12.0; float x = mAt(here() + vec2(cos(a), sin(a)) * max(w, 0.5)); mx = max(mx, x); mn = min(mn, x); }
  float ring = clamp(mx - mn, 0.0, 1.0); float g = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; g += mAt(here() + vec2(cos(a), sin(a)) * p_parlama * u_s); } g = g / 8.0 * (1.0 - m);
  vec4 c = overPre(vec4(c_dolgu, 1.0) * m * p_dolguOpak / 100.0 * pulse, s); c = overPre(vec4(c_konturReng, 1.0) * ring, c); c = overPre(vec4(c_dolgu, 1.0) * g * 0.6 * pulse, c); o = c; }
//== cbspeed
uniform float p_yon, p_cizgiSayi, p_uzunluk, p_kalinlik, p_opaklik, p_hareketiTakiEt, p_tohum; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 d = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec2 n = vec2(-d.y, d.x); vec2 B = boxU(); float acc = 0.0; int N = int(clamp(p_cizgiSayi, 1.0, 80.0));
  for (int i = 0; i < 80; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum) + floor(u_t * 12.0) * 0.0)); float off = (h.x - 0.5) * dot(B, abs(n)) * 0.9;
    float start = dot(B, abs(d)) * 0.5 + h.y * 20.0; float L = p_uzunluk * (0.5 + h.y); float flick = fract(u_t * 3.0 + h.x); vec2 rel = q; float along = -dot(rel, d) - start - flick * 15.0; float ac = dot(rel, n) - off;
    float m = (1.0 - smoothstep(p_kalinlik * 0.5, p_kalinlik * 0.5 + 0.8, abs(ac))) * step(0.0, along) * step(along, L) * (1.0 - along / max(L, 1.0)); acc = max(acc, m); }
  o = overPre(s, vec4(c_renk, 1.0) * acc * p_opaklik / 100.0); }
//== cbdust
uniform vec2 p_merkez; uniform float p_tetiklem, p_sure, p_pufSayi, p_boyut, p_yayilma, p_yumusakl, p_tohum; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float pr = (u_t - p_tetiklem) / max(p_sure, 0.05); if (pr < 0.0 || pr > 1.0) { o = s; return; } float acc = 0.0; int N = int(clamp(p_pufSayi, 1.0, 30.0));
  for (int i = 0; i < 30; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum))); float side = (float(i) / max(float(N) - 1.0, 1.0) - 0.5) * 2.0; vec2 c = p_merkez + vec2(side * p_yayilma * (0.4 + 0.6 * pr), -p_boyut * 0.3 * pr * (0.5 + h.y));
    float r = p_boyut * (0.4 + 0.6 * pr) * (0.6 + 0.6 * h.x); float d = length(q - c); acc = max(acc, (1.0 - smoothstep(r * (1.0 - p_yumusakl / 100.0) - 0.5, r, d)) * (1.0 - pr)); }
  o = overPre(s, vec4(c_renk, 1.0) * acc); }
//== cbflagtrans
uniform sampler2D s_hedefBayr; uniform float p_hedefBayrOn; uniform float p_ilerleme, p_bicim, p_aci, p_yumusatm, p_govdeMaskKoru, p_konturuKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec4 tg = p_hedefBayrOn > 0.5 ? texture(s_hedefBayr, clamp(b, 0.0, 1.0)) : vec4(1.0 - unpre(s), 1.0) * s.a; if (p_govdeMaskKoru > 0.5) tg = pre(tg.a > 0.0 ? tg.rgb / tg.a : vec3(0.0), s.a);
  float pr = p_ilerleme / 100.0; float x; vec2 r = b - 0.5; if (p_bicim < 0.5) x = dot(rot2(p_aci) * r, normalize(vec2(1.0, 1.0))) * 0.7071 + 0.5; else if (p_bicim < 1.5) x = dot(rot2(p_aci) * r, vec2(1.0, 0.0)) + 0.5; else if (p_bicim < 2.5) x = 0.5; else x = length(r) * 1.42;
  float w = p_yumusatm / max(boxU().x, 1.0) + 1e-3; float k = p_bicim > 1.5 && p_bicim < 2.5 ? pr : 1.0 - smoothstep(pr * (1.0 + w * 2.0) - w * 2.0, pr * (1.0 + w * 2.0), x);
  vec4 c = mix(s, tg, k); if (p_konturuKoru > 0.5) { float dark = 1.0 - smoothstep(0.05, 0.2, luma(unpre(s))); c = mix(c, s, dark * s.a * step(0.5, s.a)); } o = c; }
//== cbsticker
uniform float p_icKont, p_disKont, p_golgeUzak, p_golge, p_kose, p_bosluklaDold; uniform vec3 c_icRenk, c_disRenk;
void main() { vec4 s = texture(u_tex, v_uv); float wi = p_icKont * u_s, wo = p_disKont * u_s; float a1 = dilateA(here(), wi); float a2 = dilateA(here(), wi + wo); if (p_kose > 0.5) { a1 = step(0.5, a1); a2 = step(0.5, a2); }
  float sh = dilateA(here() - vec2(0.0, p_golgeUzak * u_s), wi + wo) * p_golge / 100.0; vec4 c = vec4(0.0, 0.0, 0.0, 1.0) * sh; c = overPre(vec4(c_disRenk, 1.0) * a2, c); c = overPre(vec4(c_icRenk, 1.0) * a1, c);
  c = overPre(s, c); o = c; }
