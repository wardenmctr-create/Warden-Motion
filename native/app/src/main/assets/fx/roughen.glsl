// roughen
uniform float p_kenarMikt, p_dokuOlce, p_ayrinti, p_evrim, p_tohum, p_kenarYumu;
void main() {
  vec2 q = toUnit(here()); vec2 n = q / max(p_dokuOlce, 1.0) + seedf(p_tohum);
  vec2 d = vec2(fbm(n + vec2(p_evrim * 0.05, 0.0), p_ayrinti - 1.0), fbm(n + vec2(3.7, -p_evrim * 0.05), p_ayrinti - 1.0)) * p_kenarMikt;
  vec4 s = texU(q); vec4 w = texU(q + d);
  float a = smoothstep(0.5 - max(p_kenarYumu, 0.3) * 0.1, 0.5 + max(p_kenarYumu, 0.3) * 0.1, w.a);
  o = pre(s.a > 0.01 ? unpre(s) : unpre(w), a);
}
