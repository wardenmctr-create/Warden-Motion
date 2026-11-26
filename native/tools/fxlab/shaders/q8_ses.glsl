// 1000 rehberi bölüm 8 (959–978): ses görselleştiricileri — veri motordan (AudioVis2) p_dv olarak; veri yoksa örnek hareket
//== pitchcurve
INCLUDE(_chart)
uniform float p_dvN, p_altSini, p_ustSini, p_guvenEsig, p_notaEtik;
// Nota ekseni (yarım ton çizgileri, Do notaları belirgin) üzerinde son 3 saniyenin perde eğrisi
float M(int i) { if (p_dvN > 0.5) return dvAt(i); float x = float(i) / 127.0; return 60.0 + 7.0 * sin(x * 9.0 + u_t * 2.0) + 3.0 * sin(x * 23.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float m0 = 69.0 + 12.0 * log2(max(p_altSini, 20.0) / 440.0), m1 = 69.0 + 12.0 * log2(max(p_ustSini, p_altSini + 10.0) / 440.0);
  float m = mix(m1, m0, b.y); float semi = abs(fract(m + 0.5) - 0.5); float isC = step(abs(mod(floor(m + 0.5), 12.0)), 0.5); vec4 res = overPre(vec4(vec3(1.0), 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.w * (m1 - m0), semi)) * mix(0.08, 0.3, isC), s);
  float f = clamp(b.x, 0.0, 1.0) * 127.0; int i = int(floor(f)); float a = M(i), c = M(min(i + 1, 127)); float val = (a > 0.0 && c > 0.0) ? mix(a, c, fract(f)) : 0.0;
  if (val > 0.0) { float y = (m1 - val) / (m1 - m0); float d = abs(b.y - y) * u_box.w; res = overPre(vec4(1.0, 0.7, 0.25, 1.0) * (1.0 - smoothstep(1.2, 2.5, d)), res); }
  if (p_notaEtik > 0.5) { float cur = M(127); vec2 lp = (b - vec2(0.12, 0.08)) / vec2(0.035, 0.05); res = overPre(vec4(1.0) * numAt(lp, cur), res); } o = res; }

//== tuningmeter
INCLUDE(_chart)
uniform float p_dvN, p_referansA, p_yumusatm, p_olcek, p_notaEtik;
// Yarım daire gösterge: −50…+50 cent; ibre sapmayı, renk doğruluğu gösterir; altta nota numarası ya da Hz
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - vec2(0.0, boxU().y * 0.15); float R = min(boxU().x, boxU().y) * 0.42; float cents = p_dvN > 0.5 ? dvAt(0) : sin(u_t * 1.3) * 30.0;
  float r = length(q); float ang = atan(q.x, -q.y); vec4 res = s; if (q.y < 0.0 && r < R && r > R * 0.78) { float k = ang / 1.5708 * 50.0; vec3 c = mix(vec3(0.3, 0.9, 0.4), vec3(1.0, 0.35, 0.3), smoothstep(5.0, 40.0, abs(k))); res = overPre(vec4(c, 0.85), res);
    float tick = 1.0 - smoothstep(0.0, 0.015, abs(fract(k / 10.0 + 0.5) - 0.5)); res = overPre(vec4(vec3(1.0), 1.0) * tick, res); }
  float na = clamp(cents, -50.0, 50.0) / 50.0 * 1.5708; vec2 dir = vec2(sin(na), -cos(na)); float tt = clamp(dot(q, dir), 0.0, R * 0.95); float nd = length(q - dir * tt); res = overPre(vec4(1.0) * (1.0 - smoothstep(1.0, 2.2, nd * u_s)) * step(0.0, -q.y + 1.0), res);
  vec2 lp = (q - vec2(0.0, R * 0.25)) / (R * 0.12); float val = p_olcek < 0.5 ? (p_notaEtik > 0.5 ? (p_dvN > 0.5 ? dvAt(1) : 69.0) : abs(cents)) : (p_dvN > 0.5 ? dvAt(2) : p_referansA); res = overPre(vec4(1.0) * numAt(lp, val), res); o = res; }

//== chromawheel
INCLUDE(_chart)
uniform float p_dvN, p_pencere, p_cikti, p_yumusatm;
// 12 nota sınıfı çember üzerinde: dilim parlaklığı ve boyu enerjiyle; akor etiketinde kök nota numarası (0 = Do) ortada
float C(int i) { if (p_dvN > 0.5) return dvAt(i); return 0.3 + 0.7 * pow(0.5 + 0.5 * sin(u_t * 1.7 + float(i) * 0.9), 3.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = min(boxU().x, boxU().y) * 0.45; float r = length(q); float a = mod(atan(q.x, -q.y) + 6.2832, 6.2832); int i = int(floor(a / 6.2832 * 12.0)) % 12;
  float e = clamp(C(i), 0.0, 1.0); vec4 res = s; float outer = R * (0.55 + 0.45 * e); if (r > R * 0.3 && r < outer && fract(a / 6.2832 * 12.0) > 0.04) res = overPre(vec4(hsv2rgb(vec3(float(i * 7 % 12) / 12.0, 0.75, 0.35 + 0.65 * e)), 0.9), res);
  if (p_cikti > 0.5) { vec2 lp = q / (R * 0.12); float root = p_dvN > 0.5 ? dvAt(12) : floor(mod(u_t, 12.0)); res = overPre(vec4(1.0) * numAt(lp, root), res); if (p_dvN > 0.5 && dvAt(13) > 0.5) res = overPre(vec4(0.6, 0.8, 1.0, 1.0) * (1.0 - smoothstep(R * 0.02, R * 0.03, abs(r - R * 0.25))), res); } o = res; }

//== tempocurve
INCLUDE(_chart)
uniform float p_dvN, p_minBpm, p_maxBpm, p_pencere, p_elleDuze;
// BPM eğrisi parça boyunca; dikey çizgi şimdiki konum; şimdiki tempo sayı olarak
float B(int i) { if (p_dvN > 0.5) return dvAt(i); return 110.0 + 20.0 * sin(float(i) * 0.15) + 8.0 * sin(float(i) * 0.6); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float lo = p_minBpm, hi = max(p_maxBpm, lo + 1.0); vec4 res = overPre(vec4(0.05, 0.06, 0.1, 0.7), s);
  for (int k = 1; k < 4; k++) { float y = float(k) / 4.0; res = overPre(vec4(vec3(1.0), 1.0) * (1.0 - smoothstep(0.0, 1.2 / u_box.w, abs(b.y - y))) * 0.15, res); }
  float f = clamp(b.x, 0.0, 1.0) * 63.0; int i = int(floor(f)); float v = mix(B(i), B(min(i + 1, 63)), fract(f)); float y = 1.0 - (v - lo) / (hi - lo); res = overPre(vec4(0.4, 0.85, 1.0, 1.0) * (1.0 - smoothstep(1.2, 2.5, abs(b.y - y) * u_box.w)), res);
  float pos = p_dvN > 0.5 ? dvAt(64) : fract(u_t * 0.1); res = overPre(vec4(1.0, 0.4, 0.3, 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.z, abs(b.x - pos))), res);
  vec2 lp = (b - vec2(0.85, 0.1)) / vec2(0.035, 0.05); res = overPre(vec4(1.0) * numAt(lp, B(int(pos * 63.0))), res); o = res; }

//== onsetdetect
INCLUDE(_chart)
uniform float p_dvN, p_duyarlil, p_enAzAral, p_mod;
// Her başlangıç darbesi merkezden yayılan bir halka (yaşla büyür ve söner); altta son 3 saniyenin olay çizgisi
float A(int i) { if (p_dvN > 0.5) return dvAt(i); float per = 0.45; return mod(u_t - float(i) * per, per * 8.0) + float(i) * per * 0.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 b = boxUV(here()); float R = min(boxU().x, boxU().y) * 0.45; vec4 res = s;
  for (int i = 0; i < 8; i++) { float age = A(i); if (age > 3.0) continue; float rr = R * clamp(age / 0.8, 0.0, 1.2); float a = exp(-age * 2.5); res = overPre(vec4(1.0, 0.85, 0.4, 1.0) * (1.0 - smoothstep(1.0, 3.0, abs(length(q) - rr) * u_s)) * a, res);
    float x = 1.0 - age / 3.0; if (b.y > 0.9) res = overPre(vec4(1.0, 0.6, 0.3, 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.z, abs(b.x - x))), res); }
  if (b.y > 0.9) res = overPre(vec4(0.05, 0.06, 0.1, 0.5), res); o = res; }

//== envelopeparts
uniform vec4 p_dv4[32]; float dvAt(int i) { return i < 0 || i >= 128 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_baslangiTepk, p_kuyrukTepk, p_cikti;
// Son 2 saniyenin giriş (başlangıç) ve çıkış (kuyruk) zarfları ayrı eğriler
float E(int i, bool rel) { if (p_dvN > 0.5) return dvAt(i + (rel ? 64 : 0)); float x = float(i) / 63.0 * 6.0 + u_t * 3.0; float ph = fract(x / 1.5); return rel ? exp(-ph * 3.0) * 0.6 * step(0.1, ph) : exp(-ph * 18.0) * 0.9; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float f = clamp(b.x, 0.0, 1.0) * 63.0; int i = int(floor(f)); vec4 res = overPre(vec4(0.05, 0.06, 0.1, 0.55), s);
  float mx = 1e-4; for (int k = 0; k < 64; k++) mx = max(mx, max(E(k, false), E(k, true)));
  if (p_cikti != 1.0) { float v = mix(E(i, false), E(min(i + 1, 63), false), fract(f)) / mx; float y = 0.95 - v * 0.85; res = overPre(vec4(1.0, 0.75, 0.3, 1.0) * (1.0 - smoothstep(1.2, 2.5, abs(b.y - y) * u_box.w)), res); }
  if (p_cikti != 0.0) { float v = mix(E(i, true), E(min(i + 1, 63), true), fract(f)) / mx; float y = 0.95 - v * 0.85; res = overPre(vec4(0.4, 0.8, 1.0, 1.0) * (1.0 - smoothstep(1.2, 2.5, abs(b.y - y) * u_box.w)), res); }
  o = res; }

//== stereodir
uniform vec4 p_dv4[32]; float dvAt(int i) { return i < 0 || i >= 128 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_bant, p_yumusatm, p_altFrek, p_ustFrek;
// Yatay: sol–sağ dengesi, dikey: frekans bandı (altta bas); her bant enerjisiyle parlayan, frekans renginde bir leke
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); int N = int(clamp(p_bant, 8.0, 64.0)); vec4 res = overPre(vec4(0.04, 0.05, 0.08, 0.75), s); res = overPre(vec4(vec3(1.0), 1.0) * (1.0 - smoothstep(0.0, 1.2 / u_box.z, abs(b.x - 0.5))) * 0.25, res);
  for (int k = 0; k < 64; k++) { if (k >= N) break; float bal = p_dvN > 0.5 ? dvAt(k * 2) : sin(u_t * 1.1 + float(k) * 0.4) * 0.6; float en = p_dvN > 0.5 ? dvAt(k * 2 + 1) : 0.4 + 0.4 * sin(u_t * 2.0 + float(k)); float y = 1.0 - (float(k) + 0.5) / float(N);
    vec2 c = vec2(0.5 + bal * 0.45, y); float d = length((b - c) * u_box.zw); float r = (2.0 + en * 6.0) * u_s; res = overPre(vec4(hsv2rgb(vec3(float(k) / float(N) * 0.8, 0.7, 1.0)), 1.0) * (1.0 - smoothstep(r * 0.5, r, d)) * clamp(en, 0.0, 1.0), res); }
  o = res; }
