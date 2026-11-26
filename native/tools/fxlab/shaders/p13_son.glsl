// Son ekler: kamera sabitleme, doku bölütleme, gölge yakalama, nesne matı, modeli eğriye uydurma
//== stabilize
uniform float p_sabitlemGucu, p_kenarYone, p_enFazlYaki, p_takipNoktGost, p_dvN; uniform float p_dv[8];
void main() { vec2 q = toUnit(here()); vec2 sh = p_dvN >= 2.0 ? vec2(p_dv[0], p_dv[1]) : vec2(0.0); float z = p_kenarYone < 0.5 ? min(1.0 + length(sh) / max(min(boxU().x, boxU().y), 1.0) * 2.2, p_enFazlYaki / 100.0) : 1.0;
  vec2 src = (q / z) + sh; vec2 b = boxUV(fromUnit(src)); vec4 c = texU(src); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) c = p_kenarYone > 1.5 ? texEdge(fromUnit(src), 3.0) : vec4(0.0);
  if (p_takipNoktGost > 0.5 && u_export < 0.5) c = overPre(vec4(0.2, 1.0, 0.4, 1.0) * (1.0 - smoothstep(3.0, 4.0, length(q + sh * 0.0 - sh))), c); o = c; }
//== texsegment
uniform float p_bolgeHede, p_dokuAgir;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float m = 0.0, m2 = 0.0; vec2 g = vec2(0.0); for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; vec2 o2 = vec2(cos(a), sin(a)) * 6.0 * u_s; float l = luma(unpre(texPx(here() + o2))); m += l; m2 += l * l; g += abs(lumGrad(here() + o2, u_s)); }
  m /= 12.0; float var_ = sqrt(max(m2 / 12.0 - m * m, 0.0)); vec2 gd = g / 12.0; float k = max(2.0, pow(p_bolgeHede, 1.0 / 3.0)); vec3 f = vec3(mix(luma(c), var_ * 4.0, p_dokuAgir / 100.0), mix(rgb2hsv(c).x, gd.x * 6.0, p_dokuAgir / 100.0), mix(rgb2hsv(c).y, gd.y * 6.0, p_dokuAgir / 100.0));
  vec3 id = floor(clamp(f, 0.0, 0.999) * k); vec3 col = hsv2rgb(vec3(hash1(id.xy + id.z * 7.0), 0.55, 0.55 + 0.4 * hash1(id.zy + 3.0))); o = pre(col, s.a); }
//== shadowcatcher
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_isikMode; uniform float p_isikModeOn, p_golgeGucu, p_zeminGizl;
float sdf(vec3 p) { return cardD(p, 14.0); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { vec4 c = render3d(vec3(0.0)); vec4 s = texture(u_tex, v_uv); float objA = s.a; vec4 sh = vec4(0.0, 0.0, 0.0, 1.0) * clamp((c.a - objA) * p_golgeGucu / 100.0 * 1.5, 0.0, 1.0); if (luma(c.rgb / max(c.a, 1e-3)) > 0.05) sh *= step(objA, 0.01);
  o = p_zeminGizl > 0.5 ? sh : overPre(sh, vec4(0.9, 0.92, 0.95, 1.0)); }
//== objectmatte
uniform sampler2D s_nesne; uniform float p_nesneOn, p_kimlikTuru;
void main() { vec4 s = texture(u_tex, v_uv); if (p_nesneOn < 0.5) { o = vec4(vec3(s.a), 1.0) * 1.0; return; } vec4 n = texture(s_nesne, clamp(boxUV(here()), 0.0, 1.0)); float m = p_kimlikTuru < 0.5 ? n.a : step(0.05, length(unpre(n) - unpre(s))) * n.a; o = vec4(vec3(m), 1.0); }
//== bendtocurve
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_eksen, p_ilerleme, p_dvN; uniform float p_dv[128];
// kart, eğri boyunca bükülür: x ekseni eğri uzunluğuna, y normal yönüne eşlenir
vec3 unbend(vec3 p) { int N = int(p_dvN / 2.0); if (N < 2) return p; float best = 1e9; float s = 0.0; float acc = 0.0; float yOff = 0.0; float tot = 0.0;
  for (int i = 0; i < 63; i++) { if (i >= N - 1) break; vec2 a = vec2(p_dv[i * 2], -p_dv[i * 2 + 1]), b = vec2(p_dv[i * 2 + 2], -p_dv[i * 2 + 3]); tot += length(b - a); }
  for (int i = 0; i < 63; i++) { if (i >= N - 1) break; vec2 a = vec2(p_dv[i * 2], -p_dv[i * 2 + 1]), b = vec2(p_dv[i * 2 + 2], -p_dv[i * 2 + 3]); vec2 ab = b - a; float L = length(ab); float u = clamp(dot(p.xy - a, ab) / max(L * L, 1e-4), 0.0, 1.0); vec2 c = a + ab * u; float d = length(p.xy - c);
    if (d < best) { best = d; s = acc + u * L; vec2 nrm = vec2(-ab.y, ab.x) / max(L, 1e-4); yOff = dot(p.xy - c, nrm); } acc += L; }
  vec3 flat_ = vec3((s / max(tot, 1.0) - 0.5) * boxU().x, yOff, p.z); return mix(p, flat_, p_ilerleme / 100.0); }
float sdf(vec3 p) { return cardD(unbend(p), 14.0) * 0.5; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(unbend(p), n); }
void main() { o = render3d(vec3(0.0)); }
//== brushmask
uniform float p_fircaCapi, p_sertlik, p_ilerleme, p_maskeyiTersCevi, p_dvN; uniform float p_dv[128];
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = int(p_dvN / 2.0); if (N < 2) { o = s; return; } float tot = 0.0; for (int i = 0; i < 63; i++) { if (i >= N - 1) break; tot += length(vec2(p_dv[i * 2 + 2], p_dv[i * 2 + 3]) - vec2(p_dv[i * 2], p_dv[i * 2 + 1])); }
  float lim = tot * p_ilerleme / 100.0; float acc = 0.0; float best = 1e9;
  for (int i = 0; i < 63; i++) { if (i >= N - 1) break; vec2 a = vec2(p_dv[i * 2], p_dv[i * 2 + 1]), b = vec2(p_dv[i * 2 + 2], p_dv[i * 2 + 3]); vec2 ab = b - a; float L = length(ab); if (acc >= lim) break; float um = min(1.0, (lim - acc) / max(L, 1e-4)); float u = clamp(dot(q - a, ab) / max(L * L, 1e-4), 0.0, um); best = min(best, length(q - a - ab * u)); acc += L; }
  float R = p_fircaCapi * 0.5; float m = 1.0 - smoothstep(R * (p_sertlik / 100.0) * 0.99, R + 0.5, best); if (p_maskeyiTersCevi > 0.5) m = 1.0 - m; o = s * m; }
//== perspfix
uniform sampler2D s_anl; uniform float p_anlOn, p_duzeltme, p_otomatikKirp;
void main() { if (p_anlOn < 0.5) { o = texture(u_tex, v_uv); return; } float a = (texture(s_anl, vec2(0.25, 0.5)).r - 0.5) * 2.0, b = (texture(s_anl, vec2(0.75, 0.5)).r - 0.5) * 2.0; vec2 bb = boxUV(here()); float k = p_duzeltme / 100.0;
  float y = bb.y - 0.5; vec2 src = vec2(bb.x + (a + b * (bb.x - 0.5)) * y * k * (boxU().y / boxU().x), bb.y); if (p_otomatikKirp > 0.5) { float z = 1.0 + abs(b) * k * 0.5 + abs(a) * k * 0.5; src = (src - 0.5) / z + 0.5; }
  o = any(lessThan(src, vec2(0.0))) || any(greaterThan(src, vec2(1.0))) ? vec4(0.0) : texPx(boxPx(src)); }
//== panorama
uniform sampler2D s_kaynakla, s_kaynakla_1, s_kaynakla_2; uniform float p_kaynaklaOn, p_kaynakla_1On, p_kaynakla_2On, p_dikisGeni;
vec4 img(int i, vec2 uv) { uv = clamp(uv, 0.0, 1.0); if (i == 0) return texPx(boxPx(uv)); if (i == 1) return texture(s_kaynakla, uv); if (i == 2) return texture(s_kaynakla_1, uv); return texture(s_kaynakla_2, uv); }
float meanL(int i, float x0, float x1) { float m = 0.0; for (int k = 0; k < 8; k++) m += luma(unpre(img(i, vec2(mix(x0, x1, (float(k) + 0.5) / 8.0), 0.5)))); return m / 8.0; }
void main() { int N = 1 + int(p_kaynaklaOn > 0.5) + int(p_kaynakla_1On > 0.5) + int(p_kaynakla_2On > 0.5); vec2 b = boxUV(here()); float ov = clamp(p_dikisGeni / max(boxU().x, 1.0), 0.0, 0.45);
  float span = float(N) - ov * float(N - 1); float X = b.x * span; vec4 acc = vec4(0.0); float ws = 0.0; float gain = 1.0;
  for (int i = 0; i < 4; i++) { if (i >= N) break; float x0 = float(i) * (1.0 - ov); float lx = X - x0; if (i > 0) gain *= meanL(i - 1, 1.0 - ov, 1.0) / max(meanL(i, 0.0, ov), 0.02);
    if (lx < 0.0 || lx > 1.0) continue; float w = min(1.0, min(lx / max(ov, 1e-3), (1.0 - lx) / max(ov, 1e-3))); if (i == 0) w = max(w, step(lx, 0.5)); if (i == N - 1) w = max(w, step(0.5, lx));
    vec2 uv = vec2(lx, 0.5 + (b.y - 0.5) * span * boxU().y / boxU().x * 0.0 + (b.y - 0.5)); vec4 c = img(i, uv); c.rgb = clamp(c.rgb * gain, 0.0, c.a); acc += c * w; ws += w; }
  o = ws > 0.0 ? acc / ws : vec4(0.0); }
//== areacompare
uniform float p_alanBiri, p_alanEtik, p_dvN; uniform float p_dv[8];
float seg7(vec2 p, int d) { int m[10] = int[10](63, 6, 91, 79, 102, 109, 125, 7, 127, 111); int b = m[d % 10]; float r = 0.0; vec2 a[7] = vec2[7](vec2(0.0, 0.8), vec2(0.45, 0.4), vec2(0.45, -0.4), vec2(0.0, -0.8), vec2(-0.45, -0.4), vec2(-0.45, 0.4), vec2(0.0, 0.0));
  for (int i = 0; i < 7; i++) { if ((b / int(pow(2.0, float(i)))) % 2 == 0) continue; vec2 q = p - a[i]; bool hz = i == 0 || i == 3 || i == 6; vec2 e = hz ? vec2(0.34, 0.08) : vec2(0.08, 0.32); vec2 dd = abs(q) - e; r = max(r, 1.0 - smoothstep(0.0, 0.08, max(dd.x, dd.y))); } return r; }
void main() { vec2 b = boxUV(here()); int N = int(p_dvN + 0.5); if (N < 1) N = 3; float km2PerUnit2 = pow(40075.0 / 1920.0, 2.0); float unit = p_alanBiri < 0.5 ? 1e6 : p_alanBiri < 1.5 ? 1.0 : 100.0; float M = 1e-6; float vals[4];
  for (int i = 0; i < 4; i++) { vals[i] = p_dvN > 0.5 ? p_dv[i] * km2PerUnit2 * unit : (3.0 - float(i)) * 1000.0; if (i < N) M = max(M, vals[i]); }
  vec4 col = vec4(0.04, 0.06, 0.12, 0.85); for (int i = 0; i < 4; i++) { if (i >= N) break; float y0 = float(i) / float(N); float w = vals[i] / M * 0.6; if (b.y > y0 + 0.1 / float(N) && b.y < y0 + 0.8 / float(N) && b.x > 0.05 && b.x < 0.05 + w) col = vec4(hsv2rgb(vec3(float(i) * 0.17 + 0.55, 0.6, 0.95)), 1.0);
    if (p_alanEtik > 0.5) { int iv = int(vals[i] + 0.5); int nd = 1; int t = iv; for (int k = 0; k < 8; k++) { if (t < 10) break; t /= 10; nd++; } t = iv; vec2 lp = (b - vec2(0.1 + w, y0 + 0.45 / float(N))) * boxU() / (boxU().y / float(N) * 0.25); float nm = 0.0;
      for (int k = 0; k < 9; k++) { if (k >= nd) break; nm = max(nm, seg7(lp - vec2(float(nd - 1 - k) * 1.1, 0.0), t % 10)); t /= 10; } col = overPre(vec4(1.0) * nm, col); } }
  o = col; }
//== remesh
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_hucreBoyu, p_yontem, p_boslukKapa;
float rA(vec2 xy) { float C = max(p_hucreBoyu, 0.5) * 2.0; vec2 c = (floor(xy / C) + 0.5) * C; float a = cardA(c); if (p_boslukKapa > 0.5) { float n = 0.0; for (int i = 0; i < 4; i++) n += cardA(c + vec2(cos(float(i) * 1.57), sin(float(i) * 1.57)) * C); a = max(a, step(3.5, n * 1.0 + 0.0)); } return a; }
float sdf(vec3 p) { float C = max(p_hucreBoyu, 0.5) * 2.0; vec2 c = (floor(p.xy / C) + 0.5) * C; float on = step(0.5, rA(p.xy)); vec3 dd = abs(p - vec3(c, 0.0)) - vec3(C * 0.5, C * 0.5, p_yontem < 0.5 ? C * 0.5 * 2.0 : 8.0); float d = length(max(dd, 0.0)) + min(max(dd.x, max(dd.y, dd.z)), 0.0); return on > 0.5 ? d : max(C * 0.5, cardD(p, 20.0)); }
vec4 surf(vec3 p, vec3 n) { float C = max(p_hucreBoyu, 0.5) * 2.0; vec2 f = abs(fract(p.xy / C) - 0.5); vec4 c = cardSurf(vec3((floor(p.xy / C) + 0.5) * C, 0.0), vec3(0.0, 0.0, 1.0)); c.rgb *= 1.0 - (1.0 - smoothstep(0.42, 0.48, max(f.x, f.y))) * 0.0 - smoothstep(0.44, 0.5, max(f.x, f.y)) * 0.35; return c; }
void main() { o = render3d(vec3(0.0)); }
//== weldedges
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_mesafe;
float wA(vec2 xy) { float g = max(p_mesafe * 4.0, 0.01); vec2 c = floor(xy / g + 0.5) * g; return mix(cardA(xy), cardA(c), step(0.02, p_mesafe)); }
float sdf(vec3 p) { float d2 = (0.5 - wA(p.xy)) * 6.0; vec2 w = vec2(d2, abs(p.z) - 10.0); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== text3d
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_metinBmp, s_model; uniform float p_metinBmpOn, p_modelOn, p_kabarti, p_egriAral;
float txt(vec3 p) { vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; b.y = (b.y - 0.5) * 3.0 + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return p_metinBmpOn > 0.5 ? texture(s_metinBmp, b).a : 0.0; }
float sdf(vec3 p) { float base = cardD(p, 16.0); float t = txt(p); float h = p_kabarti * 1.5 + 0.5; vec2 w = vec2((0.5 - t) * 4.0, abs(p.z - 8.0 - h * 0.5) - h * 0.5); float d = min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); return min(base, d); }
vec4 surf(vec3 p, vec3 n) { if (p.z > 8.2 && txt(p) > 0.5) return vec4(vec3(0.95, 0.85, 0.3), 1.0); return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== regiondata
INCLUDE(_chart)
uniform sampler2D t_world_id, t_world_b, s_bolgeGeom; uniform float p_bolgeGeomOn, p_siniflan, p_renkSiniSayi; uniform vec3 c_palet;
// her satır: "ülke kodu (ISO 3166 sayısal), değer" — ör. 792, 85 (Türkiye)
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = clamp(boxUV(here()), 0.0, 0.9999); ivec2 ts = textureSize(t_world_id, 0); vec3 idc = texelFetch(t_world_id, ivec2(b * vec2(ts)), 0).rgb; int code = int(idc.r * 255.0 + 0.5) * 256 + int(idc.g * 255.0 + 0.5);
  vec4 base = p_bolgeGeomOn > 0.5 ? texture(s_bolgeGeom, b) : vec4(mix(vec3(0.08, 0.14, 0.26), vec3(0.85), step(0.5, idc.b)), 1.0); if (idc.b < 0.5) { o = base; return; }
  float R = dR(); float mn = 1e9, mx = -1e9; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; mn = min(mn, dat(float(r), 1.0)); mx = max(mx, dat(float(r), 1.0)); }
  float val = -1e9; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; if (int(dat(float(r), 0.0) + 0.5) == code) val = dat(float(r), 1.0); }
  if (p_dvR < 0.5) val = mod(float(code) * 7.3, 100.0), mn = 0.0, mx = 100.0;
  vec4 c = base; if (val > -1e8) { float k = clamp((val - mn) / max(mx - mn, 1e-6), 0.0, 0.999); float N = max(floor(p_renkSiniSayi), 2.0);
    if (p_siniflan > 0.5 && p_siniflan < 1.5) { float below = 0.0, tot = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; tot += 1.0; below += step(dat(float(r), 1.0), val); } k = clamp(below / max(tot, 1.0) - 1e-3, 0.0, 0.999); }
    float cls = floor(k * N) / max(N - 1.0, 1.0); c = vec4(mix(vec3(0.97, 0.97, 0.95), c_palet * 0.55, cls), 1.0); }
  float border = texture(t_world_b, b).r; o = overPre(vec4(0.2, 0.2, 0.25, 1.0) * border * 0.8, c); }
//== markedsep
uniform sampler2D s_onIsaret, s_arkaIsaret; uniform float p_onIsaretOn, p_arkaIsaretOn, p_yineleme, p_yumusatm;
void main() { vec4 s = texture(u_tex, v_uv); if (p_onIsaretOn < 0.5 || p_arkaIsaretOn < 0.5) { o = s; return; } vec3 fg = vec3(0.0), bg = vec3(0.0); float nf = 0.0, nb = 0.0;
  for (int j = 0; j < 12; j++) for (int i = 0; i < 12; i++) { vec2 uv = (vec2(i, j) + 0.5) / 12.0; vec3 c = unpre(texPx(boxPx(uv))); float f = texture(s_onIsaret, uv).a, b = texture(s_arkaIsaret, uv).a; fg += c * f; nf += f; bg += c * b; nb += b; }
  fg /= max(nf, 1e-3); bg /= max(nb, 1e-3); float R = max(p_yumusatm, 0.5) * u_s; float acc = 0.0; int K = int(clamp(p_yineleme, 1.0, 30.0)); int S = min(16, 4 + K);
  for (int i = 0; i < 16; i++) { if (i >= S) break; float a = float(i) * 2.39996; float r = R * sqrt(float(i) / float(S)); vec3 c = unpre(texPx(here() + vec2(cos(a), sin(a)) * r)); acc += step(length(c - fg), length(c - bg)); }
  float m = acc / float(S); vec2 b0 = clamp(boxUV(here()), 0.0, 1.0); m = max(m, texture(s_onIsaret, b0).a); m = min(m, 1.0 - texture(s_arkaIsaret, b0).a); o = s * smoothstep(0.3, 0.7, m); }
//== conformsurface
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_hedef; uniform float p_hedefOn, p_ofset, p_projeksiYonu, p_azamiProjUzak;
float H(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; float h = p_hedefOn > 0.5 ? luma(unpre(texture(s_hedef, clamp(b, 0.0, 1.0)))) : 0.5 + 0.5 * sin(xy.x * 0.03) * cos(xy.y * 0.03); return (h - 0.5) * p_azamiProjUzak * (p_projeksiYonu > 0.5 ? -1.0 : 1.0) + p_ofset; }
float sdf(vec3 p) { return cardD(p - vec3(0.0, 0.0, H(p.xy)), 8.0) * 0.5; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== envelopewarp
uniform sampler2D s_kaynakAg; uniform float p_kaynakAgOn, p_bagGucu;
void main() { vec2 b = boxUV(here()); if (p_kaynakAgOn < 0.5) { o = texture(u_tex, v_uv); return; } float L = 1.0, R = 0.0; for (int i = 0; i < 48; i++) { float x = (float(i) + 0.5) / 48.0; if (texture(s_kaynakAg, vec2(x, b.y)).a > 0.5) { L = min(L, x); R = max(R, x); } }
  if (R <= L) { o = vec4(0.0); return; } float u = (b.x - L) / max(R - L, 1e-3); if (u < 0.0 || u > 1.0) { o = mix(texture(u_tex, v_uv), vec4(0.0), p_bagGucu / 100.0); return; } vec2 src = vec2(mix(b.x, u, p_bagGucu / 100.0), b.y); o = texPx(boxPx(src)); }
