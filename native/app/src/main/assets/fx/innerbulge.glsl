// innerbulge
uniform vec2 p_merkez; uniform float p_yaricap, p_sisirme, p_kenarKoru, p_dusus, p_alfayiKoru;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float R = max(p_yaricap, 1.0); float x = length(r) / R;
  float f = x < 1.0 ? pow(1.0 - x * x, mix(0.5, 2.0, p_dusus / 100.0)) : 0.0;
  float k = p_kenarKoru; float m = 1.0;
  if (k > 0.01) { for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; m = min(m, texU(q + vec2(cos(a), sin(a)) * k).a); } }
  vec4 s = texU(p_merkez + r * (1.0 - p_sisirme / 100.0 * 0.65 * f * m));
  if (p_alfayiKoru > 0.5) s = pre(unpre(s), texU(q).a);
  o = s;
}
