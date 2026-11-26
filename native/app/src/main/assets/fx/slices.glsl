// slices
uniform float p_dilimSayi, p_azamiKaym, p_aci, p_yenilenm, p_tohum, p_sarmala;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 p = rot2(-p_aci) * q;
  float n = max(2.0, floor(p_dilimSayi)); float hh = max(B.x, B.y);
  float id = floor((p.y / hh + 0.5) * n);
  float r = hash1(vec2(id, floor(u_t * p_yenilenm) + seedf(p_tohum))) * 2.0 - 1.0;
  vec2 src = rot2(p_aci) * (p - vec2(r * p_azamiKaym, 0.0));
  o = p_sarmala > 0.5 ? texEdge(fromUnit(src), 2.0) : texU(src);
}
