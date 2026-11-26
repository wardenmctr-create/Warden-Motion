// flip3d
INCLUDE(_3d)
uniform float p_donusX, p_donusY, p_donusZ, p_arkaYuzuGost; uniform vec2 p_dayanak; uniform vec3 c_arkaYuzReng;
float sdf(vec3 p) { return 1e5; } vec4 surf(vec3 p, vec3 n) { return vec4(0.0); }
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float F = max(B.x, B.y) * 0.5 / tan(radians(clamp(p_gorusAcis, 10.0, 120.0)) * 0.5) * mix(3.0, 1.0, clamp(p_perspekt < 0.5 ? 1.0 : 0.0, 0.0, 1.0));
  vec3 piv = vec3(p_dayanak.x, -p_dayanak.y, 0.0);
  vec3 ro = p_perspekt < 0.5 ? vec3(0.0, 0.0, F) : vec3(q.x, -q.y, F); vec3 rd = p_perspekt < 0.5 ? normalize(vec3(q.x, -q.y, -F)) : vec3(0.0, 0.0, -1.0);
  mat3 R = rotXYZ(vec3(p_donusX, p_donusY, p_donusZ) + p_yonelimXY + p_surekliDonuX * u_t); mat3 Ri = transpose(R); vec3 T = vec3(p_konumXY.x, -p_konumXY.y, -p_konumXY.z);
  vec3 o2 = Ri * (ro - T - piv) + piv, d2 = Ri * rd;
  if (abs(d2.z) < 1e-5) { o = vec4(0.0); return; } float t = -o2.z / d2.z; if (t < 0.0) { o = vec4(0.0); return; }
  vec3 p = o2 + d2 * t; vec2 b = vec2(p.x, -p.y) / B + 0.5;
  if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = vec4(0.0); return; }
  vec4 c = layerAt(b); bool back = d2.z > 0.0;
  if (back) { if (p_arkaYuzuGost < 0.5) { o = vec4(0.0); return; } c = vec4(c_arkaYuzReng, 1.0) * c.a; }
  vec3 n = vec3(0.0, 0.0, back ? -1.0 : 1.0); vec3 col = c.a > 0.0 ? c.rgb / c.a : vec3(0.0); col = shade(col, p, n, d2, Ri);
  o = vec4(clamp(col, 0.0, 1.0) * c.a, c.a);
}
