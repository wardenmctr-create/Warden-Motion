// Prosedürel (rehberdeki ayarlar). Desenler katmanın dolu kısmına çizilir (genOver).
//== checker
uniform float p_kareBoyu, p_aci, p_kareleriBagl; uniform vec2 p_ofset; uniform vec3 c_renk1, c_renk2; uniform float a_renk1, a_renk2;
void main() {
  vec2 p = rot2(-p_aci) * toUnit(here()) + p_ofset / 100.0 * boxU(); float s = max(p_kareBoyu, 1.0);
  vec2 f = p / s; float k = mod(floor(f.x) + floor(f.y), 2.0);
  vec2 e = abs(fract(f) - 0.5); float aa = 1.0 - smoothstep(0.5 - 1.0 / (s * u_s), 0.5, max(e.x, e.y)) * 0.0;
  o = genOver(k < 0.5 ? colA(c_renk1, a_renk1) : colA(c_renk2, a_renk2));
}
//== stripes
uniform float p_seritGeni, p_bosluk, p_aci, p_faz, p_hiz, p_kenarGeci; uniform vec3 c_renk1, c_renk2; uniform float a_renk1, a_renk2;
void main() {
  vec2 p = rot2(-p_aci) * toUnit(here()); float per = max(p_seritGeni + p_bosluk, 1.0);
  float x = mod(p.x + p_faz / 100.0 * per + u_t * p_hiz * per, per);
  float w = max(p_kenarGeci / 100.0 * per * 0.25, 0.6 / u_s);
  float k = smoothstep(p_seritGeni - w, p_seritGeni + w, x) * (1.0 - smoothstep(per - w, per + w * 0.0, x));
  if (x < w) k = 1.0 - smoothstep(-w, w, x);
  o = genOver(mix(colA(c_renk1, a_renk1), colA(c_renk2, a_renk2), k));
}
//== grid
uniform float p_yatayAral, p_dikeyAral, p_cizgiKali, p_aci, p_araliklaBagl; uniform vec2 p_ofset; uniform vec3 c_cizgiReng, c_arkaPlan; uniform float a_cizgiReng, a_arkaPlan;
void main() {
  vec2 p = rot2(-p_aci) * toUnit(here()) + p_ofset / 100.0 * boxU(); vec2 sp = vec2(max(p_yatayAral, 1.0), max(p_araliklaBagl > 0.5 ? p_yatayAral : p_dikeyAral, 1.0));
  vec2 d = abs(fract(p / sp + 0.5) - 0.5) * sp; float w = p_cizgiKali * 0.5; float px = 0.7 / u_s;
  float l = max(1.0 - smoothstep(w - px, w + px, d.x), 1.0 - smoothstep(w - px, w + px, d.y));
  o = genOver(mix(colA(c_arkaPlan, a_arkaPlan), colA(c_cizgiReng, a_cizgiReng), l));
}
//== dots
uniform float p_noktaBoyu, p_noktaAral, p_faz, p_dizilim, p_boyutRast; uniform vec2 p_ofset; uniform vec3 c_renk1, c_renk2;
void main() {
  vec2 p = toUnit(here()) + p_ofset / 100.0 * boxU(); float sp = max(p_noktaAral, 1.0); vec2 c; vec2 id;
  if (p_dizilim > 0.5) { vec4 h = hexGrid(p, sp); c = h.xy; id = h.zw; } else { id = floor(p / sp); c = (id + 0.5) * sp; }
  float r = p_noktaBoyu * 0.5 * (1.0 + (hash1(id) - 0.5) * 2.0 * p_boyutRast / 100.0) * (0.85 + 0.15 * sin(p_faz / 100.0 * TAU + id.x * 0.7));
  float k = 1.0 - smoothstep(r - 0.7 / u_s, r + 0.7 / u_s, length(p - c));
  o = genOver(mix(vec4(c_renk2, 1.0), vec4(c_renk1, 1.0), k));
}
//== noise
uniform float p_miktar, p_grenBoyu, p_tur, p_kontrast, p_tohum, p_zamanaBagl, p_alfayiEtki;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 g = floor(toUnit(here()) / max(p_grenBoyu, 0.3)); float tk = p_zamanaBagl > 0.5 ? floor(u_t * 24.0) : 0.0; float sd = seedf(p_tohum);
  vec3 n = p_tur < 0.5 ? vec3(hash1(g + sd + tk), hash1(g + sd + tk + 31.0), hash1(g + sd + tk + 67.0)) : vec3(hash1(g + sd + tk));
  if (p_tur > 1.5) n = vec3(0.5 + (vnoise(g * 0.7 + tk * 13.0) - 0.5) * 1.4);
  n = (n - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5;
  vec3 c = unpre(s); vec3 r = mix(c, p_tur > 1.5 ? overlayB(c, n) : n, p_miktar / 100.0);
  float a = p_alfayiEtki > 0.5 ? max(s.a, p_miktar / 100.0 * n.r) : s.a;
  o = pre(clamp(r, 0.0, 1.0), a);
}
//== clouds
uniform float p_bulutOlce, p_ayrinti, p_kontrast, p_evrim, p_hiz, p_tohum; uniform vec2 p_ofset; uniform vec3 c_renk1, c_renk2;
void main() {
  vec2 p = (toUnit(here()) + p_ofset / 100.0 * boxU()) / max(p_bulutOlce, 1.0) + seedf(p_tohum) + vec2(u_t * p_hiz, 0.0);
  float n = fbm(p + vec2(0.0, p_evrim * 0.03), p_ayrinti - 1.0) * 0.5 + 0.5; n = clamp((n - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5, 0.0, 1.0);
  o = genOver(vec4(mix(c_renk1, c_renk2, smoothstep(0.25, 0.85, n)), 1.0));
}
//== blocknoise
uniform float p_blokBoyu, p_renkCesi, p_yogunluk, p_yenilenm, p_tohum, p_tekRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 id = floor(toUnit(here()) / max(p_blokBoyu, 1.0)); float tk = floor(u_t * p_yenilenm); float sd = seedf(p_tohum);
  float on = step(hash1(id + tk * 7.1 + sd), p_yogunluk / 100.0);
  vec3 c = p_tekRenk > 0.5 ? vec3(hash1(id + tk + sd + 3.0)) : mix(vec3(hash1(id + tk + 1.0)), hsv2rgb(vec3(hash1(id + tk + 5.0 + sd), 0.9, 0.95)), p_renkCesi / 100.0);
  o = genOver(vec4(c, 1.0) * on);
}
//== ridges
GRADIENT(renkGeci)
uniform float p_olcek, p_ayrinti, p_sirtKesk, p_kontrast, p_evrim, p_tohum;
void main() {
  vec2 p = toUnit(here()) / max(p_olcek, 1.0) + seedf(p_tohum) + p_evrim * 0.02; float s = 0.0, a = 0.5, n = 0.0;
  for (int i = 0; i < 10; i++) { if (float(i) >= p_ayrinti) break; float r = 1.0 - abs(pnoise(p)); r = pow(r, mix(1.0, 4.0, p_sirtKesk / 100.0)); s += r * a; n += a; p = p * 2.03 + 11.0; a *= 0.5; }
  float v = clamp((s / n - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5, 0.0, 1.0);
  o = genOver(vec4(grad_renkGeci(v), 1.0));
}
//== hexarray
uniform float p_altigenBoyu, p_aralik, p_aci, p_konturKali, p_yalnizKont; uniform vec2 p_ofset; uniform vec3 c_dolgu, c_kontur;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()) + p_ofset / 100.0 * boxU(); float sz = max(p_altigenBoyu, 2.0);
  vec4 h = hexGrid(q, sz); float d = hexDist((q - h.xy) / sz) * sz; float edge = sz * 0.5 - p_aralik * 0.5; float px = 0.7 / u_s;
  float inside = 1.0 - smoothstep(edge - px, edge + px, d); float ring = inside * smoothstep(edge - p_konturKali - px, edge - p_konturKali + px, d);
  float cov = texU(rot2(p_aci) * (h.xy - p_ofset / 100.0 * boxU())).a; // hücre merkezi doluysa
  vec4 c = vec4(0.0); if (p_yalnizKont < 0.5) c = vec4(c_dolgu, 1.0) * inside; c = mix(c, vec4(c_kontur, 1.0), ring * step(0.01, p_konturKali));
  o = c * step(0.5, cov) + vec4(0.0);
}
//== hexcells
uniform float p_hucreBoyu, p_yanmaOran, p_hiz, p_gecis, p_tohum, p_kontur; uniform vec3 c_renk1, c_renk2;
void main() {
  vec2 q = toUnit(here()); float sz = max(p_hucreBoyu, 2.0); vec4 h = hexGrid(q, sz); float r = hash1(h.zw + seedf(p_tohum));
  float ph = fract(u_t * p_hiz * 0.5 + r); float lit = smoothstep(1.0 - p_yanmaOran / 100.0 - p_gecis / 200.0, 1.0 - p_yanmaOran / 100.0 + p_gecis / 200.0 + 0.001, 0.5 + 0.5 * sin(ph * TAU));
  vec3 c = mix(c_renk1, c_renk2, lit); float d = hexDist((q - h.xy) / sz);
  if (p_kontur > 0.5) c = mix(c, c_renk2, smoothstep(0.44, 0.48, d) * 0.8);
  o = genOver(vec4(c, 1.0));
}
//== iridescence
GRADIENT(renkPale)
uniform float p_olcek, p_faz, p_hiz, p_yansimaGucu, p_kontrast;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 p = toUnit(here()) / max(p_olcek, 1.0);
  float n = fbm(p + vec2(u_t * p_hiz, -u_t * p_hiz * 0.7), 3.0); float th = fract(n * 1.5 + luma(unpre(s)) * 0.6 + p_faz / 100.0 + u_t * p_hiz * 0.3);
  vec3 ir = grad_renkPale(th); ir = conAdj(ir, 1.0 + p_kontrast / 100.0, 0.5);
  vec3 c = mix(unpre(s), screenB(unpre(s), ir), p_yansimaGucu / 100.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
//== lensflare
uniform vec2 p_isikKonu; uniform float p_parlakli, p_olcek, p_mercekTipi, p_hale, p_yansimal, p_yalnizParl; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float S = max(p_olcek / 100.0, 0.01) * min(boxU().x, boxU().y); vec2 L = p_isikKonu; vec2 r = (q - L) / S;
  float d = length(r); float k = p_parlakli / 100.0;
  vec3 c = c_renk * (exp(-d * 18.0) * 2.0 + exp(-d * 4.0) * 0.5 * p_hale / 100.0);
  if (p_mercekTipi > 0.5 && p_mercekTipi < 1.5) c += vec3(0.4, 0.6, 1.0) * exp(-abs(r.y) * 60.0) * exp(-abs(r.x) * 1.5) * 1.2;
  else c += c_renk * pow(max(0.0, cos(atan(r.y, r.x) * 6.0)), 30.0) * exp(-d * 6.0) * 0.6;
  if (p_mercekTipi > 1.5) c += vec3(0.9, 0.7, 1.0) * exp(-abs(d - 0.35) * 60.0) * 0.4;
  if (p_yansimal > 0.5) { vec2 axis = -L / S; for (int i = 1; i <= 5; i++) { float t = float(i) * 0.38; vec2 g = L / S + axis * t * 2.0; float gd = length(q / S - g); float rs = 0.03 + 0.03 * float(i % 3);
      vec3 col = hsv2rgb(vec3(fract(0.1 * float(i) + 0.55), 0.6, 1.0)); c += col * (1.0 - smoothstep(rs * 0.8, rs, gd)) * 0.18; } }
  c *= k;
  if (p_yalnizParl > 0.5) { o = vec4(c, clamp(max(c.r, max(c.g, c.b)), 0.0, 1.0)); return; }
  o = vec4(min(s.rgb + c * (1.0 - s.rgb * 0.3), vec3(1.0)), max(s.a, clamp(max(c.r, max(c.g, c.b)), 0.0, 1.0)));
}
//== lightning
uniform vec2 p_baslangi, p_bitis; uniform float p_cizgiKali, p_dallanma, p_kivrim, p_hale, p_yenilenm, p_tohum; uniform vec3 c_renk;
float bolt(vec2 q, vec2 A, vec2 B, float sd, float amp) {
  vec2 ab = B - A; float L = max(length(ab), 1.0); vec2 d = ab / L, n = vec2(-d.y, d.x); float t = clamp(dot(q - A, d) / L, 0.0, 1.0);
  float off = (fbm(vec2(t * 6.0, sd), 4.0)) * amp * sin(t * PI); return abs(dot(q - A, n) - off) + max(0.0, abs(dot(q - A, d) / L - 0.5) - 0.5) * L;
}
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float sd = seedf(p_tohum) + floor(u_t * p_yenilenm) * 3.7;
  float d = bolt(q, p_baslangi, p_bitis, sd, p_kivrim * 2.0);
  // dallar
  for (int i = 0; i < 3; i++) { if (hash1(vec2(float(i), sd)) > p_dallanma / 100.0) continue; float t0 = 0.2 + 0.2 * float(i); vec2 P = mix(p_baslangi, p_bitis, t0);
    vec2 ab = p_bitis - p_baslangi; vec2 E = P + rot2((hash1(vec2(sd, float(i))) - 0.5) * 120.0) * ab * 0.35; d = min(d, bolt(q, P, E, sd + float(i) * 9.0, p_kivrim) * 1.4); }
  float w = p_cizgiKali * 0.5; float core = 1.0 - smoothstep(w * 0.4, w, d); float glow = exp(-d / max(p_hale * 0.5, 0.5)) * 0.8;
  float fl = 0.6 + 0.4 * step(0.3, hash1(vec2(floor(u_t * 20.0), sd)));
  vec3 c = (mix(c_renk, vec3(1.0), core) * core + c_renk * glow) * fl;
  o = vec4(min(s.rgb + c, vec3(1.0)), max(s.a, clamp(core + glow, 0.0, 1.0) * fl));
}
//== rays
uniform vec2 p_merkez; uniform float p_isinSayi, p_isinGeni, p_aci, p_hiz, p_merkezYumu; uniform vec3 c_renk1, c_renk2; uniform float a_renk1, a_renk2;
void main() {
  vec2 r = toUnit(here()) - p_merkez; float a = atan(r.y, r.x) - radians(p_aci) - u_t * p_hiz * TAU;
  float n = max(2.0, floor(p_isinSayi)); float f = fract(a / TAU * n); float w = p_isinGeni / 100.0;
  float k = smoothstep(0.0, 0.02, f) * (1.0 - smoothstep(w - 0.02, w, f));
  float cm = smoothstep(0.0, max(p_merkezYumu / 100.0 * min(boxU().x, boxU().y) * 0.5, 0.5), length(r)); k *= cm;
  o = genOver(mix(colA(c_renk2, a_renk2), colA(c_renk1, a_renk1), k));
}
//== ribbon
GRADIENT(renkGeci)
uniform vec2 p_baslangi, p_bitis; uniform float p_kurdeleGeni, p_dalgaYuks, p_dalgaBoyu, p_hiz, p_parlama;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 ab = p_bitis - p_baslangi; float L = max(length(ab), 1.0); vec2 d = ab / L, n = vec2(-d.y, d.x);
  float t = dot(q - p_baslangi, d); float y = dot(q - p_baslangi, n);
  float ph = t / max(p_dalgaBoyu, 1.0) * TAU - u_t * p_hiz * TAU; float cy = sin(ph) * p_dalgaYuks; float tw = cos(ph * 0.5 + u_t * p_hiz);
  float hw = p_kurdeleGeni * 0.5 * (0.35 + 0.65 * abs(tw)); float k = 1.0 - smoothstep(hw - 0.8, hw + 0.8, abs(y - cy));
  k *= step(-5.0, t) * step(t, L + 5.0);
  vec3 c = grad_renkGeci(clamp(t / L, 0.0, 1.0)) * (0.75 + 0.25 * tw) + pow(max(0.0, 1.0 - abs(y - cy) / max(hw, 0.5)), 6.0) * p_parlama / 100.0;
  o = overPre(vec4(c, 1.0) * k, s);
}
//== starfield
uniform float p_yildizSayi, p_hiz, p_yildizBoyu, p_derinlik, p_izler, p_izUzun, p_tohum; uniform vec2 p_merkez; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_merkez; float R = length(boxU()) * 0.5; vec2 p = q / R;
  float acc = 0.0; float layers = 4.0; float dens = sqrt(clamp(p_yildizSayi, 10.0, 5000.0) / 300.0);
  for (int l = 0; l < 4; l++) { float z = fract(float(l) / layers - u_t * p_hiz * 0.15); float sc = mix(18.0, 1.0, z) * dens; vec2 g = p * sc; vec2 id = floor(g);
    for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 cid = id + vec2(float(i), float(j)); vec2 sp = (cid + hash2(cid + float(l) * 17.0 + seedf(p_tohum))) / sc;
      if (hash1(cid + float(l)) > 0.6) continue; float rad = p_yildizBoyu / R * mix(0.3, 1.6, z) * 0.5; vec2 dv = p - sp;
      if (p_izler > 0.5) { vec2 dir = normalize(sp + 1e-4); float u = clamp(dot(dv, dir), -p_izUzun / R * z, 0.0); dv -= dir * u; }
      float b = (1.0 - smoothstep(rad * 0.3, rad, length(dv))) * mix(1.0 - p_derinlik / 100.0, 1.0, z) * smoothstep(0.0, 0.15, z) * smoothstep(1.0, 0.85, z); acc = max(acc, b); } }
  o = overPre(vec4(c_renk, 1.0) * acc, s);
}
//== star
uniform vec2 p_merkez; uniform float p_boyut, p_ucSayi, p_icYari, p_aci, p_hale, p_titreme; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 r = rot2(-p_aci) * (toUnit(here()) - p_merkez) / max(p_boyut * 0.5, 1.0);
  float n = max(3.0, floor(p_ucSayi)); float a = atan(r.y, r.x); float d = length(r);
  float spike = pow(abs(cos(a * n * 0.5)), mix(2.0, 40.0, 1.0 - p_icYari / 100.0)); float shape = 1.0 - smoothstep(0.0, 1.0, d / mix(0.08, 1.0, spike));
  float fl = 1.0 + 0.25 * sin(u_t * p_titreme * TAU) * step(0.01, p_titreme);
  float glow = exp(-d * max(p_boyut * 0.5, 1.0) / max(p_hale, 0.5)) * 0.7;
  float k = clamp((shape + glow) * fl, 0.0, 1.0);
  o = vec4(min(s.rgb + c_renk * k, vec3(1.0)), max(s.a, k));
}
//== plasma
GRADIENT(palet)
uniform float p_olcek, p_hiz, p_faz, p_ayrinti, p_kontrast, p_tohum;
void main() {
  vec2 p = toUnit(here()) / max(p_olcek, 1.0) + seedf(p_tohum); float t = u_t * p_hiz * 2.0 + p_faz / 100.0 * TAU;
  float v = sin(p.x * 3.0 + t) + sin((p.y * 3.0 + t) * 0.8) + sin((p.x + p.y) * 2.5 + t * 1.3) + sin(length(p - vec2(sin(t * 0.3), cos(t * 0.4))) * 4.0) + fbm(p + t * 0.1, p_ayrinti - 1.0) * 2.0;
  float x = fract(v * 0.15 + 0.5); x = clamp((x - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5, 0.0, 1.0);
  o = genOver(vec4(grad_palet(x), 1.0));
}
//== beam
uniform vec2 p_baslangi, p_bitis; uniform float p_basKali, p_sonKali, p_yumusakl, p_uzunluk, p_yalnizIsin; uniform vec3 c_cekirdekReng, c_disRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = mix(p_baslangi, p_bitis, p_uzunluk / 100.0); vec2 ab = B - p_baslangi; float L2 = max(dot(ab, ab), 1.0);
  float t = clamp(dot(q - p_baslangi, ab) / L2, 0.0, 1.0); float d = length(q - (p_baslangi + ab * t)); float w = mix(p_basKali, p_sonKali, t) * 0.5;
  float core = 1.0 - smoothstep(w * 0.4, w, d); float glow = exp(-max(d - w * 0.5, 0.0) / max(p_yumusakl * 0.5, 0.5));
  vec3 c = c_cekirdekReng * core + c_disRenk * glow * (1.0 - core * 0.5); float a = clamp(core + glow, 0.0, 1.0);
  o = p_yalnizIsin > 0.5 ? vec4(min(c, vec3(1.0)), a) : vec4(min(s.rgb + c, vec3(1.0)), max(s.a, a));
}
//== radiowaves
uniform vec2 p_merkez; uniform float p_halkaSayi, p_yayilmaHizi, p_halkaKali, p_enBuyuYari, p_solma, p_dongu; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); float d = length(toUnit(here()) - p_merkez); float n = max(1.0, floor(p_halkaSayi)); float R = max(p_enBuyuYari, 1.0); float acc = 0.0;
  for (int i = 0; i < 32; i++) { if (float(i) >= n) break; float ph = u_t * p_yayilmaHizi * 0.5 + float(i) / n; if (p_dongu > 0.5) ph = fract(ph); else if (ph > 1.0) continue;
    float rr = ph * R; float k = 1.0 - smoothstep(p_halkaKali * 0.5 - 0.7, p_halkaKali * 0.5 + 0.7, abs(d - rr)); acc = max(acc, k * (1.0 - ph * p_solma / 100.0)); }
  o = overPre(vec4(c_renk, 1.0) * acc, s);
}
//== circlefx
uniform vec2 p_merkez; uniform float p_yaricap, p_konturKali, p_kenarGeci, p_yalnizHalk; uniform vec3 c_dolgu, c_kontur;
void main() {
  vec4 s = texture(u_tex, v_uv); float d = length(toUnit(here()) - p_merkez) - p_yaricap; float w = max(p_kenarGeci, 0.6 / u_s);
  float fill = 1.0 - smoothstep(-w, w, d); float ring = (1.0 - smoothstep(p_konturKali - w, p_konturKali + w, abs(d + p_konturKali * 0.5))) * step(0.01, p_konturKali);
  vec4 c = p_yalnizHalk > 0.5 ? vec4(0.0) : vec4(c_dolgu, 1.0) * fill; c = mix(c, vec4(c_kontur, 1.0), ring);
  o = overPre(c, s);
}
//== ellipsefx
uniform vec2 p_merkez; uniform float p_yatayYari, p_dikeyYari, p_aci, p_kalinlik, p_hale, p_kesikYay, p_yayUzun; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 r = rot2(-p_aci) * (toUnit(here()) - p_merkez); vec2 R = vec2(max(p_yatayYari, 1.0), max(p_dikeyYari, 1.0));
  float k = length(r / R); float d = abs(k - 1.0) * min(R.x, R.y);
  float core = 1.0 - smoothstep(p_kalinlik * 0.5 - 0.7, p_kalinlik * 0.5 + 0.7, d); float glow = exp(-d / max(p_hale * 0.5, 0.5)) * 0.7;
  if (p_kesikYay > 0.5) { float a = degrees(atan(r.y / R.y, r.x / R.x)); a = mod(a + 360.0, 360.0); if (a > abs(p_yayUzun)) { core = 0.0; glow = 0.0; } }
  float a2 = clamp(core + glow, 0.0, 1.0);
  o = vec4(min(s.rgb + mix(c_renk, vec3(1.0), core * 0.4) * a2, vec3(1.0)), max(s.a, a2));
}
//== threads
uniform float p_iplikGeni, p_aralik, p_aci, p_dokumaDeri, p_yatayDikeBagl; uniform vec3 c_renk1, c_renk2;
void main() {
  vec2 p = rot2(-p_aci) * toUnit(here()); float per = max(p_iplikGeni + p_aralik, 1.0); vec2 f = mod(p, per); vec2 id = floor(p / per);
  float h = 1.0 - smoothstep(p_iplikGeni - 0.7, p_iplikGeni, f.y), v = 1.0 - smoothstep(p_iplikGeni - 0.7, p_iplikGeni, f.x);
  bool over = mod(id.x + id.y, 2.0) < 0.5;
  float sh = p_dokumaDeri / 100.0;
  vec3 hc = c_renk1 * (1.0 - sh * 0.6 * pow(abs(f.y / max(p_iplikGeni, 0.1) - 0.5) * 2.0, 2.0)) * (over ? 1.0 : 1.0 - sh * 0.4);
  vec3 vc = c_renk2 * (1.0 - sh * 0.6 * pow(abs(f.x / max(p_iplikGeni, 0.1) - 0.5) * 2.0, 2.0)) * (over ? 1.0 - sh * 0.4 : 1.0);
  vec4 c = vec4(0.0); if (over) { c = mix(c, vec4(vc, 1.0), v); c = mix(c, vec4(hc, 1.0), h); } else { c = mix(c, vec4(hc, 1.0), h); c = mix(c, vec4(vc, 1.0), v); }
  o = genOver(c);
}
//== fireworks
GRADIENT(renkler)
uniform vec2 p_patlamaMerk; uniform float p_parcacikSayi, p_yayilma, p_omur, p_yercekim, p_izUzun, p_patlamaAral, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float per = max(p_patlamaAral, 0.2); vec3 acc = vec3(0.0);
  for (int b = 0; b < 3; b++) { float tb = u_t - float(b) * per * 0.33; float k = floor(tb / per); float lt = tb - k * per; if (lt > p_omur || tb < 0.0) continue;
    float sd = seedf(p_tohum) + k * 7.0 + float(b) * 13.0; vec2 C = p_patlamaMerk + (hash2(vec2(sd, 1.0)) - 0.5) * boxU() * 0.5 * step(0.5, float(b));
    vec3 col = palc_renkler(int(hash1(vec2(sd, 3.0)) * float(paln_renkler())) % paln_renkler()); float life = lt / max(p_omur, 0.05);
    int N = int(clamp(p_parcacikSayi, 10.0, 160.0));
    for (int i = 0; i < 160; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), sd)); float a = h.x * TAU; float sp = sqrt(h.y);
      vec2 pos = C + vec2(cos(a), sin(a)) * p_yayilma * sp * (1.0 - pow(1.0 - min(life * 1.5, 1.0), 3.0)) + vec2(0.0, p_yercekim * 0.5 * lt * lt);
      float d = length(q - pos); acc += col * (1.0 - life) * (exp(-d * d / 4.0) * 1.2 + exp(-d / max(p_izUzun * 0.15, 0.5)) * 0.08); } }
  float a = clamp(max(acc.r, max(acc.g, acc.b)), 0.0, 1.0);
  o = vec4(min(s.rgb + acc, vec3(1.0)), max(s.a, a));
}
//== heartrain
GRADIENT(renkler)
uniform float p_kalpSayi, p_boyut, p_hiz, p_yon, p_donusHizi, p_rastgele, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec2 dir = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec4 acc = vec4(0.0);
  int N = int(clamp(p_kalpSayi, 1.0, 80.0));
  for (int i = 0; i < 80; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum))); float sz = p_boyut * mix(1.0, 0.5 + h.y, p_rastgele / 100.0);
    float span = dot(B, abs(dir)) + sz * 2.0; float tpos = fract(h.x * 3.7 + u_t * p_hiz / span * mix(1.0, 0.6 + h.y * 0.8, p_rastgele / 100.0));
    vec2 perp = vec2(-dir.y, dir.x); vec2 c = perp * (h.x - 0.5) * dot(B, abs(perp)) + dir * (tpos - 0.5) * span + perp * sin(u_t * 1.5 + float(i)) * sz * 0.4;
    vec2 r = rot2(-p_donusHizi * u_t * (h.y - 0.5) * 2.0) * (q - c) / max(sz, 0.5); float d = heartSDF(r);
    float k = 1.0 - smoothstep(-0.02, 0.02, d); vec3 col = palc_renkler(i % paln_renkler()); acc = overPre(vec4(col, 1.0) * k, acc); }
  o = overPre(acc, s);
}
//== bokeh
GRADIENT(renkler)
uniform float p_isikSayi, p_boyut, p_bulanikl, p_hiz, p_opaklik, p_boyutDegi, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec3 acc = vec3(0.0);
  int N = int(clamp(p_isikSayi, 1.0, 80.0));
  for (int i = 0; i < 80; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum) + 2.0)); vec2 h2 = hash2(vec2(float(i) + 0.5, 9.0));
    vec2 c = (h - 0.5) * B + vec2(sin(u_t * 0.3 + h2.x * 6.0), cos(u_t * 0.25 + h2.y * 6.0)) * p_hiz * 0.3 - vec2(0.0, fract(u_t * p_hiz / max(B.y, 1.0) * 0.3 + h2.x) - 0.5) * B.y * 0.0;
    float r = p_boyut * 0.5 * mix(1.0, 0.4 + h2.y * 1.2, p_boyutDegi / 100.0); float d = length(q - c);
    float k = 1.0 - smoothstep(r - max(p_bulanikl * 0.5, 0.5), r + max(p_bulanikl * 0.5, 0.5), d); k *= 0.75 + 0.25 * smoothstep(r * 0.6, r, d);
    acc += palc_renkler(i % paln_renkler()) * k * p_opaklik / 100.0; }
  o = vec4(min(s.rgb + acc * (1.0 - s.rgb * 0.5), vec3(1.0)), max(s.a, clamp(max(acc.r, max(acc.g, acc.b)), 0.0, 1.0)));
}
//== smoke
GRADIENT(renkGeci)
uniform vec2 p_dumanMerk; uniform float p_yogunluk, p_olcek, p_yukselmeHizi, p_turbulan, p_evrim, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 r = q - p_dumanMerk; float sc = max(p_olcek, 1.0);
  vec2 p = r / sc; p.y += u_t * p_yukselmeHizi / sc; vec2 w = vec2(fbm(p + seedf(p_tohum), 3.0), fbm(p + 5.2 + p_evrim * 0.03, 3.0)) * p_turbulan / 100.0 * 2.0;
  float n = fbm(p + w, 4.0) * 0.5 + 0.5; float up = clamp(-r.y / (boxU().y * 0.9), 0.0, 1.0); float plume = exp(-pow(r.x / (sc * (0.4 + up * 1.2)), 2.0)) * smoothstep(0.0, 0.08, up + 0.05) * (1.0 - up * 0.5);
  float d = clamp(smoothstep(0.35, 0.8, n) * plume * p_yogunluk / 100.0 * 1.8, 0.0, 1.0);
  o = overPre(vec4(grad_renkGeci(clamp(up + (n - 0.5) * 0.3, 0.0, 1.0)), 1.0) * d, s);
}
//== aurora
GRADIENT(renkGeci)
uniform float p_seritSayi, p_yuksekli, p_dalgaGeni, p_hiz, p_parlakli, p_yumusakl, p_aci;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()); vec3 acc = vec3(0.0); int N = int(clamp(p_seritSayi, 1.0, 12.0));
  for (int i = 0; i < 12; i++) { if (i >= N) break; float fi = float(i); float base = -boxU().y * 0.25 + fi * 18.0;
    float cy = base + sin(q.x / max(p_dalgaGeni, 1.0) * TAU + u_t * p_hiz * TAU + fi * 1.7) * 25.0 + fbm(vec2(q.x / max(p_dalgaGeni, 1.0) + u_t * p_hiz * 0.5, fi), 3.0) * 30.0;
    float dy = cy - q.y; float h = max(p_yuksekli, 1.0);
    float k = smoothstep(0.0, 6.0, dy + 2.0) * exp(-max(dy, 0.0) / (h * mix(0.15, 0.6, p_yumusakl / 100.0))) * (0.6 + 0.4 * vnoise(vec2(q.x * 0.08, fi * 3.0 + u_t)));
    acc += grad_renkGeci(clamp(max(dy, 0.0) / h, 0.0, 1.0)) * k; }
  acc *= p_parlakli / 100.0 * 1.3;
  o = vec4(min(s.rgb + acc * (1.0 - s.rgb * 0.4), vec3(1.0)), max(s.a, clamp(max(acc.r, max(acc.g, acc.b)), 0.0, 1.0)));
}
//== galaxy
GRADIENT(renkGeci)
uniform vec2 p_merkez; uniform float p_kolSayi, p_donus, p_hiz, p_yaricap, p_yildizYogu, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 r = toUnit(here()) - p_merkez; float R = max(p_yaricap, 1.0); float d = length(r) / R;
  float a = atan(r.y, r.x) - radians(p_donus) - u_t * p_hiz * TAU; float arms = max(1.0, floor(p_kolSayi));
  float spiral = 0.5 + 0.5 * cos(arms * (a + log(d + 0.02) * 2.6)); float n = fbm(r / R * 6.0 + seedf(p_tohum), 3.0) * 0.5 + 0.5;
  float dens = pow(spiral, 2.0) * exp(-d * 2.2) * (0.6 + 0.6 * n) + exp(-d * 9.0) * 1.2;
  vec2 g = floor(here() / max(u_s * 1.5, 1.0)); float st = step(1.0 - p_yildizYogu / 100.0 * 0.04, hash1(g + seedf(p_tohum))) * (0.5 + hash1(g + 3.0));
  vec3 c = grad_renkGeci(clamp(d, 0.0, 1.0)) * dens + vec3(st) * exp(-d * 1.2);
  o = vec4(min(s.rgb + c, vec3(1.0)), max(s.a, clamp(max(c.r, max(c.g, c.b)), 0.0, 1.0)));
}
//== coderain
uniform float p_sutunAral, p_yaziBoyu, p_hiz, p_izUzun, p_tohum; uniform vec3 c_renk, c_basRenk;
float glyph(vec2 f, float id) { vec2 g = floor(f * vec2(3.0, 5.0)); return step(0.45, hash1(g + id * 7.3)) * step(0.1, f.x) * step(f.x, 0.9) * step(0.05, f.y) * step(f.y, 0.95); }
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) + boxU() * 0.5; float cw = max(p_sutunAral, 2.0), ch = max(p_yaziBoyu, 2.0);
  float col = floor(q.x / cw); float sd = seedf(p_tohum); float sp = p_hiz * (0.6 + hash1(vec2(col, sd)) * 0.8);
  float head = fract(hash1(vec2(col, sd + 1.0)) + u_t * sp / max(boxU().y + ch * p_izUzun, 1.0)) * (boxU().y + ch * p_izUzun);
  float row = floor(q.y / ch); float dist = (head - q.y) / ch;
  float k = dist >= 0.0 && dist < p_izUzun ? 1.0 - dist / p_izUzun : 0.0;
  float gid = floor(hash1(vec2(col, row)) * 50.0 + floor(u_t * 6.0 * hash1(vec2(row, col))));
  float g = glyph(fract(q / vec2(cw, ch)) * vec2(cw / ch, 1.0) * vec2(ch / cw, 1.0), gid);
  vec3 c = mix(c_renk, c_basRenk, step(dist, 1.0) * step(0.0, dist)) * g * k;
  o = overPre(vec4(c, max(c.r, max(c.g, c.b))), s);
}
//== fractalset
GRADIENT(palet)
uniform float p_fraktalTuru, p_yakinlas, p_yineleme, p_faz, p_yumusakRenk; uniform vec2 p_merkez, p_juliaSabi;
void main() {
  vec2 b = boxUV(here()) - 0.5; vec2 B = boxU(); b.x *= B.x / B.y;
  vec2 c = p_merkez + b * 3.0 / max(p_yakinlas, 1e-6);
  vec2 z = p_fraktalTuru > 0.5 ? c : vec2(0.0); vec2 k = p_fraktalTuru > 0.5 ? p_juliaSabi : c;
  float n = 0.0; int N = int(clamp(p_yineleme, 8.0, 512.0)); bool esc = false;
  for (int i = 0; i < 512; i++) { if (i >= N) break; z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + k; if (dot(z, z) > 256.0) { esc = true; break; } n += 1.0; }
  float v = n; if (p_yumusakRenk > 0.5 && esc) v = n - log2(log2(dot(z, z))) + 4.0;
  vec3 col = esc ? grad_palet(fract(v / 48.0 + p_faz / 100.0)) : vec3(0.0);
  o = genOver(vec4(col, 1.0));
}
//== cellpattern
uniform float p_hucreBoyu, p_desen, p_kenarKali, p_evrim, p_tohum, p_kenarYumu; uniform vec3 c_renk1, c_renk2;
void main() {
  vec2 p = toUnit(here()) / max(p_hucreBoyu, 1.0) + seedf(p_tohum); p += vec2(sin(p_evrim * 0.05), cos(p_evrim * 0.05)) * 0.3;
  vec4 v = voronoi(p); float edge = v.y - v.x; float w = p_kenarKali / max(p_hucreBoyu, 1.0); float aa = p_kenarYumu > 0.5 ? 0.04 : 0.005;
  float k;
  if (p_desen < 0.5) k = smoothstep(w - aa, w + aa, edge);
  else if (p_desen < 1.5) k = 1.0 - smoothstep(0.0, 0.7, v.x);
  else if (p_desen < 2.5) k = mix(0.3, 1.0, hash1(v.zw)) * smoothstep(w - aa, w + aa, edge);
  else k = step(0.5, hash1(v.zw)) * 0.6 + 0.4 * smoothstep(w - aa, w + aa, edge);
  o = genOver(vec4(mix(c_renk1, c_renk2, k), 1.0));
}
//== paintbucket
uniform vec2 p_dolguNokt; uniform float p_tolerans, p_kenarYumu, p_bitisikAlan, p_alfayiKoru; uniform vec3 c_dolguReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec4 ref = texU(p_dolguNokt); vec3 c = unpre(s), rc = unpre(ref);
  float d = distance(c, rc) + abs(s.a - ref.a); float tol = p_tolerans / 100.0 * 0.8; float m = 1.0 - smoothstep(tol, tol + 0.02 + p_kenarYumu * 0.01, d);
  if (p_bitisikAlan > 0.5) { // yaklaşık bitişiklik: noktadan buraya giden yol boyunca benzer renk
    vec2 A = fromUnit(p_dolguNokt); for (int i = 1; i < 12; i++) { float t = float(i) / 12.0; vec4 x = texPx(mix(A, here(), t)); if (distance(unpre(x), rc) + abs(x.a - ref.a) > tol + 0.05) { m = 0.0; break; } } }
  float a = p_alfayiKoru > 0.5 ? s.a : max(s.a, m);
  o = pre(mix(c, c_dolguReng, m), a);
}
//== eyedropper
uniform sampler2D s_kaynakKatm; uniform float p_kaynakKatmOn; uniform vec2 p_ornekNokt; uniform float p_ornekYari, p_dolguOpak, p_alfayiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); vec4 acc = vec4(0.0); float R = p_ornekYari * u_s;
  for (int i = 0; i < 9; i++) { vec2 d = vec2(float(i % 3) - 1.0, float(i / 3) - 1.0) * R * 0.7;
    acc += p_kaynakKatmOn > 0.5 ? texture(s_kaynakKatm, clamp(boxUV(fromUnit(p_ornekNokt) + d), 0.0, 1.0)) : texPx(fromUnit(p_ornekNokt) + d); }
  acc /= 9.0; vec3 col = unpre(acc); float a = p_alfayiKoru > 0.5 ? s.a : 1.0;
  o = mix(s, pre(col, a), p_dolguOpak / 100.0);
}
//== contourstrips
GRADIENT(renkGeci)
uniform float p_seritSayi, p_faz, p_kenarKali, p_yumusakl; uniform vec3 c_kenarReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float n = max(2.0, floor(p_seritSayi)); float l = luma(unpre(s)) + p_faz / 100.0; float x = l * n;
  float band = floor(x) / max(n - 1.0, 1.0); float f = fract(x); float soft = p_yumusakl / 100.0;
  vec3 c = grad_renkGeci(fract(band)); if (soft > 0.0) c = mix(c, grad_renkGeci(fract(band + 1.0 / n)), smoothstep(1.0 - soft, 1.0, f));
  float g = length(vec2(dFdx(x), dFdy(x))); float e = 1.0 - smoothstep(p_kenarKali * u_s * 0.5 * g, p_kenarKali * u_s * 0.5 * g + g, min(f, 1.0 - f));
  c = mix(c, c_kenarReng, e * step(0.01, p_kenarKali));
  o = pre(c, s.a);
}
//== grunge
uniform sampler2D s_dokuDosy; uniform float p_dokuDosyOn; uniform float p_doku, p_olcek, p_yogunluk, p_kontrast, p_lekeBoyu, p_tohum, p_karistir;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 p = toUnit(here()) / max(p_olcek / 100.0, 0.01) + seedf(p_tohum); float g;
  if (p_dokuDosyOn > 0.5 || p_doku > 3.5) g = luma(unpre(texture(s_dokuDosy, fract(p / 200.0))));
  else if (p_doku < 0.5) g = 0.75 + fbm(p / max(p_lekeBoyu, 1.0), 4.0) * 0.4 + (hash1(floor(p)) - 0.5) * 0.08;
  else if (p_doku < 1.5) g = 0.7 + fbm(p / 6.0, 3.0) * 0.25 - step(0.93, hash1(floor(p / 3.0))) * 0.35 + fbm(p / max(p_lekeBoyu, 1.0), 2.0) * 0.2;
  else if (p_doku < 2.5) { float n = fbm(p / max(p_lekeBoyu, 1.0), 5.0); g = 0.75 + n * 0.5; vec3 rust = vec3(0.55, 0.25, 0.08); vec3 c = unpre(s); c = mix(c, c * rust * 1.8, smoothstep(0.1, 0.5, n) * p_yogunluk / 100.0); o = pre(c, s.a); return; }
  else { vec2 q = rot2(17.0) * p; float sc = 1.0 - step(0.985, vnoise(vec2(q.x * 0.02, q.y * 2.0))) * 0.6; g = 0.85 * sc + fbm(p / 30.0, 2.0) * 0.15; }
  g = clamp((g - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5, 0.0, 1.0); vec3 c = unpre(s); vec3 t = vec3(g);
  vec3 r = p_karistir < 0.5 ? c * t : p_karistir < 1.5 ? overlayB(c, t) : t;
  o = pre(mix(c, r, p_yogunluk / 100.0), s.a);
}
//== ominodiff
GRADIENT(palet)
uniform float p_hataYayi, p_pikselBoyu, p_renkKaym, p_taramaYonu, p_tohum, p_zamanaBagl;
void main() {
  vec4 s = texture(u_tex, v_uv); float ps = max(p_pikselBoyu * u_s, 1.0); vec2 g = floor(here() / ps); vec4 x = texPx((g + 0.5) * ps); if (x.a <= 0.0) { o = x; return; }
  vec3 c = unpre(x); float tk = p_zamanaBagl > 0.5 ? floor(u_t * 12.0) : 0.0;
  float bayer = hash1(g + seedf(p_tohum) + tk) - 0.5; c += bayer * p_hataYayi / 100.0 * 0.35;
  c.r += p_renkKaym / 100.0 * 0.2 * sin((p_taramaYonu < 0.5 ? g.y : g.x) * 0.5);
  int n = paln_palet(); float best = 1e9; vec3 bc = c;
  for (int i = 0; i < 8; i++) { if (i >= n) break; vec3 p = palc_palet(i); float d = distance(c, p); if (d < best) { best = d; bc = p; } }
  o = pre(bc, x.a);
}
//== volclouds
uniform float p_bulutYogu, p_olcek, p_yuksekli, p_ruzgarHizi, p_isikYonu, p_derinlikOrne, p_tohum, p_ortamIsig, p_yonluIsikGucu, p_gorusAcis; uniform vec3 c_isikReng, c_ortamReng; uniform vec3 p_yonelimXY;
float dens(vec3 p) { float n = fbm(p.xy + vec2(p.z * 0.7, p.z * 0.4), 4.0) * 0.5 + 0.5; return clamp((n - (1.0 - p_bulutYogu / 100.0)) * 2.5, 0.0, 1.0); }
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) / max(p_olcek, 1.0) + seedf(p_tohum) + vec2(u_t * p_ruzgarHizi / max(p_olcek, 1.0), 0.0);
  q = rot2(p_yonelimXY.z) * q;
  float T = 1.0; vec3 col = vec3(0.0); int N = int(clamp(p_derinlikOrne, 8.0, 32.0)); float la = radians(p_isikYonu); vec2 ld = vec2(cos(la), sin(la)) * 0.08;
  for (int i = 0; i < 32; i++) { if (i >= N) break; float z = float(i) / float(N) * p_yuksekli / 100.0 * 2.0; float d = dens(vec3(q, z)) * 0.35;
    if (d > 0.001) { float sh = dens(vec3(q + ld, z + 0.08)); vec3 L = mix(c_ortamReng * p_ortamIsig / 100.0 * 1.5, c_isikReng, exp(-sh * 2.0) * p_yonluIsikGucu / 100.0 * 1.2);
      col += T * d * L; T *= 1.0 - d; if (T < 0.02) break; } }
  float a = 1.0 - T;
  o = overPre(vec4(col, a), s);
}
