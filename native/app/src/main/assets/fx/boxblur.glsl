// boxblur
uniform float p_yaricap, p_yineleme, p_boyutlar, p_kenarUzat;
void main() {
  float r = p_yaricap * u_s; float e = p_kenarUzat > 0.5 ? 3.0 : 0.0; int N = int(clamp(r, 1.0, 12.0));
  vec2 ax = p_boyutlar < 0.5 ? vec2(1.0) : p_boyutlar < 1.5 ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // yineleme arttıkça kutu yumuşar (üçgen → çan): örnek ağırlıkları
  float k = clamp(p_yineleme, 1.0, 8.0); vec4 acc = vec4(0.0); float ws = 0.0;
  for (int i = -12; i <= 12; i++) for (int j = -12; j <= 12; j++) { if (abs(i) > N || abs(j) > N) continue; vec2 f = vec2(float(i), float(j)) / float(N);
    if (ax.x < 0.5 && i != 0) continue; if (ax.y < 0.5 && j != 0) continue;
    float w = pow(max(0.0, 1.0 - abs(f.x)), k - 1.0) * pow(max(0.0, 1.0 - abs(f.y)), k - 1.0); acc += texEdge(here() + f * r, e) * w; ws += w; }
  o = acc / max(ws, 1e-4);
}
