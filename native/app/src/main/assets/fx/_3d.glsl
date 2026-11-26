// Ortak 3B sistemi: dönüşüm, kamera, malzeme, ışık ve gölge (her 3B shader "INCLUDE(_3d)" ile alır).
// Shader şunları tanımlar: float sdf(vec3 p); vec4 surf(vec3 p, vec3 n) (önceden çarpılmamış renk + yüzey alfası)
// Eksenler: X sağ, Y aşağı (panelde), Z kameradan uzağa. İçeride y yukarı, z kameraya doğru kullanılır.
INCLUDE(_mat)
uniform sampler2D s_ozelDoku3; uniform float p_ozelDoku3On;
uniform vec3 p_yonelimXY, p_surekliDonuX, p_konumXY, p_isikKonu, p_olcekXYZ, p_donusMerk; uniform vec3 c_isikReng, c_tabanRenk;
uniform float p_perspekt, p_gorusAcis, p_isikEtki, p_ortamIsig, p_yonluIsikGucu, p_parlakYans, p_puruzlul, p_arkaYuzlGost, p_kenarYumu,
  p_orantili, p_donusYontem, p_otoDonus, p_kameraUzak, p_perspGuc, p_malzeme, p_dokuGucu3, p_dokuAci3, p_metalik, p_kabartma3, p_opaklik3,
  p_golgelendirme, p_golgeOlustur, p_golgeOpak3, p_golgeYumu3, p_kalite3;
uniform vec2 p_dokuOlcek3, p_dokuKonum3;
float sdf(vec3 p); vec4 surf(vec3 p, vec3 n);
mat3 rotXYZ(vec3 d) { vec3 a = radians(d); float cx = cos(a.x), sx = sin(a.x), cy = cos(a.y), sy = sin(a.y), cz = cos(a.z), sz = sin(a.z);
  mat3 X = mat3(1, 0, 0, 0, cx, sx, 0, -sx, cx); mat3 Y = mat3(cy, 0, -sy, 0, 1, 0, sy, 0, cy); mat3 Z = mat3(cz, sz, 0, -sz, cz, 0, 0, 0, 1); return Z * Y * X; }
vec3 spinNow() { vec3 sp = p_surekliDonuX; if (p_otoDonus > 0.5 && dot(sp, sp) < 1e-6) sp = vec3(0.0, 45.0, 0.0); return sp * u_t; }
mat3 objRot(vec3 extra) { vec3 r = p_yonelimXY + spinNow() + extra; if (p_donusYontem > 0.5) r = mod(r + 180.0, 360.0) - 180.0; return rotXYZ(r); }
vec3 objScale() { vec3 s = max(p_olcekXYZ, vec3(1.0)) / 100.0; if (p_orantili > 0.5) s = vec3(s.x); return (p_olcekXYZ.x == 0.0 && p_olcekXYZ.y == 0.0) ? vec3(1.0) : s; }
// Ölçekli sdf (en küçük ölçekle düzeltilmiş uzaklık)
float sdfS(vec3 p) { vec3 s = objScale(); return sdf(p / s) * min(s.x, min(s.y, s.z)); }
vec3 calcN(vec3 p) { vec2 e = vec2(0.5, 0.0); return normalize(vec3(sdfS(p + e.xyy) - sdfS(p - e.xyy), sdfS(p + e.yxy) - sdfS(p - e.yxy), sdfS(p + e.yyx) - sdfS(p - e.yyx))); }
vec2 boxMapUV(vec3 p, vec3 n, vec3 halfSize) { vec3 a = abs(n); vec2 uv;
  if (a.x > a.y && a.x > a.z) uv = vec2(-p.z * sign(n.x), -p.y) / (2.0 * halfSize.zy); else if (a.y > a.z) uv = vec2(p.x, p.z * sign(n.y)) / (2.0 * halfSize.xz); else uv = vec2(p.x * sign(n.z), -p.y) / (2.0 * halfSize.xy);
  return uv + 0.5; }
// Katmanın görüntüsü yüzey dokusu olarak (doku ölçeği/konumu/açısı, taban rengi, doku gücü, malzeme dokusu)
vec4 layerAt(vec2 uv) {
  vec2 so = (p_dokuOlcek3.x == 0.0 && p_dokuOlcek3.y == 0.0) ? vec2(1.0) : max(p_dokuOlcek3, vec2(1.0)) / 100.0;
  vec2 u2 = rot2(-p_dokuAci3) * (uv - 0.5) / so + 0.5 - p_dokuKonum3 / max(boxU(), vec2(1.0));
  vec4 c = p_malzeme > 6.5 && p_ozelDoku3On > 0.5 ? texture(s_ozelDoku3, fract(u2)) : texPx(boxPx(clamp(fract(u2), 0.0005, 0.9995)));
  vec3 base = c_tabanRenk; float dg = (p_dokuGucu3 == 0.0 && p_malzeme == 0.0 && p_opaklik3 == 0.0) ? 1.0 : p_dokuGucu3 / 100.0;
  vec3 col = mix(base, (c.a > 0.0 ? c.rgb / c.a : base) * base, dg * c.a + (1.0 - dg) * 0.0);
  if (dg < 1.0) col = mix(base, col, dg);
  // kâğıt / karton / ahşap: ortak malzeme kütüphanesinden doku
  if (p_malzeme > 3.5 && p_malzeme < 6.5) { int id = p_malzeme < 4.5 ? 1 : p_malzeme < 5.5 ? 3 : 12; vec2 mp = u2 * 400.0; vec4 m = matSample(id, mp, 3.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0);
    col *= mix(vec3(1.0), m.rgb / max(matBase(id), vec3(0.05)), 0.8) * (0.85 + 0.3 * m.a); }
  return vec4(col, max(c.a, 0.999));
}
float softShadow(vec3 ro, vec3 rd, float k) { float res = 1.0; float t = 2.0; for (int i = 0; i < 28; i++) { float h = sdfS(ro + rd * t); res = min(res, k * h / t); t += clamp(h, 1.0, 40.0); if (res < 0.01 || t > 2000.0) break; } return clamp(res, 0.0, 1.0); }
vec3 lightPosObj(mat3 Ri, vec3 T) { return Ri * (vec3(p_isikKonu.x, -p_isikKonu.y, -p_isikKonu.z) - T); }
vec3 shade(vec3 col, vec3 p, vec3 n, vec3 rd, mat3 Ri) {
  if (p_isikEtki < 0.5 || p_golgelendirme < 0.5) return col * (p_isikEtki < 0.5 ? 1.0 : 0.9 + 0.1 * n.z);
  vec3 T = vec3(p_konumXY.x, -p_konumXY.y, -p_konumXY.z);
  vec3 L = p_golgelendirme < 1.5 ? normalize(lightPosObj(Ri, T) - p) : normalize(Ri * normalize(vec3(-p_isikKonu.x, p_isikKonu.y, p_isikKonu.z) * -1.0));
  vec3 H = normalize(L - rd); float rough = p_puruzlul / 100.0; float met = p_malzeme > 0.5 && p_malzeme < 1.5 ? max(p_metalik / 100.0, 0.8) : p_metalik / 100.0;
  float gloss = p_parlakYans / 100.0 * (p_malzeme > 1.5 && p_malzeme < 2.5 ? 1.8 : 1.0);
  float dif = max(dot(n, L), 0.0); float sp = pow(max(dot(n, H), 0.0), mix(120.0, 6.0, rough)) * gloss * 1.5;
  float sh = 1.0; if (p_golgeOlustur > 0.5 && dif > 0.0) sh = mix(1.0, softShadow(p + n * 1.5, L, mix(32.0, 4.0, clamp(p_golgeYumu3 / 40.0, 0.0, 1.0))), p_golgeOpak3 / 100.0 * 2.0 > 1.0 ? 1.0 : p_golgeOpak3 / 50.0);
  vec3 env = mix(vec3(0.25, 0.28, 0.35), vec3(0.95), 0.5 + 0.5 * reflect(rd, n).y);
  vec3 baseC = mix(col, col * env * 1.2, met);
  vec3 r = baseC * (p_ortamIsig / 100.0 + dif * sh * p_yonluIsikGucu / 100.0) * c_isikReng + c_isikReng * sp * sh * mix(1.0, 1.0 + met, met);
  if (p_kabartma3 > 0.0) r *= 1.0 + (vnoise(p.xy * 0.2) - 0.5) * p_kabartma3 / 100.0 * 0.4;
  return r;
}
// extra: shader'ın kendi dönüşü (derece). Sonuç önceden çarpılmış renk.
vec4 render3d(vec3 extra) {
  vec2 q = toUnit(here()); vec2 B = boxU(); float fov = radians(clamp(p_gorusAcis, 10.0, 120.0));
  float F = p_kameraUzak > 0.0 ? p_kameraUzak : max(800.0, max(B.x, B.y) * 0.5 / tan(fov * 0.5));
  float persp = p_perspekt > 0.5 && p_perspekt < 1.5 ? 0.0 : clamp(p_perspGuc == 0.0 && p_kameraUzak == 0.0 && p_malzeme == 0.0 ? 1.0 : p_perspGuc / 100.0, 0.0, 1.0);
  vec3 ro = mix(vec3(q.x, -q.y, F), vec3(0.0, 0.0, F), persp); vec3 rd = normalize(mix(vec3(0.0, 0.0, -1.0), normalize(vec3(q.x, -q.y, -F)), persp));
  if (persp > 0.0 && persp < 1.0) { vec3 target = vec3(q.x, -q.y, 0.0); rd = normalize(target - ro); }
  mat3 R = objRot(extra); mat3 Ri = transpose(R);
  vec3 T = vec3(p_konumXY.x, -p_konumXY.y, -p_konumXY.z); vec3 C = vec3(p_donusMerk.x, -p_donusMerk.y, -p_donusMerk.z);
  vec3 o2 = Ri * (ro - T - C) + C, d2 = Ri * rd;
  int steps = p_kalite3 < 0.5 ? 96 : p_kalite3 < 1.5 ? 48 : p_kalite3 < 2.5 ? 72 : p_kalite3 < 3.5 ? 128 : 192;
  float t = 0.0; bool hit = false; vec3 p;
  for (int i = 0; i < 192; i++) { if (i >= steps) break; p = o2 + d2 * t; float d = sdfS(p); if (d < 0.05) { hit = true; break; } t += d * 0.9; if (t > F * 3.0 + 6000.0) break; }
  if (!hit) {
    // arka düzleme düşen gölge (nesnenin arkasında, ışığın karşısında)
    if (p_golgeOlustur > 0.5 && p_isikEtki > 0.5) { float zb = -max(B.x, B.y) * 0.45; vec3 wp = ro + rd * ((zb - ro.z) / min(rd.z, -1e-4)); vec3 op = Ri * (wp - T - C) + C;
      vec3 L = p_golgelendirme < 1.5 ? normalize(lightPosObj(Ri, T) - op) : normalize(Ri * normalize(vec3(p_isikKonu.x, -p_isikKonu.y, -p_isikKonu.z)) * -1.0);
      float s = softShadow(op, L, mix(40.0, 8.0, clamp(p_golgeYumu3 / 40.0, 0.0, 1.0))); float a = smoothstep(0.85, 0.15, s) * p_golgeOpak3 / 100.0; return vec4(0.0, 0.0, 0.0, a); }
    return vec4(0.0);
  }
  vec3 n = calcN(p); vec3 ps = p / objScale(); vec4 c = surf(ps, normalize(n / objScale()));
  vec3 col = shade(c.rgb, p, n, d2, Ri);
  float a = c.a * (p_opaklik3 == 0.0 && p_malzeme == 0.0 && p_dokuGucu3 == 0.0 ? 1.0 : p_opaklik3 / 100.0);
  if (p_malzeme > 2.5 && p_malzeme < 3.5) { float fr = pow(1.0 - abs(dot(n, -d2)), 3.0); a *= mix(0.35, 0.9, fr); col += vec3(fr * 0.4); }
  return vec4(clamp(col, 0.0, 1.0) * a, a);
}
