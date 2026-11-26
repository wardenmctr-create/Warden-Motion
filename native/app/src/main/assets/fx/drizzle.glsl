// drizzle
uniform float p_damlaSikl, p_halkaYari, p_dalgaYuks, p_omur, p_sonum, p_tohum, p_isikYans;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); vec2 disp = vec2(0.0); float lit = 0.0; float per = 1.0 / max(p_damlaSikl, 0.05);
  for (int i = 0; i < 8; i++) { float k = floor(u_t / per) - float(i); float t = u_t - k * per; if (t > p_omur || k < 0.0) continue; vec2 c = (hash2(vec2(k, seedf(p_tohum))) - 0.5) * B;
    vec2 r = q - c; float d = length(r); float R = p_halkaYari * t / max(p_omur, 0.05); float w = exp(-pow((d - R) / 6.0, 2.0)) * (1.0 - t / max(p_omur, 0.05)) * mix(1.0, 0.3, p_sonum / 100.0 * t);
    disp += (d > 0.01 ? r / d : vec2(0.0)) * w * p_dalgaYuks * sin((d - R) * 0.8); lit += w; }
  vec4 c = texU(q + disp); if (p_isikYans > 0.5) c.rgb += vec3(lit * 0.15) * c.a; o = c; }
