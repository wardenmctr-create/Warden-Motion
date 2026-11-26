// remesh
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_hucreBoyu, p_yontem, p_boslukKapa;
float rA(vec2 xy) { float C = max(p_hucreBoyu, 0.5) * 2.0; vec2 c = (floor(xy / C) + 0.5) * C; float a = cardA(c); if (p_boslukKapa > 0.5) { float n = 0.0; for (int i = 0; i < 4; i++) n += cardA(c + vec2(cos(float(i) * 1.57), sin(float(i) * 1.57)) * C); a = max(a, step(3.5, n * 1.0 + 0.0)); } return a; }
float sdf(vec3 p) { float C = max(p_hucreBoyu, 0.5) * 2.0; vec2 c = (floor(p.xy / C) + 0.5) * C; float on = step(0.5, rA(p.xy)); vec3 dd = abs(p - vec3(c, 0.0)) - vec3(C * 0.5, C * 0.5, p_yontem < 0.5 ? C * 0.5 * 2.0 : 8.0); float d = length(max(dd, 0.0)) + min(max(dd.x, max(dd.y, dd.z)), 0.0); return on > 0.5 ? d : max(C * 0.5, cardD(p, 20.0)); }
vec4 surf(vec3 p, vec3 n) { float C = max(p_hucreBoyu, 0.5) * 2.0; vec2 f = abs(fract(p.xy / C) - 0.5); vec4 c = cardSurf(vec3((floor(p.xy / C) + 0.5) * C, 0.0), vec3(0.0, 0.0, 1.0)); c.rgb *= 1.0 - (1.0 - smoothstep(0.42, 0.48, max(f.x, f.y))) * 0.0 - smoothstep(0.44, 0.5, max(f.x, f.y)) * 0.35; return c; }
void main() { o = render3d(vec3(0.0)); }
