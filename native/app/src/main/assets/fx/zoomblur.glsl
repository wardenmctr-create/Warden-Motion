// zoomblur
uniform vec2 p_merkez; uniform float p_yakinlas, p_ornekSayi, p_yon, p_kenarUzat;
void main() {
  vec2 c = fromUnit(p_merkez); vec2 r = here() - c; float z = p_yakinlas / 100.0; int N = int(clamp(p_ornekSayi, 4.0, 128.0)); vec4 acc = vec4(0.0);
  for (int i = 0; i < 128; i++) { if (i >= N) break; float t = (float(i) + 0.5) / float(N); float s = p_yon < 0.5 ? 1.0 - z * t : p_yon < 1.5 ? 1.0 + z * t : 1.0 + z * (t - 0.5); acc += texEdge(c + r * s, p_kenarUzat > 0.5 ? 3.0 : 0.0); }
  o = acc / float(N);
}
