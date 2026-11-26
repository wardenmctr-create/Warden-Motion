// 1000 rehberi bölüm 2 (825–846): optik, çevre ve stilize VFX
//== lightcurtain
uniform vec2 p_merkez; uniform vec3 c_renk; uniform float p_genislik, p_dalga, p_akis;
// Dalgalanan enerji perdesi: dikey bant, katlı kıvrımlar (kıvrım eğimi parlak), arka planı hafif kırar
void main() { vec2 q = toUnit(here()); float y = q.y; float t = u_t * p_akis;
  float off = sin(y * 0.012 + t * 2.1) * p_dalga + sin(y * 0.031 - t * 3.3) * p_dalga * 0.35; float x = q.x - p_merkez.x - off; float hw = max(p_genislik * 0.5, 1.0);
  float band = smoothstep(hw, hw * 0.6, abs(x)); float folds = 0.5 + 0.5 * sin(x / hw * 9.0 + sin(y * 0.02 + t) * 2.0 + t * 1.7); float slope = abs(cos(y * 0.012 + t * 2.1)) * 0.5 + 0.5;
  float vfade = smoothstep(-boxU().y * 0.5, -boxU().y * 0.2, y) * (0.6 + 0.4 * smoothstep(boxU().y * 0.5, boxU().y * 0.1, y));
  float a = band * (0.18 + 0.55 * pow(folds, 3.0) * slope) * vfade; vec4 s = texU(q + vec2(sin(y * 0.05 + t * 3.0), 0.0) * band * 3.0);
  o = vec4(s.rgb + c_renk * a, max(s.a, a)); }

//== diffraction
uniform vec3 c_isik; uniform float p_aciklik, p_aralik, p_desenOlce;
// Fraunhofer kırınımı: tek yarık sinc², çift yarık cos²·sinc², ızgara keskin tepeler; R/G/B ayrı dalga boyu → spektral bantlar
float pat(float x, float lam) { float a = p_aralik * 0.35; float k = 3.14159 * x / lam / max(p_desenOlce, 0.1) * 0.02; float b = k * a; float sinc = abs(b) < 1e-4 ? 1.0 : sin(b) / b; float I = sinc * sinc;
  if (p_aciklik > 0.5 && p_aciklik < 1.5) I *= pow(cos(k * p_aralik), 2.0); else if (p_aciklik >= 1.5) { float N = 6.0; float g = k * p_aralik; float d = sin(g); float r = abs(d) < 1e-3 ? N : sin(N * g) / d; I *= r * r / (N * N); } return I; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec3 I = vec3(pat(q.x, 0.65), pat(q.x, 0.53), pat(q.x, 0.45)); float vy = exp(-q.y * q.y / pow(boxU().y * 0.12, 2.0));
  vec3 c = I * c_isik * vy * 1.4; o = vec4(s.rgb + c * (1.0 - s.a * 0.3), max(s.a, max(c.r, max(c.g, c.b)))); }

//== focusstack
uniform sampler2D s_odakKatm; uniform float p_odakKatmOn, p_odakPencBoyu, p_kenarGeci, p_otomatikHiza;
// Her pikselde iki görüntünün yerel Laplace enerjisi karşılaştırılır; keskin olan seçilir, kenar geçişiyle yumuşatılır
float sharp(bool other, vec2 px) { float R = max(p_odakPencBoyu * u_s * 0.5, 1.0); float e = 0.0; for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 q = px + vec2(i, j) / 2.0 * R;
    float c = other ? luma(unpre(texture(s_odakKatm, boxUV(q)))) : luma(unpre(texPx(q))); float n = other ? luma(unpre(texture(s_odakKatm, boxUV(q + vec2(1.0, 0.0))))) + luma(unpre(texture(s_odakKatm, boxUV(q - vec2(1.0, 0.0))))) + luma(unpre(texture(s_odakKatm, boxUV(q + vec2(0.0, 1.0))))) + luma(unpre(texture(s_odakKatm, boxUV(q - vec2(0.0, 1.0)))))
      : lumAt(q + vec2(1.0, 0.0)) + lumAt(q - vec2(1.0, 0.0)) + lumAt(q + vec2(0.0, 1.0)) + lumAt(q - vec2(0.0, 1.0)); e += abs(4.0 * c - n); } return e; }
void main() { vec4 s = texture(u_tex, v_uv); if (p_odakKatmOn < 0.5) { o = s; return; } vec4 b = texture(s_odakKatm, boxUV(here())); float a = sharp(false, here()), c = sharp(true, here());
  float w = smoothstep(-0.02 - p_kenarGeci * 0.004, 0.02 + p_kenarGeci * 0.004, c - a); o = mix(s, b, w); }

//== birefringence
uniform float p_kristalAcis, p_ayrilma, p_ikinciGoru, p_kenarYumu;
// Çift kırılma: aynı görüntünün iki tam renkli kopyası, kristal ekseni doğrultusunda ayrık; ikinci görüntü opaklığı ayarlı
vec4 soft(vec2 px) { float r = p_kenarYumu * u_s; if (r < 0.5) return texPx(px); vec4 a = vec4(0.0); for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) a += texPx(px + vec2(i, j) * r * 0.5); return a / 9.0; }
void main() { float a = radians(p_kristalAcis); vec2 d = vec2(cos(a), sin(a)) * p_ayrilma * u_s * 0.5; vec4 o1 = soft(here() - d), o2 = soft(here() + d); float k = p_ikinciGoru / 100.0;
  o = o1 * (1.0 - k * 0.5) + o2 * k * 0.5 + o1 * 0.0; o = vec4(o1.rgb * (1.0 - k * 0.5) + o2.rgb * k * 0.5 * (1.0 + 0.0), max(o1.a, o2.a * k)); o.rgb = min(o.rgb, vec3(o.a)); }

//== specline
uniform sampler2D s_normalHari; uniform vec3 c_renk; uniform float p_normalHariOn, p_isikAcis, p_parlakBant, p_yogunluk;
// Speküler çizgi normal haritasıyla bükülür; çizgi zamanla yüzeyde kayar (normal haritası yoksa parlaklıktan tahmin)
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 b = boxUV(here()); vec3 n = p_normalHariOn > 0.5 ? texture(s_normalHari, b).rgb * 2.0 - 1.0 : normalize(vec3(-lumGrad(here(), 2.0) * 6.0, 1.0));
  float a = radians(p_isikAcis); vec2 d = vec2(cos(a), sin(a)); float pr = dot(b - 0.5, d) + dot(n.xy, d) * 0.25; float pos = fract(u_t * 0.35) * 1.6 - 0.8;
  float h = exp(-pow((pr - pos) / max(p_parlakBant * 0.25, 0.005), 2.0)) * (p_yogunluk / 100.0); o = vec4(s.rgb + c_renk * h * s.a, s.a); }

//== glintstretch
uniform sampler2D s_yonHari; uniform float p_yonHariOn, p_uzunluk, p_parlakliEsig, p_karisim;
// Parlak noktalar yön alanı boyunca uzar: yön haritası (RG) ya da yerel doku yönü
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); vec2 dir; if (p_yonHariOn > 0.5) { vec2 r = texture(s_yonHari, boxUV(p)).rg * 2.0 - 1.0; dir = length(r) > 0.05 ? normalize(r) : vec2(1.0, 0.0); }
  else { vec2 g = lumGrad(p, 2.0); dir = length(g) > 1e-4 ? normalize(vec2(-g.y, g.x)) : vec2(1.0, 0.0); }
  float L = p_uzunluk * u_s; float th = p_parlakliEsig / 100.0; vec3 acc = vec3(0.0);
  for (int k = 1; k <= 24; k++) { float r = float(k) / 24.0 * L; float w = 1.0 - float(k) / 25.0; for (int sgn = -1; sgn <= 1; sgn += 2) { vec4 c = texPx(p + dir * r * float(sgn)); float l = luma(unpre(c)) * c.a; acc += unpre(c) * c.a * max(l - th, 0.0) / max(1.0 - th, 0.01) * w; } }
  vec3 st = acc / 10.0; o = vec4(s.rgb + st * p_karisim / 100.0, max(s.a, clamp(luma(st) * p_karisim / 100.0, 0.0, 1.0))); }

//== fresnelrim
uniform sampler2D s_normalHari; uniform vec3 c_renk; uniform float p_normalHariOn, p_fresnelKuvv, p_guc;
// Normal haritası yoksa silüetten küre benzeri normal: kenara yakın nz küçük; Fresnel = (1−nz)^kuvvet
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float nz;
  if (p_normalHariOn > 0.5) nz = clamp(texture(s_normalHari, boxUV(here())).b * 2.0 - 1.0, 0.0, 1.0);
  else { float R = min(u_box.z, u_box.w) * 0.25; float d = innerDist(here(), R) / R; nz = sqrt(clamp(1.0 - pow(1.0 - d, 2.0), 0.0, 1.0)); }
  float f = pow(1.0 - nz, p_fresnelKuvv) * p_guc / 100.0; o = vec4(s.rgb + c_renk * f * s.a, s.a); }

//== subsurface
uniform sampler2D s_kalinlikHari; uniform vec3 c_icRenk; uniform float p_kalinlikHariOn, p_sacilma, p_isikAcis, p_guc;
// İçe saçılma: kenardan uzaklıkla üstel sönen renkli ışık; ışığa bakan kenarda güçlü
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 p = here(); float S = max(p_sacilma * u_s, 1.0); float d = innerDist(p, S * 3.0);
  float a = radians(p_isikAcis); vec2 L = vec2(cos(a), sin(a)); vec2 g = alphaGrad(p + L * d, 1.5); float face = length(g) > 1e-4 ? clamp(dot(-normalize(g), L) * 0.5 + 0.5, 0.0, 1.0) : 0.6;
  float thick = p_kalinlikHariOn > 0.5 ? 1.0 - luma(texture(s_kalinlikHari, boxUV(p)).rgb) : 0.5; float sc = exp(-d / S) * (0.4 + 0.6 * face) * (0.5 + thick) * p_guc / 100.0;
  o = pre(unpre(s) + c_icRenk * sc * 0.8, s.a); }

//== goboshadow
uniform sampler2D s_gobo; uniform vec2 p_isik; uniform float p_goboOn, p_kaynakGeni, p_mesafe, p_golge;
// Gobo, ışığın "mesafe" kadar altındaki yatay düzlemde; ışından piksele ışın bu düzlemi kestiği yerde maske okunur. Kaynak genişliği boyunca 7 örnek → yumuşak çoklu bant
float gob(vec2 u) { if (p_goboOn > 0.5) return texture(s_gobo, u).a; return step(0.5, fract(u.x * 7.0)) * step(0.0, u.x) * step(u.x, 1.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float lit = 0.0; vec2 bu = boxU();
  for (int i = -3; i <= 3; i++) { vec2 L = p_isik + vec2(float(i) / 3.0 * p_kaynakGeni * 0.5, 0.0); vec2 d = q - L; if (d.y <= p_mesafe) { lit += 1.0; continue; }
    float xg = d.x * p_mesafe / d.y; vec2 u = vec2(xg / max(bu.x * 0.5, 1.0) + 0.5, 0.5); lit += 1.0 - gob(u); }
  lit /= 7.0; float sh = (1.0 - lit) * p_golge / 100.0; o = vec4(s.rgb * (1.0 - sh), s.a); }

//== heathaze
uniform float p_yukselisHizi, p_kirilma, p_katmanDeri, p_yogunluk;
// Yükselen ısı: farklı hızda üç kırılma katmanı; alttan üste azalan yoğunluk
void main() { vec2 q = toUnit(here()); float D = max(p_katmanDeri, 1.0); vec2 off = vec2(0.0);
  for (int i = 0; i < 3; i++) { float k = 1.0 + float(i) * 0.7; vec2 uv = q / D * k + vec2(float(i) * 3.1, u_t * p_yukselisHizi / D * (0.6 + 0.4 * float(i))); off += vec2(fbm(uv, 3.0), fbm(uv + 7.3, 3.0)) / k; }
  float grad = mix(1.0, 0.25, clamp(0.5 - q.y / max(boxU().y, 1.0), 0.0, 1.0)); off *= p_kirilma * p_yogunluk / 100.0 * grad; o = texU(q + off); }

//== marinesnow
uniform vec3 c_renk; uniform float p_zerre, p_derinlik, p_akis, p_odak;
// Üç derinlik katmanında askıdaki zerreler; odaktan uzak katmanlar bulanık ve renge doğru solgun
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec3 acc = vec3(0.0); float al = 0.0; float dens = clamp(p_zerre / 150.0, 0.05, 20.0);
  for (int L = 0; L < 3; L++) { float z = (float(L) + 0.5) / 3.0; float sc = mix(1.6, 0.6, z); float cell = 36.0 / sqrt(dens) * sc; vec2 drift = vec2(sin(u_t * 0.3 + float(L)) * 6.0, u_t * p_akis * mix(1.0, 0.4, z) * 0.3);
    vec2 g = (q + drift) / cell; vec2 id = floor(g); for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(i, j); vec2 h = hash2(c + float(L) * 13.7); if (hash1(c + 3.3 + float(L)) > min(dens * 0.4, 1.0)) continue;
      vec2 pos = (c + h) * cell + vec2(sin(u_t * 0.7 + h.x * 6.28) * cell * 0.1, 0.0) - drift; float r = mix(2.2, 0.9, z) * (0.6 + h.y * 0.8); float blur = abs(z - p_odak / 100.0) * 6.0 + 0.6;
      float a = (1.0 - smoothstep(r - blur * 0.5, r + blur, length(q - pos))) * mix(0.85, 0.35, z); acc += mix(vec3(1.0), c_renk, z) * a; al += a; } }
  al = clamp(al, 0.0, 1.0); o = vec4(s.rgb * (1.0 - al) + clamp(acc, 0.0, 1.0) * al, max(s.a, al)); }

//== wavefront
uniform vec2 p_merkez; uniform vec3 c_renk; uniform float p_yaricap, p_cepheGeni, p_artciSure;
// Tek enerji cephesi: yarıçapta parlak halka, içeride sönen artçı iz; geçtiği yüzeyler aydınlanır
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float r = length(q - p_merkez); float R = p_yaricap; float w = max(p_cepheGeni, 0.5);
  float front = exp(-pow((r - R) / w, 2.0)); float trail = r < R ? exp(-(R - r) / max(w * 2.0 + p_artciSure * 120.0, 1.0)) * 0.45 : 0.0;
  float k = front + trail; vec3 lit = s.rgb + c_renk * k * (s.a * 0.9 + 0.35); o = vec4(lit, max(s.a, clamp(front * 0.85 + trail * 0.25, 0.0, 1.0))); }

//== fluidtrail
INCLUDE(_hist)
uniform sampler2D s_izKayn; uniform float p_izKaynOn, p_birikim, p_sonme, p_akis, p_yayilma;
// Geçmiş karelerde katmanın kapladığı yerler yoğunluk izi bırakır; iz yaşla söner, akışla yukarı taşınır ve yayılır
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 2.0) { o = s; return; } vec4 acc = vec4(0.0);
  for (int i = 1; i < 16; i++) { if (float(i) >= n) break; float age = float(i) / (n - 1.0); vec2 sh = vec2(0.0, p_akis * age * u_s) / u_res; float sp = p_yayilma * u_s * age / u_res.x;
    vec4 c = (hist(float(i), v_uv + sh) + hist(float(i), v_uv + sh + vec2(sp, 0.0)) + hist(float(i), v_uv + sh - vec2(sp, 0.0))) / 3.0; acc += c * exp(-age * 3.0 / max(p_sonme, 0.01)) ; }
  acc *= p_birikim / 100.0 * 0.6; acc = min(acc, vec4(1.0)); o = overPre(s, acc); }

//== massflow
uniform sampler2D s_alanMask; uniform vec2 p_giris, p_cikis; uniform float p_alanMaskOn, p_akis, p_viskozit;
// Giriş → çıkış arasında taşınan yoğunluk: akım çizgileri boyunca hareket eden şeritler; maske içinde kalır
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float m = p_alanMaskOn > 0.5 ? texture(s_alanMask, boxUV(here())).a : s.a; if (m <= 0.0) { o = s; return; }
  vec2 ab = p_cikis - p_giris; float L = max(length(ab), 1.0); vec2 t1 = ab / L, nr = vec2(-t1.y, t1.x); float u = dot(q - p_giris, t1) / L; float v = dot(q - p_giris, nr);
  float spread = L * (0.15 + 0.35 * sin(clamp(u, 0.0, 1.0) * 3.14159)); float bend = fbm(vec2(u * 3.0, v / spread * 2.0), 3.0) * (1.0 - p_viskozit / 100.0) * spread * 0.4;
  float dens = exp(-pow((v + bend) / spread, 2.0)) * smoothstep(-0.05, 0.05, u) * smoothstep(1.05, 0.95, u);
  float stripes = 0.5 + 0.5 * sin((u * L - u_t * p_akis) / 14.0 + fbm(vec2(v * 0.05, u * 4.0), 2.0) * 3.0);
  float a = dens * (0.35 + 0.65 * stripes) * m; o = vec4(mix(s.rgb, vec3(0.3, 0.75, 1.0) * max(s.a, a), a * 0.85), max(s.a, a)); }

//== settleparticles
uniform sampler2D s_yuzey; uniform float p_yuzeyOn, p_uretim, p_yapisma, p_birikimTava, p_temizlen;
// Düşen zerreler; yüzeyin üst kenarlarında zamanla kalınlaşan tortu tabakası (yapışma × süre, tavan ile sınırlı)
float surf(vec2 px) { return p_yuzeyOn > 0.5 ? texture(s_yuzey, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float rate = p_uretim / 50.0; float depth = min(u_t * rate * p_yapisma / 100.0 * 6.0, p_birikimTava / 100.0 * 14.0) * u_s * max(0.0, 1.0 - p_temizlen / 100.0 * u_t * 0.3);
  float cov = 0.0; if (surf(p) < 0.5) for (int k = 1; k <= 8; k++) { float r = float(k) / 8.0 * depth; if (surf(p + vec2(0.0, r)) > 0.5) { cov = 1.0 - float(k - 1) / 8.0 * 0.3; break; } }
  float grain = 0.75 + 0.25 * hash1(floor(p / max(u_s, 1.0))); vec4 dep = vec4(vec3(0.93, 0.92, 0.88) * grain, 1.0) * cov;
  vec2 q = toUnit(p); float cell = 14.0 / sqrt(max(rate, 0.05)); vec2 g = (q + vec2(0.0, -u_t * 60.0)) / cell; vec2 id = floor(g); vec2 h = hash2(id); vec2 pos = (id + h) * cell + vec2(0.0, u_t * 60.0);
  float fall = (1.0 - smoothstep(1.0, 1.8, length(q - pos))) * step(surf(fromUnit(pos)), 0.5) * step(hash1(id + 5.0), min(rate * 0.5, 1.0)); o = overPre(vec4(0.95) * fall, overPre(dep, s)); }

//== edgeflow
uniform sampler2D s_sinir; uniform float p_sinirOn, p_akis, p_dogum, p_omur, p_kenarOfse;
// Zerreler silüet sınırında (ofsetli bant) yakalanır ve kenar boyunca akar; doğum/ömür ile parıldar
float A(vec2 px) { return p_sinirOn > 0.5 ? texture(s_sinir, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float off = p_kenarOfse * u_s; float R = 6.0 * u_s; float inside = step(0.5, A(p));
  float d = inside > 0.5 ? -innerDist(p, R * 4.0) : outerDist(p, R * 4.0); if (p_sinirOn > 0.5) d = (inside > 0.5 ? -1.0 : 1.0) * 2.0; float band = 1.0 - smoothstep(1.0, 2.5 * u_s, abs(d - off));
  if (band <= 0.0) { o = s; return; } vec2 q = toUnit(p); float ang = atan(q.y, q.x); float rad = length(q); float arc = ang * max(rad, 1.0); float N = max(p_dogum, 1.0);
  float v = 0.0; for (int i = 0; i < 3; i++) { float sp = arc - u_t * p_akis * (0.8 + 0.2 * float(i)); float cellL = 6.2832 * max(rad, 1.0) / N * 3.0; float id = floor(sp / cellL + float(i) * 0.37);
    float life = fract(u_t / max(p_omur, 0.1) + hash1(vec2(id, float(i)))); float x = fract(sp / cellL + float(i) * 0.37); v = max(v, (1.0 - smoothstep(0.0, 0.08, abs(x - 0.5))) * sin(life * 3.14159)); }
  o = overPre(vec4(vec3(1.0, 0.95, 0.7) * v * band, v * band), s); }

//== plexus
uniform vec3 c_cizgi; uniform float p_nokta, p_bagMesa, p_azamiKoms, p_kalinlik;
// Her ızgara hücresinde bir zerre (yavaş gezinir); komşu hücrelerdeki zerreler bağ mesafesi içindeyse çizgiyle bağlanır
vec2 pt(vec2 c, float cell) { vec2 h = hash2(c); return (c + 0.5 + 0.38 * vec2(sin(u_t * 0.6 + h.x * 6.28), cos(u_t * 0.5 + h.y * 6.28))) * cell; }
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cell = sqrt(boxU().x * boxU().y / max(p_nokta, 2.0)); vec2 id = floor(q / cell); float lw = max(p_kalinlik, 0.2); float v = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 a = pt(id + vec2(i, j), cell); v = max(v, 1.0 - smoothstep(lw * 1.2, lw * 2.4, length(q - a)));
    int cnt = 0; for (int jj = -1; jj <= 1; jj++) for (int ii = -1; ii <= 1; ii++) { if (ii == 0 && jj == 0) continue; if (float(cnt) >= p_azamiKoms) break; vec2 b = pt(id + vec2(i + ii, j + jj), cell); float L = length(a - b);
      if (L > p_bagMesa) continue; cnt++; v = max(v, (1.0 - smoothstep(lw * 0.5, lw * 0.5 + 1.0 / u_s, seg(q, a, b))) * (1.0 - L / p_bagMesa)); } }
  o = overPre(vec4(c_cizgi, 1.0) * v, s); }

//== tailribbon
uniform vec4 p_dv4[16]; float dvAt(int i) { return i < 0 || i >= 64 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform vec3 c_renk; uniform float p_dvN, p_kuyrukSure, p_basKali;
// Kuyruk noktaları (motor: nesnenin geçmiş konumları, katman biriminde) → başta kalın, sona doğru incelen şerit
vec2 P(int i) { if (p_dvN > 1.5) return vec2(dvAt(i * 2), dvAt(i * 2 + 1)); float t = u_t - float(i) * p_kuyrukSure / 15.0; return vec2(sin(t * 2.0) * boxU().x * 0.3, cos(t * 1.4) * boxU().y * 0.25); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = p_dvN > 1.5 ? int(p_dvN / 2.0) : 16; float v = 0.0;
  for (int i = 0; i < 31; i++) { if (i + 1 >= N) break; vec2 a = P(i), b = P(i + 1); vec2 ab = b - a; float t = clamp(dot(q - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(q - a - ab * t);
    float u = (float(i) + t) / float(N - 1); float w = p_basKali * 0.5 * (1.0 - u); v = max(v, (1.0 - smoothstep(w - 0.7 / u_s, w + 0.7 / u_s, d)) * (1.0 - u * 0.6)); }
  o = overPre(vec4(c_renk, 1.0) * v, s); }

//== slitlight
uniform vec2 p_kaynak; uniform float p_yarikGeni, p_projeksi, p_kenarPenu;
// Işık kaynağından kutu merkezindeki yarıktan geçen kama; projeksiyon boyunca uzar, iki kenarı yarı gölgeli
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 S = p_kaynak; vec2 C = vec2(0.0); vec2 ax = normalize(C - S + vec2(1e-4)); vec2 nr = vec2(-ax.y, ax.x);
  float along = dot(q - C, ax); float across = dot(q - C, nr); float dist = length(C - S); float halfw = p_yarikGeni * 0.5 * (1.0 + max(along, 0.0) / max(dist, 1.0));
  float pen = p_kenarPenu * (0.3 + max(along, 0.0) / max(dist, 1.0)) + 0.5; float wedge = (1.0 - smoothstep(halfw - pen, halfw + pen, abs(across))) * smoothstep(-2.0, 2.0, along) * (1.0 - smoothstep(p_projeksi * 0.8, p_projeksi, along));
  vec3 c = s.rgb * (0.45 + 0.9 * wedge); o = vec4(c, s.a); }

//== dustinlight
uniform sampler2D s_isikMask; uniform float p_isikMaskOn, p_zerre, p_akis, p_parlakli, p_maskeGeci;
// Zerreler yalnız ışık hacminde görünür (maske ya da üstten inen koni)
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 b = boxUV(here()); float m;
  if (p_isikMaskOn > 0.5) { float r = p_maskeGeci * u_s; m = 0.0; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) m += texture(s_isikMask, boxUV(here() + vec2(i, j) * r * 0.5)).a; m /= 9.0; }
  else { float w = 0.12 + b.y * 0.25; m = 1.0 - smoothstep(w - 0.05 - p_maskeGeci * 0.002, w + 0.05, abs(b.x - 0.5 - (b.y - 0.5) * 0.15)); }
  float dens = clamp(p_zerre / 300.0, 0.0, 15.0); float cell = 10.0 / sqrt(max(dens, 0.05)); vec2 dr = vec2(u_t * p_akis * 0.3, sin(u_t * 0.2) * 4.0); vec2 id = floor((q + dr) / cell); float v = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(i, j); vec2 h = hash2(c); vec2 pos = (c + h) * cell - dr + vec2(sin(u_t + h.x * 9.0), cos(u_t * 0.8 + h.y * 9.0)) * cell * 0.2;
    v += (1.0 - smoothstep(0.4, 1.1 + h.y, length(q - pos))) * (0.5 + 0.5 * sin(u_t * 3.0 + h.x * 20.0)); }
  float beam = m * 0.12; vec3 add = vec3(1.0, 0.96, 0.85) * (clamp(v, 0.0, 1.0) * m * p_parlakli / 100.0 + beam); o = vec4(s.rgb + add * (1.0 - s.a * 0.2), max(s.a, clamp(luma(add), 0.0, 1.0))); }

//== depthrim
uniform sampler2D s_derinlik; uniform vec3 c_renk; uniform float p_derinlikOn, p_derinlikEsig, p_hale, p_guc;
// Derinlik süreksizliği: komşulardan daha yakın (daha parlak) olan kenar piksellerinde, dışa doğru hale
float dep(vec2 px) { return p_derinlikOn > 0.5 ? luma(texture(s_derinlik, boxUV(px)).rgb) : lumAt(px); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float H = max(p_hale * u_s, 1.0); float th = p_derinlikEsig / 100.0; float g = 0.0;
  for (int i = 0; i < 12; i++) { float a = float(i) / 12.0 * TAU; vec2 d = vec2(cos(a), sin(a)); for (int k = 1; k <= 4; k++) { float r = float(k) / 4.0 * H; float near = dep(p + d * r); float far = dep(p + d * (r + 2.0 * u_s));
      float jump = near - far; if (jump > th) { g = max(g, (1.0 - float(k - 1) / 4.0) * smoothstep(th, th + 0.1, jump)); } } }
  o = vec4(s.rgb + c_renk * g * p_guc / 100.0, max(s.a, g * p_guc / 100.0 * 0.8)); }

//== lightocclusion
uniform sampler2D s_engel; uniform vec2 p_isikKayn; uniform float p_engelOn, p_erisim, p_acisalOrne, p_kenarGeci;
// Işıktan piksele doğru 2B ışın yürütme; engel (kaynak katman ya da katmanın kendi alfası) kesişirse gölge; erişim mesafesiyle söner
float occ(vec2 px) { return p_engelOn > 0.5 ? texture(s_engel, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 L = p_isikKayn; vec2 d = q - L; float D = length(d); float steps = clamp(p_acisalOrne / 8.0, 8.0, 64.0); float vis = 1.0;
  for (int k = 1; k < 64; k++) { if (float(k) >= steps) break; vec2 pp = L + d * float(k) / steps; float o2 = occ(fromUnit(pp)); vis = min(vis, 1.0 - o2 * smoothstep(0.0, p_kenarGeci * 0.02 + 0.05, 1.0 - float(k) / steps)); }
  if (p_engelOn < 0.5 && s.a > 0.5) vis = 1.0; float fall = 1.0 - smoothstep(p_erisim * 0.6, p_erisim, D); float lit = vis * fall;
  vec3 c = s.a > 0.0 ? s.rgb * (0.35 + 0.65 * lit) : vec3(1.0, 0.95, 0.8) * lit * 0.35; o = vec4(c, max(s.a, lit * 0.35)); }
