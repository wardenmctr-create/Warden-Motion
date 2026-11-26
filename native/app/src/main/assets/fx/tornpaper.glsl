// tornpaper
INCLUDE(_mat)
uniform float p_parcaSayi, p_bolme, p_ortusme, p_yirtikDeri, p_lifUzun, p_kagitTuru, p_dokuGucu, p_parcaYuks, p_golgeGucu, p_kolajIler, p_tohum;
int matId() { int m[6] = int[6](1, 2, 6, 3, 9, 10); return m[int(clamp(p_kagitTuru, 0.0, 5.0))]; }
vec4 cellAt(vec2 q, out vec2 cid) { float cs = sqrt(boxU().x * boxU().y / max(p_parcaSayi, 2.0)); vec2 n = q / cs + vec2(pnoise(q / max(p_yirtikDeri * 4.0, 2.0)), pnoise(q / max(p_yirtikDeri * 4.0, 2.0) + 9.0)) * p_yirtikDeri / cs * 2.0;
  if (p_bolme > 1.5 && p_bolme < 2.5) { cid = floor(n); return vec4(fract(n).x, fract(n).y, 0.0, 0.0); } vec4 v = voronoi(n + seedf(p_tohum)); cid = v.zw; return v; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 cid; vec4 v = cellAt(q, cid); vec2 h = hash2(cid + 1.3);
  float show = step(hash1(cid + 7.7), p_kolajIler / 100.0); vec2 off = (h - 0.5) * p_ortusme * 0.6; float rot = (h.x - 0.5) * p_ortusme * 0.4;
  vec2 sq = rot2(-rot) * (q - off); vec4 src = texU(sq); if (p_bolme < 0.5) { vec3 qc = floor(unpre(src) * 3.0 + 0.5) / 3.0; src = pre(qc, src.a); }
  float edge = p_bolme > 1.5 && p_bolme < 2.5 ? min(min(v.x, 1.0 - v.x), min(v.y, 1.0 - v.y)) * 2.0 : (v.y - v.x); float fib = smoothstep(0.0, 0.04 + p_lifUzun * 0.01, edge);
  int id = matId(); vec3 paper = matSample(id, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.5, 0.0).rgb; vec3 col = src.a > 0.0 ? src.rgb / src.a : paper;
  col = mix(col, col * paper / max(luma(matBase(id)), 0.1), p_dokuGucu / 100.0); col = mix(vec3(0.97, 0.95, 0.9), col, fib);
  float sh = (1.0 - smoothstep(0.0, 0.08 + p_parcaYuks * 0.01, edge)) * p_golgeGucu / 100.0 * 0.5; col *= 1.0 - sh * 0.5;
  o = pre(clamp(col, 0.0, 1.0), max(src.a, s.a) * show); }
