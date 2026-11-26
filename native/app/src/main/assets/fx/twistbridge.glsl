// twistbridge
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_kenarSeci, p_araSegm, p_bukulme;
// Ön ve arka kenar döngüsü yeni yüzlerle bağlanır: derin gövde boyunca burgu; ara segment çizgileri
float sdf(vec3 p) { float D = 60.0; float u = clamp(p.z / D + 0.5, 0.0, 1.0); float a = radians(p_bukulme) * (u - 0.5); vec2 xy = mat2(cos(a), -sin(a), sin(a), cos(a)) * p.xy;
  float d2 = (0.5 - cardA(xy)) * 6.0; vec2 w = vec2(d2, abs(p.z) - D * 0.5); return (min(max(w.x, w.y), 0.0) + length(max(w, 0.0))) * 0.7; }
vec4 surf(vec3 p, vec3 n) { float D = 60.0; float u = p.z / D + 0.5; float seg = abs(fract(u * max(p_araSegm, 1.0)) - 0.5); vec4 c = cardSurf(p, n); float ring = abs(n.z) < 0.6 ? 1.0 - smoothstep(0.02, 0.06, seg) : 0.0; return vec4(mix(c.rgb, vec3(1.0), ring * 0.6), 1.0); }
void main() { o = render3d(vec3(0.0)); }
