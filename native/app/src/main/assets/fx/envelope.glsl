// envelope
uniform float p_dogru, p_aciDegi, p_zarfCizg, p_yardimciDogr;
// Doğru ailesi n(φ)·x = h(φ), h(φ) = R(0.6 + 0.4 cos kφ); zarf E(φ) = h n + h' n⊥. Yardımcı doğrular soluk
float hF(float ph, float R, float k) { return R * (0.6 + 0.4 * cos(k * ph)); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = min(boxU().x, boxU().y) * 0.38; float k = max(p_aciDegi / 60.0, 0.0) + 1.0; float aa = 0.8 / u_s; vec4 res = s;
  if (p_yardimciDogr > 0.5) { float N = max(p_dogru, 4.0); float ln = 0.0; for (int i = 0; i < 400; i++) { if (float(i) >= N) break; float ph = float(i) / N * 6.2832 + u_t * 0.1; vec2 n = vec2(cos(ph), sin(ph)); ln = max(ln, 1.0 - smoothstep(0.3, 0.3 + aa, abs(dot(q, n) - hF(ph, R, k)))); } res = overPre(vec4(0.6, 0.7, 0.9, 1.0) * ln * 0.35, res); }
  float d = 1e5; vec2 prev = vec2(0.0); for (int i = 0; i <= 128; i++) { float ph = float(i) / 128.0 * 6.2832 + u_t * 0.1; vec2 n = vec2(cos(ph), sin(ph)), tn = vec2(-n.y, n.x); float h = hF(ph, R, k), dh = -R * 0.4 * k * sin(k * ph); vec2 e = h * n + dh * tn;
    if (i > 0) { vec2 ab = e - prev; float t = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); d = min(d, length(q - prev - ab * t)); } prev = e; }
  o = overPre(vec4(1.0, 0.75, 0.3, 1.0) * (1.0 - smoothstep(p_zarfCizg * 0.5 - aa, p_zarfCizg * 0.5 + aa, d)), res); }
