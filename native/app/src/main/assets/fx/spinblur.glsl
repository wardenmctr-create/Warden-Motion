// spinblur
uniform vec2 p_merkez; uniform float p_donusMikt, p_ornekSayi, p_disaDogrGuc, p_kenarUzat;
void main() {
  vec2 c = fromUnit(p_merkez); vec2 r = here() - c; float L = length(boxU() * u_s) * 0.5;
  float k = mix(1.0, clamp(length(r) / max(L, 1.0), 0.0, 1.0), p_disaDogrGuc / 100.0);
  int N = int(clamp(p_ornekSayi, 4.0, 128.0)); vec4 acc = vec4(0.0);
  for (int i = 0; i < 128; i++) { if (i >= N) break; float t = (float(i) + 0.5) / float(N) - 0.5; acc += texEdge(c + rot2(p_donusMikt * k * t) * r, p_kenarUzat > 0.5 ? 3.0 : 0.0); }
  o = acc / float(N);
}
