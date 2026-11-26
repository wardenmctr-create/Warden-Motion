// Ek 3B: katman kartı ve kaynak katmanlar üzerinde ağ işlemleri (530, 531, 532, 534, 535, 538, 726, 727, 732, 736, 746, 747)
//== loftprofiles
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_seciliProfKatm; uniform float p_seciliProfKatmOn, p_profilDeri, p_profilDonu, p_gecis, p_kapakOlus;
float aB(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return p_seciliProfKatmOn > 0.5 ? texture(s_seciliProfKatm, b).a : smoothstep(0.45, 0.35, length(b - 0.5)); }
float sdf(vec3 p) { float D = max(abs(p_profilDeri), 40.0) * 0.5; float k = clamp(p.z / D * 0.5 + 0.5, 0.0, 1.0); if (p_gecis > 0.5) k = k * k * (3.0 - 2.0 * k);
  vec2 xy = rot2(p_profilDonu * k) * p.xy; float a = mix(cardA(p.xy), aB(xy), k); float d2 = (0.5 - a) * 6.0; return max(d2, abs(p.z) - D) * 0.7; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== sweeppath
INCLUDE(_3d)
uniform float p_kesit, p_kesitBoyu, p_burgu, p_ucOlce, p_ilerleme, p_dvN; uniform vec4 p_dv4[32]; float dvAt(int i) { return i < 0 || i >= 128 ? 0.0 : p_dv4[i >> 2][i & 3]; }
float sdf(vec3 p) { int N = int(p_dvN / 2.0); float best = 1e9; float tot = float(max(N - 1, 1)); float lim = p_ilerleme / 100.0 * tot;
  for (int i = 0; i < 63; i++) { if (i >= N - 1) break; if (float(i) > lim) break; vec3 a = vec3(dvAt(i * 2), -dvAt(i * 2 + 1), 0.0), b = vec3(dvAt(i * 2 + 2), -dvAt(i * 2 + 3), 0.0); vec3 ab = b - a; float u = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-4), 0.0, min(1.0, lim - float(i)));
    vec3 c = p - a - ab * u; float t = (float(i) + u) / tot; float r = p_kesitBoyu * 0.5 * mix(1.0, p_ucOlce / 100.0, t); float ang = radians(p_burgu) * t; vec3 nrm = normalize(cross(ab, vec3(0.0, 0.0, 1.0)) + 1e-5);
    vec2 cs = vec2(dot(c, nrm), c.z); cs = rot2(degrees(ang)) * cs; float d = p_kesit < 0.5 ? length(cs) - r : p_kesit < 1.5 ? max(abs(cs.x), abs(cs.y)) - r : max(abs(cs.x) - r, abs(cs.y) - r * 0.15); best = min(best, d); }
  if (N < 2) { vec3 q = p; return length(vec2(length(q.xy) - boxU().x * 0.3, q.z)) - p_kesitBoyu * 0.5; } return best; }
vec4 surf(vec3 p, vec3 n) { return vec4(c_tabanRenk * (0.85 + 0.15 * n.z), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== wireframe3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_kenarTuru, p_cizgiKali, p_gizliKenaGost, p_gizliKenaOpak, p_dolguyuGost, p_dolguOpak; uniform vec3 c_cizgiReng;
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec2 g = abs(fract(p.xy / 24.0 + 0.5) - 0.5) * 24.0; float grid = p_kenarTuru < 0.5 ? 1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali * 0.5 + 0.8, min(g.x, g.y)) : 0.0;
  float rim = 1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali + 0.8, min(abs(abs(p.z) - 10.0), max(0.0, (0.5 - cardA(p.xy)) * 0.0 + 99.0))); float side = abs(n.z) < 0.6 ? 1.0 : 0.0; float edge = max(abs(abs(p.z) - 10.0) < p_cizgiKali ? side : 0.0, p_kenarTuru < 1.5 ? grid * (1.0 - side) : 0.0);
  if (p_kenarTuru > 1.5) edge = abs(abs(p.z) - 10.0) < p_cizgiKali ? side : 0.0; vec4 fill = cardSurf(p, n); float fa = p_dolguyuGost > 0.5 ? p_dolguOpak / 100.0 : 0.0;
  return vec4(mix(fill.rgb, c_cizgiReng, edge), max(edge, fa)); }
void main() { o = render3d(vec3(0.0)); }
//== sectionview
INCLUDE(_3d)
INCLUDE(_card)
uniform vec3 p_duzlemKonu, p_duzlemDonu, c_kapakReng; uniform float p_tersTaraGost, p_kesitKapa, p_kesitCizg, p_cizgiKali;
vec3 pn() { return rotXYZ(p_duzlemDonu) * vec3(1.0, 0.0, 0.0); }
float sdf(vec3 p) { float pl = dot(p - vec3(p_duzlemKonu.x, -p_duzlemKonu.y, -p_duzlemKonu.z), pn()) * (p_tersTaraGost > 0.5 ? -1.0 : 1.0); return max(cardD(p, 40.0), pl); }
vec4 surf(vec3 p, vec3 n) { float pl = abs(dot(p - vec3(p_duzlemKonu.x, -p_duzlemKonu.y, -p_duzlemKonu.z), pn())); if (pl < 0.8 && p_kesitKapa > 0.5) { float hatch = p_kesitCizg > 0.5 ? step(0.5, fract((p.y + p.z) / max(p_cizgiKali * 4.0, 2.0))) : 1.0; return vec4(c_kapakReng * (0.7 + 0.3 * hatch), 1.0); } return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== csgcards
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_ikinciMode; uniform float p_ikinciModeOn, p_islem, p_yontem, p_voxelBoyu, p_girislerGoruTut; uniform vec3 c_yeniYuzReng;
float aB(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return p_ikinciModeOn > 0.5 ? texture(s_ikinciMode, b).a : step(length(b - vec2(0.62, 0.42)), 0.28); }
float dB(vec3 p) { vec3 q = p; if (p_yontem > 0.5) q = (floor(p / max(p_voxelBoyu, 0.5)) + 0.5) * max(p_voxelBoyu, 0.5); float d2 = (0.5 - aB(q.xy)) * 6.0; vec2 w = vec2(d2, abs(p.z - 6.0) - 14.0); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); }
float sdf(vec3 p) { float a = cardD(p, 24.0), b = dB(p); return p_islem < 0.5 ? min(a, b) : p_islem < 1.5 ? max(a, b) : max(a, -b); }
vec4 surf(vec3 p, vec3 n) { float a = cardD(p, 24.0), b = dB(p); if (abs(b) < abs(a) && p_islem > 1.5) return vec4(c_yeniYuzReng, 1.0); if (abs(b) < abs(a)) { vec2 bb = vec2(p.x, -p.y) / boxU() + 0.5; vec4 c = p_ikinciModeOn > 0.5 ? texture(s_ikinciMode, clamp(bb, 0.0, 1.0)) : vec4(c_yeniYuzReng, 1.0); return vec4(c.a > 0.0 ? c.rgb / c.a : c_yeniYuzReng, 1.0); } return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== decal3d
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_cikartma; uniform float p_cikartmaOn, p_yontem, p_aciSini, p_opaklik, p_yuzeyIsigKull; uniform vec3 p_konum, p_donus; uniform vec2 p_boyut;
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 base = cardSurf(p, n); mat3 R = rotXYZ(p_donus); vec3 l = transpose(R) * (p - vec3(p_konum.x, -p_konum.y, -p_konum.z)); vec2 uv = l.xy / max(p_boyut, vec2(1.0)) + 0.5; uv.y = 1.0 - uv.y;
  float facing = dot(n, R * vec3(0.0, 0.0, 1.0)); if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0))) || facing < cos(radians(p_aciSini))) return base;
  vec4 d = p_cikartmaOn > 0.5 ? texture(s_cikartma, uv) : vec4(vec3(1.0, 0.8, 0.2) * step(length(uv - 0.5), 0.4), step(length(uv - 0.5), 0.4)); float e = smoothstep(0.0, max(p_kenarYumu, 0.01) * 0.05, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
  return vec4(mix(base.rgb, d.a > 0.0 ? d.rgb / d.a : base.rgb, d.a * e * p_opaklik / 100.0), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== subdivide
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_seviye, p_yontem, p_kenarlarKoru;
float sA(vec2 xy) { float r = 3.0 * p_seviye; if (r < 0.5) return cardA(xy); float a = 0.0; for (int i = 0; i < 12; i++) { float an = float(i) * 0.5236; a += cardA(xy + vec2(cos(an), sin(an)) * r); } return mix(a / 12.0, cardA(xy), p_kenarlarKoru > 0.5 ? 0.25 : 0.0); }
float sdf(vec3 p) { float d2 = (0.5 - sA(p.xy)) * 6.0; float r = p_yontem < 0.5 ? 4.0 * p_seviye : 0.0; vec2 w = vec2(d2 + r * 0.3, abs(p.z) - 10.0 + r * 0.3); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - r * 0.3; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== decimate
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_yuzOran, p_kenarKoru, p_onceSonrYuz;
float sdf(vec3 p) { float N = mix(6.0, 64.0, p_yuzOran / 100.0); float a = atan(p.y, p.x); float sec = TAU / N; float a0 = floor(a / sec) * sec, a1 = a0 + sec; float R = length(boxU()) * 0.5;
  float r0 = 0.0, r1 = 0.0; for (int k = 0; k < 24; k++) { float t = R * float(k) / 23.0; if (cardA(vec2(cos(a0), sin(a0)) * t) > 0.5) r0 = t; if (cardA(vec2(cos(a1), sin(a1)) * t) > 0.5) r1 = t; }
  vec2 A = vec2(cos(a0), sin(a0)) * r0, B = vec2(cos(a1), sin(a1)) * r1; vec2 e = B - A; float side = (e.x * (p.y - A.y) - e.y * (p.x - A.x)) / max(length(e), 1e-3); float d2 = -side; return max(d2, abs(p.z) - 10.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); if (p_onceSonrYuz > 0.5) { float N = mix(6.0, 64.0, p_yuzOran / 100.0); float a = atan(p.y, p.x); float f = fract(a / (TAU / N)); c.rgb *= 1.0 - (1.0 - smoothstep(0.0, 0.03, min(f, 1.0 - f))) * 0.4; } return c; }
void main() { o = render3d(vec3(0.0)); }
//== triangulate
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_ucgenYont, p_yonleriKoru, p_normalKoru;
float sdf(vec3 p) { return cardD(p, 16.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); vec2 g = p.xy / 18.0; vec2 f = fract(g); float diag = p_ucgenYont < 0.5 ? abs(f.x - f.y) : p_ucgenYont < 1.5 ? abs(f.x + f.y - 1.0) : (mod(floor(g.x) + floor(g.y), 2.0) > 0.5 ? abs(f.x - f.y) : abs(f.x + f.y - 1.0));
  float e = min(min(f.x, 1.0 - f.x), min(min(f.y, 1.0 - f.y), diag * 0.7)); float line = 1.0 - smoothstep(0.0, 0.05, e); float facet = p_normalKoru > 0.5 ? 1.0 : 0.9 + 0.1 * step(f.x, f.y); return vec4(mix(c.rgb * facet, vec3(0.1, 0.12, 0.2), line * 0.7), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== skelvolume
INCLUDE(_3d)
uniform float p_yaricap, p_birlesimYumu, p_dvN; uniform vec4 p_dv4[16]; float dvAt(int i) { return i < 0 || i >= 64 ? 0.0 : p_dv4[i >> 2][i & 3]; }
float smin(float a, float b, float k) { float h = clamp(0.5 + 0.5 * (b - a) / max(k, 1e-3), 0.0, 1.0); return mix(b, a, h) - k * h * (1.0 - h); }
float sdf(vec3 p) { int N = int(p_dvN / 2.0); float k = p_birlesimYumu * 0.6; float d = 1e9; if (N < 1) { for (int i = 0; i < 4; i++) { vec3 c = vec3(cos(float(i) * 1.57), sin(float(i) * 1.57), 0.0) * boxU().x * 0.2; d = smin(d, length(p - c) - p_yaricap * 3.0, k); } return d; }
  vec3 prev = vec3(dvAt(0), -dvAt(1), 0.0); d = length(p - prev) - p_yaricap; for (int i = 1; i < 32; i++) { if (i >= N) break; vec3 c = vec3(dvAt(i * 2), -dvAt(i * 2 + 1), 0.0); vec3 ab = c - prev; float u = clamp(dot(p - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); d = smin(d, length(p - prev - ab * u) - p_yaricap, k); prev = c; } return d; }
vec4 surf(vec3 p, vec3 n) { return vec4(c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== vol2surf
INCLUDE(_3d)
uniform float p_yogunlukEsig, p_cozunurl, p_yumusatm;
float dens(vec3 p) { vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; float q = max(p_cozunurl, 16.0); b = mix(b, (floor(b * q) + 0.5) / q, 1.0 - p_yumusatm / 100.0);
  vec4 c = texPx(boxPx(b)); float l = luma(unpre(c)) * c.a; float th = max(boxU().x, boxU().y) * 0.15 * l; return l - smoothstep(0.0, th + 1.0, abs(p.z)) * 0.0 - abs(p.z) / max(th * 2.0 + 1.0, 1.0); }
float sdf(vec3 p) { return (p_yogunlukEsig / 100.0 - dens(p)) * 20.0; }
vec4 surf(vec3 p, vec3 n) { vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; vec4 c = texPx(boxPx(clamp(b, 0.0, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== painttrail
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_izGeni, p_solma, p_dvN; uniform vec4 p_dv4[16]; float dvAt(int i) { return i < 0 || i >= 64 ? 0.0 : p_dv4[i >> 2][i & 3]; }
float sdf(vec3 p) { return cardD(p, 16.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); int N = int(p_dvN / 2.0); float best = 1e9; float bk = 0.0; for (int i = 0; i < 31; i++) { if (i >= N - 1) break; vec2 a = vec2(dvAt(i * 2), -dvAt(i * 2 + 1)), b = vec2(dvAt(i * 2 + 2), -dvAt(i * 2 + 3)); vec2 ab = b - a; float u = clamp(dot(p.xy - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(p.xy - a - ab * u); if (d < best) { best = d; bk = float(i) / max(float(N - 1), 1.0); } }
  float m = (1.0 - smoothstep(p_izGeni * 0.4, p_izGeni * 0.5, best)) * mix(1.0, bk, p_solma / 100.0) * step(0.6, abs(n.z)); return vec4(mix(c.rgb, vec3(0.9, 0.2, 0.25), m), 1.0); }
void main() { o = render3d(vec3(0.0)); }
