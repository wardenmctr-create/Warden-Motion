// extrude
INCLUDE(_3d)
uniform float p_derinlik, p_pah, p_kaynakDokuYanl, p_onYuz; uniform vec3 c_yanYuzReng, c_arkaYuzReng;
float aAt(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return texPx(boxPx(b)).a; }
float sdf(vec3 p) { float a = aAt(p.xy); float d2 = (0.5 - a) * 6.0; vec2 w = vec2(d2, abs(p.z) - max(p_derinlik, 1.0) * 0.5); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); }
vec4 surf(vec3 p, vec3 n) { vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; vec4 c = layerAt(b); vec3 col = c.a > 0.0 ? c.rgb / c.a : c_yanYuzReng;
  if (n.z > 0.7) return vec4(p_onYuz > 0.5 ? col : c_yanYuzReng, 1.0); if (n.z < -0.7) return vec4(c_arkaYuzReng, 1.0); return vec4(p_kaynakDokuYanl > 0.5 ? col * 0.8 : c_yanYuzReng, 1.0); }
void main() { o = render3d(vec3(0.0)); }
