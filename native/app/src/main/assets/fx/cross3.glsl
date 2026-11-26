// cross3
INCLUDE(_3d)
uniform float p_kolUzun, p_kolKali, p_xKolu, p_yKolu, p_zKolu, p_kosePahi;
float rb(vec3 p, vec3 b, float r) { vec3 q = abs(p) - b + r; return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r; }
float sdf(vec3 p) { float L = max(p_kolUzun, 1.0) * 0.5, w = max(p_kolKali, 1.0) * 0.5, r = min(p_kosePahi, w); float d = 1e5;
  if (p_xKolu > 0.5) d = min(d, rb(p, vec3(L, w, w), r)); if (p_yKolu > 0.5) d = min(d, rb(p, vec3(w, L, w), r)); if (p_zKolu > 0.5) d = min(d, rb(p, vec3(w, w, L), r)); return d; }
vec4 surf(vec3 p, vec3 n) { vec4 c = layerAt(boxMapUV(p, n, vec3(max(p_kolUzun, 1.0) * 0.5))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(25.0, 35.0, 0.0)); }
