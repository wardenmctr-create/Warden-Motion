// capsule
INCLUDE(_3d)
uniform float p_yaricap, p_govdeUzun, p_ucYuva, p_segment, p_dokuSari;
float sdf(vec3 p) { float h = max(p_govdeUzun, 0.0) * 0.5; vec3 q = p; q.y -= clamp(q.y, -h, h); return length(q * vec3(1.0, 1.0 / max(p_ucYuva / 100.0, 0.05), 1.0)) * mix(0.6, 1.0, p_ucYuva / 100.0) - max(p_yaricap, 1.0) * mix(0.6, 1.0, p_ucYuva / 100.0); }
vec4 surf(vec3 p, vec3 n) { float H = max(p_govdeUzun, 0.0) + 2.0 * p_yaricap; vec4 c = layerAt(vec2(atan(p.x, p.z) / TAU + 0.5, 0.5 - p.y / max(H, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
