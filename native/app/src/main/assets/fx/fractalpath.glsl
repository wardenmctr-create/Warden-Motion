// fractalpath
uniform float p_yolTuru, p_seviye, p_buyukluk, p_cizimIler, p_cizgiKali, p_renklend, p_tersCiz; uniform vec3 c_baslangiReng, c_bitisReng;
// Hilbert eğrisi: d ↔ (x,y) (tam sayı, klasik algoritma)
vec2 h2xy(int n, int d) { int x = 0, y = 0, t = d; for (int s = 1; s < 256; s *= 2) { if (s >= n) break; int rx = 1 & (t / 2); int ry = 1 & (t ^ rx);
    if (ry == 0) { if (rx == 1) { x = s - 1 - x; y = s - 1 - y; } int tmp = x; x = y; y = tmp; } x += s * rx; y += s * ry; t /= 4; } return vec2(x, y); }
int xy2d(int n, int x, int y) { int d = 0; for (int s = 128; s > 0; s /= 2) { if (s >= n) continue; int rx = (x & s) > 0 ? 1 : 0; int ry = (y & s) > 0 ? 1 : 0; d += s * s * ((3 * rx) ^ ry);
    if (ry == 0) { if (rx == 1) { x = n - 1 - x; y = n - 1 - y; } int tmp = x; x = y; y = tmp; } } return d; }
void main() { vec4 s = texture(u_tex, v_uv); int L = int(clamp(floor(p_seviye), 1.0, 7.0)); int n = 1 << L; float nf = float(n); float S = max(p_buyukluk, 10.0); vec2 q = toUnit(here()) / S + 0.5;
  if (any(lessThan(q, vec2(-0.05))) || any(greaterThan(q, vec2(1.05)))) { o = s; return; }
  ivec2 cell = ivec2(clamp(floor(q * nf), 0.0, nf - 1.0)); int N = n * n; float lim = float(N) * p_cizimIler / 100.0; float best = 1e9; float bestT = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { ivec2 c = cell + ivec2(i, j); if (c.x < 0 || c.y < 0 || c.x >= n || c.y >= n) continue; int d = xy2d(n, c.x, c.y);
    for (int k = -1; k <= 0; k++) { int d0 = d + k; if (d0 < 0 || d0 + 1 >= N) continue; if (float(d0 + 1) > lim) continue; vec2 A = (h2xy(n, d0) + 0.5) / nf, B = (h2xy(n, d0 + 1) + 0.5) / nf;
      vec2 ab = B - A; float t = clamp(dot(q - A, ab) / dot(ab, ab), 0.0, 1.0); float dist = length(q - A - ab * t); if (dist < best) { best = dist; bestT = (float(d0) + t) / float(N); } } }
  float w = p_cizgiKali / S * 0.5; float m = 1.0 - smoothstep(w, w + 1.0 / (S * u_s), best); if (p_tersCiz > 0.5) bestT = 1.0 - bestT;
  vec3 c = p_renklend > 0.5 ? mix(c_baslangiReng, c_bitisReng, bestT) : c_baslangiReng; o = overPre(vec4(c, 1.0) * m, s); }
