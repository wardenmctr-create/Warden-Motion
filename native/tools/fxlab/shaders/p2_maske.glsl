// 800 rehberi, bölüm 2: maske ve katman birleştirme (576–600)
//== alphadist
uniform float p_azamiMesa, p_isaretliMesa, p_gorunum;
void main() { vec4 s = texture(u_tex, v_uv); float R = max(p_azamiMesa, 1.0) * u_s; float inside = step(0.5, s.a); float d = inside > 0.5 ? innerDist(here(), R) : outerDist(here(), R); float v = d / R;
  if (p_isaretliMesa > 0.5) v = inside > 0.5 ? 0.5 + v * 0.5 : 0.5 - v * 0.5; else if (inside < 0.5) v = 0.0;
  if (p_gorunum < 0.5) o = vec4(vec3(v), 1.0); else if (p_gorunum < 1.5) o = vec4(hsv2rgb(vec3(0.7 - v * 0.7, 0.9, 1.0)), 1.0); else o = vec4(vec3(v), v); }
//== alphaskel
uniform float p_dalBuda, p_cizgiKali; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = s; return; } float R = 80.0 * u_s; float d0 = innerDist(here(), R); float st = max(1.0, d0 * 0.15);
  float mx = 0.0; float cnt = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; float dn = innerDist(here() + vec2(cos(a), sin(a)) * st, R); cnt += step(dn, d0 + 0.01 * u_s); }
  float ridge = step(5.5, cnt) * step(p_dalBuda * u_s * 0.25, d0); float w = max(p_cizgiKali * u_s * 0.5, 0.6);
  float line = 0.0; for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; vec2 p = here() + vec2(cos(a), sin(a)) * w; float dp = innerDist(p, R); float c2 = 0.0; for (int k = 0; k < 8; k++) { float b = float(k) * 0.785; c2 += step(innerDist(p + vec2(cos(b), sin(b)) * max(1.0, dp * 0.15), R), dp + 0.01 * u_s); } line = max(line, step(5.5, c2) * step(p_dalBuda * u_s * 0.25, dp)); }
  o = overPre(vec4(c_renk, 1.0) * max(ridge, line * 0.8), s); }
//== maskcombine
uniform sampler2D s_ikinciMask; uniform float p_ikinciMaskOn, p_islem, p_tersCevi;
void main() { vec4 s = texture(u_tex, v_uv); float a = s.a; float b = p_ikinciMaskOn > 0.5 ? texture(s_ikinciMask, clamp(boxUV(here()), 0.0, 1.0)).a : 0.0; if (p_tersCevi > 0.5) b = 1.0 - b;
  float m = p_islem < 0.5 ? max(a, b) : p_islem < 1.5 ? min(a, b) : p_islem < 2.5 ? a * (1.0 - b) : abs(a - b); vec3 c = s.a > 0.0 ? s.rgb / s.a : vec3(1.0); o = pre(c, m); }
//== condblend
uniform sampler2D s_aB; uniform float p_aBOn, p_kanal, p_esik, p_yumusatm;
void main() { vec4 s = texture(u_tex, v_uv); if (p_aBOn < 0.5) { o = s; return; } vec4 b = texture(s_aB, clamp(boxUV(here()), 0.0, 1.0)); vec3 u = unpre(s); float v = p_kanal < 0.5 ? luma(u) : p_kanal < 1.5 ? u.r : p_kanal < 2.5 ? u.g : p_kanal < 3.5 ? u.b : s.a;
  float w = smoothstep(p_esik / 100.0 - p_yumusatm / 200.0 - 1e-3, p_esik / 100.0 + p_yumusatm / 200.0 + 1e-3, v); o = mix(b, s, w); }
//== colorselect
uniform float p_tolerans, p_renkUzay; uniform vec3 c_ornekRenk;
vec3 lab(vec3 c) { vec3 l = srgb2lin(c); vec3 xyz = mat3(0.4124, 0.2126, 0.0193, 0.3576, 0.7152, 0.1192, 0.1805, 0.0722, 0.9505) * l; xyz /= vec3(0.9505, 1.0, 1.089); vec3 f = mix(pow(xyz, vec3(1.0 / 3.0)), xyz * 7.787 + 16.0 / 116.0, step(xyz, vec3(0.008856)));
  return vec3(116.0 * f.y - 16.0, 500.0 * (f.x - f.y), 200.0 * (f.y - f.z)); }
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float d; if (p_renkUzay < 0.5) d = length(lab(c) - lab(c_ornekRenk)) / 100.0; else if (p_renkUzay < 1.5) { vec3 a = rgb2hsv(c), b = rgb2hsv(c_ornekRenk); float dh = abs(a.x - b.x); dh = min(dh, 1.0 - dh); d = length(vec3(dh * 2.0, a.y - b.y, (a.z - b.z) * 0.5)); } else d = length(c - c_ornekRenk) / 1.732;
  float m = 1.0 - smoothstep(p_tolerans / 100.0 * 0.8, p_tolerans / 100.0 * 1.2 + 0.01, d); o = pre(c, s.a * m); }
//== edgedirmatte
uniform float p_aci, p_tolerans, p_kenarEsig;
void main() { vec4 s = texture(u_tex, v_uv); vec2 g = lumGrad(here(), u_s) + alphaGrad(here(), u_s); float mag = length(g); float tang = mod(degrees(atan(g.y, g.x)) + 90.0, 180.0); float d = abs(tang - p_aci); d = min(d, 180.0 - d);
  float m = (1.0 - smoothstep(p_tolerans, p_tolerans + 5.0, d)) * smoothstep(p_kenarEsig / 100.0 * 0.5, p_kenarEsig / 100.0 * 0.5 + 0.05, mag); o = pre(vec3(m), m * max(s.a, 0.0) + (1.0 - s.a) * m); }
//== alphaholes
uniform float p_enKucuDeli, p_disBoslDisl; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a > 0.5) { o = vec4(0.0); return; } float R = max(boxU().x, boxU().y) * u_s; int hits = 0; float near = 1e9;
  for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; vec2 d = vec2(cos(a), sin(a)); for (int k = 1; k <= 48; k++) { float t = R * float(k) / 48.0; if (texPx(here() + d * t).a > 0.5) { hits++; near = min(near, t); break; } } }
  bool hole = hits == 12 || p_disBoslDisl < 0.5; float sz = near / u_s; o = hole && sz * 2.0 >= sqrt(p_enKucuDeli) * 0.5 ? vec4(c_renk, 1.0) : vec4(0.0); }
//== compisolate
uniform sampler2D s_anl; uniform float p_anlOn;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } float m = texture(s_anl, v_uv).a; o = s * step(0.5, m); }
//== edgeband
uniform float p_icGeni, p_disGeni, p_yumusatm;
void main() { vec4 s = texture(u_tex, v_uv); float R = max(max(p_icGeni, p_disGeni), 1.0) * u_s + 2.0; float a = s.a; float m;
  if (a > 0.5) { float d = innerDist(here(), R) / u_s; m = 1.0 - smoothstep(p_icGeni, p_icGeni + max(p_yumusatm, 0.01), d); } else { float d = outerDist(here(), R) / u_s; m = 1.0 - smoothstep(p_disGeni, p_disGeni + max(p_yumusatm, 0.01), d); }
  vec3 c = a > 0.0 ? s.rgb / a : vec3(1.0); if (a <= 0.0) { for (int i = 0; i < 8; i++) { float an = float(i) * 0.785; vec4 n = texPx(here() + vec2(cos(an), sin(an)) * R); if (n.a > 0.0) { c = n.rgb / n.a; break; } } } o = pre(c, m); }
//== edgeextend
uniform float p_uzatma, p_alfayiDegi, p_yontem, p_onizlemeUzatRgb;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a > 0.99) { o = s; return; } float R = max(p_uzatma, 0.0) * u_s; vec3 acc = vec3(0.0); float ws = 0.0; vec3 best = vec3(0.0); float bd = 1e9;
  for (int i = 0; i < 16; i++) { float a = float(i) * 0.3927; for (int k = 1; k <= 12; k++) { float t = R * float(k) / 12.0; vec4 n = texPx(here() + vec2(cos(a), sin(a)) * t); if (n.a > 0.5) { vec3 c = n.rgb / n.a; float w = 1.0 / (t + 1.0); acc += c * w; ws += w; if (t < bd) { bd = t; best = c; } break; } } }
  if (ws <= 0.0) { o = s; return; } vec3 c = p_yontem < 0.5 ? best : acc / ws; float a = p_alfayiDegi > 0.5 ? s.a : 1.0; if (p_onizlemeUzatRgb > 0.5 && u_export < 0.5) a = 1.0; o = vec4(mix(c, s.a > 0.0 ? s.rgb / s.a : c, s.a) * a, a); }
//== matte2img
uniform float p_tersCevi, p_rgbVeyaAlfa; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); float a = p_tersCevi > 0.5 ? 1.0 - s.a : s.a; o = p_rgbVeyaAlfa < 0.5 ? vec4(c_renk * a, 1.0) : vec4(c_renk * a, a); }
//== depthpriority
uniform sampler2D s_onArkaDeri, s_ikinciGoru; uniform float p_onArkaDeriOn, p_ikinciGoruOn, p_tolerans, p_gecis;
void main() { vec4 s = texture(u_tex, v_uv); if (p_ikinciGoruOn < 0.5) { o = s; return; } vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec4 o2 = texture(s_ikinciGoru, b);
  float d1 = p_onArkaDeriOn > 0.5 ? luma(unpre(texture(s_onArkaDeri, b))) : luma(unpre(s)); float d2 = luma(unpre(o2)); float w = smoothstep(-p_gecis / 100.0 - p_tolerans / 100.0, p_gecis / 100.0 + 1e-3, d1 - d2);
  o = mix(overPre(s, o2), overPre(o2, s), w); }
//== colorbounce
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_mesafe, p_guc; uniform vec2 p_yon;
void main() { vec4 s = texture(u_tex, v_uv); if (p_kaynakOn < 0.5 || s.a <= 0.0) { o = s; return; } vec2 d = length(p_yon) > 0.01 ? normalize(p_yon) : vec2(1.0, 0.0); vec3 acc = vec3(0.0); float ws = 0.0;
  for (int i = 1; i <= 10; i++) { float t = p_mesafe * float(i) / 10.0 * u_s; vec4 c = texture(s_kaynak, clamp(boxUV(here() + d * t), 0.0, 1.0)); float w = c.a * exp(-float(i) * 0.2); acc += unpre(c) * w; ws += w; }
  float edge = 1.0 - smoothstep(0.0, p_mesafe * u_s, innerDist(here(), p_mesafe * u_s)); vec3 bounce = ws > 0.0 ? acc / ws : vec3(0.0); o = pre(clamp(unpre(s) + bounce * edge * p_guc / 100.0 * 0.6 * step(0.001, ws), 0.0, 1.0), s.a); }
//== depthview
uniform float p_yakinUzakSini, p_tersCevi, p_dogrusal;
void main() { vec4 s = texture(u_tex, v_uv); float z = luma(unpre(s)); float k = max(p_yakinUzakSini, 0.01); float v = p_dogrusal < 0.5 ? clamp(z * 10.0 / k, 0.0, 1.0) : log(1.0 + z * k) / log(1.0 + k); if (p_tersCevi > 0.5) v = 1.0 - v; o = vec4(vec3(v), 1.0) * s.a; }
//== normalselect
uniform vec2 p_yon; uniform float p_aciAral, p_yumusatm;
void main() { vec4 s = texture(u_tex, v_uv); float e = 1.5 * u_s; float hx = luma(unpre(texPx(here() + vec2(e, 0.0)))) - luma(unpre(texPx(here() - vec2(e, 0.0)))); float hy = luma(unpre(texPx(here() + vec2(0.0, e)))) - luma(unpre(texPx(here() - vec2(0.0, e))));
  vec3 n = normalize(vec3(-hx * 4.0, -hy * 4.0, 1.0)); vec3 d = normalize(vec3(p_yon, sqrt(max(0.0, 1.0 - dot(p_yon, p_yon))) + 0.001)); float ang = degrees(acos(clamp(dot(n, d), -1.0, 1.0)));
  float m = 1.0 - smoothstep(p_aciAral, p_aciAral + max(p_yumusatm, 0.1), ang); o = pre(unpre(s), s.a * m); }
//== fresnelmatte
uniform float p_kirilmaIndi, p_guc, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float R = 40.0 * u_s; float d = innerDist(here(), R) / R; float cosT = clamp(d * 1.5, 0.0, 1.0); float r0 = pow((p_kirilmaIndi - 1.0) / (p_kirilmaIndi + 1.0), 2.0);
  float f = clamp((r0 + (1.0 - r0) * pow(1.0 - cosT, 5.0)) * p_guc / 100.0, 0.0, 1.0); if (p_ters > 0.5) f = 1.0 - f; o = vec4(vec3(f), 1.0) * s.a; }
//== diffmap
uniform sampler2D s_karsilas; uniform float p_karsilasOn, p_renkMetr, p_esik;
void main() { vec4 s = texture(u_tex, v_uv); if (p_karsilasOn < 0.5) { o = s; return; } vec3 a = unpre(s), b = unpre(texture(s_karsilas, clamp(boxUV(here()), 0.0, 1.0)));
  float d = p_renkMetr < 0.5 ? length(a - b) * 1.2 : p_renkMetr < 1.5 ? length(a - b) / 1.732 : abs(luma(a) - luma(b)); float v = smoothstep(p_esik / 100.0, 1.0, d) ; vec3 heat = v <= 0.0 ? vec3(0.0) : hsv2rgb(vec3(0.66 - clamp(v * 2.0, 0.0, 1.0) * 0.66, 1.0, 1.0)); o = vec4(heat, 1.0) * max(s.a, 1.0); }
