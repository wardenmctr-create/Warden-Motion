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
