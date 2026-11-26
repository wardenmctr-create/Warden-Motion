// facethick
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_derinlik, p_aralik;
float sdf(vec3 p) { float cs = 24.0; vec2 id = floor(p.xy / cs); vec2 c = (id + 0.5) * cs; float on = cardA(c); vec3 q = p - vec3(c, 0.0); float gap = cs * 0.5 * (1.0 - p_aralik / 100.0); float hz = max(abs(p_derinlik), 1.0) * (0.5 + 0.5 * on);
  vec3 dd = abs(q) - vec3(gap, gap, hz * 0.5); float d = length(max(dd, 0.0)) + min(max(dd.x, max(dd.y, dd.z)), 0.0); return on > 0.3 ? d : max(d, cs * 0.5); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
