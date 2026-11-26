// repeatpath
uniform float p_yol, p_kopyaSayi, p_boyutX, p_boyutY, p_baslangi, p_bitis, p_yolaDond, p_kapaliYol;
vec2 pathAt(float t) { float a = t * TAU; vec2 S = vec2(p_boyutX, p_boyutY) * 0.5;
  if (p_yol < 0.5 || p_yol > 3.5) return vec2(cos(a), sin(a)) * S; if (p_yol < 1.5) return vec2((t * 2.0 - 1.0), sin(a * 1.5)) * S;
  if (p_yol < 2.5) return vec2(pow(sin(a), 3.0), -(13.0 * cos(a) - 5.0 * cos(2.0 * a) - 2.0 * cos(3.0 * a) - cos(4.0 * a)) / 16.0) * S;
  float k = floor(t * 10.0); float f = fract(t * 10.0); float r0 = mod(k, 2.0) < 0.5 ? 1.0 : 0.45, r1 = mod(k, 2.0) < 0.5 ? 0.45 : 1.0; float a0 = k / 10.0 * TAU - PI * 0.5, a1 = (k + 1.0) / 10.0 * TAU - PI * 0.5;
  return mix(vec2(cos(a0), sin(a0)) * r0, vec2(cos(a1), sin(a1)) * r1, f) * S; }
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 96.0)); float closed = p_kapaliYol > 0.5 && (p_yol < 0.5 || p_yol > 1.5) ? 1.0 : 0.0;
  for (int i = 0; i < 96; i++) { if (i >= N) break; float t = mix(p_baslangi, p_bitis, float(i) / max(float(N) - (closed > 0.5 ? 0.0 : 1.0), 1.0)) / 100.0; vec2 c = pathAt(t);
    vec2 l = q - c; if (p_yolaDond > 0.5) { vec2 tg = pathAt(t + 0.002) - pathAt(t - 0.002); l = rot2(-degrees(atan(tg.y, tg.x))) * l; } res = overPre(texU(l / 0.3), res); }
  o = res;
}
