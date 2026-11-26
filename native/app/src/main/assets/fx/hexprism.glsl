// hexprism
INCLUDE(_3d)
uniform float p_yaricap, p_yuksekli, p_kapaklar, p_kenarPahi; uniform vec3 c_kapakReng;
float sdf(vec3 p) { vec3 k = vec3(-0.8660254, 0.5, 0.57735); vec3 q = abs(p.xzy); vec2 h = vec2(max(p_yaricap, 1.0) * 0.866, max(p_yuksekli, 1.0) * 0.5);
  q.xy -= 2.0 * min(dot(k.xy, q.xy), 0.0) * k.xy; vec2 d = vec2(length(q.xy - vec2(clamp(q.x, -k.z * h.x, k.z * h.x), h.x)) * sign(q.y - h.x), q.z - h.y); return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - p_kenarPahi * 0.3; }
vec4 surf(vec3 p, vec3 n) { if (abs(n.y) > 0.8) return vec4(p_kapaklar > 0.5 ? c_kapakReng : vec3(0.3), 1.0); vec4 c = layerAt(vec2(atan(p.x, p.z) / TAU + 0.5, 0.5 - p.y / max(p_yuksekli, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
