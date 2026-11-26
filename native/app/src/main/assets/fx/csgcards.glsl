// csgcards
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_ikinciMode; uniform float p_ikinciModeOn, p_islem, p_yontem, p_voxelBoyu, p_girislerGoruTut; uniform vec3 c_yeniYuzReng;
float aB(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return p_ikinciModeOn > 0.5 ? texture(s_ikinciMode, b).a : step(length(b - vec2(0.62, 0.42)), 0.28); }
float dB(vec3 p) { vec3 q = p; if (p_yontem > 0.5) q = (floor(p / max(p_voxelBoyu, 0.5)) + 0.5) * max(p_voxelBoyu, 0.5); float d2 = (0.5 - aB(q.xy)) * 6.0; vec2 w = vec2(d2, abs(p.z - 6.0) - 14.0); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); }
float sdf(vec3 p) { float a = cardD(p, 24.0), b = dB(p); return p_islem < 0.5 ? min(a, b) : p_islem < 1.5 ? max(a, b) : max(a, -b); }
vec4 surf(vec3 p, vec3 n) { float a = cardD(p, 24.0), b = dB(p); if (abs(b) < abs(a) && p_islem > 1.5) return vec4(c_yeniYuzReng, 1.0); if (abs(b) < abs(a)) { vec2 bb = vec2(p.x, -p.y) / boxU() + 0.5; vec4 c = p_ikinciModeOn > 0.5 ? texture(s_ikinciMode, clamp(bb, 0.0, 1.0)) : vec4(c_yeniYuzReng, 1.0); return vec4(c.a > 0.0 ? c.rgb / c.a : c_yeniYuzReng, 1.0); } return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
