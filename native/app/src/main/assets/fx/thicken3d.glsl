// thicken3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_duvar, p_ofset, p_acikKenaKapa;
float sdf(vec3 p) { float d = cardD(p - vec3(0.0, 0.0, p_ofset), max(p_duvar, 0.5) * 2.0); if (p_acikKenaKapa < 0.5) d = max(d, -cardD(p - vec3(0.0, 0.0, p_ofset), max(p_duvar - 2.0, 0.1) * 2.0) + 0.0); return d; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
