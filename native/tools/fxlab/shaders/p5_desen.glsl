// 800 rehberi, bölüm 5: prosedürel çizim ve arka plan (651–675)
//== spirograph
uniform float p_icDisYari, p_kalemUzak, p_cizimIler, p_cizgiKali; uniform vec3 c_cizgiReng;
vec2 spi(float t) { float R = min(boxU().x, boxU().y) * 0.45; float r = R * clamp(p_icDisYari / 1000.0 * 0.9, 0.05, 0.95); float d = r * p_kalemUzak / 100.0 * 2.0; return vec2((R - r) * cos(t) + d * cos((R - r) / r * t), (R - r) * sin(t) - d * sin((R - r) / r * t)); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float best = 1e9; float T = 20.0 * TAU * p_cizimIler / 100.0; vec2 prev = spi(0.0);
  for (int i = 1; i <= 600; i++) { float t = T * float(i) / 600.0; vec2 p = spi(t); vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); best = min(best, length(q - prev - ab * u)); prev = p; }
  o = overPre(vec4(c_cizgiReng, 1.0) * (1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali * 0.5 + 0.8 / u_s, best)), s); }
//== lissajous
uniform vec2 p_frekansl; uniform float p_faz, p_cizgiKali;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 A = boxU() * 0.45; float best = 1e9; vec2 prev = vec2(sin(radians(p_faz)), 0.0) * A;
  for (int i = 1; i <= 400; i++) { float t = TAU * float(i) / 400.0; vec2 p = vec2(sin(p_frekansl.x * t + radians(p_faz) + u_t * 0.3), sin(p_frekansl.y * t)) * A; vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); best = min(best, length(q - prev - ab * u)); prev = p; }
  o = overPre(vec4(0.2, 0.6, 1.0, 1.0) * (1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali * 0.5 + 0.8 / u_s, best)), s); }
//== cycloid
uniform float p_yaricap, p_noktaUzak, p_donusSayi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float r = max(p_yaricap, 1.0); float d = p_noktaUzak; float T = p_donusSayi * TAU; float W = r * T; vec2 off = vec2(-W * 0.5, boxU().y * 0.25); float best = 1e9; vec2 prev = off + vec2(0.0, -(r - d));
  for (int i = 1; i <= 500; i++) { float t = T * float(i) / 500.0; vec2 p = off + vec2(r * t - d * sin(t), -(r - d * cos(t))); vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); best = min(best, length(q - prev - ab * u)); prev = p; }
  float ground = 1.0 - smoothstep(0.5, 1.5, abs(q.y - off.y)); o = overPre(vec4(1.0, 0.6, 0.2, 1.0) * max(1.0 - smoothstep(1.0, 2.0, best), ground * 0.4), s); }
//== complexmap
uniform float p_fonksiyo, p_olcek, p_renkCevr;
vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 z = toUnit(here()) / max(p_olcek, 1.0) * 2.0; vec2 w;
  if (p_fonksiyo < 0.5) w = cmul(z, z); else if (p_fonksiyo < 1.5) w = vec2(z.x, -z.y) / max(dot(z, z), 1e-6); else if (p_fonksiyo < 2.5) w = vec2(sin(z.x) * cosh(z.y), cos(z.x) * sinh(z.y)); else w = exp(z.x) * vec2(cos(z.y), sin(z.y));
  float hue = fract(atan(w.y, w.x) / TAU + p_renkCevr / 360.0); float m = log(length(w) + 1e-6); float rings = 0.75 + 0.25 * fract(m); vec3 c = hsv2rgb(vec3(hue, 0.85, rings));
  vec2 g = fract(w) ; c *= 0.85 + 0.15 * smoothstep(0.0, 0.05, min(g.x, g.y)); o = pre(c, s.a); }
//== apollonian
uniform float p_derinlik, p_enKucuCap; uniform vec3 c_palet;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) / (min(boxU().x, boxU().y) * 0.48); float scale = 1.0; float best = 1e9; int D = int(clamp(p_derinlik, 1.0, 10.0)); float lvl = 0.0;
  vec2 p = q; for (int i = 0; i < 10; i++) { if (i >= D) break; p = -1.0 + 2.0 * fract(0.5 * p + 0.5); float r2 = dot(p, p); float k = 1.2 / max(r2, 1e-4); p *= k; scale *= k; lvl += 1.0; }
  float d = 0.25 * abs(p.y) / scale; float line = 1.0 - smoothstep(0.0, 0.004 * max(p_enKucuCap / 3.0, 0.3), d); float inside = step(length(q), 1.0);
  vec3 c = mix(c_palet, vec3(1.0), line) * (0.7 + 0.3 * fract(log(scale) * 0.3)); o = pre(c, s.a * inside); }
//== penrose
uniform float p_yineleme, p_karoOlce, p_karoAile; uniform vec3 c_palet;
// de Bruijn ızgara yöntemi: 5 yönlü kayık ızgaralar; komşu tam sayı katmanları karo türünü belirler
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) / max(p_karoOlce, 10.0) * 4.0; float k[5]; float sum = 0.0; float edge = 1e9;
  for (int i = 0; i < 5; i++) { float a = float(i) * TAU / 5.0; float v = dot(q, vec2(cos(a), sin(a))) + 0.2 + p_yineleme * 0.01; k[i] = floor(v); sum += k[i]; edge = min(edge, abs(fract(v) - 0.5)); }
  float t = mod(sum, 5.0); float thin = p_karoAile < 0.5 ? step(2.5, t) : step(1.5, mod(sum + k[0], 3.0)); vec3 c = mix(c_palet, mix(c_palet, vec3(1.0), 0.6), thin) * (0.85 + 0.15 * fract(sum * 0.37));
  c = mix(c, vec3(0.05), 1.0 - smoothstep(0.43, 0.47, edge)); o = pre(c, s.a); }
//== wangtiles
uniform float p_karoTuru, p_boyut, p_tohum;
float edgeCol(vec2 e) { return floor(hash1(e + seedf(p_tohum)) * 2.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) / max(p_boyut, 2.0); vec2 id = floor(q); vec2 f = fract(q) - 0.5;
  float n = edgeCol(vec2(id.x, id.y + 0.5) * 3.1), so = edgeCol(vec2(id.x, id.y - 0.5) * 3.1), e = edgeCol(vec2(id.x + 0.5, id.y) * 7.3), w = edgeCol(vec2(id.x - 0.5, id.y) * 7.3);
  float v = 0.0; v += n * smoothstep(0.35, 0.0, length(f - vec2(0.0, 0.5))); v += so * smoothstep(0.35, 0.0, length(f + vec2(0.0, 0.5))); v += e * smoothstep(0.35, 0.0, length(f - vec2(0.5, 0.0))); v += w * smoothstep(0.35, 0.0, length(f + vec2(0.5, 0.0)));
  float lines = step(0.5, fract(v * max(p_karoTuru, 2.0) * 0.25)); vec3 c = mix(vec3(0.08, 0.12, 0.25), vec3(0.3, 0.7, 1.0), clamp(v, 0.0, 1.0)); c = mix(c, c * 0.7, lines * 0.4); o = pre(c, s.a); }
//== powervoronoi
uniform float p_merkez, p_agirlikDagi, p_sinir;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = sqrt(boxU().x * boxU().y / max(p_merkez, 2.0)); vec2 g = floor(q / cs); float b1 = 1e9, b2 = 1e9; vec2 bid = vec2(0.0);
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 id = g + vec2(i, j); vec2 p = (id + hash2(id)) * cs; float wgt = (hash1(id + 5.0) - 0.5) * p_agirlikDagi / 100.0 * cs * cs; float d = dot(q - p, q - p) - wgt;
    if (d < b1) { b2 = b1; b1 = d; bid = id; } else if (d < b2) b2 = d; }
  float edge = 1.0 - smoothstep(p_sinir * cs * 0.5, p_sinir * cs * 0.5 + cs * 0.4, b2 - b1); vec3 c = unpre(texU((bid + 0.5) * cs)) * 0.9 + hsv2rgb(vec3(hash1(bid), 0.4, 0.5)) * 0.1; o = pre(mix(c, vec3(0.05), edge * step(0.01, p_sinir)), s.a); }
//== delaunay
uniform float p_nokta, p_baglantiKali, p_hareket;
vec2 pt(vec2 id, float cs) { vec2 h = hash2(id); if (p_hareket > 0.5) h = 0.5 + 0.4 * vec2(sin(u_t + h.x * 6.28), cos(u_t * 0.8 + h.y * 6.28)); return (id + h) * cs; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = sqrt(boxU().x * boxU().y / max(p_nokta, 3.0)); vec2 g = floor(q / cs); float best = 1e9;
  vec2 P[9]; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) P[(j + 1) * 3 + i + 1] = pt(g + vec2(i, j), cs);
  for (int a = 0; a < 9; a++) for (int b = a + 1; b < 9; b++) { vec2 A = P[a], B = P[b]; if (length(A - B) > cs * 1.6) continue; vec2 m = (A + B) * 0.5; vec2 ab = B - A; float u = clamp(dot(q - A, ab) / dot(ab, ab), 0.0, 1.0); best = min(best, length(q - A - ab * u)); }
  float l = 1.0 - smoothstep(p_baglantiKali * 0.5, p_baglantiKali * 0.5 + 0.8 / u_s, best); float dots = 0.0; for (int i = 0; i < 9; i++) dots = max(dots, 1.0 - smoothstep(2.0, 3.0, length(q - P[i]))); o = overPre(vec4(0.4, 0.8, 1.0, 1.0) * max(l, dots), s); }
//== poissondots
uniform float p_enAzUzak, p_azamiNokt, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = max(p_enAzUzak, 1.0) * 0.7071; vec2 g = floor(q / cs); float m = 0.0; float dens = clamp(p_azamiNokt * cs * cs / max(boxU().x * boxU().y, 1.0), 0.0, 1.0);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = g + vec2(i, j); vec2 p = (id + 0.15 + 0.7 * hash2(id + seedf(p_tohum))) * cs; if (hash1(id + 9.0 + seedf(p_tohum)) > dens) continue; m = max(m, 1.0 - smoothstep(cs * 0.12, cs * 0.18, length(q - p))); }
  o = overPre(vec4(1.0) * m, s); }
//== crescents
uniform float p_cap, p_kesisimOran, p_aci;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()); float D = max(p_cap, 2.0); vec2 g = q / D; g.x += mod(floor(g.y), 2.0) * 0.5; vec2 f = fract(g) - 0.5; float r = 0.42;
  float a = 1.0 - smoothstep(r - 0.01, r + 0.01, length(f)); float b = 1.0 - smoothstep(r - 0.01, r + 0.01, length(f - vec2(r * (1.0 - p_kesisimOran / 100.0) * 1.2, 0.0))); float cr = a * (1.0 - b);
  o = pre(mix(vec3(0.07, 0.1, 0.22), vec3(0.95, 0.8, 0.3), cr), s.a); }
//== illusiongrid
uniform float p_frekans, p_kayma, p_kontrast;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) * p_frekans; float row = floor(q.y); float x = q.x + mod(row, 2.0) * p_kayma / 100.0 + sin(row * 0.5) * p_kayma / 200.0; float sq = step(0.5, fract(x * 0.5));
  float mortar = 1.0 - smoothstep(0.03, 0.06, abs(fract(q.y) - 0.0)); vec3 c = mix(vec3(0.5 - p_kontrast / 140.0), vec3(0.5 + p_kontrast / 140.0), sq); c = mix(c, vec3(0.5), mortar); o = pre(c, s.a); }
//== ribbonflow
uniform float p_serit, p_akis; uniform vec3 c_palet;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float N = max(floor(p_serit), 2.0); float y = b.y + sin(b.x * 6.0 + u_t * p_akis / 30.0) * 0.05 * p_akis / 30.0 + sin(b.x * 2.0 + b.y * 3.0) * 0.08;
  float id = floor(y * N); float f = fract(y * N); vec3 c = hsv2rgb(vec3(fract(rgb2hsv(c_palet).x + id / N * 0.5), 0.6, 0.55 + 0.4 * hash1(vec2(id, 1.0)))); c *= 0.8 + 0.2 * sin(f * PI); o = pre(c, s.a); }
//== turingmaze
uniform sampler2D s_anl; uniform float p_anlOn, p_dalKali;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } float g = texture(s_anl, fract(boxUV(here()) * max(1.0, 3.0 / max(p_dalKali, 0.5)))).r; o = pre(mix(vec3(0.06, 0.08, 0.16), vec3(0.95, 0.9, 0.8), smoothstep(0.35, 0.6, g)), s.a); }
//== cellauto
uniform sampler2D s_anl; uniform float p_anlOn;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } ivec2 n = textureSize(s_anl, 0); vec2 uv = (floor(boxUV(here()) * vec2(n)) + 0.5) / vec2(n); float g = texture(s_anl, uv).r;
  vec2 f = fract(boxUV(here()) * vec2(n)); float cell = g * step(0.06, min(f.x, f.y)); o = pre(mix(vec3(0.04, 0.06, 0.12), vec3(0.3, 0.9, 0.6), cell), s.a); }
//== selfavoid
uniform sampler2D s_anl; uniform float p_anlOn;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } float g = texture(s_anl, clamp(boxUV(here()), 0.0, 1.0)).r; o = overPre(vec4(1.0, 0.75, 0.3, 1.0) * smoothstep(0.1, 0.5, g), s); }
//== dla
uniform sampler2D s_anl; uniform float p_anlOn;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } float g = texture(s_anl, clamp(boxUV(here()), 0.0, 1.0)).r; o = overPre(vec4(hsv2rgb(vec3(0.55 + g * 0.3, 0.6, 1.0)), 1.0) * smoothstep(0.05, 0.3, g), s); }
//== reactdiff
uniform sampler2D s_anl; uniform float p_anlOn, p_olcek; uniform vec3 c_birinciRenk, c_ikinciRenk;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } float g = texture(s_anl, fract(boxUV(here()) * max(p_olcek / 100.0, 0.1))).r; o = pre(mix(c_birinciRenk, c_ikinciRenk, smoothstep(0.2, 0.7, g)), s.a); }
//== rootnet
uniform float p_hedef, p_dalEgim, p_buyume;
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); int N = int(clamp(p_hedef, 1.0, 40.0)); float best = 1e9; float grow = p_buyume / 100.0;
  for (int i = 0; i < 40; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), 2.0)); vec2 a = vec2((h.x - 0.5) * B.x * 0.3, -B.y * 0.5); vec2 tgt = vec2((h.y - 0.5) * B.x, B.y * (0.0 + 0.45 * hash1(vec2(float(i), 5.0))));
    vec2 prev = a; for (int k = 1; k <= 8; k++) { float t = float(k) / 8.0; if (t > grow) break; vec2 p = mix(a, tgt, t) + vec2(sin(t * 6.0 + float(i)) * p_dalEgim * 0.4, 0.0) * (1.0 - t); best = min(best, seg(q, prev, p) / (1.5 - t)); prev = p; } }
  o = overPre(vec4(0.55, 0.38, 0.22, 1.0) * (1.0 - smoothstep(1.0, 2.0, best)), s); }
//== mossgrow
uniform sampler2D s_yuzeyMask; uniform float p_yuzeyMaskOn, p_koloniYogu, p_buyume; uniform vec3 c_palet;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float m = p_yuzeyMaskOn > 0.5 ? texture(s_yuzeyMask, clamp(boxUV(here()), 0.0, 1.0)).a : s.a; float f = fbm01(q * 0.02, 5.0) + fbm01(q * 0.15, 3.0) * 0.3;
  float cov = smoothstep(1.2 - p_koloniYogu / 100.0 * p_buyume / 100.0 * 0.9, 1.25 - p_koloniYogu / 100.0 * p_buyume / 100.0 * 0.9, f + 0.3); vec3 c = c_palet * (0.7 + 0.6 * vnoise(q * 0.6)); o = overPre(vec4(c, 1.0) * cov * m, s); }
//== duneripples
uniform float p_ruzgarYonu, p_sirtAral, p_yuksekli;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_ruzgarYonu) * toUnit(here()); float x = q.x / max(p_sirtAral, 2.0) + fbm(q * 0.01, 3.0) * 0.8; float saw = fract(x); float h = saw < 0.7 ? saw / 0.7 : (1.0 - saw) / 0.3;
  vec3 c = vec3(0.86, 0.72, 0.5) * (0.75 + 0.35 * mix(h, 1.0 - h, step(0.7, saw)) * p_yuksekli / 10.0); o = pre(clamp(c, 0.0, 1.0), s.a); }
//== mudcrack
uniform float p_kuruma, p_catlakKali, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec4 v = voronoi(q / 30.0 + seedf(p_tohum)); vec4 v2 = voronoi(q / 12.0 + seedf(p_tohum) + 3.0); float w = p_catlakKali * 0.01 * p_kuruma / 60.0;
  float crack = (1.0 - smoothstep(w, w + 0.02, v.y - v.x)) + (1.0 - smoothstep(w * 0.5, w * 0.5 + 0.02, v2.y - v2.x)) * step(0.6, p_kuruma / 100.0) * 0.6; vec3 mud = mix(vec3(0.45, 0.33, 0.22), vec3(0.72, 0.6, 0.45), p_kuruma / 100.0) * (0.9 + 0.2 * vnoise(q * 0.3));
  o = pre(mix(mud, vec3(0.15, 0.1, 0.06), clamp(crack, 0.0, 1.0)), s.a); }
//== strata
uniform float p_katman, p_kivrim; uniform vec3 c_mineralPale;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float y = b.y + sin(b.x * 5.0) * p_kivrim / 400.0 + fbm(b * 3.0, 4.0) * p_kivrim / 300.0; float id = floor(y * p_katman); float f = fract(y * p_katman);
  vec3 c = c_mineralPale * (0.6 + 0.6 * hash1(vec2(id, 4.0))) * (0.92 + 0.08 * vnoise(b * vec2(200.0, 20.0))); c *= 1.0 - smoothstep(0.92, 1.0, f) * 0.3; o = pre(clamp(c, 0.0, 1.0), s.a); }
//== treerings
uniform vec2 p_merkez; uniform float p_halkaAral, p_duzensiz;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_merkez; float a = atan(q.y, q.x); float r = length(q) + fbm(vec2(a * 2.0, length(q) * 0.02), 3.0) * p_duzensiz * 0.6; float ring = fract(r / max(p_halkaAral, 1.0));
  float late = smoothstep(0.7, 0.95, ring); vec3 c = mix(vec3(0.82, 0.62, 0.38), vec3(0.55, 0.35, 0.18), late) * (0.9 + 0.1 * vnoise(vec2(a * 30.0, r * 0.3))); o = pre(c, s.a); }
//== foamcells
uniform float p_hucre, p_buyume, p_filmCizg;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = sqrt(boxU().x * boxU().y / max(p_hucre, 2.0)) * (0.5 + p_buyume / 200.0); vec4 v = voronoi(q / cs + u_t * 0.05);
  float film = 1.0 - smoothstep(p_filmCizg * 0.02, p_filmCizg * 0.02 + 0.03, v.y - v.x); vec3 irid = hsv2rgb(vec3(fract(v.x * 2.0 + u_t * 0.1), 0.4, 1.0)); vec3 c = mix(vec3(0.9, 0.95, 1.0) * 0.15 + irid * 0.15, vec3(1.0), film);
  o = overPre(vec4(c, 1.0) * (0.3 + film * 0.7), s); }
//== flowerrosette
uniform float p_yaprak, p_aci, p_yaprakUzun; uniform vec3 c_palet;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = int(clamp(p_yaprak, 1.0, 300.0)); float best = 0.0; float c2 = 0.0;
  for (int i = 0; i < 300; i++) { if (i >= N) break; float fi = float(i); float a = radians(p_aci) * fi; float r = sqrt(fi) * p_yaprakUzun * 0.35; vec2 c = vec2(cos(a), sin(a)) * r; vec2 l = rot2(-degrees(a)) * (q - c);
    float m = 1.0 - smoothstep(0.9, 1.0, length(l / vec2(p_yaprakUzun * 0.5, p_yaprakUzun * 0.2))); if (m > best) { best = m; c2 = fi / float(N); } }
  vec3 col = mix(c_palet * 0.6, c_palet, c2) * (0.85 + 0.15 * best); o = overPre(vec4(col, 1.0) * best, s); }
