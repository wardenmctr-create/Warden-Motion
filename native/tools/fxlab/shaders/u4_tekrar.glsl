// Güncelleme: Tekrar ortak ayarları (277–284)
//== gridrepeat
INCLUDE(_rep)
uniform float p_sutun, p_satir, p_aralikX, p_aralikY, p_kopyaOlce, p_kopyaAcis, p_satirKaym, p_aynala; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); vec2 sp = vec2(max(p_aralikX, 1.0), max(p_aralikY, 1.0)); vec4 res = vec4(0.0); float sc = max(p_kopyaOlce / 100.0, 0.01);
  vec2 rel = q - p_merkez; vec2 g0 = floor(rel / sp + (n - 1.0) * 0.5 + 0.5);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = g0 + vec2(float(i), float(j)); if (any(lessThan(id, vec2(0.0))) || any(greaterThanEqual(id, n))) continue;
    float k = id.y * n.x + id.x;
    vec2 c = p_merkez + (id - (n - 1.0) * 0.5) * sp + vec2(mod(id.y, 2.0) * p_satirKaym, 0.0); vec2 l = repL(rot2(-p_kopyaAcis) * (q - c) / sc, k);
    if (p_aynala > 0.5 && mod(id.x + id.y, 2.0) > 0.5) l.x = -l.x; res = rov(res, repC(texU(l), k)); }
  o = res;
}
//== linrepeat
INCLUDE(_rep)
uniform float p_kopyaSayi, p_adimX, p_adimY, p_olcekAdim, p_donusAdim, p_opaklikAdim, p_orijinalGost;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 64.0));
  for (int i = 63; i >= 0; i--) { if (i >= N) continue; if (i == 0 && p_orijinalGost < 0.5) continue; float k = float(i); float sc = max(1.0 + p_olcekAdim / 100.0 * k, 0.01);
    vec2 c = vec2(p_adimX, p_adimY) * k; vec2 l = repL(rot2(-p_donusAdim * k) * (q - c) / sc, k); float op = clamp(1.0 + p_opaklikAdim / 100.0 * k, 0.0, 1.0); res = rov(repC(texU(l) * op, k), res); }
  o = res;
}
//== radrepeat
INCLUDE(_rep)
uniform float p_kopyaSayi, p_yaricap, p_baslangiAcis, p_yay, p_kopyaOlce, p_radyalDond, p_orijinalGost; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec4 res = p_orijinalGost > 0.5 ? texU(q) : vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 64.0)); float sc = max(p_kopyaOlce / 100.0, 0.01);
  float full = abs(abs(p_yay) - 360.0) < 0.5 ? 1.0 : 0.0;
  for (int i = 0; i < 64; i++) { if (i >= N) break; float k = float(i); float a = p_baslangiAcis + p_yay * k / max(float(N) - full, 1.0); vec2 c = p_merkez + vec2(cos(radians(a)), sin(radians(a))) * p_yaricap;
    vec2 l = (q - c); if (p_radyalDond > 0.5) l = rot2(-(a + 90.0)) * l; l = repL(l / sc, k); res = rov(repC(texU(l), k), res); }
  o = res;
}
//== scatter
INCLUDE(_rep)
uniform float p_kopyaSayi, p_alanX, p_alanY, p_olcekDegi, p_aciDegi, p_tohum, p_cakismayAzal; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 96.0));
  for (int i = 0; i < 96; i++) { if (i >= N) break; float k = float(i); vec2 h = hash2(vec2(k, seedf(p_tohum))); vec2 h2 = hash2(vec2(k + 0.3, seedf(p_tohum) + 5.0));
    vec2 c = p_merkez + (h - 0.5) * vec2(p_alanX, p_alanY); float sc = max(1.0 - p_olcekDegi / 100.0 * h2.x, 0.05) * 0.5; vec2 l = repL(rot2(-(h2.y - 0.5) * 2.0 * p_aciDegi) * (q - c) / sc, k);
    res = rov(repC(texU(l), k), res); }
  o = res;
}
//== spiral
INCLUDE(_rep)
uniform float p_kopyaSayi, p_icYari, p_disYari, p_tur, p_olcekAdim, p_yolaDond; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 96.0));
  for (int i = 0; i < 96; i++) { if (i >= N) break; float k = float(i); float t = k / max(float(N) - 1.0, 1.0); float a = t * p_tur * TAU; float r = mix(p_icYari, p_disYari, t);
    vec2 c = p_merkez + vec2(cos(a), sin(a)) * r; float sc = max(0.3 * (1.0 + p_olcekAdim / 100.0 * k), 0.01); vec2 l = q - c; if (p_yolaDond > 0.5) l = rot2(-degrees(a) - 90.0) * l; res = rov(repC(texU(repL(l / sc, k)), k), res); }
  o = res;
}
//== mirrorrepeat
INCLUDE(_rep)
uniform float p_eksen, p_eksenAcis, p_mesafe, p_kopyaOpak, p_orijinalGost; uniform vec2 p_aynaCizg;
void main() {
  vec2 q = toUnit(here()); float a = p_eksen < 0.5 ? 90.0 : p_eksen < 1.5 ? 0.0 : p_eksenAcis + 90.0; vec2 d = vec2(cos(radians(a)), sin(radians(a))); vec2 n = vec2(-d.y, d.x);
  vec2 L = p_aynaCizg + n * (p_mesafe * 0.5); float s = dot(q - L, n); vec2 m = q - 2.0 * s * n;
  vec4 copy = repC(texU(repL(m, 1.0)), 1.0) * p_kopyaOpak / 100.0; vec4 orig = p_orijinalGost > 0.5 ? texU(q) : vec4(0.0); o = rov(orig, copy);
}
//== repeatpath
INCLUDE(_rep)
uniform float p_yol, p_kopyaSayi, p_boyutX, p_boyutY, p_baslangi, p_bitis, p_yolaDond, p_kapaliYol;
vec2 pathAt(float t) { float a = t * TAU; vec2 S = vec2(p_boyutX, p_boyutY) * 0.5;
  if (p_yol < 0.5 || p_yol > 3.5) return vec2(cos(a), sin(a)) * S; if (p_yol < 1.5) return vec2((t * 2.0 - 1.0), sin(a * 1.5)) * S;
  if (p_yol < 2.5) return vec2(pow(sin(a), 3.0), -(13.0 * cos(a) - 5.0 * cos(2.0 * a) - 2.0 * cos(3.0 * a) - cos(4.0 * a)) / 16.0) * S;
  float k = floor(t * 10.0); float f = fract(t * 10.0); float r0 = mod(k, 2.0) < 0.5 ? 1.0 : 0.45, r1 = mod(k, 2.0) < 0.5 ? 0.45 : 1.0; float a0 = k / 10.0 * TAU - PI * 0.5, a1 = (k + 1.0) / 10.0 * TAU - PI * 0.5;
  return mix(vec2(cos(a0), sin(a0)) * r0, vec2(cos(a1), sin(a1)) * r1, f) * S; }
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 96.0)); float closed = p_kapaliYol > 0.5 && (p_yol < 0.5 || p_yol > 1.5) ? 1.0 : 0.0;
  for (int i = 0; i < 96; i++) { if (i >= N) break; float k = float(i); float t = mix(p_baslangi, p_bitis, k / max(float(N) - (closed > 0.5 ? 0.0 : 1.0), 1.0)) / 100.0; vec2 c = pathAt(t);
    vec2 l = q - c; if (p_yolaDond > 0.5) { vec2 tg = pathAt(t + 0.002) - pathAt(t - 0.002); l = rot2(-degrees(atan(tg.y, tg.x))) * l; } res = rov(repC(texU(repL(l / 0.3, k)), k), res); }
  o = res;
}
//== scatterfield
INCLUDE(_rep)
uniform float p_yogunluk, p_alanX, p_alanY, p_enKucuOlce, p_enBuyuOlce, p_hiz, p_yon, p_tohum, p_sarmala, p_rastgeleDon;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); vec2 A = vec2(max(p_alanX, 10.0), max(p_alanY, 10.0)); float cell = sqrt(A.x * A.y / max(p_yogunluk, 1.0)); vec2 dir = vec2(cos(radians(p_yon)), sin(radians(p_yon)));
  vec2 p = q - dir * p_hiz * u_t; if (p_sarmala > 0.5) p = mod(p + A * 0.5, A) - A * 0.5; vec2 id = floor(p / cell);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(float(i), float(j)); vec2 h = hash2(c + seedf(p_tohum)); vec2 h2 = hash2(c + 3.7); float k = mod(c.x * 7.0 + c.y * 13.0, 97.0);
    vec2 cp = (c + h) * cell; float sc = mix(p_enKucuOlce, p_enBuyuOlce, h2.x) / 100.0; vec2 l = p - cp; if (p_rastgeleDon > 0.5) l = rot2(-h2.y * 360.0) * l; res = rov(res, repC(texU(repL(l / max(sc, 0.01), k)), k)); }
  o = res;
}
