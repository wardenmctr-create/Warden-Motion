// subdivide
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_seviye, p_yontem, p_kenarlarKoru;
float sA(vec2 xy) { float r = 3.0 * p_seviye; if (r < 0.5) return cardA(xy); float a = 0.0; for (int i = 0; i < 12; i++) { float an = float(i) * 0.5236; a += cardA(xy + vec2(cos(an), sin(an)) * r); } return mix(a / 12.0, cardA(xy), p_kenarlarKoru > 0.5 ? 0.25 : 0.0); }
float sdf(vec3 p) { float d2 = (0.5 - sA(p.xy)) * 6.0; float r = p_yontem < 0.5 ? 4.0 * p_seviye : 0.0; vec2 w = vec2(d2 + r * 0.3, abs(p.z) - 10.0 + r * 0.3); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - r * 0.3; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
