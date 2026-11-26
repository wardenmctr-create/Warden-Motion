// freqsep
uniform float p_filtre, p_ayirmaYari, p_renkDoyg, p_parlakli, p_ayrintiGucu, p_gurultuEsig, p_gorunum, p_alfayiKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float R = max(p_ayirmaYari, 0.5) * u_s; vec3 acc = vec3(0.0); float ws = 0.0;
  for (int i = 0; i < 24; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 24.0); vec3 c = unpre(texPx(here() + vec2(cos(a), sin(a)) * r)); float w = exp(-r * r / (R * R) * 2.0); if (p_filtre > 0.5) w *= exp(-pow(length(c - c0) * 6.0, 2.0)); acc += c * w; ws += w; }
  vec3 low = acc / ws; vec3 high = c0 - low; float hm = length(high); high *= smoothstep(p_gurultuEsig / 100.0 * 0.2, p_gurultuEsig / 100.0 * 0.2 + 0.01, hm) * step(0.0, hm);
  low = satAdj(low, p_renkDoyg / 100.0) + p_parlakli / 100.0; vec3 r = p_gorunum < 0.5 ? low + high * p_ayrintiGucu / 100.0 : p_gorunum < 1.5 ? low : high * p_ayrintiGucu / 100.0 + 0.5;
  o = pre(clamp(r, 0.0, 1.0), p_alfayiKoru > 0.5 ? s.a : 1.0); }
