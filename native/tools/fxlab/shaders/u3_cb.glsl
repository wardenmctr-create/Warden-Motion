// Güncelleme: CB efektleri (401, 402, 413, 416, 428)
//== flagwave
uniform sampler2D s_arkaGorsel; uniform float p_arkaGorselOn;
uniform float p_sabitKena, p_sabitSeriGeni, p_dalgaYuks, p_dalgaBoyu, p_ruzgarHizi, p_ruzgarAcis, p_faz, p_ikinciDalg, p_duzensiz, p_tohum, p_p3bGolg, p_isikAcis, p_golgeGucu, p_kenarlarKoru, p_kusursuzDong, p_donguSure,
  p_sertlik, p_agirlik, p_sarkma, p_degisken, p_degisGuc, p_degisSik, p_ucTitre, p_kumasParlak, p_kumasDoku, p_arkaGoster, p_arkaYuz;
uniform vec2 p_ozelSabiCizg, p_ozelSabiCizg2; uniform vec3 c_arkaRenk;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 b = boxUV(here()); vec2 fdir; float u;
  if (p_sabitKena < 0.5) { fdir = vec2(1, 0); u = b.x; } else if (p_sabitKena < 1.5) { fdir = vec2(-1, 0); u = 1.0 - b.x; } else if (p_sabitKena < 2.5) { fdir = vec2(0, 1); u = b.y; } else if (p_sabitKena < 3.5) { fdir = vec2(0, -1); u = 1.0 - b.y; }
  else { vec2 a = p_ozelSabiCizg, c = p_ozelSabiCizg2; vec2 d = normalize(c - a + 1e-5); fdir = vec2(d.y, -d.x); if (dot(-a, fdir) < 0.0) fdir = -fdir; u = clamp(dot(q - a, fdir) / max(abs(dot(B, abs(fdir))), 1.0), 0.0, 1.0); }
  float s = p_sabitSeriGeni / 100.0; float w = smoothstep(s, 1.0, u) * smoothstep(s, min(s + 0.35, 1.0), u);
  w = pow(w, mix(0.6, 1.6, p_sertlik / 100.0));
  float dist = u * abs(dot(B, abs(fdir))); float f = p_ruzgarHizi; if (p_kusursuzDong > 0.5) f = max(1.0, floor(f * p_donguSure + 0.5)) / max(p_donguSure, 0.01);
  float amp = p_dalgaYuks; if (p_degisken > 0.5) amp *= 1.0 + (vnoise(vec2(u_t * p_degisSik, seedf(p_tohum) + 3.0)) - 0.5) * 2.0 * p_degisGuc / 100.0;
  float ph = TAU * (dist / max(p_dalgaBoyu, 1.0) - f * u_t) + radians(p_faz);
  float irr = (vnoise(vec2(dist / max(p_dalgaBoyu, 1.0) * 1.7 - f * u_t * 0.8, seedf(p_tohum))) - 0.5) * 2.0 * p_duzensiz / 100.0;
  float tip = smoothstep(0.75, 1.0, u) * sin(ph * 3.7 + u_t * 9.0) * p_ucTitre / 100.0 * 0.5;
  float h = sin(ph) + p_ikinciDalg / 100.0 * sin(ph * 2.13 + 1.3) + irr + tip; float disp = amp * w * h;
  vec2 perp = vec2(-fdir.y, fdir.x);
  // ağırlık: dalga aşağı doğru sarkar (serbest kenara doğru artan)
  vec2 sag = vec2(0.0, (p_sarkma + p_agirlik * 0.3) * w * u);
  vec2 sq = q - perp * disp * (1.0 - p_agirlik / 100.0 * 0.4) - fdir * disp * 0.15 * cos(ph) - sag;
  vec4 c = texU(sq); if (p_kenarlarKoru < 0.5) c = texEdge(fromUnit(sq), 3.0) * step(0.001, texU(sq).a + 0.001);
  // arka yüz: dalganın eğimi tersine döndüğü bölgeler
  float slope = cos(ph) * w * amp / max(p_dalgaBoyu, 1.0) * TAU;
  if (p_arkaGoster > 0.5 && slope < -0.9 && c.a > 0.0) { vec3 back = p_arkaYuz < 0.5 ? unpre(texU(sq * vec2(-1.0, 1.0))) : p_arkaYuz < 1.5 && p_arkaGorselOn > 0.5 ? unpre(texture(s_arkaGorsel, clamp(boxUV(fromUnit(sq)), 0.0, 1.0))) : c_arkaRenk; c = pre(back * 0.8, c.a); }
  if (p_p3bGolg > 0.5 && c.a > 0.0) { float la = radians(p_isikAcis); float lit = cos(ph) * w * cos(la) * p_golgeGucu / 100.0 * 1.6; c.rgb = clamp(c.rgb * (1.0 + lit), 0.0, c.a);
    c.rgb += vec3(pow(max(cos(ph) * w, 0.0), 6.0) * p_kumasParlak / 100.0 * 0.5) * c.a; }
  if (p_kumasDoku > 0.0 && c.a > 0.0) { vec2 fq = sq * 0.8; float wv = mix(sin(fq.x * PI), sin(fq.y * PI), step(0.5, mod(floor(fq.x) + floor(fq.y), 2.0))); c.rgb *= 1.0 - (0.5 - 0.5 * wv) * p_kumasDoku / 100.0 * 0.3; }
  o = c;
}
//== cbshade
uniform vec2 p_isikMerk, p_isik2Konum; uniform vec3 c_isikReng, c_golgeReng, c_isik2Renk;
uniform float p_isikGucu, p_golgeGucu, p_kenarKara, p_yumusakl, p_alfayaKirp, p_yuzeyParlak, p_noktaBuyu, p_noktaGuc, p_isik2, p_isik2Guc, p_bayrakKoru, p_konturIsik;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 q = toUnit(here()); vec2 B = boxU(); float R = min(B.x, B.y) * 0.5;
  vec2 r = q / R; float d = length(r); vec3 n = vec3(r, sqrt(max(0.0, 1.0 - min(dot(r, r), 1.0)))); vec3 L = normalize(vec3(p_isikMerk / R, 0.9));
  float dif = dot(n, L); float hl = pow(max(dif, 0.0), mix(12.0, 2.0, p_yumusakl / 100.0)); float sh = smoothstep(0.2, -0.6, dif);
  vec3 c = unpre(s); bool dark = luma(c) < 0.12; float k = (dark && p_konturIsik < 0.5) ? 0.0 : 1.0;
  float keep = p_bayrakKoru > 0.5 ? 0.75 : 1.0;
  c = mix(c, c_golgeReng, sh * p_golgeGucu / 100.0 * keep * k); c = mix(c, c_isikReng, hl * p_isikGucu / 100.0 * keep * k);
  float spot = pow(max(dot(reflect(-L, n), vec3(0, 0, 1)), 0.0), mix(200.0, 8.0, p_noktaBuyu / 100.0)); c += c_isikReng * spot * (p_noktaGuc / 100.0 + p_yuzeyParlak / 100.0 * 0.4) * k;
  if (p_isik2 > 0.5) { vec3 L2 = normalize(vec3(p_isik2Konum / R, 0.6)); c += c_isik2Renk * pow(max(dot(n, L2), 0.0), 4.0) * p_isik2Guc / 100.0 * k; }
  c *= 1.0 - smoothstep(0.7, 1.0, d) * p_kenarKara / 100.0 * k;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== cbskin
uniform sampler2D s_bayrakKatm, s_govdeMask; uniform float p_bayrakKatmOn, p_govdeMaskOn;
uniform float p_yerlesim, p_olcek, p_aci, p_kureBuku, p_golge, p_konturuKoru, p_esleme, p_kureDonus, p_dikeyDonus, p_yuzeySabit, p_sekilTakip, p_yuzeyKabar, p_aksesuarKoru; uniform vec2 p_kayma;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float mask = p_govdeMaskOn > 0.5 ? texture(s_govdeMask, clamp(b, 0.0, 1.0)).a : s.a; if (mask <= 0.0) { o = s; return; }
  vec2 r = b - 0.5; float d = length(r) * 2.0; vec2 uv;
  if (p_esleme < 0.5) uv = r;
  else { vec2 rr = r * 2.0; if (p_esleme > 1.5) rr.y *= 1.15; float z = sqrt(max(0.0, 1.0 - dot(rr, rr))); vec3 n = vec3(rr, z);
    float a = radians(p_kureDonus), e = radians(p_dikeyDonus); n.xz = mat2(cos(a), -sin(a), sin(a), cos(a)) * n.xz; n.yz = mat2(cos(e), -sin(e), sin(e), cos(e)) * n.yz;
    uv = mix(r, vec2(atan(n.x, n.z) / PI * 0.5, asin(clamp(n.y, -1.0, 1.0)) / PI * 0.5) * 1.1, p_kureBuku / 100.0 * 2.0 > 1.0 ? 1.0 : p_kureBuku / 50.0 + 0.0); }
  vec2 fb = rot2(-p_aci) * (uv - p_kayma / boxU()) / max(p_olcek / 100.0, 0.01) + 0.5;
  vec4 f = p_bayrakKatmOn > 0.5 ? texture(s_bayrakKatm, clamp(fb, 0.0, 1.0)) : s; vec3 c = f.a > 0.0 ? f.rgb / f.a : unpre(s);
  c *= 1.0 - smoothstep(0.5, 1.0, d) * p_golge / 100.0; if (p_yuzeyKabar > 0.0) c *= 1.0 + (0.5 - d) * p_yuzeyKabar / 100.0 * 0.5;
  vec4 res = pre(c, mask);
  if (p_konturuKoru > 0.5 || p_aksesuarKoru > 0.5) { vec3 sc = unpre(s); float dark = 1.0 - smoothstep(0.05, 0.25, luma(sc)); float white = smoothstep(0.85, 0.97, min(sc.r, min(sc.g, sc.b)));
    float keep = (p_konturuKoru > 0.5 ? dark : 0.0) + (p_aksesuarKoru > 0.5 ? white * 0.0 : 0.0); res = mix(res, s, clamp(keep, 0.0, 1.0) * s.a); }
  o = res;
}
//== cbmaphl
uniform sampler2D s_bolgeMask, s_dolguGorsel; uniform float p_bolgeMaskOn, p_dolguGorselOn;
uniform float p_dolguOpak, p_kontur, p_parlama, p_nabiz, p_nabizAcik, p_sinirlarKoru, p_dolguBicim, p_taramaAci, p_taramaAral, p_taramaKalin, p_sinirKirp, p_sinirCiz, p_cizimIler, p_dolguIler, p_konturSabit;
uniform vec3 c_dolgu, c_konturReng, c_dolgu2;
float mAt(vec2 px) { return p_bolgeMaskOn > 0.5 ? texture(s_bolgeMask, clamp(boxUV(px), 0.0, 1.0)).a : texPx(px).a; }
void main() {
  vec4 s = texture(u_tex, v_uv); float m = mAt(here()); float pulse = p_nabizAcik > 0.5 ? 0.7 + 0.3 * sin(u_t * p_nabiz * TAU) : 1.0; float ks = p_konturSabit > 0.5 ? 1.0 : u_s;
  float w = p_kontur * ks; float mx = m, mn = m; for (int i = 0; i < 12; i++) { float a = float(i) * TAU / 12.0; float x = mAt(here() + vec2(cos(a), sin(a)) * max(w, 0.5)); mx = max(mx, x); mn = min(mn, x); }
  float ring = clamp(mx - mn, 0.0, 1.0);
  if (p_sinirCiz > 0.5) { vec2 q = toUnit(here()); float ang = fract(atan(q.y, q.x) / TAU + 0.25); ring *= step(ang, p_cizimIler / 100.0); }
  float g = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; g += mAt(here() + vec2(cos(a), sin(a)) * p_parlama * u_s); } g = g / 8.0 * (1.0 - m);
  vec3 fc = c_dolgu; vec2 q = toUnit(here());
  if (p_dolguBicim > 0.5 && p_dolguBicim < 1.5) fc = mix(c_dolgu, c_dolgu2, clamp(boxUV(here()).y, 0.0, 1.0));
  else if ((p_dolguBicim > 1.5 && p_dolguBicim < 2.5) || p_dolguBicim > 4.5) fc = p_dolguGorselOn > 0.5 ? unpre(texture(s_dolguGorsel, clamp(boxUV(here()), 0.0, 1.0))) : c_dolgu;
  float pat = 1.0; if (p_dolguBicim > 2.5 && p_dolguBicim < 3.5) { vec2 r = rot2(-p_taramaAci) * q; pat = 1.0 - smoothstep(p_taramaKalin * 0.5, p_taramaKalin * 0.5 + 0.8, abs(mod(r.y, max(p_taramaAral, 1.0)) - p_taramaAral * 0.5)); }
  else if (p_dolguBicim > 3.5 && p_dolguBicim < 4.5) { vec2 f = mod(q, max(p_taramaAral, 1.0)) - p_taramaAral * 0.5; pat = 1.0 - smoothstep(p_taramaKalin * 0.5, p_taramaKalin * 0.5 + 0.8, length(f)); }
  float fill = m * p_dolguOpak / 100.0 * pulse * pat * p_dolguIler / 100.0; if (p_sinirKirp < 0.5) fill = max(fill, mx * p_dolguOpak / 100.0 * pat * 0.5);
  vec4 c = overPre(vec4(fc, 1.0) * fill, s); c = overPre(vec4(c_konturReng, 1.0) * ring, c); c = overPre(vec4(c_dolgu, 1.0) * g * 0.6 * pulse, c); o = c;
}
//== cbsticker
INCLUDE(_mat)
uniform sampler2D s_malzOzel; uniform float p_malzOzelOn;
uniform float p_icKont, p_disKont, p_golgeUzak, p_golge, p_kose, p_bosluklaDold, p_altlikBicim, p_alfaYorum, p_alfaEsik, p_malzDoku, p_malz, p_dokuGucuS; uniform vec2 p_disKayma; uniform vec3 c_icRenk, c_disRenk;
float sA(vec2 px) { float a = texPx(px).a; if (p_alfaYorum < 0.5) return step(0.5, a); if (p_alfaYorum < 1.5) return a; if (p_alfaYorum < 2.5) return smoothstep(0.08, 0.55, a); return step(p_alfaEsik / 100.0, a); }
float dil(vec2 px, float r) { float m = sA(px); if (r < 0.5) return m; for (int k = 1; k <= 3; k++) { float rr = r * float(k) / 3.0; for (int i = 0; i < 16; i++) { float a = float(i) * TAU / 16.0 + float(k) * 0.4; m = max(m, sA(px + vec2(cos(a), sin(a)) * rr)); } } return m; }
void main() {
  vec4 s = texture(u_tex, v_uv); float wi = p_icKont * u_s, wo = p_disKont * u_s; vec2 off = p_disKayma * u_s;
  float a1 = dil(here(), wi); float a2 = p_altlikBicim > 0.5 ? dil(here() - off, wi + wo) : 0.0;
  if (p_altlikBicim > 1.5) { vec2 q = toUnit(here()); vec2 n = vec2(pnoise(q / max(p_disKont * 3.0, 3.0)), pnoise(q / max(p_disKont * 3.0, 3.0) + 9.0)) * p_disKont * 0.4; a2 = dil(here() - off + n * u_s, wi + wo); }
  if (p_kose > 0.5) { a1 = step(0.5, a1); a2 = step(0.5, a2); }
  vec3 dc = c_disRenk;
  if (p_malzDoku > 0.5) { int id = p_malz < 0.5 ? 1 : p_malz < 1.5 ? 3 : p_malz < 2.5 ? 5 : 13; vec2 mp = toUnit(here());
    vec3 t = p_malz > 3.5 && p_malzOzelOn > 0.5 ? unpre(texture(s_malzOzel, fract(mp / 200.0))) : matSample(id, mp, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb / max(matBase(id), vec3(0.05));
    dc = mix(dc, dc * t * matLight(id, mp, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0, 4.0, 135.0), p_dokuGucuS / 100.0); }
  float sh = dil(here() - off - vec2(0.0, p_golgeUzak * u_s), wi + wo) * p_golge / 100.0;
  vec4 c = vec4(0.0, 0.0, 0.0, 1.0) * sh; c = overPre(vec4(dc, 1.0) * a2, c); c = overPre(vec4(c_icRenk, 1.0) * a1, c);
  o = overPre(s, c);
}
