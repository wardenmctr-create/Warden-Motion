// bendtocurve
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_eksen, p_ilerleme, p_dvN; uniform vec4 p_dv4[32]; float dvAt(int i) { return i < 0 || i >= 128 ? 0.0 : p_dv4[i >> 2][i & 3]; }
// kart, eğri boyunca bükülür: x ekseni eğri uzunluğuna, y normal yönüne eşlenir
vec3 unbend(vec3 p) { int N = int(p_dvN / 2.0); if (N < 2) return p; float best = 1e9; float s = 0.0; float acc = 0.0; float yOff = 0.0; float tot = 0.0;
  for (int i = 0; i < 63; i++) { if (i >= N - 1) break; vec2 a = vec2(dvAt(i * 2), -dvAt(i * 2 + 1)), b = vec2(dvAt(i * 2 + 2), -dvAt(i * 2 + 3)); tot += length(b - a); }
  for (int i = 0; i < 63; i++) { if (i >= N - 1) break; vec2 a = vec2(dvAt(i * 2), -dvAt(i * 2 + 1)), b = vec2(dvAt(i * 2 + 2), -dvAt(i * 2 + 3)); vec2 ab = b - a; float L = length(ab); float u = clamp(dot(p.xy - a, ab) / max(L * L, 1e-4), 0.0, 1.0); vec2 c = a + ab * u; float d = length(p.xy - c);
    if (d < best) { best = d; s = acc + u * L; vec2 nrm = vec2(-ab.y, ab.x) / max(L, 1e-4); yOff = dot(p.xy - c, nrm); } acc += L; }
  vec3 flat_ = vec3((s / max(tot, 1.0) - 0.5) * boxU().x, yOff, p.z); return mix(p, flat_, p_ilerleme / 100.0); }
float sdf(vec3 p) { return cardD(unbend(p), 14.0) * 0.5; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(unbend(p), n); }
void main() { o = render3d(vec3(0.0)); }
