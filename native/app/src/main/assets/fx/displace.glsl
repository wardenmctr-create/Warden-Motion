// displace
uniform float p_miktar, p_olcek, p_karmasik, p_evrim, p_bozulmaTipi, p_sabitKena, p_tohum, p_eksenBagla, p_turbYon, p_kenarKoru, p_evrimHiz, p_dongu, p_donguSure;
uniform vec2 p_ofset, p_turbOlcek, p_paralaks;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 so = max(p_turbOlcek, vec2(1.0)) / 100.0; if (p_eksenBagla > 0.5) so = vec2(so.x);
  vec2 qq = rot2(-p_turbYon) * q; vec2 n = (qq + p_ofset / 100.0 * B + p_paralaks) / (max(p_olcek, 1.0) * so) + vec2(seedf(p_tohum));
  float evo = p_evrim * 0.05 + radians(p_evrimHiz) * u_t * 0.3; float oc = p_karmasik - 1.0; vec2 d;
  if (p_dongu > 0.5) { float a = TAU * fract(u_t / max(p_donguSure, 0.1)); vec2 c = vec2(cos(a), sin(a)) * 0.8; d = vec2(fbm(n + c, oc), fbm(n + c + 4.3, oc)); }
  else d = vec2(fbm(n + vec2(evo, 1.7), oc), fbm(n + vec2(4.3, -evo), oc));
  if (p_bozulmaTipi > 0.5 && p_bozulmaTipi < 1.5) { vec2 r = normalize(q + 1e-4); d = r * d.x; } else if (p_bozulmaTipi > 1.5 && p_bozulmaTipi < 2.5) { vec2 r = normalize(q + 1e-4); d = vec2(-r.y, r.x) * d.x; }
  else if (p_bozulmaTipi > 2.5 && p_bozulmaTipi < 3.5) d.y = 0.0; else if (p_bozulmaTipi > 3.5) d.x = 0.0;
  d = rot2(p_turbYon) * d;
  float w = pinW(p_sabitKena, boxUV(here())); if (p_kenarKoru > 0.0) w *= mix(1.0, pinW(1.0, boxUV(here())), p_kenarKoru / 100.0);
  o = texU(q + d * p_miktar * w);
}
