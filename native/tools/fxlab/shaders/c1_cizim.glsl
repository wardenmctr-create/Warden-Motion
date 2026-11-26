// Çizim ve Kenar (rehberdeki ayarlar)
//== glow_a
uniform float p_yayilim;
void main() { float a = dilateA(here(), 0.0); vec4 s = texture(u_tex, v_uv); o = vec4(min(1.0, s.a * (1.0 + p_yayilim / 100.0 * 3.0))); }
//== glow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_yogunluk, p_karistir, p_yalnizParl;
void main() {
  vec4 s = texture(u_src, v_uv); float g = clamp(texture(u_aux, v_uv).a * p_yogunluk / 100.0 * 1.8, 0.0, 1.0); vec4 gc = vec4(c_renk, 1.0) * g;
  if (p_yalnizParl > 0.5) { o = gc * (1.0 - s.a); return; }
  if (p_karistir < 0.5) o = vec4(s.rgb + gc.rgb * (1.0 - s.rgb) * (1.0 - s.a * 0.7), max(s.a, g));
  else if (p_karistir < 1.5) o = vec4(min(s.rgb + gc.rgb * (1.0 - s.a * 0.6), vec3(1.0)), max(s.a, g));
  else o = overPre(s, gc);
}
//== shadow_a
uniform float p_aci, p_mesafe, p_yayilma;
void main() { float a = radians(p_aci); vec2 off = vec2(cos(a), sin(a)) * p_mesafe * u_s; o = vec4(dilateA(here() - off, p_yayilma * u_s)); }
//== shadow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_opaklik, p_yalnizGolg;
void main() { vec4 s = texture(u_src, v_uv); vec4 sh = vec4(c_renk, 1.0) * texture(u_aux, v_uv).a * p_opaklik / 100.0; o = p_yalnizGolg > 0.5 ? sh * (1.0 - s.a) : overPre(s, sh); }
//== stroke
uniform float p_kalinlik, p_konum, p_opaklik, p_birlesim, p_yalnizCizg; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); float w = p_kalinlik * u_s; float ring;
  if (p_konum < 0.5) ring = clamp(dilateA(here(), w) - s.a, 0.0, 1.0);
  else if (p_konum < 1.5) ring = clamp(s.a - erodeA(here(), w), 0.0, 1.0);
  else ring = clamp(dilateA(here(), w * 0.5) - erodeA(here(), w * 0.5), 0.0, 1.0);
  vec4 st = vec4(c_renk, 1.0) * ring * p_opaklik / 100.0;
  if (p_yalnizCizg > 0.5) { o = st; return; }
  o = p_konum < 0.5 ? overPre(s, st) : overPre(st, s * (1.0 - ring * p_opaklik / 100.0));
}
//== innerglow
uniform vec3 c_renk; uniform float p_yaricap, p_yogunluk, p_yayilma, p_kaynak, p_karistir;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float R = max(p_yaricap * u_s, 1.0); float d = innerDist(here(), R) / R;
  float g = p_kaynak < 0.5 ? 1.0 - smoothstep(p_yayilma / 100.0 * 0.8, 1.0, d) : smoothstep(0.0, 1.0 - p_yayilma / 100.0 * 0.8, d);
  g *= p_yogunluk / 100.0; vec3 c = unpre(s);
  vec3 r = p_karistir < 0.5 ? screenB(c, c_renk * g) : mix(c, c_renk, g);
  o = pre(r, s.a);
}
//== innershadow
uniform vec3 c_renk; uniform float p_opaklik, p_aci, p_mesafe, p_yumusakl, p_daralma;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float a = radians(p_aci); vec2 off = vec2(cos(a), sin(a)) * p_mesafe * u_s; float R = max(p_yumusakl * u_s, 1.0);
  float d = innerDist(here() - off, R) / R; float sh = (1.0 - smoothstep(p_daralma / 100.0, 1.0, d)) * p_opaklik / 100.0;
  if (texPx(here() - off).a < 0.5) sh = p_opaklik / 100.0;
  o = pre(mix(unpre(s), c_renk, sh), s.a);
}
//== edges
uniform float p_yontem, p_esik, p_kalinlik, p_tersCevi, p_saydamArkaPlan; uniform vec3 c_kenarReng, c_arkaPlan;
void main() {
  vec4 s = texture(u_tex, v_uv); float st = max(1.0, p_kalinlik * u_s * 0.5); float e;
  if (p_yontem < 1.5) e = sobel(here(), st) * (p_yontem > 0.5 ? 1.2 : 1.0) * 0.5;
  else e = abs(4.0 * lumAt(here()) - lumAt(here() + vec2(st, 0.0)) - lumAt(here() - vec2(st, 0.0)) - lumAt(here() + vec2(0.0, st)) - lumAt(here() - vec2(0.0, st))) * 1.5;
  e += length(alphaGrad(here(), st)) * st * 0.8;
  float k = smoothstep(p_esik / 100.0 * 0.5, p_esik / 100.0 * 0.5 + 0.15, e); if (p_tersCevi > 0.5) k = 1.0 - k;
  float a = max(s.a, k * 0.0 + (s.a > 0.0 ? 1.0 : k));
  if (p_saydamArkaPlan > 0.5) { o = vec4(c_kenarReng, 1.0) * k; return; }
  o = pre(mix(c_arkaPlan, c_kenarReng, k), max(s.a, k));
}
//== emboss
uniform float p_isikAcis, p_yuksekli, p_kabartmaGucu, p_isikSevi, p_rengiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float a = radians(p_isikAcis); vec2 d = vec2(cos(a), sin(a)) * max(p_yuksekli * u_s, 0.5);
  float e = (lumAt(here() + d) - lumAt(here() - d)) * p_kabartmaGucu / 100.0 * 2.0 + (texPx(here() + d).a - texPx(here() - d).a) * 0.5 * p_kabartmaGucu / 100.0;
  float g = clamp(p_isikSevi / 100.0 + e, 0.0, 1.0);
  vec3 r = p_rengiKoru > 0.5 ? clamp(unpre(s) + (g - p_isikSevi / 100.0), 0.0, 1.0) : vec3(g);
  o = pre(r, s.a);
}
//== halftone
uniform float p_noktaBoyu, p_aci, p_kontrast, p_tur, p_saydamArkaPlan; uniform vec3 c_murekkep, c_kagit;
float dotAt(vec2 px, float ang, float l, float shape) {
  float sz = max(p_noktaBoyu * u_s, 2.0); vec2 p = rot2(-ang) * (px - u_box.xy); vec2 c = (floor(p / sz) + 0.5) * sz; vec2 f = (p - c) / sz;
  float d = shape < 0.5 ? length(f) * 2.0 : shape < 1.5 ? max(abs(f.x), abs(f.y)) * 2.0 : (abs(f.x) + abs(f.y)) * 1.42;
  float r = sqrt(1.0 - l) * 1.15; return 1.0 - smoothstep(r - 0.08, r + 0.08, d);
}
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = conAdj(unpre(s), 1.0 + p_kontrast / 100.0, 0.5); c = clamp(c, 0.0, 1.0);
  vec3 r;
  if (p_tur > 2.5) { vec3 cmy = 1.0 - c; float k = min(cmy.r, min(cmy.g, cmy.b));
    float dc = dotAt(here(), radians(15.0), 1.0 - cmy.r, 0.0), dm = dotAt(here(), radians(75.0), 1.0 - cmy.g, 0.0), dy = dotAt(here(), 0.0, 1.0 - cmy.b, 0.0), dk = dotAt(here(), radians(45.0), 1.0 - k, 0.0);
    r = c_kagit * (1.0 - vec3(dc, 0.0, 0.0)) * (1.0 - vec3(0.0, dm, 0.0)) * (1.0 - vec3(0.0, 0.0, dy)) * (1.0 - dk); }
  else { float d = dotAt(here(), radians(p_aci), luma(c), p_tur); r = mix(c_kagit, c_murekkep, d);
    if (p_saydamArkaPlan > 0.5) { o = vec4(c_murekkep, 1.0) * d * s.a; return; } }
  o = pre(r, s.a);
}
//== sketch
uniform float p_cizgiGucu, p_kalemKali, p_taramaYogu, p_renkliKale; uniform vec3 c_kagitReng, c_kalemReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float e = sobel(here(), max(1.0, p_kalemKali * u_s * 0.6)) * p_cizgiGucu / 100.0 * 1.6;
  float l = luma(c); vec2 p = here() / max(u_s * 4.0, 2.0);
  float h1 = step(0.5, fract((p.x + p.y) * 0.7)) * (1.0 - smoothstep(0.35, 0.6, l)); float h2 = step(0.5, fract((p.x - p.y) * 0.7)) * (1.0 - smoothstep(0.1, 0.35, l));
  float ink = clamp(e + (h1 + h2) * p_taramaYogu / 100.0 * 0.5, 0.0, 1.0);
  vec3 pen = p_renkliKale > 0.5 ? c * 0.6 : c_kalemReng;
  o = pre(mix(c_kagitReng, pen, ink), s.a);
}
//== neonedge
uniform float p_esik, p_kenarKali, p_hale, p_yogunluk, p_kaynakRenkKull, p_arkaPlanKara; uniform vec3 c_neonReng;
void main() {
  vec4 s = texture(u_tex, v_uv); float st = max(1.0, p_kenarKali * u_s * 0.5);
  float e = smoothstep(p_esik / 100.0 * 0.4, p_esik / 100.0 * 0.4 + 0.12, sobel(here(), st) * 0.5 + length(alphaGrad(here(), st)) * st);
  float g = 0.0; float R = p_hale * u_s;
  for (int i = 0; i < 12; i++) { float a = float(i) * TAU / 12.0; vec2 d = vec2(cos(a), sin(a)); g += smoothstep(p_esik / 100.0 * 0.4, p_esik / 100.0 * 0.4 + 0.12, sobel(here() + d * R * 0.45, st) * 0.5) * 0.5 + smoothstep(p_esik / 100.0 * 0.4, p_esik / 100.0 * 0.4 + 0.12, sobel(here() + d * R, st) * 0.5) * 0.25; }
  g /= 12.0;
  vec3 col = p_kaynakRenkKull > 0.5 ? (s.a > 0.0 ? normalize(unpre(s) + 0.05) : c_neonReng) : c_neonReng;
  float k = p_yogunluk / 100.0; vec3 line = mix(col, vec3(1.0), 0.5 * e) * e;
  vec3 bg = p_arkaPlanKara > 0.5 ? vec3(0.02, 0.03, 0.08) : unpre(s) * 0.35;
  vec3 r = bg + (line + col * g * 1.5) * k;
  o = pre(clamp(r, 0.0, 1.0), max(s.a, clamp(e + g, 0.0, 1.0)));
}
//== cartoon
uniform float p_renkSevi, p_kenarEsig, p_kenarKali, p_yuzeyYumu, p_cizgilerGost; uniform vec3 c_kenarReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 acc = vec3(0.0); float ws = 0.0; float R = p_yuzeyYumu * u_s; vec3 c0 = unpre(s);
  for (int i = -2; i <= 2; i++) for (int j = -2; j <= 2; j++) { vec2 d = vec2(float(i), float(j)) * R * 0.5; vec4 x = texPx(here() + d); if (x.a < 0.01) continue; vec3 c = x.rgb / x.a; float w = exp(-dot(c - c0, c - c0) * 12.0); acc += c * w; ws += w; }
  vec3 c = acc / max(ws, 1e-3); float n = max(2.0, p_renkSevi) - 1.0; vec3 h = rgb2hsv(c); h.z = floor(h.z * n + 0.5) / n; c = hsv2rgb(h);
  if (p_cizgilerGost > 0.5) { float e = smoothstep(p_kenarEsig / 100.0 * 0.5, p_kenarEsig / 100.0 * 0.5 + 0.1, sobel(here(), max(1.0, p_kenarKali * u_s * 0.6)) * 0.5); c = mix(c, c_kenarReng, e); }
  o = pre(c, s.a);
}
//== roughen
uniform float p_kenarMikt, p_dokuOlce, p_ayrinti, p_evrim, p_tohum, p_kenarYumu;
void main() {
  vec2 q = toUnit(here()); vec2 n = q / max(p_dokuOlce, 1.0) + seedf(p_tohum);
  vec2 d = vec2(fbm(n + vec2(p_evrim * 0.05, 0.0), p_ayrinti - 1.0), fbm(n + vec2(3.7, -p_evrim * 0.05), p_ayrinti - 1.0)) * p_kenarMikt;
  vec4 s = texU(q); vec4 w = texU(q + d);
  float a = smoothstep(0.5 - max(p_kenarYumu, 0.3) * 0.1, 0.5 + max(p_kenarYumu, 0.3) * 0.1, w.a);
  o = pre(s.a > 0.01 ? unpre(s) : unpre(w), a);
}
//== frame
uniform float p_cerceveKali, p_icBosl, p_koseYari, p_opaklik, p_konum; uniform vec3 c_renk;
float rbox(vec2 p, vec2 b, float r) { vec2 q = abs(p) - b + r; return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r; }
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU() * 0.5;
  float w = p_cerceveKali; vec2 bb = p_konum < 0.5 ? B - p_icBosl - w : p_konum < 1.5 ? B + p_icBosl : B - w * 0.5;
  float d = rbox(q, bb, min(p_koseYari, min(bb.x, bb.y)));
  float ring = smoothstep(-0.6, 0.6, d) * (1.0 - smoothstep(w - 0.6, w + 0.6, d));
  o = overPre(vec4(c_renk, 1.0) * ring * p_opaklik / 100.0, s);
}
//== brushstrokes
uniform float p_fircaBoyu, p_darbeUzun, p_aci, p_aciCesi, p_yogunluk, p_tohum, p_kaynakRenkKoru;
void main() {
  vec4 s0 = texture(u_tex, v_uv); vec2 px = here(); float sz = max(p_fircaBoyu * u_s, 2.0); vec2 id = floor(px / sz);
  vec4 acc = vec4(0.0); float ws = 0.0;
  for (int i = -1; i <= 1; i++) for (int j = -1; j <= 1; j++) {
    vec2 cid = id + vec2(float(i), float(j)); vec2 r = hash2(cid + seedf(p_tohum)); vec2 cp = (cid + r) * sz;
    float a = radians(p_aci + (r.x - 0.5) * 2.0 * p_aciCesi * 0.9); vec2 dir = vec2(cos(a), sin(a));
    vec2 rel = px - cp; float u = dot(rel, dir), v = dot(rel, vec2(-dir.y, dir.x)); float L = max(p_darbeUzun * u_s * 0.5, sz * 0.5);
    float m = (1.0 - smoothstep(L * 0.7, L, abs(u))) * (1.0 - smoothstep(sz * 0.35, sz * 0.55, abs(v)));
    vec4 c = texPx(cp); acc += c * m; ws += m;
  }
  vec4 b = ws > 0.0 ? acc / ws : s0;
  b.rgb *= 1.0 + (hash1(floor(px / 2.0)) - 0.5) * 0.06;
  o = mix(s0, b, p_yogunluk / 100.0) * (s0.a > 0.0 || p_kaynakRenkKoru < 0.5 ? 1.0 : 0.0);
}
//== glass
uniform sampler2D s_dokuKatm; uniform float p_dokuKatmOn; uniform float p_kirilma, p_camDoku, p_dokuOlce, p_bulanikl, p_parlakli;
void main() {
  vec2 q = toUnit(here()); vec2 n;
  if (p_dokuKatmOn > 0.5 || p_camDoku > 1.5) { vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec2 e = 2.0 / u_box.zw; n = vec2(luma(unpre(texture(s_dokuKatm, b + vec2(e.x, 0.0)))) - luma(unpre(texture(s_dokuKatm, b - vec2(e.x, 0.0)))), luma(unpre(texture(s_dokuKatm, b + vec2(0.0, e.y)))) - luma(unpre(texture(s_dokuKatm, b - vec2(0.0, e.y))))) * 4.0; }
  else if (p_camDoku < 0.5) { vec2 p = q / max(p_dokuOlce, 1.0) * 6.0; n = vec2(hash1(floor(p * 3.0)) - 0.5, hash1(floor(p * 3.0) + 9.0) - 0.5) * 0.6 + vec2(pnoise(p), pnoise(p + 5.0)) * 0.6; }
  else { vec2 p = q / max(p_dokuOlce, 1.0); n = vec2(sin(p.y * TAU + sin(p.x * 3.0)), cos(p.x * TAU * 0.7)) * 0.6; }
  vec2 d = n * p_kirilma; vec4 acc = vec4(0.0); float R = p_bulanikl;
  for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; acc += texU(q + d + vec2(cos(a), sin(a)) * R * 0.6); }
  vec4 c = mix(texU(q + d), acc / 8.0, step(0.5, R));
  c.rgb += p_parlakli / 100.0 * 0.4 * max(n.x + n.y, 0.0) * c.a;
  o = c;
}
//== plastic
uniform float p_parlakYuze, p_kabartma, p_isikAcis, p_isikYuks, p_yuzeyPuru; uniform vec3 c_isikReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float st = max(1.0, p_kabartma * u_s * 0.5); vec2 g = lumGrad(here(), st) * st * 3.0 + alphaGrad(here(), st) * st * 2.0;
  g += (vec2(hash1(floor(here())), hash1(floor(here()) + 3.0)) - 0.5) * p_yuzeyPuru / 100.0 * 0.3;
  vec3 n = normalize(vec3(-g * p_kabartma * 0.4, 1.0)); float a = radians(p_isikAcis), e = radians(p_isikYuks);
  vec3 L = normalize(vec3(cos(a) * cos(e), sin(a) * cos(e), sin(e))); vec3 H = normalize(L + vec3(0, 0, 1));
  float sp = pow(max(dot(n, H), 0.0), mix(8.0, 60.0, p_parlakYuze / 100.0)) * p_parlakYuze / 100.0 * 1.5;
  vec3 c = unpre(s) * (0.75 + 0.35 * max(dot(n, L), 0.0)) + c_isikReng * sp;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== coloremboss
uniform float p_kabartmaYuks, p_isikAcis, p_guc, p_renkKoru, p_kontrast;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float a = radians(p_isikAcis); vec2 d = vec2(cos(a), sin(a)) * max(p_kabartmaYuks * u_s, 0.5);
  vec3 e = (unpre(texPx(here() + d)) - unpre(texPx(here() - d))) * p_guc / 100.0;
  vec3 c = mix(vec3(0.5), unpre(s), p_renkKoru / 100.0) + e; c = conAdj(c, 1.0 + p_kontrast / 100.0, 0.5);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== texturize
uniform sampler2D s_dokuDosy; uniform float p_dokuDosyOn; uniform float p_doku, p_olcek, p_kabartma, p_aci, p_dokuGucu, p_tersDoku;
float tx(vec2 p) {
  if (p_dokuDosyOn > 0.5 || p_doku > 3.5) return luma(unpre(texture(s_dokuDosy, fract(p / 120.0))));
  if (p_doku < 0.5) { vec2 f = fract(p / 4.0); return 0.5 + 0.25 * (sin(p.x * 1.6) * 0.5 + sin(p.y * 1.6) * 0.5) * step(0.5, f.x + f.y * 0.0) + vnoise(p * 0.6) * 0.2; }
  if (p_doku < 1.5) return 0.5 + (fbm(p / 8.0, 3.0)) * 0.35 + (hash1(floor(p)) - 0.5) * 0.08;
  if (p_doku < 2.5) { vec2 b = p / vec2(40.0, 18.0); b.x += step(1.0, mod(floor(b.y), 2.0)) * 0.5; vec2 f = fract(b); float m = step(0.06, f.x) * step(0.1, f.y); return 0.35 + 0.4 * m + vnoise(p * 0.3) * 0.15; }
  return 0.5 + 0.3 * sin(p.x * 0.15 + fbm(p / vec2(80.0, 10.0), 2.0) * 6.0);
}
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 p = toUnit(here()) / max(p_olcek / 100.0, 0.01); float a = radians(p_aci); vec2 d = vec2(cos(a), sin(a)) * max(p_kabartma, 0.3);
  float h = tx(p), h2 = tx(p + d); if (p_tersDoku > 0.5) { h = 1.0 - h; h2 = 1.0 - h2; }
  float sh = (h2 - h) * p_kabartma * 0.5 + (h - 0.5) * 0.4;
  o = pre(clamp(unpre(s) * (1.0 + sh * p_dokuGucu / 100.0 * 1.6), 0.0, 1.0), s.a);
}
//== bevelalpha
uniform float p_pahGeni, p_pahDeri, p_isikAcis, p_guc, p_icPah; uniform vec3 c_acikRenk, c_koyuRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0 && p_icPah > 0.5) { o = s; return; }
  float W = max(p_pahGeni * u_s, 1.0); float st = W * 0.35;
  vec2 g = alphaGrad(here(), st) * st; float d = innerDist(here(), W) / W;
  float band = 1.0 - smoothstep(0.6, 1.0, d);
  float a = radians(p_isikAcis); float lit = dot(normalize(g + 1e-5), -vec2(cos(a), sin(a))) * min(1.0, length(g) * 4.0) * band * (p_pahDeri / max(p_pahGeni, 0.1));
  vec3 c = unpre(s); c = lit > 0.0 ? mix(c, c_acikRenk, clamp(lit, 0.0, 1.0) * p_guc / 100.0) : mix(c, c_koyuRenk, clamp(-lit, 0.0, 1.0) * p_guc / 100.0);
  o = pre(c, s.a);
}
//== beveledges
uniform float p_genislik, p_derinlik, p_isikAcis, p_koseBici; uniform vec3 c_acikRenk, c_koyuRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 q = toUnit(here()); vec2 B = boxU() * 0.5; vec2 e = B - abs(q); float W = max(p_genislik, 0.5);
  float dx = e.x, dy = e.y; float m = min(dx, dy); if (m > W) { o = s; return; }
  vec2 n = dx < dy ? vec2(sign(q.x), 0.0) : vec2(0.0, sign(q.y));
  if (p_koseBici > 0.5) { vec2 k = max(W - e, 0.0); if (k.x > 0.0 && k.y > 0.0) n = normalize(k * sign(q)); }
  float a = radians(p_isikAcis); float lit = dot(n, -vec2(cos(a), sin(a))) * (p_derinlik / max(W, 0.1)) * (1.0 - m / W * 0.5);
  vec3 c = unpre(s); c = lit > 0.0 ? mix(c, c_acikRenk, clamp(lit, 0.0, 0.85)) : mix(c, c_koyuRenk, clamp(-lit, 0.0, 0.85));
  o = pre(c, s.a);
}
//== spotlight
uniform vec2 p_merkez; uniform float p_isikYari, p_kenarYumu, p_isikYogu, p_ortamIsig, p_elipsOran; uniform vec3 c_isikReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 r = toUnit(here()) - p_merkez; r.x /= max(p_elipsOran, 0.05); float R = max(p_isikYari, 1.0);
  float l = 1.0 - smoothstep(R * (1.0 - p_kenarYumu / 100.0), R, length(r));
  vec3 k = mix(vec3(p_ortamIsig / 100.0), c_isikReng * (0.6 + 0.6 * p_isikYogu / 100.0), l);
  o = pre(clamp(unpre(s) * k, 0.0, 1.0), s.a);
}
//== anaglyph
uniform sampler2D s_solGozKatm, s_sagGozKatm; uniform float p_solGozKatmOn, p_sagGozKatmOn;
uniform float p_ayrisma, p_yakinsam, p_filtre, p_gozleriDegi;
void main() {
  float d = (p_ayrisma - p_yakinsam) * u_s * 0.5; if (p_gozleriDegi > 0.5) d = -d;
  vec4 L = p_solGozKatmOn > 0.5 ? texture(s_solGozKatm, clamp(boxUV(here()), 0.0, 1.0)) : texPx(here() + vec2(d, 0.0));
  vec4 R = p_sagGozKatmOn > 0.5 ? texture(s_sagGozKatm, clamp(boxUV(here()), 0.0, 1.0)) : texPx(here() - vec2(d, 0.0));
  vec3 l = unpre(L), r = unpre(R);
  vec3 c = p_filtre < 0.5 ? vec3(luma(l) * 0.3 + l.r * 0.7, r.g, r.b) : vec3(r.r, luma(l) * 0.3 + l.g * 0.7, r.b);
  float a = max(L.a, R.a);
  o = pre(c, a);
}
//== lightsweep
uniform vec2 p_merkez; uniform float p_aci, p_seritGeni, p_isikGucu, p_kenarVurg, p_seritBici; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float a = radians(p_aci); vec2 n = vec2(cos(a), sin(a)); float d = abs(dot(toUnit(here()) - p_merkez, n)); float w = max(p_seritGeni * 0.5, 0.5);
  float k = p_seritBici < 0.5 ? exp(-d * d / (w * w) * 2.0) : 1.0 - smoothstep(w - 0.8, w + 0.8, d);
  float ed = clamp(length(alphaGrad(here(), 1.5)) * 3.0, 0.0, 1.0) * p_kenarVurg / 100.0;
  vec3 c = unpre(s) + c_renk * k * (p_isikGucu / 100.0) * (0.8 + ed * 2.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== vegas
uniform float p_noktaSayi, p_noktaBoyu, p_faz, p_hiz, p_bosluk, p_hale, p_tersYon; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU() * 0.5;
  // kutunun çevresi boyunca konum
  vec2 e = B - abs(q); float per = 4.0 * (B.x + B.y);
  float t; if (e.x < e.y) t = q.x > 0.0 ? 2.0 * B.x + (q.y + B.y) : 4.0 * B.x + 2.0 * B.y + (B.y - q.y); else t = q.y < 0.0 ? (q.x + B.x) : 2.0 * B.x + 2.0 * B.y + (B.x - q.x);
  t = t / per; float n = max(2.0, floor(p_noktaSayi));
  float ph = t * n - (u_t * p_hiz * (p_tersYon > 0.5 ? -1.0 : 1.0)) * n * 0.2 - p_faz / 100.0 * n;
  float id = floor(ph); float on = step(p_bosluk / 100.0, fract(id * 0.37 + u_t * p_hiz));
  float sp = per / n; float dAlong = (fract(ph) - 0.5) * sp; float dPerp = min(e.x, e.y) - p_noktaBoyu;
  float d = length(vec2(dAlong, dPerp)); float r = max(p_noktaBoyu * 0.5, 0.5);
  float core = (1.0 - smoothstep(r - 0.5, r + 0.5, d)) * on; float halo = exp(-max(d - r, 0.0) / max(p_hale * 0.4, 0.5)) * on * 0.6;
  vec4 L = vec4(mix(c_renk, vec3(1.0), core * 0.5), 1.0) * clamp(core + halo, 0.0, 1.0);
  o = overPre(L, s);
}
//== scribble
uniform float p_cizgiKali, p_aci, p_cizgiAral, p_kivrim, p_rastgele, p_ilerleme, p_tohum; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()); float sp = max(p_cizgiAral, 1.0);
  float row = floor(q.y / sp + 0.5); float y = q.y - row * sp;
  float wob = sin(q.x / max(p_kivrim * 4.0, 1.0) + row * 1.7 + seedf(p_tohum)) * p_kivrim * 0.5 * (0.5 + p_rastgele / 100.0) + (vnoise(vec2(q.x * 0.05, row + seedf(p_tohum))) - 0.5) * p_rastgele / 100.0 * sp;
  float d = abs(y - wob); float line = 1.0 - smoothstep(p_cizgiKali * 0.5 - 0.5, p_cizgiKali * 0.5 + 0.5, d);
  vec2 B = boxU(); float prog = (row * sp / B.y + 0.5); float shown = step(prog, p_ilerleme / 100.0 * 1.02);
  o = vec4(c_renk, 1.0) * line * s.a * shown;
}
//== watercolor
uniform float p_lekeBoyu, p_renkYayi, p_kagitDoku, p_pigmentGucu, p_kenarKara, p_tohum;
void main() {
  vec2 q = toUnit(here()); vec2 w = vec2(fbm(q / max(p_lekeBoyu, 1.0) + seedf(p_tohum), 2.0), fbm(q / max(p_lekeBoyu, 1.0) + 7.0, 2.0)) * p_renkYayi;
  vec4 acc = vec4(0.0); for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; acc += texU(q + w + vec2(cos(a), sin(a)) * p_lekeBoyu * 0.35); }
  vec4 c = acc / 8.0; if (c.a <= 0.0) { o = c; return; }
  vec3 col = unpre(c); float l = luma(col); col = mix(vec3(l), col, p_pigmentGucu / 100.0 + 0.2);
  float ed = clamp(length(alphaGrad(fromUnit(q + w), 2.0)) * 4.0 + abs(fbm(q / max(p_lekeBoyu * 0.6, 1.0), 2.0)) * 0.3, 0.0, 1.0);
  col *= 1.0 - ed * p_kenarKara / 100.0 * 0.5;
  float paper = 1.0 - (fbm(q * 0.25, 3.0) * 0.5 + 0.5) * p_kagitDoku / 100.0 * 0.35;
  col = mix(vec3(0.97, 0.95, 0.9), col, 0.85) * paper;
  o = pre(clamp(col, 0.0, 1.0), smoothstep(0.1, 0.6, c.a));
}
//== oilpaint
uniform float p_fircaYari, p_darbeUzun, p_stilGucu, p_aydinlatAcis, p_kabartma, p_renkYumu;
void main() {
  vec4 s0 = texture(u_tex, v_uv); if (s0.a <= 0.0) { o = s0; return; }
  float R = max(p_fircaYari * u_s, 1.0); vec2 g = lumGrad(here(), R * 0.5); vec2 dir = length(g) > 1e-5 ? normalize(vec2(-g.y, g.x)) : vec2(1.0, 0.0);
  // Kuwahara benzeri: 4 çeyrekten en düşük varyanslı
  vec3 best = unpre(s0); float bv = 1e9;
  for (int k = 0; k < 4; k++) { vec2 o2 = vec2(k == 0 || k == 3 ? -1.0 : 1.0, k < 2 ? -1.0 : 1.0); vec3 m = vec3(0.0), m2 = vec3(0.0);
    for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) { vec2 d = (vec2(float(i), float(j)) / 2.0) * o2 * R; vec3 c = unpre(texPx(here() + d + dir * float(i - 1) * p_darbeUzun * u_s * 0.15)); m += c; m2 += c * c; }
    m /= 9.0; vec3 v = m2 / 9.0 - m * m; float vv = v.r + v.g + v.b; if (vv < bv) { bv = vv; best = m; } }
  vec3 c = mix(unpre(s0), best, p_stilGucu / 100.0);
  float a = radians(p_aydinlatAcis); float h = dot(lumGrad(here(), 1.5), vec2(cos(a), sin(a))) * 6.0;
  c *= 1.0 + h * p_kabartma / 100.0; c = mix(c, satAdj(c, 1.1), p_renkYumu / 100.0 * 0.5);
  o = pre(clamp(c, 0.0, 1.0), s0.a);
}
//== comic
uniform float p_renkSevi, p_kontur, p_noktaBoyu, p_tramYogu, p_noktalarGost; uniform vec3 c_kenarReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float n = max(2.0, p_renkSevi) - 1.0; vec3 h = rgb2hsv(c); h.z = floor(h.z * n + 0.5) / n; h.y = min(1.0, h.y * 1.2); c = hsv2rgb(h);
  if (p_noktalarGost > 0.5) { float sz = max(p_noktaBoyu * u_s, 2.0); vec2 p = rot2(-45.0) * here(); vec2 f = fract(p / sz) - 0.5; float r = sqrt(1.0 - luma(c)) * 0.5;
    float dt = 1.0 - smoothstep(r - 0.06, r + 0.06, length(f)); c *= 1.0 - dt * p_tramYogu / 100.0 * 0.6; }
  float e = smoothstep(0.15, 0.35, sobel(here(), max(1.0, p_kontur * u_s * 0.5)) * 0.5 + length(alphaGrad(here(), 1.5)) * 1.5);
  o = pre(mix(c, c_kenarReng, e), s.a);
}
//== stipple
uniform float p_noktaBoyu, p_yogunluk, p_boyutCesi, p_renk, p_tohum, p_arkaPlanSayd; uniform vec3 c_noktaReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 B = u_box.zw; float area = B.x * B.y; float cell = max(sqrt(area / max(p_yogunluk, 10.0)), 1.5);
  vec2 px = here() - u_box.xy; vec2 id = floor(px / cell); float ink = 0.0; vec3 col = c_noktaReng;
  for (int i = -1; i <= 1; i++) for (int j = -1; j <= 1; j++) { vec2 cid = id + vec2(float(i), float(j)); vec2 r = hash2(cid + seedf(p_tohum)); vec2 cp = (cid + r) * cell;
    vec4 x = texPx(cp + u_box.xy); float l = x.a > 0.0 ? luma(x.rgb / x.a) : 1.0; if (hash1(cid + 3.3) > (1.0 - l) * 1.25 || x.a < 0.1) continue;
    float rad = p_noktaBoyu * u_s * 0.5 * mix(1.0, 0.4 + (1.0 - l), p_boyutCesi / 100.0);
    float d = length(px - cp); float m = 1.0 - smoothstep(rad - 0.6, rad + 0.6, d); if (m > ink) { ink = m; if (p_renk < 0.5) col = x.rgb / x.a; } }
  if (p_arkaPlanSayd > 0.5) { o = vec4(col, 1.0) * ink; return; }
  o = pre(mix(vec3(0.98, 0.97, 0.94), col, ink), s.a);
}
//== neonsign
uniform float p_tupKali, p_hale, p_yogunluk, p_titreme, p_titremeHizi, p_arkaPlanKara; uniform vec3 c_tupReng;
void main() {
  vec4 s = texture(u_tex, v_uv); float w = max(p_tupKali * u_s, 1.0);
  float ring = clamp(dilateA(here(), w * 0.5) - erodeA(here(), w * 0.5), 0.0, 1.0);
  float glow = clamp(dilateA(here(), w * 0.5 + p_hale * u_s) - erodeA(here(), w * 0.5 + p_hale * u_s), 0.0, 1.0) * 0.0;
  float g = 0.0; for (int i = 0; i < 12; i++) { float a = float(i) * TAU / 12.0; vec2 d = vec2(cos(a), sin(a)) * p_hale * u_s; g += clamp(dilateA(here() + d * 0.5, w * 0.5) - erodeA(here() + d * 0.5, w * 0.5), 0.0, 1.0); }
  g /= 12.0;
  float fl = 1.0 - p_titreme / 100.0 * step(0.75, hash1(vec2(floor(u_t * p_titremeHizi * 8.0), 1.0)));
  vec3 core = mix(c_tupReng, vec3(1.0), 0.55);
  vec3 bg = p_arkaPlanKara > 0.5 ? vec3(0.03, 0.03, 0.06) : unpre(s) * 0.4;
  vec3 c = mix(bg, core, ring) + c_tupReng * g * 1.6 * p_yogunluk / 100.0;
  o = pre(clamp(c * fl, 0.0, 1.0), max(s.a, clamp(ring + g, 0.0, 1.0)));
}
//== hologram
uniform vec3 c_hologramReng; uniform float p_taramaAral, p_cizgiOpak, p_bozulma, p_akisHizi, p_titreme, p_saydamla;
void main() {
  vec2 px = here(); float y = px.y / u_s; float jit = (hash1(vec2(floor(y / 3.0), floor(u_t * 12.0))) - 0.5) * p_bozulma * step(0.85, hash1(vec2(floor(u_t * 6.0), floor(y / 20.0))));
  vec4 s = texPx(px + vec2(jit * u_s, 0.0)); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); vec3 c = c_hologramReng * (0.35 + l * 1.1);
  float scan = step(0.5, fract((y - u_t * p_akisHizi * 20.0) / max(p_taramaAral, 0.5))); c *= 1.0 - scan * p_cizgiOpak / 100.0;
  c += c_hologramReng * 0.6 * clamp(length(alphaGrad(px, 1.5)) * 4.0, 0.0, 1.0);
  float fl = 1.0 - p_titreme / 100.0 * hash1(vec2(floor(u_t * 20.0), 3.0));
  o = pre(clamp(c, 0.0, 1.0), s.a * (1.0 - p_saydamla / 100.0) * fl);
}
//== thresholdrgb
uniform float p_kirmiziEsik, p_yesilEsik, p_maviEsik, p_gecis, p_tersCevi;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 t = vec3(p_kirmiziEsik, p_yesilEsik, p_maviEsik) / 100.0; float w = max(p_gecis / 200.0, 0.002);
  vec3 r = smoothstep(t - w, t + w, c); if (p_tersCevi > 0.5) r = 1.0 - r;
  o = pre(r, s.a);
}
//== scatterpx
uniform float p_sacilmaMesa, p_yogunluk, p_eksen, p_tohum, p_zamanaBagl;
void main() {
  vec2 px = here(); float tk = p_zamanaBagl > 0.5 ? floor(u_t * 24.0) : 0.0;
  vec2 r = hash2(floor(px) + seedf(p_tohum) + tk * 1.7) * 2.0 - 1.0; if (p_eksen > 0.5 && p_eksen < 1.5) r.y = 0.0; if (p_eksen > 1.5) r.x = 0.0;
  float on = step(hash1(floor(px) + 9.1 + tk), p_yogunluk / 100.0);
  o = texPx(px + r * p_sacilmaMesa * u_s * on);
}
//== repetile
uniform float p_solUzat, p_sagUzat, p_ustUzat, p_altUzat, p_doseme, p_birlesimYumu; uniform vec2 p_faz;
void main() {
  vec2 b = boxUV(here()); vec2 B = boxU();
  float l = -p_solUzat / B.x, r = 1.0 + p_sagUzat / B.x, t = -p_ustUzat / B.y, bo = 1.0 + p_altUzat / B.y;
  if (b.x < l || b.x > r || b.y < t || b.y > bo) { o = vec4(0.0); return; }
  b -= p_faz / 100.0;
  float m = p_doseme < 0.5 ? 2.0 : p_doseme < 1.5 ? 1.0 : 3.0;
  vec4 c = texEdge(boxPx(b), m);
  if (p_birlesimYumu > 0.5) { vec2 f = fract(b); float e = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)); vec4 c2 = texEdge(boxPx(b + 0.5), m); c = mix(c2, c, smoothstep(0.0, 0.05, e)); }
  o = c;
}
//== burnfilm
uniform float p_yanmaIler, p_kenarGeni, p_puruz, p_tohum, p_delikAc; uniform vec2 p_merkez; uniform vec3 c_yanikReng, c_isikReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU();
  float d = length((q - p_merkez) / (length(B) * 0.5)); float n = fbm(q / 40.0 + seedf(p_tohum), 4.0) * p_puruz / 100.0;
  float front = p_yanmaIler / 100.0 * 1.6 - d * 0.7 + n; // >0 yanmış
  float w = max(p_kenarGeni, 1.0) / (length(B) * 0.5);
  float hole = smoothstep(0.0, 0.02, front); float glow = exp(-abs(front) / (w * 0.4)); float char_ = smoothstep(-w, 0.0, front);
  vec3 c = unpre(s); c = mix(c, c_yanikReng, char_ * 0.9); c += c_isikReng * glow * 1.2;
  float a = s.a * (p_delikAc > 0.5 ? 1.0 - hole : 1.0);
  o = pre(clamp(c, 0.0, 1.0), a);
}
//== blockload
uniform float p_yuklemeIler, p_blokBoyu, p_sira, p_tohum, p_renkOrta;
void main() {
  vec2 px = here(); float bs0 = max(p_blokBoyu * u_s, 2.0); vec2 b = boxUV(px);
  float order = p_sira < 0.5 ? hash1(floor((px - u_box.xy) / bs0) + seedf(p_tohum)) : p_sira < 1.5 ? b.y : 1.0 - b.y;
  float p = p_yuklemeIler / 100.0;
  float lev = clamp(p * 4.0 - order * 2.0, 0.0, 3.0);
  float bs = lev >= 3.0 ? 1.0 : bs0 / pow(2.0, floor(lev) * 1.5);
  if (lev <= 0.0) { o = vec4(0.0); return; }
  if (bs <= 1.0) { o = texPx(px); return; }
  vec2 c0 = floor((px - u_box.xy) / bs) * bs + u_box.xy; vec4 c = p_renkOrta > 0.5 ? (texPx(c0 + bs * 0.25) + texPx(c0 + bs * 0.75) + texPx(c0 + vec2(bs * 0.25, bs * 0.75)) + texPx(c0 + vec2(bs * 0.75, bs * 0.25))) * 0.25 : texPx(c0 + bs * 0.5);
  o = c;
}
//== chrome
uniform sampler2D s_yansimaKatm; uniform float p_yansimaKatmOn; uniform float p_yansimaAcis, p_metalik, p_puruzlul, p_kontrast; uniform vec3 c_kromTonu;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 g = lumGrad(here(), 2.0) * 8.0 + alphaGrad(here(), 2.0) * 4.0; vec3 n = normalize(vec3(-g, 1.0));
  vec3 r = reflect(vec3(0.0, 0.0, -1.0), n); vec2 env = r.xy * 0.5 + 0.5; env = rot2(p_yansimaAcis) * (env - 0.5) + 0.5;
  vec3 e = p_yansimaKatmOn > 0.5 ? unpre(texture(s_yansimaKatm, clamp(env, 0.0, 1.0))) : vec3(0.5 + 0.5 * sin(env.y * 9.0 + 1.0) * cos(env.x * 3.0)) * mix(vec3(0.4, 0.45, 0.55), vec3(1.0), smoothstep(0.3, 0.7, env.y));
  e = mix(e, vec3(luma(e)), p_puruzlul / 100.0 * 0.6); e = conAdj(e, 1.0 + p_kontrast / 100.0, 0.5);
  vec3 c = mix(unpre(s), e * c_kromTonu * (0.7 + 0.5 * luma(unpre(s))), p_metalik / 100.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== contourgrad
GRADIENT(gecis)
uniform float p_kenarMesa, p_yumusakl, p_tersCevi, p_icDis;
void main() {
  vec4 s = texture(u_tex, v_uv); float R = max(p_kenarMesa * u_s, 1.0);
  float din = innerDist(here(), R) / R, dout = outerDist(here(), R) / R;
  float x; float a;
  if (p_icDis < 0.5) { if (s.a <= 0.0) { o = s; return; } x = din; a = s.a; }
  else if (p_icDis < 1.5) { x = dout; a = s.a > 0.5 ? 0.0 : (1.0 - step(0.999, dout)); }
  else { x = s.a > 0.5 ? din : dout; a = max(s.a, 1.0 - step(0.999, dout)); }
  x = pow(x, mix(2.0, 0.5, p_yumusakl / 100.0)); if (p_tersCevi > 0.5) x = 1.0 - x;
  vec4 g = pre(grad_gecis(x), a);
  o = p_icDis > 0.5 && p_icDis < 1.5 ? overPre(s, g) : g;
}
//== contourlines
uniform float p_cizgiSayi, p_aralik, p_kalinlik, p_faz, p_iceDogr, p_disaDogr; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); float sp = max(p_aralik * u_s, 1.0); float N = max(1.0, floor(p_cizgiSayi)); float R = sp * N + sp;
  float l = 0.0;
  if (p_iceDogr > 0.5 && s.a >= 0.5) { float d = innerDist(here(), R) - p_faz * u_s; float k = d / sp; if (k > 0.3 && k < N + 0.5) l = 1.0 - smoothstep(p_kalinlik * u_s * 0.5 - 0.6, p_kalinlik * u_s * 0.5 + 0.6, abs(fract(k + 0.5) - 0.5) * sp); }
  if (p_disaDogr > 0.5 && s.a < 0.5) { float d = outerDist(here(), R) + p_faz * u_s; float k = d / sp; if (k > 0.3 && k < N + 0.5) l = 1.0 - smoothstep(p_kalinlik * u_s * 0.5 - 0.6, p_kalinlik * u_s * 0.5 + 0.6, abs(fract(k + 0.5) - 0.5) * sp); }
  o = overPre(vec4(c_renk, 1.0) * l, s);
}
//== electricedges
uniform vec3 c_elektrikReng; uniform float p_cizgiKali, p_dalgalan, p_ayrinti, p_hiz, p_hale, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here());
  vec2 jit = vec2(fbm(q / 18.0 + vec2(u_t * p_hiz, seedf(p_tohum)), p_ayrinti - 1.0), fbm(q / 18.0 + vec2(7.0, u_t * p_hiz * 1.3), p_ayrinti - 1.0)) * p_dalgalan;
  vec2 p = fromUnit(q + jit); float w = max(p_cizgiKali * u_s, 1.0);
  float ring = clamp(dilateA(p, w * 0.5) - erodeA(p, w * 0.5), 0.0, 1.0);
  float g = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; g += clamp(dilateA(p + vec2(cos(a), sin(a)) * p_hale * u_s * 0.6, w) - erodeA(p + vec2(cos(a), sin(a)) * p_hale * u_s * 0.6, w), 0.0, 1.0); } g /= 8.0;
  vec4 L = vec4(mix(c_elektrikReng, vec3(1.0), ring * 0.6), 1.0) * clamp(ring + g * 0.8, 0.0, 1.0);
  o = vec4(s.rgb + L.rgb * (1.0 - s.a * 0.5), max(s.a, L.a));
}
//== glowscan_a
uniform float p_altParl, p_ustParl, p_gecis, p_taramaHizi;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = s.a > 0.0 ? s.rgb / s.a : vec3(0.0); float l = luma(c); float sh = fract(u_t * p_taramaHizi * 0.25) * (p_taramaHizi > 0.0 ? 1.0 : 0.0);
  float lo = fract(p_altParl / 100.0 + sh), hi = lo + (p_ustParl - p_altParl) / 100.0; float w = max(p_gecis / 100.0, 0.01);
  float k = smoothstep(lo - w, lo, l) * (1.0 - smoothstep(hi, hi + w, l)); o = vec4(c * k, k) * s.a; }
//== glowscan_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_yogunluk, p_yalnizHale;
void main() { vec4 s = texture(u_src, v_uv); vec4 g = texture(u_aux, v_uv) * p_yogunluk / 100.0 * 2.0; g.rgb *= c_renk;
  if (p_yalnizHale > 0.5) { o = min(g, vec4(1.0)); return; } o = vec4(min(s.rgb + g.rgb * (1.0 - s.rgb * 0.5), vec3(1.0)), max(s.a, min(g.a, 1.0))); }
//== halftonelines
uniform float p_cizgiAral, p_aci, p_enInceKali, p_enKaliKali, p_tersCevi; uniform vec3 c_murekkep, c_kagit;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); if (p_tersCevi > 0.5) l = 1.0 - l;
  float sp = max(p_cizgiAral * u_s, 1.5); vec2 p = rot2(-p_aci) * here(); float d = abs(fract(p.y / sp) - 0.5) * sp;
  float w = mix(p_enKaliKali, p_enInceKali, l) * u_s * 0.5; float ink = 1.0 - smoothstep(w - 0.6, w + 0.6, d);
  o = pre(mix(c_kagit, c_murekkep, ink), s.a);
}
//== smoothedges
uniform float p_yumusatm, p_esik, p_kenarDara, p_ayrintiyKoru, p_yalnizAlfa;
void main() {
  vec4 s = texture(u_tex, v_uv); float R = max(p_yumusatm * u_s, 0.5);
  float a = 0.0; vec4 c = vec4(0.0);
  for (int i = -2; i <= 2; i++) for (int j = -2; j <= 2; j++) { vec4 x = texPx(here() + vec2(float(i), float(j)) * R * 0.5); a += x.a; c += x; }
  a /= 25.0; c /= 25.0;
  float th = clamp(p_esik / 100.0 - p_kenarDara / 500.0, 0.01, 0.99); float na = smoothstep(th - 0.15, th + 0.15, a);
  vec3 col = p_yalnizAlfa > 0.5 || s.a > 0.05 ? (s.a > 0.0 ? s.rgb / s.a : (c.a > 0.0 ? c.rgb / c.a : vec3(0.0))) : (c.a > 0.0 ? c.rgb / c.a : vec3(0.0));
  if (p_yalnizAlfa < 0.5 && c.a > 0.0) col = mix(c.rgb / c.a, col, p_ayrintiyKoru / 100.0);
  o = pre(col, na);
}
