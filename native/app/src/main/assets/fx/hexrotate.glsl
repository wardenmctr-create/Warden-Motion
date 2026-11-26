// hexrotate
uniform float p_altigenBoyu, p_donusAcis, p_rastgeleDonu, p_faz, p_tohum, p_kenariKirp;
void main() {
  vec2 q = toUnit(here()); float s = max(p_altigenBoyu, 4.0); vec4 h = hexGrid(q, s);
  float r = hash1(h.zw + seedf(p_tohum)) * 2.0 - 1.0;
  float ang = p_donusAcis * mix(1.0, r, p_rastgeleDonu / 100.0) + p_faz * 3.6;
  vec2 src = h.xy + rot2(-ang) * (q - h.xy);
  if (p_kenariKirp > 0.5) { vec4 h2 = hexGrid(src, s); if (distance(h2.zw, h.zw) > 0.1) { o = vec4(0.0); return; } }
  o = texU(src);
}
