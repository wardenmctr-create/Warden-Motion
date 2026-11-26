// taper3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_eksen, p_merkez;
vec3 tp(vec3 p) { int a = int(p_eksen + 0.5); float ext = (a == 0 ? boxU().x : boxU().y) * 0.5; float coord = a == 0 ? p.x : a == 1 ? p.y : p.z * 4.0; float k = mix(0.4, 1.4, clamp(coord / max(ext, 1.0) * 0.5 + p_merkez / 100.0, 0.0, 1.0));
  if (a == 0) p.yz /= k; else if (a == 1) p.xz /= k; else p.xy /= k; return p; }
float sdf(vec3 p) { return cardD(tp(p), 16.0) * 0.5; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(tp(p), n); }
void main() { o = render3d(vec3(0.0)); }
