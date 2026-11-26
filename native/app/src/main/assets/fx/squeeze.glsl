// squeeze
uniform float p_esneme, p_yon, p_esneklik, p_sonum, p_hiz, p_hacmiKoru; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float a = radians(p_yon); vec2 d = vec2(cos(a), sin(a)), n = vec2(-d.y, d.x);
  vec2 r = q - p_merkez; float s = dot(r, d), m = dot(r, n);
  float wob = sin(TAU * p_hiz * u_t) * exp(-p_sonum / 100.0 * u_t * 1.5);
  float half_ = max(1.0, abs(dot(B * 0.5, abs(d))));
  float st = 1.0 + p_esneme / half_ * wob * mix(0.4, 1.0, p_esneklik / 100.0);
  // jöle: uçlar biraz gecikir
  float lag = 1.0 + 0.15 * p_esneklik / 100.0 * sin(TAU * p_hiz * u_t - abs(s) / half_ * 1.5) * exp(-p_sonum / 100.0 * u_t * 1.5);
  st *= lag;
  float pf = p_hacmiKoru > 0.5 ? inversesqrt(max(0.05, st)) : 1.0;
  o = texU(p_merkez + d * s / max(0.05, st) + n * m / max(0.05, pf));
}
