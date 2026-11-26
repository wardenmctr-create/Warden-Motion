// 800 rehberi, bölüm 10: geçişler (ilerleme: 0 = katman tam görünür, 100 = tamamen geçti) ve pratik kurgu
//== swishpan
uniform float p_yon, p_ivme, p_bulanikl, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; float e = mix(p, p * p * (3.0 - 2.0 * p), p_ivme / 100.0); vec2 d = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec2 q = toUnit(here()); vec2 sh = d * e * length(boxU()) * 1.2;
  float bl = p_bulanikl * sin(p * PI) * u_s; vec4 acc = vec4(0.0); for (int i = 0; i < 16; i++) acc += texU(q - sh + d * bl / u_s * (float(i) / 15.0 - 0.5)); o = acc / 16.0; }
//== filmroll
uniform float p_yon, p_hiz, p_cerceveAral, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 d = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec2 q = toUnit(here()); vec2 B = boxU(); float L = dot(abs(d), B) + p_cerceveAral;
  float off = p * L * (p_hiz / 100.0); vec2 sq = q + d * off; float k = dot(sq, d); float cell = floor((k + dot(abs(d), B) * 0.5) / L); vec2 local = sq - d * cell * L; vec4 c = cell == 0.0 ? texU(local) : vec4(0.0);
  vec2 n = vec2(-d.y, d.x); float side = abs(dot(q, n)) - dot(abs(n), B) * 0.5; float holes = step(0.0, side + 10.0) * step(side, 10.0); vec4 strip = vec4(0.08, 0.07, 0.06, 1.0) * holes * (1.0 - step(0.6, fract(dot(q, d) / 14.0)) * step(abs(side - 0.0), 6.0) * 0.0);
  float gap = abs(fract((k + dot(abs(d), B) * 0.5) / L) * L - dot(abs(d), B) - p_cerceveAral * 0.5) < p_cerceveAral * 0.5 ? 1.0 : 0.0; o = overPre(c, vec4(0.08, 0.07, 0.06, 1.0) * max(gap * 0.0, holes) * step(0.001, p)); }
//== focuspull
uniform float p_azamiBoke, p_odakMerk, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; float k = 1.0 - abs(p - p_odakMerk / 100.0) / max(p_odakMerk / 100.0, 1.0 - p_odakMerk / 100.0); float r = p_azamiBoke * (1.0 - k) * u_s * step(0.001, p); vec4 acc = vec4(0.0);
  for (int i = 0; i < 24; i++) { float a = float(i) * 2.39996; float rr = r * sqrt((float(i) + 0.5) / 24.0); acc += texPx(here() + vec2(cos(a), sin(a)) * rr); } o = acc / 24.0 * (1.0 - smoothstep(0.6, 1.0, p)); }
//== parallaxstrips
uniform float p_serit, p_derinlikFark, p_yon, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 d = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec2 n = vec2(-d.y, d.x); vec2 q = toUnit(here()); float N = max(floor(p_serit), 2.0); float B = dot(abs(n), boxU());
  float id = floor((dot(q, n) / B + 0.5) * N); float depth = 1.0 + hash1(vec2(id, 3.0)) * p_derinlikFark / 50.0; vec2 sq = q - d * p * depth * dot(abs(d), boxU()) * 1.3; o = texU(sq); }
//== cubeface
uniform float p_donus, p_kameraMesa, p_golge, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; float a = radians(p_donus) * p; vec2 b = boxUV(here()) * 2.0 - 1.0; float F = max(p_kameraMesa, 100.0) / max(boxU().x, 1.0) * 2.0;
  // küpün ön yüzü Y ekseni etrafında döner; ışın-düzlem kesişimi
  vec3 ro = vec3(0.0, 0.0, F + 1.0); vec3 rd = normalize(vec3(b.x, -b.y * boxU().y / boxU().x, -F)); vec3 nrm = vec3(sin(a), 0.0, cos(a)); vec3 c0 = vec3(-sin(a), 0.0, -cos(a) + 1.0) * 1.0 + vec3(0.0, 0.0, 0.0);
  vec3 ctr = vec3(0.0, 0.0, 1.0) - vec3(sin(a), 0.0, cos(a)) + vec3(0.0); ctr = vec3(sin(a), 0.0, cos(a)) * 1.0 - vec3(0.0, 0.0, 1.0) + vec3(0.0, 0.0, 1.0) - vec3(0.0, 0.0, 1.0);
  vec3 C = vec3(sin(a), 0.0, cos(a)) - vec3(0.0, 0.0, 1.0) + vec3(0.0, 0.0, 1.0); C = vec3(sin(a), 0.0, cos(a) - 1.0) + vec3(0.0, 0.0, 1.0) * 0.0; float den = dot(rd, nrm); if (abs(den) < 1e-4) { o = vec4(0.0); return; }
  float t = dot(C - ro, nrm) / den; vec3 hp = ro + rd * t; vec3 u = vec3(cos(a), 0.0, -sin(a)); vec2 uv = vec2(dot(hp - C, u), hp.y * boxU().x / boxU().y) * 0.5 + 0.5; uv.y = 1.0 - uv.y;
  if (t < 0.0 || any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0))) || nrm.z < 0.0) { o = vec4(0.0); return; } vec4 c = texPx(boxPx(uv)); if (p_golge > 0.5) c.rgb *= 1.0 - p * 0.6; o = c; }
//== pageturn2
uniform float p_kivrim, p_ilerleme, p_golge;
void main() { float p = p_ilerleme / 100.0; vec2 b = boxUV(here()); float edge = 1.0 - p * 1.3; float r = 0.05 + p_kivrim / 100.0 * 0.15; float x = b.x + (1.0 - b.y) * 0.2 * p;
  if (x < edge) { o = texture(u_tex, v_uv) * (1.0 - smoothstep(edge - 0.08, edge, x) * p_golge / 100.0); return; } float d = x - edge;
  if (d < r * PI) { float ang = d / r; float bx = edge - sin(ang) * r; if (ang < PI * 0.5) { o = texPx(boxPx(vec2(edge + ang * r, b.y))) * (0.7 + 0.3 * cos(ang)); return; } vec4 back = vec4(vec3(0.92), 1.0) * texPx(boxPx(vec2(clamp(edge + ang * r, 0.0, 1.0), b.y))).a; o = back * (0.6 + 0.4 * -cos(ang)); return; }
  o = vec4(0.0); }
//== doorwings
uniform float p_kanatAcis, p_derinlik, p_golge, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 b = boxUV(here()); bool left = b.x < 0.5; float a = radians(p_kanatAcis) * p; float x = left ? b.x * 2.0 : (1.0 - b.x) * 2.0; float w = cos(a); float persp = 1.0 + sin(a) * x * p_derinlik / 400.0;
  float u = x / max(w, 0.01); if (u > 1.0 || w <= 0.01) { o = vec4(0.0); return; } float y = (b.y - 0.5) * persp + 0.5; if (y < 0.0 || y > 1.0) { o = vec4(0.0); return; } vec2 src = vec2(left ? u * 0.5 : 1.0 - u * 0.5, y);
  vec4 c = texPx(boxPx(src)); c.rgb *= 1.0 - sin(a) * p_golge / 100.0; o = c; }
//== irisblades
uniform float p_yaprakSayi, p_ilerleme, p_kivrim;
void main() { vec4 s = texture(u_tex, v_uv); float p = p_ilerleme / 100.0; vec2 q = (boxUV(here()) - 0.5) * boxU() / (length(boxU()) * 0.5); float N = max(floor(p_yaprakSayi), 3.0); float a = atan(q.y, q.x) + p * 1.2;
  float sec = TAU / N; float la = mod(a, sec) - sec * 0.5; float r = length(q) * cos(la) * (1.0 + p_kivrim / 300.0 * sin(la * 3.0)); float open_ = 1.0 - p; float m = step(r, open_ * 1.05);
  float bladeEdge = 1.0 - smoothstep(0.0, 0.01, abs(r - open_)) ; o = overPre(vec4(0.15, 0.15, 0.17, 1.0) * bladeEdge * step(0.001, p) * step(p, 0.999), s * m); }
//== foldpanels
uniform float p_panel, p_katlanma, p_perspekt, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 b = boxUV(here()); float N = max(floor(p_panel), 2.0); float a = radians(p_katlanma) * p; float pw = cos(a) / N; float total = pw * N; float x = (b.x - 0.5) / max(total, 1e-3) * 1.0 + 0.5;
  if (x < 0.0 || x > 1.0 || total < 1e-3) { o = vec4(0.0); return; } float id = floor(x * N); float f = fract(x * N); bool odd = mod(id, 2.0) > 0.5; float shade = odd ? 1.0 - sin(a) * 0.5 : 1.0;
  float persp = 1.0 + (odd ? f : 1.0 - f) * sin(a) * p_perspekt / 200.0; float y = (b.y - 0.5) * persp + 0.5; if (y < 0.0 || y > 1.0) { o = vec4(0.0); return; } vec4 c = texPx(boxPx(vec2((id + f) / N, y))); c.rgb *= shade; o = c; }
//== curtain
uniform float p_toplanma, p_kivrim, p_yon, p_ilerleme;
void main() { float p = p_ilerleme / 100.0 * p_toplanma / 100.0; vec2 b = boxUV(here()); float x = p_yon < 0.5 ? b.x : p_yon < 1.5 ? 1.0 - b.x : p_yon < 2.5 ? abs(b.x - 0.5) * 2.0 : 1.0 - b.y;
  float open_ = p; if (x < open_) { o = vec4(0.0); return; } float u = (x - open_) / max(1.0 - open_, 1e-3); float folds = sin(u * (8.0 + p_kivrim / 5.0) * (1.0 + p * 3.0)) * 0.5 + 0.5; vec2 src = b;
  if (p_yon < 0.5) src.x = open_ + u * (1.0 - open_) * 0.0 + b.x * 0.0 + mix(b.x, u, p); else if (p_yon < 1.5) src.x = 1.0 - mix(1.0 - b.x, u, p); else if (p_yon < 2.5) src.x = 0.5 + sign(b.x - 0.5) * 0.5 * mix(abs(b.x - 0.5) * 2.0, u, p); else src.y = 1.0 - mix(1.0 - b.y, u, p);
  vec4 c = texPx(boxPx(clamp(src, 0.0, 1.0))); c.rgb *= 1.0 - folds * p * p_kivrim / 100.0 * 0.6; o = c; }
//== ringcross
uniform float p_halka, p_aci, p_gecikme, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 q = toUnit(here()); float R = length(boxU()) * 0.5; float N = max(floor(p_halka), 1.0); float id = floor(length(q) / R * N); float k = clamp((p - id / N * p_gecikme * N * 0.5) / max(1.0 - p_gecikme * N * 0.5, 0.1), 0.0, 1.0);
  vec2 sq = rot2(p_aci * k * (mod(id, 2.0) > 0.5 ? -1.0 : 1.0)) * q; o = texU(sq) * (1.0 - smoothstep(0.7, 1.0, k)); }
//== colormatchtrans
uniform float p_tolerans, p_ilerleme; uniform vec3 c_referansRenk;
void main() { vec4 s = texture(u_tex, v_uv); float p = p_ilerleme / 100.0; vec3 c = unpre(s); float d = length(c - c_referansRenk) / 1.732; float near = 1.0 - smoothstep(p_tolerans / 100.0 * 0.6, p_tolerans / 100.0 * 0.6 + 0.1, d);
  vec3 r = mix(c, c_referansRenk, smoothstep(0.0, 0.5, p)); float a = s.a * (1.0 - smoothstep(0.5 + near * 0.3, 1.0, p)); o = pre(r, a); }
//== shapematchtrans
uniform vec2 p_esNokt; uniform float p_hizalama, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; float e = p * p * (3.0 - 2.0 * p); vec2 q = toUnit(here()); vec2 c = p_esNokt * p_hizalama / 100.0; float sc = mix(1.0, 0.05, e); vec4 col = texU((q - c * e) / sc + c * 0.0); o = col * (1.0 - smoothstep(0.85, 1.0, p)); }
//== peel
uniform vec2 p_baslangi; uniform float p_soyulma, p_kivrim;
void main() { float p = p_soyulma / 100.0; vec2 b = boxUV(here()); vec2 o0 = p_baslangi / 100.0; vec2 dir = normalize(vec2(0.5) - o0 + 1e-4); float d = dot(b - o0, dir); float line = p * 1.5; float r = 0.03 + p_kivrim / 100.0 * 0.1;
  if (d > line) { o = texture(u_tex, v_uv) * (1.0 - smoothstep(line + 0.06, line, d) * 0.3); return; } float back = line - d; if (back < r * PI) { vec2 src = b + dir * back * 2.0; vec4 c = texPx(boxPx(clamp(src, 0.0, 1.0))); o = vec4(vec3(0.9), 1.0) * c.a * (0.7 + 0.3 * cos(back / r)); return; } o = vec4(0.0); }
//== liquidmerge
uniform float p_gerilim, p_viskozit, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 q = toUnit(here()); float n = fbm(q * 0.01 + vec2(0.0, u_t * 0.2), 4.0); vec2 w = vec2(fbm(q * 0.008 + 3.0, 3.0), fbm(q * 0.008 + 7.0, 3.0)) * p * (1.0 - p_viskozit / 200.0) * 120.0;
  vec4 c = texU(q + w); float th = p * 1.4 - 0.2; float m = smoothstep(th - (1.0 - p_gerilim / 100.0) * 0.2 - 0.02, th + 0.02, n * 0.5 + 0.5); o = c * m; }
//== paperhole
INCLUDE(_mat)
uniform float p_delikIler, p_kenarKivr, p_lif, p_kagitMalz;
void main() { vec4 s = texture(u_tex, v_uv); float p = p_delikIler / 100.0; vec2 q = toUnit(here()); float R = p * length(boxU()) * 0.6; float r = length(q) + fbm(q * 0.03, 4.0) * 30.0 * (0.5 + p_lif / 100.0);
  if (r < R) { o = vec4(0.0); return; } float rim = 1.0 - smoothstep(R, R + 8.0 + p_kenarKivr * 0.3, r); int id = p_kagitMalz < 0.5 ? 1 : p_kagitMalz < 1.5 ? 3 : 5; vec3 paper = matSample(id, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.5, 0.0).rgb;
  o = overPre(vec4(mix(paper, vec3(0.97, 0.95, 0.9), 0.4), 1.0) * rim * step(0.001, p), s * (1.0 - rim * 0.8)); }
//== plateseparate
uniform float p_plaka, p_kayma, p_gecikme, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; int N = int(clamp(p_plaka, 2.0, 8.0)); vec3 acc = vec3(0.0); float a = 0.0;
  for (int i = 0; i < 8; i++) { if (i >= N) break; float k = clamp((p - float(i) * p_gecikme) / max(1.0 - float(N - 1) * p_gecikme, 0.1), 0.0, 1.0); float ang = float(i) * TAU / float(N); vec2 off = vec2(cos(ang), sin(ang)) * p_kayma * k * u_s;
    vec4 c = texPx(here() - off); vec3 ink = hsv2rgb(vec3(float(i) / float(N), 0.9, 1.0)); acc += unpre(c) * ink * c.a * (1.0 - k) * (3.0 / float(N)); a = max(a, c.a * (1.0 - k)); }
  o = pre(clamp(acc, 0.0, 1.0), a); }
//== timeslice
INCLUDE(_hist)
uniform sampler2D s_dagilimHari; uniform float p_dagilimHariOn, p_zamanFark, p_ilerleme;
void main() { vec4 s = texture(u_tex, v_uv); float p = p_ilerleme / 100.0; float m = p_dagilimHariOn > 0.5 ? luma(unpre(texture(s_dagilimHari, clamp(boxUV(here()), 0.0, 1.0)))) : boxUV(here()).x; float N = histN();
  vec4 h = N > 0.0 ? hist(clamp(m * (N - 1.0), 0.0, N - 1.0), v_uv) : s; float k = smoothstep(m - 0.1, m + 0.1, p * 1.2); o = mix(s, h, 0.6) * (1.0 - k); }
//== multicam
uniform sampler2D s_kamerala; uniform float p_kameralaOn, p_duzen, p_seciliKame;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec4 cam = p_kameralaOn > 0.5 ? texture(s_kamerala, b) : vec4(vec3(1.0) - s.rgb, s.a);
  if (p_duzen < 0.5) { vec2 g = floor(b * 2.0); vec2 f = fract(b * 2.0); vec4 c = (g.x + g.y * 2.0) < 0.5 ? texPx(boxPx(f)) : (p_kameralaOn > 0.5 ? texture(s_kamerala, f) : vec4(texPx(boxPx(f)).rgb * vec3(0.6, 0.8, 1.0), 1.0)); float sel = (g.x + g.y * 2.0 + 1.0) == floor(p_seciliKame) ? 1.0 : 0.0; float edge = step(min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)), 0.015); o = overPre(vec4(1.0, 0.75, 0.2, 1.0) * edge * sel, c); }
  else if (p_duzen < 1.5) { vec2 f = vec2(fract(b.x * 2.0), b.y); o = b.x < 0.5 ? texPx(boxPx(f)) : (p_kameralaOn > 0.5 ? texture(s_kamerala, f) : texPx(boxPx(f)) * 0.7); }
  else { vec4 c = texPx(boxPx(b)); vec2 pip = (b - vec2(0.68, 0.68)) / 0.28; if (all(greaterThanEqual(pip, vec2(0.0))) && all(lessThanEqual(pip, vec2(1.0)))) c = p_kameralaOn > 0.5 ? texture(s_kamerala, pip) : texPx(boxPx(pip)) * 0.7; o = c; } }
//== smartframe
uniform float p_kenarPayi, p_hedefEnBoy, p_dvN; uniform float p_dv[8];
void main() { vec2 b = boxUV(here()); vec2 tg = p_dvN >= 2.0 ? vec2(p_dv[0], p_dv[1]) : vec2(0.5 + 0.2 * sin(u_t * 0.8), 0.5); float ar = p_hedefEnBoy < 0.5 ? 1.0 : p_hedefEnBoy < 1.5 ? 9.0 / 16.0 : p_hedefEnBoy < 2.5 ? 16.0 / 9.0 : 1.0;
  float boxAr = boxU().x / boxU().y; vec2 win = ar < boxAr ? vec2(ar / boxAr, 1.0) : vec2(1.0, boxAr / ar); win *= 1.0 - p_kenarPayi / 100.0 * 0.5; vec2 c = clamp(tg, win * 0.5, 1.0 - win * 0.5);
  vec2 src = c + (b - 0.5) * win; o = texPx(boxPx(src)); }
//== twotargetzoom
uniform float p_kenarPayi, p_azamiZoom, p_dvN; uniform float p_dv[8];
void main() { vec2 b = boxUV(here()); vec2 A = p_dvN >= 4.0 ? vec2(p_dv[0], p_dv[1]) : vec2(0.35, 0.45), B = p_dvN >= 4.0 ? vec2(p_dv[2], p_dv[3]) : vec2(0.65, 0.55); vec2 mn = min(A, B), mx = max(A, B); vec2 sz = (mx - mn) * (1.0 + p_kenarPayi / 50.0) + 0.05;
  float z = clamp(1.0 / max(sz.x, sz.y), 1.0, p_azamiZoom / 100.0); vec2 c = (mn + mx) * 0.5; vec2 src = c + (b - 0.5) / z; o = texPx(boxPx(src)); }
//== dollyzoom
uniform float p_kameraUzak, p_odakUzak;
void main() { vec2 q = toUnit(here()); float r = length(q) / (length(boxU()) * 0.5); float k = p_odakUzak / 50.0; float bend = 1.0 + (k - 1.0) * r * r * 0.5; float sc = 800.0 / max(p_kameraUzak, 10.0) * k; o = texU(q / max(sc * bend, 0.05) * 1.0); }
//== comparesplit
uniform sampler2D s_ikinciKatm; uniform float p_ikinciKatmOn, p_ayirici, p_cizgiKali, p_ayiriciYonu; uniform vec3 c_cizgiReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec4 o2 = p_ikinciKatmOn > 0.5 ? texture(s_ikinciKatm, clamp(b, 0.0, 1.0)) : vec4(vec3(luma(unpre(s))) * s.a, s.a); float x = p_ayiriciYonu < 0.5 ? b.x : p_ayiriciYonu < 1.5 ? b.y : (b.x + b.y) * 0.5;
  float k = p_ayirici / 100.0; vec4 c = x < k ? s : o2; float line = 1.0 - smoothstep(p_cizgiKali / max(boxU().x, 1.0) * 0.5, p_cizgiKali / max(boxU().x, 1.0) * 0.5 + 0.002, abs(x - k)); o = overPre(vec4(c_cizgiReng, 1.0) * line, c); }
//== magnifier
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_yakinlas; uniform vec2 p_ornekMerk, p_pencere, p_pencereBoyu;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 W = p_pencereBoyu * 0.5; vec2 l = (q - p_pencere) / W; if (any(greaterThan(abs(l), vec2(1.0)))) { o = s; return; }
  vec2 src = p_ornekMerk / 100.0 + l * W / boxU() / (p_yakinlas / 100.0); vec4 c = p_kaynakOn > 0.5 ? texture(s_kaynak, clamp(src, 0.0, 1.0)) : texPx(boxPx(src)); float edge = step(1.0 - 4.0 / max(W.x, 1.0), max(abs(l.x), abs(l.y)));
  o = overPre(vec4(1.0) * edge, overPre(c, vec4(0.0, 0.0, 0.0, 1.0))); }
//== popout
uniform sampler2D s_cerceve, s_nesneMask; uniform float p_cerceveOn, p_nesneMaskOn, p_tasma, p_disParcGolg;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = clamp(boxUV(here()), 0.0, 1.0); float fr = p_cerceveOn > 0.5 ? texture(s_cerceve, b).a : step(0.15, b.x) * step(b.x, 0.85) * step(0.2, b.y) * step(b.y, 0.85); float obj = p_nesneMaskOn > 0.5 ? texture(s_nesneMask, b).a : step(0.4, luma(unpre(s))) * s.a;
  float vis = max(fr, obj * p_tasma / 100.0); float sh = 0.0; if (p_nesneMaskOn > 0.5) { sh = texture(s_nesneMask, clamp(b - vec2(0.01, -0.015), 0.0, 1.0)).a * (1.0 - fr) * (1.0 - obj) * p_disParcGolg / 100.0; }
  vec4 frameBorder = vec4(1.0) * (fr - (p_cerceveOn > 0.5 ? texture(s_cerceve, clamp(b + vec2(0.006), 0.0, 1.0)).a * texture(s_cerceve, clamp(b - vec2(0.006), 0.0, 1.0)).a : step(0.155, b.x) * step(b.x, 0.845) * step(0.205, b.y) * step(b.y, 0.845)));
  o = overPre(s * vis, overPre(frameBorder * (1.0 - obj), vec4(0.0, 0.0, 0.0, 1.0) * sh)); }
