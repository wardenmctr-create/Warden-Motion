// unfold3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_kokYuz, p_acilim, p_cakismalIsar;
// Açılım: kart üç panele bölünür; açılım 0'da zikzak katlı, 100'de düz; paneller menteşe çevresinde zincir halinde döner
float panel(vec3 p, float k, float W) { return cardD(p, 8.0); }
float sdf(vec3 p) { float W = boxU().x / 3.0; float ang = radians(90.0 * (1.0 - p_acilim / 100.0)); float d = 1e5; vec3 q = p; float x0 = -boxU().x * 0.5;
  // panel i'nin yerel koordinatı: sol menteşeden zincirle döndürülmüş
  vec2 hinge = vec2(x0, 0.0); float rot = 0.0;
  for (int i = 0; i < 3; i++) { float a = (i == 0) ? 0.0 : (mod(float(i), 2.0) > 0.5 ? ang : -ang); rot += a; vec2 dir = vec2(cos(rot), sin(rot));
    vec3 lp = vec3(dot(vec2(p.x, p.z) - hinge, dir), p.y, dot(vec2(p.x, p.z) - hinge, vec2(-dir.y, dir.x))); vec3 cp = vec3(x0 + W * float(i) + clamp(lp.x, 0.0, W), lp.y, lp.z);
    float inside = step(0.0, lp.x) * step(lp.x, W); float dd = inside > 0.5 ? cardD(cp, 8.0) : length(vec2(min(lp.x, lp.x - W) * step(lp.x, 0.0) + max(lp.x - W, 0.0), 0.0)) + cardD(cp, 8.0); d = min(d, dd);
    hinge += dir * W; }
  return d * 0.8; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
