// voxelize
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_voxelBoyu, p_yogunluk, p_iciDold;
float sdf(vec3 p) { float V = max(p_voxelBoyu, 1.0); vec3 id = floor(p / V); vec3 c = (id + 0.5) * V; float on = step(0.5, cardA(c.xy)) * step(abs(c.z), 12.0) * step(hash1(id.xy + id.z * 7.0), p_yogunluk / 100.0 + 0.001);
  if (p_iciDold < 0.5) on *= 1.0 - step(0.5, cardA(c.xy + vec2(V, 0.0)) * cardA(c.xy - vec2(V, 0.0)) * cardA(c.xy + vec2(0.0, V)) * cardA(c.xy - vec2(0.0, V)) * step(abs(c.z), 12.0 - V));
  vec3 dd = abs(p - c) - V * 0.45; float d = length(max(dd, 0.0)) + min(max(dd.x, max(dd.y, dd.z)), 0.0); return on > 0.5 ? d : max(V * 0.5, cardD(p, 24.0)); }
vec4 surf(vec3 p, vec3 n) { float V = max(p_voxelBoyu, 1.0); vec3 c = (floor(p / V) + 0.5) * V; return cardSurf(vec3(c.xy, 0.0), vec3(0.0, 0.0, 1.0)) * vec4(vec3(0.8 + 0.2 * abs(n.z)), 1.0); }
void main() { o = render3d(vec3(0.0)); }
