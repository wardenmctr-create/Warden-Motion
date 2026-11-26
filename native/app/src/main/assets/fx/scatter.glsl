// scatter
uniform float p_kopyaSayi, p_alanX, p_alanY, p_olcekDegi, p_aciDegi, p_tohum, p_cakismayAzal; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 96.0));
  for (int i = 0; i < 96; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum))); vec2 h2 = hash2(vec2(float(i) + 0.3, seedf(p_tohum) + 5.0));
    vec2 c = p_merkez + (h - 0.5) * vec2(p_alanX, p_alanY); float sc = max(1.0 - p_olcekDegi / 100.0 * h2.x, 0.05) * 0.5; vec2 l = rot2(-(h2.y - 0.5) * 2.0 * p_aciDegi) * (q - c) / sc;
    res = overPre(texU(l), res); }
  o = res;
}
