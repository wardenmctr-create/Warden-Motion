// scatterfield
INCLUDE(_rep)
uniform float p_yogunluk, p_alanX, p_alanY, p_enKucuOlce, p_enBuyuOlce, p_hiz, p_yon, p_tohum, p_sarmala, p_rastgeleDon;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); vec2 A = vec2(max(p_alanX, 10.0), max(p_alanY, 10.0)); float cell = sqrt(A.x * A.y / max(p_yogunluk, 1.0)); vec2 dir = vec2(cos(radians(p_yon)), sin(radians(p_yon)));
  vec2 p = q - dir * p_hiz * u_t; if (p_sarmala > 0.5) p = mod(p + A * 0.5, A) - A * 0.5; vec2 id = floor(p / cell);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(float(i), float(j)); vec2 h = hash2(c + seedf(p_tohum)); vec2 h2 = hash2(c + 3.7); float k = mod(c.x * 7.0 + c.y * 13.0, 97.0);
    vec2 cp = (c + h) * cell; float sc = mix(p_enKucuOlce, p_enBuyuOlce, h2.x) / 100.0; vec2 l = p - cp; if (p_rastgeleDon > 0.5) l = rot2(-h2.y * 360.0) * l; res = rov(res, repC(texU(repL(l / max(sc, 0.01), k)), k)); }
  o = res;
}
