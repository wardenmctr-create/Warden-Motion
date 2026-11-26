// 800 rehberi, bölüm 7: grafik ve harita (708, 710–716, 718–723, 725)
//== stackarea
INCLUDE(_chart)
uniform float p_cizimIler; uniform vec3 c_seriler;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); b.y = 1.0 - b.y; float R = dR(), C = dC(); float x = b.x * (R - 1.0); float r0 = floor(x), f = x - r0; if (b.x > p_cizimIler / 100.0) { o = s; return; }
  float tot = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; float sm = 0.0; for (int c = 0; c < 16; c++) { if (float(c) >= C) break; sm += max(dat(float(r), float(c)), 0.0); } tot = max(tot, sm); }
  float acc = 0.0; vec4 col = vec4(0.04, 0.06, 0.12, 0.85);
  for (int c = 0; c < 16; c++) { if (float(c) >= C) break; float v = mix(max(dat(r0, float(c)), 0.0), max(dat(min(r0 + 1.0, R - 1.0), float(c)), 0.0), f) / max(tot, 1e-6) * 0.9; if (b.y >= acc && b.y < acc + v) col = vec4(serCol(float(c), c_seriler), 1.0); acc += v; }
  o = col; }
//== treemap
INCLUDE(_chart)
uniform float p_bosluk; uniform vec3 c_renkPale;
void main() { vec2 b = boxUV(here()); float R = dR(); float tot = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; tot += max(dat(float(r), 0.0), 0.0); }
  vec4 rect = vec4(0.0, 0.0, 1.0, 1.0); float rem = tot; int pick = -1; vec4 pr = rect;
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; float v = max(dat(float(r), 0.0), 0.0); float k = v / max(rem, 1e-6); bool vert = (rect.z - rect.x) * boxU().x >= (rect.w - rect.y) * boxU().y; vec4 cell = rect;
    if (vert) { cell.z = rect.x + (rect.z - rect.x) * k; rect.x = cell.z; } else { cell.w = rect.y + (rect.w - rect.y) * k; rect.y = cell.w; } rem -= v;
    if (b.x >= cell.x && b.x < cell.z && b.y >= cell.y && b.y < cell.w) { pick = r; pr = cell; } }
  if (pick < 0) { o = vec4(0.0); return; } vec2 gap = p_bosluk / boxU() * 0.5; bool in_ = b.x > pr.x + gap.x && b.x < pr.z - gap.x && b.y > pr.y + gap.y && b.y < pr.w - gap.y;
  vec3 c = serCol(float(pick), c_renkPale); vec2 lp = (b - (pr.xy + pr.zw) * 0.5) * boxU() / 9.0; float n = numAt(lp, dat(float(pick), 0.0)); o = in_ ? vec4(mix(c, vec3(1.0), n), 1.0) : vec4(0.0); }
//== scatterplot
INCLUDE(_chart)
uniform float p_eksen, p_noktaBoyu;
void main() { vec2 b = boxUV(here()); vec2 q = vec2(b.x, 1.0 - b.y); float R = dR(); vec2 mn = vec2(1e9), mx = vec2(-1e9);
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; vec2 p = vec2(dat(float(r), 0.0), dat(float(r), 1.0)); if (p_eksen > 0.5) p = log(max(p, vec2(1e-3))); mn = min(mn, p); mx = max(mx, p); }
  vec4 col = vec4(0.04, 0.06, 0.12, 0.85); float ax = 1.0 - smoothstep(0.0, 0.004, min(q.x - 0.06, q.y - 0.06)) * 1.0; col = overPre(vec4(0.6, 0.6, 0.6, 1.0) * step(min(abs(q.x - 0.06), abs(q.y - 0.06)), 0.004), col);
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; vec2 p = vec2(dat(float(r), 0.0), dat(float(r), 1.0)); if (p_eksen > 0.5) p = log(max(p, vec2(1e-3))); vec2 u = 0.08 + (p - mn) / max(mx - mn, vec2(1e-6)) * 0.86;
    float sz = p_noktaBoyu * (dC() >= 3.0 ? 0.5 + dat(float(r), 2.0) / max(dMax(), 1e-6) : 1.0); float d = length((q - u) * boxU()); col = overPre(vec4(serCol(float(r) * 0.3, vec3(0.2, 0.5, 1.0)), 1.0) * (1.0 - smoothstep(sz * 0.5, sz * 0.5 + 1.0, d)), col); }
  o = col; }
//== radarchart
INCLUDE(_chart)
uniform float p_eksen; uniform vec3 c_seriReng;
void main() { vec2 q = (boxUV(here()) - 0.5) * 2.0; q.y = -q.y; float N = clamp(floor(p_eksen), 3.0, 24.0); float a = atan(q.y, q.x); float r = length(q); float M = dMax();
  float sec = TAU / N; float k = (a + PI * 0.5) / sec; float i0 = floor(mod(k, N)); float f = fract(k); vec4 col = vec4(0.04, 0.06, 0.12, 0.85) * step(r, 1.0);
  for (int g = 1; g <= 4; g++) col = overPre(vec4(0.4, 0.45, 0.55, 1.0) * (1.0 - smoothstep(0.0, 0.01, abs(r - float(g) * 0.22))), col);
  col = overPre(vec4(0.4, 0.45, 0.55, 1.0) * (1.0 - smoothstep(0.0, 0.012, abs(f - 0.0) * r * sec)) * step(r, 0.88), col);
  for (int s = 0; s < 4; s++) { if (float(s) >= dR()) break; float v0 = dat(float(s), mod(i0, dC())) / M * 0.88, v1 = dat(float(s), mod(i0 + 1.0, dC())) / M * 0.88; float rr = mix(v0, v1, f);
    vec3 c = s == 0 ? c_seriReng : serCol(float(s), c_seriReng); col = overPre(vec4(c, 1.0) * (step(r, rr) * 0.3 + (1.0 - smoothstep(0.0, 0.015, abs(r - rr)))), col); }
  o = col; }
//== heatmapchart
INCLUDE(_chart)
uniform float p_hucreAral; uniform vec3 c_renkAral;
void main() { vec2 b = boxUV(here()); float R = dR(), C = dC(); vec2 g = vec2(b.x * C, b.y * R); vec2 id = floor(g), f = fract(g); vec2 gap = p_hucreAral / (boxU() / vec2(C, R)) * 0.5;
  if (any(lessThan(f, gap)) || any(greaterThan(f, 1.0 - gap))) { o = vec4(0.0); return; } float v = dat(id.y, id.x) / dMax(); vec3 c = mix(vec3(0.95, 0.97, 1.0), c_renkAral, clamp(v, 0.0, 1.0));
  float n = numAt((f - 0.5) * boxU() / vec2(C, R) / 7.0, dat(id.y, id.x)); o = vec4(mix(c, v > 0.5 ? vec3(1.0) : vec3(0.1), n), 1.0); }
//== barrace
INCLUDE(_chart)
uniform float p_gorunenOge, p_gecis, p_degerEtik;
void main() { vec2 b = boxUV(here()); float R = dR(), C = dC(); float tt = clamp(u_t / max(u_dur, 0.1), 0.0, 1.0) * (R - 1.0); float r0 = floor(tt), f = smoothstep(0.0, 1.0, fract(tt));
  float M = 1e-6; float vals[16]; for (int c = 0; c < 16; c++) { if (float(c) >= C) break; vals[c] = mix(dat(r0, float(c)), dat(min(r0 + 1.0, R - 1.0), float(c)), f); M = max(M, vals[c]); }
  float N = min(floor(p_gorunenOge), C); vec4 col = vec4(0.04, 0.06, 0.12, 0.85);
  for (int c = 0; c < 16; c++) { if (float(c) >= C) break; float rank = 0.0; for (int d = 0; d < 16; d++) { if (float(d) >= C) break; if (vals[d] > vals[c] || (vals[d] == vals[c] && d < c)) rank += 1.0; } if (rank >= N) continue;
    float y0 = rank / N, y1 = y0 + 0.8 / N; float w = vals[c] / M * 0.82; if (b.y > y0 + 0.05 / N && b.y < y1 && b.x < w + 0.02) col = vec4(serCol(float(c), vec3(0.2, 0.5, 1.0)), 1.0);
    if (p_degerEtik > 0.5) { vec2 lp = (b - vec2(w + 0.08, (y0 + y1) * 0.5 + 0.02 / N)) * boxU() / (boxU().y / N * 0.3); col = overPre(vec4(1.0) * numAt(lp, vals[c]), col); } }
  o = col; }
//== netdiagram
INCLUDE(_chart)
uniform float p_duzen, p_bagUzak;
vec2 node(float i, float n) { if (p_duzen > 1.5) { float lv = floor(log2(i + 1.0)); float idx = i + 1.0 - pow(2.0, lv); return vec2((idx + 0.5) / pow(2.0, lv) - 0.5, lv * 0.18 - 0.4); } float a = i / n * TAU; return vec2(cos(a), sin(a)) * 0.4 * (p_duzen < 0.5 ? 0.9 + 0.1 * sin(i * 3.7) : 1.0); }
void main() { vec2 q = boxUV(here()) - 0.5; q.x *= boxU().x / boxU().y; float R = dR(); float n = 2.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; n = max(n, max(dat(float(r), 0.0), dat(float(r), 1.0)) + 1.0); } n = min(n, 40.0);
  vec4 col = vec4(0.04, 0.06, 0.12, 0.85);
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; vec2 a = node(dat(float(r), 0.0), n), b = node(dat(float(r), 1.0), n); vec2 ab = b - a; float u = clamp(dot(q - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); col = overPre(vec4(0.5, 0.65, 0.9, 1.0) * (1.0 - smoothstep(0.002, 0.005, length(q - a - ab * u))), col); }
  for (int i = 0; i < 40; i++) { if (float(i) >= n) break; vec2 p = node(float(i), n); col = overPre(vec4(serCol(float(i), vec3(1.0, 0.6, 0.2)), 1.0) * (1.0 - smoothstep(0.022, 0.026, length(q - p))), col); }
  o = col; }
//== geoheat
INCLUDE(_chart)
uniform sampler2D t_world_a; uniform float p_yaricap, p_agirligaGoreNorm; uniform vec3 c_renkPale;
void main() { vec2 b = boxUV(here()); vec4 land = texture(t_world_a, b); vec4 col = mix(vec4(0.05, 0.12, 0.25, 1.0), vec4(0.18, 0.22, 0.3, 1.0), land.a); float R = dR(); float h = 0.0; float M = 1e-6;
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; M = max(M, dC() >= 3.0 ? dat(float(r), 2.0) : 1.0); }
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; float lat = p_dvR > 0.5 ? dat(float(r), 0.0) : sin(float(r) * 1.7) * 50.0, lon = p_dvR > 0.5 ? dat(float(r), 1.0) : cos(float(r) * 2.3) * 150.0;
    vec2 p = vec2(lon / 360.0 + 0.5, 0.5 - lat / 180.0); float w = dC() >= 3.0 ? dat(float(r), 2.0) : 1.0; if (p_agirligaGoreNorm > 0.5) w /= M; float d = length((b - p) * boxU()); h += w * exp(-d * d / max(p_yaricap * p_yaricap * 0.25, 1.0)); }
  vec3 hc = mix(c_renkPale, vec3(1.0, 0.85, 0.2), smoothstep(0.4, 1.2, h)); o = overPre(vec4(hc, 1.0) * clamp(h, 0.0, 0.9), col); }
//== contourmap
uniform sampler2D s_yuksekli; uniform float p_yuksekliOn, p_egriAral, p_anaCizgSikl;
float hAt(vec2 px) { return (p_yuksekliOn > 0.5 ? luma(unpre(texture(s_yuksekli, clamp(boxUV(px), 0.0, 1.0)))) : luma(unpre(texPx(px)))) * 5000.0; }
void main() { vec4 s = texture(u_tex, v_uv); float h = hAt(here()); float g = length(vec2(hAt(here() + vec2(1.0, 0.0)) - h, hAt(here() + vec2(0.0, 1.0)) - h)) + 1e-4; float iv = max(p_egriAral, 1.0);
  float d = abs(fract(h / iv + 0.5) - 0.5) * iv / g; float major = step(0.5, 1.0 - abs(fract(h / (iv * max(p_anaCizgSikl, 1.0)) + 0.5) - 0.5) * 2.0 * 0.0) * 0.0; float isMajor = abs(fract(h / (iv * max(p_anaCizgSikl, 1.0)) + 0.5) - 0.5) * iv * max(p_anaCizgSikl, 1.0) / g;
  float line = 1.0 - smoothstep(0.5, 1.2, d); float mline = 1.0 - smoothstep(1.0, 1.8, isMajor); vec3 base = mix(vec3(0.85, 0.9, 0.75), vec3(0.75, 0.6, 0.45), h / 5000.0);
  o = vec4(mix(base, vec3(0.45, 0.3, 0.15), max(line * 0.6, mline)), 1.0); }
//== slopemap
uniform sampler2D s_yuksekli; uniform float p_yuksekliOn, p_egimSini; uniform vec3 c_palet;
void main() { float e = u_s; vec2 b = boxUV(here()); float hx = (p_yuksekliOn > 0.5 ? luma(unpre(texture(s_yuksekli, clamp(boxUV(here() + vec2(e, 0.0)), 0.0, 1.0)))) - luma(unpre(texture(s_yuksekli, clamp(boxUV(here() - vec2(e, 0.0)), 0.0, 1.0)))) : luma(unpre(texPx(here() + vec2(e, 0.0)))) - luma(unpre(texPx(here() - vec2(e, 0.0)))));
  float hy = (p_yuksekliOn > 0.5 ? luma(unpre(texture(s_yuksekli, clamp(boxUV(here() + vec2(0.0, e)), 0.0, 1.0)))) - luma(unpre(texture(s_yuksekli, clamp(boxUV(here() - vec2(0.0, e)), 0.0, 1.0)))) : luma(unpre(texPx(here() + vec2(0.0, e)))) - luma(unpre(texPx(here() - vec2(0.0, e)))));
  float slope = degrees(atan(length(vec2(hx, hy)) * 60.0)); float k = clamp(slope / max(p_egimSini, 1.0), 0.0, 1.0); vec3 c = mix(c_palet, vec3(0.75, 0.15, 0.1), k); c = mix(c, vec3(0.95, 0.85, 0.2), smoothstep(0.3, 0.6, k) * (1.0 - smoothstep(0.6, 0.9, k))); o = vec4(c, 1.0); }
//== hillshade
uniform sampler2D s_yuksekli; uniform float p_yuksekliOn, p_isikAcis, p_yuksekliAbar;
float hAt(vec2 px) { return p_yuksekliOn > 0.5 ? luma(unpre(texture(s_yuksekli, clamp(boxUV(px), 0.0, 1.0)))) : luma(unpre(texPx(px))); }
void main() { vec4 s = texture(u_tex, v_uv); float e = u_s; vec3 n = normalize(vec3(-(hAt(here() + vec2(e, 0.0)) - hAt(here() - vec2(e, 0.0))) * 20.0 * p_yuksekliAbar, -(hAt(here() + vec2(0.0, e)) - hAt(here() - vec2(0.0, e))) * 20.0 * p_yuksekliAbar, 1.0));
  float az = radians(p_isikAcis); vec3 L = normalize(vec3(cos(az), -sin(az), 0.8)); float sh = max(dot(n, L), 0.0); o = vec4(unpre(s) * (0.25 + sh * 0.9), max(s.a, p_yuksekliOn)); }
//== graticule
uniform float p_projeksi, p_dereceAral, p_etiketle;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 xy = (b - 0.5) * vec2(2.0, -1.0); float lon, lat; bool ok = true;
  if (p_projeksi < 0.5) { lon = xy.x * PI; lat = xy.y * PI; } else if (p_projeksi < 1.5) { lon = xy.x * PI; lat = atan(sinh(xy.y * PI)); } else if (p_projeksi < 2.5) { lat = xy.y * PI * 0.97; lon = xy.x * PI / (0.8487 + 0.15 * cos(lat * 1.2)) * 0.85; ok = abs(lon) <= PI; }
  else { vec2 p = vec2(xy.x * 2.0, xy.y * 4.0); float r = length(p); ok = r <= 1.0; float c = asin(clamp(r, 0.0, 1.0)); lat = r < 1e-5 ? 0.0 : asin(clamp(p.y * sin(c) / r, -1.0, 1.0)); lon = atan(p.x * sin(c), r * cos(c)); }
  if (!ok) { o = s; return; } vec2 ll = degrees(vec2(lon, lat)) / max(p_dereceAral, 1.0); vec2 fw = fwidth(ll); vec2 d = abs(fract(ll - 0.5) - 0.5) / max(fw, vec2(1e-4)); float line = 1.0 - min(min(d.x, d.y), 1.0);
  o = overPre(vec4(1.0, 1.0, 1.0, 1.0) * line * 0.7, s); }
//== scalebar
uniform sampler2D s_harita; uniform float p_haritaOn, p_birim, p_hedefGeni;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float kmPerUnit = 40075.0 / max(boxU().x, 1.0); float target = p_hedefGeni * kmPerUnit; float unit = p_birim < 0.5 ? 1000.0 : p_birim < 1.5 ? 1.0 : 0.621371;
  float val = target * unit; float p10 = pow(10.0, floor(log(val) / log(10.0))); float nice = val / p10 < 2.0 ? p10 : val / p10 < 5.0 ? 2.0 * p10 : 5.0 * p10; float L = nice / unit / kmPerUnit;
  vec2 o0 = vec2(-boxU().x * 0.45, boxU().y * 0.4); vec2 lq = q - o0; float bar = step(0.0, lq.x) * step(lq.x, L) * step(abs(lq.y), 3.0); float seg = step(0.5, fract(lq.x / max(L / 4.0, 1.0) * 0.5)); float ticks = step(abs(lq.y + 3.0), 5.0) * (step(abs(lq.x), 1.0) + step(abs(lq.x - L), 1.0));
  vec3 c = mix(vec3(1.0), vec3(0.1), seg); vec4 col = overPre(vec4(c, 1.0) * bar, s); col = overPre(vec4(1.0) * clamp(ticks, 0.0, 1.0), col);
  int iv = int(nice + 0.5); float num = 0.0; int nd = 1; int t = iv; for (int i = 0; i < 6; i++) { if (t < 10) break; t /= 10; nd++; } t = iv;
  for (int i = 0; i < 7; i++) { if (i >= nd) break; vec2 lp = (lq - vec2(L + 14.0 + float(nd - 1 - i) * 11.0, 0.0)) / 9.0; int m[10] = int[10](63, 6, 91, 79, 102, 109, 125, 7, 127, 111); int bb = m[t % 10]; t /= 10;
    vec2 a[7] = vec2[7](vec2(0.0, 0.8), vec2(0.45, 0.4), vec2(0.45, -0.4), vec2(0.0, -0.8), vec2(-0.45, -0.4), vec2(-0.45, 0.4), vec2(0.0, 0.0)); for (int k = 0; k < 7; k++) { if ((bb / int(pow(2.0, float(k)))) % 2 == 0) continue; vec2 qq = lp - a[k]; bool hz = k == 0 || k == 3 || k == 6; vec2 e = hz ? vec2(0.34, 0.08) : vec2(0.08, 0.32); vec2 dd = abs(qq) - e; num = max(num, 1.0 - smoothstep(0.0, 0.08, max(dd.x, dd.y))); } }
  o = overPre(vec4(1.0) * num, col); }
//== compass
uniform float p_buyukluk, p_stil, p_dvN; uniform float p_dv[8];
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - vec2(boxU().x * 0.38, -boxU().y * 0.38); float rot = p_dvN > 0.5 ? p_dv[0] : 0.0; q = rot2(rot) * q; float R = p_buyukluk * 0.5; float r = length(q) / R; float a = atan(q.x, -q.y);
  int N = p_stil < 2.5 ? 4 : 8; float sec = TAU / float(N); float la = mod(a + sec * 0.5, sec) - sec * 0.5; float spike = step(r, 1.0) * step(abs(la), (1.0 - r) * 0.35 * (p_stil < 0.5 ? 0.6 : 1.0)); bool north = abs(a) < sec * 0.5;
  vec4 col = vec4(0.0); col = overPre(vec4(0.1, 0.12, 0.2, 1.0) * step(r, 1.05) * 0.6, col); if (p_stil > 0.5) col = overPre(vec4(0.9, 0.85, 0.7, 1.0) * (1.0 - smoothstep(0.0, 0.04, abs(r - 1.0))), col);
  col = overPre(vec4(north ? vec3(0.9, 0.15, 0.15) : vec3(0.95), 1.0) * spike, col); o = overPre(col, s); }
//== minimap
uniform sampler2D s_kucukHariKayn; uniform float p_kucukHariKaynOn, p_dvN; uniform float p_dv[8]; uniform vec2 p_pencereBoyu; uniform vec3 c_kadrajReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 W = p_pencereBoyu; vec2 o0 = boxU() * 0.5 - W - 10.0; vec2 l = (q - o0) / W; if (any(lessThan(l, vec2(0.0))) || any(greaterThan(l, vec2(1.0)))) { o = s; return; }
  vec4 m = p_kucukHariKaynOn > 0.5 ? texture(s_kucukHariKayn, l) : texPx(boxPx(l)); vec4 col = overPre(m, vec4(0.05, 0.08, 0.15, 1.0)); vec4 fr = p_dvN >= 4.0 ? vec4(p_dv[0], p_dv[1], p_dv[2], p_dv[3]) : vec4(0.35, 0.35, 0.65, 0.65);
  vec2 px = W * 0.004 + 1.5 / W; float inX = step(fr.x - px.x, l.x) * step(l.x, fr.z + px.x) * step(fr.y - px.y, l.y) * step(l.y, fr.w + px.y); float inI = step(fr.x + px.x, l.x) * step(l.x, fr.z - px.x) * step(fr.y + px.y, l.y) * step(l.y, fr.w - px.y);
  col = overPre(vec4(c_kadrajReng, 1.0) * (inX - inI), col); float edge = step(min(min(l.x, 1.0 - l.x), min(l.y, 1.0 - l.y)), 0.01); o = overPre(vec4(1.0) * edge, col); }
