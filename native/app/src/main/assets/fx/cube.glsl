// cube
INCLUDE(_3d)
uniform float p_boyut, p_kosePahi, p_yuzDoku, p_dokuDose, p_arkaYuz;
float sdf(vec3 p) { vec3 b = vec3(max(p_boyut, 2.0) * 0.5); float r = min(p_kosePahi, b.x); vec3 q = abs(p) - b + r; return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r; }
vec4 surf(vec3 p, vec3 n) { vec2 uv = boxMapUV(p, n, vec3(max(p_boyut, 2.0) * 0.5)); uv = fract((uv - 0.5) * p_dokuDose / 100.0 + 0.5); vec4 c = layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), max(c.a, 0.999)); }
void main() { o = render3d(vec3(0.0)); }
