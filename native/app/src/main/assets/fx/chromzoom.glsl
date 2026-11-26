// chromzoom
uniform vec2 p_merkez; uniform float p_yakinlas, p_kanalAyri, p_ornekSayi, p_yon, p_kenarUzat;
void main() {
  vec2 c = fromUnit(p_merkez); vec2 r = here() - c; int N = int(clamp(p_ornekSayi, 4.0, 64.0)); vec3 acc = vec3(0.0); float aa = 0.0;
  float e = p_kenarUzat > 0.5 ? 3.0 : 0.0; float z = p_yakinlas / 100.0 * (p_yon > 0.5 ? -1.0 : 1.0); float sep = p_kanalAyri * u_s / max(length(r), 10.0) * 0.5;
  for (int i = 0; i < 64; i++) { if (i >= N) break; float t = (float(i) + 0.5) / float(N); float s = 1.0 - z * t;
    vec4 xr = texEdge(c + r * (s - sep), e), xg = texEdge(c + r * s, e), xb = texEdge(c + r * (s + sep), e); acc += vec3(xr.r, xg.g, xb.b); aa += max(xr.a, max(xg.a, xb.a)); }
  o = vec4(acc / float(N), aa / float(N));
}
