// text3d
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_metinBmp, s_model; uniform float p_metinBmpOn, p_modelOn, p_kabarti, p_egriAral;
float txt(vec3 p) { vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; b.y = (b.y - 0.5) * 3.0 + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return p_metinBmpOn > 0.5 ? texture(s_metinBmp, b).a : 0.0; }
float sdf(vec3 p) { float base = cardD(p, 16.0); float t = txt(p); float h = p_kabarti * 1.5 + 0.5; vec2 w = vec2((0.5 - t) * 4.0, abs(p.z - 8.0 - h * 0.5) - h * 0.5); float d = min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); return min(base, d); }
vec4 surf(vec3 p, vec3 n) { if (p.z > 8.2 && txt(p) > 0.5) return vec4(vec3(0.95, 0.85, 0.3), 1.0); return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
