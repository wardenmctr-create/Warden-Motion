// 1000 rehberi bölüm 7 (935–956): 3B — gerçek model dosyası yerine katmanın kalınlık verilmiş kartı (alfa siluetinden levha) üzerinde
//== latticevolume
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_hucre, p_cubukKali, p_kafes, p_yuzeyeKirp;
// İç hacim kafes çubuklarıyla dolu: küp (eksen çubukları) ya da çapraz; isteğe bağlı silüete kırpılır
float bars(vec3 p) { float h = max(p_hucre, 2.0); float r = max(p_cubukKali, 0.3) * 0.5; vec3 q = p; if (p_kafes > 0.5) { q = vec3(p.x + p.y, p.y - p.x, p.z * 1.41421) * 0.70710678; }
  vec3 m = mod(q + h * 0.5, h) - h * 0.5; return min(min(length(m.xy), length(m.yz)), length(m.xz)) - r; }
float sdf(vec3 p) { float vol = p_yuzeyeKirp > 0.5 ? cardD(p, 40.0) : max(max(abs(p.x) - boxU().x * 0.5, abs(p.y) - boxU().y * 0.5), abs(p.z) - 20.0); return max(vol, bars(p)); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); return vec4(mix(c.rgb, vec3(0.85, 0.88, 0.95), 0.35), 1.0); }
void main() { o = render3d(vec3(0.0)); }

//== bevel3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_pah, p_segment, p_aciEsig;
// Kartın kenarları pah: 1 segment = düz eğimli, çok segment = yuvarlatılmış
float sdf(vec3 p) { float th = 20.0; float r = min(max(p_pah, 0.0), th * 0.49); float d2 = (0.5 - cardA(p.xy)) * 6.0; vec2 w = vec2(d2 + r, abs(p.z) - th * 0.5 + r);
  if (p_segment < 1.5) { float d = max(max(w.x - r, w.y - r), (w.x + w.y) * 0.70710678 - r * 0.29); return d; } return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - r; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }

//== twistbridge
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_kenarSeci, p_araSegm, p_bukulme;
// Ön ve arka kenar döngüsü yeni yüzlerle bağlanır: derin gövde boyunca burgu; ara segment çizgileri
float sdf(vec3 p) { float D = 60.0; float u = clamp(p.z / D + 0.5, 0.0, 1.0); float a = radians(p_bukulme) * (u - 0.5); vec2 xy = mat2(cos(a), -sin(a), sin(a), cos(a)) * p.xy;
  float d2 = (0.5 - cardA(xy)) * 6.0; vec2 w = vec2(d2, abs(p.z) - D * 0.5); return (min(max(w.x, w.y), 0.0) + length(max(w, 0.0))) * 0.7; }
vec4 surf(vec3 p, vec3 n) { float D = 60.0; float u = p.z / D + 0.5; float seg = abs(fract(u * max(p_araSegm, 1.0)) - 0.5); vec4 c = cardSurf(p, n); float ring = abs(n.z) < 0.6 ? 1.0 - smoothstep(0.02, 0.06, seg) : 0.0; return vec4(mix(c.rgb, vec3(1.0), ring * 0.6), 1.0); }
void main() { o = render3d(vec3(0.0)); }

//== geodesicline3d
INCLUDE(_3d)
INCLUDE(_card)
uniform vec3 p_baslangi, p_bitis; uniform float p_kalinlik, p_ilerleme;
// Kart yüzeyindeki en kısa yol: ön yüzde düz çizgi (uçlar yüzeye iz düşürülür), ilerlemeye kadar
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); vec2 A = p_baslangi.xy, B = p_bitis.xy; if (length(A - B) < 1.0) { A = vec2(-boxU().x * 0.35, boxU().y * 0.25); B = vec2(boxU().x * 0.35, -boxU().y * 0.25); }
  B = mix(A, B, p_ilerleme / 100.0); vec2 ab = B - A; float t = clamp(dot(p.xy - A, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(p.xy - A - ab * t);
  float line = (1.0 - smoothstep(p_kalinlik * 0.5, p_kalinlik * 0.5 + 1.0, d)) * step(0.6, n.z); return vec4(mix(c.rgb, vec3(1.0, 0.8, 0.2), line), 1.0); }
void main() { o = render3d(vec3(0.0)); }

//== normalsmooth
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_agirlik, p_sertKena, p_guc, p_disaYone;
// Normal düzeltme: kartın kenarı güce göre yuvarlanır (yumuşak gölgeleme); sert kenar açısı küçükse daha az yuvarlama
float sdf(vec3 p) { float th = 20.0; float r = th * 0.45 * p_guc / 100.0 * (1.0 - p_sertKena / 360.0); float d2 = (0.5 - cardA(p.xy)) * 6.0; vec2 w = vec2(d2 + r, abs(p.z) - th * 0.5 + r); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - r; }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); return vec4(c.rgb * (p_disaYone > 0.5 ? 1.0 : 0.92), 1.0); }
void main() { o = render3d(vec3(0.0)); }

//== seamline3d
INCLUDE(_3d)
INCLUDE(_card)
uniform vec3 c_renk; uniform float p_kaynak, p_kalinlik, p_yuzeyOfse;
// Dikiş: ön/arka yüz ile yan duvarın birleştiği kenar döngüsü (UV dikişi) ya da ortadan geçen kenar (seçili)
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); float side = 1.0 - smoothstep(0.4, 0.8, abs(n.z)); float d = p_kaynak < 0.5 ? abs(abs(p.z) - 10.0 + p_yuzeyOfse) * (side > 0.5 ? 1.0 : 99.0) : abs(p.z) * side + (1.0 - side) * abs(p.y);
  float line = 1.0 - smoothstep(p_kalinlik * 0.5, p_kalinlik * 0.5 + 0.8, d); return vec4(mix(c.rgb, c_renk, line), 1.0); }
void main() { o = render3d(vec3(0.0)); }

//== unfold3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_kokYuz, p_acilim, p_cakismalIsar;
// Açılım: kart üç panele bölünür; açılım 0'da zikzak katlı, 100'de düz; paneller menteşe çevresinde zincir halinde döner
float panel(vec3 p, float k, float W) { return cardD(p, 8.0); }
float sdf(vec3 p) { float W = boxU().x / 3.0; float ang = radians(90.0 * (1.0 - p_acilim / 100.0)); float d = 1e5; vec3 q = p; float x0 = -boxU().x * 0.5;
  // panel i'nin yerel koordinatı: sol menteşeden zincirle döndürülmüş
  vec2 hinge = vec2(x0, 0.0); float rot = 0.0;
  for (int i = 0; i < 3; i++) { float a = (i == 0) ? 0.0 : (mod(float(i), 2.0) > 0.5 ? ang : -ang); rot += a; vec2 dir = vec2(cos(rot), sin(rot));
    vec3 lp = vec3(dot(vec2(p.x, p.z) - hinge, dir), p.y, dot(vec2(p.x, p.z) - hinge, vec2(-dir.y, dir.x))); vec3 cp = vec3(x0 + W * float(i) + clamp(lp.x, 0.0, W), lp.y, lp.z);
    float inside = step(0.0, lp.x) * step(lp.x, W); float dd = inside > 0.5 ? cardD(cp, 8.0) : length(vec2(min(lp.x, lp.x - W) * step(lp.x, 0.0) + max(lp.x - W, 0.0), 0.0)) + cardD(cp, 8.0); d = min(d, dd);
    hinge += dir * W; }
  return d * 0.8; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }

//== shellpeel
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_yuzMask; uniform float p_yuzMaskOn, p_uzaklasm, p_kabukKali, p_ilerleme;
// Ön yüzden ince ikinci kabuk; normal yönünde (+z) ilerlemeyle uzaklaşır; maske varsa yalnız o bölge
float mask(vec2 xy) { if (p_yuzMaskOn < 0.5) return 1.0; vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; return texture(s_yuzMask, b).a; }
float sdf(vec3 p) { float body = cardD(p, 20.0); float off = 10.0 + p_uzaklasm * p_ilerleme / 100.0; float th = max(p_kabukKali, 0.3); float m = mask(p.xy);
  float d2 = (0.5 - min(cardA(p.xy), m)) * 6.0; vec2 w = vec2(d2, abs(p.z - off - th * 0.5) - th * 0.5); float shell = min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); return min(body, shell); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); return p.z > 10.5 ? vec4(c.rgb * 1.05, 1.0) : vec4(c.rgb * 0.8, 1.0); }
void main() { o = render3d(vec3(0.0)); }

//== surfwave3d
INCLUDE(_3d)
INCLUDE(_card)
uniform vec3 p_kaynak; uniform float p_genlik, p_dalgaBoyu, p_hiz;
// Yüzey boyunca yayılan dalga: kaynaktan yüzey uzaklığına göre z yer değiştirmesi
float hgt(vec2 xy) { float r = length(xy - p_kaynak.xy); float L = max(p_dalgaBoyu, 1.0); return p_genlik * sin(6.2832 * (r - u_t * p_hiz) / L) * exp(-r / (L * 6.0)); }
float sdf(vec3 p) { return cardD(p - vec3(0.0, 0.0, hgt(p.xy)), 20.0) * 0.55; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }

//== morphparticles3d
uniform sampler2D s_kaynak, s_hedef; uniform float p_kaynakOn, p_hedefOn, p_parcacik, p_ilerleme, p_dagilim;
// Parçacıklar kaynak silüetten (katmanın kendisi ya da kaynak) hedef silüete yer değiştirir; ortada derinlikte saçılır (perspektifle boyutlanır)
vec2 pick(int k, bool tgt) { for (int i = 0; i < 6; i++) { vec2 u = hash2(vec2(float(k) * 1.37 + float(i) * 7.1, tgt ? 31.7 : 3.3)); float a = tgt ? (p_hedefOn > 0.5 ? texture(s_hedef, u).a : step(length(u - 0.5), 0.35)) : (p_kaynakOn > 0.5 ? texture(s_kaynak, u).a : texPx(boxPx(u)).a); if (a > 0.5) return u; } return vec2(0.5); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float pr = smoothstep(0.0, 1.0, p_ilerleme / 100.0); int N = int(clamp(p_parcacik / 4.0, 16.0, 256.0)); vec3 acc = vec3(0.0); float al = 0.0;
  for (int k = 0; k < 256; k++) { if (k >= N) break; vec2 a = pick(k, false), c = pick(k, true); float z = sin(pr * 3.14159) * (hash1(vec2(float(k), 9.0)) - 0.3) * p_dagilim / 100.0; vec2 pos = mix(a, c, pr) + (hash2(vec2(float(k), 4.0)) - 0.5) * sin(pr * 3.14159) * p_dagilim / 200.0;
    float R = (1.6 + z * 3.0) * u_s / min(u_box.z, u_box.w); float d = length((b - pos) * vec2(u_box.z / u_box.w, 1.0)); float v = 1.0 - smoothstep(R * 0.6, R, d); if (v <= 0.0) continue;
    vec4 col = p_kaynakOn > 0.5 ? texture(s_kaynak, a) : texPx(boxPx(a)); acc += mix(unpre(col), vec3(1.0), 0.15) * v; al = max(al, v); }
  vec4 fade = s * (1.0 - smoothstep(0.0, 0.15, pr)); o = overPre(vec4(acc, al), fade); }

//== atlasfaces
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_atlas; uniform float p_atlasOn, p_sutun, p_satir, p_secim, p_tohum;
// Kartın ön yüzü yüz hücrelerine bölünür; her hücre atlastaki bir kutuyu (kimlik / sıra / tohum ile) alır
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); if (abs(n.z) < 0.6) return c; float C = max(floor(p_sutun), 1.0), R = max(floor(p_satir), 1.0); vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; vec2 g = floor(b * vec2(C, R)); vec2 f = fract(b * vec2(C, R));
  float id = g.y * C + g.x; float pick = p_secim < 0.5 ? id : (p_secim < 1.5 ? mod(id * 7.0 + 3.0, C * R) : floor(hash1(g + p_tohum) * C * R)); vec2 tile = vec2(mod(pick, C), floor(pick / C));
  vec4 t = p_atlasOn > 0.5 ? texture(s_atlas, (tile + f) / vec2(C, R)) : vec4(hsv2rgb(vec3(pick / (C * R), 0.55, 0.95)), 1.0); return vec4(mix(c.rgb, t.rgb, t.a), 1.0); }
void main() { o = render3d(vec3(0.0)); }

//== cameracapture
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_kaynakKame; uniform float p_kaynakKameOn, p_derinlikTole, p_cikti;
// İkinci (kaynak) kamera, ışık konumundaki bakış: oradan görünen yüzey maskesi ya da kaynak kamera görüntüsünün aktarımı
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); vec3 Cd = normalize(vec3(p_isikKonu.x, -p_isikKonu.y, -p_isikKonu.z) + vec3(0.0, 0.0, 1e-3)); float facing = dot(n, Cd);
  float vis = facing > 0.0 ? softShadow(p + n * max(p_derinlikTole, 0.2), Cd, 16.0) : 0.0; if (p_cikti < 0.5) return vec4(mix(vec3(0.08), vec3(1.0), step(0.5, vis)), 1.0);
  vec2 uv = vec2(p.x, -p.y) / boxU() + 0.5; vec4 k = p_kaynakKameOn > 0.5 ? texture(s_kaynakKame, uv) : vec4(1.0, 0.8, 0.3, 1.0); return vec4(mix(c.rgb * 0.5, k.rgb, step(0.5, vis)), 1.0); }
void main() { o = render3d(vec3(0.0)); }

//== projectionpaint
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_projekto, s_goruntu; uniform float p_projektoOn, p_goruntuOn, p_kenarGeci, p_gizliYuzlUygu;
// Görüntü, projektör doğrultusundan (projektör katmanı yoksa ışık konumundan) yüzeye işlenir; gölgeleme yüzeyde kalır
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); vec3 D = normalize(vec3(p_isikKonu.x, -p_isikKonu.y, -p_isikKonu.z) + vec3(0.0, 0.0, 1e-3)); vec3 u = normalize(cross(D, vec3(0.0, 1.0, 0.001))); vec3 v = cross(u, D);
  vec2 uv = vec2(dot(p, u), -dot(p, v)) / max(boxU().x, boxU().y) + 0.5; vec4 img = p_goruntuOn > 0.5 ? texture(s_goruntu, uv) : vec4(step(0.5, fract(uv.x * 6.0)) * vec3(1.0, 0.4, 0.2) + (1.0 - step(0.5, fract(uv.x * 6.0))) * vec3(0.2, 0.5, 1.0), 1.0);
  float edge = smoothstep(0.0, max(p_kenarGeci / 100.0 * 0.5, 0.001), min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y))); float face = p_gizliYuzlUygu > 0.5 ? 1.0 : step(0.0, dot(n, D));
  return vec4(mix(c.rgb, img.rgb, img.a * edge * face), 1.0); }
void main() { o = render3d(vec3(0.0)); }

//== multiview
INCLUDE(_chart)
float cardA(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return texPx(boxPx(b)).a; }
float cardD(vec3 p, float th) { float d2 = (0.5 - cardA(p.xy)) * 6.0; vec2 w = vec2(d2, abs(p.z) - th * 0.5); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); }
uniform float p_duzen, p_bosluk, p_kameraEtik;
// Ön, yan, üst ve perspektif görünüm aynı karede: her bölmede kart küçük ışın izleyiciyle farklı açıdan
float cd(vec3 p) { return cardD(p, 20.0); }
vec4 view(vec2 uv, mat3 R) { vec2 B = boxU(); vec3 ro = R * vec3((uv - 0.5) * vec2(1.0, -1.0) * max(B.x, B.y) * 1.1, 400.0); vec3 rd = R * vec3(0.0, 0.0, -1.0); float t = 0.0;
  for (int i = 0; i < 64; i++) { vec3 p = ro + rd * t; float d = cd(p); if (d < 0.1) { vec2 e = vec2(0.5, 0.0); vec3 n = normalize(vec3(cd(p + e.xyy) - cd(p - e.xyy), cd(p + e.yxy) - cd(p - e.yxy), cd(p + e.yyx) - cd(p - e.yyx)));
      vec2 b = vec2(p.x, -p.y) / B + 0.5; vec4 c = texPx(boxPx(clamp(b, 0.0, 1.0))); vec3 col = c.a > 0.0 ? unpre(c) : vec3(0.8); float l = 0.45 + 0.55 * clamp(dot(n, normalize(vec3(0.4, 0.6, 0.8))), 0.0, 1.0); return vec4(col * l, 1.0); } t += d * 0.9; if (t > 900.0) break; }
  return vec4(0.08, 0.09, 0.12, 1.0); }
mat3 rotY(float a) { float c = cos(a), s2 = sin(a); return mat3(c, 0.0, -s2, 0.0, 1.0, 0.0, s2, 0.0, c); }
mat3 rotX(float a) { float c = cos(a), s2 = sin(a); return mat3(1.0, 0.0, 0.0, 0.0, c, s2, 0.0, -s2, c); }
void main() { vec2 b = boxUV(here()); float gap = p_bosluk * u_s / u_box.z; vec2 cell, f; float idx;
  if (p_duzen < 0.5) { cell = floor(b * 2.0); f = fract(b * 2.0); idx = cell.y * 2.0 + cell.x; } else { cell = vec2(floor(b.x * 4.0), 0.0); f = vec2(fract(b.x * 4.0), (b.y - 0.375) * 4.0); idx = cell.x; if (f.y < 0.0 || f.y > 1.0) { o = vec4(0.0); return; } }
  if (any(lessThan(f, vec2(gap))) || any(greaterThan(f, vec2(1.0 - gap)))) { o = vec4(0.0); return; } f = (f - gap) / (1.0 - 2.0 * gap);
  mat3 R = idx < 0.5 ? mat3(1.0) : (idx < 1.5 ? rotY(1.5708) : (idx < 2.5 ? rotX(-1.5708) : rotY(0.6) * rotX(-0.45))); vec4 c = view(f, R);
  if (p_kameraEtik > 0.5) { vec2 lp = (f - vec2(0.08, 0.1)) / vec2(0.05, 0.06); c = mix(c, vec4(1.0, 0.85, 0.3, 1.0), numAt(lp, idx + 1.0)); } o = c; }

//== depthpointsize
uniform sampler2D s_noktaBulu; uniform float p_noktaBuluOn, p_yakinBoyu, p_uzakBoyu, p_yogunlukKoru;
// Nokta bulutu: kaynak (ya da katman) ızgara örnekleri; derinlik = parlaklık; yakın noktalar büyük, uzak küçük; yavaş paralaks
vec4 S(vec2 u) { return p_noktaBuluOn > 0.5 ? texture(s_noktaBulu, u) : texPx(boxPx(u)); }
void main() { vec2 q = here(); float sp = max(min(u_box.z, u_box.w) / 60.0, 3.0); vec2 id0 = floor((q - u_box.xy) / sp); float v = 0.0; vec3 col = vec3(0.0);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = id0 + vec2(i, j); vec2 u = (id + 0.5) * sp / u_box.zw; if (any(lessThan(u, vec2(0.0))) || any(greaterThan(u, vec2(1.0)))) continue; vec4 c = S(u); if (c.a < 0.3) continue;
    float z = luma(unpre(c)); vec2 pos = u_box.xy + (id + 0.5) * sp + vec2(sin(u_t * 0.6), 0.0) * (z - 0.5) * sp * 1.5; float sz = mix(p_uzakBoyu, p_yakinBoyu, z) * u_s * 0.5; sz = mix(sz, sz * sp / max(sz * 2.0, 1.0), p_yogunlukKoru / 100.0 * 0.5);
    float a = 1.0 - smoothstep(sz - 0.7, sz + 0.7, length(q - pos)); if (a > v) { v = a; col = unpre(c) * (0.6 + 0.4 * z); } }
  o = vec4(col * v, v); }

//== areasample
uniform sampler2D s_agirlikHari; uniform float p_agirlikHariOn, p_nokta, p_enAzMesa, p_tohum;
// Yüzey (alfa) üzerinde alana göre eşit dağılım; ağırlık haritası parlak yerlerde yoğunluğu artırır; en az mesafe hücre boyunu büyütür
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cell = max(sqrt(boxU().x * boxU().y / max(p_nokta, 1.0)), p_enAzMesa); vec2 id0 = floor(q / cell); float v = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = id0 + vec2(i, j); vec2 c = (id + 0.15 + hash2(id + p_tohum) * 0.7) * cell; vec4 base = texU(c); if (base.a < 0.5) continue;
    float w = p_agirlikHariOn > 0.5 ? luma(texture(s_agirlikHari, boxUV(fromUnit(c))).rgb) : 1.0; if (hash1(id * 1.7 + p_tohum) > w) continue; v = max(v, 1.0 - smoothstep(1.2, 1.2 + 1.0 / u_s, length(q - c))); }
  o = overPre(vec4(1.0, 0.9, 0.4, 1.0) * v, vec4(s.rgb * 0.6, s.a)); }

//== normallines3d
uniform vec3 c_renk; uniform float p_okBoyu, p_atlama, p_tur;
// Normaller ok olarak: silüet kenarında dışa (yan yüz normali), ön yüzde izleyiciye bakan normaller nokta-halka işaretiyle
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float sp = max(p_atlama * (p_tur < 0.5 ? 6.0 : 3.0), 2.0) * u_s; vec2 id0 = floor(p / sp); float v = 0.0; float L = p_okBoyu * u_s;
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 c = (id0 + vec2(i, j) + 0.5) * sp; float a = texPx(c).a; vec2 g = alphaGrad(c, 1.5);
    if (a > 0.5 && length(g) > 0.15) { vec2 n = -normalize(g); v = max(v, 1.0 - smoothstep(0.6, 1.4, seg(p, c, c + n * L))); vec2 tip = c + n * L; v = max(v, 1.0 - smoothstep(1.5, 2.5, length(p - tip))); }
    else if (a > 0.5 && i == 0 && j == 0) { float d = length(p - c); v = max(v, (1.0 - smoothstep(0.8, 1.6, abs(d - L * 0.15))) + (1.0 - smoothstep(0.8, 1.6, d))); } }
  o = overPre(vec4(c_renk, 1.0) * clamp(v, 0.0, 1.0), s); }

//== sectioncap
INCLUDE(_3d)
INCLUDE(_card)
uniform vec3 p_duzlem; uniform vec3 c_kesitReng; uniform float p_kapakGolg;
// Kesme düzlemi (normal = düzlem değerleri; boşsa yatay eksen) kartı keser; açılan kesit yüzeyi kesit rengiyle kapatılır, isteğe bağlı tarama
vec3 N() { return length(p_duzlem) > 0.5 ? normalize(vec3(p_duzlem.x, -p_duzlem.y, p_duzlem.z)) : normalize(vec3(1.0, 0.0, 0.35)); }
float sdf(vec3 p) { return max(cardD(p, 20.0), dot(p, N()) - sin(u_t * 0.5) * boxU().x * 0.1); }
vec4 surf(vec3 p, vec3 n) { float onCap = step(0.98, dot(n, N())); vec4 c = cardSurf(p, n); if (onCap < 0.5) return c; float hatch = p_kapakGolg > 0.5 ? 0.75 + 0.25 * step(0.5, fract((p.x + p.y + p.z) / 6.0)) : 1.0; return vec4(c_kesitReng * hatch, 1.0); }
void main() { o = render3d(vec3(0.0)); }
