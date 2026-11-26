// sectioncap
INCLUDE(_3d)
INCLUDE(_card)
uniform vec3 p_duzlem; uniform vec3 c_kesitReng; uniform float p_kapakGolg;
// Kesme düzlemi (normal = düzlem değerleri; boşsa yatay eksen) kartı keser; açılan kesit yüzeyi kesit rengiyle kapatılır, isteğe bağlı tarama
vec3 N() { return length(p_duzlem) > 0.5 ? normalize(vec3(p_duzlem.x, -p_duzlem.y, p_duzlem.z)) : normalize(vec3(1.0, 0.0, 0.35)); }
float sdf(vec3 p) { return max(cardD(p, 20.0), dot(p, N()) - sin(u_t * 0.5) * boxU().x * 0.1); }
vec4 surf(vec3 p, vec3 n) { float onCap = step(0.98, dot(n, N())); vec4 c = cardSurf(p, n); if (onCap < 0.5) return c; float hatch = p_kapakGolg > 0.5 ? 0.75 + 0.25 * step(0.5, fract((p.x + p.y + p.z) / 6.0)) : 1.0; return vec4(c_kesitReng * hatch, 1.0); }
void main() { o = render3d(vec3(0.0)); }
