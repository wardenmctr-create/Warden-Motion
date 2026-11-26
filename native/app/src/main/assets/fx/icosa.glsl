// icosa
INCLUDE(_3d)
uniform float p_yaricap, p_altBolm, p_duzYuze, p_dokuEsle;
float sdf(vec3 p) { float r = max(p_yaricap, 1.0); if (p_altBolm > 2.5 && p_duzYuze < 0.5) return length(p) - r;
  const float G = 1.618034; vec3 n1 = normalize(vec3(G, 1.0 / G, 0.0)), n2 = normalize(vec3(1.0)); vec3 q = abs(p);
  float d = max(max(max(dot(q, n1.xyz), dot(q, n1.yzx)), max(dot(q, n1.zxy), dot(q, n2))), 0.0) - r * 0.85;
  return mix(d, length(p) - r, clamp(p_altBolm / 4.0, 0.0, 1.0)); }
vec4 surf(vec3 p, vec3 n) { vec2 uv = p_dokuEsle < 0.5 ? vec2(atan(p.x, p.z) / TAU + 0.5, 0.5 - p.y / (2.0 * max(p_yaricap, 1.0))) : fract(n.xy * 2.0 + 0.5); vec4 c = layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
