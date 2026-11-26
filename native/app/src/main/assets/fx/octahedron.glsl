// octahedron
INCLUDE(_3d)
uniform float p_boyut, p_yatayOran, p_dikeyOran, p_yuzCizg; uniform vec3 c_yuzReng;
float sdf(vec3 p) { vec3 s = vec3(p_yatayOran, p_dikeyOran, p_yatayOran); vec3 q = abs(p / s); float r = max(p_boyut, 1.0) * 0.5; return (q.x + q.y + q.z - r) * 0.57735 * min(s.x, s.y); }
vec4 surf(vec3 p, vec3 n) { vec2 uv = vec2(p.x, -p.y) / max(p_boyut, 1.0) + 0.5; vec4 c = layerAt(uv); vec3 col = (c.a > 0.0 ? c.rgb / c.a : vec3(1.0)) * c_yuzReng;
  if (p_yuzCizg > 0.5) { vec3 a = abs(p) / max(p_boyut * 0.5, 1.0); float e = min(a.x, min(a.y, a.z)); col *= mix(0.3, 1.0, smoothstep(0.0, 0.03, e)); } return vec4(col, 1.0); }
void main() { o = render3d(vec3(0.0)); }
