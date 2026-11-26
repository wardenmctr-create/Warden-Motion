// triprism
INCLUDE(_3d)
uniform float p_tabanGeni, p_ucgenYuks, p_derinlik, p_kapaklar, p_pah;
float sdf(vec3 p) { float w = max(p_tabanGeni, 1.0) * 0.5, h = max(p_ucgenYuks, 1.0); vec2 q = vec2(abs(p.x), p.y + h / 3.0);
  vec2 nn = normalize(vec2(h, w)); float tri = max(dot(q - vec2(w, 0.0), nn), -q.y); vec2 d = vec2(tri, abs(p.z) - max(p_derinlik, 1.0) * 0.5); return (min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - p_pah * 0.3) * 0.9; }
vec4 surf(vec3 p, vec3 n) { if (abs(n.z) > 0.8) return vec4(vec3(p_kapaklar > 0.5 ? 0.9 : 0.35), 1.0); vec4 c = layerAt(vec2(p.z / max(p_derinlik, 1.0) + 0.5, 0.5 - p.y / max(p_ucgenYuks, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0, 35.0, 0.0)); }
