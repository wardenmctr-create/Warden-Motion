// loftprofiles
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_seciliProfKatm; uniform float p_seciliProfKatmOn, p_profilDeri, p_profilDonu, p_gecis, p_kapakOlus;
float aB(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return p_seciliProfKatmOn > 0.5 ? texture(s_seciliProfKatm, b).a : smoothstep(0.45, 0.35, length(b - 0.5)); }
float sdf(vec3 p) { float D = max(abs(p_profilDeri), 40.0) * 0.5; float k = clamp(p.z / D * 0.5 + 0.5, 0.0, 1.0); if (p_gecis > 0.5) k = k * k * (3.0 - 2.0 * k);
  vec2 xy = rot2(p_profilDonu * k) * p.xy; float a = mix(cardA(p.xy), aB(xy), k); float d2 = (0.5 - a) * 6.0; return max(d2, abs(p.z) - D) * 0.7; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
