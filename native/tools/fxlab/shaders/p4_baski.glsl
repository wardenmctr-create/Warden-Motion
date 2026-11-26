// 800 rehberi, bölüm 4: sanatsal yüzey ve baskı (626–650)
//== linocut
INCLUDE(_mat)
uniform float p_oyukGeni, p_tonEsig; uniform vec3 c_murekkep;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float L = luma(unpre(s)); vec2 g = lumGrad(here(), 2.0 * u_s); float ang = length(g) > 0.01 ? atan(g.y, g.x) : 0.785;
  vec2 r = rot2(-degrees(ang) - 90.0) * q; float W = max(p_oyukGeni, 0.5); float gouge = abs(fract(r.y / (W * 2.5) + pnoise(q * 0.03) * 0.3) - 0.5) * 2.0;
  float ink = step(L, p_tonEsig / 100.0 + (gouge - 0.5) * 0.35); vec3 paper = matSample(1, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb; ink *= 0.85 + 0.15 * vnoise(q * 0.5);
  o = pre(mix(paper, c_murekkep, ink), s.a); }
//== risograph
uniform float p_plakaSayi, p_tram; uniform vec2 p_plakaKaym; uniform vec3 c_plakaRenk;
void main() { vec4 s = texture(u_tex, v_uv); vec3 inks[4] = vec3[4](c_plakaRenk, vec3(0.13, 0.42, 0.85), vec3(1.0, 0.85, 0.1), vec3(0.1, 0.1, 0.12)); int N = int(clamp(p_plakaSayi, 1.0, 4.0)); vec3 res = vec3(1.0);
  for (int k = 0; k < 4; k++) { if (k >= N) break; vec2 off = p_plakaKaym * float(k) * u_s * 0.5; vec3 c = unpre(texPx(here() - off)); float a = texPx(here() - off).a;
    float amt = k == 0 ? (1.0 - luma(c)) * 0.6 + c.r * 0.4 : k == 1 ? (1.0 - c.r) * 0.8 : k == 2 ? (1.0 - c.b) * c.g : (1.0 - luma(c)) * 0.5; amt *= a;
    vec2 g = rot2(15.0 + float(k) * 30.0) * toUnit(here()) / max(p_tram, 1.0); float dot_ = 1.0 - smoothstep(sqrt(amt) * 0.55 - 0.08, sqrt(amt) * 0.55 + 0.08, length(fract(g) - 0.5));
    res *= mix(vec3(1.0), inks[k], dot_ * (0.85 + 0.15 * vnoise(toUnit(here()) * 0.8 + float(k) * 9.0))); }
  vec3 paper = vec3(0.97, 0.95, 0.9); o = pre(res * paper, s.a); }
//== cyanotype
INCLUDE(_mat)
uniform float p_pozlama, p_maviYogu, p_kagitDoku;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float L = clamp(luma(unpre(s)) * p_pozlama / 100.0, 0.0, 1.0); vec3 prussian = vec3(0.04, 0.18, 0.43); vec3 paper = vec3(0.92, 0.94, 0.95);
  vec3 c = mix(prussian, paper, pow(L, 0.8)); c = mix(paper, c, p_maviYogu / 100.0 + 0.2); c *= mix(vec3(1.0), matSample(1, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.5, 0.0).rgb / max(luma(matBase(1)), 0.1), p_kagitDoku / 100.0); o = pre(clamp(c, 0.0, 1.0), s.a); }
//== chromolitho
uniform float p_renkPlak, p_kenarKaym, p_murekkepOrtu;
void main() { vec4 s = texture(u_tex, v_uv); float k = max(floor(pow(max(p_renkPlak, 2.0), 1.0 / 2.0)), 2.0); vec3 res = vec3(0.98, 0.96, 0.9); float N = max(p_renkPlak, 2.0);
  for (int i = 0; i < 3; i++) { vec2 off = vec2(cos(float(i) * 2.1), sin(float(i) * 2.1)) * p_kenarKaym * u_s; vec3 c = unpre(texPx(here() + off)); float ch = c[i]; float q = floor(ch * N / 3.0 + 0.5) / (N / 3.0);
    vec3 ink = i == 0 ? vec3(0.0, 1.0, 1.0) : i == 1 ? vec3(1.0, 0.0, 1.0) : vec3(1.0, 1.0, 0.0); res *= mix(vec3(1.0), ink, (1.0 - q) * (0.7 + p_murekkepOrtu / 300.0) * texPx(here() + off).a); }
  o = pre(clamp(res, 0.0, 1.0), s.a); }
//== drypastel
INCLUDE(_mat)
uniform float p_pastelCapi, p_basinc, p_kagitDisi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 g = lumGrad(here(), 2.0 * u_s); float ang = length(g) > 0.01 ? degrees(atan(g.y, g.x)) + 90.0 : 30.0; vec2 r = rot2(-ang) * q;
  vec2 cell = floor(r / vec2(p_pastelCapi * 2.5, p_pastelCapi * 0.6)); vec3 col = unpre(texU(rot2(ang) * ((cell + 0.5) * vec2(p_pastelCapi * 2.5, p_pastelCapi * 0.6))));
  float tooth = fbm01(q * 0.35, 3.0); float cov = smoothstep(1.0 - p_basinc / 100.0, 1.0 - p_basinc / 100.0 + 0.25, tooth * (1.0 - p_kagitDisi / 200.0) + vnoise(r * vec2(0.08, 1.2)) * 0.5);
  vec3 paper = vec3(0.93, 0.9, 0.84); o = pre(mix(paper, col, cov), s.a); }
//== waxcrayon
uniform float p_darbeCapi, p_bosluk, p_basinc;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 r = rot2(-35.0) * q; float W = max(p_darbeCapi, 1.0); float row = floor(r.y / W); vec2 sp = rot2(35.0) * vec2(floor(r.x / (W * 3.0)) * W * 3.0 + W * 1.5, row * W + W * 0.5);
  vec3 col = unpre(texU(sp)); float grain = vnoise(q * vec2(0.9, 0.25) * 2.0) * 0.6 + vnoise(q * 1.7) * 0.4; float wax = step(p_bosluk / 100.0 * 0.8, grain) * (0.75 + 0.25 * p_basinc / 100.0);
  vec3 paper = vec3(0.97, 0.96, 0.92); vec3 c = mix(paper, col * (0.9 + 0.2 * vnoise(r * vec2(0.05, 1.0))), wax); o = pre(c, s.a); }
//== inkwash
uniform float p_yayilma, p_kenarPigm, p_kuruma;
void main() { vec4 s = texture(u_tex, v_uv); float R = max(p_yayilma, 0.5) * u_s; vec4 acc = vec4(0.0); for (int i = 0; i < 16; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 16.0); vec2 w = vec2(pnoise(toUnit(here()) * 0.05 + float(i)), pnoise(toUnit(here()) * 0.05 + 7.0)) * R * 0.3; acc += texPx(here() + vec2(cos(a), sin(a)) * r + w); } acc /= 16.0;
  float e = clamp(length(alphaGrad(here(), R * 0.5)) * 3.0 + sobel(here(), R * 0.3) * 2.0, 0.0, 1.0); vec3 c = acc.a > 0.0 ? acc.rgb / acc.a : vec3(1.0); c = mix(vec3(1.0), c, 0.6 + 0.4 * (1.0 - p_kuruma / 200.0)); c *= 1.0 - e * p_kenarPigm / 100.0 * 0.6;
  o = pre(clamp(c, 0.0, 1.0), max(s.a, acc.a * (1.0 - p_kuruma / 100.0 * 0.5))); }
//== paintdrip
uniform float p_akisHizi, p_viskozit, p_damlaYogu;
void main() { vec2 q = toUnit(here()); float colW = max(4.0, 12.0 * (1.0 - p_viskozit / 200.0)); float cx = floor(q.x / colW); float h = hash1(vec2(cx, 7.0)); vec4 s = texture(u_tex, v_uv);
  float len = (h < p_damlaYogu / 100.0) ? min(u_t * p_akisHizi * (0.5 + h), boxU().y) * (1.0 - p_viskozit / 150.0) : 0.0; vec4 best = s;
  for (int i = 1; i <= 16; i++) { float d = len * float(i) / 16.0; vec4 up = texU(vec2(q.x, q.y - d)); float wcol = 1.0 - smoothstep(colW * 0.25, colW * 0.45, abs(fract(q.x / colW) - 0.5) * colW * (1.0 + float(i) / 16.0));
    if (up.a > 0.5 && best.a < 0.5) best = up * wcol; } o = best; }
//== marbling
uniform float p_renkSayi, p_taramaAral, p_akisGucu; uniform vec3 c_boyaPale;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float N = max(floor(p_renkSayi), 2.0); vec2 p = q;
  for (int i = 0; i < 3; i++) { p.x += sin(p.y / max(p_taramaAral, 1.0) * 3.0 + float(i)) * p_akisGucu * 0.3; p.y += sin(p.x / max(p_taramaAral, 1.0) * 2.0 + float(i) * 1.7) * p_akisGucu * 0.2; }
  p += vec2(fbm(q * 0.01, 3.0), fbm(q * 0.01 + 5.0, 3.0)) * p_akisGucu; float band = fract(p.y / (p_taramaAral * 1.5)); float id = floor(band * N);
  vec3 c = hsv2rgb(vec3(fract(rgb2hsv(c_boyaPale).x + id / N * 0.6), 0.65, 0.5 + 0.5 * hash1(vec2(id, 2.0)))); c = mix(c, c_boyaPale, step(0.5, mod(id, 2.0)) * 0.6); o = pre(c, s.a); }
//== batik
uniform float p_baglamaNokt, p_yayilim; uniform vec3 c_renkler;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = int(clamp(p_baglamaNokt, 1.0, 24.0)); float best = 1e9; for (int i = 0; i < 24; i++) { if (i >= N) break; vec2 c = (hash2(vec2(float(i), 3.3)) - 0.5) * boxU(); best = min(best, length(q - c)); }
  float d = best / max(p_yayilim / 100.0 * length(boxU()) * 0.3, 1.0); float rings = 0.5 + 0.5 * sin(d * 18.0 + fbm(q * 0.02, 3.0) * 4.0); float crack = smoothstep(0.92, 1.0, abs(pnoise(q * 0.06)) * 3.0);
  vec3 c = mix(vec3(0.96, 0.92, 0.84), c_renkler, smoothstep(0.3, 0.7, rings) * (1.0 - smoothstep(1.2, 2.2, d) * 0.5)); c = mix(c, c_renkler * 0.5, crack * 0.6); o = pre(c * mix(vec3(1.0), unpre(s), 0.3), s.a); }
//== applique
INCLUDE(_mat)
uniform float p_renkBolg, p_kenarDiki, p_parcaOrtu, p_kumasMalz, p_dokuGucu;
void main() { vec4 s = texture(u_tex, v_uv); float k = max(pow(p_renkBolg, 1.0 / 3.0), 1.5); vec3 c = floor(unpre(s) * k + 0.5) / k; vec3 c2 = floor(unpre(texPx(here() + vec2(1.5 * u_s, 0.0))) * k + 0.5) / k; vec3 c3 = floor(unpre(texPx(here() + vec2(0.0, 1.5 * u_s))) * k + 0.5) / k;
  float edge = step(0.01, length(c - c2) + length(c - c3)); int m = p_kumasMalz < 0.5 ? 10 : 11; vec2 q = toUnit(here()); vec3 fab = matSample(m, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb / max(luma(matBase(m)), 0.1);
  if (p_kumasMalz > 2.5 && p_kumasMalz < 3.5) fab *= vec3(0.8, 0.85, 1.05) * (0.9 + 0.2 * step(0.5, fract((q.x + q.y) * 0.5)));
  vec3 r = mix(c, c * fab, p_dokuGucu / 100.0); float stitch = edge > 0.0 ? 0.0 : step(0.5, fract(q.x / 3.0 + q.y / 3.0)) * (1.0 - smoothstep(p_kenarDiki * u_s * 0.5, p_kenarDiki * u_s, innerDist(here(), (p_kenarDiki + 2.0) * u_s))) * step(0.01, p_kenarDiki);
  r = mix(r, r * 0.55, edge * 0.8); r = mix(r, vec3(0.95), stitch * 0.7); o = pre(clamp(r, 0.0, 1.0), max(s.a, dilateA(here(), p_parcaOrtu * u_s) * 0.0 + s.a)); }
//== stainedglass
uniform float p_parcaSayi, p_kursunCizg, p_camGeci; uniform vec3 c_birlestiCizgReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = sqrt(boxU().x * boxU().y / max(p_parcaSayi, 4.0)); vec4 v = voronoi(q / cs); vec2 ctr = q - (vec2(0.0)); 
  vec2 g = floor(q / cs); vec2 best = vec2(0.0); float bd = 1e9; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = g + vec2(i, j); vec2 p = (id + hash2(id)) * cs; float d = length(q - p); if (d < bd) { bd = d; best = p; } }
  vec3 c = unpre(texU(best)); c = satAdj(c, 1.4) * (0.85 + 0.3 * p_camGeci / 100.0 * (1.0 - bd / cs)); float lead = 1.0 - smoothstep(p_kursunCizg / cs * 0.04, p_kursunCizg / cs * 0.04 + 0.02, v.y - v.x);
  o = pre(mix(clamp(c, 0.0, 1.0), c_birlestiCizgReng, lead), s.a); }
//== ceramicglaze
uniform float p_sirAkis, p_catlakYogu, p_parlakli;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 fl = vec2(0.0, fbm(q * 0.02, 3.0) * p_sirAkis * 0.3); vec3 c = unpre(texU(q - fl)); vec4 v = voronoi(q / max(30.0 - p_catlakYogu * 0.25, 4.0));
  float crack = (1.0 - smoothstep(0.0, 0.05, v.y - v.x)) * p_catlakYogu / 100.0; c = mix(c, c * 0.55, crack); float h = fbm01(q * 0.04, 3.0); vec3 n = normalize(vec3(dFdx(h) * -20.0, dFdy(h) * -20.0, 1.0));
  float sp = pow(max(dot(reflect(normalize(vec3(-0.5, -0.5, -1.0)), n), vec3(0.0, 0.0, 1.0)), 0.0), 30.0) * p_parlakli / 100.0; o = pre(clamp(c * 1.05 + sp, 0.0, 1.0), s.a); }
//== mosaicgrout
uniform float p_tasBoyu, p_derzDeri, p_isikYonu;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float T = max(p_tasBoyu, 2.0); vec2 g = q / T; g += vec2(pnoise(g * 0.7), pnoise(g * 0.7 + 3.0)) * 0.15; vec2 id = floor(g); vec2 f = fract(g) - 0.5;
  vec3 c = unpre(texU((id + 0.5) * T)); float dEdge = 0.5 - max(abs(f.x), abs(f.y)); float grout = 1.0 - smoothstep(p_derzDeri / T * 0.05, p_derzDeri / T * 0.05 + 0.03, dEdge);
  vec2 L = vec2(cos(radians(p_isikYonu)), sin(radians(p_isikYonu))); float sh = dot(normalize(f + 1e-4), L) * smoothstep(0.15, 0.0, dEdge) * 0.25; c = mix(c * (1.0 + sh), vec3(0.75, 0.73, 0.7) * (0.8 - 0.2 * dot(L, vec2(0.0, 1.0))), grout); o = pre(clamp(c, 0.0, 1.0), s.a); }
//== sequins
uniform float p_pulCapi, p_yonRast, p_parlakli;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float D = max(p_pulCapi, 1.0); vec2 g = q / D; g.x += mod(floor(g.y), 2.0) * 0.5; vec2 id = floor(g); vec2 f = fract(g) - 0.5; float r = length(f);
  vec3 c = unpre(texU((id + 0.5) * D)); vec2 tilt = (hash2(id) - 0.5) * p_yonRast / 50.0; float spec = pow(max(0.0, 1.0 - length(tilt + vec2(sin(u_t * 1.5 + id.x), cos(u_t + id.y)) * 0.3)), 6.0) * p_parlakli / 100.0;
  float m = 1.0 - smoothstep(0.45, 0.5, r); float hole = smoothstep(0.06, 0.1, r); vec3 col = c * (0.7 + 0.4 * (1.0 - r)) + spec; o = pre(clamp(mix(c * 0.4, col, m * hole), 0.0, 1.0), s.a); }
//== beadwork
uniform float p_boncukCapi, p_aralik, p_isikGucu;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float P = max(p_boncukCapi + p_aralik, 1.0); vec2 id = floor(q / P); vec2 f = (fract(q / P) - 0.5) * P; float R = p_boncukCapi * 0.5;
  vec4 src = texU((id + 0.5) * P); float d = length(f); if (d > R || src.a < 0.3) { o = vec4(0.0); return; } vec3 n = vec3(f / R, sqrt(max(0.0, 1.0 - dot(f, f) / (R * R))));
  vec3 c = unpre(src); float lit = 0.6 + 0.5 * max(dot(n, normalize(vec3(-0.5, -0.6, 0.7))), 0.0); float sp = pow(max(dot(n, normalize(vec3(-0.3, -0.4, 1.0))), 0.0), 40.0) * p_isikGucu / 100.0; o = pre(clamp(c * lit + sp, 0.0, 1.0), src.a); }
//== knitting
uniform float p_ilmekBoyu, p_ipKali, p_orguTipi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float S = max(p_ilmekBoyu, 2.0); vec2 g = q / vec2(S, S * 0.8); vec2 id = floor(g); vec2 f = fract(g);
  vec3 c = unpre(texU((id + 0.5) * vec2(S, S * 0.8))); bool purl = p_orguTipi > 0.5 && p_orguTipi < 1.5 || (p_orguTipi > 1.5 && p_orguTipi < 2.5 && mod(id.x, 2.0) > 0.5);
  float side = f.x < 0.5 ? 1.0 : -1.0; vec2 lf = vec2(abs(f.x - 0.5) * 2.0, f.y); if (p_orguTipi > 2.5) lf.x = abs(fract(f.x + f.y * 0.5) - 0.5) * 2.0;
  float v = purl ? abs(sin(f.y * PI * 2.0)) : 1.0 - abs(lf.x - (1.0 - lf.y) * 0.6 - 0.2) / max(p_ipKali / S * 1.5, 0.05); v = clamp(v, 0.0, 1.0);
  float fiber = 0.85 + 0.15 * sin((f.x + f.y) * 40.0); o = pre(c * (0.45 + 0.55 * v) * fiber, s.a); }
//== papiermache
uniform float p_hamurYuks, p_lifBoyu, p_kenarYumu, p_yuzeyPuru;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float h = fbm01(q / max(p_lifBoyu * 4.0, 2.0), 4.0) * p_yuzeyPuru / 100.0 + smoothstep(0.0, p_kenarYumu * 0.3 * u_s + u_s, innerDist(here(), 30.0 * u_s)) * p_hamurYuks / 10.0;
  vec3 n = normalize(vec3(-dFdx(h) * 6.0, -dFdy(h) * 6.0, 1.0)); float lit = 0.55 + 0.6 * max(dot(n, normalize(vec3(-0.5, -0.5, 0.8))), 0.0); vec3 c = unpre(s) * lit * (0.92 + 0.08 * vnoise(q * 2.0)); o = pre(clamp(c, 0.0, 1.0), s.a); }
//== waxseal
uniform float p_kenarTasm, p_izDeri; uniform vec3 c_mumReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = (p_kenarTasm + 2.0) * u_s; float body = smoothstep(0.3, 0.6, dilateA(here(), R * (0.7 + 0.3 * fbm01(q * 0.05, 3.0))));
  float hgt = body * 0.5 - s.a * p_izDeri / 50.0 * 0.5; vec3 n = normalize(vec3(-dFdx(hgt) * 30.0, -dFdy(hgt) * 30.0, 1.0)); float lit = 0.5 + 0.7 * max(dot(n, normalize(vec3(-0.4, -0.6, 0.7))), 0.0);
  float sp = pow(max(dot(reflect(normalize(vec3(0.4, 0.6, -0.7)), n), vec3(0.0, 0.0, 1.0)), 0.0), 20.0) * 0.5; o = vec4(clamp(c_mumReng * lit + sp, 0.0, 1.0), 1.0) * body; }
//== sandcarve
uniform sampler2D s_yol; uniform float p_yolOn, p_kaziDeri, p_kumTane;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float path = p_yolOn > 0.5 ? texture(s_yol, clamp(boxUV(here()), 0.0, 1.0)).a : s.a; float r = 3.0 * u_s;
  float around = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; around += p_yolOn > 0.5 ? texture(s_yol, clamp(boxUV(here() + vec2(cos(a), sin(a)) * r), 0.0, 1.0)).a : texPx(here() + vec2(cos(a), sin(a)) * r).a; } around /= 8.0;
  float ridge = clamp(around - path, 0.0, 1.0) * 1.5; float grain = vnoise(q / max(p_kumTane, 0.5)) * 0.15; vec3 sand = vec3(0.86, 0.75, 0.55) * (0.9 + grain);
  vec3 c = sand * (1.0 - path * p_kaziDeri / 50.0 * 0.5) * (1.0 + ridge * 0.25); o = vec4(clamp(c, 0.0, 1.0), 1.0); }
//== lenticular
uniform sampler2D s_goruntul; uniform float p_goruntulOn, p_bakisAcis, p_seritSikl;
void main() { vec4 s = texture(u_tex, v_uv); vec4 b = p_goruntulOn > 0.5 ? texture(s_goruntul, clamp(boxUV(here()), 0.0, 1.0)) : vec4(vec3(1.0) - s.rgb, s.a); float stripe = fract(toUnit(here()).x / max(p_seritSikl, 1.0));
  float k = smoothstep(-15.0, 15.0, p_bakisAcis + (stripe - 0.5) * 20.0); vec4 c = mix(s, b, k); c.rgb *= 0.9 + 0.1 * sin(stripe * TAU); o = c; }
//== moireprint
uniform float p_tramFrek, p_aciFark, p_kontrast;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) * p_tramFrek; float a = sin(q.x * TAU) * 0.5 + 0.5; vec2 r = rot2(p_aciFark) * q; float b = sin(r.x * TAU * 1.03) * 0.5 + 0.5;
  float m = a * b; vec3 c = unpre(s); vec3 r3 = c * mix(1.0, 0.5 + m, p_kontrast / 100.0); o = pre(clamp(r3, 0.0, 1.0), s.a); }
//== linedensity
uniform float p_cizgiSayi, p_tonEtki, p_kivrim;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float L = luma(unpre(s)); float y = b.y * p_cizgiSayi + sin(b.x * 6.0 + b.y * 4.0) * p_kivrim / 100.0 * 2.0;
  float w = mix(0.5, (1.0 - L) * 0.9, p_tonEtki / 100.0); float line = 1.0 - smoothstep(w * 0.5 - 0.05, w * 0.5 + 0.05, abs(fract(y) - 0.5)); o = pre(vec3(1.0 - line), s.a); }
//== chipcollage
uniform float p_parcaBoyu, p_bosluk, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float P = max(p_parcaBoyu, 1.0); vec4 v = voronoi(q / P + seedf(p_tohum)); vec2 g = floor(q / P); vec2 best = q; float bd = 1e9;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = g + vec2(i, j); vec2 p = (id + hash2(id + seedf(p_tohum))) * P; float d = length(q - p); if (d < bd) { bd = d; best = p; } }
  vec4 c = texU(best); float gap = smoothstep(p_bosluk / P * 0.1, p_bosluk / P * 0.1 + 0.02, v.y - v.x); vec3 col = (c.a > 0.0 ? c.rgb / c.a : vec3(0.0)) * (0.9 + 0.2 * hash1(floor(best))); o = pre(col, c.a * gap * step(0.3, s.a + c.a)); }
//== shadowtheater
uniform vec2 p_isik; uniform float p_perdeUzak, p_golgeYumu; uniform vec3 c_perdeReng, c_golgeReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float k = 1.0 + p_perdeUzak / 400.0; vec2 sq = (q - p_isik) / k + p_isik; float a = 0.0; float R = p_golgeYumu * u_s * (0.3 + p_perdeUzak / 500.0);
  for (int i = 0; i < 12; i++) { float an = float(i) * 0.5236; a += texU(sq + vec2(cos(an), sin(an)) * R / u_s * fract(float(i) * 0.618 + 0.3)).a; } a /= 12.0;
  float glow = 1.0 - length(boxUV(here()) - 0.5) * 0.9; vec3 c = mix(c_perdeReng * (0.7 + 0.4 * glow), c_golgeReng, a); o = vec4(c, 1.0); }
