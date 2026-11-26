// tileshift
uniform float p_karoBoyu, p_kaydirma, p_yon, p_rastgeleYon, p_faz, p_tohum, p_kenariKirp;
void main() {
  vec2 q = toUnit(here()); float s = max(p_karoBoyu, 2.0); vec2 id = floor(q / s); vec2 c = (id + 0.5) * s;
  vec2 rr = hash2(id + seedf(p_tohum) + floor(p_faz / 10.0));
  float ang = radians(p_yon) + (rr.x - 0.5) * TAU * p_rastgeleYon / 100.0;
  float amt = p_kaydirma * mix(1.0, rr.y * 2.0 - 1.0, p_rastgeleYon / 100.0) * (0.6 + 0.4 * cos(p_faz * TAU / 100.0));
  vec2 src = q - vec2(cos(ang), sin(ang)) * amt;
  if (p_kenariKirp > 0.5 && any(greaterThan(abs(src - c), vec2(s * 0.5)))) { o = vec4(0.0); return; }
  o = texU(src);
}
