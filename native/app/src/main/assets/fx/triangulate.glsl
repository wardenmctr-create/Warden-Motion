// triangulate
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_ucgenYont, p_yonleriKoru, p_normalKoru;
float sdf(vec3 p) { return cardD(p, 16.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); vec2 g = p.xy / 18.0; vec2 f = fract(g); float diag = p_ucgenYont < 0.5 ? abs(f.x - f.y) : p_ucgenYont < 1.5 ? abs(f.x + f.y - 1.0) : (mod(floor(g.x) + floor(g.y), 2.0) > 0.5 ? abs(f.x - f.y) : abs(f.x + f.y - 1.0));
  float e = min(min(f.x, 1.0 - f.x), min(min(f.y, 1.0 - f.y), diag * 0.7)); float line = 1.0 - smoothstep(0.0, 0.05, e); float facet = p_normalKoru > 0.5 ? 1.0 : 0.9 + 0.1 * step(f.x, f.y); return vec4(mix(c.rgb * facet, vec3(0.1, 0.12, 0.2), line * 0.7), 1.0); }
void main() { o = render3d(vec3(0.0)); }
