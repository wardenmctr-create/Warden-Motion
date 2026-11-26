// weldedges
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_mesafe;
float wA(vec2 xy) { float g = max(p_mesafe * 4.0, 0.01); vec2 c = floor(xy / g + 0.5) * g; return mix(cardA(xy), cardA(c), step(0.02, p_mesafe)); }
float sdf(vec3 p) { float d2 = (0.5 - wA(p.xy)) * 6.0; vec2 w = vec2(d2, abs(p.z) - 10.0); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
