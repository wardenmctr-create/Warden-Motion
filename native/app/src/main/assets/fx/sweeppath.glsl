// sweeppath
INCLUDE(_3d)
uniform float p_kesit, p_kesitBoyu, p_burgu, p_ucOlce, p_ilerleme, p_dvN; uniform float p_dv[128];
float sdf(vec3 p) { int N = int(p_dvN / 2.0); float best = 1e9; float tot = float(max(N - 1, 1)); float lim = p_ilerleme / 100.0 * tot;
  for (int i = 0; i < 63; i++) { if (i >= N - 1) break; if (float(i) > lim) break; vec3 a = vec3(p_dv[i * 2], -p_dv[i * 2 + 1], 0.0), b = vec3(p_dv[i * 2 + 2], -p_dv[i * 2 + 3], 0.0); vec3 ab = b - a; float u = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-4), 0.0, min(1.0, lim - float(i)));
    vec3 c = p - a - ab * u; float t = (float(i) + u) / tot; float r = p_kesitBoyu * 0.5 * mix(1.0, p_ucOlce / 100.0, t); float ang = radians(p_burgu) * t; vec3 nrm = normalize(cross(ab, vec3(0.0, 0.0, 1.0)) + 1e-5);
    vec2 cs = vec2(dot(c, nrm), c.z); cs = rot2(degrees(ang)) * cs; float d = p_kesit < 0.5 ? length(cs) - r : p_kesit < 1.5 ? max(abs(cs.x), abs(cs.y)) - r : max(abs(cs.x) - r, abs(cs.y) - r * 0.15); best = min(best, d); }
  if (N < 2) { vec3 q = p; return length(vec2(length(q.xy) - boxU().x * 0.3, q.z)) - p_kesitBoyu * 0.5; } return best; }
vec4 surf(vec3 p, vec3 n) { return vec4(c_tabanRenk * (0.85 + 0.15 * n.z), 1.0); }
void main() { o = render3d(vec3(0.0)); }
