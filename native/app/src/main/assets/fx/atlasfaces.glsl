// atlasfaces
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_atlas; uniform float p_atlasOn, p_sutun, p_satir, p_secim, p_tohum;
// Kartın ön yüzü yüz hücrelerine bölünür; her hücre atlastaki bir kutuyu (kimlik / sıra / tohum ile) alır
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); if (abs(n.z) < 0.6) return c; float C = max(floor(p_sutun), 1.0), R = max(floor(p_satir), 1.0); vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; vec2 g = floor(b * vec2(C, R)); vec2 f = fract(b * vec2(C, R));
  float id = g.y * C + g.x; float pick = p_secim < 0.5 ? id : (p_secim < 1.5 ? mod(id * 7.0 + 3.0, C * R) : floor(hash1(g + p_tohum) * C * R)); vec2 tile = vec2(mod(pick, C), floor(pick / C));
  vec4 t = p_atlasOn > 0.5 ? texture(s_atlas, (tile + f) / vec2(C, R)) : vec4(hsv2rgb(vec3(pick / (C * R), 0.55, 0.95)), 1.0); return vec4(mix(c.rgb, t.rgb, t.a), 1.0); }
void main() { o = render3d(vec3(0.0)); }
