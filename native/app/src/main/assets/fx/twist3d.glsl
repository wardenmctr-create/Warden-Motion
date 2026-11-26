// twist3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_eksen, p_burguAcis, p_etkiAral;
vec3 tw(vec3 p) { int a = int(p_eksen + 0.5); float ext = (a == 0 ? boxU().x : a == 1 ? boxU().y : 40.0) * 0.5 * p_etkiAral / 100.0; float coord = a == 0 ? p.x : a == 1 ? p.y : p.z; float ang = radians(p_burguAcis) * clamp(coord / max(ext, 1.0), -1.0, 1.0) * 0.5; mat2 m = mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
  if (a == 0) p.yz = m * p.yz; else if (a == 1) p.xz = m * p.xz; else p.xy = m * p.xy; return p; }
float sdf(vec3 p) { return cardD(tw(p), 16.0) * 0.5; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(tw(p), n); }
void main() { o = render3d(vec3(0.0)); }
