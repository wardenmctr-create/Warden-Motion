// bumpcard
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_yuksekli; uniform float p_yuksekliOn, p_derinlik, p_notrDege;
float hgt(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; float h = p_yuksekliOn > 0.5 ? luma(unpre(texture(s_yuksekli, clamp(b, 0.0, 1.0)))) : luma(unpre(texPx(boxPx(clamp(b, 0.0, 1.0))))); return (h - p_notrDege / 100.0) * p_derinlik; }
float sdf(vec3 p) { float h = hgt(p.xy); return cardD(p - vec3(0.0, 0.0, h * 0.5), 10.0 + abs(h)) * 0.6; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
