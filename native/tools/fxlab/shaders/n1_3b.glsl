// Bölüm C: yeni 3B efektler (ortak 3B paneli _3d ile)
//== globe3d
INCLUDE(_3d)
uniform sampler2D t_world_a, t_world_b, s_ozelHari; uniform float p_ozelHariOn;
uniform float p_buyukluk, p_eksenEgik, p_enlem, p_boylam, p_basiklik, p_harita, p_ulkeSini, p_sinirKali, p_atmosfer, p_atmosferKali, p_bulutlar, p_bulutYogu, p_bulutHizi, p_geceIsik, p_okyanusYans;
uniform vec3 c_sinirReng, c_atmosferReng;
float R0() { return max(p_buyukluk * 0.5, 2.0); }
float sdf(vec3 p) { float f = 1.0 - p_basiklik / 100.0; return (length(p * vec3(1.0, 1.0 / f, 1.0)) - R0()) * f; }
vec3 earthDir(vec3 p) { vec3 d = normalize(p); d = rotXYZ(vec3(0.0, 0.0, p_eksenEgik)) * d; d = rotXYZ(vec3(-p_enlem, 0.0, 0.0)) * d; d = rotXYZ(vec3(0.0, p_boylam, 0.0)) * d; return d; }
vec2 llUV(vec3 d) { return vec2(atan(d.x, d.z) / TAU + 0.5, 0.5 - asin(clamp(d.y, -1.0, 1.0)) / PI); }
vec4 surf(vec3 p, vec3 n) {
  vec3 d = earthDir(p); vec2 uv = llUV(d); vec4 A = texture(t_world_a, uv); vec4 Bm = texture(t_world_b, uv);
  float land = A.a * (1.0 - Bm.b); vec3 pol = A.a > 0.0 ? A.rgb / A.a : vec3(0.0); float lat = abs(d.y);
  vec3 ocean = mix(vec3(0.06, 0.24, 0.52), vec3(0.03, 0.12, 0.32), smoothstep(0.0, 0.8, lat)); vec3 col;
  float det = fbm01(uv * vec2(80.0, 40.0), 4.0);
  vec3 phys = mix(mix(vec3(0.20, 0.45, 0.18), vec3(0.62, 0.52, 0.32), smoothstep(0.15, 0.4, lat) * smoothstep(0.62, 0.42, lat) + det * 0.25), vec3(0.95), smoothstep(0.72, 0.85, lat));
  if (p_harita < 0.5) col = mix(ocean * 1.1, pol, land);
  else if (p_harita < 1.5) col = mix(ocean, phys, land);
  else if (p_harita < 2.5) col = mix(ocean * 0.8, phys * (0.75 + det * 0.4), land);
  else if (p_harita < 3.5) col = mix(vec3(0.01, 0.02, 0.05), vec3(0.04, 0.05, 0.07), land) + vec3(1.0, 0.75, 0.4) * Bm.g * 1.4;
  else col = p_ozelHariOn > 0.5 ? unpre(texture(s_ozelHari, uv)) : mix(ocean, phys, land);
  if (p_ulkeSini > 0.5) { float w = max(p_sinirKali, 0.0) / 2048.0; float b = Bm.r; for (int i = 0; i < 4; i++) { vec2 o = vec2(cos(float(i) * 1.57), sin(float(i) * 1.57)) * w; b = max(b, texture(t_world_b, uv + o).r); } col = mix(col, c_sinirReng, clamp(b * 1.4, 0.0, 1.0) * step(0.001, p_sinirKali + 1e-3)); }
  float ocn = 1.0 - land; vec3 Ld = normalize(vec3(-p_isikKonu.x, p_isikKonu.y, -p_isikKonu.z) * -1.0 + vec3(0.0, 0.0, 1e-3));
  col += vec3(pow(max(dot(reflect(-normalize(vec3(0.3, 0.5, 1.0)), n), vec3(0.0, 0.0, 1.0)), 0.0), 24.0)) * ocn * p_okyanusYans / 100.0;
  if (p_bulutlar > 0.5) { vec2 cu = uv + vec2(u_t * p_bulutHizi / 360.0, 0.0); float cl = smoothstep(0.55 - p_bulutYogu / 250.0, 0.85, fbm01(cu * vec2(24.0, 12.0), 5.0) + 0.1); col = mix(col, vec3(1.0), cl * 0.85); }
  if (p_geceIsik > 0.5 && p_harita < 2.5) { float dark = smoothstep(0.1, -0.3, dot(n, normalize(vec3(-0.6, 0.4, 0.7)))); col += vec3(1.0, 0.75, 0.4) * Bm.g * dark * 1.5; }
  return vec4(col, 1.0);
}
void main() {
  vec4 c = render3d(vec3(0.0));
  if (p_atmosfer > 0.5) { vec2 q = toUnit(here()) - p_konumXY.xy; float r = length(q) / (R0() * objScale().x); float th = p_atmosferKali / 100.0;
    float halo = smoothstep(1.0 + th * 2.5, 1.0, r) * step(0.98, r) * 0.9 + smoothstep(1.0 - th * 2.0, 1.0, r) * step(r, 1.0) * 0.5; c = overPre(vec4(c_atmosferReng, 1.0) * halo * step(0.0001, th), c); }
  o = c;
}
//== planet3d
INCLUDE(_3d)
uniform float p_gezegenTuru, p_buyukluk, p_yuzeyAyri, p_kraterYogu, p_kraterBuyu, p_yuzeyYuks, p_bulutSeriSayi, p_firtinaYogu, p_atmosferKali, p_tohum; uniform vec3 c_anaRenk, c_ikinciRenk, c_atmosferReng;
float R0() { return max(p_buyukluk * 0.5, 2.0); }
vec2 sph(vec3 p) { vec3 d = normalize(p); return vec2(atan(d.x, d.z) / TAU + 0.5, asin(clamp(d.y, -1.0, 1.0)) / PI + 0.5); }
float crater(vec2 uv) { if (p_kraterYogu <= 0.0) return 0.0; float sc = max(R0() * 2.0 / max(p_kraterBuyu, 1.0), 1.0); vec4 v = voronoi(uv * vec2(2.0, 1.0) * sc + seedf(p_tohum));
  float keep = step(hash1(v.zw + 3.1), p_kraterYogu / 100.0); float r = 0.35 + 0.3 * hash1(v.zw); float x = v.x / r; return keep * (x < 1.0 ? (x * x - 0.7) : smoothstep(1.4, 1.0, x) * 0.3); }
float hgt(vec3 p) { if (p_gezegenTuru > 0.5 && p_gezegenTuru < 1.5) return 0.0; vec2 uv = sph(p); return (fbm01(uv * vec2(12.0, 6.0) + seedf(p_tohum), 4.0) - 0.5) * p_yuzeyAyri / 100.0 + crater(uv) * 0.6; }
float sdf(vec3 p) { return length(p) - R0() - hgt(p) * R0() * p_yuzeyYuks / 100.0 * 0.4; }
vec4 surf(vec3 p, vec3 n) {
  vec2 uv = sph(p); float sd = seedf(p_tohum); float k = p_gezegenTuru; vec3 c;
  if (k > 0.5 && k < 1.5) { float y = uv.y * max(p_bulutSeriSayi, 1.0); float w = fbm01(vec2(uv.x * 6.0 + u_t * 0.01, uv.y * 40.0) + sd, 4.0); float b = sin((y + w * 0.6) * PI) * 0.5 + 0.5;
    c = mix(c_anaRenk, c_ikinciRenk, b); vec2 st = vec2(fract(uv.x * 3.0 + sd), uv.y) - vec2(0.5, 0.38); float spot = smoothstep(0.08, 0.0, length(st * vec2(1.0, 2.2))) * step(0.3, p_firtinaYogu / 100.0); c = mix(c, c_ikinciRenk * 0.7, spot); }
  else { float h = hgt(p); float f = fbm01(uv * vec2(16.0, 8.0) + sd * 1.7, 5.0); c = mix(c_anaRenk, c_ikinciRenk, smoothstep(0.35, 0.7, f));
    if (k > 1.5 && k < 2.5) c = mix(vec3(0.85, 0.93, 1.0), c_anaRenk, f * 0.5);
    if (k > 3.5 && k < 4.5) c = mix(c_anaRenk * 0.5, c_ikinciRenk * 1.6, smoothstep(0.62, 0.66, f) + smoothstep(0.02, 0.0, abs(fract(f * 7.0) - 0.5) - 0.45) * 0.0);
    if (k > 4.5) c = mix(vec3(0.05, 0.2, 0.55), mix(c_anaRenk, c_ikinciRenk, f), smoothstep(0.55, 0.6, f));
    c *= 0.85 + h * 0.6; }
  return vec4(c, 1.0);
}
void main() { vec4 c = render3d(vec3(0.0)); vec2 q = toUnit(here()) - p_konumXY.xy; float r = length(q) / (R0() * objScale().x); float th = p_atmosferKali / 100.0;
  float halo = (smoothstep(1.0 + th * 2.5, 1.0, r) * step(0.98, r) * 0.8 + smoothstep(1.0 - th * 2.0, 1.0, r) * step(r, 1.0) * 0.45) * step(0.0001, th); o = overPre(vec4(c_atmosferReng, 1.0) * halo, c); }
//== ringplanet
INCLUDE(_3d)
uniform float p_gezegenGovd, p_gezegenBuyu, p_icHalkYari, p_disHalkYari, p_halkaSayi, p_halkaBosl, p_halkaKali, p_parcacikYogu, p_halkaOpak, p_donusHizi, p_karsilikGolg; uniform vec3 p_halkaEgim, c_anaRenk, c_ikinciRenk;
float Rp() { return max(p_gezegenBuyu * 0.5, 2.0); }
vec3 ringP(vec3 p) { return rotXYZ(-p_halkaEgim) * p; }
float ringD(vec3 p) { vec3 r = ringP(p); float ri = Rp() * p_icHalkYari / 100.0, ro = Rp() * max(p_disHalkYari, p_icHalkYari + 1.0) / 100.0; float l = length(r.xz); return max(abs(r.y) - max(p_halkaKali * 0.5, 0.3), max(ri - l, l - ro)); }
float sdf(vec3 p) { float s = p_gezegenGovd > 0.5 ? length(p) - Rp() : 1e5; return min(s, ringD(p)); }
float ringA(vec3 p) { vec3 r = ringP(p); float ri = Rp() * p_icHalkYari / 100.0, ro = Rp() * max(p_disHalkYari, p_icHalkYari + 1.0) / 100.0; float x = clamp((length(r.xz) - ri) / max(ro - ri, 1.0), 0.0, 1.0);
  float N = max(p_halkaSayi, 1.0); float band = fract(x * N); float gap = step(band, 1.0 - p_halkaBosl / 100.0); float id = floor(x * N);
  float grain = mix(1.0, vnoise(vec2(x * 300.0, atan(r.z, r.x) * 40.0 + u_t * p_donusHizi * 0.05)), 1.0 - p_parcacikYogu / 100.0);
  return gap * (0.55 + 0.45 * hash1(vec2(id, 7.0))) * grain * smoothstep(0.0, 0.02, x) * smoothstep(1.0, 0.98, x); }
vec4 surf(vec3 p, vec3 n) { vec3 L = normalize(vec3(-0.6, 0.5, 0.6));
  if (ringD(p) < 0.6 && !(p_gezegenGovd > 0.5 && length(p) - Rp() < 0.6)) { vec3 r = ringP(p); float x = length(r.xz) / Rp(); vec3 c = mix(c_anaRenk, c_ikinciRenk, fract(x * 3.7) * 0.6);
    float sh = 1.0; if (p_karsilikGolg > 0.5 && p_gezegenGovd > 0.5) { float b = dot(p, L); vec3 cl = p - L * b; sh = (b < 0.0 && length(cl) < Rp()) ? 0.25 : 1.0; }
    return vec4(c * sh, ringA(p) * p_halkaOpak / 100.0); }
  vec3 d = normalize(p); float lat = d.y; float b = sin((lat * 6.0 + fbm01(vec2(atan(d.x, d.z) * 2.0, lat * 20.0), 3.0) * 0.4) * PI * 2.0) * 0.5 + 0.5; vec3 c = mix(c_anaRenk, c_ikinciRenk, b * 0.5);
  if (p_karsilikGolg > 0.5) { vec3 rp = ringP(p); vec3 rl = ringP(L); float t = -rp.y / (abs(rl.y) > 1e-3 ? rl.y : 1e-3); if (t > 0.0) { vec3 h = p + L * t; float a = ringA(h); c *= 1.0 - a * 0.6 * p_halkaOpak / 100.0; } }
  return vec4(c, 1.0); }
void main() { o = render3d(vec3(0.0, u_t * p_donusHizi * 0.0, 0.0)); }
//== flagpole3d
INCLUDE(_3d)
uniform sampler2D s_bayrakKatm, s_bayrakGors; uniform float p_bayrakKatmOn, p_bayrakGorsOn;
uniform vec2 p_bayrakBoyu; uniform float p_enBoyOran, p_sabitKena, p_dalgaYuks, p_dalgaBoyu, p_ruzgarHizi, p_kumasSert, p_diregiGost, p_direkYuks, p_direkKali, p_direkMalz, p_direkTepe, p_bayraginYuks, p_baglantiIpi, p_ipKali; uniform vec3 c_direkReng;
vec2 FS() { vec2 s = max(p_bayrakBoyu, vec2(10.0)); if (p_enBoyOran > 0.5) s.y = s.x * boxU().y / max(boxU().x, 1.0); return s; }
float poleX() { return -FS().x * 0.5; }
float topY() { return p_direkYuks * 0.5; }
float flagW(float u) { return sin(TAU * (u * FS().x / max(p_dalgaBoyu, 1.0) - p_ruzgarHizi * u_t)) * p_dalgaYuks * pow(u, mix(0.6, 1.6, p_kumasSert / 100.0)); }
vec3 flagLocal(vec3 p) { float y0 = topY() - FS().y * 0.5 - (topY() * 2.0 - FS().y) * (1.0 - p_bayraginYuks / 100.0); return vec3(p.x - poleX(), p.y - y0, p.z); }
float flagD(vec3 p) { vec3 f = flagLocal(p); float u = clamp(f.x / FS().x, 0.0, 1.0); float z = f.z - flagW(u); vec3 b = vec3(FS().x * 0.5, FS().y * 0.5, 0.8); vec3 q = abs(vec3(f.x - FS().x * 0.5, f.y, z)) - b; return (length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0)) * 0.6; }
float poleD(vec3 p) { if (p_diregiGost < 0.5) return 1e5; vec3 c = p - vec3(poleX() - p_direkKali * 0.5, 0.0, 0.0); float r = p_direkKali * 0.5; float d = max(length(c.xz) - r, abs(c.y) - p_direkYuks * 0.5);
  vec3 tp = c - vec3(0.0, topY() + r * 1.2, 0.0); if (p_direkTepe < 0.5) d = min(d, length(tp) - r * 1.6); else if (p_direkTepe < 1.5) d = min(d, max(length(tp.xz) - r * 1.5, abs(tp.y) - r * 0.4)); else if (p_direkTepe < 2.5) d = min(d, max(length(tp.xz) - r * (1.2 - (tp.y + r) / (r * 4.0)) * 1.2, abs(tp.y) - r * 2.0));
  if (p_baglantiIpi > 0.5) { vec3 rp = c - vec3(r * 1.6, 0.0, 0.0); d = min(d, max(length(rp.xz) - max(p_ipKali * 0.5, 0.3), abs(rp.y) - p_direkYuks * 0.48)); } return d; }
float sdf(vec3 p) { return min(flagD(p), poleD(p)); }
vec4 surf(vec3 p, vec3 n) { if (flagD(p) < poleD(p)) { vec3 f = flagLocal(p); vec2 uv = vec2(f.x / FS().x, 0.5 - f.y / FS().y);
    vec4 c = p_bayrakKatmOn > 0.5 ? texture(s_bayrakKatm, clamp(uv, 0.0, 1.0)) : p_bayrakGorsOn > 0.5 ? texture(s_bayrakGors, clamp(uv, 0.0, 1.0)) : layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.9), 1.0); }
  vec3 pc = c_direkReng; if (p_direkMalz > 0.5 && p_direkMalz < 1.5) pc *= 0.8 + 0.3 * vnoise(vec2(p.y * 0.08, atan(p.x, p.z) * 3.0)); return vec4(pc, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== book3d
INCLUDE(_3d)
uniform sampler2D s_onKapaGors, s_arkaKapaGors, s_kitapSirtGors, s_sayfaGors; uniform float p_onKapaGorsOn, p_arkaKapaGorsOn, p_kitapSirtGorsOn, p_sayfaGorsOn;
uniform vec2 p_kitapBoyu; uniform float p_kalinlik, p_sayfaSayi, p_kapakKali, p_acilmaAcis, p_acikSayf, p_sayfaCevi, p_sayfaKivr, p_sayfaSert, p_sayfaCizg, p_sayfaGolg; uniform vec3 c_sayfaReng;
vec2 BS() { return max(p_kitapBoyu, vec2(10.0)); }
float boxd(vec3 p, vec3 b) { vec3 q = abs(p) - b; return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0); }
// Arka yarı sabit: x∈[0,W], kapak z∈[-T,-T+k], sayfalar z∈[-T+k,0]. Ön yarı sırt (x=0) etrafında açılma açısı kadar döner ve aynalanır.
float A_() { return radians(clamp(p_acilmaAcis, 0.0, 180.0)); }
vec3 toHalf(vec3 p, float side) { float a = A_() * 0.5; if (side > 0.0) a -= A_(); vec3 q = p; q.xz = mat2(cos(a), -sin(a), sin(a), cos(a)) * q.xz; if (side > 0.0) q.z = -q.z; return q; }
float halfD(vec3 p, float side, out float isPage) { float T = max(p_kalinlik, 2.0) * 0.5; float k = max(p_kapakKali, 0.5); vec3 q = toHalf(p, side); float W = BS().x;
  float cover = boxd(q - vec3(W * 0.5, 0.0, -T + k * 0.5), vec3(W * 0.5, BS().y * 0.5, k * 0.5));
  float curl = p_sayfaKivr / 100.0 * T * 0.5 * sin(clamp(q.x / W, 0.0, 1.0) * PI) * step(1.0, p_acilmaAcis);
  float pages = boxd(q - vec3(W * 0.5 - 1.5, 0.0, (-T + k) * 0.5 + curl * 0.5), vec3(W * 0.5 - 2.5, BS().y * 0.5 - 3.0, max((T - k) * 0.5 + curl * 0.5, 0.3)));
  isPage = step(pages, cover); return min(cover, pages); }
float sdf(vec3 p) { float a, b; float T = max(p_kalinlik, 2.0) * 0.5; vec3 sp = p; sp.xz = mat2(cos(A_() * 0.5), -sin(A_() * 0.5), sin(A_() * 0.5), cos(A_() * 0.5)) * sp.xz;
  float spine = boxd(sp - vec3(-max(p_kapakKali, 0.5) * 0.5, 0.0, 0.0), vec3(max(p_kapakKali, 0.5) * 0.5, BS().y * 0.5, T)) ;
  return min(p_acilmaAcis < 1.0 ? spine : 1e5, min(halfD(p, 1.0, a), halfD(p, -1.0, b))); }
vec4 surf(vec3 p, vec3 n) { float pg1, pg2; float d1 = halfD(p, 1.0, pg1), d2 = halfD(p, -1.0, pg2); float side = d1 < d2 ? 1.0 : -1.0; float pg = d1 < d2 ? pg1 : pg2;
  if (min(d1, d2) > 1.0) return vec4(c_tabanRenk * 0.7, 1.0);
  vec3 q = toHalf(p, side); vec2 uv = vec2(q.x / BS().x, 0.5 - q.y / BS().y); if (side > 0.0) uv.x = uv.x; float T = max(p_kalinlik, 2.0) * 0.5;
  if (pg > 0.5) { vec3 c = c_sayfaReng; bool top = q.z > -1.5; vec2 puv = side > 0.0 ? vec2(1.0 - uv.x, uv.y) : uv; if (top && p_sayfaGorsOn > 0.5) c = unpre(texture(s_sayfaGors, clamp(vec2(puv.x * 0.5 + (side > 0.0 ? 0.0 : 0.5), puv.y), 0.0, 1.0)));
    if (!top) c *= 0.86 + 0.14 * step(0.5, fract(q.z * 1.5)); if (top && p_sayfaCizg > 0.5) c *= 1.0 - 0.25 * step(0.92, fract(uv.y * 24.0)) * step(0.08, uv.y);
    if (p_sayfaGolg > 0.5 && top) c *= mix(0.65, 1.0, smoothstep(0.0, 0.15, uv.x)); return vec4(c, 1.0); }
  bool outer = q.z < -T + max(p_kapakKali, 0.5) * 0.5;
  vec4 c = side > 0.0 ? (p_onKapaGorsOn > 0.5 ? texture(s_onKapaGors, clamp(uv, 0.0, 1.0)) : layerAt(uv)) : (p_arkaKapaGorsOn > 0.5 ? texture(s_arkaKapaGors, clamp(vec2(1.0 - uv.x, uv.y), 0.0, 1.0)) : vec4(c_tabanRenk * 0.8, 1.0));
  if (!outer) c = vec4(c_tabanRenk * 0.6, 1.0);
  if (uv.x < 0.03 && p_kitapSirtGorsOn > 0.5) c = texture(s_kitapSirtGors, clamp(vec2(0.5, uv.y), 0.0, 1.0));
  return vec4(c.a > 0.0 ? c.rgb / c.a : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== dice3d
INCLUDE(_3d)
uniform sampler2D s_herYuzIcin; uniform float p_herYuzIcinOn;
uniform float p_yuzSayi, p_buyukluk, p_koseYuva, p_kenarPahi, p_yuzGoru, p_noktaBuyu, p_noktaDeri, p_otomatikYuva, p_yuvarlanIler, p_sicramaYuks, p_sonYuz, p_tohum; uniform vec3 c_zarReng, c_isaretReng;
float Hs() { return max(p_buyukluk * 0.5, 2.0); }
float sdf(vec3 p) { float h = Hs(); float k = p_yuzSayi;
  if (k > 0.5 && k < 1.5 || k < 0.5 && false) {}
  if (k < 0.5) { return (max(abs(p.x + p.y) - p.z, abs(p.x - p.y) + p.z) - h * 0.55) / 1.732; }
  if (k < 1.5) { float r = min(p_koseYuva, h * 0.9); vec3 q = abs(p) - vec3(h - r); return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r; }
  if (k < 2.5) { vec3 a = abs(p); return (a.x + a.y + a.z - h * 1.3) * 0.577; }
  vec3 a = abs(p); const float G = 1.618034;
  if (k < 3.5) { vec3 n1 = normalize(vec3(0.0, 1.0, G)); vec3 n2 = n1.zxy, n3 = n1.yzx; return max(max(dot(a, n1), dot(a, n2)), dot(a, n3)) - h * 0.95; }
  vec3 m1 = normalize(vec3(1.0)), m2 = normalize(vec3(0.0, 1.0 / G, G)), m3 = m2.zxy, m4 = m2.yzx; return max(max(dot(a, m1), dot(a, m2)), max(dot(a, m3), dot(a, m4))) - h * 0.92; }
float seg7(vec2 p, int d) { // 7 segment rakam
  int m[10] = int[10](63, 6, 91, 79, 102, 109, 125, 7, 127, 111); int b = m[d]; float r = 0.0;
  vec2 a[7] = vec2[7](vec2(0.0, 0.8), vec2(0.45, 0.4), vec2(0.45, -0.4), vec2(0.0, -0.8), vec2(-0.45, -0.4), vec2(-0.45, 0.4), vec2(0.0, 0.0));
  for (int i = 0; i < 7; i++) { if ((b / int(pow(2.0, float(i)))) % 2 == 0) continue; vec2 q = p - a[i]; bool hz = i == 0 || i == 3 || i == 6; vec2 e = hz ? vec2(0.36, 0.09) : vec2(0.09, 0.34); vec2 dd = abs(q) - e; r = max(r, 1.0 - smoothstep(0.0, 0.04, max(dd.x, dd.y))); } return r; }
float digits(vec2 p, int v) { if (v < 10) return seg7(p * 1.2, v); return max(seg7((p - vec2(-0.5, 0.0)) * 1.2 * 1.6, v / 10), seg7((p - vec2(0.5, 0.0)) * 1.2 * 1.6, v % 10)); }
float pips(vec2 f, int v) { float r = p_noktaBuyu / 100.0 * 0.5; float acc = 0.0;
  for (int i = 0; i < 9; i++) { vec2 c = vec2(float(i % 3) - 1.0, float(i / 3) - 1.0) * 0.55; bool on = false; int k = i;
    if (v == 1) on = k == 4; else if (v == 2) on = k == 0 || k == 8; else if (v == 3) on = k == 0 || k == 4 || k == 8; else if (v == 4) on = k == 0 || k == 2 || k == 6 || k == 8;
    else if (v == 5) on = k == 0 || k == 2 || k == 4 || k == 6 || k == 8; else on = k == 0 || k == 2 || k == 3 || k == 5 || k == 6 || k == 8;
    if (on) acc = max(acc, 1.0 - smoothstep(r * 0.85, r, length(f - c))); } return acc; }
vec4 surf(vec3 p, vec3 n) { vec3 a = abs(n); vec2 f; int face;
  if (a.x > a.y && a.x > a.z) { f = p.zy / Hs(); face = n.x > 0.0 ? 3 : 4; } else if (a.y > a.z) { f = p.xz / Hs(); face = n.y > 0.0 ? 1 : 6; } else { f = p.xy / Hs(); face = n.z > 0.0 ? 2 : 5; }
  int maxF = p_yuzSayi < 0.5 ? 4 : p_yuzSayi < 1.5 ? 6 : p_yuzSayi < 2.5 ? 8 : p_yuzSayi < 3.5 ? 12 : 20;
  if (p_yuzSayi > 1.5 || p_yuzSayi < 0.5) { vec3 d = normalize(p); face = 1 + int(mod(floor((atan(d.x, d.z) / TAU + 0.5) * 5.0) + floor((d.y * 0.5 + 0.5) * 4.0) * 5.0, float(maxF))); f = vec2(0.0); vec3 t = normalize(cross(n, vec3(0.0, 1.0, 0.01))); f = vec2(dot(p - n * dot(p, n), t), dot(p - n * dot(p, n), cross(n, t))) / Hs() * 1.6; }
  float mark = 0.0; if (p_yuzGoru < 0.5 && maxF == 6) mark = pips(f, face); else if (p_yuzGoru < 1.5 || maxF != 6) mark = digits(f * 1.2, face);
  vec3 c = c_zarReng; if (p_yuzGoru > 1.5 && p_herYuzIcinOn > 0.5 && maxF == 6) { vec2 uv = (f * 0.5 + 0.5); uv.x = (uv.x + float(face - 1)) / 6.0; c = unpre(texture(s_herYuzIcin, clamp(uv, 0.0, 1.0))); mark = 0.0; }
  c = mix(c, c_isaretReng, mark); c *= 1.0 - mark * p_noktaDeri / 20.0 * 0.3; return vec4(c, 1.0); }
void main() { vec3 ex = vec3(0.0); if (p_otomatikYuva > 0.5) { float k = clamp(p_yuvarlanIler / 100.0, 0.0, 1.0); float e = 1.0 - pow(1.0 - k, 3.0); vec2 h = hash2(vec2(seedf(p_tohum), 3.0));
    ex = vec3(720.0 + h.x * 360.0, 540.0 + h.y * 360.0, 90.0) * (1.0 - e); }
  vec4 c = render3d(ex);
  o = c; }
//== gear3d
INCLUDE(_3d)
uniform sampler2D s_baglantiDisl; uniform float p_baglantiDislOn;
uniform float p_cap, p_kalinlik, p_disSayi, p_disYuks, p_disGeni, p_merkezDeli, p_destekKoll, p_destekKoluSayi, p_donusHizi, p_baskaDislBagl, p_donusHiziDis;
float sdf(vec3 p) { float R = max(p_cap * 0.5, 4.0); float N = max(floor(p_disSayi), 3.0); float a = atan(p.y, p.x) + radians(u_t * p_donusHizi); float r = length(p.xy);
  float t = smoothstep(0.5 - p_disGeni / 200.0 - 0.08, 0.5 - p_disGeni / 200.0 + 0.08, abs(fract(a / TAU * N) - 0.5) * 2.0 * 0.5 + 0.25);
  float prof = r - (R - p_disYuks * 0.5 + p_disYuks * (1.0 - t)); float hole = (R * p_merkezDeli / 100.0) - r; float d2 = max(prof, hole);
  if (p_destekKoll > 0.5) { float M = max(floor(p_destekKoluSayi), 2.0); float sa = mod(a, TAU / M) - PI / M; float win = max(max(r - R * 0.72, R * max(p_merkezDeli / 100.0 + 0.12, 0.3) - r), abs(sa) * r - (R * 0.72 * PI / M - R * 0.1)); d2 = max(d2, -win); }
  return max(d2, abs(p.z) - max(p_kalinlik, 1.0) * 0.5); }
vec4 surf(vec3 p, vec3 n) { vec2 uv = p.xy / max(p_cap, 1.0) + 0.5; uv.y = 1.0 - uv.y; vec4 c = abs(n.z) > 0.6 ? layerAt(uv) : vec4(c_tabanRenk * 0.8, 1.0); return vec4(c.a > 0.0 ? c.rgb / c.a : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== chain3d
INCLUDE(_3d)
uniform float p_halkaSayi, p_halkaKali, p_halkaAral, p_ardisikHalkDonu, p_halkaBici, p_yol, p_sarkma, p_sallanma, p_sallanmaBuyu, p_sallanmaHizi; uniform vec2 p_halkaBoyu, p_baslangiNokt, p_bitisNokt;
float linkD(vec3 p) { vec2 S = max(p_halkaBoyu, vec2(4.0)) * 0.5; float th = max(p_halkaKali, 0.5) * 0.5; vec2 q = p.xy;
  float d2 = p_halkaBici < 0.5 ? length(vec2(max(abs(q.x) - (S.x - S.y * 0.0) * 0.0, 0.0), max(abs(q.y) - (S.y - S.x), 0.0))) - S.x + th : p_halkaBici < 1.5 ? length(q) - S.x + th : max(abs(q.x) - S.x + th, abs(q.y) - S.y + th);
  if (p_halkaBici < 0.5) { vec2 r = vec2(abs(q.x), max(abs(q.y) - (S.y - S.x), 0.0)); d2 = length(r) - (S.x - th); }
  return length(vec2(d2, p.z)) - th; }
vec2 pathPt(float s, out vec2 tg) { vec2 A = p_baslangiNokt, B = p_bitisNokt; if (length(B - A) < 1.0) { A = vec2(-boxU().x * 0.4, 0.0); B = vec2(boxU().x * 0.4, 0.0); }
  vec2 d = B - A; float L = length(d); vec2 u = d / L, nrm = vec2(-u.y, u.x); vec2 pt;
  if (p_yol < 0.5) { pt = A + u * s; tg = u; }
  else if (p_yol < 1.5) { float ang = (s / L - 0.5) * 2.0; pt = A + u * s - nrm * (1.0 - ang * ang) * L * 0.25; tg = normalize(u + nrm * ang * 2.0 * 0.25 * 2.0); }
  else if (p_yol < 2.5) { float R = L / TAU; float a = s / R; pt = (A + B) * 0.5 + vec2(cos(a), sin(a)) * R; tg = vec2(-sin(a), cos(a)); }
  else { float x = s / L * 2.0 - 1.0; float sw = p_sallanma > 0.5 ? sin(u_t * p_sallanmaHizi * TAU) * p_sallanmaBuyu : 0.0; pt = A + u * s + vec2(0.0, (1.0 - x * x) * p_sarkma) + vec2(sw * (1.0 - x * x), 0.0); tg = normalize(u + vec2(0.0, -2.0 * x / L * 2.0 * p_sarkma)); }
  return pt; }
float sdf(vec3 p) { float N = clamp(floor(p_halkaSayi), 1.0, 60.0); float sp = max(p_halkaBoyu.y - p_halkaKali * 1.5, 2.0) * (1.0 - p_halkaAral / 200.0); float d = 1e5;
  vec2 P = vec2(p.x, -p.y); float best = 1e9; float bi = 0.0;
  for (int i = 0; i < 60; i++) { if (float(i) >= N) break; vec2 tg; vec2 c = pathPt(float(i) * sp, tg); float dd = length(P - c); if (dd < best) { best = dd; bi = float(i); } }
  for (int k = -1; k <= 1; k++) { float i = bi + float(k); if (i < 0.0 || i >= N) continue; vec2 tg; vec2 c = pathPt(i * sp, tg); vec2 lq = P - c; float an = atan(tg.y, tg.x) - PI * 0.5;
    vec3 l = vec3(rot2(degrees(an)) * lq * vec2(1.0, 1.0), p.z); l.y = -l.y; float ra = radians(p_ardisikHalkDonu) * mod(i, 2.0); l.xz = mat2(cos(ra), sin(ra), -sin(ra), cos(ra)) * l.xz; d = min(d, linkD(l)); }
  return d; }
vec4 surf(vec3 p, vec3 n) { return vec4(c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== coin3d
INCLUDE(_3d)
uniform sampler2D s_onYuz, s_arkaYuz; uniform float p_onYuzOn, p_arkaYuzOn;
uniform float p_cap, p_kalinlik, p_pah, p_bicim, p_kenarSayi, p_tirtikliKena, p_tirtikSayi, p_tirtikDeri, p_yuzeyKaba, p_otomatikDonm, p_donmeHizi, p_yalpalam;
float sdf(vec3 p) { float R = max(p_cap * 0.5, 2.0); float a = atan(p.y, p.x); float r = length(p.xy);
  float d2 = p_bicim < 0.5 || p_bicim > 1.5 ? r - R : (cos(PI / max(floor(p_kenarSayi), 3.0)) / cos(mod(a, TAU / max(floor(p_kenarSayi), 3.0)) - PI / max(floor(p_kenarSayi), 3.0))) * r - R;
  if (p_tirtikliKena > 0.5) d2 += p_tirtikDeri * 0.5 * (0.5 + 0.5 * cos(a * max(p_tirtikSayi, 8.0))) * smoothstep(-2.0, 0.0, d2);
  float h = max(p_kalinlik, 0.5) * 0.5; vec2 w = vec2(d2 + p_pah * 0.5, abs(p.z) - h); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - p_pah * 0.5; }
vec4 surf(vec3 p, vec3 n) { vec2 uv = p.xy / max(p_cap, 1.0) + 0.5; uv.y = 1.0 - uv.y; vec3 c = c_tabanRenk;
  if (abs(n.z) > 0.5) { bool front = n.z > 0.0; vec4 t = front ? (p_onYuzOn > 0.5 ? texture(s_onYuz, clamp(uv, 0.0, 1.0)) : layerAt(uv)) : (p_arkaYuzOn > 0.5 ? texture(s_arkaYuz, clamp(vec2(1.0 - uv.x, uv.y), 0.0, 1.0)) : layerAt(vec2(1.0 - uv.x, uv.y)));
    float l = luma(t.a > 0.0 ? t.rgb / t.a : vec3(0.0)); c = mix(c_tabanRenk * (0.7 + 0.5 * l), t.a > 0.0 ? t.rgb / t.a : c_tabanRenk, p_malzeme > 0.5 && p_malzeme < 1.5 ? 0.25 : 0.85);
    c *= 1.0 + (vnoise(p.xy * 0.6) - 0.5) * p_yuzeyKaba / 100.0 * 0.3; } else c *= 0.85;
  return vec4(c, 1.0); }
void main() { vec3 ex = vec3(0.0); if (p_otomatikDonm > 0.5) ex = vec3(sin(u_t * 3.0) * p_yalpalam, u_t * p_donmeHizi, 0.0); o = render3d(ex); }
//== pipe3d
INCLUDE(_3d)
uniform float p_disCap, p_uzunluk, p_duvarKali, p_kesit, p_boruYolu, p_bukulmeAcis, p_bukulmeYari, p_koniklik, p_baslangiKapa, p_bitisKapa, p_icYuzeGost; uniform vec3 c_icYuzeReng;
float sec(vec2 q, float r) { if (p_kesit < 0.5) return length(q) - r; if (p_kesit < 1.5) { vec2 d = abs(q) - r; return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0); } vec2 a = abs(q); return max(a.x * 0.866 + a.y * 0.5, a.y) - r; }
vec2 pipeCoord(vec3 p, out float s) { float L = max(p_uzunluk, 1.0);
  if (p_boruYolu < 0.5 || (p_boruYolu < 1.5 && abs(p_bukulmeAcis) < 0.5)) { s = p.y / L + 0.5; return p.xz; }
  if (p_boruYolu < 1.5) { float R = max(p_bukulmeYari, p_disCap); vec2 c = vec2(R, 0.0); vec2 q = p.xy - vec2(-R, -L * 0.0); float a = atan(q.y, q.x); float A = radians(p_bukulmeAcis);
    float ac = clamp(a, -A * 0.5, A * 0.5); s = ac / A + 0.5; vec2 on = vec2(cos(ac), sin(ac)) * R; return vec2(length(q) - R, p.z) + (a != ac ? vec2(1e3) : vec2(0.0)); }
  float R = max(p_bukulmeYari, p_disCap); float pitch = max(p_disCap * 2.5, 10.0); float a = atan(p.z, p.x); float yy = p.y - a / TAU * pitch; float k = floor(yy / pitch + 0.5); float y0 = k * pitch + a / TAU * pitch; s = (y0 / L) + 0.5; return vec2(length(p.xz) - R, p.y - y0); }
float sdf(vec3 p) { float s; vec2 q = pipeCoord(p, s); float r = max(p_disCap * 0.5, 1.0) * mix(1.0, 1.0 - p_koniklik / 100.0, clamp(s, 0.0, 1.0));
  float outer = sec(q, r); float wall = max(outer, -(sec(q, max(r - max(p_duvarKali, 0.5), 0.1)))); float caps = (p_baslangiKapa > 0.5 || p_bitisKapa > 0.5) ? outer : 1e5;
  float d = wall; float ends = max(-s, s - 1.0) * max(p_uzunluk, 1.0);
  if (p_baslangiKapa > 0.5) d = min(d, max(caps, max(-s * p_uzunluk, (s - 0.01) * p_uzunluk))); if (p_bitisKapa > 0.5) d = min(d, max(caps, max((0.99 - s) * p_uzunluk, (s - 1.0) * p_uzunluk)));
  return max(d, ends); }
vec4 surf(vec3 p, vec3 n) { float s; vec2 q = pipeCoord(p, s); float r = max(p_disCap * 0.5, 1.0); bool inner = sec(q, r) < -max(p_duvarKali, 0.5) * 0.5;
  if (inner && p_icYuzeGost > 0.5) return vec4(c_icYuzeReng, 1.0); vec4 c = layerAt(vec2(atan(q.y, q.x) / TAU + 0.5, 1.0 - s)); return vec4(c.a > 0.0 ? c.rgb / c.a : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
