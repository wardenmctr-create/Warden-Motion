// 800 rehberi, bölüm 1: renk, onarım ve görüntü analizi (551–575)
//== localcontrast
uniform float p_yaricap, p_guc, p_kenarKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); float L = luma(c); float R = max(p_yaricap, 1.0) * u_s; float acc = 0.0, ws = 0.0;
  for (int i = 0; i < 32; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 32.0); float w = exp(-r * r / (R * R) * 1.5); acc += luma(unpre(texPx(here() + vec2(cos(a), sin(a)) * r))) * w; ws += w; }
  float base = acc / ws; float det = L - base; float edge = smoothstep(0.08, 0.3, abs(det)) * p_kenarKoru / 100.0; float nl = L + det * p_guc / 100.0 * (1.0 - edge * 0.8);
  o = pre(clamp(c * (nl / max(L, 1e-3)), 0.0, 1.0), s.a); }
//== clahe
uniform float p_bolgeSayi, p_kontrastSini, p_karisim;
float rankIn(vec2 tile, float L, float N) { vec2 cs = boxU() / N; vec2 o2 = tile * cs - boxU() * 0.5; float below = 0.0; float lim = p_kontrastSini / 64.0 * 4.0; float clipped = 0.0;
  for (int j = 0; j < 8; j++) for (int i = 0; i < 8; i++) { vec2 q = o2 + (vec2(i, j) + 0.5) / 8.0 * cs; float l = luma(unpre(texU(q))); below += step(l, L); }
  float cdf = below / 64.0; return mix(L, cdf, clamp(p_kontrastSini / 4.0, 0.15, 1.0)); }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); float L = luma(c); float N = max(floor(p_bolgeSayi), 1.0);
  vec2 g = boxUV(here()) * N - 0.5; vec2 t0 = clamp(floor(g), vec2(0.0), vec2(N - 1.0)); vec2 t1 = clamp(t0 + 1.0, vec2(0.0), vec2(N - 1.0)); vec2 f = clamp(g - t0, 0.0, 1.0);
  float r = mix(mix(rankIn(t0, L, N), rankIn(vec2(t1.x, t0.y), L, N), f.x), mix(rankIn(vec2(t0.x, t1.y), L, N), rankIn(t1, L, N), f.x), f.y);
  float nl = mix(L, r, p_karisim / 100.0); o = pre(clamp(c * (nl / max(L, 1e-3)), 0.0, 1.0), s.a); }
//== satlimit
uniform float p_doygunluTava, p_yumusakSini;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); float L = luma(c); vec3 ch = c - L; float sat = length(ch) * 1.7;
  float cap = p_doygunluTava / 100.0 * mix(0.6, 1.0, 1.0 - abs(2.0 * L - 1.0)); float ns = p_yumusakSini > 0.5 ? cap * tanh(sat / max(cap, 1e-3)) : min(sat, cap);
  o = pre(clamp(L + ch * (ns / max(sat, 1e-4)), 0.0, 1.0), s.a); }
//== chromasharpen
uniform float p_yaricap, p_guc, p_esik;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float R = max(p_yaricap, 0.3) * u_s; vec3 acc = vec3(0.0); for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; acc += unpre(texPx(here() + vec2(cos(a), sin(a)) * R)); } acc /= 8.0;
  vec3 d = (c - luma(c)) - (acc - luma(acc)); float m = smoothstep(p_esik / 100.0 * 0.2, p_esik / 100.0 * 0.2 + 0.02, length(d)); o = pre(clamp(c + d * p_guc / 100.0 * m, 0.0, 1.0), s.a); }
//== chromadenoise
uniform float p_kromaYari, p_renkEsig, p_parlakliKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float L = luma(c); float R = max(p_kromaYari, 0.3) * u_s; vec3 acc = c - L; float ws = 1.0;
  for (int i = 0; i < 24; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 24.0); vec3 n = unpre(texPx(here() + vec2(cos(a), sin(a)) * r)); float w = 1.0 - smoothstep(p_renkEsig / 100.0 * 0.5, p_renkEsig / 100.0, length((n - luma(n)) - (c - L))); acc += (n - luma(n)) * w; ws += w; }
  vec3 ch = acc / ws; vec3 r = L + ch; if (p_parlakliKoru < 0.5) r = mix(r, unpre(texture(u_tex, v_uv)), 0.0); o = pre(clamp(r, 0.0, 1.0), s.a); }
//== gamutwarn
uniform float p_hedefProf, p_opaklik; uniform vec3 c_uyariReng;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float sat = length(c - luma(c)); float lim = p_hedefProf < 0.5 ? 0.985 : p_hedefProf < 1.5 ? 0.995 : p_hedefProf < 2.5 ? 0.985 : 0.999;
  float lo = 1.0 - lim; bool clip = (max(c.r, max(c.g, c.b)) >= lim || min(c.r, min(c.g, c.b)) <= lo) && sat > 0.25; float m = clip ? 1.0 : 0.0; m *= 0.6 + 0.4 * step(0.5, fract((here().x + here().y) / (6.0 * u_s)));
  o = overPre(vec4(c_uyariReng, 1.0) * m * p_opaklik / 100.0 * s.a, s); }
//== exposurezones
uniform float p_altEsik, p_ustEsik, p_gosterim, p_yalnizAnalOniz; uniform vec3 c_isaretRenk;
void main() { vec4 s = texture(u_tex, v_uv); if (p_yalnizAnalOniz > 0.5 && u_export > 0.5) { o = s; return; } vec3 c = unpre(s); float L = luma(c) * 100.0;
  float lo = step(L, p_altEsik), hi = step(p_ustEsik, L); if (lo + hi <= 0.0) { o = s; return; }
  if (p_gosterim < 0.5) { float z = step(0.5, fract((here().x - here().y) / (8.0 * u_s) + u_t)); o = overPre(vec4(hi > 0.5 ? vec3(1.0, 0.4, 0.0) : c_isaretRenk, 1.0) * z * s.a, s); return; }
  if (p_gosterim < 1.5) { vec3 fc = hi > 0.5 ? mix(vec3(1.0, 0.8, 0.0), vec3(1.0, 0.0, 0.0), clamp((L - p_ustEsik) / max(100.0 - p_ustEsik, 1.0), 0.0, 1.0)) : mix(vec3(0.0, 0.0, 0.6), c_isaretRenk, clamp(L / max(p_altEsik, 1.0), 0.0, 1.0)); o = pre(fc, s.a); return; }
  o = pre(vec3(1.0), s.a); }
//== histogram2
uniform sampler2D s_anl; uniform float p_anlOn, p_kanal, p_kutuSayi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float bins = max(floor(p_kutuSayi), 16.0); float x = (floor(b.x * bins) + 0.5) / bins; vec4 h = texture(s_anl, vec2(x, 0.5)); float y = 1.0 - b.y;
  vec3 col = vec3(0.0); float a = 0.0; int k = int(p_kanal + 0.5);
  if (k == 0) { col = vec3(step(y, h.r), step(y, h.g), step(y, h.b)); a = max(col.r, max(col.g, col.b)); } else { float v = k == 1 ? h.a : k == 2 ? h.r : k == 3 ? h.g : k == 4 ? h.b : h.a; a = step(y, v); col = k == 2 ? vec3(1, 0.3, 0.3) : k == 3 ? vec3(0.3, 1, 0.3) : k == 4 ? vec3(0.3, 0.5, 1) : vec3(0.9); }
  vec4 bg = vec4(0.05, 0.07, 0.12, 0.85); o = overPre(vec4(col, 1.0) * a * 0.9, bg); }
//== waveform
uniform sampler2D s_anl; uniform float p_anlOn, p_parlakliRgb, p_cizgiGucu, p_referansCizg;
void main() { vec2 b = boxUV(here()); vec4 bg = vec4(0.03, 0.04, 0.07, 0.9); float k = p_cizgiGucu / 100.0 * 1.6; vec3 c;
  if (p_parlakliRgb < 0.5) c = vec3(0.4, 1.0, 0.5) * texture(s_anl, b).a * k;
  else if (p_parlakliRgb < 1.5) { vec4 h = texture(s_anl, b); c = vec3(h.r, h.g, h.b) * k; }
  else { float seg = floor(b.x * 3.0); vec2 u = vec2(fract(b.x * 3.0), b.y); vec4 h = texture(s_anl, u); c = (seg < 0.5 ? vec3(h.r, 0.0, 0.0) : seg < 1.5 ? vec3(0.0, h.g, 0.0) : vec3(0.0, 0.0, h.b)) * k * 1.5; }
  vec4 r = overPre(vec4(clamp(c, 0.0, 1.0), 1.0) * min(1.0, max(c.r, max(c.g, c.b)) * 2.0), bg);
  if (p_referansCizg > 0.5) { float y = 1.0 - b.y; float ln = 0.0; for (int i = 0; i <= 4; i++) ln = max(ln, 1.0 - smoothstep(0.0, 1.5 / max(u_box.w, 1.0), abs(y - float(i) * 0.25))); r = overPre(vec4(0.6, 0.6, 0.6, 1.0) * ln * 0.5, r); }
  o = r; }
//== vectorscope
uniform sampler2D s_anl; uniform float p_anlOn, p_renkUzay, p_olcek, p_referansHede;
void main() { vec2 b = boxUV(here()); vec2 q = (b - 0.5) * 2.0; float sc = p_olcek / 100.0; vec2 uv = q / sc * 0.5 + 0.5; vec4 bg = vec4(0.03, 0.04, 0.07, 0.9) * step(length(q), 1.0);
  vec4 h = all(greaterThanEqual(uv, vec2(0.0))) && all(lessThanEqual(uv, vec2(1.0))) ? texture(s_anl, uv) : vec4(0.0); vec4 r = overPre(vec4(h.rgb / max(h.a, 1e-3), 1.0) * h.a, bg);
  float ring = 1.0 - smoothstep(0.0, 0.01, abs(length(q) - 0.98)); r = overPre(vec4(0.5, 0.5, 0.5, 1.0) * ring, r);
  if (p_referansHede > 0.5) { vec3 T[6] = vec3[6](vec3(1, 0, 0), vec3(1, 1, 0), vec3(0, 1, 0), vec3(0, 1, 1), vec3(0, 0, 1), vec3(1, 0, 1));
    for (int i = 0; i < 6; i++) { vec3 c = T[i] * 0.75; float y = luma(c); vec2 p = vec2((c.b - y) / (p_renkUzay > 0.5 ? 2.03 : 1.8556), -(c.r - y) / (p_renkUzay > 0.5 ? 1.14 : 1.5748)) * 2.0 * sc;
      vec2 d = abs(q - p); float bx = step(max(d.x, d.y), 0.05) * (1.0 - step(max(d.x, d.y), 0.04)); r = overPre(vec4(T[i], 1.0) * bx, r); } }
  o = r; }
//== avgcolor
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_ortalamaOrta; uniform vec2 p_ornekAlan, p_ornekAlanBoyu;
vec4 smp(vec2 uv) { return p_kaynakOn > 0.5 ? texture(s_kaynak, clamp(uv, 0.0, 1.0)) : texPx(boxPx(clamp(uv, 0.0, 1.0))); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 c = p_ornekAlan / 100.0; vec2 sz = p_ornekAlanBoyu / 100.0; vec3 acc = vec3(0.0); float n = 0.0; float vs[25]; vec3 cs[25];
  for (int j = 0; j < 5; j++) for (int i = 0; i < 5; i++) { vec4 v = smp(c + (vec2(i, j) / 4.0 - 0.5) * sz); vec3 u = unpre(v); acc += u * v.a; n += v.a; cs[j * 5 + i] = u; vs[j * 5 + i] = luma(u) + (v.a < 0.1 ? 9.0 : 0.0); }
  vec3 col = acc / max(n, 1e-3);
  if (p_ortalamaOrta > 0.5) { for (int i = 0; i < 13; i++) for (int j = i + 1; j < 25; j++) if (vs[j] < vs[i]) { float t = vs[i]; vs[i] = vs[j]; vs[j] = t; vec3 tc = cs[i]; cs[i] = cs[j]; cs[j] = tc; } col = cs[12]; }
  o = pre(col, s.a); }
//== channelalign
uniform vec2 p_kirmiziKaym, p_maviKaym;
void main() { vec4 s = texture(u_tex, v_uv); vec4 r = texPx(here() - p_kirmiziKaym * u_s), b = texPx(here() - p_maviKaym * u_s); o = vec4(r.r, s.g, b.b, max(s.a, max(r.a, b.a))); }
//== localwb
uniform sampler2D s_bolgeMask; uniform float p_bolgeMaskOn, p_gecis; uniform vec3 c_notrOrne;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); vec3 n = max(c_notrOrne, vec3(0.02)); vec3 g = vec3(luma(n)) / n; g /= max(max(g.r, max(g.g, g.b)), 1e-3) * 0.0 + 1.0;
  float m = 1.0; if (p_bolgeMaskOn > 0.5) { m = 0.0; float R = max(p_gecis, 0.5) * u_s; for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; m += texture(s_bolgeMask, clamp(boxUV(here() + vec2(cos(a), sin(a)) * R * fract(float(i) * 0.618 + 0.2)), 0.0, 1.0)).a; } m /= 12.0; }
  o = pre(clamp(mix(c, c * g, m), 0.0, 1.0), s.a); }
//== highlightrecover
uniform float p_kirpilmaEsig, p_karisim, p_renkGeci;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float th = p_kirpilmaEsig / 100.0; float mx = max(c.r, max(c.g, c.b)); if (mx < th) { o = s; return; }
  vec3 acc = vec3(0.0); float ws = 0.0; for (int i = 0; i < 16; i++) { float a = float(i) * 2.39996; float r = (4.0 + float(i) * 2.0) * u_s; vec3 n = unpre(texPx(here() + vec2(cos(a), sin(a)) * r)); float w = 1.0 - smoothstep(th - 0.1, th, max(n.r, max(n.g, n.b))); acc += n * w; ws += w; }
  vec3 hue = ws > 0.0 ? acc / ws : c; vec3 rec = c; if (p_renkGeci > 0.5 && ws > 0.0) rec = hue / max(max(hue.r, max(hue.g, hue.b)), 1e-3) * mx * 0.97; else rec = c * (th + (1.0 - th) * 0.5) / max(mx, 1e-3);
  float k = smoothstep(th, 1.0, mx) * p_karisim / 100.0; o = pre(clamp(mix(c, rec, k), 0.0, 1.0), s.a); }
//== darkframe
uniform sampler2D s_karanlik; uniform float p_karanlikOn, p_cikarmaMikt, p_negatiflSini;
void main() { vec4 s = texture(u_tex, v_uv); if (p_karanlikOn < 0.5) { o = s; return; } vec3 d = unpre(texture(s_karanlik, clamp(boxUV(here()), 0.0, 1.0))); vec3 r = unpre(s) - d * p_cikarmaMikt / 100.0; if (p_negatiflSini > 0.5) r = max(r, 0.0); o = pre(clamp(r, 0.0, 1.0), s.a); }
//== flatfield
uniform sampler2D s_duzAlan; uniform float p_duzAlanOn, p_normaliz, p_guc;
void main() { vec4 s = texture(u_tex, v_uv); if (p_duzAlanOn < 0.5) { o = s; return; } vec3 f = unpre(texture(s_duzAlan, clamp(boxUV(here()), 0.0, 1.0)));
  vec3 m = vec3(0.0); for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) m += unpre(texture(s_duzAlan, (vec2(i, j) + 0.5) / 4.0)); m /= 16.0;
  vec3 r = unpre(s) * (m * p_normaliz / 100.0) / max(f, vec3(0.02)); o = pre(clamp(mix(unpre(s), r, p_guc / 100.0), 0.0, 1.0), s.a); }
//== bandclean
uniform float p_yon, p_seritEsig, p_koruma;
float lineMean(vec2 px, vec2 dir) { float a = 0.0; for (int i = -16; i <= 16; i++) a += luma(unpre(texPx(px + dir * float(i) * boxU().x * u_s / 32.0))); return a / 33.0; }
float localMean(vec2 px, vec2 dir) { vec2 n = vec2(-dir.y, dir.x); float a = 0.0; for (int i = -3; i <= 3; i++) a += lineMean(px + n * float(i) * 2.0 * u_s, dir); return a / 7.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float corr = 0.0;
  if (p_yon < 0.5 || p_yon > 1.5) { vec2 d = vec2(1, 0); float st = lineMean(here(), d) - localMean(here(), d); corr += abs(st) < p_seritEsig / 100.0 ? st : 0.0; }
  if (p_yon > 0.5) { vec2 d = vec2(0, 1); float st = lineMean(here(), d) - localMean(here(), d); corr += abs(st) < p_seritEsig / 100.0 ? st : 0.0; }
  float det = smoothstep(0.05, 0.25, sobel(here(), u_s)) * p_koruma / 100.0; o = pre(clamp(c - corr * (1.0 - det), 0.0, 1.0), s.a); }
//== fftnotch
uniform vec2 p_frekansMerk; uniform float p_yaricap, p_azaltma, p_simetrikCent;
void main() { vec4 s = texture(u_tex, v_uv); vec2 f = p_frekansMerk / max(u_s, 0.1); vec2 px = here(); float W = clamp(1.0 / max(p_yaricap, 0.001), 4.0, 60.0);
  vec3 I = vec3(0.0), Q = vec3(0.0); float ws = 0.0; for (int j = -6; j <= 6; j++) for (int i = -6; i <= 6; i++) { vec2 o2 = vec2(i, j) * W / 6.0; float w = exp(-dot(o2, o2) / (W * W) * 2.0); vec3 c = unpre(texPx(px + o2)); float ph = TAU * dot(px + o2, f); I += c * cos(ph) * w; Q += c * sin(ph) * w; ws += w; }
  I *= 2.0 / ws; Q *= 2.0 / ws; float ph0 = TAU * dot(px, f); vec3 wave = I * cos(ph0) + Q * sin(ph0); o = pre(clamp(unpre(s) - wave * p_azaltma / 100.0, 0.0, 1.0), s.a); }
//== anisodiff
uniform float p_yineleme, p_kenarIlet, p_adim;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float k = p_kenarIlet / 100.0 * 0.3 + 0.01; int R = int(clamp(p_yineleme / 3.0, 1.0, 8.0)); vec3 acc = c; float ws = 1.0;
  for (int r = 1; r <= 8; r++) { if (r > R) break; for (int i = 0; i < 8; i++) { float a = float(i) * 0.785 + float(r) * 0.3; vec3 n = unpre(texPx(here() + vec2(cos(a), sin(a)) * float(r) * u_s)); float d = length(n - c); float w = exp(-(d * d) / (k * k)) * p_adim / 0.24; acc += n * w; ws += w; } }
  o = pre(acc / ws, s.a); }
//== nlmeans
uniform float p_yamaBoyu, p_aramaBoyu, p_guc;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float h = p_guc / 100.0 * 0.25 + 0.005; float S = floor(p_aramaBoyu * 0.5); float P = floor(p_yamaBoyu * 0.5); vec3 acc = vec3(0.0); float ws = 0.0;
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 o2 = vec2(i, j) * S / 3.0 * u_s; float d = 0.0;
    for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) { vec2 pp = vec2(x, y) * P * u_s; vec3 a = unpre(texPx(here() + pp)), b = unpre(texPx(here() + o2 + pp)); vec3 e = a - b; d += dot(e, e); }
    float w = exp(-d / 9.0 / (h * h)); acc += unpre(texPx(here() + o2)) * w; ws += w; }
  o = pre(acc / ws, s.a); }
//== multiscale
uniform float p_olcekSayi, p_herBantKaza, p_kenarKoru;
vec3 blurR(float r) { vec3 a = vec3(0.0); for (int i = 0; i < 12; i++) { float an = float(i) * 0.5236; a += unpre(texPx(here() + vec2(cos(an), sin(an)) * r * u_s)); } return a / 12.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); vec3 prev = c; vec3 res = c; int N = int(clamp(p_olcekSayi, 1.0, 8.0)); float g = p_herBantKaza / 100.0 - 1.0;
  for (int k = 0; k < 8; k++) { if (k >= N) break; vec3 b = blurR(pow(2.0, float(k))); vec3 band = prev - b; float m = p_kenarKoru > 0.5 ? 1.0 - smoothstep(0.1, 0.3, length(band)) : 1.0; res += band * g * m; prev = b; }
  o = pre(clamp(res, 0.0, 1.0), s.a); }
//== texsimilar
uniform sampler2D s_ornekDoku; uniform float p_ornekDokuOn, p_benzerli, p_olcekTole;
vec3 stats(bool ref, vec2 px, vec2 uv) { float m = 0.0, m2 = 0.0, g = 0.0; for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 o2 = vec2(i, j) * 3.0; float l = ref ? luma(unpre(texture(s_ornekDoku, fract(uv + o2 / 64.0)))) : luma(unpre(texPx(px + o2 * u_s))); m += l; m2 += l * l; } m /= 25.0; return vec3(m, sqrt(max(m2 / 25.0 - m * m, 0.0)), 0.0); }
void main() { vec4 s = texture(u_tex, v_uv); if (p_ornekDokuOn < 0.5) { o = s; return; } vec3 a = stats(false, here(), vec2(0.0)); vec3 b = vec3(0.0); for (int i = 0; i < 4; i++) b += stats(true, vec2(0.0), vec2(float(i) * 0.25 + 0.1, 0.4)); b /= 4.0;
  float d = abs(a.x - b.x) * 2.0 + abs(a.y - b.y) * 4.0 * (1.0 - p_olcekTole / 200.0); float sim = 1.0 - smoothstep(0.0, (1.0 - p_benzerli / 100.0) * 0.6 + 0.02, d);
  o = overPre(vec4(1.0, 0.3, 0.1, 1.0) * sim * 0.6 * s.a, s); }
//== vignettefix
uniform vec2 p_optikMerk; uniform float p_guc, p_yaricap, p_renkDeng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()) - p_optikMerk / 100.0; b.x *= boxU().x / max(boxU().y, 1.0); float r = length(b) / max(p_yaricap / 100.0 * 0.75, 0.01); float k = 1.0 + p_guc / 100.0 * r * r;
  vec3 c = unpre(s) * k; c *= vec3(1.0 + p_renkDeng / 100.0 * 0.1 * r * r, 1.0, 1.0 - p_renkDeng / 100.0 * 0.1 * r * r); o = pre(clamp(c, 0.0, 1.0), s.a); }
//== focusmap
uniform float p_pencere, p_esik; uniform vec3 c_odakReng;
void main() { vec4 s = texture(u_tex, v_uv); float R = max(p_pencere, 3.0) * 0.5 * u_s; float m = 0.0, m2 = 0.0;
  for (int i = 0; i < 16; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 16.0); vec2 p = here() + vec2(cos(a), sin(a)) * r; float lap = luma(unpre(texPx(p))) * 4.0 - luma(unpre(texPx(p + vec2(u_s, 0.0)))) - luma(unpre(texPx(p - vec2(u_s, 0.0)))) - luma(unpre(texPx(p + vec2(0.0, u_s)))) - luma(unpre(texPx(p - vec2(0.0, u_s)))); m += lap; m2 += lap * lap; }
  float v = sqrt(max(m2 / 16.0 - (m / 16.0) * (m / 16.0), 0.0)); float f = smoothstep(p_esik / 100.0 * 0.3, p_esik / 100.0 * 0.3 + 0.05, v); o = overPre(vec4(c_odakReng, 1.0) * f * 0.6 * s.a, s); }
