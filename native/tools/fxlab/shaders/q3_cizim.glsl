// 1000 rehberi bölüm 3 (847–868): çizim, sanat ve malzeme
//== lineweight
uniform float p_enBuyuKali, p_yumusatm, p_uclariKoru;
// Mürekkep çizgileri: kutu boyunca konum u (en uzun eksen) → kalınlık profili sin(πu); çizgi o kalınlığa genişler, uçlar korunur/incelir
float ink(vec2 p) { vec4 c = texPx(p); return c.a > 0.5 && luma(unpre(c)) < 0.4 ? 1.0 : 0.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float u = u_box.z >= u_box.w ? b.x : b.y; float prof = sin(clamp(u, 0.0, 1.0) * 3.14159); if (p_uclariKoru > 0.5) prof = max(prof, 0.35);
  float W = p_enBuyuKali * u_s * prof * 0.5; float sm = max(p_yumusatm * u_s * 0.2, 0.75); float d = 1e5;
  for (int i = 0; i < 16; i++) { float a = float(i) / 16.0 * TAU; vec2 dd = vec2(cos(a), sin(a)); for (int k = 0; k <= 12; k++) { float r = float(k) / 12.0 * max(W, 1.0); if (ink(here() + dd * r) > 0.5) { d = min(d, r); break; } } }
  float cov = 1.0 - smoothstep(W - sm, W + sm, d); if (cov <= 0.0 || ink(here()) > 0.5 && W < 0.6) { o = s; return; }
  vec4 lc = vec4(0.05, 0.05, 0.07, 1.0); o = mix(s, overPre(lc, s), cov); }

//== linesmooth
uniform float p_uyumTole, p_koseKoru, p_cikti, p_cizgiKali;
// Alfa konturu düzleştirilir (bulanıklaştırıp eşikleme); köşelerde daha az yumuşatma; isteğe bağlı kontur çizgisi
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float R = max(p_uyumTole * u_s, 0.75); float a = 0.0, w = 0.0;
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { float g = exp(-float(i * i + j * j) / 6.0); a += texPx(p + vec2(i, j) / 3.0 * R).a * g; w += g; } a /= w;
  float corner = abs(a - s.a); float k = mix(1.0, 0.25, p_koseKoru / 100.0 * smoothstep(0.1, 0.4, corner)); a = mix(s.a, a, k);
  float aa = p_cikti < 0.5 ? smoothstep(0.5 - 0.5 / R, 0.5 + 0.5 / R, a) : step(0.5, a); vec3 base = s.a > 0.0 ? unpre(s) : unpre(texPx(p + alphaGrad(p, 2.0) * -4.0));
  float edge = 1.0 - smoothstep(0.0, p_cizgiKali * u_s * 0.08 + 0.02, abs(a - 0.5)) ; vec3 c = mix(base, vec3(0.05), edge * step(0.1, p_cizgiKali)); o = pre(c, max(aa, edge * step(0.1, p_cizgiKali))); }

//== colorbleed
uniform sampler2D s_dolguKayn; uniform float p_dolguKaynOn, p_sizma, p_guc, p_koyuCizgMerk;
// Koyu çizgi pikselleri, sızma mesafesindeki çizgi olmayan komşu renkleri içine çeker; çizgi merkezi koyu kalabilir
float ink(vec2 p) { vec4 c = texPx(p); return c.a > 0.5 && luma(unpre(c)) < 0.3 ? 1.0 : 0.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); if (ink(p) < 0.5) { o = s; return; } float R = max(p_sizma * u_s, 1.0); vec3 acc = vec3(0.0); float w = 0.0; float dmin = 1e5;
  for (int i = 0; i < 12; i++) { float a = float(i) / 12.0 * TAU; vec2 d = vec2(cos(a), sin(a)); for (int k = 1; k <= 8; k++) { vec2 q = p + d * float(k) / 8.0 * R * 2.0; if (ink(q) > 0.5) continue;
      vec4 c = p_dolguKaynOn > 0.5 ? texture(s_dolguKayn, boxUV(q)) : texPx(q); if (c.a < 0.3) break; float dist = float(k) / 8.0 * R * 2.0; acc += unpre(c) / dist; w += 1.0 / dist; dmin = min(dmin, dist); break; } }
  if (w <= 0.0) { o = s; return; } vec3 fill = acc / w; float k = exp(-dmin / R) * p_guc / 100.0; if (p_koyuCizgMerk > 0.5) k *= smoothstep(R * 1.6, R * 0.4, dmin);
  o = pre(mix(unpre(s), fill * 0.8, k), s.a); }

//== paperfold
uniform sampler2D s_katCizg; uniform float p_katCizgOn, p_katAcis, p_kirisikl, p_isikAcis;
// Kat çizgileri (kaynak ya da dikey orta + köşegen): her kat iki yanı farklı eğimle ışık alır; kırışıklık gürültülü normal
float side(vec2 b) { if (p_katCizgOn > 0.5) { float a = 0.0; for (int k = 1; k <= 24; k++) { if (texture(s_katCizg, vec2(b.x - float(k) / 24.0, b.y)).a > 0.5) { a = mod(a + 1.0, 2.0); } } return a; }
  return step(0.5, b.x) + step(b.y, 0.35 + b.x * 0.3) * 2.0; }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 b = boxUV(here()); float sd = side(b); float tilt = radians(p_katAcis) * (mod(sd, 2.0) < 0.5 ? 1.0 : -1.0);
  vec3 n = normalize(vec3(sin(tilt), sd > 1.5 ? sin(tilt) * 0.5 : 0.0, cos(tilt))); vec2 cr = vec2(fbm(here() / max(14.0 * u_s, 1.0), 3.0), fbm(here() / max(14.0 * u_s, 1.0) + 9.0, 3.0)) * p_kirisikl * 0.03; n = normalize(n + vec3(cr, 0.0));
  float la = radians(p_isikAcis); vec3 L = normalize(vec3(cos(la), -sin(la), 1.2)); float sh = clamp(dot(n, L), 0.0, 1.0) / dot(vec3(0.0, 0.0, 1.0), L);
  vec2 gx = vec2(1.0 / u_box.z, 0.0); float crease = abs(side(b + gx * 2.0) - side(b - gx * 2.0)) > 0.0 ? 0.75 : 1.0; o = pre(unpre(s) * clamp(sh, 0.55, 1.25) * crease, s.a); }

//== stencilprint
uniform float p_sablon, p_kopruGeni, p_kenarSizi, p_katmanMaskCika;
// Ton seviyeleri ayrı şablonlarla basılır; şablon içinde asılı kalan adacıklar için düzenli köprü şeritleri kâğıt rengi bırakır; mürekkep kenarı hafif taşar
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float N = clamp(floor(p_sablon), 1.0, 12.0); float bleed = p_kenarSizi * u_s; float l = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) l += lumAt(p + vec2(i, j) * bleed * 0.5); l /= 9.0; float lev = floor((1.0 - l) * N + 0.5) / N;
  vec3 paper = vec3(0.96, 0.94, 0.88); vec3 inkc = unpre(s) * 0.85; int layer = int(lev * N + 0.5);
  float bridge = step(fract((p.x + p.y * 0.35) / (48.0 * u_s)), p_kopruGeni * u_s / (48.0 * u_s)) * step(1.5, float(layer));
  vec3 c = mix(paper, inkc, lev * (1.0 - bridge)); if (p_katmanMaskCika > 0.5) { vec2 b = boxUV(p); float k = floor(b.x * N); c = vec3(step(abs(lev * N - k - 1.0), 0.5)); }
  c *= 0.97 + 0.03 * hash1(floor(p / max(u_s, 1.0))); o = pre(c, s.a); }

//== woodcarve
uniform vec3 c_ahsap; uniform float p_oyukDeri, p_cizgiAral, p_keskiUcu, p_isikAcis;
// Koyu tonlar geniş oyuk kanalları olur; V/U keski profili yanlardan ışık alır; ahşap damarı yüzeyde
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 p = here(); float sp = max(p_cizgiAral * u_s, 2.0); float l = luma(unpre(s));
  float v = p.y + fbm(p / (sp * 6.0), 2.0) * sp * 1.5; float f = fract(v / sp); float hw = (1.0 - l) * 0.5; float x = (f - 0.5) / max(hw, 0.02);
  float inG = step(abs(x), 1.0); float prof = p_keskiUcu < 0.5 ? x : sign(x) * x * x; float la = radians(p_isikAcis); float slope = -sin(la) * prof * p_oyukDeri * 0.06;
  float grain = 0.88 + 0.12 * sin(p.x / (4.0 * u_s) + fbm(p / (40.0 * u_s), 3.0) * 8.0); vec3 wood = c_ahsap * grain;
  vec3 c = inG > 0.5 ? wood * (0.45 + slope - abs(prof) * 0.1) : wood * 1.05; o = pre(clamp(c, 0.0, 1.0), s.a); }

//== paperstitch
uniform vec3 c_iplikReng; uniform float p_delikAral, p_delikCapi, p_iplik, p_deliklerAlfaYap;
// Kenardan içeri sabit mesafede delik dizisi; delikler arasında iplik; delikler gerçek saydamlık olabilir
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = s; return; } vec2 p = here(); float inset = p_delikAral * u_s * 0.8; float d = innerDist(p, inset * 2.0);
  vec2 q = toUnit(p); float per = atan(q.y, q.x) * length(q); float sp = max(p_delikAral, 1.0); float k = fract(per / sp); float onRing = 1.0 - smoothstep(0.5 * u_s, 1.5 * u_s, abs(d - inset));
  float hole = onRing * (1.0 - smoothstep(p_delikCapi * 0.35, p_delikCapi * 0.5, abs(k - 0.5) * sp));
  float thread = (1.0 - smoothstep(p_iplik * u_s * 0.4, p_iplik * u_s * 0.6 + 0.5, abs(d - inset))) * step(k, 0.5) * (1.0 - hole);
  vec4 res = overPre(vec4(c_iplikReng, 1.0) * thread, s); if (hole > 0.0) res = p_deliklerAlfaYap > 0.5 ? res * (1.0 - hole) : mix(res, vec4(0.1, 0.1, 0.1, 1.0), hole); o = res; }

//== cardboardcut
uniform vec3 c_icRenk; uniform float p_kartonKali, p_olukAral, p_kesitGoru;
// Kesik kenar bandında oluklu karton kesiti: iki düz kâğıt arasında dalgalı oluk
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = s; return; } vec2 p = here(); float T = p_kartonKali * u_s; float d = innerDist(p, T * 1.2); if (d > T) { o = s; return; }
  vec2 q = toUnit(p); float along = atan(q.y, q.x) * length(q); float y = d / T; float wave = 0.5 + 0.38 * sin(along / max(p_olukAral, 0.5) * 3.14159);
  float liner = step(y, 0.12) + step(0.88, y); float flute = 1.0 - smoothstep(0.03, 0.09, abs(y - wave)); float cav = step(0.12, y) * step(y, 0.88) * (1.0 - flute);
  vec3 c = liner > 0.0 ? c_icRenk * 1.08 : (flute > 0.0 ? c_icRenk * 0.92 : c_icRenk * 0.45); o = mix(s, pre(c, 1.0), p_kesitGoru / 100.0 * (1.0 - cav * 0.0)); }

//== coffeering
uniform float p_halkaGeni, p_pigment, p_kuruma, p_kenarPuru;
// Kuruyan boya lekesi: renk alanının kenarına doğru biriken koyu pigment halkası; kenar pürüzlü
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 p = here(); float W = max(p_halkaGeni * u_s, 0.5); float rough = (fbm(p / (10.0 * u_s), 3.0)) * p_kenarPuru / 100.0 * W;
  float d = innerDist(p, W * 4.0) + rough; vec3 c = unpre(s); float l0 = luma(c); float edgeC = 0.0;
  for (int i = 0; i < 8; i++) { float a = float(i) / 8.0 * TAU; vec3 n = unpre(texPx(p + vec2(cos(a), sin(a)) * W)); edgeC = max(edgeC, length(n - c)); }
  float ring = max(exp(-max(d, 0.0) / W), smoothstep(0.15, 0.4, edgeC) * 0.8); float k = ring * p_pigment / 100.0 * p_kuruma / 100.0 * 1.6; o = pre(c * (1.0 - k * 0.7) * mix(vec3(1.0), c * 1.2 + 0.1, k * 0.3), s.a); }

//== scratchreveal
uniform sampler2D s_altKatm, s_kaziMask; uniform float p_altKatmOn, p_kaziMaskOn, p_kaziGeni, p_kalinti;
// Kazıma maskesi (kaynak ya da zamanla çoğalan rastgele çizikler) üst boyayı kaldırır, alt katman görünür; kenarlarda kalıntı
float scratches(vec2 q) { float m = 0.0; for (int i = 0; i < 10; i++) { float t0 = float(i) * 0.35; if (u_t < t0) break; vec2 h = hash2(vec2(float(i), 3.7)); vec2 a = (h - 0.5) * boxU(); float ang = h.x * 6.28; vec2 d = vec2(cos(ang), sin(ang));
    float len = min((u_t - t0) / 0.3, 1.0) * boxU().x * 0.6; vec2 ap = q - a; float tt = clamp(dot(ap, d), 0.0, len); m = max(m, 1.0 - smoothstep(p_kaziGeni * 0.4, p_kaziGeni * 0.5 + 1.0, length(ap - d * tt))); } return m; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float m = p_kaziMaskOn > 0.5 ? texture(s_kaziMask, b).a : scratches(toUnit(here()));
  float res = hash1(floor(here() / max(2.0 * u_s, 1.0))) < p_kalinti / 100.0 ? 0.6 : 0.0; m *= 1.0 - res; vec4 under = p_altKatmOn > 0.5 ? texture(s_altKatm, b) : vec4(vec3(0.95, 0.85, 0.3) * s.a, s.a);
  o = mix(s, under, m); }

//== paperfibers
uniform vec3 c_lifReng; uniform float p_lifUzun, p_lifYogu, p_lifKali;
// Kesik kâğıt kenarından dışarı uzanan ince lifler: kenar boyunca tohumlu konumlar, normal yönünde hafif kıvrımlı
void main() { vec4 s = texture(u_tex, v_uv); if (s.a > 0.5) { o = s; return; } vec2 p = here(); float Lf = p_lifUzun * u_s; float d = outerDist(p, Lf * 1.2); if (d > Lf || d <= 0.0) { o = s; return; }
  vec2 g = alphaGrad(p - normalize(alphaGrad(p, 1.5) + 1e-5) * d, 1.5); vec2 n = length(g) > 1e-5 ? -normalize(g) : vec2(0.0, -1.0); vec2 t = vec2(-n.y, n.x);
  vec2 base = p - n * d; float along = dot(base, t); float sp = max(400.0 / max(p_lifYogu, 1.0), 0.6) * u_s; float id = floor(along / sp); float f = fract(along / sp);
  float h = hash1(vec2(id, 1.7)); float len = Lf * (0.3 + 0.7 * h); float curve = sin(d / max(Lf, 1.0) * 3.0 + h * 6.28) * sp * 0.3; float x = (f - 0.5) * sp - curve;
  float v = (1.0 - smoothstep(p_lifKali * u_s * 0.5, p_lifKali * u_s * 0.5 + 0.8, abs(x))) * step(d, len) * (1.0 - d / max(len, 1.0) * 0.6); o = vec4(c_lifReng, 1.0) * v; }

//== pencilpressure
uniform sampler2D s_cizgiYolu; uniform vec3 c_renk; uniform float p_cizgiYoluOn, p_tane, p_yogunluk;
// Yol (kaynak katman alfası ya da katmanın kendi koyu çizgileri) renk kalemiyle: kâğıt tanesi tepeleri dolar, basınç yol boyunca değişir
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float m = p_cizgiYoluOn > 0.5 ? texture(s_cizgiYolu, b).a : (s.a > 0.5 && luma(unpre(s)) < 0.45 ? 1.0 : 0.0); if (m <= 0.0) { o = s; return; }
  float press = 0.45 + 0.55 * sin(clamp((u_box.z >= u_box.w ? b.x : b.y), 0.0, 1.0) * 3.14159); float tooth = fbm(here() / max(p_tane * u_s * 0.6, 1.0), 3.0) * 0.5 + 0.5;
  float cov = smoothstep(1.0 - press * p_yogunluk / 100.0 - 0.1, 1.0 - press * p_yogunluk / 100.0 + 0.1, tooth) * m;
  vec4 bg = p_cizgiYoluOn > 0.5 ? s : vec4(vec3(0.97, 0.96, 0.92) * s.a, s.a); // kendi çizgisinde: çizgi kâğıt rengine açılır, kalem tanesi üstüne
  o = overPre(vec4(c_renk, 1.0) * cov, bg); }

//== glassetch
uniform sampler2D s_oymaMask, s_arkaPlan; uniform float p_oymaMaskOn, p_arkaPlanOn, p_matlik, p_kirilma, p_kenarParl;
// Oyma bölgeleri (maske ya da desen) buzlu: arka plan bulanık ve beyazımsı; kenarda parlama; şeffaf bölgede hafif kırılma
vec4 bgAt(vec2 b) { return p_arkaPlanOn > 0.5 ? texture(s_arkaPlan, b) : texPx(boxPx(b)); }
float etch(vec2 b) { if (p_oymaMaskOn > 0.5) return texture(s_oymaMask, b).a; vec2 q = (b - 0.5) * 6.0; return step(0.5, fract(length(q) * 0.5 + atan(q.y, q.x) / 6.28318 * 2.0)); }
void main() { vec2 b = boxUV(here()); float m = etch(b); vec2 off = vec2(fbm(b * 9.0, 2.0), fbm(b * 9.0 + 4.0, 2.0)) * p_kirilma / max(u_box.z, 1.0) * u_s;
  vec4 clear = bgAt(b + off * 0.4); vec4 fr = vec4(0.0); float R = p_matlik / 100.0 * 10.0 / max(u_box.z, 1.0) * u_s; for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) fr += bgAt(b + off + vec2(i, j) * R); fr /= 25.0;
  fr.rgb = mix(fr.rgb, vec3(fr.a), 0.35 * p_matlik / 100.0); float e = abs(etch(b + vec2(1.5 / u_box.z, 0.0)) - etch(b - vec2(1.5 / u_box.z, 0.0))) + abs(etch(b + vec2(0.0, 1.5 / u_box.w)) - etch(b - vec2(0.0, 1.5 / u_box.w)));
  vec4 r = mix(clear, fr, m); r.rgb += vec3(1.0) * clamp(e, 0.0, 1.0) * p_kenarParl / 100.0 * r.a; o = r; }

//== hammeredmetal
uniform float p_cukurCapi, p_derinlik, p_darbeOrtu, p_puruz;
// Çekiç izleri: Voronoi hücresi başına çukur (merkeze eğimli normal); kapsama oranı kadar hücre; pürüz ince gürültü; metal ışığı
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 q = toUnit(here()) / max(p_cukurCapi, 1.0); vec2 id = floor(q); vec2 best = vec2(0.0); float bd = 9.0; vec2 bc = vec2(0.0);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(i, j); vec2 pt = c + hash2(c); float d = length(q - pt); if (d < bd) { bd = d; best = pt; bc = c; } }
  float on = step(hash1(bc + 7.0), p_darbeOrtu / 100.0); vec2 dv = (q - best); float r = length(dv); vec3 n = normalize(vec3(-dv * on * p_derinlik * 0.6 * smoothstep(0.7, 0.0, r), 1.0));
  n = normalize(n + vec3(vec2(hash1(floor(here())) - 0.5, hash1(floor(here()) + 3.0) - 0.5) * p_puruz / 100.0 * 0.3, 0.0)); vec3 L = normalize(vec3(-0.5, -0.6, 1.0));
  float dif = clamp(dot(n, L), 0.0, 1.0); float spec = pow(clamp(dot(reflect(-L, n), vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 30.0); vec3 c = unpre(s) * (0.35 + 0.75 * dif) + spec * 0.6; o = pre(clamp(c, 0.0, 1.0), s.a); }

//== crackvarnish
uniform sampler2D s_altYuze; uniform float p_altYuzeOn, p_catlakOlce, p_genislik, p_vernikOpak;
// Vernik katmanı (sarımsı) altındaki görüntü; Voronoi kenarları çatlak olur ve alt yüzeyi gösterir
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 q = toUnit(here()) / max(p_catlakOlce, 1.0); q += vec2(fbm(q * 2.0, 2.0), fbm(q * 2.0 + 5.0, 2.0)) * 0.25;
  vec4 v = voronoi(q); float edge = v.y - v.x; float w = p_genislik / max(p_catlakOlce, 1.0); float crack = 1.0 - smoothstep(w * 0.5, w * 0.5 + 0.03, edge);
  vec3 under = p_altYuzeOn > 0.5 ? unpre(texture(s_altYuze, boxUV(here()))) : unpre(s) * 0.35; vec3 varn = mix(unpre(s), unpre(s) * vec3(1.05, 0.95, 0.72), p_vernikOpak / 100.0);
  o = pre(mix(varn, under, crack), s.a); }

//== heathertwine
uniform sampler2D s_yol; uniform vec3 c_ikinciRenk; uniform float p_yolOn, p_lif, p_toplamKali, p_renkKari;
// Şerit/kontur içinde kenara paralel lifler; lif başına renk (ana renk ya da ikinci renk), akış boyunca hafif titreşim
float A(vec2 px) { return p_yolOn > 0.5 ? texture(s_yol, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); if (A(p) < 0.5) { o = s; return; } float T = p_toplamKali * u_s; float d = 0.0;
  for (int i = 0; i < 12; i++) { float a = float(i) / 12.0 * TAU; float r = T; for (int k = 1; k <= 16; k++) { float rr = float(k) / 16.0 * T; if (A(p + vec2(cos(a), sin(a)) * rr) < 0.5) { r = rr; break; } } d = i == 0 ? r : min(d, r); }
  vec2 q = toUnit(p); float along = atan(q.y, q.x) * length(q); float wob = sin(along * 0.2) * 0.3; float N = clamp(floor(p_lif), 2.0, 32.0); float idx = floor(d / max(T, 1.0) * N + wob);
  float h = hash1(vec2(idx, 2.3)); vec3 base = p_yolOn > 0.5 ? vec3(0.85, 0.3, 0.25) : unpre(s); vec3 c = h < p_renkKari / 100.0 ? c_ikinciRenk : base;
  float sep = abs(fract(d / max(T, 1.0) * N + wob) - 0.5) * 2.0; c *= 0.82 + 0.18 * (1.0 - sep * sep); o = d >= T * 0.999 ? s : pre(c, 1.0); }

//== seamallowance
uniform vec3 c_iplik; uniform float p_pay, p_dikisAral, p_sokulme, p_ipUzun;
// İçe ofsetli kesik dikiş çizgisi; sökülme oranı kadar bölgede dikiş yok ve kopuk iplik uçları sarkar
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = s; return; } vec2 p = here(); float P = max(p_pay * u_s, 1.0); float d = innerDist(p, P * 2.0);
  vec2 q = toUnit(p); float ang = atan(q.y, q.x); float along = ang * length(q); float sp = max(p_dikisAral, 1.0); float seg = fract(along / sp);
  float broken = step(fract(ang / 6.28318 + 0.5), p_sokulme / 100.0); float line = 1.0 - smoothstep(0.6 * u_s, 1.4 * u_s, abs(d - P));
  float stitch = line * step(seg, 0.6) * (1.0 - broken); float dang = broken * step(fract(along / (sp * 3.0)), 0.12) * step(P, d) * step(d, P + p_ipUzun * u_s) * (1.0 - smoothstep(0.5 * u_s, 1.2 * u_s, abs(fract(along / (sp * 3.0)) * sp * 3.0 - sp * 0.15)));
  o = overPre(vec4(c_iplik, 1.0) * max(stitch, dang * 0.9), s); }

//== flipstrips
uniform sampler2D s_on, s_arka; uniform float p_onOn, p_arkaOn, p_bakisAcis, p_serit, p_gecisYumu;
// Lentiküler şeritler: bakış açısı her şeritte ön/arka görüntünün payını belirler
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec4 A = p_onOn > 0.5 ? texture(s_on, b) : s; vec4 B = p_arkaOn > 0.5 ? texture(s_arka, b) : vec4(hueRotate(unpre(s), 160.0) * s.a, s.a);
  float st = fract(here().x / max(p_serit * u_s, 1.0)); float k = clamp(0.5 + p_bakisAcis / 90.0, 0.0, 1.0); float sw = max(p_gecisYumu / 100.0 * 0.25, 0.01);
  float m = smoothstep(k - sw, k + sw, st); float ridge = 0.92 + 0.08 * cos(st * 6.28318); o = mix(A, B, m) * vec4(vec3(ridge), 1.0); }

//== pixelclean
uniform float p_hucreBoyu, p_kural, p_gecis, p_paletiKoru;
// Piksel sanatı hücreleri: tek hücrelik çıkıntı (komşuların çoğu aynı ve farklı) → komşu rengi; çentik (boş hücre, dolu komşular) → doldur
void main() { vec4 s = texture(u_tex, v_uv); float C = max(p_hucreBoyu * u_s, 1.0); vec2 c0 = (floor(here() / C) + 0.5) * C; vec4 me = texPx(c0);
  vec4 n[4]; n[0] = texPx(c0 + vec2(C, 0.0)); n[1] = texPx(c0 - vec2(C, 0.0)); n[2] = texPx(c0 + vec2(0.0, C)); n[3] = texPx(c0 - vec2(0.0, C));
  float need = 4.0 - min(p_gecis - 1.0, 1.0); vec4 best = me; float bc = 0.0;
  for (int i = 0; i < 4; i++) { float cnt = 0.0; for (int j = 0; j < 4; j++) cnt += step(length(n[i] - n[j]), 0.08); if (cnt > bc) { bc = cnt; best = n[i]; } }
  bool differs = length(best - me) > 0.08; vec4 r = me;
  if (p_kural < 0.5 && differs && bc >= need - 1.0 && me.a > 0.5) r = best; else if (p_kural >= 0.5 && me.a < 0.5 && best.a > 0.5 && bc >= need - 1.0) r = best;
  o = r; }

//== subpixeldither
uniform sampler2D s_palet; uniform float p_paletOn, p_kume, p_esik, p_karisim;
// Kaynak palet (palet katmanından 8 renk ya da 4 seviyeli kanal nicemleme); iki en yakın renk arasında seçilen küme deseniyle titreme
vec3 palC(int i) { return texture(s_palet, vec2((float(i) + 0.5) / 8.0, 0.5)).rgb; }
float pat(vec2 c) { if (p_kume < 0.5) return fract((c.x + c.y) / 4.0) ; if (p_kume < 1.5) return mod(c.x + c.y, 2.0) * 0.5 + 0.25; int x = int(mod(c.x, 4.0)), y = int(mod(c.y, 4.0)); float m[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0); return (m[y * 4 + x] + 0.5) / 16.0; }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); vec3 a, b2; float k;
  if (p_paletOn > 0.5) { float d1 = 9.0, d2 = 9.0; a = c; b2 = c; for (int i = 0; i < 8; i++) { vec3 pc = palC(i); float d = length(pc - c); if (d < d1) { d2 = d1; b2 = a; d1 = d; a = pc; } else if (d < d2) { d2 = d; b2 = pc; } } k = d1 / max(d1 + d2, 1e-4); }
  else { vec3 lo = floor(c * 3.0) / 3.0, hi = min(lo + 1.0 / 3.0, 1.0); a = lo; b2 = hi; k = luma((c - lo) * 3.0); }
  vec2 cell = floor(here() / max(u_s, 1.0)); vec3 d = k > pat(cell) + (p_esik - 50.0) / 100.0 ? b2 : a; if (p_paletOn > 0.5 && k > pat(cell) + (p_esik - 50.0) / 100.0) d = b2; else if (p_paletOn > 0.5) d = a;
  o = pre(mix(c, d, p_karisim / 100.0), s.a); }

//== twotonelines
uniform vec3 c_aydinlik, c_golge; uniform float p_isikAcis, p_cizgiKali, p_gecis;
// Koyu çizginin ışığa bakan kenarı açık, karşı kenarı koyu renkle boyanır
float ink(vec2 p) { vec4 c = texPx(p); return c.a > 0.5 && luma(unpre(c)) < 0.35 ? 1.0 : 0.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); if (ink(p) < 0.5) { o = s; return; } float W = max(p_cizgiKali * u_s, 1.0); float la = radians(p_isikAcis); vec2 L = vec2(cos(la), -sin(la));
  float toLight = 1e5, toShade = 1e5; for (int k = 1; k <= 10; k++) { float r = float(k) / 10.0 * W * 2.0; if (toLight > 9e4 && ink(p + L * r) < 0.5) toLight = r; if (toShade > 9e4 && ink(p - L * r) < 0.5) toShade = r; }
  float sw = max(p_gecis / 100.0, 0.02); float lightSide = smoothstep(0.5 + sw, 0.5 - sw, toLight / max(toLight + toShade, 1e-3)); vec3 c = mix(c_golge, c_aydinlik, lightSide);
  float rim = step(min(toLight, toShade), W); o = pre(mix(unpre(s), c, rim), s.a); }

//== wetblend
uniform sampler2D s_digerBoya; uniform float p_digerBoyaOn, p_karisimDeri, p_islaklik, p_akis, p_kurutma;
// İki boyanın temas sınırında pigment karışımı: sınıra yakın pikseller komşu boyanın rengini akış yönünde sürüklenmiş izlerle alır; zamanla kurur
vec4 other(vec2 px) { return p_digerBoyaOn > 0.5 ? texture(s_digerBoya, boxUV(px)) : texPx(px + vec2(9.0 * u_s, 0.0)) * step(0.0, 0.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float D = max(p_karisimDeri * u_s, 1.0); float wet = p_islaklik / 100.0 * (1.0 - exp(-u_t / max(p_kurutma, 0.05)) * 0.0) * exp(-u_t / max(p_kurutma * 4.0, 0.1) * 0.15);
  vec2 flow = vec2(fbm(p / (D * 2.0) + u_t * 0.1, 3.0), fbm(p / (D * 2.0) + 5.0, 3.0)) * p_akis * u_s; vec3 mine = unpre(s); vec3 acc = vec3(0.0); float w = 0.0;
  for (int i = 0; i < 8; i++) { float a = float(i) / 8.0 * TAU; vec2 q = p + flow + vec2(cos(a), sin(a)) * D; vec4 c = p_digerBoyaOn > 0.5 ? other(q) : texPx(q); if (c.a < 0.3) continue; vec3 cc = unpre(c); float diff = length(cc - mine); if (diff < 0.12) continue; acc += cc; w += 1.0; }
  if (w <= 0.0 || s.a <= 0.0) { o = s; return; } vec3 mixc = sqrt(mine * (acc / w)); float k = wet * clamp(w / 4.0, 0.0, 1.0) * 0.8; o = pre(mix(mine, mixc, k), s.a); }
