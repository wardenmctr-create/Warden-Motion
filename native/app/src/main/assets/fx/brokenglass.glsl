// brokenglass
uniform vec2 p_catlakMerk; uniform float p_anaCatl, p_dalSayi, p_catlakKali, p_catlakUzun, p_kirilma, p_tohum; uniform vec3 c_renk;
void main() { vec2 q = toUnit(here()); vec2 r = q - p_catlakMerk; float d = length(r); float a = atan(r.y, r.x); float n = max(1.0, floor(p_anaCatl)); float sd = seedf(p_tohum);
  float seg = TAU / n; float ai = floor(a / seg); float rnd = hash1(vec2(ai, sd)); float ca = (ai + 0.5 + (rnd - 0.5) * 0.6) * seg; float off = abs(sin(a - ca)) * d;
  float wob = (vnoise(vec2(d * 0.05, ai + sd)) - 0.5) * 6.0; float line = (1.0 - smoothstep(p_catlakKali * 0.5, p_catlakKali * 0.5 + 0.8, abs(off + wob))) * step(d, p_catlakUzun * (0.6 + 0.4 * rnd));
  float rings = 0.0; for (int k = 1; k <= 4; k++) { if (float(k) > p_dalSayi + 1.0) break; float rr = p_catlakUzun * float(k) / (p_dalSayi + 2.0) * (0.8 + 0.4 * hash1(vec2(ai, float(k)))); rings = max(rings, (1.0 - smoothstep(p_catlakKali * 0.4, p_catlakKali * 0.4 + 0.8, abs(d - rr))) * step(0.5, hash1(vec2(ai * 3.0, float(k) + sd)))); }
  vec2 sh = vec2(hash1(vec2(ai, 1.0 + sd)), hash1(vec2(ai, 2.0 + sd))) - 0.5; vec4 c = texU(q + sh * p_kirilma * step(d, p_catlakUzun));
  float crack = max(line, rings); o = overPre(vec4(c_renk, 1.0) * crack * 0.85, c); }
