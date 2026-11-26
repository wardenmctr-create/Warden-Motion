// hexshift
uniform float p_altigenBoyu, p_kaydirma, p_rastgeleYon, p_faz, p_tohum, p_kenariKirp;
void main() {
  vec2 q = toUnit(here()); float s = max(p_altigenBoyu, 4.0); vec4 h = hexGrid(q, s);
  vec2 rr = hash2(h.zw + seedf(p_tohum) + floor(p_faz / 10.0));
  float ang = mix(0.0, rr.x * TAU, p_rastgeleYon / 100.0); float amt = p_kaydirma * mix(1.0, rr.y, 0.5) * (0.6 + 0.4 * cos(p_faz * TAU / 100.0));
  vec2 src = q - vec2(cos(ang), sin(ang)) * amt;
  if (p_kenariKirp > 0.5) { vec4 h2 = hexGrid(src, s); if (distance(h2.zw, h.zw) > 0.1) { o = vec4(0.0); return; } }
  o = texU(src);
}
