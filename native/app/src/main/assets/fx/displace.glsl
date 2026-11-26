// displace
uniform float p_miktar, p_olcek, p_karmasik, p_evrim, p_bozulmaTipi, p_sabitKena, p_tohum; uniform vec2 p_ofset;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float sc = max(p_olcek, 1.0);
  vec2 n = (q + p_ofset / 100.0 * B) / sc + vec2(seedf(p_tohum)); float ev = p_evrim * 0.05;
  float oc = p_karmasik - 1.0;
  float fx = fbm(n + vec2(ev, 1.7), oc), fy = fbm(n + vec2(4.3, -ev), oc);
  vec2 d;
  if (p_bozulmaTipi < 0.5) d = vec2(fx, fy);
  else if (p_bozulmaTipi < 1.5) { vec2 r = normalize(q + 1e-4); d = r * fx; }
  else if (p_bozulmaTipi < 2.5) { vec2 r = normalize(q + 1e-4); d = vec2(-r.y, r.x) * fx; }
  else if (p_bozulmaTipi < 3.5) d = vec2(fx, 0.0); else d = vec2(0.0, fy);
  o = texU(q + d * p_miktar * pinW(p_sabitKena, boxUV(here())));
}
