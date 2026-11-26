// swishpan
uniform float p_yon, p_ivme, p_bulanikl, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; float e = mix(p, p * p * (3.0 - 2.0 * p), p_ivme / 100.0); vec2 d = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec2 q = toUnit(here()); vec2 sh = d * e * length(boxU()) * 1.2;
  float bl = p_bulanikl * sin(p * PI) * u_s; vec4 acc = vec4(0.0); for (int i = 0; i < 16; i++) acc += texU(q - sh + d * bl / u_s * (float(i) / 15.0 - 0.5)); o = acc / 16.0; }
