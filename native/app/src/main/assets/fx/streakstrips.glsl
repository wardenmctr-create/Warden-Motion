// streakstrips
uniform float p_seritKali, p_aci, p_azamiIz, p_rastgele, p_faz, p_tohum, p_ikiYon;
void main() {
  vec2 q = rot2(-p_aci) * toUnit(here()); float w = max(p_seritKali, 0.5); float id = floor(q.y / w);
  float r = mix(1.0, hash1(vec2(id, seedf(p_tohum))), p_rastgele / 100.0); float L = p_azamiIz * r * (0.6 + 0.4 * cos(p_faz / 100.0 * TAU + id));
  float dir = p_ikiYon > 0.5 && mod(id, 2.0) > 0.5 ? -1.0 : 1.0; vec4 acc = vec4(0.0);
  for (int i = 0; i < 16; i++) { float t = float(i) / 15.0; acc += texU(rot2(p_aci) * (q - vec2(L * t * dir, 0.0))); }
  o = acc / 16.0;
}
