// bevel3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_pah, p_segment, p_aciEsig;
// Kartın kenarları pah: 1 segment = düz eğimli, çok segment = yuvarlatılmış
float sdf(vec3 p) { float th = 20.0; float r = min(max(p_pah, 0.0), th * 0.49); float d2 = (0.5 - cardA(p.xy)) * 6.0; vec2 w = vec2(d2 + r, abs(p.z) - th * 0.5 + r);
  if (p_segment < 1.5) { float d = max(max(w.x - r, w.y - r), (w.x + w.y) * 0.70710678 - r * 0.29); return d; } return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - r; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
