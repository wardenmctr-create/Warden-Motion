// painttrail
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_izGeni, p_solma, p_dvN; uniform vec4 p_dv4[16]; float dvAt(int i) { return i < 0 || i >= 64 ? 0.0 : p_dv4[i >> 2][i & 3]; }
float sdf(vec3 p) { return cardD(p, 16.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); int N = int(p_dvN / 2.0); float best = 1e9; float bk = 0.0; for (int i = 0; i < 31; i++) { if (i >= N - 1) break; vec2 a = vec2(dvAt(i * 2), -dvAt(i * 2 + 1)), b = vec2(dvAt(i * 2 + 2), -dvAt(i * 2 + 3)); vec2 ab = b - a; float u = clamp(dot(p.xy - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(p.xy - a - ab * u); if (d < best) { best = d; bk = float(i) / max(float(N - 1), 1.0); } }
  float m = (1.0 - smoothstep(p_izGeni * 0.4, p_izGeni * 0.5, best)) * mix(1.0, bk, p_solma / 100.0) * step(0.6, abs(n.z)); return vec4(mix(c.rgb, vec3(0.9, 0.2, 0.25), m), 1.0); }
void main() { o = render3d(vec3(0.0)); }
