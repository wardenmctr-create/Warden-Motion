// heathaze
uniform float p_yukselisHizi, p_kirilma, p_katmanDeri, p_yogunluk;
// Yükselen ısı: farklı hızda üç kırılma katmanı; alttan üste azalan yoğunluk
void main() { vec2 q = toUnit(here()); float D = max(p_katmanDeri, 1.0); vec2 off = vec2(0.0);
  for (int i = 0; i < 3; i++) { float k = 1.0 + float(i) * 0.7; vec2 uv = q / D * k + vec2(float(i) * 3.1, u_t * p_yukselisHizi / D * (0.6 + 0.4 * float(i))); off += vec2(fbm(uv, 3.0), fbm(uv + 7.3, 3.0)) / k; }
  float grad = mix(1.0, 0.25, clamp(0.5 - q.y / max(boxU().y, 1.0), 0.0, 1.0)); off *= p_kirilma * p_yogunluk / 100.0 * grad; o = texU(q + off); }
