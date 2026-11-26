// Ortak 3B grubu: kamera, dönüş, ışık ve ışın-izleme (her 3B shader "INCLUDE(_3d)" ile alır).
// Shader şunları tanımlar: float sdf(vec3 p); vec4 surf(vec3 p, vec3 n) (önceden çarpılmamış renk + yüzey alfası)
uniform vec3 p_yonelimXY, p_surekliDonuX, p_konumXY, p_isikKonu; uniform vec3 c_isikReng;
uniform float p_perspekt, p_gorusAcis, p_isikEtki, p_ortamIsig, p_yonluIsikGucu, p_parlakYans, p_puruzlul, p_arkaYuzlGost, p_kenarYumu;
float sdf(vec3 p); vec4 surf(vec3 p, vec3 n);
mat3 rotXYZ(vec3 d) { vec3 a = radians(d); float cx = cos(a.x), sx = sin(a.x), cy = cos(a.y), sy = sin(a.y), cz = cos(a.z), sz = sin(a.z);
  mat3 X = mat3(1, 0, 0, 0, cx, sx, 0, -sx, cx); mat3 Y = mat3(cy, 0, -sy, 0, 1, 0, sy, 0, cy); mat3 Z = mat3(cz, sz, 0, -sz, cz, 0, 0, 0, 1); return Z * Y * X; }
mat3 objRot(vec3 extra) { return rotXYZ(p_yonelimXY + p_surekliDonuX * u_t + extra); }
vec3 calcN(vec3 p) { vec2 e = vec2(0.5, 0.0); return normalize(vec3(sdf(p + e.xyy) - sdf(p - e.xyy), sdf(p + e.yxy) - sdf(p - e.yxy), sdf(p + e.yyx) - sdf(p - e.yyx))); }
vec2 boxMapUV(vec3 p, vec3 n, vec3 halfSize) { vec3 a = abs(n); vec2 uv;
  if (a.x > a.y && a.x > a.z) uv = vec2(-p.z * sign(n.x), -p.y) / (2.0 * halfSize.zy); else if (a.y > a.z) uv = vec2(p.x, p.z * sign(n.y)) / (2.0 * halfSize.xz); else uv = vec2(p.x * sign(n.z), -p.y) / (2.0 * halfSize.xy);
  return uv + 0.5; }
vec4 layerAt(vec2 uv) { return texPx(boxPx(clamp(uv, 0.0005, 0.9995))); }
vec3 shade(vec3 col, vec3 p, vec3 n, vec3 rd, mat3 R) {
  if (p_isikEtki < 0.5) return col;
  vec3 lp = R * vec3(p_isikKonu.x, -p_isikKonu.y, -p_isikKonu.z); // ışık (dünya, y yukarı) → nesne uzayı
  vec3 L = normalize(lp - p); vec3 H = normalize(L - rd);
  float dif = max(dot(n, L), 0.0); float sp = pow(max(dot(n, H), 0.0), mix(80.0, 6.0, p_puruzlul / 100.0)) * p_parlakYans / 100.0 * 1.5;
  return col * (p_ortamIsig / 100.0 + dif * p_yonluIsikGucu / 100.0) * c_isikReng + c_isikReng * sp;
}
// extra: shader'ın kendi dönüşü (derece). Sonuç önceden çarpılmış renk.
vec4 render3d(vec3 extra) {
  vec2 q = toUnit(here()); vec2 B = boxU(); float fov = radians(clamp(p_gorusAcis, 10.0, 120.0));
  float F = max(B.x, B.y) * 0.5 / tan(fov * 0.5) + 0.0;
  vec3 ro, rd;
  if (p_perspekt < 0.5) { ro = vec3(0.0, 0.0, F); rd = normalize(vec3(q.x, -q.y, -F)); } else { ro = vec3(q.x, -q.y, F); rd = vec3(0.0, 0.0, -1.0); }
  mat3 R = objRot(extra); mat3 Ri = transpose(R);
  vec3 T = vec3(p_konumXY.x, -p_konumXY.y, -p_konumXY.z);
  vec3 o2 = Ri * (ro - T), d2 = Ri * rd;
  float t = 0.0; bool hit = false; vec3 p;
  for (int i = 0; i < 96; i++) { p = o2 + d2 * t; float d = sdf(p); if (d < 0.05) { hit = true; break; } t += d * 0.9; if (t > F * 3.0 + 4000.0) break; }
  if (!hit) return vec4(0.0);
  vec3 n = calcN(p); vec4 c = surf(p, n);
  vec3 col = shade(c.rgb, p, n, d2, Ri);
  return vec4(clamp(col, 0.0, 1.0) * c.a, c.a);
}
