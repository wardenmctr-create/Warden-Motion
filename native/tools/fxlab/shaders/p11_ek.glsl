// 550/800 rehberlerinden ek efektler: zamansal mat ve onarım, hareketli fotoğraf, hareket büyütme, kukla pimi, grafikler, kabartı
//== movingmatte
INCLUDE(_hist)
uniform float p_gecmis, p_hareketEsig, p_golgeBast;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 3.0) { o = s; return; } vec3 bg = vec3(0.0); float ws = 0.0;
  for (int i = 1; i < 16; i++) { if (float(i) >= N) break; vec4 h = hist(float(i), v_uv); bg += unpre(h); ws += 1.0; } bg /= max(ws, 1.0); vec3 c = unpre(s); float d = length(c - bg);
  float sh = (luma(c) < luma(bg) && length((c / max(luma(c), 0.02)) - (bg / max(luma(bg), 0.02))) < 0.3) ? p_golgeBast / 100.0 : 0.0; float m = smoothstep(p_hareketEsig / 100.0 * 0.5, p_hareketEsig / 100.0 + 0.05, d) * (1.0 - sh);
  o = pre(c, s.a * m); }
//== motiondirmatte
INCLUDE(_hist)
uniform float p_yon, p_aciTole, p_asgariHiz, p_akisYumu;
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 3.0) { o = s; return; } vec2 px = 1.0 / u_res; float r = max(p_akisYumu, 1.0); mat2 A = mat2(0.0); vec2 bvec = vec2(0.0);
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 uv = v_uv + vec2(i, j) * px * r; float Ix = (luma(hist(0.0, uv + vec2(px.x, 0.0)).rgb) - luma(hist(0.0, uv - vec2(px.x, 0.0)).rgb)) * 0.5; float Iy = (luma(hist(0.0, uv + vec2(0.0, px.y)).rgb) - luma(hist(0.0, uv - vec2(0.0, px.y)).rgb)) * 0.5;
    float It = (luma(hist(2.0, uv).rgb) - luma(hist(1.0, uv).rgb)) * 0.5; A += mat2(Ix * Ix, Ix * Iy, Ix * Iy, Iy * Iy); bvec += vec2(Ix * It, Iy * It); }
  float det = A[0][0] * A[1][1] - A[0][1] * A[1][0]; vec2 v = abs(det) > 1e-6 ? -inverse(A) * bvec : vec2(0.0); float sp = length(v) / max(u_s, 0.1) * 30.0; float ang = degrees(atan(v.y, v.x)); float d = abs(mod(ang - p_yon + 540.0, 360.0) - 180.0);
  float m = step(p_asgariHiz * 0.1, sp) * (1.0 - smoothstep(p_aciTole, p_aciTole + 10.0, d)); o = pre(unpre(s), s.a * m); }
//== cinemagraph
INCLUDE(_hist)
uniform sampler2D s_hareketMask; uniform float p_hareketMaskOn, p_maskeyiTersCevi, p_kenarYumu, p_maskeOniz;
void main() { vec4 s = texture(u_tex, v_uv); vec4 fr = histN() > 0.0 ? hist(0.0, v_uv) : s; float m = 0.0; float R = max(p_kenarYumu, 0.5) * u_s;
  if (p_hareketMaskOn > 0.5) { for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; m += texture(s_hareketMask, clamp(boxUV(here() + vec2(cos(a), sin(a)) * R * fract(float(i) * 0.618 + 0.2)), 0.0, 1.0)).a; } m /= 12.0; } else m = 1.0 - smoothstep(0.25, 0.35, length(boxUV(here()) - 0.5));
  if (p_maskeyiTersCevi > 0.5) m = 1.0 - m; vec4 c = mix(fr, s, m); if (p_maskeOniz > 0.5 && u_export < 0.5) c = overPre(vec4(1.0, 0.2, 0.2, 1.0) * m * 0.35, c); o = c; }
//== motionmagnify
INCLUDE(_hist)
uniform float p_hareketBuyu, p_maksimumSapm, p_gurultuKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 3.0) { o = s; return; } vec4 avg = (hist(1.0, v_uv) + hist(2.0, v_uv)) * 0.5; vec4 d = s - avg; float n = length(d.rgb); d *= smoothstep(p_gurultuKoru / 100.0 * 0.05, p_gurultuKoru / 100.0 * 0.05 + 0.02, n);
  vec4 r = s + clamp(d * (p_hareketBuyu - 1.0), -p_maksimumSapm / 100.0, p_maksimumSapm / 100.0); o = clamp(r, 0.0, 1.0); }
//== framerepair
INCLUDE(_hist)
uniform float p_kareSeci, p_tahminYont, p_hareketGuve, p_sahneKesiKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 3.0) { o = s; return; } vec4 a = hist(1.0, v_uv), b = hist(2.0, v_uv); vec4 avg = (a + b) * 0.5;
  // karenin tamamına bakılır: 4×4 örnekte komşu karelere göre aykırı mı?
  float dev = 0.0, nb = 0.0; for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) { vec2 uv = (vec2(i, j) + 0.5) / 4.0; vec4 c = hist(0.0, uv), p = hist(1.0, uv), n = hist(2.0, uv); dev += length(c.rgb - (p.rgb + n.rgb) * 0.5); nb += length(p.rgb - n.rgb); }
  bool bad = dev > nb * (1.0 + p_hareketGuve / 50.0) + 0.6; if (p_sahneKesiKoru > 0.5 && nb > 4.0) bad = false; if (!bad) { o = s; return; } o = p_tahminYont < 0.5 ? a : avg; }
//== puppetpin
uniform vec2 p_pimKonu; uniform float p_pimTuru, p_pimEtkiAlan, p_sertlik, p_agiGost, p_dvN; uniform float p_dv[8];
void main() { vec2 q = toUnit(here()); vec2 start = p_dvN >= 2.0 ? vec2(p_dv[0], p_dv[1]) : p_pimKonu; vec2 disp = p_pimKonu - start; float R = max(p_pimEtkiAlan, 1.0) * (1.0 + (1.0 - p_sertlik / 100.0));
  float w = exp(-dot(q - p_pimKonu, q - p_pimKonu) / (R * R)); if (p_pimTuru > 0.5) w = 0.0; vec4 c = texU(q - disp * w);
  if (p_agiGost > 0.5 && u_export < 0.5) { vec2 g = abs(fract((q - disp * w) / 20.0) - 0.5); c = overPre(vec4(0.3, 0.7, 1.0, 1.0) * (1.0 - smoothstep(0.0, 0.05, min(g.x, g.y))) * 0.5 * c.a, c); c = overPre(vec4(1.0, 0.8, 0.2, 1.0) * (1.0 - smoothstep(4.0, 6.0, length(q - p_pimKonu))), c); }
  o = c; }
//== animchart
INCLUDE(_chart)
uniform float p_grafikTuru, p_sifirdanBasl, p_degerEtik, p_izgaraCizg, p_yaziBoyu, p_belirmeIler; uniform vec3 c_anaRenk;
void main() { vec2 b = boxUV(here()); vec2 q = vec2(b.x, 1.0 - b.y); float R = dR(); float M = dMax(); float g = p_belirmeIler / 100.0; vec4 col = vec4(0.04, 0.06, 0.12, 0.85); int k = int(p_grafikTuru + 0.5);
  if (p_izgaraCizg > 0.5 && k < 3) for (int i = 1; i <= 4; i++) col = overPre(vec4(0.3, 0.35, 0.45, 1.0) * (1.0 - smoothstep(0.0, 0.003, abs((k == 1 ? q.x : q.y) - 0.1 - float(i) * 0.2))), col);
  if (k == 0 || k == 1) { float ax = k == 0 ? q.x : 1.0 - q.y; float ay = k == 0 ? q.y : q.x; float id = floor(ax * R); float f = fract(ax * R); float v = dat(id, 0.0) / M * 0.85 * clamp(g * R - id, 0.0, 1.0);
    if (f > 0.15 && f < 0.85 && ay > 0.05 && ay < 0.05 + v) col = vec4(serCol(id * 0.15, c_anaRenk), 1.0);
    if (p_degerEtik > 0.5) { vec2 lp = vec2((f - 0.5), ay - 0.08 - v) * boxU() / max(p_yaziBoyu * 0.5, 4.0); if (k == 1) lp = vec2(ay - 0.08 - v, f - 0.5) * boxU().yx / max(p_yaziBoyu * 0.5, 4.0); col = overPre(vec4(1.0) * numAt(lp, dat(id, 0.0)), col); } }
  else if (k == 2) { float best = 1e9; vec2 prev = vec2(0.05, 0.1 + dat(0.0, 0.0) / M * 0.8); for (int r = 1; r < 64; r++) { if (float(r) >= R) break; float x = 0.05 + float(r) / (R - 1.0) * 0.9; if (x > 0.05 + g * 0.9 + 1e-3) break; vec2 p = vec2(x, 0.1 + dat(float(r), 0.0) / M * 0.8);
      vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); best = min(best, length((q - prev - ab * u) * boxU())); prev = p; } col = overPre(vec4(c_anaRenk, 1.0) * (1.0 - smoothstep(2.0, 3.5, best)), col); }
  else { vec2 c = (q - 0.5) * boxU() / min(boxU().x, boxU().y); float r = length(c); float a = fract(atan(c.x, c.y) / TAU + 1.0); float tot = 0.0; for (int i = 0; i < 64; i++) { if (float(i) >= R) break; tot += max(dat(float(i), 0.0), 0.0); }
    float acc = 0.0; for (int i = 0; i < 64; i++) { if (float(i) >= R) break; float v = max(dat(float(i), 0.0), 0.0) / tot; if (a >= acc && a < acc + v && r < 0.42 && a < g) col = vec4(serCol(float(i), c_anaRenk) * (0.9 + 0.1 * step(0.4, r)), 1.0); acc += v; } }
  o = col; }
//== timeline
INCLUDE(_chart)
uniform float p_yon, p_aralik, p_olayAral, p_cizgiKali, p_yaziBoyu, p_ilerleme, p_etiketCakiOnle; uniform vec3 c_cizgiReng;
void main() { vec2 b = boxUV(here()); vec2 q = p_yon < 0.5 ? b : b.yx; float R = dR(); float mn = 1e9, mx = -1e9; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; mn = min(mn, dat(float(r), 0.0)); mx = max(mx, dat(float(r), 0.0)); }
  float prog = p_ilerleme / 100.0; vec4 col = vec4(0.0); float L = boxU().x; float ln = (1.0 - smoothstep(p_cizgiKali / L * 0.5, p_cizgiKali / L * 0.5 + 0.002, abs(q.y - 0.5))) * step(q.x, 0.05 + 0.9 * prog); col = overPre(vec4(c_cizgiReng, 1.0) * ln, col);
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; float x = p_aralik < 0.5 ? 0.05 + (dat(float(r), 0.0) - mn) / max(mx - mn, 1e-6) * 0.9 : 0.05 + float(r) / max(R - 1.0, 1.0) * 0.9; if (x > 0.05 + 0.9 * prog + 1e-4) continue;
    float dot_ = 1.0 - smoothstep(0.008, 0.012, length((q - vec2(x, 0.5)) * vec2(L / boxU().y, 1.0) * vec2(boxU().y / L, 1.0))); col = overPre(vec4(1.0) * dot_, col);
    float up = (p_etiketCakiOnle > 0.5 && mod(float(r), 2.0) > 0.5) ? -1.0 : 1.0; vec2 lp = (q - vec2(x, 0.5 - up * 0.12)) * boxU() / max(p_yaziBoyu * 0.5, 4.0); col = overPre(vec4(1.0) * numAt(lp, dat(float(r), 0.0)), col); }
  o = col; }
//== sankey
INCLUDE(_chart)
uniform float p_bantKivr, p_dugumAral, p_degerEtik;
void main() { vec2 b = boxUV(here()); float R = dR(); float ns = 1.0, nt = 1.0, tot = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; ns = max(ns, dat(float(r), 0.0) + 1.0); nt = max(nt, dat(float(r), 1.0) + 1.0); tot += max(dat(float(r), 2.0), 0.0); }
  if (p_dvR < 0.5) { ns = 3.0; nt = 3.0; } float gap = p_dugumAral / boxU().y; float usable = 1.0 - gap * max(ns, nt); vec4 col = vec4(0.04, 0.06, 0.12, 0.85);
  float sOff[16]; float tOff[16]; float sAcc = gap * 0.5, tAcc = gap * 0.5; for (int i = 0; i < 16; i++) { sOff[i] = 0.0; tOff[i] = 0.0; }
  for (int i = 0; i < 16; i++) { if (float(i) >= ns) break; float sum = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; if (int(dat(float(r), 0.0)) == i) sum += dat(float(r), 2.0); } sOff[i] = sAcc; sAcc += sum / max(tot, 1e-6) * usable + gap; }
  for (int i = 0; i < 16; i++) { if (float(i) >= nt) break; float sum = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; if (int(dat(float(r), 1.0)) == i) sum += dat(float(r), 2.0); } tOff[i] = tAcc; tAcc += sum / max(tot, 1e-6) * usable + gap; }
  float sCur[16]; float tCur[16]; for (int i = 0; i < 16; i++) { sCur[i] = sOff[i]; tCur[i] = tOff[i]; }
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; int si = int(dat(float(r), 0.0)), ti = int(dat(float(r), 1.0)); float h = max(dat(float(r), 2.0), 0.0) / max(tot, 1e-6) * usable; if (si > 15 || ti > 15) continue;
    float x = clamp((b.x - 0.1) / 0.8, 0.0, 1.0); float e = mix(x, x * x * (3.0 - 2.0 * x), p_bantKivr / 100.0); float y0 = mix(sCur[si], tCur[ti], e); if (b.x > 0.1 && b.x < 0.9 && b.y > y0 && b.y < y0 + h) col = overPre(vec4(serCol(float(si), vec3(0.2, 0.5, 1.0)), 1.0) * 0.7, col);
    sCur[si] += h; tCur[ti] += h; }
  for (int i = 0; i < 16; i++) { if (float(i) < ns && b.x > 0.08 && b.x < 0.1 && b.y > sOff[i] && b.y < (i + 1 < 16 && float(i + 1) < ns ? sOff[i + 1] - gap : sAcc - gap)) col = vec4(0.9, 0.9, 0.95, 1.0);
    if (float(i) < nt && b.x > 0.9 && b.x < 0.92 && b.y > tOff[i] && b.y < (i + 1 < 16 && float(i + 1) < nt ? tOff[i + 1] - gap : tAcc - gap)) col = vec4(0.9, 0.9, 0.95, 1.0); }
  o = col; }
//== bumpcard
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_yuksekli; uniform float p_yuksekliOn, p_derinlik, p_notrDege;
float hgt(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; float h = p_yuksekliOn > 0.5 ? luma(unpre(texture(s_yuksekli, clamp(b, 0.0, 1.0)))) : luma(unpre(texPx(boxPx(clamp(b, 0.0, 1.0))))); return (h - p_notrDege / 100.0) * p_derinlik; }
float sdf(vec3 p) { float h = hgt(p.xy); return cardD(p - vec3(0.0, 0.0, h * 0.5), 10.0 + abs(h)) * 0.6; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== organicgrow
uniform sampler2D s_anl; uniform float p_anlOn, p_cizgiKali; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } vec2 b = clamp(boxUV(here()), 0.0, 1.0); float g = 0.0; float r = max(p_cizgiKali, 0.5) * 0.002;
  for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; g = max(g, texture(s_anl, b + vec2(cos(a), sin(a)) * r).r); } g = max(g, texture(s_anl, b).r); o = overPre(vec4(c_renk, 1.0) * smoothstep(0.2, 0.6, g), s); }
