// chromvortex
uniform vec2 p_merkez; uniform float p_donusAcis, p_kanalAyri, p_ornekSayi, p_renkSira, p_kenarUzat;
void main() {
  vec2 c = fromUnit(p_merkez); vec2 r = here() - c; int N = int(clamp(p_ornekSayi, 4.0, 64.0)); vec3 acc = vec3(0.0); float aa = 0.0;
  float e = p_kenarUzat > 0.5 ? 3.0 : 0.0; float sep = p_kanalAyri / max(length(r) / u_s, 10.0) * 57.3;
  for (int i = 0; i < 64; i++) { if (i >= N) break; float t = (float(i) + 0.5) / float(N) - 0.5;
    vec4 xr = texEdge(c + rot2(p_donusAcis * t - sep) * r, e), xg = texEdge(c + rot2(p_donusAcis * t) * r, e), xb = texEdge(c + rot2(p_donusAcis * t + sep) * r, e);
    acc += p_renkSira < 0.5 ? vec3(xr.r, xg.g, xb.b) : vec3(xb.r, xg.g, xr.b); aa += max(xr.a, max(xg.a, xb.a)); }
  o = vec4(acc / float(N), aa / float(N));
}
