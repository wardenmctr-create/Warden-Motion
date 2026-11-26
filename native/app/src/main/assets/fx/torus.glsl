// torus
INCLUDE(_3d)
uniform float p_anaYari, p_tupYari, p_halkaAcis, p_segment, p_tupSegm;
float sdf(vec3 p) { vec2 q = vec2(length(p.xz) - max(p_anaYari, 1.0), p.y); float d = length(q) - max(p_tupYari, 0.5);
  if (abs(p_halkaAcis) < 359.0) { float a = degrees(atan(p.z, p.x)) + 180.0; float lim = abs(p_halkaAcis); if (a > lim) { float a1 = radians(lim - 180.0); vec3 e1 = vec3(cos(a1), 0.0, sin(a1)) * p_anaYari; vec3 e0 = vec3(-p_anaYari, 0.0, 0.0); d = max(d, -min(length(p - e1), length(p - e0)) + p_tupYari * 1.0); d = min(length(p - e1), length(p - e0)) - p_tupYari; } }
  return d; }
vec4 surf(vec3 p, vec3 n) { float u = atan(p.z, p.x) / TAU + 0.5; vec2 q = vec2(length(p.xz) - p_anaYari, p.y); float v = atan(q.y, q.x) / TAU + 0.5; vec4 c = layerAt(vec2(fract(u * 2.0), v)); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
