// ripplepulse
uniform vec2 p_merkez; uniform float p_halkaIler, p_genlik, p_halkaGeni, p_yayilmaHizi, p_azalma, p_otomatikTekr;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 r = q - p_merkez; float d = length(r);
  float Rm = length(B) * 0.6; float prog = p_otomatikTekr > 0.5 ? fract(u_t * p_yayilmaHizi) : p_halkaIler / 100.0;
  float rr = prog * Rm; float w = max(p_halkaGeni, 1.0);
  float band = exp(-pow((d - rr) / w, 2.0)); float amp = p_genlik * (1.0 - prog * p_azalma / 100.0);
  vec2 dir = d > 0.001 ? r / d : vec2(0.0);
  o = texU(q - dir * sin((d - rr) / w * PI) * band * amp);
}
