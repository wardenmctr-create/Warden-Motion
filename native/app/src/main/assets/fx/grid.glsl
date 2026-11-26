// grid
uniform float p_yatayAral, p_dikeyAral, p_cizgiKali, p_aci, p_araliklaBagl; uniform vec2 p_ofset; uniform vec3 c_cizgiReng, c_arkaPlan; uniform float a_cizgiReng, a_arkaPlan;
void main() {
  vec2 p = rot2(-p_aci) * toUnit(here()) + p_ofset / 100.0 * boxU(); vec2 sp = vec2(max(p_yatayAral, 1.0), max(p_araliklaBagl > 0.5 ? p_yatayAral : p_dikeyAral, 1.0));
  vec2 d = abs(fract(p / sp + 0.5) - 0.5) * sp; float w = p_cizgiKali * 0.5; float px = 0.7 / u_s;
  float l = max(1.0 - smoothstep(w - px, w + px, d.x), 1.0 - smoothstep(w - px, w + px, d.y));
  o = genOver(mix(colA(c_arkaPlan, a_arkaPlan), colA(c_cizgiReng, a_cizgiReng), l));
}
