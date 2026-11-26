// 550 rehberi: görüntü onarımı (463–472) — tek karelik (uzamsal) yöntemler
//== debandfix
uniform float p_guc, p_renkFarkEsig, p_ornekYari, p_gecisSayi, p_kenarKoru, p_inceAyriKoru, p_renkKanaBirl, p_inceGrenEkle, p_grenMikt, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c0 = unpre(s); vec3 acc = c0; float wsum = 1.0; float th = p_renkFarkEsig / 100.0;
  int P = int(clamp(p_gecisSayi, 1.0, 8.0)); float R = p_ornekYari * u_s;
  for (int k = 0; k < 8; k++) { if (k >= P) break; float rr = R * (float(k) + 1.0) / float(P);
    for (int i = 0; i < 8; i++) { float a = float(i) * 0.785 + float(k) * 0.39 + hash1(here() * 0.01 + float(k)) * 0.6; vec3 c = unpre(texPx(here() + vec2(cos(a), sin(a)) * rr));
      vec3 d = abs(c - c0); float diff = p_renkKanaBirl > 0.5 ? max(d.r, max(d.g, d.b)) : luma(d); float w = 1.0 - smoothstep(th * 0.5, th, diff); acc += c * w; wsum += w; } }
  vec3 sm = acc / wsum; float edge = smoothstep(0.05, 0.25, sobel(here(), u_s)) * p_kenarKoru / 100.0; float det = smoothstep(0.01, 0.05, length(c0 - unpre(texPx(here() + vec2(u_s, 0.0))))) * p_inceAyriKoru / 100.0 * 0.5;
  vec3 r = mix(c0, sm, p_guc / 100.0 * (1.0 - max(edge, det)));
  if (p_inceGrenEkle > 0.5) r += (hash1(here() + seedf(p_tohum)) - 0.5) * p_grenMikt / 100.0 * 2.0 / 255.0 * 64.0 * 0.25;
  o = pre(clamp(r, 0.0, 1.0), s.a); }
//== deinterlace
uniform float p_alanSira, p_yontem, p_hareketEsig, p_ayrintiKoru, p_yalnizTaraBolg, p_gorunum;
void main() { vec2 px = here(); vec4 s = texture(u_tex, v_uv); float row = floor(px.y); bool keepEven = p_alanSira < 1.5; bool missing = (mod(row, 2.0) > 0.5) == keepEven;
  vec4 up = texPx(px - vec2(0.0, 1.0)), dn = texPx(px + vec2(0.0, 1.0)); vec4 up2 = texPx(px - vec2(0.0, 2.0)), dn2 = texPx(px + vec2(0.0, 2.0));
  float comb = abs(luma(unpre(s)) - luma(unpre(up + dn) * 0.5)) - abs(luma(unpre(up)) - luma(unpre(dn))) * 0.5; float m = smoothstep(p_hareketEsig / 100.0 * 0.3, p_hareketEsig / 100.0 * 0.3 + 0.05, comb);
  if (p_gorunum > 1.5) { o = vec4(vec3(m), 1.0); return; } if (p_gorunum > 0.5) { o = missing ? vec4(0.0, 0.0, 0.0, 1.0) : s; return; }
  if (!missing) { o = s; return; }
  vec4 fix = p_yontem < 0.5 ? up : mix((up + dn) * 0.5, (up + dn) * 0.5 + ((up - up2) + (dn - dn2)) * 0.125 * p_ayrintiKoru / 100.0, 0.5);
  float w = p_yontem > 1.5 || p_yalnizTaraBolg > 0.5 ? m : 1.0; o = mix(s, clamp(fix, 0.0, 1.0), w); }
//== deadpixel
uniform sampler2D s_sinirlayMask; uniform float p_sinirlayMaskOn;
uniform float p_kusurTuru, p_sapmaEsig, p_kusurCapi, p_doldurma, p_ayrintiKoru, p_kusurlarIsar;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float R = max(p_kusurCapi, 1.0) * u_s + 1.0; vec3 v[8]; vec3 mean = vec3(0.0);
  for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; v[i] = unpre(texPx(here() + vec2(cos(a), sin(a)) * R)); mean += v[i] / 8.0; }
  // 8 komşunun ortancası (her kanal ayrı, seçmeli sıralama)
  vec3 med; for (int ch = 0; ch < 3; ch++) { float a[8]; for (int i = 0; i < 8; i++) a[i] = v[i][ch]; for (int i = 0; i < 5; i++) for (int j = i + 1; j < 8; j++) if (a[j] < a[i]) { float t = a[i]; a[i] = a[j]; a[j] = t; } med[ch] = (a[3] + a[4]) * 0.5; }
  float dev = luma(c0) - luma(med); float cd = length(c0 - med); float th = p_sapmaEsig / 100.0;
  bool bad = p_kusurTuru < 0.5 ? cd > th : p_kusurTuru < 1.5 ? dev > th : p_kusurTuru < 2.5 ? -dev > th : length((c0 - luma(c0)) - (med - luma(med))) > th;
  float spread = 0.0; for (int i = 0; i < 8; i++) spread = max(spread, length(v[i] - med)); if (spread > th * (1.0 + p_ayrintiKoru / 50.0)) bad = false;
  if (p_sinirlayMaskOn > 0.5 && texture(s_sinirlayMask, clamp(boxUV(here()), 0.0, 1.0)).a < 0.5) bad = false;
  if (!bad) { o = s; return; } if (p_kusurlarIsar > 0.5) { o = vec4(1.0, 0.0, 0.0, 1.0); return; }
  o = pre(p_doldurma < 0.5 ? med : p_doldurma < 1.5 ? mix(med, mean, 0.5) : mean, s.a); }
//== smartfill
uniform sampler2D s_onarimMask; uniform float p_onarimMaskOn;
uniform float p_maskeGeni, p_kenarYumu, p_yontem, p_aramaYari, p_yamaBoyu, p_gecisSayi, p_alfaBoslDold;
float holeAt(vec2 px) { float h = 0.0; if (p_onarimMaskOn > 0.5) h = texture(s_onarimMask, clamp(boxUV(px), 0.0, 1.0)).a; if (p_alfaBoslDold > 0.5) h = max(h, 1.0 - texPx(px).a) * step(0.001, 1.0); return h; }
void main() { vec4 s = texture(u_tex, v_uv); float g = p_maskeGeni * u_s; float h = holeAt(here()); if (g > 0.0) for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; h = max(h, holeAt(here() + vec2(cos(a), sin(a)) * g)); }
  if (h <= 0.001) { o = s; return; }
  vec4 acc = vec4(0.0); float ws = 0.0; float maxR = max(p_aramaYari, 4.0) * u_s; int D = 8 + int(clamp(p_gecisSayi, 1.0, 8.0)) * 2;
  for (int i = 0; i < 24; i++) { if (i >= D) break; float a = float(i) * TAU / float(D); vec2 dir = vec2(cos(a), sin(a)); float t = 2.0;
    for (int k = 0; k < 24; k++) { vec2 p = here() + dir * t; if (holeAt(p) < 0.5) { vec4 c = texPx(p + (p_yontem > 0.5 ? dir * p_yamaBoyu * u_s * hash1(p) : vec2(0.0))); float w = 1.0 / (t * t + 1.0); acc += c * w; ws += w; break; } t += maxR / 24.0; } }
  vec4 f = ws > 0.0 ? acc / ws : s; float soft = p_kenarYumu > 0.0 ? smoothstep(0.0, 1.0, h) : step(0.5, h); o = mix(s, f, soft); }
//== dehaze
uniform float p_pusGide, p_ortamIsig, p_enDusuGeci, p_tahminAlan, p_gokyuzuKoru, p_kenarKoru, p_renkKoru; uniform vec3 c_ortamReng;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 I = unpre(s); float R = max(p_tahminAlan * u_s, 1.0); float dark = 1.0;
  for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; vec3 c = unpre(texPx(here() + vec2(cos(a), sin(a)) * R * (0.4 + 0.6 * fract(float(i) * 0.618)))); dark = min(dark, min(c.r, min(c.g, c.b))); }
  dark = mix(dark, min(I.r, min(I.g, I.b)), p_kenarKoru / 100.0 * 0.5);
  vec3 A = p_ortamIsig > 0.5 ? c_ortamReng : vec3(0.85, 0.88, 0.92); float t = max(1.0 - p_pusGide / 100.0 * 0.95 * dark / max(luma(A), 0.1), p_enDusuGeci / 100.0);
  float sky = smoothstep(0.7, 0.95, luma(I)) * (1.0 - smoothstep(0.05, 0.25, length(I - luma(I)))) * p_gokyuzuKoru / 100.0; t = mix(t, 1.0, sky);
  vec3 J = (I - A) / t + A; vec3 r = mix(J, J * (luma(I) / max(luma(J), 1e-3)) * 0.0 + J, 1.0); r = mix(r, satAdj(r, 1.0 - (1.0 - t) * 0.3), p_renkKoru / 100.0);
  o = pre(clamp(r, 0.0, 1.0), s.a); }
//== rollingfix
uniform float p_okumaYonu, p_guc, p_satirYumu, p_elleYataEgim, p_elleDikeEgim, p_kenarDold;
void main() { vec2 b = boxUV(here()); float pos = p_okumaYonu < 0.5 ? b.y : p_okumaYonu < 1.5 ? 1.0 - b.y : p_okumaYonu < 2.5 ? b.x : 1.0 - b.x; float k = (pos - 0.5) * p_guc / 100.0;
  pos = mix(pos, smoothstep(0.0, 1.0, pos), p_satirYumu / 100.0); k = (pos - 0.5) * p_guc / 100.0;
  vec2 off = (p_okumaYonu < 1.5 ? vec2(tan(radians(p_elleYataEgim)) * boxU().y, -(p_elleDikeEgim / 100.0) * boxU().y) : vec2(-(p_elleDikeEgim / 100.0) * boxU().x, tan(radians(p_elleYataEgim)) * boxU().x)) * k;
  vec2 q = toUnit(here()) - off; vec2 bb = boxUV(fromUnit(q)); bool outB = any(lessThan(bb, vec2(0.0))) || any(greaterThan(bb, vec2(1.0)));
  vec4 c = texU(q); if (outB) c = p_kenarDold < 0.5 ? vec4(0.0) : texEdge(fromUnit(q), 3.0); if (p_kenarDold > 1.5) { vec2 m = abs(off) / boxU() * 1.05; vec2 cb = boxUV(here()); if (any(lessThan(cb, m)) || any(greaterThan(cb, 1.0 - m))) c = vec4(0.0); }
  o = c; }
//== demoire
uniform sampler2D s_bolgeMask; uniform float p_bolgeMaskOn;
uniform float p_mod, p_desenAral, p_desenYonu, p_otomatikYonBul, p_guc, p_frekansGeni, p_ayrintiKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float r = max(p_desenAral, 1.0) * u_s * (1.0 + p_frekansGeni / 100.0) * 0.6; float ang = radians(p_desenYonu);
  if (p_otomatikYonBul > 0.5) { vec2 g = lumGrad(here(), r * 0.5); ang = atan(g.y, g.x); }
  vec2 d1 = vec2(cos(ang), sin(ang)), d2 = vec2(-d1.y, d1.x); vec3 acc = c0; float n = 1.0;
  for (int i = 1; i <= 4; i++) { float t = r * float(i) / 4.0; acc += unpre(texPx(here() + d1 * t)) + unpre(texPx(here() - d1 * t)) + (unpre(texPx(here() + d2 * t)) + unpre(texPx(here() - d2 * t))) * 0.5; n += 3.0; }
  vec3 lp = acc / n; vec3 r3;
  if (p_mod < 0.5) r3 = luma(c0) + (lp - luma(lp)); else if (p_mod < 1.5) r3 = c0 - luma(c0) + luma(lp); else r3 = lp;
  float edge = smoothstep(0.15, 0.4, sobel(here(), r)) * p_ayrintiKoru / 100.0; float w = p_guc / 100.0 * (1.0 - edge);
  if (p_bolgeMaskOn > 0.5) w *= texture(s_bolgeMask, clamp(boxUV(here()), 0.0, 1.0)).a; o = pre(clamp(mix(c0, r3, w), 0.0, 1.0), s.a); }
//== deblock
uniform float p_blokBoyu, p_guc, p_sinirEsig, p_renkOnar, p_ayrintiKoru, p_gecisSayi; uniform vec2 p_izgaraBasl;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float B = p_blokBoyu < 0.5 ? 8.0 : p_blokBoyu < 1.5 ? 4.0 : p_blokBoyu < 2.5 ? 8.0 : p_blokBoyu < 3.5 ? 16.0 : p_blokBoyu < 4.5 ? 32.0 : 64.0; B *= u_s;
  vec2 m = mod(here() - p_izgaraBasl * u_s, B); vec2 dist = min(m, B - m); float near = 1.0 - smoothstep(0.0, B * 0.35, min(dist.x, dist.y)); vec3 acc = c0; float ws = 1.0;
  int P = int(clamp(p_gecisSayi, 1.0, 4.0));
  for (int k = 1; k <= 4; k++) { if (k > P) break; for (int i = 0; i < 4; i++) { vec2 o2 = (i == 0 ? vec2(1, 0) : i == 1 ? vec2(-1, 0) : i == 2 ? vec2(0, 1) : vec2(0, -1)) * float(k) * B * 0.25; vec3 c = unpre(texPx(here() + o2));
    float w = 1.0 - smoothstep(p_sinirEsig / 100.0 * 0.5, p_sinirEsig / 100.0, length(c - c0)); acc += c * w; ws += w; } }
  vec3 sm = acc / ws; float det = smoothstep(0.1, 0.3, sobel(here(), u_s)) * p_ayrintiKoru / 100.0; vec3 r = mix(c0, sm, near * p_guc / 100.0 * (1.0 - det));
  vec3 chroma = (sm - luma(sm)); r = mix(r, luma(r) + chroma, p_renkOnar / 100.0 * 0.6); o = pre(clamp(r, 0.0, 1.0), s.a); }
//== dehalo
uniform sampler2D s_korumaMask; uniform float p_korumaMaskOn;
uniform float p_halkaGeni, p_kenarEsig, p_halkaTuru, p_guc, p_renkKoru, p_dokuKoru, p_halkaMaskGost;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float R = max(p_halkaGeni, 0.5) * u_s; vec3 mn = vec3(1.0), mx = vec3(0.0);
  for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; vec3 c = unpre(texPx(here() + vec2(cos(a), sin(a)) * R * 1.6)); mn = min(mn, c); mx = max(mx, c); }
  float edge = smoothstep(p_kenarEsig / 100.0 * 0.5, p_kenarEsig / 100.0, length(mx - mn)); vec3 cl = clamp(c0, mn, mx);
  vec3 r = c0; if (p_halkaTuru < 0.5 || p_halkaTuru > 1.5) r = min(r, max(cl, mn)); if (p_halkaTuru > 0.5) r = max(r, min(cl, mx));
  float tex = smoothstep(0.05, 0.2, length(c0 - unpre(texPx(here() + vec2(u_s, u_s))))) * p_dokuKoru / 100.0 * 0.5; float w = edge * p_guc / 100.0 * (1.0 - tex);
  if (p_korumaMaskOn > 0.5) w *= 1.0 - texture(s_korumaMask, clamp(boxUV(here()), 0.0, 1.0)).a;
  if (p_halkaMaskGost > 0.5) { o = vec4(vec3(w), 1.0); return; } vec3 res = mix(c0, r, w); res = mix(res, luma(res) + (c0 - luma(c0)), p_renkKoru / 100.0 * 0.5); o = pre(clamp(res, 0.0, 1.0), s.a); }
