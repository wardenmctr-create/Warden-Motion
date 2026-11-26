// skelvolume
INCLUDE(_3d)
uniform float p_yaricap, p_birlesimYumu, p_dvN; uniform float p_dv[64];
float smin(float a, float b, float k) { float h = clamp(0.5 + 0.5 * (b - a) / max(k, 1e-3), 0.0, 1.0); return mix(b, a, h) - k * h * (1.0 - h); }
float sdf(vec3 p) { int N = int(p_dvN / 2.0); float k = p_birlesimYumu * 0.6; float d = 1e9; if (N < 1) { for (int i = 0; i < 4; i++) { vec3 c = vec3(cos(float(i) * 1.57), sin(float(i) * 1.57), 0.0) * boxU().x * 0.2; d = smin(d, length(p - c) - p_yaricap * 3.0, k); } return d; }
  vec3 prev = vec3(p_dv[0], -p_dv[1], 0.0); d = length(p - prev) - p_yaricap; for (int i = 1; i < 32; i++) { if (i >= N) break; vec3 c = vec3(p_dv[i * 2], -p_dv[i * 2 + 1], 0.0); vec3 ab = c - prev; float u = clamp(dot(p - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); d = smin(d, length(p - prev - ab * u) - p_yaricap, k); prev = c; } return d; }
vec4 surf(vec3 p, vec3 n) { return vec4(c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
