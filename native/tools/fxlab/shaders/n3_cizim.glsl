// Bölüm C: çizim ve baskı efektleri
//== inkdraw
INCLUDE(_mat)
uniform float p_cizgiKali, p_kenarHass, p_ayrinti, p_cizgiDuze, p_murekkepYayi, p_murekkepYogu, p_orijinalRenkKoru, p_kagitDoku, p_kagitTuru, p_dokuGucu, p_taramaYogu, p_dinamikCizg, p_yenilenmAral; uniform vec3 c_murekkepReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float tick = p_dinamikCizg > 0.5 ? floor(u_t * 24.0 / max(p_yenilenmAral, 1.0)) : 0.0;
  vec2 j = (vec2(pnoise(q * 0.05 + tick * 1.7), pnoise(q * 0.05 + 9.0 + tick)) ) * p_cizgiDuze / 100.0 * 3.0 * u_s; vec2 px = here() + j;
  float st = max(p_cizgiKali * u_s * 0.6, 0.6); float e = sobel(px, st) * (0.5 + p_kenarHass / 50.0); float ea = length(alphaGrad(px, st)) * 2.0;
  float detail = mix(0.6, 0.15, p_ayrinti / 100.0); float line = smoothstep(detail, detail + 0.25, max(e, ea));
  float bleed = 0.0; if (p_murekkepYayi > 0.0) { for (int i = 0; i < 6; i++) { float a = float(i) * 1.047; bleed = max(bleed, sobel(px + vec2(cos(a), sin(a)) * p_murekkepYayi * u_s, st)); } line = max(line, smoothstep(detail + 0.2, detail + 0.6, bleed) * 0.6); }
  float L = luma(unpre(s)); float hatch = 0.0; if (p_taramaYogu > 0.0) { vec2 r = rot2(45.0) * q; float h1 = step(0.5, fract(r.y / 5.0)) * step(L, 0.45); vec2 r2 = rot2(-45.0) * q; float h2 = step(0.5, fract(r2.y / 5.0)) * step(L, 0.25);
    hatch = max(h1, h2) * p_taramaYogu / 100.0 * (0.7 + 0.3 * pnoise(q * 0.3)); }
  float ink = clamp(max(line, hatch) * p_murekkepYogu / 100.0, 0.0, 1.0) * s.a;
  int id = p_kagitTuru < 0.5 ? 1 : p_kagitTuru < 1.5 ? 6 : p_kagitTuru < 2.5 ? 9 : 3; vec3 paper = vec3(1.0);
  if (p_kagitDoku > 0.5) { vec3 m = matSample(id, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb; paper = mix(vec3(1.0), m / max(luma(matBase(id)), 0.05) * (id == 1 ? 1.0 : 0.85), p_dokuGucu / 100.0 * 2.0); }
  vec3 base = mix(paper, unpre(s) * paper, p_orijinalRenkKoru / 100.0); vec3 c = mix(base, c_murekkepReng, ink); o = pre(clamp(c, 0.0, 1.0), s.a); }
//== embroidery
INCLUDE(_mat)
uniform float p_dikisTuru, p_dikisUzun, p_iplikKali, p_dikisAral, p_dikisYonu, p_dikisYonl, p_dikisDuze, p_iplikKaba, p_orijinalRenkKull, p_renkSayi, p_kumasAltl, p_kumasTuru, p_kenarDiki, p_islenmeIler, p_sekilDegiTaki; uniform vec3 c_ozelIpliReng;
vec3 quant(vec3 c) { float n = max(p_renkSayi, 2.0); float k = pow(n, 1.0 / 3.0); return floor(c * k + 0.5) / k; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float ang = p_dikisYonu;
  if (p_dikisYonl > 0.5) { vec2 g = p_dikisYonl < 1.5 ? alphaGrad(here(), 2.0 * u_s) + lumGrad(here(), 2.0 * u_s) * 0.5 : lumGrad(here(), 3.0 * u_s); if (length(g) > 1e-3) ang = degrees(atan(g.y, g.x)) + 90.0; }
  float L = max(p_dikisUzun, 1.0); float W = max(p_iplikKali, 0.5) + p_dikisAral; vec2 r = rot2(-ang) * q; float row = floor(r.y / W); float off = p_dikisTuru > 0.5 && p_dikisTuru < 1.5 ? 0.0 : mod(row, 2.0) * 0.5 * L;
  if (p_dikisTuru > 3.5) r.x += sin(r.y / W * PI) * W * 0.5; float cx = (r.x + off) / L; float id = floor(cx); float fx = fract(cx); float fy = fract(r.y / W);
  vec2 jit = (hash2(vec2(id, row)) - 0.5) * p_dikisDuze / 100.0 * 0.4; fx += jit.x; fy += jit.y;
  float thr = max(p_iplikKali, 0.5) / W; float yy = (fy - 0.5) / max(thr * 0.5, 0.05);
  float stitch; if (p_dikisTuru > 2.5 && p_dikisTuru < 3.5) stitch = 1.0 - smoothstep(0.8, 1.0, abs(yy)); else if (p_dikisTuru > 1.5 && p_dikisTuru < 2.5) { vec2 f = vec2(fx, fy) - 0.5; stitch = max(1.0 - smoothstep(0.06, 0.12, abs(f.x - f.y)), 1.0 - smoothstep(0.06, 0.12, abs(f.x + f.y))); }
  else stitch = (1.0 - smoothstep(0.8, 1.0, abs(yy))) * smoothstep(0.0, 0.08, fx) * smoothstep(1.0, 0.92, fx);
  float shade = 0.7 + 0.3 * sqrt(max(0.0, 1.0 - yy * yy)) + (vnoise(r * vec2(0.5, 3.0)) - 0.5) * p_iplikKaba / 100.0 * 0.6; shade *= 0.85 + 0.3 * fx * (1.0 - fx) * 2.0;
  vec3 thread = p_orijinalRenkKull > 0.5 ? quant(unpre(texPx(here() - (vec2(fx, fy) - 0.5) * vec2(L, W) * 0.0))) : c_ozelIpliReng;
  float reveal = step(hash1(vec2(id, row) + 0.37), p_islenmeIler / 100.0 * 1.001);
  float edge = 0.0; if (p_kenarDiki > 0.5) { float d = innerDist(here(), 4.0 * u_s); edge = smoothstep(4.0 * u_s, 3.0 * u_s, d) * step(0.001, s.a); }
  float a = s.a * stitch * reveal; vec3 col = thread * shade; if (edge > 0.0) { float sat = 0.75 + 0.25 * sin(q.x * 2.0 + q.y * 2.0); col = mix(col, quant(unpre(s)) * 0.7 * sat, edge); a = max(a, edge * s.a); }
  vec4 res = pre(clamp(col, 0.0, 1.0), clamp(a, 0.0, 1.0));
  if (p_kumasAltl > 0.5) { int id2 = p_kumasTuru < 0.5 ? 10 : 11; vec3 fab = matSample(id2, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb; vec3 fc = p_kumasTuru > 2.5 && p_kumasTuru < 3.5 ? vec3(0.2, 0.3, 0.55) * fab / max(luma(fab), 0.05) * 0.5 : fab;
    res = overPre(res, vec4(fc, 1.0) * max(s.a, dilateA(here(), 6.0 * u_s))); }
  o = res; }
//== pencilhatch
INCLUDE(_mat)
uniform float p_tarama, p_cizgiKali, p_cizgiAral, p_cizgiUzun, p_birinciAci, p_ikinciAci, p_taramaKatm, p_kalemBasi, p_tonHass, p_cizgiDuze, p_ucYumu, p_kagitDoku, p_cizgilerCanl, p_yenilenmAral; uniform vec3 c_kalemReng;
float hatchLayer(vec2 q, float ang, float k, float tick) { vec2 r = rot2(-ang) * q; float sp = max(p_cizgiAral, 1.0); float row = floor(r.y / sp); float segL = max(p_cizgiUzun, 2.0);
  float sx = r.x / segL + hash1(vec2(row, k + tick)) * 3.0; float seg = floor(sx); float fx = fract(sx); float jy = (hash1(vec2(seg, row + k * 7.0 + tick)) - 0.5) * p_cizgiDuze / 100.0 * sp;
  float y = abs(mod(r.y + jy, sp) - sp * 0.5); float w = max(p_cizgiKali, 0.3) * 0.5; float taper = smoothstep(0.0, p_ucYumu / 100.0 * 0.4 + 0.01, fx) * smoothstep(1.0, 1.0 - p_ucYumu / 100.0 * 0.4 - 0.01, fx);
  return (1.0 - smoothstep(w * 0.5, w + 0.6 / max(u_s, 0.1), y)) * taper * step(0.08, hash1(vec2(seg + 0.5, row))); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float tick = p_cizgilerCanl > 0.5 ? floor(u_t * 24.0 / max(p_yenilenmAral, 1.0)) : 0.0;
  float L = luma(unpre(s)); float dark = clamp((1.0 - L) * (0.5 + p_tonHass / 100.0), 0.0, 1.0); int K = int(clamp(p_taramaKatm, 1.0, 6.0)); float acc = 0.0;
  for (int k = 0; k < 6; k++) { if (k >= K) break; float th = float(k) / float(K); if (dark < th + 0.05) continue; float ang = p_tarama < 0.5 ? p_birinciAci : p_tarama < 1.5 ? (k % 2 == 0 ? p_birinciAci : p_ikinciAci) : p_birinciAci + float(k) * 180.0 / float(K);
    if (p_tarama > 2.5) { vec2 g = lumGrad(here(), 2.0 * u_s); if (length(g) > 1e-3) ang = degrees(atan(g.y, g.x)) + 90.0 + float(k) * 30.0; }
    acc = max(acc, hatchLayer(q, ang, float(k), tick) * smoothstep(th, th + 0.15, dark)); }
  float edge = smoothstep(0.3, 0.7, sobel(here(), u_s) + length(alphaGrad(here(), u_s))); acc = max(acc, edge * 0.8);
  vec3 paper = vec3(0.98, 0.97, 0.94); if (p_kagitDoku > 0.5) paper = matSample(1, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb;
  vec3 c = mix(paper, c_kalemReng * (0.6 + 0.4 * vnoise(q * 0.8)), acc * p_kalemBasi / 100.0 * 1.4); o = pre(clamp(c, 0.0, 1.0), s.a); }
//== photocopy
uniform float p_kontrast, p_parlakli, p_tonerYogu, p_siyahEsig, p_renkKayb, p_baskiCozu, p_kenarAsin, p_tonerTasm, p_gurultu, p_kagitDoku, p_lekeYogu, p_baskiCizg, p_kopyaNesl, p_saydamliKoru; uniform vec3 c_tonerReng, c_kagitReng;
void main() { float gen = max(p_kopyaNesl, 1.0); float g = log2(gen + 1.0); float res = mix(3.0, 0.5, p_baskiCozu / 100.0) * (1.0 + g * 0.35);
  vec2 px = here() + vec2(0.0, sin(here().y * 0.01) * g * 0.6 * u_s); vec2 cell = floor(px / max(res * u_s, 1.0)) * max(res * u_s, 1.0); vec4 s = texture(u_tex, v_uv); vec4 sp = texPx(mix(px, cell, 0.6));
  vec3 c = unpre(sp); float L = luma(c); L = (L - 0.5) * (1.0 + p_kontrast / 50.0 + g * 0.25) + 0.5 + p_parlakli / 100.0;
  float n = (hash1(floor(px / max(u_s, 0.5)) + floor(u_t * 12.0)) - 0.5) * p_gurultu / 100.0 * (1.0 + g * 0.3); float th = p_siyahEsig / 100.0;
  float toner = smoothstep(th + 0.08, th - 0.08 - p_tonerTasm * 0.02, L + n) * p_tonerYogu / 100.0 * (1.0 + 0.15 * g);
  float wear = p_kenarAsin / 100.0 * smoothstep(0.0, 1.0, 1.0 - innerDist(here(), 6.0 * u_s) / (6.0 * u_s)) * step(0.5, hash1(floor(px / (2.0 * u_s)))); toner *= 1.0 - wear;
  if (p_baskiCizg > 0.5) toner = max(toner, step(0.985, hash1(vec2(floor(px.x / (1.5 * u_s)), 3.0))) * 0.6 * step(0.3, vnoise(vec2(px.x * 0.01, px.y * 0.002))));
  float spots = step(1.0 - p_lekeYogu / 100.0 * 0.03 * (1.0 + g * 0.2), hash1(floor(px / (3.0 * u_s)) + 7.0)); toner = max(toner, spots * 0.8);
  vec3 paper = c_kagitReng * (1.0 - p_kagitDoku / 100.0 * 0.15 * vnoise(toUnit(px) * 0.4)) * (1.0 - g * 0.03);
  vec3 colKept = mix(c, vec3(luma(c)), p_renkKayb / 100.0); vec3 outc = mix(mix(paper, paper * colKept, 1.0 - p_renkKayb / 100.0), c_tonerReng, clamp(toner, 0.0, 1.0));
  o = pre(clamp(outc, 0.0, 1.0), p_saydamliKoru > 0.5 ? s.a : 1.0); }
//== datacorrupt
uniform float p_bozulmaMikt, p_blokBuyu, p_blokYogu, p_blokKaym, p_hareketYayi, p_renkBozu, p_cozunurl, p_oncekiKareTasi, p_kareHafi, p_donmusBlokSure, p_yenilenmAral, p_otomatikTeti, p_elleTeti, p_hareketYonuTaki, p_sahneDegiHafi, p_aniParlDegi, p_tohum;
void main() { vec2 px = here(); float amt = (p_otomatikTeti > 0.5 ? p_bozulmaMikt : p_elleTeti) / 100.0; float tick = floor(u_t * 24.0 / max(p_yenilenmAral, 1.0)); float sd = seedf(p_tohum);
  float bs = max(p_blokBuyu, 2.0) * u_s; vec2 bid = floor(px / bs); float h = hash1(bid + sd + tick * 0.37); float frozen = floor(u_t * 24.0 / max(p_donmusBlokSure, 1.0));
  vec4 c = texture(u_tex, v_uv);
  if (h < p_blokYogu / 100.0 * amt * 1.5) { vec2 hh = hash2(bid + frozen + sd); vec2 off = (hh - 0.5) * 2.0 * p_blokKaym * u_s;
    vec2 mv = p_hareketYonuTaki > 0.5 ? lumGrad(bid * bs, bs) : vec2(0.0); vec2 smear = normalize(mv + vec2(1e-3, 0.0)) * fract(px.x / bs) * bs * p_hareketYayi / 100.0 * 2.0;
    vec2 src = bid * bs + mod(px, bs) * mix(1.0, 0.25, step(0.7, hh.x) * p_oncekiKareTasi / 100.0) + off + smear; c = texPx(src);
    float rl = mix(1.0, 8.0, 1.0 - p_cozunurl / 100.0); vec2 cs = floor(px / (rl * u_s)) * rl * u_s; c = mix(c, texPx(cs + off), 1.0 - p_cozunurl / 100.0);
    if (hash1(bid + 5.0 + tick) < p_renkBozu / 100.0) { vec3 u = unpre(c); u = vec3(u.g, u.b * 1.2, u.r) * vec3(1.1, 0.9, 1.2); c = pre(clamp(u, 0.0, 1.0), c.a); }
    if (p_aniParlDegi > 0.5 && hash1(bid + 11.0 + tick) < 0.08 * amt) c.rgb = min(c.rgb * 1.8, vec3(c.a)); }
  else if (hash1(vec2(bid.y, tick + 3.0)) < amt * 0.15) { c = texPx(px + vec2((hash1(vec2(bid.y, tick)) - 0.5) * p_blokKaym * u_s, 0.0)); }
  o = c; }
