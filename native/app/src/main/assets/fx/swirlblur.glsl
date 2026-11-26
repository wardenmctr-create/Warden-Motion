// swirlblur
uniform vec2 p_merkez; uniform float p_girdapAcis, p_yaricap, p_bulanikl, p_dusus, p_ornekSayi;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float R = max(p_yaricap, 1.0); float t = clamp(1.0 - length(r) / R, 0.0, 1.0);
  float f = pow(t, mix(0.5, 2.5, p_dusus / 100.0)); int N = int(clamp(p_ornekSayi, 4.0, 64.0)); vec4 acc = vec4(0.0);
  float span = p_bulanikl / max(length(r), 5.0) * 57.3 * f + p_girdapAcis * f * 0.3;
  for (int i = 0; i < 64; i++) { if (i >= N) break; float u = (float(i) + 0.5) / float(N) - 0.5; acc += texU(p_merkez + rot2(-p_girdapAcis * f + span * u) * r); }
  o = acc / float(N);
}
