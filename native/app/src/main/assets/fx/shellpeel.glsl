// shellpeel
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_yuzMask; uniform float p_yuzMaskOn, p_uzaklasm, p_kabukKali, p_ilerleme;
// Ön yüzden ince ikinci kabuk; normal yönünde (+z) ilerlemeyle uzaklaşır; maske varsa yalnız o bölge
float mask(vec2 xy) { if (p_yuzMaskOn < 0.5) return 1.0; vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; return texture(s_yuzMask, b).a; }
float sdf(vec3 p) { float body = cardD(p, 20.0); float off = 10.0 + p_uzaklasm * p_ilerleme / 100.0; float th = max(p_kabukKali, 0.3); float m = mask(p.xy);
  float d2 = (0.5 - min(cardA(p.xy), m)) * 6.0; vec2 w = vec2(d2, abs(p.z - off - th * 0.5) - th * 0.5); float shell = min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); return min(body, shell); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); return p.z > 10.5 ? vec4(c.rgb * 1.05, 1.0) : vec4(c.rgb * 0.8, 1.0); }
void main() { o = render3d(vec3(0.0)); }
