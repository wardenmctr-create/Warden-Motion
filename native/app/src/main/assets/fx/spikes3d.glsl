// spikes3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_uzunluk, p_yogunluk, p_normalYonu;
float sdf(vec3 p) { float base = cardD(p, 12.0); float cs = mix(40.0, 8.0, p_yogunluk / 100.0); vec2 id = floor(p.xy / cs); vec2 c = (id + 0.5) * cs; float on = step(0.5, cardA(c)); if (on < 0.5) return base;
  vec3 q = p - vec3(c, 6.0); float h = p_uzunluk; float side = p_normalYonu > 0.5 ? 1.0 : sign(p.z + 1e-4); q.z *= side; float t = clamp(q.z / max(h, 1.0), 0.0, 1.0); float cone = max(length(q.xy) - cs * 0.3 * (1.0 - t), -q.z); cone = max(cone, q.z - h);
  return min(base, cone * 0.7); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
