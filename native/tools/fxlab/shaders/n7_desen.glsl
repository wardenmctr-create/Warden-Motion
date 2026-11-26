// 550 rehberi: prosedürel desenler (508–517) ve yardımcı çizimler
//== maze
uniform float p_satir, p_sutun, p_bicim, p_tohum, p_donguOran, p_duvarKali, p_cizimIler; uniform vec3 c_duvarReng;
// İkili ağaç labirenti: her hücre kuzey ya da doğu duvarını rastgele açar → tek parça, döngüsüz labirent (hücre başına yerel karar)
bool openN(vec2 id, vec2 n) { if (id.y >= n.y - 1.0) return false; if (id.x >= n.x - 1.0) return true; float h = hash1(id + seedf(p_tohum)); return h < 0.5 || hash1(id + 7.1) < p_donguOran / 100.0; }
bool openE(vec2 id, vec2 n) { if (id.x >= n.x - 1.0) return false; if (id.y >= n.y - 1.0) return true; float h = hash1(id + seedf(p_tohum)); return h >= 0.5 || hash1(id + 3.3) < p_donguOran / 100.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 n = vec2(max(floor(p_sutun), 2.0), max(floor(p_satir), 2.0)); vec2 b = boxUV(here()); vec2 g;
  if (p_bicim > 1.5) { vec2 q = toUnit(here()) / (min(boxU().x, boxU().y) * 0.5); float r = length(q); if (r > 1.0) { o = s; return; } g = vec2(fract(atan(q.y, q.x) / TAU + 0.5) * n.x, r * n.y); }
  else { g = vec2(b.x, 1.0 - b.y) * n; if (p_bicim > 0.5) g.x += mod(floor(g.y), 2.0) * 0.5; }
  vec2 id = floor(g); vec2 f = fract(g); if (any(lessThan(id, vec2(0.0))) || any(greaterThanEqual(id, n))) { o = s; return; }
  float w = max(p_duvarKali, 0.5) / (boxU().x / n.x) * 0.5; float wall = 0.0;
  if (!openN(id, n)) wall = max(wall, step(1.0 - w, f.y)); if (!openE(id, n)) wall = max(wall, step(1.0 - w, f.x));
  if (id.y < 0.5) wall = max(wall, step(f.y, w)); if (id.x < 0.5 && p_bicim < 1.5) wall = max(wall, step(f.x, w));
  if (!openN(id - vec2(0, 1), n) && id.y > 0.5) wall = max(wall, step(f.y, w)); if (!openE(id - vec2(1, 0), n) && id.x > 0.5) wall = max(wall, step(f.x, w));
  wall = max(wall, step(length(min(f, 1.0 - f)), w * 1.2));
  float reveal = step((id.y * n.x + id.x) / (n.x * n.y), p_cizimIler / 100.0 * 1.0001); o = overPre(vec4(c_duvarReng, 1.0) * wall * reveal, s); }
//== truchet
uniform float p_karoBoyu, p_yolBici, p_cizgiKali, p_tohum, p_yonDagi, p_donus; uniform vec2 p_kayma; uniform vec3 c_cizgiReng, c_zeminReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_donus) * toUnit(here()) + p_kayma; float T = max(p_karoBoyu, 4.0); vec2 id = floor(q / T); vec2 f = fract(q / T) - 0.5;
  float h = hash1(id + seedf(p_tohum)); if (h < p_yonDagi / 100.0) f.x = -f.x; float kind = p_yolBici < 1.5 ? p_yolBici : step(0.5, hash1(id + 9.0)); float d;
  if (kind < 0.5) { vec2 c = f.x + f.y > 0.0 ? vec2(0.5) : vec2(-0.5); d = abs(length(f - c) - 0.5); } else d = min(abs(f.x + f.y) , abs(f.x - f.y + (f.x - f.y > 0.0 ? -1.0 : 1.0) * 0.0) * 9.0) ;
  if (kind > 0.5) d = abs(f.x + f.y) / 1.4142; float line = 1.0 - smoothstep(p_cizgiKali / T * 0.5, p_cizgiKali / T * 0.5 + 1.0 / (T * u_s), d);
  vec3 c = mix(c_zeminReng, c_cizgiReng, line); o = overPre(pre(c, 1.0) * s.a, vec4(0.0)) ; }
//== plantgrow
uniform vec2 p_kok; uniform float p_bitkiBici, p_yineleme, p_dalAcis, p_dalUzun, p_kisalma, p_ilerleme, p_tohum, p_govdeKali, p_yaprakla; uniform vec3 c_dalReng, c_yaprakReng;
float segD(vec2 p, vec2 a, vec2 b, out float t) { vec2 ab = b - a; t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 root = p_kok; int D = int(clamp(p_yineleme, 1.0, 7.0)); float grow = p_ilerleme / 100.0 * float(D + 1); float sd = seedf(p_tohum);
  float wood = 0.0, leaf = 0.0; int total = (1 << (D + 1)) - 1; float k = p_kisalma / 100.0;
  for (int i = 0; i < 255; i++) { if (i >= total) break; int lvl = int(floor(log2(float(i + 1)))); int idx = i + 1 - (1 << lvl);
    // yolu kökten yürü: her seviye sol/sağ dal
    vec2 a = root; float ang = -90.0; float L = p_dalUzun; for (int j = 0; j < 8; j++) { if (j >= lvl) break; a += vec2(cos(radians(ang)), sin(radians(ang))) * L; int bit = (idx >> (lvl - 1 - j)) & 1;
      float jit = (hash1(vec2(float(i), float(j)) + sd) - 0.5) * 20.0; ang += (bit == 1 ? p_dalAcis : -p_dalAcis) * (p_bitkiBici > 0.5 && p_bitkiBici < 1.5 ? 0.6 : 1.0) + jit + (p_bitkiBici > 1.5 ? 25.0 : 0.0); L *= k; }
    float gl = clamp(grow - float(lvl), 0.0, 1.0); if (gl <= 0.0) continue; vec2 b = a + vec2(cos(radians(ang)), sin(radians(ang))) * L * gl; float t; float d = segD(q, a, b, t);
    float w = max(p_govdeKali * pow(0.65, float(lvl)), 0.6) * 0.5; wood = max(wood, 1.0 - smoothstep(w, w + 0.8, d));
    if (p_yaprakla > 0.5 && lvl >= D - 1) { vec2 lp = rot2(-ang) * (q - b); leaf = max(leaf, (1.0 - smoothstep(0.0, 0.8, length(lp / vec2(L * 0.35 + 3.0, L * 0.15 + 1.5)) - 1.0)) * gl); } }
  vec4 c = overPre(vec4(c_dalReng, 1.0) * wood, vec4(0.0)); c = overPre(vec4(c_yaprakReng, 1.0) * leaf, c); o = overPre(c, s); }
//== guilloche
uniform vec2 p_merkez; uniform float p_yaricap, p_egriSayi, p_dalgaSayi, p_dalgaGucu, p_faz, p_cizgiKali, p_opaklik; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_merkez; float r = length(q); float a = atan(q.y, q.x); float N = max(floor(p_egriSayi), 1.0); float acc = 0.0;
  for (int i = 0; i < 64; i++) { if (float(i) >= N) break; float fi = float(i); float ph = radians(p_faz) + fi / N * TAU / max(p_dalgaSayi, 1.0);
    float R = p_yaricap * (1.0 + p_dalgaGucu / 100.0 * 0.5 * sin(a * max(p_dalgaSayi, 1.0) + ph)) * (0.6 + 0.4 * fi / N); float d = abs(r - R);
    acc = max(acc, 1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali * 0.5 + 0.8 / u_s, d)); }
  o = overPre(vec4(c_renk, 1.0) * acc * p_opaklik / 100.0, s); }
//== interference
uniform vec2 p_birinciMerk, p_ikinciMerk; uniform float p_bicim, p_birinciDalgBoyu, p_ikinciDalgBoyu, p_fazFark, p_hiz, p_kontrast; uniform vec3 c_birinciRenk, c_ikinciRenk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float t = u_t * p_hiz * TAU; float w1, w2;
  float d1 = p_bicim > 0.5 && p_bicim < 1.5 ? q.x : length(q - p_birinciMerk); float d2 = p_bicim > 0.5 ? dot(q - p_ikinciMerk, normalize(vec2(1.0, 0.3))) : length(q - p_ikinciMerk);
  w1 = sin(d1 / max(p_birinciDalgBoyu, 1.0) * TAU - t); w2 = sin(d2 / max(p_ikinciDalgBoyu, 1.0) * TAU - t + radians(p_fazFark)); float v = (w1 + w2) * 0.25 + 0.5; v = clamp((v - 0.5) * (1.0 + p_kontrast / 25.0) + 0.5, 0.0, 1.0);
  o = pre(mix(c_birinciRenk, c_ikinciRenk, v), 1.0) * s.a; }
//== flowfield
uniform sampler2D s_vektorHari; uniform float p_vektorHariOn;
uniform float p_alanKayn, p_olcek, p_turbulan, p_tohum, p_sayi, p_hiz, p_izSure, p_kalinlik; uniform vec3 c_renk;
vec2 fieldAt(vec2 q) { float sd = seedf(p_tohum); if (p_alanKayn < 0.5) { float a = fbm01(q / max(p_olcek, 1.0) + sd, 2.0 + p_turbulan / 30.0) * TAU * 2.0; return vec2(cos(a), sin(a)); }
  if (p_alanKayn < 1.5) return normalize(q + 1e-3); if (p_alanKayn < 2.5) return normalize(vec2(-q.y, q.x) + q * 0.15 + 1e-3);
  if (p_vektorHariOn > 0.5) { vec2 v = unpre(texture(s_vektorHari, clamp(boxUV(fromUnit(q)), 0.0, 1.0))).rg * 2.0 - 1.0; return length(v) > 1e-3 ? normalize(v) : vec2(1.0, 0.0); } return vec2(1.0, 0.0); }
// Akış çizgileri: piksel, alan boyunca geriye izlenir; yol üzerinde rastgele "parçacık başları" taşınır
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float dens = clamp(p_sayi / 2000.0, 0.02, 1.0); float acc = 0.0; vec2 p = q; float L = max(p_izSure, 0.05) * p_hiz; float st = L / 16.0;
  for (int i = 0; i < 16; i++) { vec2 cell = floor(p / max(p_kalinlik * 3.0, 3.0)); float h = hash1(cell + seedf(p_tohum)); float ph = fract(h * 7.0 + u_t * p_hiz / max(L, 1.0) * 0.5);
    float head = step(1.0 - dens, h) * smoothstep(0.0, 1.0, 1.0 - abs(fract(float(i) / 16.0 + ph) - 0.5) * 2.0); acc = max(acc, head * (1.0 - float(i) / 16.0)); p -= fieldAt(p) * st; }
  o = overPre(vec4(c_renk, 1.0) * acc, s); }
//== snowflake
uniform float p_yaricap, p_kolSayi, p_yanDalSayi, p_dalAcis, p_dalUzun, p_cizgiKali, p_buyume, p_tohum, p_parlama; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float N = max(floor(p_kolSayi), 3.0); float a = atan(q.y, q.x); float r = length(q); float sec = TAU / N;
  float la = mod(a + sec * 0.5, sec) - sec * 0.5; vec2 p = vec2(cos(la), abs(sin(la))) * r; float R = p_yaricap * p_buyume / 100.0; float w = p_cizgiKali * 0.5;
  float d = abs(p.y) + max(p.x - R, 0.0) + max(-p.x, 0.0); int B = int(clamp(p_yanDalSayi, 0.0, 12.0));
  for (int i = 0; i < 12; i++) { if (i >= B) break; float x0 = R * (float(i) + 1.0) / (float(B) + 1.0); float bl = R * p_dalUzun / 100.0 * (1.0 - float(i) / (float(B) + 1.0)) * (0.7 + 0.6 * hash1(vec2(float(i), seedf(p_tohum))));
    vec2 dir = vec2(cos(radians(p_dalAcis)), sin(radians(p_dalAcis))); vec2 rp = p - vec2(x0, 0.0); float t = clamp(dot(rp, dir), 0.0, bl * p_buyume / 100.0); d = min(d, length(rp - dir * t)); }
  float m = 1.0 - smoothstep(w, w + 0.8 / u_s, d); float glow = exp(-d / max(w * 4.0, 1.0)) * p_parlama / 100.0; o = overPre(vec4(c_renk, 1.0) * clamp(m + glow, 0.0, 1.0), s); }
//== ornament
uniform float p_geometri, p_karoBoyu, p_icYari, p_aci, p_cizgiKali, p_dolguGost; uniform vec2 p_kayma; uniform vec3 c_anaRenk, c_ikinciRenk, c_cizgiReng;
float star(vec2 p, float n, float inner) { float a = atan(p.y, p.x); float sec = TAU / n; float la = abs(mod(a, sec) - sec * 0.5); vec2 q = vec2(cos(la), sin(la)) * length(p);
  vec2 A = vec2(1.0, 0.0), B = vec2(cos(sec * 0.5), sin(sec * 0.5)) * inner; vec2 e = B - A; vec2 w = q - A; float d = length(w - e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0)); return d * sign(e.x * w.y - e.y * w.x); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()) + p_kayma; float T = max(p_karoBoyu, 8.0); float n = p_geometri < 0.5 ? 4.0 : p_geometri < 1.5 ? 6.0 : p_geometri < 2.5 ? 8.0 : 12.0;
  vec2 f; if (n == 6.0 || n == 12.0) { vec4 h = hexGrid(q / T, 1.0); f = h.xy; } else f = fract(q / T) - 0.5; vec2 p = f * 2.0;
  float d = star(p, n, p_icYari / 100.0 * 0.9 + 0.05); float d2 = star(rot2(180.0 / n) * p * 1.35, n, p_icYari / 100.0 * 0.9 + 0.05);
  float line = 1.0 - smoothstep(p_cizgiKali / T, p_cizgiKali / T + 1.5 / (T * u_s), min(abs(d), abs(d2)));
  vec3 c = p_dolguGost > 0.5 ? (d < 0.0 ? c_ikinciRenk : c_anaRenk) : c_anaRenk; c = mix(c, c_cizgiReng, line); o = pre(c, 1.0) * s.a; }
//== fractalpath
uniform float p_yolTuru, p_seviye, p_buyukluk, p_cizimIler, p_cizgiKali, p_renklend, p_tersCiz; uniform vec3 c_baslangiReng, c_bitisReng;
// Hilbert eğrisi: d ↔ (x,y) (tam sayı, klasik algoritma)
vec2 h2xy(int n, int d) { int x = 0, y = 0, t = d; for (int s = 1; s < 256; s *= 2) { if (s >= n) break; int rx = 1 & (t / 2); int ry = 1 & (t ^ rx);
    if (ry == 0) { if (rx == 1) { x = s - 1 - x; y = s - 1 - y; } int tmp = x; x = y; y = tmp; } x += s * rx; y += s * ry; t /= 4; } return vec2(x, y); }
int xy2d(int n, int x, int y) { int d = 0; for (int s = 128; s > 0; s /= 2) { if (s >= n) continue; int rx = (x & s) > 0 ? 1 : 0; int ry = (y & s) > 0 ? 1 : 0; d += s * s * ((3 * rx) ^ ry);
    if (ry == 0) { if (rx == 1) { x = n - 1 - x; y = n - 1 - y; } int tmp = x; x = y; y = tmp; } } return d; }
void main() { vec4 s = texture(u_tex, v_uv); int L = int(clamp(floor(p_seviye), 1.0, 7.0)); int n = 1 << L; float nf = float(n); float S = max(p_buyukluk, 10.0); vec2 q = toUnit(here()) / S + 0.5;
  if (any(lessThan(q, vec2(-0.05))) || any(greaterThan(q, vec2(1.05)))) { o = s; return; }
  ivec2 cell = ivec2(clamp(floor(q * nf), 0.0, nf - 1.0)); int N = n * n; float lim = float(N) * p_cizimIler / 100.0; float best = 1e9; float bestT = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { ivec2 c = cell + ivec2(i, j); if (c.x < 0 || c.y < 0 || c.x >= n || c.y >= n) continue; int d = xy2d(n, c.x, c.y);
    for (int k = -1; k <= 0; k++) { int d0 = d + k; if (d0 < 0 || d0 + 1 >= N) continue; if (float(d0 + 1) > lim) continue; vec2 A = (h2xy(n, d0) + 0.5) / nf, B = (h2xy(n, d0 + 1) + 0.5) / nf;
      vec2 ab = B - A; float t = clamp(dot(q - A, ab) / dot(ab, ab), 0.0, 1.0); float dist = length(q - A - ab * t); if (dist < best) { best = dist; bestT = (float(d0) + t) / float(N); } } }
  float w = p_cizgiKali / S * 0.5; float m = 1.0 - smoothstep(w, w + 1.0 / (S * u_s), best); if (p_tersCiz > 0.5) bestT = 1.0 - bestT;
  vec3 c = p_renklend > 0.5 ? mix(c_baslangiReng, c_bitisReng, bestT) : c_baslangiReng; o = overPre(vec4(c, 1.0) * m, s); }
