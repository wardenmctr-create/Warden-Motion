// heart3d
INCLUDE(_3d)
uniform float p_genislik, p_yuksekli, p_derinlik, p_kenarYuva, p_dokuOlce;
float sdf(vec3 p) { vec2 s = vec2(max(p_genislik, 1.0), max(p_yuksekli, 1.0)) * 0.5; vec2 q = vec2(p.x, -p.y) / s; float d2 = heartSDF(q) * min(s.x, s.y);
  float r = min(p_kenarYuva, p_derinlik * 0.5); vec2 w = vec2(d2 + r, abs(p.z) - max(p_derinlik, 1.0) * 0.5 + r); return (min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - r) * 0.7; }
vec4 surf(vec3 p, vec3 n) { vec2 uv = (vec2(p.x, -p.y) / vec2(max(p_genislik, 1.0), max(p_yuksekli, 1.0))) / max(p_dokuOlce / 100.0, 0.01) + 0.5; vec4 c = layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.9, 0.2, 0.3), 1.0); }
void main() { o = render3d(vec3(0.0)); }
