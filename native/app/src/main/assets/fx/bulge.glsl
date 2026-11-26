// bulge
uniform vec2 p_merkez; uniform float p_yaricap, p_sisirme, p_dusus, p_disHattKoru;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float R = max(p_yaricap, 1.0); float x = length(r) / R;
  float f = x < 1.0 ? pow(1.0 - x * x, mix(0.5, 2.0, p_dusus / 100.0)) : 0.0;
  vec4 s = texU(p_merkez + r * (1.0 - p_sisirme / 100.0 * 0.65 * f));
  if (p_disHattKoru > 0.5) s = pre(unpre(s), texU(q).a);
  o = s;
}
