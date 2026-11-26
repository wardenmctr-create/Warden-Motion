// box3d
INCLUDE(_3d)
uniform sampler2D s_yuzKatm; uniform float p_yuzKatmOn; uniform float p_en, p_boy, p_derinlik, p_pah, p_oranlariBagl;
vec3 hs() { return vec3(max(p_en, 1.0), max(p_oranlariBagl > 0.5 ? p_en : p_boy, 1.0), max(p_oranlariBagl > 0.5 ? p_en : p_derinlik, 1.0)) * 0.5; }
float sdf(vec3 p) { vec3 b = hs(); float r = min(p_pah, min(b.x, min(b.y, b.z))); vec3 q = abs(p) - b + r; return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r; }
vec4 surf(vec3 p, vec3 n) { vec2 uv = boxMapUV(p, n, hs()); vec4 c = (p_yuzKatmOn > 0.5 && abs(n.z) < 0.7) ? texture(s_yuzKatm, clamp(uv, 0.0, 1.0)) : layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
