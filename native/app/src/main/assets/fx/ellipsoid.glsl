// ellipsoid
INCLUDE(_3d)
uniform float p_xYari, p_yYari, p_zYari, p_oranlariBagl, p_segment;
vec3 rr() { return p_oranlariBagl > 0.5 ? vec3(max(p_xYari, 1.0)) : max(vec3(p_xYari, p_yYari, p_zYari), vec3(1.0)); }
float sdf(vec3 p) { vec3 r = rr(); float k0 = length(p / r); float k1 = length(p / (r * r)); return k0 * (k0 - 1.0) / max(k1, 1e-5); }
vec4 surf(vec3 p, vec3 n) { vec3 q = p / rr(); vec4 c = layerAt(vec2(atan(q.x, q.z) / TAU + 0.5, acos(clamp(q.y, -1.0, 1.0)) / PI)); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
