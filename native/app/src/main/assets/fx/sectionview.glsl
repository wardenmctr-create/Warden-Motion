// sectionview
INCLUDE(_3d)
INCLUDE(_card)
uniform vec3 p_duzlemKonu, p_duzlemDonu, c_kapakReng; uniform float p_tersTaraGost, p_kesitKapa, p_kesitCizg, p_cizgiKali;
vec3 pn() { return rotXYZ(p_duzlemDonu) * vec3(1.0, 0.0, 0.0); }
float sdf(vec3 p) { float pl = dot(p - vec3(p_duzlemKonu.x, -p_duzlemKonu.y, -p_duzlemKonu.z), pn()) * (p_tersTaraGost > 0.5 ? -1.0 : 1.0); return max(cardD(p, 40.0), pl); }
vec4 surf(vec3 p, vec3 n) { float pl = abs(dot(p - vec3(p_duzlemKonu.x, -p_duzlemKonu.y, -p_duzlemKonu.z), pn())); if (pl < 0.8 && p_kesitKapa > 0.5) { float hatch = p_kesitCizg > 0.5 ? step(0.5, fract((p.y + p.z) / max(p_cizgiKali * 4.0, 2.0))) : 1.0; return vec4(c_kapakReng * (0.7 + 0.3 * hatch), 1.0); } return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
