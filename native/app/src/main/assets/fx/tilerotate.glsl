// tilerotate
uniform float p_karoBoyu, p_donusAcis, p_rastgeleDonu, p_faz, p_tohum, p_kenariKirp;
void main() {
  vec2 q = toUnit(here()); float s = max(p_karoBoyu, 2.0); vec2 id = floor(q / s); vec2 c = (id + 0.5) * s;
  float r = hash1(id + seedf(p_tohum)) * 2.0 - 1.0;
  float ang = p_donusAcis * mix(1.0, r, p_rastgeleDonu / 100.0) + p_faz * 3.6;
  vec2 src = c + rot2(-ang) * (q - c);
  if (p_kenariKirp > 0.5 && any(greaterThan(abs(src - c), vec2(s * 0.5)))) { o = vec4(0.0); return; }
  o = texU(src);
}
