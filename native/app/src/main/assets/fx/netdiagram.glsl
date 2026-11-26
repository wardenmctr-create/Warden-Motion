// netdiagram
INCLUDE(_chart)
uniform float p_duzen, p_bagUzak;
vec2 node(float i, float n) { if (p_duzen > 1.5) { float lv = floor(log2(i + 1.0)); float idx = i + 1.0 - pow(2.0, lv); return vec2((idx + 0.5) / pow(2.0, lv) - 0.5, lv * 0.18 - 0.4); } float a = i / n * TAU; return vec2(cos(a), sin(a)) * 0.4 * (p_duzen < 0.5 ? 0.9 + 0.1 * sin(i * 3.7) : 1.0); }
void main() { vec2 q = boxUV(here()) - 0.5; q.x *= boxU().x / boxU().y; float R = dR(); float n = 2.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; n = max(n, max(dat(float(r), 0.0), dat(float(r), 1.0)) + 1.0); } n = min(n, 40.0);
  vec4 col = vec4(0.04, 0.06, 0.12, 0.85);
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; vec2 a = node(dat(float(r), 0.0), n), b = node(dat(float(r), 1.0), n); vec2 ab = b - a; float u = clamp(dot(q - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); col = overPre(vec4(0.5, 0.65, 0.9, 1.0) * (1.0 - smoothstep(0.002, 0.005, length(q - a - ab * u))), col); }
  for (int i = 0; i < 40; i++) { if (float(i) >= n) break; vec2 p = node(float(i), n); col = overPre(vec4(serCol(float(i), vec3(1.0, 0.6, 0.2)), 1.0) * (1.0 - smoothstep(0.022, 0.026, length(q - p))), col); }
  o = col; }
