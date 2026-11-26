// Eski katalogda motoru eksik kalan efektler: flaş, zaman farkı/kayması, fark matı, gren eşleme, ses spektrumu/dalgası
//== flash
uniform vec3 c_renk; uniform float p_sure, p_tepeGucu, p_gecikme, p_egri, p_tumKare;
void main() { vec4 s = texture(u_tex, v_uv); float x = (u_t - p_gecikme) / max(p_sure, 1e-3); float k = 0.0;
  if (x >= 0.0 && x <= 1.0) { float tri = x < 0.2 ? x / 0.2 : 1.0 - (x - 0.2) / 0.8; k = p_egri < 0.5 ? tri * tri * (3.0 - 2.0 * tri) : tri; }
  k *= p_tepeGucu / 100.0;
  if (p_tumKare > 0.5) { vec2 b = boxUV(here()); float inside = step(0.0, b.x) * step(b.x, 1.0) * step(0.0, b.y) * step(b.y, 1.0); o = mix(s, vec4(c_renk, 1.0), k * inside); }
  else o = vec4(mix(s.rgb, c_renk * s.a, k), s.a); }

//== timediff
INCLUDE(_hist)
uniform float p_zamanFark, p_kazanc, p_esik, p_yontem, p_tekRenk, p_alfayiKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 1.0) { o = s; return; } vec4 h = hist(0.0, v_uv);
  vec3 a = s.rgb - h.rgb; float g = p_kazanc / 100.0 * 3.0; float th = p_esik / 100.0; vec3 m = max(abs(a) - th, 0.0) * g;
  vec3 r = p_yontem < 0.5 ? m : 0.5 + sign(a) * m * 0.5;
  if (p_tekRenk > 0.5) r = vec3(p_yontem < 0.5 ? max(r.r, max(r.g, r.b)) : luma(r));
  float al = p_alfayiKoru > 0.5 ? s.a : max(s.a, h.a); o = vec4(clamp(r, 0.0, 1.0) * al, al); }

//== timedisplace
INCLUDE(_hist)
uniform sampler2D s_haritaKatm; uniform float p_haritaKatmOn, p_harita, p_maksimumZama, p_ornekSayi, p_yumusatm, p_zamanSini, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 2.0) { o = s; return; } vec2 b = clamp(boxUV(here()), 0.0, 1.0); float m;
  if (p_harita < 0.5) m = b.y; else if (p_harita < 1.5) m = b.x; else if (p_harita < 2.5 || p_haritaKatmOn < 0.5) m = luma(unpre(s)); else { vec4 q = texture(s_haritaKatm, v_uv); m = luma(unpre(q)) * q.a; }
  if (p_ters > 0.5) m = 1.0 - m; float k = clamp(m, 0.0, 1.0) * (n - 1.0); float f = fract(k); float sm = p_yumusatm / 100.0;
  float w = sm < 0.01 ? step(0.5, f) : smoothstep(0.5 - sm * 0.5, 0.5 + sm * 0.5, f);
  o = mix(hist(floor(k), v_uv), hist(min(floor(k) + 1.0, n - 1.0), v_uv), w); }

//== diffmatte
INCLUDE(_hist)
uniform sampler2D s_temizKareKatm; uniform float p_temizKareKatmOn, p_referansZama, p_tolerans, p_yumusakl, p_onBula, p_ters, p_matiGost;
vec4 refAt(vec2 uv) { return p_temizKareKatmOn > 0.5 ? texture(s_temizKareKatm, uv) : hist(0.0, uv); }
void main() { vec4 s = texture(u_tex, v_uv); if (p_temizKareKatmOn < 0.5 && histN() < 1.0) { o = s; return; }
  vec2 px = max(p_onBula, 0.0) * u_s / u_res; vec3 a = vec3(0.0), r = vec3(0.0);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 uv = v_uv + vec2(i, j) * px; a += unpre(texture(u_tex, uv)); r += unpre(refAt(uv)); }
  float d = length(a / 9.0 - r / 9.0) / 1.732; float tol = p_tolerans / 100.0; float m = smoothstep(tol, tol + max(p_yumusakl / 100.0, 1e-3), d);
  if (p_ters > 0.5) m = 1.0 - m;
  o = p_matiGost > 0.5 ? vec4(vec3(m) * s.a, s.a) : s * m; }

//== matchgrain
uniform sampler2D s_referansKatm; uniform vec2 p_ornekAlan; uniform float p_referansKatmOn, p_ornekBoyu, p_grenGucu, p_grenBoyu, p_renkliGren, p_zamansalDegi;
float lumR(vec2 uv) { vec4 c = p_referansKatmOn > 0.5 ? texture(s_referansKatm, uv) : texture(u_tex, uv); return luma(unpre(c)); }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  // referansın ince ayrıntı (yüksek geçiren) sapması: Örnek Alan noktası çevresinde, Örnek Boyu genişliğinde 16 nokta
  vec2 c0 = fromUnit(p_ornekAlan) / u_res; vec2 ext = vec2(max(p_ornekBoyu, 2.0) * u_s * 0.5) / u_res; vec2 px = 1.0 / u_res; float acc = 0.0;
  for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) { vec2 uv = c0 + ext * (vec2(float(i), float(j)) / 1.5 - 1.0);
    float hp = lumR(uv) - 0.25 * (lumR(uv + vec2(px.x, 0.0)) + lumR(uv - vec2(px.x, 0.0)) + lumR(uv + vec2(0.0, px.y)) + lumR(uv - vec2(0.0, px.y))); acc += hp * hp; }
  float sd = sqrt(acc / 16.0) * 1.6 + 0.004;
  float fr = p_zamansalDegi > 0.5 ? floor(u_t * 24.0) : 0.0; vec2 g = floor(here() / max(p_grenBoyu * u_s, 1.0)) + fr * 17.31;
  vec3 nz = p_renkliGren > 0.5 ? vec3(hash1(g), hash1(g + 3.7), hash1(g + 9.1)) - 0.5 : vec3(hash1(g) - 0.5);
  vec3 rgb = clamp(unpre(s) + nz * sd * 3.4 * p_grenGucu / 100.0, 0.0, 1.0); o = pre(rgb, s.a); }

//== audiospec
GRADIENT(renkGeci)
uniform vec4 p_dv4[64]; float dvAt(int i) { return i < 0 || i >= 256 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform vec2 p_baslangi, p_bitis; uniform float p_dvN, p_altFrek, p_ustFrek, p_bantSayi, p_yuksekli, p_kalinlik, p_yumusatm, p_gosterim, p_ikiTara;
float band(int i, float N) { if (p_dvN > 0.5) return clamp(dvAt(i), 0.0, 1.0); float x = float(i) / N; return clamp(0.55 + 0.35 * sin(u_t * 5.0 + x * 13.0) * sin(u_t * 2.3 + x * 5.0) - x * 0.3, 0.0, 1.0); }
// Çubuklar Başlangıç → Bitiş çizgisi boyunca dizilir, çizgiye dik yükselir (katman birimi)
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 A = p_baslangi, d = p_bitis - A; float L = max(length(d), 1e-3); vec2 t1 = d / L, nrm = vec2(t1.y, -t1.x);
  float u = dot(q - A, t1) / L; float y = dot(q - A, nrm); if (u < 0.0 || u > 1.0) { o = s; return; }
  float N = clamp(floor(p_bantSayi), 2.0, 128.0); if (p_dvN > 0.5) N = min(N, p_dvN);
  float fi = u * N; int i = int(min(floor(fi), N - 1.0)); float H = p_yuksekli; float th = max(p_kalinlik, 0.3); float aa = 0.75 / u_s; float a = 0.0;
  float yy = p_ikiTara > 0.5 ? abs(y) : y;
  if (p_gosterim < 0.5) { float v = band(i, N) * H; float cw = fract(fi); float inBar = step(0.12, cw) * step(cw, 0.88); a = inBar * step(0.0, yy) * (1.0 - smoothstep(max(v, th * 0.5) - aa, max(v, th * 0.5) + aa, yy)); }
  else { float fl = clamp(fi - 0.5, 0.0, N - 1.0); int i0 = int(floor(fl)); float v = mix(band(i0, N), band(min(i0 + 1, int(N) - 1), N), smoothstep(0.0, 1.0, fract(fl))) * H;
    if (p_gosterim < 1.5) a = 1.0 - smoothstep(th * 0.5 - aa, th * 0.5 + aa, abs(yy - v));
    else { float cx = (floor(fi) + 0.5) / N; float dx = (u - cx) * L; float vv = band(i, N) * H; a = 1.0 - smoothstep(th - aa, th + aa, length(vec2(dx, yy - vv))); } }
  o = overPre(vec4(grad_renkGeci(u), 1.0) * a, s); }

//== audiowave
uniform vec4 p_dv4[64]; float dvAt(int i) { return i < 0 || i >= 256 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform vec2 p_baslangi, p_bitis; uniform vec3 c_renk; uniform float p_dvN, p_yuksekli, p_ornekSayi, p_zamanPenc, p_cizgiKali, p_kanal, p_ciftYon;
float smp(float x) { x = clamp(x, 0.0, 1.0); if (p_dvN > 0.5) { float f = x * (p_dvN - 1.0); int i = int(floor(f)); return mix(dvAt(i), dvAt(min(i + 1, int(p_dvN) - 1)), fract(f)); }
  return sin(x * 40.0 + u_t * 9.0) * 0.5 * (0.6 + 0.4 * sin(x * 7.0 - u_t * 3.0)); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 A = p_baslangi, d = p_bitis - A; float L = max(length(d), 1e-3); vec2 t1 = d / L, nrm = vec2(t1.y, -t1.x);
  float u = dot(q - A, t1) / L; float y = dot(q - A, nrm); if (u < 0.0 || u > 1.0) { o = s; return; }
  float H = p_yuksekli; float th = max(p_cizgiKali, 0.3); float aa = 0.75 / u_s; float v = clamp(smp(u), -1.0, 1.0) * H;
  float dU = 1.0 / max(L * u_s, 1.0); float slope = (smp(u + dU) - smp(u - dU)) * H / (2.0 * dU * L); float corr = sqrt(1.0 + slope * slope);
  float dd = p_ciftYon > 0.5 ? abs(abs(y) - abs(v)) : abs(y - v);
  float a = 1.0 - smoothstep(th * 0.5 - aa, th * 0.5 + aa, dd / corr);
  if (p_ciftYon > 0.5) a = max(a, (1.0 - step(abs(v), abs(y))) * 0.35);
  o = overPre(vec4(c_renk, 1.0) * a, s); }
