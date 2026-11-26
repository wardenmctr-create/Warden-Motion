// Renk ve Işık (rehberdeki ayarlar)
//== bricon
uniform float p_parlakli, p_kontrast, p_kontrastMerk, p_alfaKanaKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s) + p_parlakli / 100.0 * 0.6;
  float k = p_kontrast >= 0.0 ? 1.0 / max(0.02, 1.0 - p_kontrast / 100.0 * 0.98) : 1.0 + p_kontrast / 100.0;
  c = conAdj(c, k, p_kontrastMerk / 100.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== exposure
uniform float p_pozlama, p_gama, p_siyahNokt, p_acikTonlKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 l = srgb2lin(unpre(s)) * exp2(p_pozlama);
  if (p_acikTonlKoru > 0.5) l = l / (1.0 + max(l - 1.0, 0.0) * 0.5);
  vec3 c = lin2srgb(l); c = max(c - p_siyahNokt / 100.0, 0.0) / max(0.01, 1.0 - p_siyahNokt / 100.0);
  c = pow(clamp(c, 0.0, 1.0), vec3(1.0 / max(p_gama, 0.01)));
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== vibrance
uniform float p_doygunlu, p_canlilik, p_acikligiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l0 = luma(c);
  c = satAdj(c, 1.0 + p_doygunlu / 100.0);
  float sat = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b));
  c = satAdj(c, 1.0 + p_canlilik / 100.0 * (1.0 - sat) * 1.5);
  if (p_acikligiKoru > 0.5) c += l0 - luma(c);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== hue
uniform float p_tonAcis, p_doygunlu, p_renkAral;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float w = hueRange(c, p_renkAral);
  vec3 h = hueRotate(c, p_tonAcis); h = satAdj(h, 1.0 + p_doygunlu / 100.0);
  o = pre(clamp(mix(c, h, w), 0.0, 1.0), s.a);
}
//== colortune
uniform float p_kirmizi, p_yesil, p_mavi, p_parlakliKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l0 = luma(c);
  c *= 1.0 + vec3(p_kirmizi, p_yesil, p_mavi) / 100.0;
  if (p_parlakliKoru > 0.5) c *= l0 / max(luma(c), 1e-3);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== temperature
uniform float p_sicaklik, p_renkTonu, p_guc;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 w = kelvin(clamp(p_sicaklik, 1000.0, 40000.0)) / kelvin(6500.0);
  // düşük K = sıcak görüntü: aydınlatmanın tersini uygula (ışık beyaz dengesi gibi)
  vec3 g = c / max(w, vec3(0.05)); g *= luma(c) / max(luma(g), 1e-3);
  g.g *= 1.0 - p_renkTonu / 100.0 * 0.25; g.rb *= 1.0 + p_renkTonu / 100.0 * 0.12;
  o = pre(clamp(mix(c, g, p_guc / 100.0), 0.0, 1.0), s.a);
}
//== colorize
uniform vec3 c_renk; uniform float p_doygunlu, p_aciklik, p_golgeyiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c);
  vec3 hs = rgb2hsl(c_renk); vec3 t = hsl2rgb(vec3(hs.x, hs.y * p_doygunlu / 100.0, clamp(l + p_aciklik / 100.0 * 0.5, 0.0, 1.0)));
  if (p_golgeyiKoru < 0.5) t = mix(c_renk, t, 0.35);
  o = pre(clamp(t, 0.0, 1.0), s.a);
}
//== grayscale
uniform float p_guc, p_tonYont, p_kontrast;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float g = p_tonYont < 0.5 ? luma(c) : p_tonYont < 1.5 ? (c.r + c.g + c.b) / 3.0 : max(c.r, max(c.g, c.b));
  g = (g - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5;
  o = pre(clamp(mix(c, vec3(g), p_guc / 100.0), 0.0, 1.0), s.a);
}
//== sepia
uniform vec3 c_sepyaReng; uniform float p_guc, p_solma, p_kontrast;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c); l = (l - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5;
  vec3 t = l < 0.5 ? mix(vec3(0.05, 0.03, 0.02), c_sepyaReng, l * 2.0) : mix(c_sepyaReng, vec3(1.0, 0.97, 0.9), (l - 0.5) * 2.0);
  t = mix(t, vec3(0.92, 0.86, 0.74), p_solma / 100.0 * 0.5);
  o = pre(clamp(mix(c, t, p_guc / 100.0), 0.0, 1.0), s.a);
}
//== invert
uniform float p_kanal, p_guc, p_alfayiDaTers;
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float a = s.a; vec3 n = c;
  if (p_kanal < 0.5) n = 1.0 - c; else if (p_kanal < 1.5) n.r = 1.0 - c.r; else if (p_kanal < 2.5) n.g = 1.0 - c.g; else if (p_kanal < 3.5) n.b = 1.0 - c.b;
  float k = p_guc / 100.0; vec3 r = mix(c, n, k);
  if (p_kanal > 3.5 || p_alfayiDaTers > 0.5) { a = mix(a, 1.0 - a, k); if (s.a < 0.001) r = vec3(1.0) - vec3(0.0); }
  o = pre(clamp(r, 0.0, 1.0), a);
}
//== threshold
uniform float p_esik, p_yumusakl, p_tersCevi; uniform vec3 c_dusukRenk, c_yuksekRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); float w = max(p_yumusakl / 100.0 * 0.5, 0.002); float k = smoothstep(p_esik / 100.0 - w, p_esik / 100.0 + w, l);
  if (p_tersCevi > 0.5) k = 1.0 - k;
  o = pre(mix(c_dusukRenk, c_yuksekRenk, k), s.a);
}
//== posterize
uniform float p_tonSevi, p_kanal, p_titresimDagi, p_gurultu;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float n = max(2.0, floor(p_tonSevi)) - 1.0;
  float dz = p_titresimDagi > 0.5 ? (hash1(floor(here())) - 0.5) / n : 0.0;
  dz += (hash1(here() + 7.0) - 0.5) * p_gurultu / 100.0 * 0.3;
  if (p_kanal < 0.5) c = floor((c + dz) * n + 0.5) / n;
  else { float l = luma(c); float q = floor((l + dz) * n + 0.5) / n; c *= q / max(l, 1e-3); }
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== levels
uniform float p_kanal, p_girisSiya, p_girisBeya, p_gama, p_cikisSiya, p_cikisBeya;
float lv(float x) { float a = p_girisSiya / 100.0, b = max(a + 0.001, p_girisBeya / 100.0); x = clamp((x - a) / (b - a), 0.0, 1.0); x = pow(x, 1.0 / max(p_gama, 0.01)); return mix(p_cikisSiya / 100.0, p_cikisBeya / 100.0, x); }
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float a = s.a;
  if (p_kanal < 0.5) c = vec3(lv(c.r), lv(c.g), lv(c.b)); else if (p_kanal < 1.5) c.r = lv(c.r); else if (p_kanal < 2.5) c.g = lv(c.g); else if (p_kanal < 3.5) c.b = lv(c.b); else a = lv(a);
  o = pre(c, a);
}
//== gradmap
GRADIENT(renkGeci)
uniform float p_gecisKayd, p_tersCevi, p_duzlesti;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); if (p_tersCevi > 0.5) l = 1.0 - l; l = clamp(l + p_gecisKayd / 100.0, 0.0, 1.0);
  if (p_duzlesti > 0.5) l = floor(l * 6.0 + 0.5) / 6.0;
  o = pre(grad_renkGeci(l), s.a);
}
//== palettemap
GRADIENT(palet)
uniform float p_eslemeYont, p_dagitim, p_paletDisiRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); c += (hash1(floor(here())) - 0.5) * p_dagitim / 100.0 * 0.25;
  int n = paln_palet(); float best = 1e9; vec3 bc = c;
  for (int i = 0; i < 8; i++) { if (i >= n) break; vec3 p = palc_palet(i);
    float d = p_eslemeYont < 0.5 ? distance(c, p) : p_eslemeYont < 1.5 ? length((c - p) * vec3(0.299, 0.587, 0.114) * 3.0) : abs(luma(c) - luma(p));
    if (d < best) { best = d; bc = p; } }
  if (p_paletDisiRenk > 0.5 && best > 0.35) bc = c;
  o = pre(bc, s.a);
}
//== hotcolor
GRADIENT(isiPale)
uniform float p_altEsik, p_ustEsik, p_tersCevi;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); l = clamp((l - p_altEsik / 100.0) / max(0.01, (p_ustEsik - p_altEsik) / 100.0), 0.0, 1.0);
  if (p_tersCevi > 0.5) l = 1.0 - l;
  o = pre(grad_isiPale(l), s.a);
}
//== fourcolor
uniform vec3 c_solUstRenk, c_sagUstRenk, c_solAltRenk, c_sagAltRenk; uniform float p_gecisYumu, p_karistir;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 b = clamp(boxUV(here()), 0.0, 1.0); float k = mix(4.0, 1.0, p_gecisYumu / 100.0);
  vec2 f = vec2(pow(b.x, k) / (pow(b.x, k) + pow(1.0 - b.x, k)), pow(b.y, k) / (pow(b.y, k) + pow(1.0 - b.y, k)));
  vec3 g = mix(mix(c_solUstRenk, c_sagUstRenk, f.x), mix(c_solAltRenk, c_sagAltRenk, f.x), f.y);
  o = pre(blendMode(unpre(s), g, p_karistir), s.a);
}
//== gradoverlay
GRADIENT(renkDura)
uniform float p_gecisTuru, p_aci, p_olcek, p_tersCevi, p_karistir; uniform vec2 p_baslangi, p_bitis;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 q = toUnit(here()); vec2 A = p_baslangi, B = p_bitis; vec2 ab = rot2(p_aci) * (B - A); float L = max(length(ab), 1.0) * max(p_olcek / 100.0, 0.01);
  float x;
  if (p_gecisTuru < 0.5) x = dot(q - A, normalize(ab)) / L; else if (p_gecisTuru < 1.5) x = length(q - A) / L;
  else x = fract((atan(q.y - A.y, q.x - A.x) - atan(ab.y, ab.x)) / TAU);
  x = clamp(x, 0.0, 1.0); if (p_tersCevi > 0.5) x = 1.0 - x;
  o = pre(blendMode(unpre(s), grad_renkDura(x), p_karistir), s.a);
}
//== highshadow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform float p_acikTonl, p_golgeler, p_beyazlar, p_siyahlar, p_tonAral;
void main() {
  vec4 s = texture(u_src, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec4 bl = texture(u_aux, v_uv); float L = bl.a > 0.0 ? luma(bl.rgb / bl.a) : luma(c);
  float r = p_tonAral / 100.0 * 0.5 + 0.25;
  float wS = 1.0 - smoothstep(0.0, r * 2.0, L), wH = smoothstep(1.0 - r * 2.0, 1.0, L);
  float l = luma(c);
  float wB = smoothstep(0.75, 1.0, l), wK = 1.0 - smoothstep(0.0, 0.25, l);
  float d = p_golgeler / 100.0 * 0.45 * wS + p_acikTonl / 100.0 * 0.45 * wH + p_beyazlar / 100.0 * 0.3 * wB + p_siyahlar / 100.0 * 0.3 * wK;
  c = c + d * (d > 0.0 ? (1.0 - c) : c);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== replacecolor
uniform vec3 c_kaynakRenk, c_hedefRenk; uniform float p_tolerans, p_kenarGeci, p_parlakliKoru, p_eslesmeyGost;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 h = rgb2hsv(c), k = rgb2hsv(c_kaynakRenk);
  float d = length(vec3(min(abs(h.x - k.x), 1.0 - abs(h.x - k.x)) * 2.0, (h.y - k.y) * 0.5, (h.z - k.z) * 0.35));
  float tol = p_tolerans / 100.0 * 0.6; float m = 1.0 - smoothstep(tol, tol + p_kenarGeci / 100.0 * 0.4 + 0.001, d);
  vec3 t = c_hedefRenk; if (p_parlakliKoru > 0.5) { vec3 th = rgb2hsv(t); t = hsv2rgb(vec3(th.x, th.y * min(1.0, h.y / max(k.y, 0.05)), clamp(h.z * th.z / max(k.z, 0.05), 0.0, 1.0))); }
  if (p_eslesmeyGost > 0.5) { o = pre(vec3(m), s.a); return; }
  o = pre(mix(c, t, m), s.a);
}
//== spotcolor
uniform vec3 c_korunacaRenk; uniform float p_tolerans, p_gecis, p_disDoyg, p_secimiTersCevi;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 h = rgb2hsv(c), k = rgb2hsv(c_korunacaRenk);
  float d = min(abs(h.x - k.x), 1.0 - abs(h.x - k.x)) * 2.0 + (1.0 - smoothstep(0.08, 0.3, h.y)) * 0.6;
  float tol = p_tolerans / 100.0 * 0.5; float m = 1.0 - smoothstep(tol, tol + p_gecis / 100.0 * 0.3 + 0.001, d);
  if (p_secimiTersCevi > 0.5) m = 1.0 - m;
  o = pre(mix(satAdj(c, p_disDoyg / 100.0), c, m), s.a);
}
//== solidcolor
uniform vec3 c_dolguReng; uniform float p_renkOpak, p_kaynakAlfaKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); float a = p_kaynakAlfaKoru > 0.5 ? s.a : (boxUV(here()) == clamp(boxUV(here()), 0.0, 1.0) ? 1.0 : 0.0);
  o = mix(s, pre(c_dolguReng, a), p_renkOpak / 100.0);
}
//== longshadow
uniform float p_uzunluk, p_aci, p_golgeOpak, p_uctaSolm, p_yalnizGolg; uniform vec3 c_golgeReng;
void main() {
  vec4 s = texture(u_tex, v_uv); float a = radians(p_aci); vec2 d = vec2(cos(a), sin(a)) * u_s;
  float L = p_uzunluk; float sh = 0.0; int N = int(clamp(L * u_s / 1.5, 4.0, 120.0));
  for (int i = 1; i <= 120; i++) { if (i > N) break; float t = float(i) / float(N); float aa = texPx(here() - d * L * t).a; sh = max(sh, aa * (1.0 - t * p_uctaSolm / 100.0)); }
  vec4 shc = vec4(c_golgeReng, 1.0) * sh * p_golgeOpak / 100.0;
  o = p_yalnizGolg > 0.5 ? shc * (1.0 - s.a) : overPre(s, shc);
}
//== radialshadow_a
uniform vec2 p_isikMerk; uniform float p_golgeMesa;
void main() {
  // ışıktan uzaklaşan yönde kaydırılmış siluet
  vec2 q = toUnit(here()); vec2 dir = q - p_isikMerk; float L = max(length(dir), 1.0); vec2 src = q - dir / L * p_golgeMesa * (0.4 + 0.6 * clamp(L / max(length(boxU()), 1.0), 0.0, 1.0));
  o = vec4(texU(src).a);
}
//== radialshadow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_opaklik, p_yalnizGolg;
void main() {
  vec4 s = texture(u_src, v_uv); float sh = texture(u_aux, v_uv).a * p_opaklik / 100.0;
  vec4 shc = vec4(c_renk, 1.0) * sh;
  o = p_yalnizGolg > 0.5 ? shc * (1.0 - s.a) : overPre(s, shc);
}
//== lightrays
uniform vec2 p_isikMerk; uniform float p_esik, p_uzunluk, p_yogunluk, p_ornekSayi, p_yalnizIsin; uniform vec3 c_isikReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 c = fromUnit(p_isikMerk); vec2 px = here(); vec2 d = px - c;
  float span = clamp(p_uzunluk * u_s / max(length(d), 1.0), 0.0, 1.0);
  int N = int(clamp(p_ornekSayi, 4.0, 64.0)); vec3 acc = vec3(0.0); float th = p_esik / 100.0;
  for (int i = 0; i < 64; i++) { if (i >= N) break; float t = float(i) / float(N); vec4 x = texPx(c + d * (1.0 - span * t));
    vec3 col = x.a > 0.0 ? x.rgb / x.a : vec3(0.0); float b = max(luma(col) - th, 0.0) / max(1.0 - th, 0.01); acc += col * b * x.a * (1.0 - t); }
  acc = acc / float(N) * p_yogunluk / 100.0 * 3.0 * c_isikReng;
  vec4 r = vec4(acc, max(acc.r, max(acc.g, acc.b)));
  o = p_yalnizIsin > 0.5 ? r : vec4(s.rgb + r.rgb * (1.0 - s.rgb), max(s.a, r.a));
}
//== curves
uniform float p_kanal, p_cikisiSini;
void main() { o = texture(u_tex, v_uv); }
//== chanmix
uniform float p_cikisKana, p_kirmiziKatk, p_yesilKatk, p_maviKatk, p_sabit, p_tekRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float v = dot(c, vec3(p_kirmiziKatk, p_yesilKatk, p_maviKatk) / 100.0) + p_sabit / 100.0;
  vec3 r = c; if (p_tekRenk > 0.5) r = vec3(v); else if (p_cikisKana < 0.5) r.r = v; else if (p_cikisKana < 1.5) r.g = v; else r.b = v;
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
//== tritone
uniform vec3 c_golgeReng, c_ortaTon, c_acikTon; uniform float p_ortaNokt, p_gecis;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); float m = clamp(p_ortaNokt / 100.0, 0.05, 0.95); float w = max(p_gecis / 100.0, 0.02);
  vec3 a = mix(c_golgeReng, c_ortaTon, smoothstep(0.0, m * (1.0 + w) , l)); vec3 c = mix(a, c_acikTon, smoothstep(m * (1.0 - w * 0.5), 1.0, l));
  o = pre(c, s.a);
}
//== photofilter
uniform vec3 c_filtreReng; uniform float p_yogunluk, p_parlakliKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 f = c * mix(vec3(1.0), c_filtreReng * 1.4, p_yogunluk / 100.0);
  if (p_parlakliKoru > 0.5) f *= luma(c) / max(luma(f), 1e-3);
  o = pre(clamp(f, 0.0, 1.0), s.a);
}
//== selcolor
uniform float p_renkGrub, p_camgobeg, p_macenta, p_sari, p_siyah, p_yontem;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float w;
  if (p_renkGrub < 5.5) { float r = p_renkGrub < 0.5 ? 1.0 : p_renkGrub < 1.5 ? 2.0 : p_renkGrub < 2.5 ? 3.0 : p_renkGrub < 3.5 ? 4.0 : p_renkGrub < 4.5 ? 5.0 : 6.0; w = hueRange(c, r); }
  else { float l = luma(c); float sat = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)); w = (1.0 - smoothstep(0.1, 0.35, sat)) * (p_renkGrub < 6.5 ? smoothstep(0.7, 0.95, l) : p_renkGrub < 7.5 ? 1.0 - abs(l - 0.5) * 2.0 : 1.0 - smoothstep(0.05, 0.3, l)); }
  vec3 cmy = 1.0 - c; vec3 adj = vec3(p_camgobeg, p_macenta, p_sari) / 100.0; float k = p_siyah / 100.0;
  cmy += (p_yontem < 0.5 ? adj * cmy : adj) * w; cmy += k * w * (p_yontem < 0.5 ? (1.0 - cmy) * 0.5 : vec3(0.5));
  o = pre(clamp(1.0 - cmy, 0.0, 1.0), s.a);
}
//== colorbal
uniform float p_tonBolg, p_camgobeg, p_macentay, p_sarimavi, p_parlakliKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c);
  float w = p_tonBolg < 0.5 ? 1.0 - smoothstep(0.0, 0.5, l) : p_tonBolg < 1.5 ? 1.0 - abs(l - 0.5) * 2.0 : smoothstep(0.5, 1.0, l);
  vec3 sh = vec3(p_camgobeg, p_macentay, p_sarimavi) / 100.0 * 0.35 * w; vec3 r = c + sh;
  if (p_parlakliKoru > 0.5) r *= l / max(luma(r), 1e-3);
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
//== autolevels
uniform float p_siyahKirp, p_beyazKirp, p_zamanYumu, p_kanallarAyriIsle, p_guc;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 mn, mx, av; stats(mn, mx, av); vec3 c = unpre(s);
  if (p_kanallarAyriIsle < 0.5) { mn = vec3(min(mn.r, min(mn.g, mn.b))); mx = vec3(max(mx.r, max(mx.g, mx.b))); }
  mn += p_siyahKirp / 100.0; mx -= p_beyazKirp / 100.0;
  vec3 r = clamp((c - mn) / max(mx - mn, vec3(0.05)), 0.0, 1.0);
  o = pre(mix(c, r, p_guc / 100.0), s.a);
}
//== colorama
GRADIENT(palet)
uniform float p_giris, p_faz, p_donguSayi, p_hiz, p_renkleriAraDege;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float v = p_giris < 0.5 ? luma(c) : p_giris < 1.5 ? rgb2hsv(c).x : p_giris < 2.5 ? c.r : p_giris < 3.5 ? c.g : c.b;
  float x = fract(v * p_donguSayi + p_faz / 100.0 + u_t * p_hiz);
  if (p_renkleriAraDege < 0.5) x = floor(x * float(paln_palet())) / float(paln_palet());
  o = pre(grad_palet(x), s.a);
}
//== chanshift
uniform float p_kirmiziKayn, p_yesilKayn, p_maviKayn, p_alfaKayn;
float src(vec4 s, vec3 c, float k, int base) {
  // her seçim listesinin ilk öğesi kanalın kendisi; diğerleri sıradaki
  int i = int(k + 0.5); int ord[7];
  if (base == 0) ord = int[7](0, 1, 2, 3, 4, 5, 6); else if (base == 1) ord = int[7](1, 0, 2, 3, 4, 5, 6); else if (base == 2) ord = int[7](2, 0, 1, 3, 4, 5, 6); else ord = int[7](3, 0, 1, 2, 4, 5, 6);
  int w = ord[clamp(i, 0, 6)];
  return w == 0 ? c.r : w == 1 ? c.g : w == 2 ? c.b : w == 3 ? s.a : w == 4 ? luma(c) : w == 5 ? 0.0 : 1.0;
}
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s);
  o = pre(vec3(src(s, c, p_kirmiziKayn, 0), src(s, c, p_yesilKayn, 1), src(s, c, p_maviKayn, 2)), src(s, c, p_alfaKayn, 3));
}
//== equalize
uniform float p_yontem, p_guc, p_bolgeBoyu, p_kontrastSini;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c);
  // yaklaşık eşitleme: kaba histogramdan birikimli dağılım
  float below = 0.0, n = 0.0;
  for (int j = 0; j < 10; j++) for (int i = 0; i < 10; i++) {
    vec2 b = (vec2(float(i), float(j)) + 0.5) / 10.0;
    if (p_yontem > 1.5) b = boxUV(here()) + (b - 0.5) * p_bolgeBoyu * u_s / u_box.zw * 2.0;
    vec4 x = texPx(boxPx(b)); if (x.a < 0.1) continue; n += 1.0; below += step(luma(x.rgb / x.a), l); }
  float e = n > 0.0 ? below / n : l; e = mix(l, e, 1.0 / max(1.0, p_kontrastSini * 0.3));
  vec3 r = p_yontem > 0.5 && p_yontem < 1.5 ? c * (e / max(l, 1e-3)) : c * (e / max(l, 1e-3));
  o = pre(clamp(mix(c, r, p_guc / 100.0), 0.0, 1.0), s.a);
}
//== nightvision
uniform vec3 c_yesilTonu; uniform float p_kazanc, p_gren, p_tarama, p_vinyet, p_otomatikPozl;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); if (p_otomatikPozl > 0.5) { vec3 mn, mx, av; stats(mn, mx, av); l = l / max(luma(av) * 2.0, 0.1); }
  l = 1.0 - exp(-l * p_kazanc * 1.6);
  l += (hash1(floor(here()) + floor(u_t * 24.0) * 3.1) - 0.5) * p_gren / 100.0 * 0.6;
  l *= 1.0 - p_tarama / 100.0 * 0.5 * step(0.5, fract(here().y / 3.0));
  vec2 b = boxUV(here()) - 0.5; l *= 1.0 - p_vinyet / 100.0 * smoothstep(0.2, 0.75, length(b));
  o = pre(clamp(c_yesilTonu * l * 1.2, 0.0, 1.0), s.a);
}
//== xray
uniform vec3 c_ton; uniform float p_terslik, p_kontrast, p_kenarVurg, p_alfayiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float l = luma(c);
  l = mix(l, 1.0 - l, p_terslik / 100.0); l = (l - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5;
  vec2 e = vec2(1.0) ; float ed = abs(luma(unpre(texPx(here() + vec2(e.x, 0.0)))) - luma(unpre(texPx(here() - vec2(e.x, 0.0))))) + abs(luma(unpre(texPx(here() + vec2(0.0, e.y)))) - luma(unpre(texPx(here() - vec2(0.0, e.y)))));
  l += ed * p_kenarVurg / 100.0 * 2.0;
  vec3 r = clamp(c_ton * l * 1.1 + pow(max(l, 0.0), 3.0) * 0.3, 0.0, 1.0);
  o = pre(r, p_alfayiKoru > 0.5 ? s.a : max(s.a, l * 0.0 + 1.0) * step(0.0, boxUV(here()).x) * step(boxUV(here()).x, 1.0) * step(0.0, boxUV(here()).y) * step(boxUV(here()).y, 1.0));
}
//== underwater
uniform vec3 c_suTonu; uniform float p_derinlik, p_dalgaYuks, p_dalgaBoyu, p_akisHizi, p_isikDese;
void main() {
  vec2 q = toUnit(here()); float wl = max(p_dalgaBoyu, 1.0);
  vec2 d = vec2(sin(q.y / wl * TAU + u_t * p_akisHizi * TAU), cos(q.x / wl * TAU * 0.8 + u_t * p_akisHizi * TAU * 1.3)) * p_dalgaYuks;
  vec4 s = texU(q + d); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float dp = p_derinlik / 100.0;
  c = mix(c, c_suTonu * (0.4 + luma(c)), dp * 0.75); c *= mix(1.0, 0.65, dp * boxUV(here()).y);
  if (p_isikDese > 0.5) { vec2 p = q / (wl * 0.6) + u_t * p_akisHizi * 0.6; float caust = pow(1.0 - abs(pnoise(p) + pnoise(p * 1.7 + 3.0)) * 0.7, 6.0); c += caust * 0.25 * (1.0 - boxUV(here()).y * 0.7); }
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== bleach
uniform float p_agartmaGucu, p_doygunlu, p_kontrast, p_golgeSevi, p_gren;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c); vec3 bl = overlayB(c, vec3(l));
  c = mix(c, bl, p_agartmaGucu / 100.0); c = satAdj(c, 1.0 + p_doygunlu / 100.0); c = conAdj(c, 1.0 + p_kontrast / 100.0, 0.5);
  c += p_golgeSevi / 100.0 * 0.25 * (1.0 - smoothstep(0.0, 0.5, l));
  c += (hash1(floor(here()) + floor(u_t * 24.0)) - 0.5) * p_gren / 100.0 * 0.4;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== crossprocess
uniform float p_yesilKaym, p_maviKaym, p_kontrast, p_doygunlu, p_gorunum;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  vec3 r = p_gorunum < 0.5 ? vec3(smoothstep(0.05, 0.95, c.r), pow(c.g, 0.85), c.b * 0.7 + 0.15) : p_gorunum < 1.5 ? vec3(pow(c.r, 1.2), smoothstep(0.0, 1.0, c.g), pow(c.b, 0.7) * 0.85 + 0.1) : c;
  r.g += p_yesilKaym / 100.0 * 0.15; r.b += p_maviKaym / 100.0 * 0.15;
  r = conAdj(r, 1.0 + p_kontrast / 100.0, 0.5); r = satAdj(r, 1.0 + p_doygunlu / 100.0);
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
//== lomo
uniform float p_doygunlu, p_kontrast, p_vinyet, p_vinyetYari, p_renkKaym; uniform vec2 p_merkez;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); c = satAdj(c, 1.0 + p_doygunlu / 100.0); c = conAdj(c, 1.0 + p_kontrast / 100.0, 0.5);
  c.r += p_renkKaym / 100.0 * 0.1; c.b -= p_renkKaym / 100.0 * 0.1;
  vec2 r = (toUnit(here()) - p_merkez) / (boxU() * 0.5); float d = length(r);
  float R = p_vinyetYari / 100.0 * 1.2; c *= 1.0 - p_vinyet / 100.0 * smoothstep(R * 0.5, R + 0.4, d);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== cinematic
uniform vec3 c_golgeReng, c_acikTonReng; uniform float p_golgeGucu, p_acikTonGucu, p_ortaNokt, p_notrRenkKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c); float m = p_ortaNokt / 100.0;
  float wS = 1.0 - smoothstep(0.0, m * 1.6, l), wH = smoothstep(m * 0.6, 1.0, l);
  float sat = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)); float k = p_notrRenkKoru > 0.5 ? mix(0.4, 1.0, smoothstep(0.0, 0.3, sat)) : 1.0;
  vec3 r = mix(c, softLightB(c, c_golgeReng), wS * p_golgeGucu / 100.0 * k); r = mix(r, softLightB(r, c_acikTonReng), wH * p_acikTonGucu / 100.0 * k);
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
//== infrared
uniform float p_kirmiziKatk, p_yesilKatk, p_maviKatk, p_gokyuzuKara, p_tekRenk; uniform vec3 c_renkTonu;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float v = dot(c, vec3(p_kirmiziKatk, p_yesilKatk, p_maviKatk) / 100.0);
  float sky = smoothstep(0.1, 0.4, c.b - max(c.r, c.g)); v *= 1.0 - sky * p_gokyuzuKara / 100.0;
  v = clamp(v, 0.0, 1.0);
  vec3 r = p_tekRenk > 0.5 ? vec3(v) * c_renkTonu : vec3(v, c.g * 0.8 + v * 0.2, c.r * 0.6 + 0.1);
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
//== autocolor
uniform float p_siyahKirp, p_beyazKirp, p_renkKaymDuze, p_zamanYumu, p_notrTonlKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 mn, mx, av; stats(mn, mx, av); vec3 c = unpre(s);
  vec3 g = c * mix(vec3(1.0), vec3(luma(av)) / max(av, vec3(0.05)), p_renkKaymDuze / 100.0);
  float lo = min(mn.r, min(mn.g, mn.b)) + p_siyahKirp / 100.0, hi = max(mx.r, max(mx.g, mx.b)) - p_beyazKirp / 100.0;
  g = clamp((g - lo) / max(hi - lo, 0.05), 0.0, 1.0);
  o = pre(g, s.a);
}
//== huesat
uniform float p_renkAral, p_ton, p_doygunlu, p_aciklik, p_renklend, p_renklendTonu, p_renklendDoyg;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 h = rgb2hsl(c); vec3 r;
  if (p_renklend > 0.5) r = hsl2rgb(vec3(fract(p_renklendTonu / 360.0), p_renklendDoyg / 100.0, h.z));
  else { h.x = fract(h.x + p_ton / 360.0); h.y = clamp(h.y * (1.0 + p_doygunlu / 100.0), 0.0, 1.0); r = hsl2rgb(h); }
  r = p_aciklik >= 0.0 ? mix(r, vec3(1.0), p_aciklik / 100.0) : r * (1.0 + p_aciklik / 100.0);
  o = pre(clamp(mix(c, r, p_renklend > 0.5 ? 1.0 : hueRange(c, p_renkAral)), 0.0, 1.0), s.a);
}
//== gammagain
uniform float p_kanal, p_gama, p_taban, p_kazanc, p_siyahiSini;
float gg(float x) { x = x * p_kazanc + p_taban / 100.0; if (p_siyahiSini > 0.5) x = max(x, 0.0); return pow(max(x, 0.0), 1.0 / max(p_gama, 0.01)); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  if (p_kanal < 0.5) c = vec3(gg(c.r), gg(c.g), gg(c.b)); else if (p_kanal < 1.5) c.r = gg(c.r); else if (p_kanal < 2.5) c.g = gg(c.g); else c.b = gg(c.b);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== lumetri
uniform sampler2D s_yaraticiLut; uniform float p_yaraticiLutOn;
uniform float p_sicaklik, p_renkTonu, p_pozlama, p_kontrast, p_acikTonl, p_golgeler, p_beyazlar, p_siyahlar, p_doygunlu, p_canlilik, p_lutYogu, p_vinyet;
vec3 lut8(sampler2D t, vec3 c) { // 512x512 (8x8 karo, 64 düzey) LUT görseli
  float b = c.b * 63.0; float b0 = floor(b), b1 = min(63.0, b0 + 1.0);
  vec2 t0 = vec2(mod(b0, 8.0), floor(b0 / 8.0)), t1 = vec2(mod(b1, 8.0), floor(b1 / 8.0)); vec2 rg = c.rg * 63.0 / 64.0 + 0.5 / 64.0;
  vec3 a = texture(t, (t0 + rg) / 8.0).rgb, d = texture(t, (t1 + rg) / 8.0).rgb; return mix(a, d, b - b0); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  c *= vec3(1.0 + p_sicaklik / 100.0 * 0.2, 1.0 - p_renkTonu / 100.0 * 0.15, 1.0 - p_sicaklik / 100.0 * 0.2);
  c = lin2srgb(srgb2lin(c) * exp2(p_pozlama)); c = conAdj(c, 1.0 + p_kontrast / 100.0, 0.5);
  float l = luma(c); c += p_golgeler / 100.0 * 0.3 * (1.0 - smoothstep(0.0, 0.5, l)) + p_acikTonl / 100.0 * 0.3 * smoothstep(0.5, 1.0, l);
  c += p_beyazlar / 100.0 * 0.2 * smoothstep(0.75, 1.0, l) + p_siyahlar / 100.0 * 0.2 * (1.0 - smoothstep(0.0, 0.25, l));
  c = satAdj(clamp(c, 0.0, 1.0), 1.0 + p_doygunlu / 100.0);
  float sat = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)); c = satAdj(c, 1.0 + p_canlilik / 100.0 * (1.0 - sat));
  if (p_yaraticiLutOn > 0.5) c = mix(c, lut8(s_yaraticiLut, clamp(c, 0.0, 1.0)), p_lutYogu / 100.0);
  vec2 b = boxUV(here()) - 0.5; c *= 1.0 - p_vinyet / 100.0 * smoothstep(0.25, 0.75, length(b));
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== lut
uniform sampler2D s_lutDosy; uniform float p_lutDosyOn; uniform float p_yogunluk, p_enterpol, p_girisProf, p_cikisiSini;
vec3 lut8(sampler2D t, vec3 c) { float b = c.b * 63.0; float b0 = floor(b), b1 = min(63.0, b0 + 1.0);
  vec2 t0 = vec2(mod(b0, 8.0), floor(b0 / 8.0)), t1 = vec2(mod(b1, 8.0), floor(b1 / 8.0)); vec2 rg = c.rg * 63.0 / 64.0 + 0.5 / 64.0;
  return mix(texture(t, (t0 + rg) / 8.0).rgb, texture(t, (t1 + rg) / 8.0).rgb, b - b0); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); if (p_girisProf > 2.5) c = pow(c, vec3(0.8)) * 1.1 - 0.05;
  vec3 r;
  if (p_lutDosyOn > 0.5) r = lut8(s_lutDosy, clamp(c, 0.0, 1.0));
  else { // dosya yoksa yerleşik sinema görünümü
    float l = luma(c); r = softLightB(c, mix(vec3(0.0, 0.45, 0.5), vec3(1.0, 0.62, 0.35), smoothstep(0.1, 0.9, l))); r = conAdj(r, 1.12, 0.5); }
  if (p_cikisiSini > 0.5) r = clamp(r, 0.0, 1.0);
  o = pre(clamp(mix(c, r, p_yogunluk / 100.0), 0.0, 1.0), s.a);
}
//== bwmix
uniform float p_kirmizi, p_sari, p_yesil, p_camgobeg, p_mavi, p_mor, p_renkTonuEkle; uniform vec3 c_ton;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 h = rgb2hsv(c); float hx = h.x * 6.0;
  float w[6] = float[6](p_kirmizi, p_sari, p_yesil, p_camgobeg, p_mavi, p_mor);
  int i0 = int(floor(hx)) % 6; int i1 = (i0 + 1) % 6; float wv = mix(w[i0], w[i1], fract(hx)) / 100.0;
  float g = luma(c) + (wv - 0.4) * h.y * h.z * 0.8;
  vec3 r = vec3(clamp(g, 0.0, 1.0)); if (p_renkTonuEkle > 0.5) r = softLightB(r, c_ton);
  o = pre(r, s.a);
}
//== hdrsdr
uniform float p_girisAkta, p_kaynakTepeParl, p_cikisTepeParl, p_tonEsle, p_renkSiki;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 l = srgb2lin(c) * (p_kaynakTepeParl / max(p_cikisTepeParl, 1.0)) * 0.25;
  vec3 m;
  if (p_tonEsle < 1.5 && p_tonEsle > 0.5) m = l / (1.0 + l);
  else if (p_tonEsle > 1.5) { vec3 x = l * 2.0; m = ((x * (0.15 * x + 0.05) + 0.004) / (x * (0.15 * x + 0.5) + 0.06) - 0.0667) / 0.81; }
  else m = l * (1.0 + l / 16.0) / (1.0 + l);
  float lm = luma(m); m = mix(vec3(lm), m, p_renkSiki / 100.0 * 0.5 + 0.5);
  o = pre(clamp(lin2srgb(m) * 1.08, 0.0, 1.0), s.a);
}
//== logconv
uniform float p_logProf, p_pozlama, p_cikisProf, p_acikTonYumu;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 lin;
  if (p_logProf < 0.5) lin = mix((c - 0.0928641) / 5.367655, pow(vec3(10.0), (c * 1023.0 - 420.0) / 261.5) * 0.19 - 0.01, step(171.2102946929 / 1023.0, c));
  else if (p_logProf < 1.5) lin = (pow(vec3(10.0), (c - 0.12512248) / 0.36726845) - 1.0) / 14.98325;
  else if (p_logProf < 2.5) lin = mix((c - 0.125) / 5.6, pow(vec3(10.0), (c - 0.598206) / 0.241514) - 0.00873, step(0.181, c));
  else lin = mix((c - 0.092809) / 5.367655, (pow(vec3(10.0), (c - 0.385537) / 0.247190) - 0.052272) / 5.555556, step(0.1496582, c));
  lin = max(lin, 0.0) * exp2(p_pozlama);
  lin = lin / (1.0 + lin * p_acikTonYumu / 100.0 * 0.5);
  o = pre(clamp(lin2srgb(lin), 0.0, 1.0), s.a);
}
//== colorprofile
uniform float p_girisProf, p_cikisProf, p_gamutEsle, p_siyahNoktTela;
mat3 toXYZ(float k) { if (k < 1.5) return mat3(0.4124, 0.2126, 0.0193, 0.3576, 0.7152, 0.1192, 0.1805, 0.0722, 0.9505); if (k < 2.5) return mat3(0.4866, 0.2290, 0.0, 0.2657, 0.6917, 0.0451, 0.1982, 0.0793, 1.0439); if (k < 3.5) return mat3(0.4124, 0.2126, 0.0193, 0.3576, 0.7152, 0.1192, 0.1805, 0.0722, 0.9505); return mat3(0.6370, 0.2627, 0.0, 0.1446, 0.6780, 0.0281, 0.1689, 0.0593, 1.0610); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float gi = p_girisProf < 0.5 ? 1.0 : p_girisProf; float go = p_cikisProf + 1.0;
  vec3 l = srgb2lin(unpre(s)); vec3 x = toXYZ(gi) * l; vec3 r = inverse(toXYZ(go)) * x;
  if (p_gamutEsle < 0.5) { float m = max(r.r, max(r.g, r.b)); if (m > 1.0) r /= m; } else if (p_gamutEsle < 1.5) { float lm = dot(r, vec3(0.2126, 0.7152, 0.0722)); r = mix(vec3(lm), r, 0.92); }
  o = pre(clamp(lin2srgb(r), 0.0, 1.0), s.a);
}
//== broadcast
uniform float p_yayinStan, p_duzeltme, p_sinirDisiGost, p_yasalAral;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float lo = p_yasalAral > 0.5 ? 16.0 / 255.0 : 0.0, hi = p_yasalAral > 0.5 ? 235.0 / 255.0 : 1.0;
  float l = luma(c); float sat = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)); float maxS = p_yayinStan < 0.5 ? 0.85 : 0.75;
  bool bad = l > hi || l < lo || sat > maxS;
  if (p_sinirDisiGost > 0.5 && bad) { o = pre(vec3(1.0, 0.0, 1.0), s.a); return; }
  if (p_duzeltme < 0.5) c *= min(1.0, hi / max(l, 1e-3)); else if (p_duzeltme < 1.5) c = satAdj(c, min(1.0, maxS / max(sat, 1e-3))); else c = clamp(c, lo, hi);
  c = mix(vec3(lo), vec3(hi), c);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== colorstab
uniform float p_referansZama, p_zamanPenc, p_parlakliDuze, p_renkDuze, p_sahneDegiAlgi;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 mn, mx, av; stats(mn, mx, av); vec3 c = unpre(s);
  float tl = 0.45; vec3 g = c * mix(1.0, tl / max(luma(av), 0.05), p_parlakliDuze / 100.0);
  g *= mix(vec3(1.0), vec3(luma(av)) / max(av, vec3(0.05)), p_renkDuze / 100.0);
  o = pre(clamp(g, 0.0, 1.0), s.a);
}
//== darkglow_a
uniform float p_esik;
void main() { vec4 s = texture(u_tex, v_uv); float l = s.a > 0.0 ? luma(s.rgb / s.a) : 1.0; float d = (1.0 - smoothstep(p_esik / 100.0 - 0.1, p_esik / 100.0 + 0.05, l)) * s.a; o = vec4(d); }
//== darkglow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_yogunluk, p_karistir, p_yalnizHale;
void main() {
  vec4 s = texture(u_src, v_uv); float h = clamp(texture(u_aux, v_uv).a * p_yogunluk / 100.0 * 1.8, 0.0, 1.0);
  if (p_yalnizHale > 0.5) { o = vec4(c_renk, 1.0) * h; return; }
  vec3 c = unpre(s); vec3 r = p_karistir < 0.5 ? c * mix(vec3(1.0), c_renk, h) : mix(c, c_renk, h);
  float a = max(s.a, h * (1.0 - s.a) * (p_karistir < 0.5 ? 1.0 : 1.0));
  o = s.a > 0.0 ? pre(r, s.a) + vec4(c_renk, 1.0) * h * (1.0 - s.a) : vec4(c_renk, 1.0) * h;
}
//== lightglow_a
uniform float p_esik;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = s.a > 0.0 ? s.rgb / s.a : vec3(0.0); float k = smoothstep(p_esik / 100.0 - 0.05, p_esik / 100.0 + 0.15, luma(c)); o = vec4(c * k, k) * s.a; }
//== lightglow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_yogunluk, p_karistir, p_yalnizParl;
void main() {
  vec4 s = texture(u_src, v_uv); vec4 g = texture(u_aux, v_uv) * p_yogunluk / 100.0 * 2.2; g.rgb *= c_renk;
  if (p_yalnizParl > 0.5) { o = min(g, vec4(1.0)); return; }
  vec3 add = p_karistir < 0.5 ? g.rgb * (1.0 - s.rgb) : g.rgb;
  o = vec4(min(s.rgb + add, vec3(1.0)), max(s.a, min(1.0, g.a)));
}
//== softglow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_yogunluk, p_parlakliEsig, p_orijinalAyriKoru;
void main() {
  vec4 s = texture(u_src, v_uv); vec4 b = texture(u_aux, v_uv); vec3 bc = b.a > 0.0 ? b.rgb / b.a : vec3(0.0);
  float k = smoothstep(p_parlakliEsig / 100.0 - 0.1, 1.0, luma(bc)) * p_yogunluk / 100.0;
  vec3 c = unpre(s); vec3 r = mix(c, screenB(c, bc * c_renk), k);
  if (p_orijinalAyriKoru > 0.5) r = mix(r, c, 0.25);
  float a = max(s.a, b.a * k);
  o = pre(clamp(r, 0.0, 1.0), max(s.a, a * 0.6));
}
