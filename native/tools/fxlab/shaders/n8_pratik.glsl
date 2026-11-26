// 550 rehberi: pratik video/harita araçları (520–528), gelişmiş 3B (529, 533, 537, 539), ip ve kumaş (502, 503)
//== connector
uniform vec2 p_baslangiBagl, p_bitisBagl; uniform float p_bicim, p_egrilik, p_kalinlik, p_ucIsar, p_cizimIler; uniform vec3 c_renk;
vec2 bez(vec2 a, vec2 c, vec2 b, float t) { return mix(mix(a, c, t), mix(c, b, t), t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 A = p_baslangiBagl, B = p_bitisBagl; vec2 m = (A + B) * 0.5; vec2 nrm = normalize(vec2(-(B - A).y, (B - A).x) + 1e-5);
  vec2 C = p_bicim < 0.5 ? m : p_bicim < 1.5 ? m + nrm * length(B - A) * (0.3 + p_egrilik / 200.0) : p_bicim < 2.5 ? vec2(B.x, A.y) : m + nrm * length(B - A) * p_egrilik / 100.0;
  float best = 1e9, bt = 0.0; vec2 prev = A; float prog = p_cizimIler / 100.0;
  for (int i = 1; i <= 32; i++) { float t = float(i) / 32.0; if (t - 1.0 / 32.0 > prog) break; vec2 p = p_bicim > 1.5 && p_bicim < 2.5 ? (t < 0.5 ? mix(A, C, t * 2.0) : mix(C, B, t * 2.0 - 1.0)) : bez(A, C, B, min(t, prog));
    vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(q - prev - ab * u); if (d < best) { best = d; bt = t; } prev = p; }
  float w = p_kalinlik * 0.5; float line = 1.0 - smoothstep(w, w + 0.8 / u_s, best); vec2 end = prev; float cap = 0.0;
  if (p_ucIsar > 0.5) { vec2 dir = normalize(end - bez(A, C, B, max(prog - 0.03, 0.0)) + 1e-5); vec2 l = vec2(dot(q - end, dir), dot(q - end, vec2(-dir.y, dir.x))); float hs = w * 4.0 + 4.0;
    if (p_ucIsar < 1.5 || p_ucIsar > 2.5) cap = max(cap, step(l.x, 0.0) * step(-hs * 1.6, l.x) * step(abs(l.y), (l.x + hs * 1.6) * 0.5)); if (p_ucIsar > 1.5) cap = max(cap, 1.0 - smoothstep(hs * 0.6, hs * 0.6 + 1.0, length(q - A))); }
  o = overPre(vec4(c_renk, 1.0) * max(line, cap), s); }
//== measurearrow
uniform vec2 p_baslangiNokt, p_bitisNokt; uniform float p_olcum, p_birimBasiPiks, p_ondalikBasa, p_okKali, p_yaziBoyu; uniform vec3 c_renk;
float seg7(vec2 p, int d) { int m[10] = int[10](63, 6, 91, 79, 102, 109, 125, 7, 127, 111); int b = m[d % 10]; float r = 0.0;
  vec2 a[7] = vec2[7](vec2(0.0, 0.8), vec2(0.45, 0.4), vec2(0.45, -0.4), vec2(0.0, -0.8), vec2(-0.45, -0.4), vec2(-0.45, 0.4), vec2(0.0, 0.0));
  for (int i = 0; i < 7; i++) { if ((b / int(pow(2.0, float(i)))) % 2 == 0) continue; vec2 q = p - a[i]; bool hz = i == 0 || i == 3 || i == 6; vec2 e = hz ? vec2(0.34, 0.08) : vec2(0.08, 0.32); vec2 dd = abs(q) - e; r = max(r, 1.0 - smoothstep(0.0, 0.06, max(dd.x, dd.y))); } return r; }
float number(vec2 p, float v, int dec) { float r = 0.0; int iv = int(floor(v * pow(10.0, float(dec)) + 0.5)); int nd = 1; int t = iv; for (int i = 0; i < 8; i++) { if (t < 10) break; t /= 10; nd++; } nd = max(nd, dec + 1);
  float w = float(nd) + (dec > 0 ? 0.4 : 0.0); float x0 = -w * 0.55; t = iv;
  for (int i = 0; i < 9; i++) { if (i >= nd) break; int dgt = t % 10; t /= 10; float pos = float(nd - 1 - i) + (dec > 0 && nd - 1 - i >= nd - dec ? 0.4 : 0.0); r = max(r, seg7((p - vec2(x0 + pos * 1.1 + 0.5, 0.0)), dgt)); }
  if (dec > 0) r = max(r, 1.0 - smoothstep(0.08, 0.14, length(p - vec2(x0 + float(nd - dec) * 1.1 + 0.1, -0.8)))); return r; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 A = p_baslangiNokt, B = p_bitisNokt; if (p_olcum > 0.5 && p_olcum < 1.5) B.y = A.y; if (p_olcum > 1.5) B.x = A.x;
  vec2 ab = B - A; float L = length(ab); vec2 dir = ab / max(L, 1e-3); vec2 n = vec2(-dir.y, dir.x); vec2 l = vec2(dot(q - A, dir), dot(q - A, n)); float w = p_okKali * 0.5;
  float line = (1.0 - smoothstep(w, w + 0.8, abs(l.y))) * step(0.0, l.x) * step(l.x, L); float hs = w * 4.0 + 5.0;
  float head = step(abs(l.y), (l.x) * 0.45) * step(l.x, hs) + step(abs(l.y), (L - l.x) * 0.45) * step(L - hs, l.x); float ticks = (1.0 - smoothstep(w, w + 0.8, min(abs(l.x), abs(l.x - L)))) * step(abs(l.y), hs);
  float val = L * u_s / max(p_birimBasiPiks, 1e-3) / u_s; vec2 tp = (vec2(l.x - L * 0.5, -l.y - hs * 1.8)) / max(p_yaziBoyu * 0.5, 1.0); float txt = number(tp, val, int(clamp(p_ondalikBasa, 0.0, 3.0)));
  o = overPre(vec4(c_renk, 1.0) * clamp(max(max(line, head), max(ticks, txt)), 0.0, 1.0), s); }
//== reliefmap
uniform sampler2D s_yuksekliDosy, s_renkHari; uniform float p_yuksekliDosyOn, p_renkHariOn;
uniform float p_yuksekliTersCevi, p_yukselti, p_yumusatm, p_isikYonu, p_isikYuks, p_yuksekliReng;
float hAt(vec2 px) { vec2 b = clamp(boxUV(px), 0.0, 1.0); float h = p_yuksekliDosyOn > 0.5 ? luma(unpre(texture(s_yuksekliDosy, b))) : luma(unpre(texPx(px))); return p_yuksekliTersCevi > 0.5 ? 1.0 - h : h; }
void main() { vec4 s = texture(u_tex, v_uv); float e = max(p_yumusatm, 0.5) * u_s; float dx = hAt(here() + vec2(e, 0.0)) - hAt(here() - vec2(e, 0.0)), dy = hAt(here() + vec2(0.0, e)) - hAt(here() - vec2(0.0, e));
  vec3 n = normalize(vec3(-dx * p_yukselti / 5.0, -dy * p_yukselti / 5.0, 1.0)); float az = radians(p_isikYonu), el = radians(p_isikYuks); vec3 L = vec3(cos(az) * cos(el), -sin(az) * cos(el), sin(el));
  float sh = max(dot(n, L), 0.0); float h = hAt(here()); vec3 base = p_renkHariOn > 0.5 ? unpre(texture(s_renkHari, clamp(boxUV(here()), 0.0, 1.0))) : p_yuksekliReng > 0.5 ? mix(mix(vec3(0.15, 0.45, 0.2), vec3(0.6, 0.5, 0.3), smoothstep(0.2, 0.6, h)), vec3(0.95), smoothstep(0.75, 0.9, h)) : unpre(s);
  o = pre(clamp(base * (0.35 + sh * 0.9), 0.0, 1.0), max(s.a, p_yuksekliDosyOn)); }
//== mapproject
uniform float p_kaynakProj, p_hedefProj, p_merkezBoyl, p_merkezEnle, p_olcek, p_gecersizAlanSayd, p_enlemBoylCizg, p_izgaraAral; uniform vec3 c_izgaraReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 xy = (b - 0.5) * vec2(2.0, -1.0) / max(p_olcek / 100.0, 0.05); float lon, lat; bool ok = true; // xy: x ∈ [-1,1]·π, y ∈ [-0.5,0.5]·π
  if (p_hedefProj < 0.5) { lon = xy.x * PI; lat = atan(sinh(xy.y * PI)); }
  else if (p_hedefProj < 1.5) { lon = xy.x * PI; lat = xy.y * PI; }
  else if (p_hedefProj < 2.5) { vec2 p = vec2(xy.x * 2.0, xy.y * 2.0 * 2.0); float r = length(p); if (r > 1.0) ok = false; float c = asin(clamp(r, 0.0, 1.0)); lat = r < 1e-5 ? 0.0 : asin(clamp(p.y * sin(c) / r, -1.0, 1.0)); lon = atan(p.x * sin(c), r * cos(c)); }
  else if (p_hedefProj < 3.5) { float X = xy.x * 2.0 * 1.4142, Y = xy.y * 2.0 * 1.4142; float th = asin(clamp(Y / 1.4142, -1.0, 1.0)); lon = PI * X / (2.0 * 1.4142 * cos(th)); lat = asin(clamp((2.0 * th + sin(2.0 * th)) / PI, -1.0, 1.0)); if (abs(lon) > PI) ok = false; }
  else { lat = xy.y * PI * 0.97; lon = xy.x * PI / (0.8487 + 0.15 * cos(lat * 1.2)) * 0.85; if (abs(lon) > PI) ok = false; }
  lon += radians(p_merkezBoyl); lat += radians(p_merkezEnle); lon = mod(lon + PI, TAU) - PI; lat = clamp(lat, -PI * 0.5, PI * 0.5);
  vec2 src = p_kaynakProj < 0.5 ? vec2(lon / TAU + 0.5, 0.5 - lat / PI) : vec2(lon / TAU + 0.5, 0.5 - log(tan(PI * 0.25 + clamp(lat, -1.48, 1.48) * 0.5)) / TAU);
  vec4 c = ok ? texPx(boxPx(src)) : (p_gecersizAlanSayd > 0.5 ? vec4(0.0) : vec4(0.0, 0.0, 0.0, 1.0));
  if (p_enlemBoylCizg > 0.5 && ok) { float g = radians(max(p_izgaraAral, 1.0)); vec2 ll = vec2(lon, lat) / g; vec2 fw = fwidth(ll); vec2 d = abs(fract(ll - 0.5) - 0.5) / max(fw, vec2(1e-4)); c = overPre(vec4(c_izgaraReng, 1.0) * (1.0 - min(min(d.x, d.y), 1.0)) * 0.7, c); }
  o = c; }
//== morphimg
uniform sampler2D s_hedefKatm, s_hedefGors; uniform float p_hedefKatmOn, p_hedefGorsOn;
uniform float p_alfaGeci, p_ilerleme, p_sekilEtki, p_renkEtki;
vec4 tgt(vec2 uv) { return p_hedefKatmOn > 0.5 ? texture(s_hedefKatm, uv) : texture(s_hedefGors, uv); }
float sdA(vec2 px, bool other) { // alfa sınırına işaretli uzaklık (yaklaşık, 16 ışın)
  float a0 = other ? tgt(clamp(boxUV(px), 0.0, 1.0)).a : texPx(px).a; float R = 40.0 * u_s; float best = R;
  for (int i = 0; i < 16; i++) { float ang = float(i) * TAU / 16.0; for (int k = 1; k <= 8; k++) { vec2 p = px + vec2(cos(ang), sin(ang)) * R * float(k) / 8.0; float a = other ? tgt(clamp(boxUV(p), 0.0, 1.0)).a : texPx(p).a; if ((a > 0.5) != (a0 > 0.5)) { best = min(best, R * float(k) / 8.0); break; } } }
  return a0 > 0.5 ? -best : best; }
void main() { vec4 s = texture(u_tex, v_uv); if (p_hedefKatmOn < 0.5 && p_hedefGorsOn < 0.5) { o = s; return; } float t = clamp(p_ilerleme / 100.0, 0.0, 1.0); float ts = t * p_sekilEtki / 100.0, tc = t * p_renkEtki / 100.0;
  vec2 uv = clamp(boxUV(here()), 0.0, 1.0); vec4 b = tgt(uv); float a;
  if (p_alfaGeci > 0.5) { float d = mix(sdA(here(), false), sdA(here(), true), ts); a = 1.0 - smoothstep(-1.0 * u_s, 1.0 * u_s, d); } else a = mix(s.a, b.a, ts);
  vec3 ca = s.a > 0.0 ? s.rgb / s.a : (b.a > 0.0 ? b.rgb / b.a : vec3(0.0)), cb = b.a > 0.0 ? b.rgb / b.a : ca; o = pre(mix(ca, cb, tc), a); }
//== lathe3d
INCLUDE(_3d)
uniform float p_donusEkse, p_donusAcis, p_uclariKapa, p_yuzeyKali;
// Profil: katmanın sağ yarısının siluetini (alfa) dönüş ekseni etrafında çevirir
float prof(float r, float y) { vec2 B = boxU(); vec2 u = vec2(0.5 + r / B.x, 0.5 - y / B.y); if (u.x > 1.0 || u.y < 0.0 || u.y > 1.0) return 0.0; return texPx(boxPx(u)).a; }
float sdf(vec3 p) { vec3 a = p_donusEkse < 0.5 ? p.yxz : p_donusEkse < 1.5 ? p : p.xzy; float r = length(a.xz); float ang = degrees(atan(a.z, a.x)) + 180.0; if (ang > p_donusAcis + 0.01) return max(length(vec2(r, 0.0)) * sin(radians(min(ang - p_donusAcis, 90.0))), 1.0);
  float in_ = prof(r, a.y); float d = (0.5 - in_) * 6.0; if (p_yuzeyKali > 0.0) d = max(d, -(d + p_yuzeyKali)); return d; }
vec4 surf(vec3 p, vec3 n) { vec3 a = p_donusEkse < 0.5 ? p.yxz : p_donusEkse < 1.5 ? p : p.xzy; vec2 B = boxU(); vec2 u = vec2(0.5 + length(a.xz) / B.x, 0.5 - a.y / B.y); vec4 c = texPx(boxPx(clamp(u, 0.0, 1.0)));
  return vec4(c.a > 0.0 ? c.rgb / c.a : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== pointcloud
INCLUDE(_3d)
uniform sampler2D s_kaynakKatm; uniform float p_kaynakKatmOn;
uniform float p_noktaSayi, p_noktaBoyu, p_renk, p_dagilma, p_rastgeleBoyu, p_tohum; uniform vec3 c_tekRenk;
float depthAt(vec2 uv) { return p_kaynakKatmOn > 0.5 ? luma(unpre(texture(s_kaynakKatm, uv))) : luma(unpre(texPx(boxPx(uv)))); }
float grid() { return max(sqrt(max(p_noktaSayi, 100.0)), 8.0); }
float sdf(vec3 p) { vec2 B = boxU(); vec2 uv = vec2(p.x / B.x + 0.5, 0.5 - p.y / B.y); if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0)))) return max(abs(p.z), 2.0);
  float G = grid(); vec2 cell = (floor(uv * G) + 0.5) / G; vec2 h = hash2(cell * G + seedf(p_tohum)) - 0.5; vec2 cu = cell + h / G * p_dagilma / 100.0; float a = texPx(boxPx(cu)).a; if (a < 0.5) return max(B.x / G, 2.0);
  vec3 c = vec3((cu.x - 0.5) * B.x, (0.5 - cu.y) * B.y, depthAt(cu) * max(B.x, B.y) * 0.3); float r = p_noktaBoyu * 0.5 * (1.0 + (hash1(cu * 97.0) - 0.5) * p_rastgeleBoyu / 50.0);
  return min(length(p - c) - max(r, 0.4), max(B.x / G * 0.5, 1.0)); }
vec4 surf(vec3 p, vec3 n) { vec2 B = boxU(); vec2 uv = vec2(p.x / B.x + 0.5, 0.5 - p.y / B.y); float G = grid(); vec2 cell = (floor(uv * G) + 0.5) / G; vec4 c = texPx(boxPx(cell));
  vec3 col = p_renk < 0.5 ? (c.a > 0.0 ? c.rgb / c.a : vec3(1.0)) : p_renk < 1.5 ? c_tekRenk : mix(vec3(0.1, 0.3, 1.0), vec3(1.0, 0.4, 0.1), depthAt(cell)); return vec4(col, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== volslices
uniform sampler2D s_dilimDizi; uniform float p_dilimDiziOn;
uniform float p_dilimKayn, p_dilimSayi, p_dilimAral, p_sonOlce, p_dilimDonu, p_dilimOpak, p_uzakSolm, p_derinlikSira;
void main() { vec2 q = toUnit(here()); int N = int(clamp(p_dilimSayi, 1.0, 48.0)); vec4 res = vec4(0.0);
  for (int i = 0; i < 48; i++) { if (i >= N) break; int k = p_derinlikSira > 0.5 ? N - 1 - i : i; float f = float(k) / max(float(N - 1), 1.0); float sc = mix(1.0, p_sonOlce / 100.0, f);
    vec2 l = rot2(-p_dilimDonu * f) * (q - vec2(0.0, -p_dilimAral * float(k) * 0.5)) / max(sc, 0.05); vec4 c = texU(l);
    if (p_dilimKayn > 0.5 && p_dilimDiziOn > 0.5) { vec2 b = clamp(boxUV(fromUnit(l)), 0.0, 1.0); c = texture(s_dilimDizi, vec2((b.x + float(k)) / float(N), b.y)); }
    float lum = luma(c.a > 0.0 ? c.rgb / c.a : vec3(0.0)); float band = smoothstep(f - 0.6 / float(N), f, lum) * (p_dilimKayn < 0.5 ? 1.0 : 1.0);
    c *= p_dilimOpak / 100.0 * (1.0 - f * p_uzakSolm / 100.0) * (p_dilimKayn < 0.5 ? mix(1.0, band, 0.7) : 1.0); res = overPre(c, res); }
  o = res; }
//== scatter3d
uniform float p_alan, p_kopyaSayi, p_minimumMesa, p_tohum, p_boyutRast, p_yuzeyNormHiza; uniform vec3 p_alanBoyu, p_donusRast;
void main() { vec2 q = toUnit(here()); int N = int(clamp(p_kopyaSayi, 1.0, 160.0)); vec4 res = vec4(0.0); float F = 900.0; float sd = seedf(p_tohum);
  for (int i = 160; i >= 0; i--) { if (i >= N) continue; float fi = float(i); vec3 h = vec3(hash2(vec2(fi, sd)), hash1(vec2(fi, sd + 4.0))) - 0.5; vec3 P;
    if (p_alan < 0.5) P = h * p_alanBoyu; else if (p_alan < 1.5) { vec3 d = normalize(h + 1e-3); P = d * p_alanBoyu * 0.5; } else if (p_alan < 2.5) { float g = ceil(pow(float(N), 1.0 / 3.0)); vec3 id = vec3(mod(fi, g), mod(floor(fi / g), g), floor(fi / (g * g))); P = (id / max(g - 1.0, 1.0) - 0.5) * p_alanBoyu; }
    else { float a = fi / float(N) * TAU; P = vec3(cos(a) * p_alanBoyu.x * 0.5, h.y * p_alanBoyu.y * 0.1, sin(a) * p_alanBoyu.z * 0.5); }
    float persp = F / max(F + P.z, 50.0); vec2 c = P.xy * persp; float sc = persp * 0.25 * (1.0 + h.z * p_boyutRast / 50.0); vec3 r = h * 2.0 * p_donusRast;
    vec2 l = rot2(-r.z) * (q - c) / max(sc, 0.01); l.x /= max(abs(cos(radians(r.y))), 0.15); l.y /= max(abs(cos(radians(r.x))), 0.15); res = overPre(texU(l), res); }
  o = res; }
//== ropephys
uniform vec2 p_baslangi, p_bitis, p_ruzgar; uniform float p_uzunluk, p_kalinlik, p_sertlik, p_sonum, p_yercekim; uniform vec3 c_renk;
// İp: iki uç arası sarkık eğri (zincir eğrisi yaklaşımı); fazla uzunluk sarkmayı, rüzgâr ve sönümlü salınım yanal hareketi belirler
vec2 ropeAt(float t) { vec2 A = p_baslangi, B = p_bitis; float span = length(B - A); float slack = max(p_uzunluk - span, 0.0); float sag = sqrt(slack * max(span, 1.0) * 0.375) * (p_yercekim / 300.0) * (1.0 - p_sertlik / 200.0);
  float sw = sin(u_t * (1.0 + p_sertlik / 30.0)) * exp(-u_t * p_sonum / 100.0) * 0.5 + 0.5 * sin(u_t * 0.7); vec2 wind = p_ruzgar * (0.6 + 0.4 * sw) * 0.4;
  float k = 4.0 * t * (1.0 - t); return mix(A, B, t) + vec2(0.0, sag) * k + wind * k; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float best = 1e9; vec2 prev = ropeAt(0.0); float bt = 0.0;
  for (int i = 1; i <= 40; i++) { float t = float(i) / 40.0; vec2 p = ropeAt(t); vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(q - prev - ab * u); if (d < best) { best = d; bt = t; } prev = p; }
  float w = max(p_kalinlik, 0.5) * 0.5; float m = 1.0 - smoothstep(w, w + 0.8 / u_s, best); float tw = 0.85 + 0.15 * sin(bt * 120.0 + best / w * 2.0); vec3 c = c_renk * tw * (1.0 - smoothstep(0.0, w, best) * 0.35);
  o = overPre(vec4(c, 1.0) * m, s); }
//== clothphys
uniform float p_agCozu, p_sabitKena, p_sertlik, p_bukulmeDire, p_sonum, p_yercekim, p_ciftTaraGost, p_golgelen; uniform vec2 p_ruzgar;
void main() { vec2 q = toUnit(here()); vec2 b = boxUV(here()); vec2 B = boxU(); float u = p_sabitKena < 0.5 ? b.x : p_sabitKena < 1.5 ? 1.0 - b.x : p_sabitKena < 2.5 ? b.y : 1.0 - b.y; vec2 fdir = p_sabitKena < 0.5 ? vec2(1, 0) : p_sabitKena < 1.5 ? vec2(-1, 0) : p_sabitKena < 2.5 ? vec2(0, 1) : vec2(0, -1);
  float stiff = mix(1.6, 0.7, p_sertlik / 100.0); float w = pow(u, stiff); float wind = length(p_ruzgar); vec2 wd = wind > 0.0 ? p_ruzgar / wind : vec2(1.0, 0.0);
  float ph = q.y * 0.02 * (1.0 + p_bukulmeDire / 50.0) + q.x * 0.01 - u_t * (1.0 + wind / 150.0) * 2.0; float res = max(p_agCozu, 4.0) / 24.0;
  float h = (sin(ph * TAU / res) + 0.4 * sin(ph * TAU * 1.7 / res + 1.3)) * wind / 150.0 * 14.0 * w * (1.0 + 0.3 * exp(-u_t * p_sonum / 50.0));
  vec2 sag = vec2(0.0, p_yercekim / 100.0 * 12.0 * w * w); vec2 sq = q - vec2(-fdir.y, fdir.x) * h - sag - wd * w * wind * 0.02; vec4 c = texU(sq);
  float slope = cos(ph * TAU / res); if (p_golgelen > 0.5) c.rgb *= 1.0 + slope * w * 0.25 * min(wind / 150.0, 1.5); if (p_ciftTaraGost > 0.5 && slope * w < -0.7) c.rgb *= 0.75; o = c; }
