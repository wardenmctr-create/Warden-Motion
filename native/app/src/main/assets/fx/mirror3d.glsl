// mirror3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_eksen, p_duzlemOfse;
vec3 fold(vec3 p) { int a = int(p_eksen + 0.5); if (a == 0 || a == 3) p.x = abs(p.x - p_duzlemOfse) + p_duzlemOfse; if (a == 1) p.y = abs(p.y - p_duzlemOfse) + p_duzlemOfse; if (a == 2) p.z = abs(p.z - p_duzlemOfse) + p_duzlemOfse; return p; }
float sdf(vec3 p) { return cardD(fold(p) - vec3(p_eksen > 1.5 && p_eksen < 2.5 ? 0.0 : 0.0, 0.0, p_eksen > 1.5 && p_eksen < 2.5 ? 10.0 : 0.0), 10.0); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(fold(p), n); }
void main() { o = render3d(vec3(0.0)); }
