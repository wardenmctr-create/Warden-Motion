// swirl
uniform vec2 p_merkez; uniform float p_yaricap, p_girdapAcis, p_dusus, p_disHattKoru;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float R = max(p_yaricap, 1.0);
  float t = clamp(1.0 - length(r) / R, 0.0, 1.0);
  float f = pow(smoothstep(0.0, 1.0, t), mix(0.6, 2.5, p_dusus / 100.0));
  vec4 s = texU(p_merkez + rot2(-p_girdapAcis * f) * r);
  if (p_disHattKoru > 0.5) { float a0 = texU(q).a; s = pre(unpre(s), a0); }
  o = s;
}
