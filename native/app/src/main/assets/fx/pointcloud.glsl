// pointcloud
INCLUDE(_3d)
uniform sampler2D s_kaynakKatm; uniform float p_kaynakKatmOn;
uniform float p_noktaSayi, p_noktaBoyu, p_renk, p_dagilma, p_rastgeleBoyu, p_tohum; uniform vec3 c_tekRenk;
float depthAt(vec2 uv) { return p_kaynakKatmOn > 0.5 ? luma(unpre(texture(s_kaynakKatm, uv))) : luma(unpre(texPx(boxPx(uv)))); }
float grid() { return max(sqrt(max(p_noktaSayi, 100.0)), 8.0); }
float sdf(vec3 p) { vec2 B = boxU(); vec2 uv = vec2(p.x / B.x + 0.5, 0.5 - p.y / B.y); if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0)))) return max(abs(p.z), 2.0);
  float G = grid(); vec2 cell = (floor(uv * G) + 0.5) / G; vec2 h = hash2(cell * G + seedf(p_tohum)) - 0.5; vec2 cu = cell + h / G * p_dagilma / 100.0; float a = texPx(boxPx(cu)).a; if (a < 0.5) return max(B.x / G, 2.0);
  vec3 c = vec3((cu.x - 0.5) * B.x, (0.5 - cu.y) * B.y, depthAt(cu) * max(B.x, B.y) * 0.3); float r = p_noktaBoyu * 0.5 * (1.0 + (hash1(cu * 97.0) - 0.5) * p_rastgeleBoyu / 50.0);
  return min(length(p - c) - max(r, 0.4), max(B.x / G * 0.5, 1.0)); }
vec4 surf(vec3 p, vec3 n) { vec2 B = boxU(); vec2 uv = vec2(p.x / B.x + 0.5, 0.5 - p.y / B.y); float G = grid(); vec2 cell = (floor(uv * G) + 0.5) / G; vec4 c = texPx(boxPx(cell));
  vec3 col = p_renk < 0.5 ? (c.a > 0.0 ? c.rgb / c.a : vec3(1.0)) : p_renk < 1.5 ? c_tekRenk : mix(vec3(0.1, 0.3, 1.0), vec3(1.0, 0.4, 0.1), depthAt(cell)); return vec4(col, 1.0); }
void main() { o = render3d(vec3(0.0)); }
