// Simülasyon ve Geçiş (rehberdeki ayarlar). Parçacıklar belirlenimci: aynı kare hep aynı.
//== snow
uniform float p_yogunluk, p_enKucuTane, p_enBuyuTane, p_dususHizi, p_ruzgar, p_sallanma, p_derinlik, p_tohum, p_alfayaKirp; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); float acc = 0.0;
  for (int l = 0; l < 3; l++) { float z = 1.0 - float(l) * 0.3 * p_derinlik / 100.0; float cell = mix(60.0, 25.0, clamp(p_yogunluk / 600.0, 0.0, 1.0)) / z;
    vec2 off = vec2(p_ruzgar, p_dususHizi) * u_t * z; vec2 p = q + B * 0.5 - off + float(l) * 37.0; vec2 id = floor(p / cell);
    for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(float(i), float(j)); vec2 h = hash2(c + seedf(p_tohum) + float(l) * 9.0);
      if (h.x > clamp(p_yogunluk / 300.0, 0.05, 1.0)) continue; vec2 cp = (c + h) * cell + vec2(sin(u_t * 1.5 + h.y * 6.0) * p_sallanma, 0.0);
      float r = mix(p_enKucuTane, p_enBuyuTane, h.y) * 0.5 * z; float d = length(p - cp); acc = max(acc, (1.0 - smoothstep(r * 0.4, r, d)) * mix(0.6, 1.0, z)); } }
  vec4 f = vec4(c_renk, 1.0) * acc; if (p_alfayaKirp > 0.5) f *= s.a; o = overPre(f, s);
}
//== rain
uniform float p_yogunluk, p_damlaUzun, p_kalinlik, p_hiz, p_aci, p_opaklik, p_tohum, p_alfayaKirp; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()); float acc = 0.0; float cw = mix(14.0, 4.0, clamp(p_yogunluk / 1000.0, 0.0, 1.0));
  for (int l = 0; l < 2; l++) { float col = floor(q.x / cw); float h = hash1(vec2(col, seedf(p_tohum) + float(l) * 3.0)); float sp = p_hiz * (0.7 + 0.6 * h) * (1.0 - float(l) * 0.3);
    float per = p_damlaUzun * 4.0 + 60.0; float y = mod(q.y - u_t * sp - h * per * 7.0, per); float x = abs(fract(q.x / cw) - 0.5) * cw;
    float k = (1.0 - smoothstep(p_kalinlik * 0.5, p_kalinlik * 0.5 + 0.6 / u_s, x)) * step(y, p_damlaUzun) * (y / max(p_damlaUzun, 1.0)); acc = max(acc, k * (1.0 - float(l) * 0.4)); }
  vec4 f = vec4(c_renk, 1.0) * acc * p_opaklik / 100.0; if (p_alfayaKirp > 0.5) f *= s.a; o = overPre(f, s);
}
//== confetti
GRADIENT(renkPale)
uniform float p_yogunluk, p_boyut, p_dususHizi, p_ruzgar, p_donmeHizi, p_sekil, p_tohum, p_dongu;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec4 acc = vec4(0.0); float cell = mix(70.0, 25.0, clamp(p_yogunluk / 400.0, 0.0, 1.0));
  vec2 p = q + B * 0.5 - vec2(p_ruzgar, p_dususHizi) * u_t; vec2 id = floor(p / cell);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(float(i), float(j)); vec2 h = hash2(c + seedf(p_tohum)); vec2 h2 = hash2(c + 7.0);
    vec2 cp = (c + h) * cell + vec2(sin(u_t * 2.0 + h2.x * 6.0) * 8.0, 0.0); float ang = u_t * p_donmeHizi * (h2.y - 0.5) * 2.0 + h.x * 360.0;
    vec2 r = rot2(-ang) * (p - cp); float flip = abs(cos(u_t * 4.0 + h.y * 6.0)); float sz = p_boyut * 0.5;
    float sh = p_sekil < 3.5 ? p_sekil : floor(h2.x * 3.0); float d = sh < 0.5 ? max(abs(r.x), abs(r.y) / max(flip, 0.15)) - sz : sh < 1.5 ? max(abs(r.x) - sz * 0.35, abs(r.y) / max(flip, 0.15) - sz * 1.2) : length(r * vec2(1.0, 1.0 / max(flip, 0.15))) - sz;
    float k = 1.0 - smoothstep(-0.6 / u_s, 0.6 / u_s, d); vec3 col = grad_renkPale(h2.x) * (0.75 + 0.25 * flip); acc = overPre(vec4(col, 1.0) * k, acc); }
  if (p_dongu < 0.5 && u_t > 3.0) acc *= clamp(1.0 - (u_t - 3.0), 0.0, 1.0);
  o = overPre(acc, s);
}
//== bubbles
uniform float p_yogunluk, p_enKucuBoyu, p_enBuyuBoyu, p_yukselmeHizi, p_sallanma, p_yansima, p_saydamli, p_tohum; uniform vec3 c_kenarReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec4 acc = vec4(0.0); float cell = mix(90.0, 35.0, clamp(p_yogunluk / 200.0, 0.0, 1.0));
  vec2 p = q + B * 0.5 + vec2(0.0, p_yukselmeHizi * u_t); vec2 id = floor(p / cell);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(float(i), float(j)); vec2 h = hash2(c + seedf(p_tohum)); if (h.x > clamp(p_yogunluk / 80.0, 0.1, 1.0)) continue;
    vec2 cp = (c + h) * cell + vec2(sin(u_t * 1.3 + h.y * 6.0) * p_sallanma, 0.0); float r = mix(p_enKucuBoyu, p_enBuyuBoyu, h.y); vec2 rel = p - cp; float d = length(rel);
    if (d > r) continue; float rim = smoothstep(r * 0.75, r, d); vec3 ir = hsv2rgb(vec3(fract(atan(rel.y, rel.x) / TAU + u_t * 0.1), 0.35, 1.0));
    float spec = (1.0 - smoothstep(0.0, r * 0.25, length(rel - vec2(-0.4, -0.4) * r))) * p_yansima / 100.0;
    float a = (rim * 0.8 + (1.0 - p_saydamli / 100.0) * 0.3) ; vec3 col = mix(c_kenarReng, ir, 0.4) * a + vec3(spec); acc = overPre(vec4(col, clamp(a + spec, 0.0, 1.0)), acc); }
  o = overPre(acc, s);
}
//== fire
uniform vec2 p_alevKayn; uniform float p_yuksekli, p_genislik, p_yogunluk, p_hiz, p_turbulan, p_tohum, p_alfayaKirp; uniform vec3 c_tabanReng, c_ucReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 r = toUnit(here()) - p_alevKayn; float h = max(p_yuksekli, 1.0), w = max(p_genislik, 1.0);
  float y = -r.y / h; float x = r.x / (w * 0.5); vec2 p = vec2(x * 1.5, y * 2.0 - u_t * p_hiz) + seedf(p_tohum);
  float n = fbm(p * 2.0, 4.0) * p_turbulan / 100.0; float shape = 1.0 - smoothstep(0.0, 1.0, abs(x + n * 0.6) / max(1.0 - y * 0.85, 0.05));
  float f = shape * smoothstep(-0.05, 0.05, y) * (1.0 - smoothstep(0.6, 1.1, y + n * 0.5)) * (0.7 + 0.6 * (fbm(p * 3.0, 3.0) * 0.5 + 0.5));
  f = clamp(f * p_yogunluk / 100.0 * 1.8, 0.0, 1.0); vec3 col = mix(c_ucReng, c_tabanReng, smoothstep(0.2, 0.9, f)) + vec3(1.0, 0.95, 0.8) * smoothstep(0.8, 1.0, f) * 0.6;
  vec4 fc = vec4(col, 1.0) * f; if (p_alfayaKirp > 0.5) fc *= s.a; o = vec4(s.rgb * (1.0 - fc.a) + fc.rgb, max(s.a, fc.a));
}
//== linwipe
uniform float p_ilerleme, p_aci, p_yumusatm, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 d = vec2(cos(radians(p_aci)), sin(radians(p_aci))); vec2 B = boxU(); float span = abs(d.x) * B.x + abs(d.y) * B.y + p_yumusatm * 2.0;
  float x = dot(toUnit(here()), d) / span + 0.5; float e = (p_ilerleme / 100.0) * (1.0 + 0.0); float w = p_yumusatm / span; float k = smoothstep(e - w, e + w * 0.0 + 1e-4, x - w * 0.5 + w * 0.5);
  k = smoothstep(e - w * 0.5, e + w * 0.5 + 1e-4, x); if (p_ters > 0.5) k = 1.0 - k; o = s * k; }
//== radwipe
uniform vec2 p_merkez; uniform float p_ilerleme, p_baslangiAcis, p_yumusatm, p_yon;
void main() { vec4 s = texture(u_tex, v_uv); vec2 r = toUnit(here()) - p_merkez; float a = degrees(atan(r.y, r.x)) - p_baslangiAcis; a = mod(a + 720.0, 360.0);
  if (p_yon > 0.5 && p_yon < 1.5) a = 360.0 - a; float pr = p_ilerleme / 100.0 * 360.0; float w = max(abs(p_yumusatm), 0.01);
  float k = p_yon > 1.5 ? smoothstep(pr * 0.5 - w, pr * 0.5 + w, min(a, 360.0 - a)) : smoothstep(pr - w, pr + w, a); o = s * k; }
//== iris
uniform vec2 p_merkez; uniform float p_ilerleme, p_bicim, p_kenarSayi, p_yumusatm, p_aci, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 B = boxU(); vec2 r = rot2(-p_aci) * (toUnit(here()) - p_merkez); float R = length(B) * 0.6 * p_ilerleme / 100.0;
  float d; if (p_bicim < 0.5) d = length(r); else if (p_bicim < 1.5) d = length(r * vec2(B.y / B.x, 1.0)) * (B.x / B.y > 1.0 ? B.x / B.y : 1.0); else { float n = max(3.0, floor(p_kenarSayi)); float a = atan(r.y, r.x); d = length(r) * cos(PI / n) / cos(mod(a + PI / n, TAU / n) - PI / n); }
  float k = smoothstep(R - p_yumusatm, R + 1e-3, d); if (p_ters > 0.5) k = 1.0 - k; o = s * (1.0 - k) * step(0.001, p_ilerleme) + s * 0.0; if (p_ters > 0.5) o = s * k; }
//== dissolve
uniform float p_ilerleme, p_pikselBoyu, p_tohum, p_yumusatm, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); float n = hash1(floor(toUnit(here()) / max(p_pikselBoyu, 0.3)) + seedf(p_tohum)); float w = p_yumusatm / 100.0 * 0.5 + 1e-4;
  float k = smoothstep(p_ilerleme / 100.0 - w, p_ilerleme / 100.0 + w, n * (1.0 + 2.0 * w) - w); if (p_ters > 0.5) k = 1.0 - k; o = s * k; }
//== blockdissolve
uniform float p_ilerleme, p_blokX, p_blokY, p_tohum, p_yumusatm, p_boyutlarBagl, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 bs = vec2(max(p_blokX, 1.0), max(p_boyutlarBagl > 0.5 ? p_blokX : p_blokY, 1.0)); float n = hash1(floor(toUnit(here()) / bs) + seedf(p_tohum));
  float w = p_yumusatm / 100.0 * 0.5 + 1e-4; float k = smoothstep(p_ilerleme / 100.0 - w, p_ilerleme / 100.0 + w, n * (1.0 + 2.0 * w) - w); if (p_ters > 0.5) k = 1.0 - k; o = s * k; }
//== blinds
uniform float p_ilerleme, p_seritGeni, p_aci, p_yumusatm, p_yon, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = rot2(-p_aci) * toUnit(here()); float w = max(p_seritGeni, 1.0); float f = fract(p.y / w);
  if (p_yon > 0.5) f = abs(f - 0.5) * 2.0; float e = p_ilerleme / 100.0; float sw = p_yumusatm / w + 1e-4; float k = smoothstep(e - sw, e + sw, f); if (p_ters > 0.5) k = 1.0 - k; o = s * k; }
//== shatter
uniform vec2 p_merkez; uniform float p_ilerleme, p_parcaSayi, p_parcaBici, p_dagilma, p_donus, p_yercekim, p_derinlik, p_tohum, p_otomatik, p_sure;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float pr = p_otomatik > 0.5 ? clamp(u_t / max(p_sure, 0.05), 0.0, 1.0) : p_ilerleme / 100.0; if (pr <= 0.0) { o = texture(u_tex, v_uv); return; }
  float cs = sqrt(B.x * B.y / max(p_parcaSayi, 2.0)); vec4 res = vec4(0.0);
  // Parçalar hücrelerde; her pikselde yakın hücrelerin parçası geri dönüştürülerek aranır
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) {
    vec2 cid = floor(q / cs) + vec2(float(i), float(j)); vec2 h = hash2(cid + seedf(p_tohum)); vec2 home = (cid + 0.5) * cs;
    vec2 dir = normalize(home - p_merkez + (h - 0.5) * cs); float dist = p_dagilma * pr * (0.5 + h.x) ; vec2 pos = home + dir * dist + vec2(0.0, p_yercekim * pr * pr * 0.6);
    float ang = p_donus * pr * (h.y - 0.5) * 2.0; float sc = 1.0 - p_derinlik / 100.0 * pr * h.y * 0.6;
    vec2 local = rot2(-ang) * (q - pos) / max(sc, 0.05); vec2 src = home + local;
    // kaynak nokta bu parçanın hücresinde mi (cam: voronoi benzeri sınır)
    vec2 sid = floor(src / cs); bool own = sid == cid;
    if (p_parcaBici < 0.5) { vec4 v = voronoi(src / cs + seedf(p_tohum)); own = distance(v.zw, cid + seedf(p_tohum) - fract(seedf(p_tohum))) < 0.5 || own; }
    if (!own) continue; vec4 c = texU(src); c.rgb *= 1.0 - 0.25 * pr * h.x; res = overPre(res, c * (1.0 - res.a) + res * 0.0); if (res.a > 0.99) break; }
  o = res;
}
//== pixelpolly
uniform float p_ilerleme, p_ucgenBoyu, p_dagilma, p_yon, p_donme, p_yercekim, p_tohum, p_sure, p_otomatik;
void main() {
  vec2 q = toUnit(here()); float pr = p_otomatik > 0.5 ? clamp(u_t / max(p_sure, 0.05), 0.0, 1.0) : p_ilerleme / 100.0; if (pr <= 0.0) { o = texture(u_tex, v_uv); return; }
  float cs = max(p_ucgenBoyu, 2.0); vec2 dir0 = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec4 res = vec4(0.0);
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) for (int t = 0; t < 2; t++) {
    vec2 cid = floor(q / cs) + vec2(float(i), float(j)); vec2 h = hash2(cid * 2.0 + float(t) + seedf(p_tohum)); vec2 home = (cid + (t == 0 ? vec2(0.33) : vec2(0.67))) * cs;
    float delay = h.x * 0.5; float pp = clamp((pr - delay) / max(1.0 - delay, 0.05), 0.0, 1.0);
    vec2 pos = home + (dir0 + (h - 0.5)) * p_dagilma * pp + vec2(0.0, p_yercekim * pp * pp * 0.5); float ang = p_donme * pp * (h.y - 0.5) * 2.0;
    vec2 src = home + rot2(-ang) * (q - pos); vec2 f = src / cs - cid; bool tri = t == 0 ? (f.x + f.y < 1.0) : (f.x + f.y >= 1.0);
    if (any(lessThan(f, vec2(0.0))) || any(greaterThan(f, vec2(1.0))) || !tri) continue;
    vec4 c = texU(src) * (1.0 - pp * 0.3); res = overPre(res, c); if (res.a > 0.99) break; }
  o = res;
}
//== carddance
uniform float p_satir, p_sutun, p_donusX, p_donusY, p_dalgaYonu, p_faz, p_dalgaBoyu, p_frekans, p_perspekt; uniform vec3 c_arkaYuzReng;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); vec2 cs = B / n; vec4 res = vec4(0.0);
  vec2 wd = vec2(cos(radians(p_dalgaYonu)), sin(radians(p_dalgaYonu)));
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) {
    vec2 id = floor((q + B * 0.5) / cs) + vec2(float(i), float(j)); if (any(lessThan(id, vec2(0.0))) || any(greaterThanEqual(id, n))) continue; vec2 c = (id + 0.5) * cs - B * 0.5;
    float ph = sin(dot(c, wd) / max(p_dalgaBoyu, 1.0) * TAU - u_t * p_frekans * TAU + radians(p_faz)); float ax = radians(p_donusX * ph), ay = radians(p_donusY * ph);
    // kartın düzlemi: x eksenine (ax) ve y eksenine (ay) göre döner; ışın-düzlem kesişimi (yaklaşık perspektif)
    vec3 nx = vec3(cos(ay), 0.0, -sin(ay)); vec3 ny = vec3(sin(ax) * sin(ay), cos(ax), sin(ax) * cos(ay)); vec3 nn = cross(nx, ny);
    vec3 ro = vec3(q - c, 0.0); float F = max(B.x, B.y) * mix(6.0, 1.2, p_perspekt / 100.0); vec3 rd = normalize(vec3((q - c) * 0.0, 0.0) - vec3(0.0, 0.0, F) + vec3(q - c, 0.0)) ; vec3 eye = vec3(0.0, 0.0, F);
    vec3 dir = normalize(vec3(q - c, 0.0) - eye); float den = dot(nn, dir); if (abs(den) < 1e-4) continue; float t = -dot(nn, eye) / den; vec3 hit = eye + dir * t;
    vec2 uv = vec2(dot(hit, nx), dot(hit, ny)); if (abs(uv.x) > cs.x * 0.5 || abs(uv.y) > cs.y * 0.5) continue;
    vec4 col = texU(c + uv); if (den > 0.0) col = vec4(c_arkaYuzReng, 1.0) * col.a; col.rgb *= 0.75 + 0.25 * abs(nn.z); res = overPre(res, col); }
  o = res;
}
//== caustics
uniform float p_desenOlce, p_isikGucu, p_kirilma, p_hiz, p_suDeri, p_kontrast, p_tohum; uniform vec3 c_isikReng;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 p = toUnit(here()) / max(p_desenOlce, 1.0) + seedf(p_tohum); float t = u_t * p_hiz * 0.5;
  vec2 w = vec2(pnoise(p + t), pnoise(p - t + 3.0)) * p_kirilma / 100.0; vec4 v = voronoi(p * 1.5 + w); float c = pow(clamp(1.0 - (v.y - v.x) * 3.0, 0.0, 1.0), mix(2.0, 8.0, p_kontrast / 100.0));
  vec3 col = unpre(s) + c_isikReng * c * p_isikGucu / 100.0 * 1.2; o = pre(clamp(col, 0.0, 1.0), s.a); }
//== waveworld
uniform vec2 p_kaynak; uniform float p_dalgaYuks, p_dalgaBoyu, p_hiz, p_dalgaBici, p_yon, p_sonum, p_kenar;
void main() { vec2 q = toUnit(here()); vec2 r = q - p_kaynak; float d = length(r); float wl = max(p_dalgaBoyu, 1.0); vec2 disp;
  if (p_dalgaBici < 0.5) disp = (d > 0.01 ? r / d : vec2(0.0)) * sin(d / wl * TAU - u_t * p_hiz * TAU) * exp(-d / (length(boxU()) * 0.5) * p_sonum / 50.0);
  else if (p_dalgaBici < 1.5) { vec2 dir = vec2(cos(radians(p_yon)), sin(radians(p_yon))); disp = dir * sin(dot(q, dir) / wl * TAU - u_t * p_hiz * TAU); }
  else disp = vec2(fbm(q / wl + u_t * p_hiz * 0.3, 3.0), fbm(q / wl + 4.0 - u_t * p_hiz * 0.3, 3.0));
  o = texEdge(fromUnit(q + disp * p_dalgaYuks), p_kenar < 0.5 ? 0.0 : p_kenar < 1.5 ? 3.0 : 1.0); }
//== mercury
uniform vec2 p_yayici; uniform float p_damlacikSayi, p_damlacikBoyu, p_hiz, p_yercekim, p_viskozit, p_omur, p_metalParl, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float field = 0.0; vec3 col = vec3(0.0); int N = int(clamp(p_damlacikSayi, 1.0, 48.0));
  for (int i = 0; i < 48; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum))); float life = max(p_omur, 0.1); float lt = mod(u_t + h.x * life, life);
    vec2 v = vec2(cos(h.y * TAU), sin(h.y * TAU) - 0.5) * p_hiz * mix(1.0, 0.4, p_viskozit / 100.0); vec2 pos = p_yayici + v * lt + vec2(0.0, 0.5 * p_yercekim * lt * lt);
    float r = p_damlacikBoyu * (1.0 - lt / life * 0.5); float d2 = dot(q - pos, q - pos); float f = r * r / max(d2, 1e-3); field += f; col += texU(pos).rgb * f; }
  float own = s.a * 1.5; field += own; float m = smoothstep(0.9, 1.1, field);
  vec2 g = vec2(dFdx(field), dFdy(field)); vec3 nrm = normalize(vec3(-g * 0.5, 1.0)); float spec = pow(max(dot(reflect(vec3(-0.5, 0.5, -1.0), nrm), vec3(0, 0, 1)), 0.0), 20.0) * p_metalParl / 100.0;
  vec3 base = mix(vec3(0.75, 0.78, 0.82), unpre(s), 0.25) * (0.6 + 0.4 * nrm.z) + spec; o = pre(clamp(base, 0.0, 1.0), m);
}
//== foam
uniform vec2 p_yayici; uniform float p_kopukSayi, p_boyut, p_boyutDegi, p_yukselmeHizi, p_birlesme, p_opaklik, p_tohum; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec4 acc = vec4(0.0); int N = int(clamp(p_kopukSayi, 1.0, 96.0)); float field = 0.0;
  for (int i = 0; i < 96; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum) + 3.0)); float life = boxU().y / max(p_yukselmeHizi, 1.0); float lt = mod(u_t + h.x * life, life);
    vec2 pos = p_yayici + vec2((h.y - 0.5) * boxU().x * 0.6 + sin(lt * 2.0 + h.x * 6.0) * 6.0, -p_yukselmeHizi * lt); float r = p_boyut * mix(1.0, 0.4 + h.y, p_boyutDegi / 100.0);
    float d = length(q - pos); field += exp(-pow(d / max(r, 0.5), 2.0) * mix(6.0, 2.0, p_birlesme / 100.0)); float ring = smoothstep(r * 0.7, r, d) * (1.0 - smoothstep(r, r + 1.0, d)); acc = max(acc, vec4(ring)); }
  float m = smoothstep(0.4, 0.6, field); vec3 col = c_renk * (0.85 + 0.15 * acc.r); o = overPre(vec4(col, 1.0) * m * p_opaklik / 100.0, s);
}
//== particles
uniform vec2 p_yayici; uniform float p_uretimHizi, p_hiz, p_yon, p_yayilim, p_yercekim, p_omur, p_boyut, p_tohum, p_tekSefe; uniform vec3 c_baslangiReng, c_bitisReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec3 acc = vec3(0.0); float al = 0.0; float life = max(p_omur, 0.05); int N = int(clamp(p_uretimHizi * life, 1.0, 128.0));
  for (int i = 0; i < 128; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum))); float born = p_tekSefe > 0.5 ? 0.0 : h.x * life; float lt = p_tekSefe > 0.5 ? u_t : mod(u_t - born, life);
    if (lt > life) continue; float a = radians(p_yon + (h.y - 0.5) * p_yayilim); vec2 v = vec2(cos(a), sin(a)) * p_hiz * (0.6 + 0.8 * fract(h.x * 7.3));
    vec2 pos = p_yayici + v * lt + vec2(0.0, 0.5 * p_yercekim * lt * lt); float k = lt / life; float r = p_boyut * 0.5 * (1.0 - k * 0.6); float d = length(q - pos);
    float m = (1.0 - smoothstep(r * 0.3, r, d)) * (1.0 - k); acc += mix(c_baslangiReng, c_bitisReng, k) * m; al = max(al, m); }
  o = vec4(min(s.rgb * (1.0 - al) + acc, vec3(1.0)), max(s.a, al));
}
//== scatterize
uniform float p_ilerleme, p_parcaBoyu, p_ruzgarYonu, p_savrulma, p_turbulan, p_kenarGeci, p_tohum, p_otomatik, p_sure;
void main() {
  vec2 q = toUnit(here()); float pr = p_otomatik > 0.5 ? clamp(u_t / max(p_sure, 0.05), 0.0, 1.0) : p_ilerleme / 100.0; if (pr <= 0.0) { o = texture(u_tex, v_uv); return; }
  vec2 dir = vec2(cos(radians(p_ruzgarYonu)), sin(radians(p_ruzgarYonu))); float ps = max(p_parcaBoyu, 0.5); vec4 res = vec4(0.0); vec2 B = boxU();
  for (int k = 0; k < 12; k++) { float t = float(k) / 11.0; vec2 src = q - dir * p_savrulma * pr * t * 1.2; vec2 id = floor(src / ps); float h = hash1(id + seedf(p_tohum));
    float start = clamp(dot(src / B + 0.5, dir) * (1.0 - p_kenarGeci / 100.0) + h * p_kenarGeci / 100.0, 0.0, 1.0); float pp = clamp((pr * 1.4 - start * 0.9) / 0.6, 0.0, 1.0);
    vec2 turb = vec2(pnoise(id * 0.1 + 3.0), pnoise(id * 0.1 + 9.0)) * p_turbulan / 100.0 * p_savrulma * 0.3 * pp;
    vec2 pos = (id + 0.5) * ps + dir * p_savrulma * pp + turb; if (length(q - pos) < ps * 0.6) { vec4 c = texU((id + 0.5) * ps) * (1.0 - pp); res = max(res, c); } }
  o = res;
}
//== drizzle
uniform float p_damlaSikl, p_halkaYari, p_dalgaYuks, p_omur, p_sonum, p_tohum, p_isikYans;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); vec2 disp = vec2(0.0); float lit = 0.0; float per = 1.0 / max(p_damlaSikl, 0.05);
  for (int i = 0; i < 8; i++) { float k = floor(u_t / per) - float(i); float t = u_t - k * per; if (t > p_omur || k < 0.0) continue; vec2 c = (hash2(vec2(k, seedf(p_tohum))) - 0.5) * B;
    vec2 r = q - c; float d = length(r); float R = p_halkaYari * t / max(p_omur, 0.05); float w = exp(-pow((d - R) / 6.0, 2.0)) * (1.0 - t / max(p_omur, 0.05)) * mix(1.0, 0.3, p_sonum / 100.0 * t);
    disp += (d > 0.01 ? r / d : vec2(0.0)) * w * p_dalgaYuks * sin((d - R) * 0.8); lit += w; }
  vec4 c = texU(q + disp); if (p_isikYans > 0.5) c.rgb += vec3(lit * 0.15) * c.a; o = c; }
//== hair
uniform float p_yogunluk, p_uzunluk, p_kalinlik, p_yon, p_rastgeleAci, p_ruzgar, p_tohum, p_kaynakReng; uniform vec3 c_kokReng, c_ucReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cell = max(sqrt(boxU().x * boxU().y / max(p_yogunluk, 1.0)), 2.0); vec4 acc = vec4(0.0);
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 id = floor(q / cell) + vec2(float(i), float(j)); vec2 h = hash2(id + seedf(p_tohum)); vec2 root = (id + h) * cell;
    vec4 rc = texU(root); if (rc.a < 0.5) continue; vec2 g = alphaGrad(fromUnit(root), 2.0); if (length(g) * 4.0 < 0.05 && p_yon > 900.0) continue;
    float a = radians(p_yon + (h.x - 0.5) * 2.0 * p_rastgeleAci) + sin(u_t * 2.0 + h.y * 6.0) * p_ruzgar / 100.0 * 0.4; vec2 dir = vec2(cos(a), sin(a)); float L = p_uzunluk * (0.6 + 0.4 * h.y);
    vec2 rel = q - root; float t = clamp(dot(rel, dir) / max(L, 1.0), 0.0, 1.0); float d = length(rel - dir * t * L); float w = p_kalinlik * 0.5 * (1.0 - t * 0.7);
    float m = (1.0 - smoothstep(w, w + 0.7 / u_s, d)) * step(0.0, dot(rel, dir)); vec3 col = mix(p_kaynakReng > 0.5 ? unpre(rc) * 0.7 : c_kokReng, p_kaynakReng > 0.5 ? unpre(rc) * 1.2 : c_ucReng, t); acc = max(acc, vec4(col, 1.0) * m); }
  o = overPre(acc, s);
}
//== ballaction
uniform float p_topAral, p_topBoyu, p_dagilma, p_donusX, p_donusY, p_derinlik, p_isik, p_tohum, p_kaynakReng;
void main() { vec2 q = toUnit(here()); float sp = max(p_topAral, 2.0); vec4 res = vec4(0.0); float sc = 1.0;
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 id = floor(q / sp) + vec2(float(i), float(j)); vec2 home = (id + 0.5) * sp; vec4 c = texU(home); if (c.a < 0.1) continue;
    vec3 h = vec3(hash2(id + seedf(p_tohum)), hash1(id + 9.0)) - 0.5; vec3 p3 = vec3(home, 0.0) + h * p_dagilma * vec3(1.0, 1.0, p_derinlik / 50.0);
    float ax = radians(p_donusX), ay = radians(p_donusY); p3.yz = mat2(cos(ax), sin(ax), -sin(ax), cos(ax)) * p3.yz; p3.xz = mat2(cos(ay), -sin(ay), sin(ay), cos(ay)) * p3.xz;
    float r = sp * 0.5 * p_topBoyu / 100.0 * (1.0 + p3.z / 600.0); vec2 rel = q - p3.xy; float d = length(rel); if (d > r) continue;
    vec3 n = vec3(rel / r, sqrt(max(0.0, 1.0 - dot(rel, rel) / (r * r)))); float l = 0.5 + 0.5 * dot(n, normalize(vec3(-0.5, -0.6, 0.8)));
    vec3 col = (p_kaynakReng > 0.5 ? unpre(c) : vec3(0.85)) * mix(1.0, l, p_isik / 100.0) + pow(l, 20.0) * p_isik / 100.0 * 0.5; res = overPre(res, vec4(col, 1.0) * (1.0 - res.a)); }
  o = res; }
//== brokenglass
uniform vec2 p_catlakMerk; uniform float p_anaCatl, p_dalSayi, p_catlakKali, p_catlakUzun, p_kirilma, p_tohum; uniform vec3 c_renk;
void main() { vec2 q = toUnit(here()); vec2 r = q - p_catlakMerk; float d = length(r); float a = atan(r.y, r.x); float n = max(1.0, floor(p_anaCatl)); float sd = seedf(p_tohum);
  float seg = TAU / n; float ai = floor(a / seg); float rnd = hash1(vec2(ai, sd)); float ca = (ai + 0.5 + (rnd - 0.5) * 0.6) * seg; float off = abs(sin(a - ca)) * d;
  float wob = (vnoise(vec2(d * 0.05, ai + sd)) - 0.5) * 6.0; float line = (1.0 - smoothstep(p_catlakKali * 0.5, p_catlakKali * 0.5 + 0.8, abs(off + wob))) * step(d, p_catlakUzun * (0.6 + 0.4 * rnd));
  float rings = 0.0; for (int k = 1; k <= 4; k++) { if (float(k) > p_dalSayi + 1.0) break; float rr = p_catlakUzun * float(k) / (p_dalSayi + 2.0) * (0.8 + 0.4 * hash1(vec2(ai, float(k)))); rings = max(rings, (1.0 - smoothstep(p_catlakKali * 0.4, p_catlakKali * 0.4 + 0.8, abs(d - rr))) * step(0.5, hash1(vec2(ai * 3.0, float(k) + sd)))); }
  vec2 sh = vec2(hash1(vec2(ai, 1.0 + sd)), hash1(vec2(ai, 2.0 + sd))) - 0.5; vec4 c = texU(q + sh * p_kirilma * step(d, p_catlakUzun));
  float crack = max(line, rings); o = overPre(vec4(c_renk, 1.0) * crack * 0.85, c); }
//== cardwipe
uniform float p_ilerleme, p_satir, p_sutun, p_eksen, p_sira, p_perspekt, p_tohum; uniform vec3 c_arkaYuzReng;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); vec2 cs = B / n; vec2 id = floor((q + B * 0.5) / cs);
  if (any(lessThan(id, vec2(0.0))) || any(greaterThanEqual(id, n))) { o = vec4(0.0); return; } vec2 c = (id + 0.5) * cs - B * 0.5; vec2 g = id / max(n - 1.0, 1.0);
  float ord = p_sira < 0.5 ? g.x : p_sira < 1.5 ? 1.0 - g.x : p_sira < 2.5 ? g.y : p_sira < 3.5 ? 1.0 - g.y : hash1(id + seedf(p_tohum));
  float pp = clamp(p_ilerleme / 100.0 * 1.5 - ord * 0.5, 0.0, 1.0); float ang = pp * PI; float cf = cos(ang); vec2 rel = q - c;
  float persp = 1.0 + sin(ang) * p_perspekt / 100.0 * 0.3 * (p_eksen < 0.5 ? rel.x / cs.x : rel.y / cs.y);
  vec2 src = p_eksen < 0.5 ? vec2(rel.x, rel.y / max(abs(cf), 0.01)) : vec2(rel.x / max(abs(cf), 0.01), rel.y); src /= persp;
  if (abs(src.x) > cs.x * 0.5 || abs(src.y) > cs.y * 0.5) { o = vec4(0.0); return; } vec4 col = texU(c + src); if (cf < 0.0) col = vec4(c_arkaYuzReng, 1.0) * col.a; col.rgb *= 0.6 + 0.4 * abs(cf); o = col; }
//== glasswipe
uniform vec2 p_merkez; uniform float p_ilerleme, p_parcaSayi, p_dagilma, p_kirilma, p_kenarParl, p_tohum, p_ters;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); float pr = p_ilerleme / 100.0; if (p_ters > 0.5) pr = 1.0 - pr; float cs = sqrt(B.x * B.y / max(p_parcaSayi, 2.0));
  vec4 v = voronoi(q / cs + seedf(p_tohum)); vec2 cid = v.zw; float h = hash1(cid); float d = length((cid - seedf(p_tohum)) * cs - p_merkez) / length(B);
  float pp = clamp(pr * 1.8 - d - h * 0.3, 0.0, 1.0); vec2 off = (hash2(cid) - 0.5) * p_dagilma * pp + vec2(0.0, p_dagilma * pp * pp); vec4 c = texU(q - off + (hash2(cid + 3.0) - 0.5) * p_kirilma);
  float edge = 1.0 - smoothstep(0.0, 0.08, v.y - v.x); c.rgb += edge * p_kenarParl / 100.0 * c.a * (1.0 - pp); o = c * (1.0 - pp); }
//== gridwipe
uniform float p_ilerleme, p_satir, p_sutun, p_bicim, p_aci, p_sira, p_yumusatm, p_tohum;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); vec2 cs = B / n; vec2 id = floor((q + B * 0.5) / cs); vec2 c = (id + 0.5) * cs - B * 0.5; vec2 g = id / max(n - 1.0, 1.0);
  float ord = p_sira < 0.5 ? length(g - 0.5) * 1.4 : p_sira < 1.5 ? g.x : p_sira < 2.5 ? 1.0 - g.x : hash1(id + seedf(p_tohum)); float pp = clamp(p_ilerleme / 100.0 * 1.6 - ord * 0.6, 0.0, 1.0);
  float sc = p_bicim > 0.5 && p_bicim < 1.5 ? 1.0 : 1.0 - pp; float ang = p_bicim > 0.5 ? p_aci * pp : 0.0; vec2 src = rot2(-ang) * (q - c) / max(sc, 0.001);
  if (abs(src.x) > cs.x * 0.5 || abs(src.y) > cs.y * 0.5 || (p_bicim > 0.5 && p_bicim < 1.5 && pp > 0.999)) { o = vec4(0.0); return; } o = texU(c + src) * (p_bicim > 0.5 && p_bicim < 1.5 ? 1.0 - pp : 1.0); }
//== jaws
uniform float p_ilerleme, p_disBoyu, p_disYuks, p_aci, p_yumusatm, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = rot2(-p_aci) * toUnit(here()); vec2 B = boxU(); float pr = p_ilerleme / 100.0; float sep = pr * B.y * 0.6;
  float tooth = abs(fract(p.x / max(p_disBoyu, 1.0)) - 0.5) * 2.0 * p_disYuks - p_disYuks * 0.5; vec2 sU = p + vec2(0.0, sep), sD = p - vec2(0.0, sep);
  vec4 c = vec4(0.0); if (sU.y < tooth) c = texU(rot2(p_aci) * sU); else if (sD.y > tooth) c = texU(rot2(p_aci) * sD); if (p_ters > 0.5) c = s * step(0.5, 1.0 - c.a) * 0.0 + c; o = c; }
//== lightwipe
uniform float p_ilerleme, p_aci, p_isikGeni, p_parlama, p_yumusatm, p_ters; uniform vec3 c_isikReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 d = vec2(cos(radians(p_aci)), sin(radians(p_aci))); vec2 B = boxU(); float span = abs(d.x) * B.x + abs(d.y) * B.y + p_isikGeni * 2.0;
  float x = dot(toUnit(here()), d) + span * 0.5; float e = p_ilerleme / 100.0 * span; float k = smoothstep(e - p_yumusatm * 0.5, e + p_yumusatm * 0.5 + 1e-3, x); if (p_ters > 0.5) k = 1.0 - k;
  float band = exp(-pow((x - e) / max(p_isikGeni * 0.5, 0.5), 2.0)) * step(0.001, p_ilerleme) * step(p_ilerleme, 99.9); vec4 c = s * k; c.rgb += c_isikReng * band * p_parlama / 100.0 * s.a; c.a = max(c.a, band * s.a * p_parlama / 100.0); o = c; }
//== linesweep
uniform float p_ilerleme, p_cizgiSayi, p_aci, p_cizgiGeni, p_gecikme, p_yumusatm, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = rot2(-p_aci) * toUnit(here()); vec2 B = boxU(); float n = max(1.0, floor(p_cizgiSayi)); float y = (p.y / B.y + 0.5) * n; float id = floor(y);
  float delay = id / n * p_gecikme / 100.0; float pp = clamp((p_ilerleme / 100.0 - delay) / max(1.0 - p_gecikme / 100.0, 0.05), 0.0, 1.0); float x = p.x / B.x + 0.5;
  float on = step(x, pp) * step(abs(fract(y) - 0.5) * 2.0, 1.0 - p_cizgiGeni / 100.0 * (1.0 - pp)); if (p_ters > 0.5) on = 1.0 - on; o = s * on; }
//== radscalewipe
uniform vec2 p_merkez; uniform float p_ilerleme, p_olcek, p_yumusatm, p_ters;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); float pr = p_ilerleme / 100.0; if (p_ters > 0.5) pr = 1.0 - pr; float R = pr * length(B) * 0.6; vec2 r = q - p_merkez; float d = length(r);
  float k = smoothstep(R - p_yumusatm, R + 1e-3, d); float push = 1.0 + (p_olcek / 100.0 - 1.0) * pr; vec2 src = p_merkez + r / push * max(1.0 - R / max(d, 1e-3), 0.0) + (d > 0.0 ? r / d : vec2(0.0)) * 0.0;
  src = p_merkez + (d > 0.0 ? r / d : vec2(0.0)) * max(d - R, 0.0) / push * push; o = texU(mix(q, src, pr)) * k; }
//== scalewipe
uniform vec2 p_sabitNokt; uniform float p_ilerleme, p_aci, p_olcek, p_yumusatm, p_ters;
void main() { vec2 q = toUnit(here()); float pr = p_ilerleme / 100.0; if (p_ters > 0.5) pr = 1.0 - pr; vec2 d = vec2(cos(radians(p_aci)), sin(radians(p_aci))); vec2 r = q - p_sabitNokt;
  float s = 1.0 + (p_olcek / 100.0 - 1.0) * pr; float along = dot(r, d); vec2 src = p_sabitNokt + r - d * along + d * along / s; o = texU(src) * (1.0 - smoothstep(0.7, 1.0, pr)); }
//== twister
uniform vec2 p_merkez; uniform float p_ilerleme, p_bukulmeAcis, p_eksen, p_perspekt, p_golge, p_ters; uniform vec3 c_arkaYuzReng;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); float pr = p_ilerleme / 100.0; if (p_ters > 0.5) pr = 1.0 - pr; vec2 ax = vec2(cos(radians(p_eksen)), sin(radians(p_eksen))); vec2 nx = vec2(-ax.y, ax.x);
  vec2 r = q - p_merkez; float along = dot(r, ax); float across = dot(r, nx); float L = abs(dot(B, abs(ax))); float ang = radians(p_bukulmeAcis) * pr * 2.0 * (0.5 + along / max(L, 1.0)) + PI * pr;
  float c = cos(ang); if (abs(c) < 0.02) { o = vec4(0.0); return; } float W = abs(dot(B, abs(nx))) * 0.5; float src_ = across / c * (1.0 + sin(ang) * p_perspekt / 100.0 * 0.2 * across / max(W, 1.0));
  if (abs(src_) > W) { o = vec4(0.0); return; } vec4 col = texU(p_merkez + ax * along + nx * src_); if (c < 0.0) col = vec4(c_arkaYuzReng, 1.0) * col.a; col.rgb *= 1.0 - (1.0 - abs(c)) * p_golge / 100.0; o = col; }
//== warpomatic
uniform float p_ilerleme, p_bukmeGucu, p_gurultuOlce, p_evrim, p_yumusatm, p_tohum, p_ters;
void main() { vec2 q = toUnit(here()); float pr = p_ilerleme / 100.0; if (p_ters > 0.5) pr = 1.0 - pr; vec2 p = q / max(p_gurultuOlce, 1.0) + seedf(p_tohum) + radians(p_evrim) * 0.3;
  vec2 d = vec2(fbm(p, 3.0), fbm(p + 5.0, 3.0)); vec4 c = texU(q + d * p_bukmeGucu * pr); float n = fbm(p * 2.0, 3.0) * 0.5 + 0.5; float w = p_yumusatm / 100.0 * 0.5 + 0.01;
  o = c * (1.0 - smoothstep(n - w, n + w, pr)); }
//== gradwipe
uniform sampler2D s_haritaKatm; uniform float p_haritaKatmOn; uniform float p_ilerleme, p_harita, p_yumusakl, p_olcek, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); float m; if (p_harita > 1.5 && p_haritaKatmOn > 0.5) m = luma(unpre(texture(s_haritaKatm, clamp(boxUV(here()), 0.0, 1.0))));
  else if (p_harita > 0.5) m = fbm(toUnit(here()) / max(p_olcek, 1.0), 4.0) * 0.5 + 0.5; else m = luma(unpre(s)); if (p_ters > 0.5) m = 1.0 - m;
  float w = p_yumusakl / 100.0 * 0.5 + 1e-3; float pr = p_ilerleme / 100.0 * (1.0 + 2.0 * w) - w; o = s * smoothstep(pr - w, pr + w, m); }
//== inkwipe
uniform vec2 p_merkez; uniform float p_ilerleme, p_lekeBoyu, p_kenarPuru, p_dallanma, p_yumusatm, p_tohum, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 r = q - p_merkez; float d = length(r) / (length(boxU()) * 0.6); float a = atan(r.y, r.x);
  float n = fbm(vec2(a * 2.0, seedf(p_tohum)) + d * 2.0, 4.0) * p_kenarPuru / 100.0 * 0.6 + fbm(q / max(p_lekeBoyu, 1.0) * 2.0, 3.0) * p_dallanma / 100.0 * 0.4;
  float pr = p_ilerleme / 100.0 * 1.3; float w = p_yumusatm / 100.0 * 0.2 + 0.005; float k = 1.0 - smoothstep(pr - w, pr + w, d + n); if (p_ters > 0.5) k = 1.0 - k; o = s * k; }
//== particleworld
uniform vec2 p_yayiciKonu; uniform float p_derinlik, p_uretimHizi, p_hiz, p_omur, p_yercekim, p_yayilim, p_parcacikBoyu, p_kameraAcis, p_tohum, p_derinlikSira; uniform vec3 c_baslangiReng, c_bitisReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec3 acc = vec3(0.0); float al = 0.0; float life = max(p_omur, 0.05); int N = int(clamp(p_uretimHizi * life * 0.5, 1.0, 128.0)); float F = 800.0;
  for (int i = 0; i < 128; i++) { if (i >= N) break; vec3 h = vec3(hash2(vec2(float(i), seedf(p_tohum))), hash1(vec2(float(i), 7.0))); float lt = mod(u_t + h.x * life, life);
    float a1 = (h.y - 0.5) * radians(p_yayilim), a2 = (h.z - 0.5) * radians(p_yayilim); vec3 v = vec3(sin(a1), -cos(a1) * cos(a2), sin(a2)) * p_hiz;
    vec3 p = vec3(p_yayiciKonu, p_derinlik) + v * lt + vec3(0.0, 0.5 * p_yercekim * lt * lt, 0.0); float ca = radians(p_kameraAcis + u_t * 0.0); p.xz = mat2(cos(ca), -sin(ca), sin(ca), cos(ca)) * p.xz;
    float sc = F / max(F + p.z, 50.0); vec2 sp = p.xy * sc; float k = lt / life; float r = p_parcacikBoyu * 0.5 * sc; float m = (1.0 - smoothstep(r * 0.3, r, length(q - sp))) * (1.0 - k);
    acc += mix(c_baslangiReng, c_bitisReng, k) * m * (p_derinlikSira > 0.5 ? mix(0.5, 1.0, sc) : 1.0); al = max(al, m); }
  o = vec4(min(s.rgb * (1.0 - al) + acc, vec3(1.0)), max(s.a, al)); }
