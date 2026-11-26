// watercolor
uniform float p_lekeBoyu, p_renkYayi, p_kagitDoku, p_pigmentGucu, p_kenarKara, p_tohum;
void main() {
  vec2 q = toUnit(here()); vec2 w = vec2(fbm(q / max(p_lekeBoyu, 1.0) + seedf(p_tohum), 2.0), fbm(q / max(p_lekeBoyu, 1.0) + 7.0, 2.0)) * p_renkYayi;
  vec4 acc = vec4(0.0); for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; acc += texU(q + w + vec2(cos(a), sin(a)) * p_lekeBoyu * 0.35); }
  vec4 c = acc / 8.0; if (c.a <= 0.0) { o = c; return; }
  vec3 col = unpre(c); float l = luma(col); col = mix(vec3(l), col, p_pigmentGucu / 100.0 + 0.2);
  float ed = clamp(length(alphaGrad(fromUnit(q + w), 2.0)) * 4.0 + abs(fbm(q / max(p_lekeBoyu * 0.6, 1.0), 2.0)) * 0.3, 0.0, 1.0);
  col *= 1.0 - ed * p_kenarKara / 100.0 * 0.5;
  float paper = 1.0 - (fbm(q * 0.25, 3.0) * 0.5 + 0.5) * p_kagitDoku / 100.0 * 0.35;
  col = mix(vec3(0.97, 0.95, 0.9), col, 0.85) * paper;
  o = pre(clamp(col, 0.0, 1.0), smoothstep(0.1, 0.6, c.a));
}
