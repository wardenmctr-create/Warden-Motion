// hollowbox
INCLUDE(_3d)
uniform float p_en, p_boy, p_derinlik, p_duvarKali, p_acikYuz; uniform vec3 c_icYuzReng;
float sdBox(vec3 p, vec3 b) { vec3 q = abs(p) - b; return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0); }
vec3 hs() { return vec3(max(p_en, 2.0), max(p_boy, 2.0), max(p_derinlik, 2.0)) * 0.5; }
float sdf(vec3 p) { vec3 b = hs(); float w = clamp(p_duvarKali, 0.5, min(b.x, min(b.y, b.z)) * 0.9); float outer = sdBox(p, b); vec3 off = vec3(0.0);
  int f = int(p_acikYuz + 0.5); vec3 dir = f == 0 ? vec3(0, 1, 0) : f == 1 ? vec3(0, -1, 0) : f == 2 ? vec3(0, 0, 1) : f == 3 ? vec3(0, 0, -1) : f == 4 ? vec3(-1, 0, 0) : vec3(1, 0, 0);
  float inner = sdBox(p - dir * w, b - w + abs(dir) * w); return max(outer, -inner); }
vec4 surf(vec3 p, vec3 n) { vec3 b = hs(); bool inside = all(lessThan(abs(p), b - p_duvarKali * 0.9)); if (inside) return vec4(c_icYuzReng, 1.0);
  vec4 c = layerAt(boxMapUV(p, n, b)); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(25.0, 30.0, 0.0)); }
