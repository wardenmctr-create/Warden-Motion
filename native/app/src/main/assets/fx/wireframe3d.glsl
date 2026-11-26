// wireframe3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_kenarTuru, p_cizgiKali, p_gizliKenaGost, p_gizliKenaOpak, p_dolguyuGost, p_dolguOpak; uniform vec3 c_cizgiReng;
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec2 g = abs(fract(p.xy / 24.0 + 0.5) - 0.5) * 24.0; float grid = p_kenarTuru < 0.5 ? 1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali * 0.5 + 0.8, min(g.x, g.y)) : 0.0;
  float rim = 1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali + 0.8, min(abs(abs(p.z) - 10.0), max(0.0, (0.5 - cardA(p.xy)) * 0.0 + 99.0))); float side = abs(n.z) < 0.6 ? 1.0 : 0.0; float edge = max(abs(abs(p.z) - 10.0) < p_cizgiKali ? side : 0.0, p_kenarTuru < 1.5 ? grid * (1.0 - side) : 0.0);
  if (p_kenarTuru > 1.5) edge = abs(abs(p.z) - 10.0) < p_cizgiKali ? side : 0.0; vec4 fill = cardSurf(p, n); float fa = p_dolguyuGost > 0.5 ? p_dolguOpak / 100.0 : 0.0;
  return vec4(mix(fill.rgb, c_cizgiReng, edge), max(edge, fa)); }
void main() { o = render3d(vec3(0.0)); }
