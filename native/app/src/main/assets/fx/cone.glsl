// cone
INCLUDE(_3d)
uniform float p_tabanYari, p_ustYari, p_yuksekli, p_tabanKapa, p_segment; uniform vec3 c_kapakReng;
float sdf(vec3 p) { float h = max(p_yuksekli, 1.0) * 0.5; float r1 = max(p_tabanYari, 0.5), r2 = max(p_ustYari, 0.0);
  vec2 q = vec2(length(p.xz), p.y); vec2 k1 = vec2(r2, h), k2 = vec2(r2 - r1, 2.0 * h); vec2 ca = vec2(q.x - min(q.x, q.y < 0.0 ? r1 : r2), abs(q.y) - h);
  vec2 cb = q - k1 + k2 * clamp(dot(k1 - q, k2) / dot(k2, k2), 0.0, 1.0); float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0; return s * sqrt(min(dot(ca, ca), dot(cb, cb))); }
vec4 surf(vec3 p, vec3 n) { if (n.y < -0.8) return vec4(c_kapakReng * (p_tabanKapa > 0.5 ? 1.0 : 0.4), 1.0);
  vec4 c = layerAt(vec2(atan(p.x, p.z) / TAU + 0.5, 0.5 - p.y / max(p_yuksekli, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
