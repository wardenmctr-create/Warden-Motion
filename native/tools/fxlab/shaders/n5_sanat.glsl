// 550 rehberi: sanatsal ve el yapımı efektler (474–484)
//== stringart
uniform float p_civiYerl, p_civiSayi, p_cercevePayi, p_iplikSayi, p_iplikKali, p_iplikOpak, p_renkSayi, p_kaynakRenkKull, p_dokumaIler, p_tohum;
vec2 nail(float i, float N) { vec2 B = boxU() * 0.5 * (1.0 - p_cercevePayi / 100.0); float t = fract(i / N);
  if (p_civiYerl < 0.5) return vec2(cos(t * TAU), sin(t * TAU)) * min(B.x, B.y);
  if (p_civiYerl < 1.5 || p_civiYerl > 2.5) { float per = 4.0 * t; vec2 p = per < 1.0 ? vec2(mix(-B.x, B.x, per), -B.y) : per < 2.0 ? vec2(B.x, mix(-B.y, B.y, per - 1.0)) : per < 3.0 ? vec2(mix(B.x, -B.x, per - 2.0), B.y) : vec2(-B.x, mix(B.y, -B.y, per - 3.0)); return p; }
  // siluet: merkezden ışın boyunca alfanın bittiği yer
  vec2 d = vec2(cos(t * TAU), sin(t * TAU)); float r = 0.0; for (int k = 0; k < 24; k++) { float rr = float(k) / 23.0 * length(B); if (texU(d * rr).a > 0.5) r = rr; } return d * max(r, 4.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float N = max(floor(p_civiSayi), 3.0); int T = int(clamp(p_iplikSayi * p_dokumaIler / 100.0, 0.0, 400.0)); float sd = seedf(p_tohum);
  vec4 acc = vec4(0.0); float w = max(p_iplikKali, 0.3) * 0.5;
  for (int i = 0; i < 400; i++) { if (i >= T) break; vec2 h = hash2(vec2(float(i), sd)); float a = floor(h.x * N), b = floor(mod(a + N * 0.25 + h.y * N * 0.5, N)); vec2 A = nail(a, N), Bp = nail(b, N);
    vec2 ab = Bp - A; float t = clamp(dot(q - A, ab) / max(dot(ab, ab), 1e-3), 0.0, 1.0); float d = length(q - A - ab * t); float cov = 1.0 - smoothstep(w, w + 0.8 / u_s, d); if (cov <= 0.0) continue;
    vec3 col = p_kaynakRenkKull > 0.5 ? unpre(texU(A + ab * t)) : vec3(0.1); float L = luma(unpre(texU(A + ab * t))); if (p_kaynakRenkKull > 0.5) { float k = max(p_renkSayi, 2.0); col = floor(col * k + 0.5) / k; }
    float dens = p_kaynakRenkKull > 0.5 ? texU(A + ab * t).a : (1.0 - L) * texU(A + ab * t).a; acc = overPre(vec4(col, 1.0) * cov * p_iplikOpak / 100.0 * dens, acc); }
  vec4 nails = vec4(0.0); for (int i = 0; i < 300; i++) { if (float(i) >= N) break; nails = max(nails, vec4(0.75) * (1.0 - smoothstep(1.2, 2.0, length(q - nail(float(i), N))))); }
  o = overPre(nails, acc); }
//== lowpoly
uniform float p_noktaSayi, p_dagilim, p_kenarHass, p_duzensiz, p_renkOrne, p_kenarCizg, p_cizgiKali, p_noktalarSabi, p_tohum; uniform vec3 c_cizgiReng;
vec2 jit(vec2 id, float cs) { float sd = seedf(p_tohum) + (p_noktalarSabi > 0.5 ? 0.0 : floor(u_t * 4.0)); vec2 h = hash2(id + sd) - 0.5; float k = p_dagilim < 0.5 ? 0.0 : p_duzensiz / 100.0 * 0.8;
  vec2 p = (id + 0.5 + h * k) * cs; if (p_dagilim > 1.5) { vec2 g = lumGrad(fromUnit(p), cs * u_s * 0.5); if (length(g) > 0.02) p += normalize(g) * cs * 0.3 * p_kenarHass / 100.0; } return p; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); float cs = sqrt(B.x * B.y / max(p_noktaSayi, 4.0)); vec2 id = floor(q / cs);
  vec2 p00 = jit(id, cs), p10 = jit(id + vec2(1, 0), cs), p01 = jit(id + vec2(0, 1), cs), p11 = jit(id + vec2(1, 1), cs);
  vec2 c = q; vec2 A, Bv, C;
  // hücreyi iki üçgene böl (köşegen), q hangisinde?
  vec2 f = (q - p00); bool upper = cross(vec3(p11 - p00, 0.0), vec3(q - p00, 0.0)).z > 0.0;
  if (!upper) { A = p00; Bv = p10; C = p11; } else { A = p00; Bv = p11; C = p01; }
  vec2 ctr = (A + Bv + C) / 3.0; vec4 col; if (p_renkOrne < 0.5) col = (texU(A * 0.25 + ctr * 0.75) + texU(Bv * 0.25 + ctr * 0.75) + texU(C * 0.25 + ctr * 0.75) + texU(ctr)) * 0.25; else col = texU(ctr);
  if (p_renkOrne > 1.5) { vec4 a = texU(A * 0.3 + ctr * 0.7), b = texU(Bv * 0.3 + ctr * 0.7), cc = texU(C * 0.3 + ctr * 0.7); col = luma(a.rgb) > luma(b.rgb) ? (luma(a.rgb) > luma(cc.rgb) ? a : cc) : (luma(b.rgb) > luma(cc.rgb) ? b : cc); }
  if (p_kenarCizg > 0.5) { float d = min(min(length(q - A - (Bv - A) * clamp(dot(q - A, Bv - A) / dot(Bv - A, Bv - A), 0.0, 1.0)), length(q - Bv - (C - Bv) * clamp(dot(q - Bv, C - Bv) / dot(C - Bv, C - Bv), 0.0, 1.0))), length(q - C - (A - C) * clamp(dot(q - C, A - C) / dot(A - C, A - C), 0.0, 1.0)));
    col = overPre(vec4(c_cizgiReng, 1.0) * (1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali * 0.5 + 0.8 / u_s, d)) * col.a, col); }
  o = col * step(0.001, s.a + col.a); }
//== markerpen
INCLUDE(_mat)
uniform float p_ucGeni, p_darbeUzun, p_darbeYonu, p_yonDuze, p_murekkepYogu, p_ustUsteBinm, p_renkSayi, p_kenarKoru, p_kagitDoku, p_darbelerNesnSabi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float W = max(p_ucGeni, 1.0), L = max(p_darbeUzun, 2.0); vec3 acc = vec3(1.0); float cov = 0.0;
  for (int pass = 0; pass < 2; pass++) { float ang = p_darbeYonu + float(pass) * (p_ustUsteBinm > 0.0 ? 90.0 : 0.0); vec2 r = rot2(-ang) * q; vec2 g = vec2(r.x / L, r.y / W);
    for (int j = -1; j <= 1; j++) { vec2 id = vec2(floor(g.x + hash1(vec2(floor(g.y) + float(j), float(pass))) ), floor(g.y) + float(j)); vec2 h = hash2(id + float(pass) * 7.0);
      float a2 = (h.x - 0.5) * p_yonDuze; vec2 ctr = vec2(id.x + 0.5, id.y + 0.5 + (h.y - 0.5) * 0.5); vec2 lq = rot2(-a2) * ((g - ctr) * vec2(L, W)); float m = (1.0 - smoothstep(W * 0.45, W * 0.55, abs(lq.y))) * (1.0 - smoothstep(L * 0.5, L * 0.5 + W * 0.3, abs(lq.x)));
      vec2 sp = rot2(ang) * vec2(ctr.x * L, ctr.y * W); vec4 sc = texU(sp); if (pass == 1 && hash1(id + 3.0) > p_ustUsteBinm / 100.0) m = 0.0;
      vec3 col = sc.a > 0.0 ? sc.rgb / sc.a : vec3(1.0); float k = max(p_renkSayi, 2.0); col = floor(col * pow(k, 1.0 / 3.0) + 0.5) / pow(k, 1.0 / 3.0);
      float edge = 1.0 + 0.25 * smoothstep(W * 0.3, W * 0.5, abs(lq.y)); acc *= mix(vec3(1.0), col / edge, m * p_murekkepYogu / 100.0 * sc.a); cov = max(cov, m * sc.a); } }
  vec3 paper = p_kagitDoku > 0.0 ? mix(vec3(1.0), matSample(1, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb / max(luma(matBase(1)), 0.1), p_kagitDoku / 100.0) : vec3(1.0);
  vec3 c = acc * paper; float e = smoothstep(0.2, 0.6, sobel(here(), u_s)) * p_kenarKoru / 100.0; c = mix(c, c * 0.35, e * s.a); o = pre(clamp(c, 0.0, 1.0), max(s.a, 0.0)); }
//== tornpaper
INCLUDE(_mat)
uniform float p_parcaSayi, p_bolme, p_ortusme, p_yirtikDeri, p_lifUzun, p_kagitTuru, p_dokuGucu, p_parcaYuks, p_golgeGucu, p_kolajIler, p_tohum;
int matId() { int m[6] = int[6](1, 2, 6, 3, 9, 10); return m[int(clamp(p_kagitTuru, 0.0, 5.0))]; }
vec4 cellAt(vec2 q, out vec2 cid) { float cs = sqrt(boxU().x * boxU().y / max(p_parcaSayi, 2.0)); vec2 n = q / cs + vec2(pnoise(q / max(p_yirtikDeri * 4.0, 2.0)), pnoise(q / max(p_yirtikDeri * 4.0, 2.0) + 9.0)) * p_yirtikDeri / cs * 2.0;
  if (p_bolme > 1.5 && p_bolme < 2.5) { cid = floor(n); return vec4(fract(n).x, fract(n).y, 0.0, 0.0); } vec4 v = voronoi(n + seedf(p_tohum)); cid = v.zw; return v; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 cid; vec4 v = cellAt(q, cid); vec2 h = hash2(cid + 1.3);
  float show = step(hash1(cid + 7.7), p_kolajIler / 100.0); vec2 off = (h - 0.5) * p_ortusme * 0.6; float rot = (h.x - 0.5) * p_ortusme * 0.4;
  vec2 sq = rot2(-rot) * (q - off); vec4 src = texU(sq); if (p_bolme < 0.5) { vec3 qc = floor(unpre(src) * 3.0 + 0.5) / 3.0; src = pre(qc, src.a); }
  float edge = p_bolme > 1.5 && p_bolme < 2.5 ? min(min(v.x, 1.0 - v.x), min(v.y, 1.0 - v.y)) * 2.0 : (v.y - v.x); float fib = smoothstep(0.0, 0.04 + p_lifUzun * 0.01, edge);
  int id = matId(); vec3 paper = matSample(id, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.5, 0.0).rgb; vec3 col = src.a > 0.0 ? src.rgb / src.a : paper;
  col = mix(col, col * paper / max(luma(matBase(id)), 0.1), p_dokuGucu / 100.0); col = mix(vec3(0.97, 0.95, 0.9), col, fib);
  float sh = (1.0 - smoothstep(0.0, 0.08 + p_parcaYuks * 0.01, edge)) * p_golgeGucu / 100.0 * 0.5; col *= 1.0 - sh * 0.5;
  o = pre(clamp(col, 0.0, 1.0), max(src.a, s.a) * show); }
//== quilling
uniform float p_seritGeni, p_seritYuks, p_kivrimYari, p_turSayi, p_doluluk, p_kivrimBici, p_dokuGucu, p_golgeGucu, p_kaynakRengKull, p_olusumIler;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = max(p_kivrimYari, 3.0); vec4 v = voronoi(q / (R * 2.0)); vec2 cid = v.zw;
  vec2 ctr = (floor(q / (R * 2.0)) + 0.0) * R * 2.0; vec4 vv = voronoi(q / (R * 2.0)); vec2 c0 = q / (R * 2.0); // yerel koordinat: hücre merkezine göre
  vec2 g = floor(c0); vec2 bestP = vec2(0.0); float best = 1e9; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = g + vec2(i, j); vec2 p = id + hash2(id); float d = length(c0 - p); if (d < best) { best = d; bestP = p; cid = id; } }
  vec2 l = (c0 - bestP) * R * 2.0; float k = p_kivrimBici > 2.5 ? floor(hash1(cid) * 3.0) : p_kivrimBici; if (k > 0.5 && k < 1.5) l.y += max(0.0, -l.y) * 0.0 + l.x * l.x / R * 0.3; if (k > 1.5) l.x *= 1.6;
  float r = length(l); float a = atan(l.y, l.x); float turns = max(p_turSayi, 0.5); float pitch = R / turns; float sp = fract((r - a / TAU * pitch) / pitch);
  float strip = 1.0 - smoothstep(0.0, max(p_seritGeni / pitch, 0.05) * 0.5, abs(sp - 0.5) - 0.5 + max(p_seritGeni / pitch, 0.05) * 0.5);
  strip *= step(r, R * p_doluluk / 100.0 * 1.2) * step(hash1(cid + 4.0), p_olusumIler / 100.0);
  vec4 src = texU(bestP * R * 2.0); float inside = src.a; vec3 col = p_kaynakRengKull > 0.5 && src.a > 0.0 ? src.rgb / src.a : vec3(0.95, 0.9, 0.8);
  float ridge = sin(sp * PI); col *= 0.7 + 0.3 * ridge * (1.0 + p_seritYuks / 20.0) * 0.8; col *= 1.0 - (vnoise(q * 0.8) - 0.5) * p_dokuGucu / 100.0 * 0.3;
  float shadow = (1.0 - strip) * p_golgeGucu / 100.0 * 0.4 * step(r, R * p_doluluk / 100.0 * 1.2);
  o = pre(clamp(col * (strip > 0.0 ? 1.0 : 1.0 - shadow), 0.0, 1.0), inside * max(strip, shadow * 0.5)); }
//== origami
INCLUDE(_mat)
uniform float p_katDuze, p_katSayi, p_katAcis, p_duzensiz, p_kagit, p_dokuGucu, p_katIziGucu, p_isikAcis, p_katlanmaIler;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); float N = max(p_katSayi, 1.0); float cs = max(B.x, B.y) / N; vec2 id; vec2 f; float tri;
  if (p_katDuze < 1.5) { vec2 g = q / cs; id = floor(g); f = fract(g); tri = p_katDuze < 0.5 ? step(f.x, f.y) : step(0.5, f.x) + step(0.5, f.y) * 2.0; }
  else { float a = atan(q.y, q.x); float r = length(q); id = vec2(floor(a / TAU * N * 2.0), floor(r / cs)); f = vec2(fract(a / TAU * N * 2.0), fract(r / cs)); tri = step(f.x, f.y); }
  vec2 h = hash2(id + tri * 7.3) - 0.5; vec3 n = normalize(vec3(h * tan(radians(p_katAcis)) * (1.0 + p_duzensiz / 50.0), 1.0)); n = mix(vec3(0.0, 0.0, 1.0), n, clamp(p_katlanmaIler / 100.0, 0.0, 1.0));
  vec3 L = normalize(vec3(cos(radians(p_isikAcis)), sin(radians(p_isikAcis)), 1.0)); float lit = 0.55 + 0.6 * max(dot(n, L), 0.0);
  int mid[6] = int[6](1, 2, 6, 3, 9, 10); int m = mid[int(clamp(p_kagit, 0.0, 5.0))]; vec3 paper = matSample(m, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb / max(luma(matBase(m)), 0.1);
  vec4 src = texU((id + (p_katDuze < 1.5 ? 0.5 : 0.0)) * cs); vec3 col = src.a > 0.0 ? unpre(texU(q)) : vec3(1.0); col = mix(col, col * paper, p_dokuGucu / 100.0) * lit;
  float crease = 1.0 - smoothstep(0.0, 0.03, min(min(f.x, 1.0 - f.x), min(f.y, abs(f.x - f.y)))); col *= 1.0 - crease * p_katIziGucu / 100.0 * 0.3;
  o = pre(clamp(col, 0.0, 1.0), s.a); }
//== sandart
uniform float p_tanecikCapi, p_boyutRast, p_yogunluk, p_yiginYuks, p_renkSayi, p_renkVary, p_golgeGucu, p_serpilmeIler, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float d = max(p_tanecikCapi, 0.5); vec2 g = q / d; vec2 id = floor(g); vec2 h = hash2(id + seedf(p_tohum));
  float sz = 0.5 * (1.0 + (h.x - 0.5) * p_boyutRast / 50.0); float grain = 1.0 - smoothstep(sz * 0.8, sz, length(fract(g) - 0.5 - (h - 0.5) * 0.3));
  vec4 src = texPx(fromUnit((id + 0.5) * d)); vec3 c = src.a > 0.0 ? src.rgb / src.a : vec3(0.0); float k = pow(max(p_renkSayi, 2.0), 1.0 / 3.0); c = floor(c * k + 0.5) / k;
  c *= 1.0 + (hash1(id + 3.0) - 0.5) * p_renkVary / 100.0 * 1.5; float heap = fbm01(q * 0.05, 3.0) * p_yiginYuks / 10.0; vec2 gr = vec2(fbm01(q * 0.05 + vec2(0.5, 0.0), 3.0), fbm01(q * 0.05 + vec2(0.0, 0.5), 3.0)) - fbm01(q * 0.05, 3.0);
  c *= 1.0 - (gr.x + gr.y) * p_golgeGucu / 100.0 * 4.0 * p_yiginYuks / 3.0; float present = step(hash1(id + 9.0), p_yogunluk / 100.0) * step(hash1(id + 11.0), p_serpilmeIler / 100.0);
  o = pre(clamp(c, 0.0, 1.0), src.a * grain * present); }
//== scratchart
uniform sampler2D s_altKatm, s_elleKaziMask; uniform float p_altKatmOn, p_elleKaziMaskOn;
uniform float p_altRenkKayn, p_cizgiGeni, p_cizgiYogu, p_kenarDuze, p_kazimaIler; uniform vec3 c_ustYuzeReng, c_altRenk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float L = luma(unpre(s)); vec2 gdir = lumGrad(here(), 1.5 * u_s); float e = smoothstep(0.08, 0.3, sobel(here(), u_s));
  float ang = length(gdir) > 0.01 ? degrees(atan(gdir.y, gdir.x)) + 90.0 : 45.0; vec2 r = rot2(-ang) * q; float sp = max(p_cizgiGeni * 3.0, 2.0);
  float wob = pnoise(q * 0.05) * p_kenarDuze / 100.0 * sp; float line = 1.0 - smoothstep(p_cizgiGeni * 0.5, p_cizgiGeni * 0.5 + 0.7 / u_s, abs(mod(r.y + wob, sp) - sp * 0.5));
  float scratch = max(e, line * smoothstep(1.0 - p_cizgiYogu / 100.0, 1.0, L + 0.2)); if (p_elleKaziMaskOn > 0.5) scratch = max(scratch, texture(s_elleKaziMask, clamp(boxUV(here()), 0.0, 1.0)).a);
  scratch *= step(hash1(floor(q / 40.0)), p_kazimaIler / 100.0 * 1.001);
  vec3 under = p_altRenkKayn < 0.5 ? unpre(s) : p_altRenkKayn < 1.5 ? hsv2rgb(vec3(fract(q.x / max(boxU().x, 1.0) + q.y / max(boxU().y, 1.0) * 0.5), 0.8, 1.0)) : p_altRenkKayn < 2.5 ? c_altRenk : (p_altKatmOn > 0.5 ? unpre(texture(s_altKatm, clamp(boxUV(here()), 0.0, 1.0))) : c_altRenk);
  o = pre(mix(c_ustYuzeReng, under, clamp(scratch, 0.0, 1.0)), s.a); }
//== cubism
uniform float p_duzlemSayi, p_ortusme, p_donusFark, p_konumFark, p_geometriSert, p_renkFark, p_paletSayi, p_kaynagaSada, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = sqrt(boxU().x * boxU().y / max(p_duzlemSayi, 2.0)); vec2 g = q / cs; float sd = seedf(p_tohum);
  vec2 w = g + (vec2(pnoise(g * 0.7 + sd), pnoise(g * 0.7 + sd + 5.0))) * p_ortusme / 100.0 * (1.0 - p_geometriSert / 100.0); vec4 v = voronoi(w + sd); vec2 h = hash2(v.zw + 2.0) - 0.5;
  vec2 ctr = q; vec2 sq = rot2(h.x * p_donusFark) * q + h * p_konumFark; vec4 src = mix(texU(sq), texU(q), p_kaynagaSada / 100.0 * 0.5); vec3 c = src.a > 0.0 ? src.rgb / src.a : vec3(0.0);
  c *= 1.0 + h.y * p_renkFark / 100.0; float k = pow(max(p_paletSayi, 2.0), 1.0 / 3.0); c = floor(c * k + 0.5) / k; float edge = 1.0 - smoothstep(0.0, 0.04, v.y - v.x); c *= 1.0 - edge * 0.5;
  o = pre(clamp(c, 0.0, 1.0), max(src.a, s.a)); }
//== paintbynumber
uniform float p_renkSayi, p_enKucuBolg, p_sinirYumu, p_mod, p_sinirKali, p_numaralaGost, p_yaziBuyu, p_boyamaIler, p_boyamaSira; uniform vec3 c_sinirReng;
float k3() { return max(2.0, floor(pow(max(p_renkSayi, 2.0), 1.0 / 3.0) + 0.5)); }
vec3 qz(vec3 c) { float k = k3(); return floor(c * (k - 1.0) + 0.5) / (k - 1.0); }
vec3 regionCol(vec2 px) { vec3 acc = vec3(0.0); float r = p_enKucuBolg * u_s * 0.15 + p_sinirYumu * 0.05 * u_s; for (int i = 0; i < 5; i++) { float a = float(i) * 1.2566; acc += unpre(texPx(px + vec2(cos(a), sin(a)) * r)); } return qz(acc / 5.0); }
float idx(vec3 c) { float k = k3(); vec3 i = floor(c * (k - 1.0) + 0.5); return i.r + i.g * k + i.b * k * k; }
float seg7(vec2 p, int d) { int m[10] = int[10](63, 6, 91, 79, 102, 109, 125, 7, 127, 111); int b = m[d % 10]; float r = 0.0;
  vec2 a[7] = vec2[7](vec2(0.0, 0.8), vec2(0.45, 0.4), vec2(0.45, -0.4), vec2(0.0, -0.8), vec2(-0.45, -0.4), vec2(-0.45, 0.4), vec2(0.0, 0.0));
  for (int i = 0; i < 7; i++) { if ((b / int(pow(2.0, float(i)))) % 2 == 0) continue; vec2 q = p - a[i]; bool hz = i == 0 || i == 3 || i == 6; vec2 e = hz ? vec2(0.36, 0.08) : vec2(0.08, 0.34); vec2 dd = abs(q) - e; r = max(r, 1.0 - smoothstep(0.0, 0.06, max(dd.x, dd.y))); } return r; }
void main() { vec4 s = texture(u_tex, v_uv); vec3 rc = regionCol(here()); float id = idx(rc); float bw = max(p_sinirKali, 0.3) * u_s; float border = 0.0;
  for (int i = 0; i < 4; i++) { vec2 o2 = (i == 0 ? vec2(1, 0) : i == 1 ? vec2(0, 1) : i == 2 ? vec2(-1, 0) : vec2(0, -1)) * bw; if (idx(regionCol(here() + o2)) != id) border = 1.0; }
  float order = p_boyamaSira < 0.5 ? id / (k3() * k3() * k3()) : p_boyamaSira < 1.5 ? 1.0 - luma(rc) : hash1(vec2(id, 3.0)); bool painted = p_mod > 0.5 && (p_mod < 1.5 || order < p_boyamaIler / 100.0);
  vec3 c = painted ? rc : vec3(1.0);
  if (p_numaralaGost > 0.5 && !painted) { float cs = max(p_yaziBuyu * 3.0, 12.0) * u_s; vec2 cc = (floor(here() / cs) + 0.5) * cs; vec3 cr = regionCol(cc); if (idx(cr) == id && idx(regionCol(cc + vec2(cs * 0.3, 0.0))) == id) {
      vec2 lp = (here() - cc) / (p_yaziBuyu * u_s * 0.5); int n = int(mod(id, 99.0)) + 1; float dg = n < 10 ? seg7(lp, n) : max(seg7(lp * vec2(1.0, 1.0) + vec2(0.7, 0.0), n / 10), seg7(lp - vec2(0.7, 0.0), n % 10)); c = mix(c, c_sinirReng, dg * 0.8); } }
  c = mix(c, c_sinirReng, border); o = pre(c, s.a); }
//== paperrelief
INCLUDE(_mat)
uniform sampler2D s_derinlikKayn; uniform float p_derinlikKaynOn;
uniform float p_seviyeKayn, p_katSayi, p_katArasYuks, p_kenarGeni, p_kenarDuze, p_malzeme, p_dokuGucu, p_kaynakRenkKull, p_golgeGucu, p_isikYonu, p_katAcil;
float lev(vec2 px) { vec4 c = texPx(px); float v = p_seviyeKayn < 0.5 ? luma(unpre(c)) : p_seviyeKayn < 1.5 ? rgb2hsv(unpre(c)).x : (p_derinlikKaynOn > 0.5 ? luma(unpre(texture(s_derinlikKayn, clamp(boxUV(px), 0.0, 1.0)))) : luma(unpre(c)));
  float n = max(p_katSayi, 2.0); vec2 w = vec2(pnoise(toUnit(px) * 0.05), pnoise(toUnit(px) * 0.05 + 4.0)) * p_kenarDuze / 100.0 * 0.1; return floor(clamp(v + w.x, 0.0, 0.999) * n) * step(0.01, c.a); }
void main() { vec4 s = texture(u_tex, v_uv); float l = lev(here()); vec2 ld = -vec2(cos(radians(p_isikYonu)), sin(radians(p_isikYonu))); float sh = 0.0; float hgt = p_katArasYuks * u_s;
  for (int k = 1; k <= 6; k++) { float lk = lev(here() + ld * hgt * float(k) * 0.5); sh = max(sh, clamp((lk - l) / 3.0, 0.0, 1.0) * (1.0 - float(k) / 7.0)); }
  float n = max(p_katSayi, 2.0); vec3 base = p_kaynakRenkKull > 0.5 ? unpre(s) : vec3(mix(0.55, 1.0, l / n)); int mid[6] = int[6](1, 2, 6, 3, 9, 10); int m = mid[int(clamp(p_malzeme, 0.0, 5.0))];
  vec3 paper = matSample(m, toUnit(here()), 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb / max(luma(matBase(m)), 0.1); vec3 c = mix(base, base * paper, p_dokuGucu / 100.0);
  float edge = step(0.5, abs(lev(here() + ld * p_kenarGeni * u_s) - l)); c *= 1.0 + edge * 0.15; c *= 1.0 - sh * p_golgeGucu / 100.0 * 0.8;
  float show = step(l / n, p_katAcil / 100.0 + 0.001); o = pre(clamp(c, 0.0, 1.0), s.a * show); }
