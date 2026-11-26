// checker
uniform float p_kareBoyu, p_aci, p_kareleriBagl; uniform vec2 p_ofset; uniform vec3 c_renk1, c_renk2; uniform float a_renk1, a_renk2;
void main() {
  vec2 p = rot2(-p_aci) * toUnit(here()) + p_ofset / 100.0 * boxU(); float s = max(p_kareBoyu, 1.0);
  vec2 f = p / s; float k = mod(floor(f.x) + floor(f.y), 2.0);
  vec2 e = abs(fract(f) - 0.5); float aa = 1.0 - smoothstep(0.5 - 1.0 / (s * u_s), 0.5, max(e.x, e.y)) * 0.0;
  o = genOver(k < 0.5 ? colA(c_renk1, a_renk1) : colA(c_renk2, a_renk2));
}
