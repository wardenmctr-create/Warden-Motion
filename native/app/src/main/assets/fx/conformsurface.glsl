// conformsurface
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_hedef; uniform float p_hedefOn, p_ofset, p_projeksiYonu, p_azamiProjUzak;
float H(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; float h = p_hedefOn > 0.5 ? luma(unpre(texture(s_hedef, clamp(b, 0.0, 1.0)))) : 0.5 + 0.5 * sin(xy.x * 0.03) * cos(xy.y * 0.03); return (h - 0.5) * p_azamiProjUzak * (p_projeksiYonu > 0.5 ? -1.0 : 1.0) + p_ofset; }
float sdf(vec3 p) { return cardD(p - vec3(0.0, 0.0, H(p.xy)), 8.0) * 0.5; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
