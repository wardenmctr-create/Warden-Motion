// cylinder
INCLUDE(_3d)
uniform float p_yaricap, p_yuksekli, p_dokuSariAcis, p_ustKapa, p_altKapa, p_segment; uniform vec3 c_kapakReng;
float sdf(vec3 p) { vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(max(p_yaricap, 1.0), max(p_yuksekli, 1.0) * 0.5); return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)); }
vec4 surf(vec3 p, vec3 n) { if (abs(n.y) > 0.7) { bool top = n.y > 0.0; if ((top && p_ustKapa < 0.5) || (!top && p_altKapa < 0.5)) return vec4(c_kapakReng * 0.4, 1.0); return vec4(c_kapakReng, 1.0); }
  float u = (atan(p.x, p.z) / TAU + 0.5) * 360.0 / max(abs(p_dokuSariAcis), 1.0); vec4 c = layerAt(vec2(fract(u), 0.5 - p.y / max(p_yuksekli, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
