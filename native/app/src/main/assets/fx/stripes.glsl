// stripes
uniform float p_seritGeni, p_bosluk, p_aci, p_faz, p_hiz, p_kenarGeci; uniform vec3 c_renk1, c_renk2; uniform float a_renk1, a_renk2;
void main() {
  vec2 p = rot2(-p_aci) * toUnit(here()); float per = max(p_seritGeni + p_bosluk, 1.0);
  float x = mod(p.x + p_faz / 100.0 * per + u_t * p_hiz * per, per);
  float w = max(p_kenarGeci / 100.0 * per * 0.25, 0.6 / u_s);
  float k = smoothstep(p_seritGeni - w, p_seritGeni + w, x) * (1.0 - smoothstep(per - w, per + w * 0.0, x));
  if (x < w) k = 1.0 - smoothstep(-w, w, x);
  o = genOver(mix(colA(c_renk1, a_renk1), colA(c_renk2, a_renk2), k));
}
