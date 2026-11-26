// flomotion
uniform vec2 p_cekimMerk, p_ikinciMerk; uniform float p_kuvvet, p_yaricap, p_dusus, p_ikinciNokt, p_ikinciKuvv;
vec2 pull(vec2 q, vec2 c, float k) { vec2 r = q - c; float x = length(r) / max(p_yaricap, 1.0); float f = x < 1.0 ? pow(1.0 - x, mix(0.5, 3.0, p_dusus / 100.0)) : 0.0; return c + r * (1.0 + k / 100.0 * 0.9 * f); }
void main() {
  vec2 q = toUnit(here()); vec2 s = pull(q, p_cekimMerk, p_kuvvet);
  if (p_ikinciNokt > 0.5) s = pull(s, p_ikinciMerk, p_ikinciKuvv);
  o = texU(s);
}
