// rays
uniform vec2 p_merkez; uniform float p_isinSayi, p_isinGeni, p_aci, p_hiz, p_merkezYumu; uniform vec3 c_renk1, c_renk2; uniform float a_renk1, a_renk2;
void main() {
  vec2 r = toUnit(here()) - p_merkez; float a = atan(r.y, r.x) - radians(p_aci) - u_t * p_hiz * TAU;
  float n = max(2.0, floor(p_isinSayi)); float f = fract(a / TAU * n); float w = p_isinGeni / 100.0;
  float k = smoothstep(0.0, 0.02, f) * (1.0 - smoothstep(w - 0.02, w, f));
  float cm = smoothstep(0.0, max(p_merkezYumu / 100.0 * min(boxU().x, boxU().y) * 0.5, 0.5), length(r)); k *= cm;
  o = genOver(mix(colA(c_renk2, a_renk2), colA(c_renk1, a_renk1), k));
}
