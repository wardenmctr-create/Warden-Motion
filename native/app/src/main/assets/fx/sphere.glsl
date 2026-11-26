// sphere
INCLUDE(_3d)
uniform float p_yaricap, p_yatayDokuAcis, p_dikeyDokuAcis, p_dokuEsle, p_segment;
float sdf(vec3 p) { return length(p) - max(p_yaricap, 1.0); }
vec4 surf(vec3 p, vec3 n) { vec2 uv = p_dokuEsle < 0.5 ? vec2(atan(p.x, p.z) / TAU + 0.5 + p_yatayDokuAcis / 360.0, acos(clamp(-p.y / max(p_yaricap, 1.0), -1.0, 1.0)) / PI * -1.0 + 1.0 + p_dikeyDokuAcis / 180.0) : vec2(p.x, -p.y) / (2.0 * max(p_yaricap, 1.0)) + 0.5;
  uv.x = fract(uv.x); uv.y = 1.0 - uv.y; vec4 c = layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
