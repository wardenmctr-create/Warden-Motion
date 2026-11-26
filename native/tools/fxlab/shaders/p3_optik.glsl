// 800 rehberi, bölüm 3: optik, bükme ve zamansal görüntü (601–625)
//== kernelfilter
uniform float p_matrisBoyu, p_normaliz, p_katsayilN; uniform vec4 p_katsayil4[57]; float katsayilAt(int i) { return i < 0 || i >= 228 ? 0.0 : p_katsayil4[i >> 2][i & 3]; }
void main() { vec4 s = texture(u_tex, v_uv); int N = int(clamp(floor(p_matrisBoyu), 1.0, 15.0)); if (N % 2 == 0) N -= 1; int n = int(sqrt(max(p_katsayilN, 1.0)) + 0.5); int K = min(N, n); int h = K / 2;
  vec4 acc = vec4(0.0); float sum = 0.0; for (int j = 0; j < 15; j++) for (int i = 0; i < 15; i++) { if (i >= K || j >= K) continue; float w = katsayilAt(j * n + i); acc += texPx(here() + vec2(i - h, j - h) * u_s) * w; sum += w; }
  if (p_normaliz > 0.5 && abs(sum) > 1e-4) acc /= sum; o = p_katsayilN < 1.0 ? s : vec4(clamp(acc.rgb, 0.0, 1.0), clamp(acc.a, 0.0, 1.0)); }
//== bandpassimg
uniform float p_altOlce, p_ustOlce, p_kazanc;
vec3 bl(float r) { vec3 a = vec3(0.0); float ws = 0.0; for (int i = 0; i < 16; i++) { float an = float(i) * 2.39996; float rr = r * sqrt((float(i) + 0.5) / 16.0); float w = exp(-rr * rr / (r * r)); a += unpre(texPx(here() + vec2(cos(an), sin(an)) * rr)) * w; ws += w; } return a / ws; }
void main() { vec4 s = texture(u_tex, v_uv); vec3 b = bl(max(p_altOlce, 0.5) * u_s) - bl(max(p_ustOlce, p_altOlce + 0.5) * u_s); o = pre(clamp(0.5 + b * p_kazanc / 100.0 * 2.0, 0.0, 1.0), s.a); }
//== gabor
uniform float p_yon, p_frekans, p_bantGeni;
void main() { vec4 s = texture(u_tex, v_uv); vec2 d = vec2(cos(radians(p_yon)), sin(radians(p_yon))); float f = p_frekans / max(u_s, 0.1); float sig = p_bantGeni / max(f, 1e-3) * 0.4; float re = 0.0, im = 0.0;
  for (int j = -5; j <= 5; j++) for (int i = -5; i <= 5; i++) { vec2 o2 = vec2(i, j) * sig / 2.5; float g = exp(-dot(o2, o2) / (2.0 * sig * sig)); float l = luma(unpre(texPx(here() + o2))); float ph = TAU * f * dot(o2, d); re += l * g * cos(ph); im += l * g * sin(ph); }
  float e = sqrt(re * re + im * im) / 20.0; o = pre(vec3(clamp(e * 4.0, 0.0, 1.0)), s.a); }
//== spatialdiffuse
uniform float p_yayilim, p_parlakliAgir, p_karisim;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = srgb2lin(unpre(s)); float R = max(p_yayilim, 0.5) * u_s; vec3 acc = vec3(0.0); float ws = 0.0;
  for (int i = 0; i < 32; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 32.0); vec3 n = srgb2lin(unpre(texPx(here() + vec2(cos(a), sin(a)) * r))); float w = exp(-r / R * 2.0) * mix(1.0, luma(n) * 3.0, p_parlakliAgir / 100.0); acc += n * w; ws += w; }
  vec3 d = acc / max(ws, 1e-4); o = pre(clamp(lin2srgb(mix(c, max(c, d), p_karisim / 100.0)), 0.0, 1.0), s.a); }
//== freelens
uniform vec2 p_mercekKaym, p_egim; uniform float p_odakUzak, p_odakBandGeni, p_odakDisiBula;
void main() { vec2 q = toUnit(here()) - p_mercekKaym * 0.2; vec2 b = boxUV(here()) - 0.5; float plane = dot(b, vec2(sin(radians(p_egim.x)), sin(radians(p_egim.y)))) * 2.0 + (p_odakUzak - 50.0) / 50.0;
  float blur = smoothstep(p_odakBandGeni / 100.0 * 0.5, p_odakBandGeni / 100.0 * 0.5 + 0.3, abs(plane + b.y * 0.0)) * p_odakDisiBula * 0.15 * u_s; vec4 acc = vec4(0.0);
  for (int i = 0; i < 24; i++) { float a = float(i) * 2.39996; float r = blur * sqrt((float(i) + 0.5) / 24.0); acc += texU(q + vec2(cos(a), sin(a)) * r / u_s); } o = acc / 24.0; }
//== anamorphic
uniform float p_sikistirOran, p_bokehOval, p_isikIzi;
void main() { vec2 q = toUnit(here()); q.x /= max(p_sikistirOran / 2.0 + 0.5, 0.5); vec4 c = texU(q); vec3 streak = vec3(0.0);
  for (int i = -12; i <= 12; i++) { vec4 n = texU(q + vec2(float(i) * boxU().x * 0.02 * p_isikIzi / 30.0, 0.0)); float l = luma(unpre(n)); streak += vec3(0.3, 0.6, 1.0) * smoothstep(0.75, 1.0, l) * n.a * exp(-abs(float(i)) * 0.15); }
  vec4 bo = vec4(0.0); for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; vec2 o2 = vec2(cos(a) / max(p_bokehOval, 0.25), sin(a)) * 3.0; vec4 n = texU(q + o2); bo += n * smoothstep(0.8, 1.0, luma(unpre(n))); }
  c.rgb += (streak * p_isikIzi / 100.0 * 0.3 + bo.rgb / 12.0 * 0.4) * c.a; o = vec4(clamp(c.rgb, 0.0, c.a + 0.0001), c.a); }
//== lensbreathe
uniform float p_odak, p_solumaGucu; uniform vec2 p_merkez;
void main() { float k = 1.0 + p_solumaGucu / 100.0 * (p_odak - 50.0) / 50.0; o = texU((toUnit(here()) - p_merkez) / max(k, 0.05) + p_merkez); }
//== lightleak
uniform vec2 p_kaynak; uniform float p_yayilim, p_hareket, p_isikGucu; uniform vec3 c_isikRenk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 c = p_kaynak + vec2(sin(u_t * p_hareket / 30.0), cos(u_t * p_hareket / 40.0)) * boxU() * 0.1; float d = length(q - c) / max(p_yayilim / 100.0 * length(boxU()), 1.0);
  float g = exp(-d * d * 2.0) * (0.7 + 0.3 * fbm01(q * 0.005 + u_t * p_hareket / 200.0, 3.0)); vec3 add = c_isikRenk * g * p_isikGucu / 100.0; o = pre(clamp(screenB(unpre(s), add), 0.0, 1.0), s.a); }
//== starfilter
uniform float p_kanatSayi, p_sivriUzun, p_esik, p_aci;
void main() { vec4 s = texture(u_tex, v_uv); vec3 acc = vec3(0.0); int K = int(clamp(p_kanatSayi, 3.0, 16.0)); float L = p_sivriUzun * u_s;
  for (int k = 0; k < 16; k++) { if (k >= K) break; float a = radians(p_aci) + float(k) * PI / float(K) * 2.0; vec2 d = vec2(cos(a), sin(a));
    for (int i = 1; i <= 12; i++) { float t = L * float(i) / 12.0; vec4 n = texPx(here() - d * t); float b = smoothstep(p_esik / 100.0, 1.0, luma(unpre(n))) * n.a; acc += unpre(n) * b * (1.0 - float(i) / 13.0) / 6.0; } }
  o = vec4(clamp(s.rgb + acc, 0.0, 1.0), max(s.a, min(1.0, luma(acc)))); }
//== prismfx
uniform float p_yuzSayi, p_prizmaAcis, p_kirilmaIndi;
void main() { vec2 q = toUnit(here()); float N = max(floor(p_yuzSayi), 3.0); float a = atan(q.y, q.x); float id = floor((a / TAU + 0.5) * N); float ca = (id + 0.5) / N * TAU - PI;
  vec2 shift = vec2(cos(ca), sin(ca)) * length(boxU()) * 0.08 * (p_kirilmaIndi - 1.0) * sin(radians(p_prizmaAcis)) * 3.0; vec4 r = texU(q - shift * 1.06), g = texU(q - shift), b = texU(q - shift * 0.94);
  o = vec4(r.r, g.g, b.b, max(r.a, max(g.a, b.a))) * (0.9 + 0.1 * cos(a * N)); }
//== insecteye
uniform float p_mercekSayi, p_odak, p_mercekAral;
void main() { vec2 q = toUnit(here()); float cs = max(boxU().x, boxU().y) / max(p_mercekSayi, 1.0); vec4 h = hexGrid(q / cs, 1.0); vec2 local = h.xy * cs; vec2 ctr = q - local; float r = length(h.xy);
  vec2 sq = ctr + local * mix(2.0, 0.3, p_odak / 100.0); vec4 c = texU(sq); float edge = 1.0 - smoothstep(0.5 - p_mercekAral / 200.0 - 0.03, 0.5 - p_mercekAral / 200.0, hexDist(h.xy)); o = c * edge * (1.0 - r * 0.3); }
//== warpfield
uniform vec2 p_hedefler; uniform float p_etkiYari;
void main() { vec2 q = toUnit(here()); float r = max(p_etkiYari, 1.0); float w = exp(-dot(q, q) / (r * r)); o = texU(q - p_hedefler * w); }
//== flowwarp
uniform sampler2D s_vektorHari; uniform float p_vektorHariOn, p_adim, p_akisGucu;
void main() { if (p_vektorHariOn < 0.5) { o = texture(u_tex, v_uv); return; } vec2 q = toUnit(here()); int N = int(clamp(p_adim, 1.0, 64.0)); float st = p_akisGucu / float(N);
  for (int i = 0; i < 64; i++) { if (i >= N) break; vec2 v = unpre(texture(s_vektorHari, clamp(boxUV(fromUnit(q)), 0.0, 1.0))).rg * 2.0 - 1.0; q -= v * st; } o = texU(q); }
//== feedbackloop
INCLUDE(_hist)
uniform float p_geriBesl, p_olcek, p_donus, p_birlesti;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 2.0) { o = s; return; } vec4 acc = s; float w = 1.0; vec2 q = toUnit(here());
  for (int k = 1; k < 16; k++) { if (float(k) >= N) break; w *= p_geriBesl / 100.0; float sc = pow(p_olcek / 100.0, float(k)); vec2 l = rot2(-p_donus * float(k)) * q / max(sc, 0.01); vec4 h = hist(float(k), fromUnit(l) / u_res) * w;
    acc = p_birlesti < 0.5 ? overPre(acc, h) : p_birlesti < 1.5 ? acc + h : vec4(screenB(acc.rgb, h.rgb), max(acc.a, h.a)); }
  o = clamp(acc, 0.0, 1.0); }
//== frameshuffle
INCLUDE(_hist)
void main() { o = histN() < 1.0 ? texture(u_tex, v_uv) : hist(0.0, v_uv); }
//== temporalmedian
INCLUDE(_hist)
uniform float p_karePenc, p_hareketEsig;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 3.0) { o = s; return; } vec4 v[16]; int n = int(N);
  for (int i = 0; i < 16; i++) { if (i >= n) break; v[i] = hist(float(i), v_uv); }
  for (int i = 0; i < 16; i++) { if (i >= n) break; for (int j = i + 1; j < 16; j++) { if (j >= n) break; if (luma(v[j].rgb) < luma(v[i].rgb)) { vec4 t = v[i]; v[i] = v[j]; v[j] = t; } } }
  vec4 m = v[n / 2]; float diff = length(m.rgb - s.rgb); o = mix(m, s, smoothstep(p_hareketEsig / 100.0, p_hareketEsig / 100.0 + 0.1, diff)); }
//== temporaldenoise
INCLUDE(_hist)
uniform float p_kareSayi, p_hareketEsig, p_hareketTela;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 2.0) { o = s; return; } vec4 acc = vec4(0.0); float ws = 0.0;
  for (int i = 0; i < 16; i++) { if (float(i) >= N) break; vec4 h = hist(float(i), v_uv); float w = p_hareketTela > 0.5 ? 1.0 - smoothstep(p_hareketEsig / 100.0 * 0.5, p_hareketEsig / 100.0, length(h - s)) : 1.0; acc += h * w; ws += w; }
  o = ws > 0.0 ? acc / ws : s; }
//== brightaccum
INCLUDE(_hist)
uniform float p_kareSayi, p_azalma, p_renkleriBirlAl;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); vec4 best = s; float bl = luma(s.rgb);
  for (int i = 1; i < 16; i++) { if (float(i) >= N) break; vec4 h = hist(float(i), v_uv) * pow(1.0 - p_azalma / 100.0, float(i)); if (p_renkleriBirlAl > 0.5) best = max(best, h); else if (luma(h.rgb) > bl) { best = h; bl = luma(h.rgb); } }
  o = best; }
//== darkaccum
INCLUDE(_hist)
uniform float p_kareSayi, p_azalma, p_alfayiKoru;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); vec4 best = s; float bl = s.a > 0.0 ? luma(s.rgb / s.a) : 2.0;
  for (int i = 1; i < 16; i++) { if (float(i) >= N) break; vec4 h = hist(float(i), v_uv); if (h.a < 0.05) continue; float l = luma(h.rgb / h.a) + p_azalma / 100.0 * float(i) * 0.05; if (l < bl) { bl = l; best = h; } }
  if (p_alfayiKoru > 0.5) best = pre(best.a > 0.0 ? best.rgb / best.a : vec3(0.0), max(s.a, best.a * 0.0 + s.a)); o = best; }
//== timemosaic
INCLUDE(_hist)
uniform float p_satirSutu, p_zamanAral, p_etiketle, p_hucreBosl;
void main() { float g = clamp(floor(p_satirSutu), 1.0, 4.0); vec2 b = boxUV(here()); vec2 cell = floor(b * g); vec2 f = fract(b * g); float k = cell.y * g + cell.x;
  float gap = p_hucreBosl / 100.0 * 0.5; if (any(lessThan(f, vec2(gap))) || any(greaterThan(f, vec2(1.0 - gap)))) { o = vec4(0.0); return; }
  vec2 uv = u_box.xy / u_res + ((f - gap) / (1.0 - 2.0 * gap)) * u_box.zw / u_res; vec4 c = histN() > 0.0 ? hist(k, uv) : texture(u_tex, uv);
  if (p_etiketle > 0.5) { vec2 lp = (f - vec2(0.12, 0.88)) * 20.0; c = overPre(vec4(1.0) * (1.0 - smoothstep(0.6, 0.9, length(lp))) * step(0.5, mod(k + 1.0, 2.0) + 0.5), c); } o = c; }
//== timemap
INCLUDE(_hist)
uniform sampler2D s_zamanHari; uniform float p_zamanHariOn, p_azamiFark, p_enterpol;
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 9.0) { o = s; return; } float m = p_zamanHariOn > 0.5 ? luma(unpre(texture(s_zamanHari, clamp(boxUV(here()), 0.0, 1.0)))) : boxUV(here()).y;
  float k = clamp(m * 8.0, 0.0, 8.0); o = p_enterpol > 0.5 ? mix(hist(floor(k), v_uv), hist(min(floor(k) + 1.0, 8.0), v_uv), fract(k)) : hist(floor(k + 0.5), v_uv); }
//== motioncomposite
INCLUDE(_hist)
uniform sampler2D s_nesneMati; uniform float p_nesneMatiOn, p_ornek, p_ortusme;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 2.0) { o = s; return; } vec4 acc = vec4(0.0);
  for (int i = 0; i < 16; i++) { if (float(i) >= N) break; vec4 h = hist(float(i), v_uv); acc = overPre(h * mix(0.5, 1.0, float(i) / max(N - 1.0, 1.0)) * mix(1.0, p_ortusme / 100.0 + 0.3, 0.5), acc); } o = overPre(s, acc); }
//== temporalfreq
INCLUDE(_hist)
uniform float p_altUst, p_pencere, p_cikti;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 4.0) { o = s; return; } float re = 0.0, im = 0.0; float f = clamp(p_altUst, 0.1, N / 2.0);
  float mean = 0.0; for (int i = 0; i < 16; i++) { if (float(i) >= N) break; mean += luma(hist(float(i), v_uv).rgb); } mean /= N;
  for (int i = 0; i < 16; i++) { if (float(i) >= N) break; float l = luma(hist(float(i), v_uv).rgb) - mean; float ph = TAU * f * float(i) / N; re += l * cos(ph); im += l * sin(ph); }
  float e = clamp(sqrt(re * re + im * im) / N * 8.0, 0.0, 1.0); o = p_cikti < 0.5 ? vec4(vec3(e), e) : p_cikti < 1.5 ? overPre(vec4(hsv2rgb(vec3(0.66 - e * 0.66, 1.0, 1.0)), 1.0) * e, s * 0.5) : vec4(vec3(e), 1.0); }
//== colortrail
INCLUDE(_hist)
uniform float p_ornek, p_zamanAral; uniform vec3 c_basSonRenk;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); vec4 acc = vec4(0.0);
  for (int i = 15; i >= 1; i--) { if (float(i) >= N) continue; vec4 h = hist(float(i), v_uv); float k = float(i) / max(N - 1.0, 1.0); vec3 tint = mix(vec3(1.0), c_basSonRenk, k); acc = overPre(vec4(tint, 1.0) * h.a * (1.0 - k * 0.6), acc); }
  o = overPre(s, acc); }
