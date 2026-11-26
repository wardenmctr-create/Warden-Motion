// Bükme ve Bozulma (rehberdeki ayarlar). Konum ayarları katman biriminde (merkeze göre), px ayarları katman biriminde.
//== fractal
uniform float p_bukmeMikt, p_olcek, p_ayrinti, p_evrim, p_akisHizi, p_tohum, p_kenarlarSabi;
void main() {
  vec2 q = toUnit(here()); float sc = max(p_olcek, 1.0); vec2 sd = vec2(seedf(p_tohum), seedf(p_tohum + 7.0));
  float ev = p_evrim * 0.03 + u_t * p_akisHizi;
  vec2 n = q / sc + sd;
  vec2 d = vec2(fbm(n + vec2(ev, 0.0), p_ayrinti - 1.0), fbm(n + vec2(5.2, 1.3) - vec2(0.0, ev), p_ayrinti - 1.0));
  float w = p_kenarlarSabi > 0.5 ? pinW(1.0, boxUV(here())) : 1.0;
  o = texU(q + d * p_bukmeMikt * w);
}
//== mirror
uniform float p_yatayAyna, p_dikeyAyna; uniform vec2 p_aynaMerk;
void main() {
  vec2 q = toUnit(here());
  if (p_yatayAyna > 0.5) q.x = 2.0 * p_aynaMerk.x - q.x;
  if (p_dikeyAyna > 0.5) q.y = 2.0 * p_aynaMerk.y - q.y;
  o = texU(q);
}
//== reflect
uniform float p_yansimaEkse, p_kaynakTara, p_birlesimYumu, p_tersKayn; uniform vec2 p_eksenNokt;
void main() {
  vec2 q = toUnit(here()); float a = radians(p_yansimaEkse);
  vec2 n = vec2(-sin(a), cos(a));
  vec2 want = p_kaynakTara < 0.5 ? vec2(-1, 0) : p_kaynakTara < 1.5 ? vec2(1, 0) : p_kaynakTara < 2.5 ? vec2(0, -1) : vec2(0, 1);
  float sg = dot(n, want) >= 0.0 ? 1.0 : -1.0; if (p_tersKayn > 0.5) sg = -sg;
  float d = dot(q - p_eksenNokt, n) * sg;
  vec4 orig = texU(q);
  if (d >= 0.0) { o = orig; return; }
  vec4 r = texU(q - 2.0 * dot(q - p_eksenNokt, n) * n);
  float w = p_birlesimYumu > 0.01 ? smoothstep(0.0, p_birlesimYumu, -d) : 1.0;
  o = mix(orig, r, w);
}
//== wave
uniform float p_dalgaYuks, p_dalgaBoyu, p_dalgaYonu, p_faz, p_hiz, p_dalgaTipi, p_sabitKena, p_kenarIsle;
void main() {
  vec2 q = toUnit(here()); float a = radians(p_dalgaYonu);
  vec2 d = vec2(cos(a), sin(a)), n = vec2(-d.y, d.x);
  float ph = TAU * (dot(q, d) / max(p_dalgaBoyu, 1.0) - p_hiz * u_t) + p_faz * TAU / 100.0;
  float off = wavef(p_dalgaTipi, ph) * p_dalgaYuks * pinW(p_sabitKena, boxUV(here()));
  o = texEdge(fromUnit(q - n * off), p_kenarIsle);
}
//== swirl
uniform vec2 p_merkez; uniform float p_yaricap, p_girdapAcis, p_dusus, p_disHattKoru;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float R = max(p_yaricap, 1.0);
  float t = clamp(1.0 - length(r) / R, 0.0, 1.0);
  float f = pow(smoothstep(0.0, 1.0, t), mix(0.6, 2.5, p_dusus / 100.0));
  vec4 s = texU(p_merkez + rot2(-p_girdapAcis * f) * r);
  if (p_disHattKoru > 0.5) { float a0 = texU(q).a; s = pre(unpre(s), a0); }
  o = s;
}
//== bulge
uniform vec2 p_merkez; uniform float p_yaricap, p_sisirme, p_dusus, p_disHattKoru;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float R = max(p_yaricap, 1.0); float x = length(r) / R;
  float f = x < 1.0 ? pow(1.0 - x * x, mix(0.5, 2.0, p_dusus / 100.0)) : 0.0;
  vec4 s = texU(p_merkez + r * (1.0 - p_sisirme / 100.0 * 0.65 * f));
  if (p_disHattKoru > 0.5) s = pre(unpre(s), texU(q).a);
  o = s;
}
//== ripple
uniform vec2 p_merkez; uniform float p_yaricap, p_aci, p_halkaAral, p_genlik, p_faz, p_hiz, p_azalma;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float d = length(r); float R = max(p_yaricap, 1.0);
  float w = sin(TAU * (d / max(p_halkaAral, 1.0) - p_hiz * u_t) + p_faz * TAU / 100.0);
  float amp = p_genlik * exp(-d / R * p_azalma / 100.0 * 3.0) * (1.0 - smoothstep(R * 0.85, R, d));
  vec2 dir = d > 0.001 ? rot2(p_aci) * (r / d) : vec2(0.0);
  o = texU(q - dir * w * amp);
}
//== polar
uniform float p_donusum, p_miktar, p_aci, p_tersYon; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float rad = min(B.x, B.y) * 0.5;
  vec2 src;
  if (p_donusum < 0.5) { // dikdörtgenden kutupsala: kutu daireye sarılır
    vec2 rel = q - p_merkez; float th = atan(rel.y, rel.x) - radians(p_aci) + PI * 0.5;
    float u = fract(th / TAU); if (p_tersYon > 0.5) u = 1.0 - u;
    float v = length(rel) / rad;
    src = v > 1.0 ? vec2(1e5) : (vec2(u, v) - 0.5) * B;
  } else {               // kutupsaldan dikdörtgene: daire açılır
    vec2 b = boxUV(here()); float u = p_tersYon > 0.5 ? 1.0 - b.x : b.x;
    float th = u * TAU + radians(p_aci) - PI * 0.5; float r = b.y * rad;
    src = p_merkez + r * vec2(cos(th), sin(th));
  }
  o = texU(mix(q, src, p_miktar / 100.0));
}
//== stretchseg
uniform vec2 p_merkez; uniform float p_seritGeni, p_esneme, p_aci, p_gecis, p_oraniKoru;
void main() {
  vec2 q = toUnit(here()); float a = radians(p_aci + 90.0); vec2 d = vec2(cos(a), sin(a)), n = vec2(-d.y, d.x);
  vec2 r = q - p_merkez; float s = dot(r, d), m = dot(r, n);
  float hw = max(p_seritGeni, 0.5) * 0.5; float E = p_seritGeni * p_esneme / 100.0; float ho = max(0.5, hw + E * 0.5);
  float ss = abs(s) < ho ? s * hw / ho : s - sign(s) * E * 0.5;
  if (p_gecis > 0.01) { float k = smoothstep(ho, ho + p_gecis, abs(s)); ss = mix(abs(s) < ho ? s * hw / ho : sign(s) * hw, ss, k); if (abs(s) < ho) ss = s * hw / ho; }
  float mm = (p_oraniKoru > 0.5 && abs(s) < ho) ? m * hw / ho : m;
  o = texU(p_merkez + d * ss + n * mm);
}
//== magnify
uniform vec2 p_merkez; uniform float p_yaricap, p_buyutme, p_kenarYumu, p_cerceve, p_cerceveKali; uniform vec3 c_cerceveReng;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float d = length(r); float R = max(p_yaricap, 1.0);
  vec4 orig = texU(q), mag = texU(p_merkez + r / max(p_buyutme, 0.05));
  float w = 1.0 - smoothstep(R - max(p_kenarYumu, 0.5), R, d);
  vec4 c = mix(orig, mag, w);
  if (p_cerceve > 0.5) { float ring = smoothstep(R - 0.6, R + 0.2, d) * (1.0 - smoothstep(R + p_cerceveKali - 0.2, R + p_cerceveKali + 0.6, d)); c = mix(c, vec4(c_cerceveReng, 1.0), ring); }
  o = c;
}
//== tiles
uniform float p_karoBoyu, p_karoAcis, p_aralik, p_kirpma, p_siraKayd, p_ayna, p_dikeyKayd; uniform vec2 p_ofset;
void main() {
  vec2 B = boxU(); vec2 q = toUnit(here()) + p_ofset / 100.0 * B;
  vec2 p = rot2(-p_karoAcis) * q + 0.5 * B;
  vec2 cell = vec2(max(p_karoBoyu, 2.0)); cell.y *= B.y / B.x;
  if (p_dikeyKayd > 0.5) { float col = floor(p.x / cell.x); p.y += col * cell.y * p_siraKayd / 100.0; }
  else { float row = floor(p.y / cell.y); p.x += row * cell.x * p_siraKayd / 100.0; }
  vec2 id = floor(p / cell); vec2 f = fract(p / cell);
  if (p_kirpma > 0.0) { vec2 lim = ceil(B / cell * 0.5 * (1.0 + 2.0 * p_kirpma)); vec2 cid = id - floor(B / cell * 0.5); if (abs(cid.x) > lim.x || abs(cid.y) > lim.y) { o = vec4(0.0); return; } }
  if (p_ayna > 0.5) { if (mod(id.x, 2.0) > 0.5) f.x = 1.0 - f.x; if (mod(id.y, 2.0) > 0.5) f.y = 1.0 - f.y; }
  vec2 g = p_aralik / cell; vec2 f2 = (f - g * 0.5) / max(vec2(0.01), 1.0 - g);
  if (any(lessThan(f2, vec2(0.0))) || any(greaterThan(f2, vec2(1.0)))) { o = vec4(0.0); return; }
  o = texPx(boxPx(f2));
}
//== hextile
uniform float p_karoBoyu, p_aci, p_aralik, p_ayna; uniform vec2 p_ofset; uniform vec3 c_boslukReng;
void main() {
  vec2 B = boxU(); vec2 q = rot2(-p_aci) * (toUnit(here()) + p_ofset / 100.0 * B);
  float s = max(p_karoBoyu, 4.0); vec4 h = hexGrid(q, s);
  vec2 g = (q - h.xy) / s; float hd = hexDist(g);
  float gap = p_aralik / s;
  if (hd > 0.5 - gap * 0.5) { o = vec4(c_boslukReng, 1.0); return; }
  vec2 f = g / (1.0 - gap) * vec2(1.0, B.x / B.y) + 0.5;
  if (p_ayna > 0.5 && mod(h.z + h.w, 2.0) > 0.5) f.x = 1.0 - f.x;
  o = texPx(boxPx(clamp(f, 0.0, 1.0)));
}
//== hexrotate
uniform float p_altigenBoyu, p_donusAcis, p_rastgeleDonu, p_faz, p_tohum, p_kenariKirp;
void main() {
  vec2 q = toUnit(here()); float s = max(p_altigenBoyu, 4.0); vec4 h = hexGrid(q, s);
  float r = hash1(h.zw + seedf(p_tohum)) * 2.0 - 1.0;
  float ang = p_donusAcis * mix(1.0, r, p_rastgeleDonu / 100.0) + p_faz * 3.6;
  vec2 src = h.xy + rot2(-ang) * (q - h.xy);
  if (p_kenariKirp > 0.5) { vec4 h2 = hexGrid(src, s); if (distance(h2.zw, h.zw) > 0.1) { o = vec4(0.0); return; } }
  o = texU(src);
}
//== hexshift
uniform float p_altigenBoyu, p_kaydirma, p_rastgeleYon, p_faz, p_tohum, p_kenariKirp;
void main() {
  vec2 q = toUnit(here()); float s = max(p_altigenBoyu, 4.0); vec4 h = hexGrid(q, s);
  vec2 rr = hash2(h.zw + seedf(p_tohum) + floor(p_faz / 10.0));
  float ang = mix(0.0, rr.x * TAU, p_rastgeleYon / 100.0); float amt = p_kaydirma * mix(1.0, rr.y, 0.5) * (0.6 + 0.4 * cos(p_faz * TAU / 100.0));
  vec2 src = q - vec2(cos(ang), sin(ang)) * amt;
  if (p_kenariKirp > 0.5) { vec4 h2 = hexGrid(src, s); if (distance(h2.zw, h.zw) > 0.1) { o = vec4(0.0); return; } }
  o = texU(src);
}
//== tilerotate
uniform float p_karoBoyu, p_donusAcis, p_rastgeleDonu, p_faz, p_tohum, p_kenariKirp;
void main() {
  vec2 q = toUnit(here()); float s = max(p_karoBoyu, 2.0); vec2 id = floor(q / s); vec2 c = (id + 0.5) * s;
  float r = hash1(id + seedf(p_tohum)) * 2.0 - 1.0;
  float ang = p_donusAcis * mix(1.0, r, p_rastgeleDonu / 100.0) + p_faz * 3.6;
  vec2 src = c + rot2(-ang) * (q - c);
  if (p_kenariKirp > 0.5 && any(greaterThan(abs(src - c), vec2(s * 0.5)))) { o = vec4(0.0); return; }
  o = texU(src);
}
//== tileshift
uniform float p_karoBoyu, p_kaydirma, p_yon, p_rastgeleYon, p_faz, p_tohum, p_kenariKirp;
void main() {
  vec2 q = toUnit(here()); float s = max(p_karoBoyu, 2.0); vec2 id = floor(q / s); vec2 c = (id + 0.5) * s;
  vec2 rr = hash2(id + seedf(p_tohum) + floor(p_faz / 10.0));
  float ang = radians(p_yon) + (rr.x - 0.5) * TAU * p_rastgeleYon / 100.0;
  float amt = p_kaydirma * mix(1.0, rr.y * 2.0 - 1.0, p_rastgeleYon / 100.0) * (0.6 + 0.4 * cos(p_faz * TAU / 100.0));
  vec2 src = q - vec2(cos(ang), sin(ang)) * amt;
  if (p_kenariKirp > 0.5 && any(greaterThan(abs(src - c), vec2(s * 0.5)))) { o = vec4(0.0); return; }
  o = texU(src);
}
//== kaleido
uniform vec2 p_merkez; uniform float p_dilimSayi, p_aci, p_olcek, p_aynala, p_birlesimYumu;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float d = length(r);
  float seg = TAU / max(2.0, floor(p_dilimSayi));
  float a = atan(r.y, r.x) - radians(p_aci); a = mod(a, seg);
  if (p_aynala > 0.5) a = min(a, seg - a);
  vec2 src = p_merkez + vec2(cos(a + radians(p_aci)), sin(a + radians(p_aci))) * d / max(p_olcek / 100.0, 0.01);
  vec4 c = texU(src);
  if (p_birlesimYumu > 0.01) { float e = min(mod(atan(r.y, r.x) - radians(p_aci), seg), seg - mod(atan(r.y, r.x) - radians(p_aci), seg)) * d; c *= mix(0.85, 1.0, smoothstep(0.0, p_birlesimYumu, e)); }
  o = c;
}
//== offset
uniform float p_yatayKayd, p_dikeyKayd, p_kenarModu, p_birim;
void main() {
  vec2 b = boxUV(here());
  vec2 d = p_birim < 0.5 ? vec2(p_yatayKayd, p_dikeyKayd) * u_s / u_box.zw : vec2(p_yatayKayd, p_dikeyKayd) / 100.0;
  float m = p_kenarModu < 0.5 ? 2.0 : p_kenarModu < 1.5 ? 1.0 : p_kenarModu < 2.5 ? 3.0 : 0.0;
  o = texEdge(boxPx(b - d), m);
}
//== pixelate
uniform float p_pikselGeni, p_pikselYuks, p_karePiks, p_orneklem; uniform vec2 p_izgaraKonu;
void main() {
  vec2 cs = vec2(max(p_pikselGeni, 0.5), max(p_karePiks > 0.5 ? p_pikselGeni : p_pikselYuks, 0.5)) * u_s;
  vec2 org = u_box.xy + p_izgaraKonu / 100.0 * u_box.zw;
  vec2 id = floor((here() - org) / cs); vec2 c0 = org + id * cs;
  if (p_orneklem > 0.5) { o = texPx(c0 + cs * 0.5); return; }
  vec4 acc = vec4(0.0);
  for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) acc += texPx(c0 + cs * (vec2(float(i), float(j)) + 0.5) / 4.0);
  o = acc / 16.0;
}
//== mosaic
uniform float p_tasGeni, p_tasYuks, p_derz, p_renkYont, p_kareTas; uniform vec3 c_derzReng;
void main() {
  vec2 cs = vec2(max(p_tasGeni, 1.0), max(p_kareTas > 0.5 ? p_tasGeni : p_tasYuks, 1.0)) * u_s;
  vec2 id = floor((here() - u_box.xy) / cs); vec2 c0 = u_box.xy + id * cs;
  vec4 c;
  if (p_renkYont > 0.5) c = texPx(c0 + cs * 0.5);
  else { c = vec4(0.0); for (int j = 0; j < 3; j++) for (int i = 0; i < 3; i++) c += texPx(c0 + cs * (vec2(float(i), float(j)) + 0.5) / 3.0); c /= 9.0; }
  vec2 f = (here() - c0); float g = p_derz * u_s * 0.5;
  float e = min(min(f.x, cs.x - f.x), min(f.y, cs.y - f.y));
  float gm = 1.0 - smoothstep(g - 0.7, g + 0.7, e);
  float a = texPx(here()).a;
  o = mix(c, vec4(c_derzReng, 1.0) * max(a, c.a), gm * step(0.01, max(a, c.a)));
}
//== rgbsplit
uniform vec2 p_kirmiziOfse, p_yesilOfse, p_maviOfse; uniform float p_ayrim, p_aci, p_kenarModu, p_alfayiBirl;
void main() {
  mat2 R = rot2(p_aci); float k = p_ayrim * u_s;
  float m = p_kenarModu < 0.5 ? 0.0 : p_kenarModu < 1.5 ? 3.0 : 1.0;
  vec4 r = texEdge(here() - R * p_kirmiziOfse * k, m), g = texEdge(here() - R * p_yesilOfse * k, m), b = texEdge(here() - R * p_maviOfse * k, m);
  float a = p_alfayiBirl > 0.5 ? max(r.a, max(g.a, b.a)) : texPx(here()).a;
  o = vec4(r.r, g.g, b.b, a);
}
//== glitch
uniform float p_blokMikt, p_blokBoyu, p_kayma, p_rgbAyri, p_taramaCizg, p_tekrarla, p_tohum, p_kareTut;
void main() {
  vec2 px = here(); float tq = p_kareTut > 0.5 ? floor(u_t * max(p_tekrarla, 0.01)) : u_t * p_tekrarla;
  float bs = max(p_blokBoyu, 1.0) * u_s; float sd = seedf(p_tohum);
  float by = floor((px.y - u_box.y) / bs);
  float r = hash1(vec2(by, tq + sd)); float r2 = hash1(vec2(by * 1.7, tq * 1.3 + sd + 5.0));
  float on = step(r, p_blokMikt / 100.0);
  // ikinci ölçekte küçük bloklar
  float bx = floor((px.x - u_box.x) / (bs * 3.0)); float on2 = step(hash1(vec2(bx, by + tq * 7.0 + sd)), p_blokMikt / 250.0);
  float sh = (on * (r2 * 2.0 - 1.0) + on2 * (hash1(vec2(bx, by)) - 0.5)) * p_kayma * u_s;
  float ca = (on + on2 * 0.5) * p_rgbAyri * u_s + p_rgbAyri * u_s * 0.15;
  vec2 p = px + vec2(sh, 0.0);
  vec4 c = vec4(texPx(p + vec2(ca, 0.0)).r, texPx(p).g, texPx(p - vec2(ca, 0.0)).b, 0.0);
  c.a = max(texPx(p).a, max(texPx(p + vec2(ca, 0.0)).a, texPx(p - vec2(ca, 0.0)).a));
  float sl = 1.0 - p_taramaCizg / 100.0 * 0.6 * step(0.5, fract(px.y / max(2.0, u_s * 2.0)));
  c.rgb *= sl;
  o = c;
}
//== displace
uniform float p_miktar, p_olcek, p_karmasik, p_evrim, p_bozulmaTipi, p_sabitKena, p_tohum; uniform vec2 p_ofset;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float sc = max(p_olcek, 1.0);
  vec2 n = (q + p_ofset / 100.0 * B) / sc + vec2(seedf(p_tohum)); float ev = p_evrim * 0.05;
  float oc = p_karmasik - 1.0;
  float fx = fbm(n + vec2(ev, 1.7), oc), fy = fbm(n + vec2(4.3, -ev), oc);
  vec2 d;
  if (p_bozulmaTipi < 0.5) d = vec2(fx, fy);
  else if (p_bozulmaTipi < 1.5) { vec2 r = normalize(q + 1e-4); d = r * fx; }
  else if (p_bozulmaTipi < 2.5) { vec2 r = normalize(q + 1e-4); d = vec2(-r.y, r.x) * fx; }
  else if (p_bozulmaTipi < 3.5) d = vec2(fx, 0.0); else d = vec2(0.0, fy);
  o = texU(q + d * p_miktar * pinW(p_sabitKena, boxUV(here())));
}
//== shear
uniform float p_yatayEgim, p_dikeyEgim, p_kenarKirp; uniform vec2 p_dayanak;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_dayanak;
  float tx = tan(radians(clamp(p_yatayEgim, -85.0, 85.0))), ty = tan(radians(clamp(p_dikeyEgim, -85.0, 85.0)));
  vec2 s = vec2(r.x - tx * r.y, r.y - ty * r.x) / max(0.05, 1.0 - tx * ty);
  s = vec2(r.x - tx * (r.y - ty * r.x), r.y - ty * r.x);
  vec4 c = texU(p_dayanak + s);
  if (p_kenarKirp > 0.5) { vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) c = vec4(0.0); }
  o = c;
}
//== slices
uniform float p_dilimSayi, p_azamiKaym, p_aci, p_yenilenm, p_tohum, p_sarmala;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 p = rot2(-p_aci) * q;
  float n = max(2.0, floor(p_dilimSayi)); float hh = max(B.x, B.y);
  float id = floor((p.y / hh + 0.5) * n);
  float r = hash1(vec2(id, floor(u_t * p_yenilenm) + seedf(p_tohum))) * 2.0 - 1.0;
  vec2 src = rot2(p_aci) * (p - vec2(r * p_azamiKaym, 0.0));
  o = p_sarmala > 0.5 ? texEdge(fromUnit(src), 2.0) : texU(src);
}
//== squeeze
uniform float p_esneme, p_yon, p_esneklik, p_sonum, p_hiz, p_hacmiKoru; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float a = radians(p_yon); vec2 d = vec2(cos(a), sin(a)), n = vec2(-d.y, d.x);
  vec2 r = q - p_merkez; float s = dot(r, d), m = dot(r, n);
  float wob = sin(TAU * p_hiz * u_t) * exp(-p_sonum / 100.0 * u_t * 1.5);
  float half_ = max(1.0, abs(dot(B * 0.5, abs(d))));
  float st = 1.0 + p_esneme / half_ * wob * mix(0.4, 1.0, p_esneklik / 100.0);
  // jöle: uçlar biraz gecikir
  float lag = 1.0 + 0.15 * p_esneklik / 100.0 * sin(TAU * p_hiz * u_t - abs(s) / half_ * 1.5) * exp(-p_sonum / 100.0 * u_t * 1.5);
  st *= lag;
  float pf = p_hacmiKoru > 0.5 ? inversesqrt(max(0.05, st)) : 1.0;
  o = texU(p_merkez + d * s / max(0.05, st) + n * m / max(0.05, pf));
}
//== bezierwarp
uniform float p_agYogu, p_kenarlarUzat;
void main() { o = p_kenarlarUzat > 0.5 ? texEdge(here(), 3.0) : texPx(here()); }
//== cornerpin
uniform vec2 p_solUst, p_sagUst, p_solAlt, p_sagAlt; uniform float p_perspektDuze, p_kenarModu;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU();
  vec2 q0 = p_solUst, q1 = p_sagUst, q2 = p_sagAlt, q3 = p_solAlt;
  float sx = q0.x - q1.x + q2.x - q3.x, sy = q0.y - q1.y + q2.y - q3.y;
  float a, b, c, d, e, f, g, h;
  if (p_perspektDuze < 0.5 || (abs(sx) < 1e-4 && abs(sy) < 1e-4)) { a = q1.x - q0.x; b = q3.x - q0.x; c = q0.x; d = q1.y - q0.y; e = q3.y - q0.y; f = q0.y; g = 0.0; h = 0.0; }
  else {
    float dx1 = q1.x - q2.x, dx2 = q3.x - q2.x, dy1 = q1.y - q2.y, dy2 = q3.y - q2.y; float det = dx1 * dy2 - dx2 * dy1;
    g = (sx * dy2 - dx2 * sy) / det; h = (dx1 * sy - sx * dy1) / det;
    a = q1.x - q0.x + g * q1.x; b = q3.x - q0.x + h * q3.x; c = q0.x; d = q1.y - q0.y + g * q1.y; e = q3.y - q0.y + h * q3.y; f = q0.y;
  }
  mat3 H = mat3(a, d, g, b, e, h, c, f, 1.0);
  vec3 uv = inverse(H) * vec3(q, 1.0); vec2 st = uv.xy / uv.z;
  if (p_kenarModu < 0.5 && (any(lessThan(st, vec2(0.0))) || any(greaterThan(st, vec2(1.0))))) { o = vec4(0.0); return; }
  o = texPx(boxPx(clamp(st, 0.0, 1.0)));
}
//== bendit
uniform vec2 p_baslangi, p_bitis; uniform float p_bukulmeAcis, p_bukumYonu, p_genisligKoru;
void main() {
  vec2 q = toUnit(here()); vec2 A = p_baslangi, Bp = p_bitis; vec2 ax = Bp - A; float L = max(length(ax), 1.0); vec2 d = ax / L;
  float th = radians(p_bukulmeAcis); vec2 n = vec2(-d.y, d.x) * (cos(radians(p_bukumYonu)) >= 0.0 ? 1.0 : -1.0);
  if (th < 0.0) { th = -th; n = -n; }
  if (th < 1e-3 || dot(q - A, d) < 0.0) { o = texU(q); return; }
  float R = L / th; vec2 C = A + n * R; vec2 rel = q - C;
  float phi = atan(dot(rel, d), dot(rel, -n));
  vec2 src;
  if (phi >= 0.0 && phi <= th) { float t = R - length(rel); src = A + d * phi * R + n * t; }
  else {
    vec2 E = C + (-n * cos(th) + d * sin(th)) * R; vec2 d2 = d * cos(th) + n * sin(th); vec2 n2 = vec2(-d2.y, d2.x) * sign(dot(vec2(-d.y, d.x), n));
    vec2 lr = q - E; float u = dot(lr, d2), v = dot(lr, n2);
    if (u < 0.0) { o = vec4(0.0); return; }
    src = Bp + d * u + n * v * sign(dot(n2, n));
  }
  o = texU(src);
}
//== blobby_c
uniform sampler2D u_src; uniform sampler2D u_aux; uniform float p_damlalas, p_yumusatm, p_esik, p_yuzeyParl, p_isikAcis, p_yalnizAlfa;
void main() {
  vec4 b = texture(u_aux, v_uv); float th = p_esik / 100.0; float sw = 0.02 + p_yumusatm / 200.0;
  float a = smoothstep(th - sw, th + sw, b.a);
  vec2 e = 1.5 / u_res;
  float gx = texture(u_aux, v_uv + vec2(e.x, 0.0)).a - texture(u_aux, v_uv - vec2(e.x, 0.0)).a;
  float gy = texture(u_aux, v_uv + vec2(0.0, e.y)).a - texture(u_aux, v_uv - vec2(0.0, e.y)).a;
  vec3 nrm = normalize(vec3(-gx * 6.0, -gy * 6.0, 1.0)); float la = radians(p_isikAcis);
  vec3 L = normalize(vec3(cos(la), sin(la), 1.2)); float sp = pow(max(dot(reflect(-L, nrm), vec3(0, 0, 1)), 0.0), 18.0) * p_yuzeyParl / 100.0;
  vec3 col = p_yalnizAlfa > 0.5 ? unpre(texture(u_src, v_uv)) : (b.a > 0.001 ? b.rgb / b.a : vec3(0.0));
  if (p_yalnizAlfa > 0.5 && texture(u_src, v_uv).a < 0.01) col = b.a > 0.001 ? b.rgb / b.a : vec3(0.0);
  o = pre(clamp(col * (0.85 + 0.15 * dot(nrm, L)) + sp, 0.0, 1.0), a);
}
//== flomotion
uniform vec2 p_cekimMerk, p_ikinciMerk; uniform float p_kuvvet, p_yaricap, p_dusus, p_ikinciNokt, p_ikinciKuvv;
vec2 pull(vec2 q, vec2 c, float k) { vec2 r = q - c; float x = length(r) / max(p_yaricap, 1.0); float f = x < 1.0 ? pow(1.0 - x, mix(0.5, 3.0, p_dusus / 100.0)) : 0.0; return c + r * (1.0 + k / 100.0 * 0.9 * f); }
void main() {
  vec2 q = toUnit(here()); vec2 s = pull(q, p_cekimMerk, p_kuvvet);
  if (p_ikinciNokt > 0.5) s = pull(s, p_ikinciMerk, p_ikinciKuvv);
  o = texU(s);
}
//== griddler
uniform float p_satir, p_sutun, p_parcaDonu, p_parcaKaym, p_olcek, p_rastgele, p_tohum;
void main() {
  vec2 b = boxUV(here()); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir)));
  vec2 B = boxU();
  vec2 id = floor(b * n); vec2 cell = B / n; vec2 c = (id + 0.5) / n;
  vec2 rr = hash2(id + seedf(p_tohum));
  float ang = p_parcaDonu * mix(1.0, rr.x * 2.0 - 1.0, p_rastgele / 100.0);
  float sa = rr.y * TAU; vec2 sh = vec2(cos(sa), sin(sa)) * p_parcaKaym * mix(1.0, rr.x, p_rastgele / 100.0);
  vec2 lu = (b - c) * B - sh / 1.0; lu = rot2(-ang) * lu / max(p_olcek / 100.0, 0.01);
  vec2 sb = c + lu / B;
  if (any(greaterThan(abs(sb - c), 0.5 / n))) { o = vec4(0.0); return; }
  o = texPx(boxPx(sb));
}
//== lens
uniform vec2 p_mercekMerk; uniform float p_yaricap, p_kirilma, p_buyutme, p_kenarGeci, p_renkSaca;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_mercekMerk; float R = max(p_yaricap, 1.0); float x = length(r) / R;
  if (x >= 1.0) { o = texU(q); return; }
  float z = sqrt(1.0 - x * x); float k = mix(1.0, z, clamp((p_kirilma - 1.0) / 2.0, 0.0, 1.0));
  vec2 s = r * k / max(p_buyutme, 0.05);
  float ca = p_renkSaca * x;
  vec4 c = vec4(texU(p_mercekMerk + s * (1.0 + ca / R)).r, texU(p_mercekMerk + s).g, texU(p_mercekMerk + s * (1.0 - ca / R)).b, texU(p_mercekMerk + s).a);
  float w = 1.0 - smoothstep(R - max(p_kenarGeci, 0.5), R, length(r));
  o = mix(texU(q), c, w);
}
//== pageturn
uniform sampler2D s_arkaYuzKatm; uniform float p_arkaYuzKatmOn;
uniform vec2 p_kivrilmaNokt; uniform float p_kivrimAcis, p_yaricap, p_golge, p_arkaYuzuGost; uniform vec3 c_arkaYuzReng;
vec4 backFace(vec2 src, float shade) { vec4 s = texU(src); if (s.a < 0.01) return vec4(0.0);
  vec3 col = p_arkaYuzKatmOn > 0.5 ? unpre(texture(s_arkaYuzKatm, clamp(boxUV(fromUnit(src)), 0.0, 1.0))) : c_arkaYuzReng;
  if (p_arkaYuzuGost < 0.5) col = unpre(s); return pre(col * shade, s.a); }
void main() {
  vec2 q = toUnit(here()); float a = radians(p_kivrimAcis); vec2 dir = vec2(cos(a), sin(a));
  float R = max(p_yaricap, 1.0); float d = dot(q - p_kivrilmaNokt, dir);
  vec4 front = vec4(0.0); vec4 back = vec4(0.0);
  if (d < 0.0) {
    front = texU(q);
    back = backFace(q + dir * (PI * R - 2.0 * d), 0.92);
    float sh = p_golge / 100.0 * (1.0 - smoothstep(0.0, R * 0.8, -d)) * 0.5;
    front.rgb *= 1.0 - sh;
  } else if (d < R) {
    float d1 = R * asin(d / R), d2 = R * (PI - asin(d / R));
    front = texU(q + dir * (d1 - d)); front.rgb *= mix(1.0, 0.75, d / R * p_golge / 100.0);
    back = backFace(q + dir * (d2 - d), mix(0.7, 1.0, d / R));
  }
  o = back.a > 0.01 ? overPre(back, front * (1.0 - back.a)) : front;
}
//== ripplepulse
uniform vec2 p_merkez; uniform float p_halkaIler, p_genlik, p_halkaGeni, p_yayilmaHizi, p_azalma, p_otomatikTekr;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 r = q - p_merkez; float d = length(r);
  float Rm = length(B) * 0.6; float prog = p_otomatikTekr > 0.5 ? fract(u_t * p_yayilmaHizi) : p_halkaIler / 100.0;
  float rr = prog * Rm; float w = max(p_halkaGeni, 1.0);
  float band = exp(-pow((d - rr) / w, 2.0)); float amp = p_genlik * (1.0 - prog * p_azalma / 100.0);
  vec2 dir = d > 0.001 ? r / d : vec2(0.0);
  o = texU(q - dir * sin((d - rr) / w * PI) * band * amp);
}
//== slant
uniform float p_egimAcis, p_yon, p_golge, p_golgeMesa; uniform vec2 p_dayanak; uniform vec3 c_golgeReng;
vec4 at(vec2 q) { vec2 r = q - p_dayanak; float t = tan(radians(clamp(p_egimAcis, -85.0, 85.0))); vec2 s = p_yon < 0.5 ? vec2(r.x - t * r.y, r.y) : vec2(r.x, r.y - t * r.x); return texU(p_dayanak + s); }
void main() {
  vec2 q = toUnit(here()); vec4 c = at(q);
  if (p_golge > 0.5) { float sa = at(q - vec2(p_golgeMesa) * 0.7071).a; c = overPre(c, vec4(c_golgeReng, 1.0) * sa * 0.85); }
  o = c;
}
//== smear
uniform vec2 p_baslangi, p_bitis; uniform float p_fircaYari, p_suruklem, p_yumusakl;
void main() {
  vec2 q = toUnit(here()); vec2 A = p_baslangi, Bp = p_bitis; vec2 ab = Bp - A; float L2 = max(dot(ab, ab), 1.0);
  float t = clamp(dot(q - A, ab) / L2, 0.0, 1.0); float dist = length(q - (A + ab * t));
  float R = max(p_fircaYari, 1.0); float w = 1.0 - smoothstep(R * (1.0 - p_yumusakl / 100.0) - 0.5, R, dist);
  o = texU(q - ab * t * w * p_suruklem / 100.0);
}
//== split
uniform vec2 p_yirtikMerk; uniform float p_aci, p_ayrilma, p_kenarPuru, p_tohum, p_yirtikGolg;
float side(vec2 p, vec2 d, vec2 n) { float s = dot(p - p_yirtikMerk, d); float j = (vnoise(vec2(s / 6.0, seedf(p_tohum))) - 0.5) * 2.0 * p_kenarPuru + (vnoise(vec2(s / 1.5, seedf(p_tohum) + 3.0)) - 0.5) * p_kenarPuru * 0.6; return dot(p - p_yirtikMerk, n) - j; }
void main() {
  vec2 q = toUnit(here()); float a = radians(p_aci); vec2 d = vec2(cos(a), sin(a)), n = vec2(-d.y, d.x); float h = p_ayrilma * 0.5;
  vec2 s1 = q - n * h, s2 = q + n * h; vec4 c = vec4(0.0);
  float e1 = side(s1, d, n), e2 = side(s2, d, n);
  if (e1 > 0.0) c = texU(s1); else if (e2 < 0.0) c = texU(s2);
  if (p_yirtikGolg > 0.5) { float g = 1.0 - smoothstep(0.0, 4.0, min(abs(e1), abs(e2))); c.rgb *= 1.0 - 0.35 * g * step(0.01, c.a); }
  o = c;
}
//== tiler
uniform float p_karoOlce, p_aci, p_ayna, p_bosluk, p_yalnizKatmAlan; uniform vec2 p_ofset;
void main() {
  vec2 B = boxU(); vec2 q = rot2(-p_aci) * (toUnit(here())) + p_ofset / 100.0 * B;
  if (p_yalnizKatmAlan > 0.5) { vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = vec4(0.0); return; } }
  vec2 cell = B * max(p_karoOlce / 100.0, 0.02); vec2 p = q + cell * 0.5;
  vec2 id = floor(p / cell); vec2 f = fract(p / cell);
  if (p_ayna > 0.5) { if (mod(id.x, 2.0) > 0.5) f.x = 1.0 - f.x; if (mod(id.y, 2.0) > 0.5) f.y = 1.0 - f.y; }
  vec2 g = p_bosluk / cell; vec2 f2 = (f - g * 0.5) / max(vec2(0.01), 1.0 - g);
  if (any(lessThan(f2, vec2(0.0))) || any(greaterThan(f2, vec2(1.0)))) { o = vec4(0.0); return; }
  o = texPx(boxPx(f2));
}
//== dispmap
uniform sampler2D s_haritaKatm; uniform float p_haritaKatmOn;
uniform float p_yatayKana, p_dikeyKana, p_yatayMikt, p_dikeyMikt, p_haritayiTersCevi, p_kenarModu;
float ch(vec4 c, float k) { vec3 u = unpre(c); return k < 0.5 ? u.r : k < 1.5 ? u.g : k < 2.5 ? u.b : k < 3.5 ? c.a : luma(u); }
void main() {
  vec2 b = boxUV(here());
  vec4 m = p_haritaKatmOn > 0.5 ? texture(s_haritaKatm, clamp(b, 0.0, 1.0)) : texPx(here());
  float kx = p_yatayKana; float ky = p_dikeyKana < 0.5 ? 1.0 : p_dikeyKana < 1.5 ? 0.0 : p_dikeyKana;
  vec2 v = vec2(ch(m, kx), ch(m, ky)); if (p_haritayiTersCevi > 0.5) v = 1.0 - v;
  vec2 B = boxU(); float mm = min(B.x, B.y) * 0.25;
  vec2 d = (v - 0.5) * 2.0 * vec2(p_yatayMikt, p_dikeyMikt) / 100.0 * mm;
  if (p_haritaKatmOn < 0.5 && m.a < 0.01) d = vec2(0.0);
  o = texEdge(fromUnit(toUnit(here()) - d), p_kenarModu < 0.5 ? 0.0 : p_kenarModu < 1.5 ? 1.0 : p_kenarModu < 2.5 ? 2.0 : 3.0);
}
//== warpstyle
uniform float p_stil, p_bukme, p_yatayBozu, p_dikeyBozu, p_yon; uniform vec2 p_merkez;
void main() {
  vec2 B = boxU(); vec2 p = (toUnit(here()) - p_merkez) / (B * 0.5);
  if (p_yon > 0.5) p = p.yx;
  float b = p_bukme / 100.0; float x = p.x, y = p.y; vec2 s = p;
  if (p_stil < 0.5) s.y = y + b * (1.0 - x * x) * 0.6;
  else if (p_stil < 1.5) s.y = y + b * (1.0 - x * x) * 0.6 * (1.0 - (y + 1.0) * 0.5);
  else if (p_stil < 2.5) s.y = y + b * 0.35 * sin(x * PI);
  else if (p_stil < 3.5) s.y = y / max(0.1, 1.0 + b * (1.0 - x * x) * 0.6);
  else if (p_stil < 4.5) { float r = length(p); s = p * (1.0 - b * 0.5 * max(0.0, 1.0 - r * r)); }
  else if (p_stil < 5.5) s.y = y + b * 0.3 * sin(x * TAU);
  else { float r = length(p); float a = b * PI * max(0.0, 1.0 - r); s = mat2(cos(a), sin(a), -sin(a), cos(a)) * p; }
  s.y /= max(0.1, 1.0 + p_yatayBozu / 100.0 * x * 0.6); s.x /= max(0.1, 1.0 + p_dikeyBozu / 100.0 * y * 0.6);
  if (p_yon > 0.5) s = s.yx;
  o = texU(p_merkez + s * B * 0.5);
}
//== opticscomp
uniform float p_gorusAcis, p_duzeltmeYonu, p_olcek, p_kenarKirp; uniform vec2 p_merkez;
void main() {
  vec2 B = boxU(); vec2 r = (toUnit(here()) - p_merkez) / (length(B) * 0.5); float d = length(r);
  float f = radians(clamp(p_gorusAcis, 1.0, 179.0)) * 0.5; float k = tan(f);
  float rs = p_duzeltmeYonu < 0.5 ? tan(d * f) / k : atan(d * k) / f;
  vec2 s = d > 1e-5 ? r / d * rs : r; s /= max(p_olcek / 100.0, 0.01);
  vec4 c = texU(p_merkez + s * length(B) * 0.5);
  if (p_kenarKirp > 0.5) { vec2 b = boxUV(fromUnit(p_merkez + s * length(B) * 0.5)); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) c = vec4(0.0); }
  o = c;
}
//== bender
uniform vec2 p_sabitUc, p_serbestUc; uniform float p_kavisAcis, p_kavisDagi, p_kalinligKoru;
void main() {
  vec2 q = toUnit(here()); vec2 A = p_sabitUc; vec2 ax = p_serbestUc - A; float L = max(length(ax), 1.0); vec2 d = ax / L; vec2 n = vec2(-d.y, d.x);
  float s = dot(q - A, d), m = dot(q - A, n);
  if (s <= 0.0) { o = texU(q); return; }
  // Bükülme kümülatif: açı s boyunca dağılır; geriye doğru yaklaşık ters eşleme (iteratif)
  float th = radians(p_kavisAcis); float ex = mix(0.4, 2.5, p_kavisDagi / 100.0);
  vec2 cur = A; float su = 0.0; vec2 best = q; float bd = 1e9; const int N = 48;
  for (int i = 0; i < N; i++) {
    float u = (float(i) + 0.5) / float(N); float ang = th * pow(u, ex);
    vec2 dd = d * cos(ang) + n * sin(ang); vec2 nn = vec2(-dd.y, dd.x);
    vec2 seg = cur + dd * (L / float(N)) * 0.5;
    vec2 rel = q - seg; float along = dot(rel, dd), perp = dot(rel, nn);
    float dist = abs(along) - L / float(N) * 0.5;
    float sc = max(dist, 0.0) + abs(perp) * 0.001;
    if (abs(along) <= L / float(N) * 0.5 + 0.01 && abs(perp) < bd) { bd = abs(perp); best = A + d * (u * L + along) + n * perp; }
    cur += dd * (L / float(N));
  }
  if (bd > 1e8) { // serbest ucun ötesi: son yönde düz devam
    float ang = th; vec2 dd = d * cos(ang) + n * sin(ang); vec2 nn = vec2(-dd.y, dd.x);
    vec2 rel = q - cur; float along = dot(rel, dd); if (along < 0.0) { o = vec4(0.0); return; } best = p_serbestUc + d * along + n * dot(rel, nn);
  }
  o = texU(best);
}
//== liquify
uniform float p_fircaModu, p_fircaBoyu, p_basinc, p_yogunluk, p_sertlik, p_agiDond;
void main() {
  vec2 q = toUnit(here()); float R = max(p_fircaBoyu, 1.0) * 1.6; float x = length(q) / R;
  float f = x < 1.0 ? pow(1.0 - x * x, mix(2.0, 0.6, p_sertlik / 100.0)) * (p_basinc / 100.0) * mix(0.4, 1.4, p_yogunluk / 100.0) : 0.0;
  vec2 s = q;
  if (p_agiDond > 0.5 || p_fircaModu > 4.5) s = q;
  else if (p_fircaModu < 0.5) s = q - vec2(R * 0.6 * f, 0.0);
  else if (p_fircaModu < 1.5) s = q * (1.0 + f * 0.9);
  else if (p_fircaModu < 2.5) s = rot2(-120.0 * f) * q;
  else if (p_fircaModu < 3.5) s = q * (1.0 - f * 0.6);
  else s = q * (1.0 + f * 0.6);
  o = texU(s);
}
//== viewer360
uniform float p_yatayBaki, p_dikeyBaki, p_yuvarlan, p_gorusAcis, p_projeksi, p_kenarYumu;
vec2 look(vec2 b) {
  vec2 B = boxU(); float asp = B.x / B.y; vec2 p = (b - 0.5) * 2.0 * vec2(asp, 1.0); float f = radians(clamp(p_gorusAcis, 10.0, 170.0)) * 0.5;
  vec3 dir;
  if (p_projeksi < 0.5) dir = normalize(vec3(p * tan(f), 1.0));
  else { float r = length(p) * f; vec2 u = length(p) > 1e-5 ? normalize(p) : vec2(0.0); dir = vec3(u * sin(r), cos(r)); }
  float ro = radians(p_yuvarlan), pi_ = radians(p_dikeyBaki), ya = radians(p_yatayBaki);
  dir.xy = mat2(cos(ro), sin(ro), -sin(ro), cos(ro)) * dir.xy;
  dir.yz = mat2(cos(pi_), sin(pi_), -sin(pi_), cos(pi_)) * dir.yz;
  dir.xz = mat2(cos(ya), -sin(ya), sin(ya), cos(ya)) * dir.xz;
  return vec2(atan(dir.x, dir.z) / TAU + 0.5, asin(clamp(dir.y, -1.0, 1.0)) / PI + 0.5);
}
void main() {
  vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = vec4(0.0); return; }
  vec2 s = look(b); s.x = fract(s.x);
  o = texPx(boxPx(clamp(s, 0.001, 0.999)));
}
//== curl
uniform float p_sabitKena, p_kivrimIler, p_kivrimYari, p_aci, p_golge, p_arkaYuz; uniform vec3 c_arkaRenk;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU();
  vec2 dir = p_sabitKena < 0.5 ? vec2(1, 0) : p_sabitKena < 1.5 ? vec2(-1, 0) : p_sabitKena < 2.5 ? vec2(0, 1) : vec2(0, -1);
  dir = rot2(p_aci) * dir; float span = abs(dot(B, abs(dir)));
  vec2 P = -dir * span * 0.5 + dir * span * (1.0 - p_kivrimIler / 100.0);
  float R = max(p_kivrimYari, 1.0); float d = dot(q - P, dir);
  vec4 front = vec4(0.0), back = vec4(0.0);
  if (d < 0.0) { front = texU(q); vec4 s = texU(q + dir * (PI * R - 2.0 * d)); if (s.a > 0.01) back = pre(p_arkaYuz > 0.5 ? c_arkaRenk * 0.92 : unpre(s) * 0.8, s.a);
    front.rgb *= 1.0 - p_golge / 100.0 * 0.5 * (1.0 - smoothstep(0.0, R, -d)); }
  else if (d < R) { float d1 = R * asin(d / R), d2 = R * (PI - asin(d / R)); front = texU(q + dir * (d1 - d)); front.rgb *= mix(1.0, 0.7, d / R * p_golge / 100.0);
    vec4 s = texU(q + dir * (d2 - d)); if (s.a > 0.01) back = pre((p_arkaYuz > 0.5 ? c_arkaRenk : unpre(s)) * mix(0.65, 1.0, d / R), s.a); }
  o = back.a > 0.01 ? overPre(back, front * (1.0 - back.a)) : front;
}
//== graddisp
uniform vec2 p_baslangi, p_bitis, p_yerDegi; uniform float p_gecisTuru, p_tersCevi;
void main() {
  vec2 q = toUnit(here()); vec2 ab = p_bitis - p_baslangi; float w;
  if (p_gecisTuru < 0.5) w = clamp(dot(q - p_baslangi, ab) / max(dot(ab, ab), 1.0), 0.0, 1.0);
  else w = clamp(length(q - p_baslangi) / max(length(ab), 1.0), 0.0, 1.0);
  w = smoothstep(0.0, 1.0, w); if (p_tersCevi > 0.5) w = 1.0 - w;
  o = texU(q - p_yerDegi / 100.0 * boxU() * w);
}
//== innerbulge
uniform vec2 p_merkez; uniform float p_yaricap, p_sisirme, p_kenarKoru, p_dusus, p_alfayiKoru;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float R = max(p_yaricap, 1.0); float x = length(r) / R;
  float f = x < 1.0 ? pow(1.0 - x * x, mix(0.5, 2.0, p_dusus / 100.0)) : 0.0;
  float k = p_kenarKoru; float m = 1.0;
  if (k > 0.01) { for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; m = min(m, texU(q + vec2(cos(a), sin(a)) * k).a); } }
  vec4 s = texU(p_merkez + r * (1.0 - p_sisirme / 100.0 * 0.65 * f * m));
  if (p_alfayiKoru > 0.5) s = pre(unpre(s), texU(q).a);
  o = s;
}
//== ominoglass
uniform sampler2D s_dokuKatm; uniform float p_dokuKatmOn;
uniform float p_kirilma, p_prizmaAyri, p_dokuOlce, p_camKali, p_kenarYumu, p_tersHari;
void main() {
  vec2 q = toUnit(here()); float s = max(p_dokuOlce, 2.0);
  vec2 nrm;
  if (p_dokuKatmOn > 0.5) { vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec2 e = 2.0 / u_box.zw;
    float hx = luma(unpre(texture(s_dokuKatm, b + vec2(e.x, 0.0)))) - luma(unpre(texture(s_dokuKatm, b - vec2(e.x, 0.0))));
    float hy = luma(unpre(texture(s_dokuKatm, b + vec2(0.0, e.y)))) - luma(unpre(texture(s_dokuKatm, b - vec2(0.0, e.y)))); nrm = vec2(hx, hy) * 4.0; }
  else {
    // omino karoları: farklı boy kare bloklar, her biri eğik bir cam yüzeyi
    vec2 id = floor(q / s); float big = step(0.6, hash1(floor(id / 2.0) + 3.1));
    vec2 cid = big > 0.5 ? floor(id / 2.0) * 2.0 : id; vec2 cs = vec2(big > 0.5 ? 2.0 * s : s);
    vec2 f = (q - cid * s) / cs; vec2 r = hash2(cid + 11.0) - 0.5;
    float edge = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)); float bev = smoothstep(0.0, max(p_camKali, 0.5) / cs.x, edge);
    nrm = r * 0.8 + (1.0 - bev) * (f - 0.5) * 2.0 * (p_kenarYumu > 0.0 ? 1.0 : 1.5);
  }
  if (p_tersHari > 0.5) nrm = -nrm;
  vec2 dd = nrm * p_kirilma; vec2 pa = nrm * p_prizmaAyri;
  vec4 g = texU(q + dd);
  o = vec4(texU(q + dd + pa).r, g.g, texU(q + dd - pa).b, max(g.a, texU(q).a * 0.0 + g.a));
}
//== polardisp
uniform sampler2D s_haritaKatm; uniform float p_haritaKatmOn;
uniform vec2 p_merkez; uniform float p_radyalMikt, p_acisalMikt, p_haritaKana, p_tersCevi, p_kenarModu;
void main() {
  vec2 q = toUnit(here()); vec4 m = p_haritaKatmOn > 0.5 ? texture(s_haritaKatm, clamp(boxUV(here()), 0.0, 1.0)) : texU(q);
  float v = p_haritaKana < 0.5 ? luma(unpre(m)) : p_haritaKana < 1.5 ? m.a : unpre(m).r; if (p_tersCevi > 0.5) v = 1.0 - v;
  if (p_haritaKatmOn < 0.5 && m.a < 0.01) { o = m; return; }
  vec2 r = q - p_merkez; float k = (v - 0.5) * 2.0;
  vec2 s = p_merkez + rot2(-p_acisalMikt * k) * r / max(0.05, 1.0 + p_radyalMikt / 100.0 * k * 0.5);
  o = texEdge(fromUnit(s), p_kenarModu < 0.5 ? 2.0 : p_kenarModu < 1.5 ? 0.0 : 1.0);
}
//== vrcombined
uniform float p_yatayBaki, p_dikeyBaki, p_yuvarlan, p_gorusAcis, p_renkSaca, p_projeksi, p_kenarYumu;
vec2 look(vec2 b, float fovAdd) {
  vec2 B = boxU(); float asp = B.x / B.y; vec2 p = (b - 0.5) * 2.0 * vec2(asp, 1.0); float f = radians(clamp(p_gorusAcis + fovAdd, 10.0, 170.0)) * 0.5;
  vec3 dir;
  if (p_projeksi < 0.5) dir = normalize(vec3(p * tan(f), 1.0));
  else { float r = length(p) * f; vec2 u = length(p) > 1e-5 ? normalize(p) : vec2(0.0); dir = vec3(u * sin(r), cos(r)); }
  float ro = radians(p_yuvarlan), pi_ = radians(p_dikeyBaki), ya = radians(p_yatayBaki);
  dir.xy = mat2(cos(ro), sin(ro), -sin(ro), cos(ro)) * dir.xy;
  dir.yz = mat2(cos(pi_), sin(pi_), -sin(pi_), cos(pi_)) * dir.yz;
  dir.xz = mat2(cos(ya), -sin(ya), sin(ya), cos(ya)) * dir.xz;
  return vec2(fract(atan(dir.x, dir.z) / TAU + 0.5), asin(clamp(dir.y, -1.0, 1.0)) / PI + 0.5);
}
void main() {
  vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = vec4(0.0); return; }
  float ca = p_renkSaca * 0.15;
  vec4 g = texPx(boxPx(clamp(look(b, 0.0), 0.001, 0.999)));
  o = vec4(texPx(boxPx(clamp(look(b, ca), 0.001, 0.999))).r, g.g, texPx(boxPx(clamp(look(b, -ca), 0.001, 0.999))).b, g.a);
}
