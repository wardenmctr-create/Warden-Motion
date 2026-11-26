// Bölüm C: yeni 2B efektler (uzay, hava, yüzey, çizim, bozulma)
//== meteors
uniform float p_meteorYogu, p_buyukluk, p_rastgeleBuyu, p_hiz, p_yon, p_yonDagi, p_yasamSure, p_izUzun, p_parlama, p_tohum, p_dongu; uniform vec3 c_meteorReng, c_kuyrukReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec4 acc = vec4(0.0); float N = clamp(p_meteorYogu, 0.0, 60.0); float life = max(p_yasamSure, 0.1);
  for (int i = 0; i < 60; i++) { if (float(i) >= N) break; float fi = float(i); float per = life * 1.6; float ph = u_t / per + hash1(vec2(fi, seedf(p_tohum))); float cyc = floor(ph); float k = fract(ph) * 1.6;
    if (p_dongu < 0.5 && u_dur > 0.0 && cyc * per > u_dur) continue; if (k > 1.0) continue;
    vec2 h = hash2(vec2(fi + cyc * 13.7, seedf(p_tohum) + 3.0)); float ang = radians(p_yon + (hash1(vec2(fi, cyc + 9.0)) - 0.5) * 2.0 * p_yonDagi); vec2 dir = vec2(cos(ang), sin(ang));
    vec2 st = (h - 0.5) * B * 1.4 - dir * B * 0.35; vec2 head = st + dir * p_hiz * k * life; float sz = p_buyukluk * (1.0 + (hash1(vec2(fi, cyc + 2.0)) - 0.5) * p_rastgeleBuyu / 50.0);
    vec2 d = q - head; float along = dot(d, -dir); float perp = abs(dot(d, vec2(-dir.y, dir.x))); float fade = sin(k * PI);
    float tail = step(0.0, along) * (1.0 - smoothstep(0.0, max(p_izUzun, 1.0), along)) * (1.0 - smoothstep(sz * 0.2, sz * 0.6 * (1.0 - along / max(p_izUzun, 1.0)) + 0.3, perp));
    float hd = 1.0 - smoothstep(sz * 0.3, sz, length(d)); float gl = exp(-length(d) / max(sz * 3.0, 1.0)) * p_parlama / 100.0 * 0.6;
    acc = overPre(vec4(c_kuyrukReng, 1.0) * tail * fade * 0.85, acc); acc = overPre(vec4(c_meteorReng, 1.0) * clamp(hd + gl, 0.0, 1.0) * fade, acc); }
  o = overPre(acc, s); }
//== blackhole
uniform sampler2D s_bgsrc, s_bukuleceKatm; uniform float p_bgsrcOn, p_bukuleceKatmOn;
uniform vec2 p_merkez; uniform float p_merkezYari, p_bukulmeAlan, p_mercekEtki, p_girdapEtki, p_arkaPlanBuk, p_isikliDisk, p_diskGeni, p_diskEgim, p_diskDonuHizi, p_turbulan, p_parlama; uniform vec3 c_icDiskReng, c_disDiskReng;
vec4 bgAt(vec2 u) { vec2 b = boxUV(fromUnit(u)); if (p_bukuleceKatmOn > 0.5) return texture(s_bukuleceKatm, clamp(b, 0.0, 1.0)); if (p_arkaPlanBuk > 0.5 && p_bgsrcOn > 0.5) return texture(s_bgsrc, clamp(b, 0.0, 1.0)); return texU(u); }
void main() { vec2 q = toUnit(here()) - p_merkez; float r = length(q); float Rh = max(p_merkezYari * 0.5, 1.0); float A = max(p_bukulmeAlan, Rh * 1.5);
  float w = smoothstep(A, Rh, r); float bend = p_mercekEtki / 100.0 * Rh * Rh / max(r, 1.0) * 1.6 * w; float sw = p_girdapEtki / 100.0 * w * w * 3.0;
  vec2 dq = rot2(degrees(sw)) * (q - normalize(q + 1e-4) * bend); vec4 c = mix(texU(q + p_merkez), bgAt(dq + p_merkez), w > 0.0 ? 1.0 : 0.0);
  if (p_isikliDisk > 0.5) { float tilt = cos(radians(p_diskEgim)); vec2 dp = vec2(q.x, q.y / max(tilt, 0.08)); float dr = length(dp); float a = atan(dp.y, dp.x) - u_t * radians(p_diskDonuHizi);
    float ring = smoothstep(Rh * 1.3, Rh * 1.6, dr) * smoothstep(Rh * 1.6 + p_diskGeni, Rh * 1.4 + p_diskGeni * 0.5, dr);
    float tb = mix(1.0, fbm(vec2(a * 3.0, dr * 0.05), 3.0) * 1.6, p_turbulan / 100.0); float x = clamp((dr - Rh * 1.4) / max(p_diskGeni, 1.0), 0.0, 1.0);
    vec3 dc = mix(c_icDiskReng, c_disDiskReng, x) * (1.0 + 0.6 * cos(atan(dp.y, dp.x))) ; float behind = step(0.0, -q.y) * step(dr, Rh * 1.6 + p_diskGeni);
    float occl = (r < Rh * 1.05 && q.y < 0.0) ? 0.0 : 1.0; c = overPre(vec4(dc, 1.0) * clamp(ring * tb, 0.0, 1.0) * occl, c); }
  float hole = 1.0 - smoothstep(Rh * 0.98, Rh * 1.02, r); c = overPre(vec4(0.0, 0.0, 0.0, 1.0) * hole, c);
  c = overPre(vec4(c_icDiskReng, 1.0) * exp(-abs(r - Rh * 1.08) / max(Rh * 0.08, 0.5)) * p_parlama / 100.0 * 0.7, c); o = c; }
//== nebula
uniform vec2 p_merkez; uniform float p_buyukluk, p_gazYogu, p_ayrinti, p_turbulan, p_bulutKatm, p_hareketHizi, p_yildizla, p_yildizYogu, p_derinlik, p_tohum; uniform vec3 c_birinciRenk, c_ikinciRenk, c_ucuncuRenk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = (toUnit(here()) - p_merkez) / max(length(boxU()) * 0.5 * p_buyukluk / 100.0, 1.0); float sd = seedf(p_tohum); vec4 acc = vec4(0.0);
  int L = int(clamp(p_bulutKatm, 1.0, 8.0));
  for (int i = 0; i < 8; i++) { if (i >= L) break; float fi = float(i); float z = 1.0 + fi * p_derinlik / 100.0 * 0.5; vec2 p = q * (2.0 + fi * 0.7) * z + vec2(u_t * p_hareketHizi * 0.002 * (1.0 + fi), fi * 3.1) + sd;
    vec2 warp = vec2(fbm(p + 1.7, 3.0), fbm(p + 9.2, 3.0)) * p_turbulan / 100.0 * 2.0; float f = fbm(p + warp, 2.0 + p_ayrinti / 25.0);
    float d = smoothstep(1.0 - p_gazYogu / 100.0 * 0.8, 1.0, f + 0.35 - length(q) * 0.35); vec3 c = mix(mix(c_birinciRenk, c_ikinciRenk, fbm(p * 0.7 + 4.0, 3.0)), c_ucuncuRenk, smoothstep(0.55, 0.8, f));
    acc = overPre(vec4(c, 1.0) * d * 0.55, acc); }
  if (p_yildizla > 0.5) { vec2 g = toUnit(here()) / 6.0; vec2 id = floor(g); vec2 f = fract(g) - 0.5; float h = hash1(id + sd); float st = step(1.0 - p_yildizYogu / 100.0 * 0.25, h) * (1.0 - smoothstep(0.02, 0.12, length(f - (hash2(id) - 0.5) * 0.6)));
    acc = overPre(vec4(1.0) * st * (0.6 + 0.4 * sin(u_t * 3.0 + h * 40.0)), acc); }
  o = overPre(acc, s); }
//== sunsurface
uniform float p_buyukluk, p_yuzeyAyri, p_yuzeyHare, p_parlakli, p_gunesLeke, p_lekeYogu, p_korona, p_koronaYuks, p_plazmaYayl, p_yayBuyu, p_parlama; uniform vec3 c_anaRenk, c_sicakBolg, c_koyuBolg;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = max(p_buyukluk * 0.5, 2.0); float r = length(q) / R; vec4 acc = vec4(0.0);
  if (r < 1.0) { vec3 n = vec3(q / R, sqrt(1.0 - r * r)); vec2 uv = vec2(atan(n.x, n.z), asin(n.y)) * 4.0; float tt = u_t * p_yuzeyHare / 100.0;
    vec4 v = voronoi(uv * (3.0 + p_yuzeyAyri / 10.0) + tt * 0.3); float gr = smoothstep(0.0, 0.6, v.y - v.x); float f = fbm(uv * 2.0 + tt * 0.2, 4.0);
    vec3 c = mix(c_koyuBolg, mix(c_anaRenk, c_sicakBolg, f), 0.5 + gr * 0.5); c *= mix(0.55, 1.0, pow(n.z, 0.4)) * p_parlakli / 100.0;
    if (p_gunesLeke > 0.5) { vec4 sv = voronoi(uv * 0.9 + 11.0); float spot = step(hash1(sv.zw), p_lekeYogu / 100.0) * (1.0 - smoothstep(0.08, 0.22, sv.x)); c = mix(c, c_koyuBolg * 0.25, spot); }
    acc = vec4(clamp(c, 0.0, 1.5), 1.0) * smoothstep(1.0, 0.985, r); }
  if (p_korona > 0.5) { float a = atan(q.y, q.x); float rays = 0.6 + 0.4 * fbm(vec2(a * 4.0, u_t * 0.3), 3.0); float cor = exp(-(r - 1.0) / max(p_koronaYuks / 100.0 * 0.6 * rays, 0.02)) * step(1.0, r); acc = overPre(vec4(c_sicakBolg, 1.0) * cor * 0.7, acc); }
  if (p_plazmaYayl > 0.5) { for (int i = 0; i < 4; i++) { float fi = float(i); float a0 = hash1(vec2(fi, 4.0)) * TAU; vec2 c = vec2(cos(a0), sin(a0)) * R; vec2 l = rot2(-degrees(a0) + 90.0) * (q - c);
      float H = R * p_yayBuyu / 100.0 * (0.6 + 0.4 * sin(u_t * 0.7 + fi)); float arc = abs(length(vec2(l.x, l.y * 1.0) - vec2(0.0, 0.0)) - H * 0.5); float m = (1.0 - smoothstep(0.0, R * 0.03, arc)) * step(0.0, -l.y + 0.0) * step(1.0, r);
      acc = overPre(vec4(c_anaRenk * 1.2, 1.0) * m * 0.8, acc); } }
  acc = overPre(vec4(c_sicakBolg, 1.0) * exp(-max(r - 1.0, 0.0) * 6.0) * step(1.0, r) * p_parlama / 100.0 * 0.5, acc);
  o = overPre(acc, s); }
//== tornado
uniform vec2 p_merkez; uniform float p_gorunum, p_disYari, p_gozYari, p_yuksekli, p_donusHizi, p_sarmalKolSayi, p_sarmalSiki, p_bulutYogu, p_turbulan, p_opaklik, p_tohum; uniform vec3 c_bulutReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_merkez; float sd = seedf(p_tohum); float d = 0.0; vec3 col = c_bulutReng;
  if (p_gorunum < 0.5) { float r = length(q); float a = atan(q.y, q.x) + u_t * radians(p_donusHizi) * 0.3; float lr = log(max(r, 1.0)); float arms = max(floor(p_sarmalKolSayi), 1.0);
    float sp = sin(a * arms + lr * p_sarmalSiki / 10.0 * arms); float f = fbm(vec2(a * 2.0, lr * 4.0) + sd, 5.0) * (1.0 + p_turbulan / 100.0) - p_turbulan / 200.0;
    d = smoothstep(0.1, 0.9, (sp * 0.5 + 0.5) * 0.6 + f * 0.7) * smoothstep(p_disYari, p_disYari * 0.5, r) * smoothstep(p_gozYari * 0.6, p_gozYari * 1.4, r) * p_bulutYogu / 100.0 * 1.4;
    col = mix(c_bulutReng * 0.6, vec3(1.0), smoothstep(0.3, 0.9, f)); }
  else { float H = max(p_yuksekli, 10.0); float y = clamp((q.y + H * 0.5) / H, 0.0, 1.0); float w = mix(p_disYari, p_gozYari, pow(y, 0.6)) * (p_gorunum > 1.5 ? 0.6 : 1.0);
    float sway = sin(y * 3.0 + u_t * 1.3) * w * 0.25; float x = (q.x - sway) / max(w, 1.0); float inside = 1.0 - smoothstep(0.7, 1.0, abs(x));
    float a = asin(clamp(x, -1.0, 1.0)) + u_t * radians(p_donusHizi); float f = fbm(vec2(a * 2.0, y * 8.0 - u_t * 0.5) + sd, 4.0);
    d = inside * step(-H * 0.5, q.y) * step(q.y, H * 0.5) * smoothstep(0.2, 0.7, f * (1.0 + p_turbulan / 100.0)) * p_bulutYogu / 100.0 * 1.5; col = mix(c_bulutReng * 0.7, c_bulutReng * 1.2, f);
    if (p_gorunum > 1.5) { float dust = smoothstep(H * 0.5, H * 0.3, q.y) * smoothstep(p_disYari * 1.5, 0.0, abs(q.x)) * fbm(q * 0.03 + u_t * 0.4, 3.0); d = max(d, dust); } }
  o = overPre(vec4(col, 1.0) * clamp(d, 0.0, 1.0) * p_opaklik / 100.0, s); }
//== sandstorm
uniform float p_yogunluk, p_kumBuyu, p_ruzgarHizi, p_ruzgarYonu, p_turbulan, p_tozTaba, p_gorusAzal, p_hareketBula, p_degiskenRuzg, p_ruzgarDegiSikl, p_tohum; uniform vec3 c_kumReng;
void main() { vec4 s = texture(u_tex, v_uv); float gust = p_degiskenRuzg > 0.5 ? 0.6 + 0.8 * vnoise(vec2(u_t * p_ruzgarDegiSikl, 5.0)) : 1.0; vec2 dir = vec2(cos(radians(p_ruzgarYonu)), sin(radians(p_ruzgarYonu)));
  vec2 q = toUnit(here()); vec2 p = rot2(-p_ruzgarYonu) * q; float sd = seedf(p_tohum); float off = u_t * p_ruzgarHizi * gust;
  float haze = fbm((p - vec2(off * 0.3, 0.0)) * 0.006 + sd, 4.0); haze = mix(haze, fbm((p - vec2(off * 0.3, 0.0)) * 0.006 + vec2(haze * p_turbulan / 30.0), 4.0), 0.5);
  float grains = 0.0; float gs = max(p_kumBuyu, 0.5); vec2 g = vec2((p.x - off) / (gs * (1.0 + p_hareketBula / 10.0)), p.y / gs); vec2 id = floor(g);
  float h = hash1(id + sd); grains = step(1.0 - p_yogunluk / 100.0 * 0.35, h) * (1.0 - smoothstep(0.3, 0.5, abs(fract(g.y) - 0.5)));
  float ground = smoothstep(boxU().y * (0.5 - p_tozTaba / 100.0), boxU().y * 0.5, q.y) * p_tozTaba / 100.0;
  float fog = clamp(haze * p_yogunluk / 100.0 * 1.2 + ground, 0.0, 1.0); vec4 c = s; c.rgb = mix(c.rgb, c_kumReng * c.a, p_gorusAzal / 100.0 * c.a);
  c = overPre(vec4(c_kumReng, 1.0) * fog * 0.75, c); c = overPre(vec4(c_kumReng * 1.3, 1.0) * grains * 0.8, c); o = c; }
//== leaffall
uniform sampler2D s_ozelYaprGors; uniform float p_ozelYaprGorsOn;
uniform float p_yaprakTuru, p_yaprakSayi, p_buyukluk, p_buyuklukRast, p_dusmeHizi, p_sallanmaGeni, p_sallanmaHizi, p_donmeHizi, p_p3bDonu, p_derinlikDagi, p_dongu; uniform vec2 p_ruzgar; uniform vec3 c_yaprakRenk;
float leaf(vec2 p, float kind) { if (kind > 2.5 && kind < 3.5) { float a = atan(p.y, p.x); float r = length(p); return 1.0 - smoothstep(0.0, 0.08, r - 0.75 * (0.65 + 0.35 * abs(cos(a * 2.5)))); }
  if (kind > 1.5 && kind < 2.5) { float a = atan(p.x, -p.y); float r = length(p); return 1.0 - smoothstep(0.0, 0.08, r - 0.85 * (0.55 + 0.45 * abs(sin(a * 2.5))) ); }
  float w = kind > 0.5 ? 0.5 + 0.12 * sin(p.y * 18.0) : 0.45; return 1.0 - smoothstep(0.0, 0.08, length(vec2(p.x / w, p.y)) - 0.9) * 1.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec4 acc = vec4(0.0); float N = clamp(p_yaprakSayi, 0.0, 120.0);
  const vec3 AUT[4] = vec3[4](vec3(0.85, 0.35, 0.1), vec3(0.95, 0.6, 0.12), vec3(0.7, 0.18, 0.08), vec3(0.6, 0.45, 0.15));
  for (int i = 0; i < 120; i++) { if (float(i) >= N) break; float fi = float(i); vec2 h = hash2(vec2(fi, 3.3)); float z = mix(1.0, 0.4, hash1(vec2(fi, 7.0)) * p_derinlikDagi / 100.0);
    float sz = p_buyukluk * z * (1.0 + (h.y - 0.5) * p_buyuklukRast / 50.0); float H = B.y + sz * 4.0; float y = p_dongu > 0.5 ? mod(h.y * H + u_t * p_dusmeHizi * z, H) - H * 0.5 : h.y * H - H * 0.5 + u_t * p_dusmeHizi * z;
    float x = (h.x - 0.5) * B.x * 1.2 + p_ruzgar.x * u_t * z + sin(u_t * p_sallanmaHizi * TAU * z + fi) * p_sallanmaGeni; x = mod(x + B.x * 0.6, B.x * 1.2) - B.x * 0.6;
    vec2 l = q - vec2(x, y + p_ruzgar.y * u_t); float ang = u_t * p_donmeHizi * (h.x - 0.5) * 2.0 + fi * 40.0; l = rot2(-ang) * l / max(sz, 0.5);
    float flip = p_p3bDonu > 0.5 ? cos(u_t * 2.0 + fi) : 1.0; l.x /= max(abs(flip), 0.15); vec3 col = p_yaprakTuru < 0.5 || p_yaprakTuru > 1.5 && p_yaprakTuru < 2.5 ? AUT[int(mod(fi, 4.0))] : c_yaprakRenk;
    col *= c_yaprakRenk * (flip < 0.0 ? 0.75 : 1.0);
    float m; if (p_yaprakTuru > 3.5 && p_ozelYaprGorsOn > 0.5) { vec4 t = texture(s_ozelYaprGors, clamp(l * 0.5 + 0.5, 0.0, 1.0)); m = t.a; col = t.a > 0.0 ? t.rgb / t.a : col; } else m = leaf(l, p_yaprakTuru) * (1.0 - 0.2 * step(abs(l.x), 0.03) * step(abs(l.y), 0.8));
    acc = overPre(vec4(col * mix(0.7, 1.0, z), 1.0) * m, acc); }
  o = overPre(acc, s); }
//== droplets
uniform float p_damlaSayi, p_damlaBuyu, p_buyuklukRast, p_yuvarlak, p_yukselti, p_saydamli, p_isikKiri, p_kenarParl, p_damlaHare, p_akisHizi, p_akisYonu, p_damlaIzi, p_izUzun, p_damlalarBirl;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec2 off = vec2(0.0); float mask = 0.0, rim = 0.0, trail = 0.0; float N = clamp(p_damlaSayi, 0.0, 150.0);
  vec2 dir = vec2(cos(radians(p_akisYonu)), sin(radians(p_akisYonu)));
  for (int i = 0; i < 150; i++) { if (float(i) >= N) break; float fi = float(i); vec2 h = hash2(vec2(fi, 1.7)); float r = p_damlaBuyu * 0.5 * (1.0 + (hash1(vec2(fi, 5.0)) - 0.5) * p_buyuklukRast / 50.0);
    vec2 c = (h - 0.5) * B; if (p_damlaHare > 0.5 && r > p_damlaBuyu * 0.45) { float sp = p_akisHizi * (r / max(p_damlaBuyu, 1.0)); c += dir * mod(u_t * sp + h.y * B.y, B.y * 1.2); c = mod(c + B * 0.6, B * 1.2) - B * 0.6; }
    vec2 d = q - c; d.y *= mix(1.6, 1.0, p_yuvarlak / 100.0); float l = length(d) / max(r, 0.5);
    if (p_damlaIzi > 0.5 && p_damlaHare > 0.5) { float al = dot(q - c, -dir); float pp = abs(dot(q - c, vec2(-dir.y, dir.x))); trail = max(trail, step(0.0, al) * (1.0 - smoothstep(0.0, p_izUzun, al)) * (1.0 - smoothstep(r * 0.15, r * 0.3, pp)) * 0.5); }
    if (l < 1.0) { float hgt = sqrt(1.0 - l * l); mask = max(mask, smoothstep(1.0, 0.85, l)); off = -d / max(r, 0.5) * hgt * r * p_isikKiri / 100.0 * 1.5 * p_yukselti / 60.0; rim = max(rim, smoothstep(0.7, 1.0, l) * smoothstep(1.0, 0.95, l)); } }
  vec4 ref = texPx(here() + off * u_s * 2.0); ref.rgb = mix(ref.rgb, ref.rgb * vec3(0.92, 0.97, 1.05), 0.5);
  vec4 c = mix(s, ref, mask * p_saydamli / 100.0); vec2 hl = q; c = overPre(vec4(1.0) * (rim * p_kenarParl / 100.0 + trail * 0.25) * max(s.a, 0.3), c); o = c; }
//== frostglass
uniform float p_donmaMikt, p_kristalBuyu, p_kristalYogu, p_dallanma, p_buzKali, p_bulanikl, p_isikKiri, p_donmaBasl, p_donmaAnim, p_donmaIler, p_tohum; uniform vec3 c_buzReng, c_kristalReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 b = boxUV(here()); float sd = seedf(p_tohum);
  float start = p_donmaBasl < 0.5 ? 1.0 - min(min(b.x, 1.0 - b.x), min(b.y, 1.0 - b.y)) * 2.0 : p_donmaBasl < 1.5 ? 1.0 - length(b - 0.5) * 1.6 : fbm(q * 0.01 + sd, 3.0) * 1.4;
  float prog = (p_donmaAnim > 0.5 ? p_donmaIler : 100.0) / 100.0 * p_donmaMikt / 100.0; float f = smoothstep(1.0 - prog * 1.3, 1.0 - prog * 1.3 + 0.25, start + fbm(q * 0.02 + sd, 4.0) * 0.4);
  float cs = max(p_kristalBuyu, 1.0); vec4 v = voronoi(q / cs + sd); float edges = 1.0 - smoothstep(0.0, 0.06 + p_dallanma / 2000.0, v.y - v.x);
  float dend = 0.0; for (int k = 0; k < 3; k++) { vec4 w = voronoi(q / (cs * (0.5 - float(k) * 0.12)) + sd + float(k) * 3.0); dend = max(dend, (1.0 - smoothstep(0.0, 0.05, w.y - w.x)) * p_dallanma / 100.0); }
  float cr = clamp(edges + dend * p_kristalYogu / 100.0, 0.0, 1.0) * f;
  vec2 rf = vec2(fbm(q * 0.05 + 1.0, 3.0), fbm(q * 0.05 + 7.0, 3.0)) - 0.5; vec4 bl = vec4(0.0); float br = p_bulanikl * f * u_s;
  for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; bl += texPx(here() + rf * p_isikKiri * u_s + vec2(cos(a), sin(a)) * br); } bl /= 8.0;
  vec4 c = mix(s, bl, f); c.rgb = mix(c.rgb, c_buzReng * c.a, f * p_buzKali / 100.0 * 0.5); c = overPre(vec4(c_kristalReng, 1.0) * cr * 0.8, c); o = c; }
//== wetsurface
uniform sampler2D s_yansimaKatm, s_bgsrc; uniform float p_yansimaKatmOn, p_bgsrcOn;
uniform float p_islaklik, p_yuzeyKara, p_yansimaGucu, p_puruzlul, p_suKali, p_yansimaBula, p_yansimaKayn, p_suBiri, p_birikintYogu, p_suAkis, p_akisHizi, p_alfaSiniKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 b = boxUV(here()); float w = p_islaklik / 100.0;
  float pud = p_suBiri > 0.5 ? smoothstep(0.55 - p_birikintYogu / 200.0, 0.6 - p_birikintYogu / 200.0, fbm(q * 0.008, 4.0)) : 0.0;
  vec2 rip = p_suAkis > 0.5 ? vec2(sin(q.y * 0.2 + u_t * p_akisHizi * 0.2), cos(q.x * 0.17 + u_t * p_akisHizi * 0.15)) * 0.004 : vec2(0.0);
  vec2 n = (vec2(fbm(q * 0.05, 3.0), fbm(q * 0.05 + 5.0, 3.0)) - 0.5) * p_puruzlul / 100.0 * 0.05 * (1.0 - pud) + rip;
  vec2 ru = vec2(b.x, 1.0 - b.y) + n; vec3 refl;
  if (p_yansimaKayn > 1.5 && p_yansimaKatmOn > 0.5) refl = unpre(texture(s_yansimaKatm, clamp(ru, 0.0, 1.0)));
  else if (p_yansimaKayn > 0.5 && p_bgsrcOn > 0.5) refl = unpre(texture(s_bgsrc, clamp(ru, 0.0, 1.0)));
  else { float l1 = exp(-pow((b.x - 0.3 + n.x * 4.0) * 12.0, 2.0)) + exp(-pow((b.x - 0.72 + n.x * 4.0) * 16.0, 2.0)) * 0.7; refl = vec3(1.0, 0.92, 0.8) * l1 * smoothstep(0.0, 0.8, b.y); }
  vec3 c = unpre(s); c *= 1.0 - w * p_yuzeyKara / 100.0; c = satAdj(c, 1.0 + w * 0.25);
  float rs = (p_yansimaGucu / 100.0) * w * (0.35 + 0.65 * pud) * (1.0 + p_suKali / 100.0); c = mix(c, c + refl * 0.8, clamp(rs, 0.0, 1.0));
  float a = p_alfaSiniKoru > 0.5 ? s.a : max(s.a, pud * rs); o = pre(clamp(c, 0.0, 1.0), a); }
//== perspgrid
uniform vec2 p_ufukNokt, p_hareketHizi; uniform vec3 p_izgaraDonu, c_cizgiReng; uniform float p_izgaraGeni, p_izgaraDeri, p_hucreBuyu, p_cizgiKali, p_cizgiOpak, p_hucreDolg, p_uzakliktSolm, p_perspektGucu, p_parlama, p_parlamaGucu;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_ufukNokt; float y = q.y; if (y <= 0.5) { o = s; return; }
  float tilt = radians(clamp(p_izgaraDonu.x, 5.0, 89.0)); float F = 400.0 * (1.0 - p_perspektGucu / 100.0 * 0.7) / tan(tilt) + 50.0; float z = F * 400.0 / max(y, 0.5) / max(F, 1.0) * 1.0;
  float depth = 300.0 * F / y; vec2 g = vec2(q.x * depth / F, depth); g = rot2(-p_izgaraDonu.y) * g; g += p_hareketHizi * u_t; if (depth > p_izgaraDeri || abs(g.x) > p_izgaraGeni * 0.5 + 1e5 * 0.0) { o = s; return; }
  vec2 cell = g / max(p_hucreBuyu, 1.0); vec2 fw = fwidth(cell); vec2 ln = abs(fract(cell - 0.5) - 0.5) / max(fw, vec2(1e-4)); float line = 1.0 - min(min(ln.x, ln.y) / max(p_cizgiKali, 0.3), 1.0);
  float fade = 1.0 - smoothstep(0.0, p_izgaraDeri, depth) * p_uzakliktSolm / 100.0; fade *= step(abs(g.x), p_izgaraGeni * 0.5);
  vec4 c = s; if (p_hucreDolg > 0.5) c = overPre(vec4(c_cizgiReng, 1.0) * 0.12 * fade, c); c = overPre(vec4(c_cizgiReng, 1.0) * line * fade * p_cizgiOpak / 100.0, c);
  if (p_parlama > 0.5) c = overPre(vec4(c_cizgiReng, 1.0) * exp(-y / 30.0) * p_parlamaGucu / 100.0, c); o = c; }
//== infmirror
uniform vec2 p_merkez, p_kopyaKonuFark; uniform float p_yansimaSayi, p_kuculmeOran, p_derinlikAral, p_kopyaDonu, p_opaklikKayb, p_yatayAyna, p_dikeyAyna, p_renkGeci, p_uzakKopyBula, p_derinlikHare; uniform vec3 c_uzakKopyReng;
void main() { vec2 q = toUnit(here()); vec4 res = texU(q); int N = int(clamp(p_yansimaSayi, 1.0, 40.0)); float k = clamp(p_kuculmeOran / 100.0, 0.1, 0.98);
  float ph = fract(u_t * p_derinlikHare / 100.0);
  for (int i = 1; i <= 40; i++) { if (i > N) break; float fi = float(i) - ph; float sc = pow(k, fi); vec2 l = rot2(-p_kopyaDonu * fi) * (q - p_merkez - p_kopyaKonuFark * fi) / sc + p_merkez;
    if (mod(float(i), 2.0) > 0.5) { if (p_yatayAyna > 0.5) l.x = -l.x; if (p_dikeyAyna > 0.5) l.y = -l.y; }
    vec4 c = texU(l); float fade = clamp(1.0 - p_opaklikKayb / 100.0 * fi, 0.0, 1.0); if (p_renkGeci > 0.5 && c.a > 0.0) c.rgb = mix(c.rgb, c_uzakKopyReng * c.a, clamp(fi / float(N), 0.0, 1.0));
    res = overPre(c * fade, res); } // her küçük kopya bir öncekinin önünde: sonsuz tünel
  o = res; }
//== depthparallax
uniform sampler2D s_derinlikHari, s_derinlikKatm; uniform float p_derinlikHariOn, p_derinlikKatmOn;
uniform float p_derinlikKayn, p_derinligTersCevi, p_derinlikGucu, p_derinlikYumu, p_derinlikKatmSayi, p_yakinlas, p_paralaksGucu, p_bosluklaDold, p_boslukDold, p_kenarlarKoru; uniform vec2 p_kameraKaym; uniform vec3 p_kameraDonu;
float depthAt(vec2 px) { vec2 b = clamp(boxUV(px), 0.0, 1.0); float d;
  if (p_derinlikKayn < 0.5 && p_derinlikHariOn > 0.5) d = luma(unpre(texture(s_derinlikHari, b))); else if (p_derinlikKayn > 0.5 && p_derinlikKayn < 1.5 && p_derinlikKatmOn > 0.5) d = luma(unpre(texture(s_derinlikKatm, b)));
  else if (p_derinlikKayn > 1.5 && p_derinlikKayn < 2.5) d = 1.0 - b.y; else d = luma(unpre(texPx(px)));
  if (p_derinligTersCevi > 0.5) d = 1.0 - d; float L = max(p_derinlikKatmSayi, 1.0); if (L < 63.5) d = floor(d * L + 0.5) / L; return d * p_derinlikGucu / 100.0; }
void main() { vec2 cam = p_kameraKaym * p_paralaksGucu / 100.0; float zoom = max(p_yakinlas / 100.0, 0.1); vec2 q = toUnit(here()); vec2 cur = q; float d = 0.0;
  for (int i = 0; i < 6; i++) { float blur = p_derinlikYumu * u_s; d = (depthAt(fromUnit(cur)) + depthAt(fromUnit(cur) + vec2(blur, 0.0)) + depthAt(fromUnit(cur) - vec2(0.0, blur))) / 3.0;
    vec2 tilt = vec2(p_kameraDonu.y, -p_kameraDonu.x) * 2.0; cur = (q - (cam + tilt) * d) / mix(1.0, zoom, d) ; }
  vec4 c = texU(cur); vec2 b = boxUV(fromUnit(cur)); bool out_ = any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)));
  if (out_ && p_bosluklaDold > 0.5) { if (p_boslukDold < 0.5) c = texEdge(fromUnit(cur), 3.0); else if (p_boslukDold < 1.5) { vec2 m = abs(mod(b, 2.0)); m = mix(m, 2.0 - m, step(1.0, m)); c = texture(u_tex, mix(v_uv, v_uv, 0.0)) * 0.0 + texPx(boxPx(m)); } else c = vec4(0.0); }
  o = c; }
//== ambientocc
uniform sampler2D s_derinlikKatm; uniform float p_derinlikKatmOn;
uniform float p_kaynak, p_golgeYari, p_yogunluk, p_derinlikHass, p_yumusakl, p_kontrast, p_alfaSiniKoru, p_yalnizGolgGost, p_kalite; uniform vec3 c_golgeReng;
float hAt(vec2 px) { if (p_kaynak > 0.5 && p_derinlikKatmOn > 0.5) return luma(unpre(texture(s_derinlikKatm, clamp(boxUV(px), 0.0, 1.0)))); if (p_kaynak > 0.5) return luma(unpre(texPx(px))) * texPx(px).a; return texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); float R = max(p_golgeYari * u_s, 1.0); int N = p_kalite < 1.5 && p_kalite > 0.5 ? 8 : p_kalite < 2.5 ? 16 : 24; float h0 = hAt(here()); float occ = 0.0;
  for (int i = 0; i < 24; i++) { if (i >= N) break; float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / float(N)); float h = hAt(here() + vec2(cos(a), sin(a)) * r);
    occ += clamp((h - h0) * (1.0 + p_derinlikHass / 25.0), 0.0, 1.0) * (1.0 - r / R * (1.0 - p_yumusakl / 100.0) * 0.5); }
  occ = clamp(occ / float(N) * 2.0 * p_yogunluk / 100.0 * 2.0, 0.0, 1.0);
  if (p_kaynak < 0.5 && s.a > 0.0) { float id = innerDist(here(), R); occ = max(occ, (1.0 - smoothstep(0.0, R, id)) * p_yogunluk / 100.0 * (0.6 + p_derinlikHass / 125.0)); } // kenara yaklaştıkça hacim gölgesi occ = pow(occ, 1.0 / (1.0 + p_kontrast / 50.0));
  if (p_yalnizGolgGost > 0.5) { o = vec4(c_golgeReng, 1.0) * occ * (p_alfaSiniKoru > 0.5 ? s.a : 1.0); return; }
  vec4 c = s; c.rgb = mix(c.rgb, c_golgeReng * c.a, occ * s.a); if (p_alfaSiniKoru < 0.5) c = overPre(c, vec4(c_golgeReng, 1.0) * occ * (1.0 - s.a)); o = c; }
//== volumelight
uniform sampler2D s_engelleyKatm; uniform float p_engelleyKatmOn;
uniform vec2 p_isikKonu; uniform float p_isikTuru, p_isikYonu, p_isinUzun, p_isinGeni, p_koniAcis, p_isikGucu, p_yumusakl, p_sisYogu, p_isikSaci, p_havadakiTozl, p_tozYogu, p_katmanlaIsigEnge; uniform vec3 c_isikReng;
float occAt(vec2 u) { if (p_katmanlaIsigEnge < 0.5) return 0.0; if (p_engelleyKatmOn > 0.5) return texture(s_engelleyKatm, clamp(boxUV(fromUnit(u)), 0.0, 1.0)).a; return texU(u).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 L = p_isikKonu; vec2 d = q - L; float r = length(d); vec2 dir = vec2(cos(radians(p_isikYonu)), sin(radians(p_isikYonu)));
  float cone; if (p_isikTuru < 0.5 || p_isikTuru > 2.5) { float ang = acos(clamp(dot(normalize(d + 1e-4), dir), -1.0, 1.0)); float half_ = radians(p_isikTuru > 2.5 ? p_koniAcis : p_koniAcis * 0.7); cone = 1.0 - smoothstep(half_ * (1.0 - p_yumusakl / 200.0), half_ * (1.0 + p_yumusakl / 200.0), ang); }
  else if (p_isikTuru < 1.5) { float px = abs(dot(d, vec2(-dir.y, dir.x))); cone = (1.0 - smoothstep(p_isinGeni * 0.4, p_isinGeni * 0.5 + p_yumusakl, px)) * step(0.0, dot(d, dir)); }
  else cone = 1.0;
  float fall = exp(-r / max(p_isinUzun, 1.0) * 2.0); float shaft = 1.0;
  if (p_katmanlaIsigEnge > 0.5) { float occ = 0.0; for (int i = 1; i <= 16; i++) { occ = max(occ, occAt(L + d * float(i) / 17.0)); } shaft = 1.0 - occ; }
  float fog = 0.35 + 0.65 * fbm(q * 0.01 + u_t * 0.05, 3.0) * p_sisYogu / 100.0 * 2.0; float rays = mix(1.0, 0.6 + 0.4 * fbm(vec2(atan(d.y, d.x) * 8.0, u_t * 0.1), 2.0), p_isikSaci / 100.0);
  float I = cone * fall * shaft * fog * rays * p_isikGucu / 100.0; float dust = 0.0;
  if (p_havadakiTozl > 0.5) { vec2 g = (q + vec2(u_t * 4.0, -u_t * 6.0)) / 7.0; vec2 id = floor(g); float hh = hash1(id); dust = step(1.0 - p_tozYogu / 100.0 * 0.3, hh) * (1.0 - smoothstep(0.03, 0.12, length(fract(g) - 0.5 - (hash2(id) - 0.5) * 0.6))) * cone * fall; }
  o = overPre(vec4(c_isikReng, 1.0) * clamp(I * 0.8 + dust, 0.0, 1.0), s); }
