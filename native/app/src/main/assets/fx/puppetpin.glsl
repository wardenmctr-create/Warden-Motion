// puppetpin
uniform vec2 p_pimKonu; uniform float p_pimTuru, p_pimEtkiAlan, p_sertlik, p_agiGost, p_dvN; uniform float p_dv[8];
void main() { vec2 q = toUnit(here()); vec2 start = p_dvN >= 2.0 ? vec2(p_dv[0], p_dv[1]) : p_pimKonu; vec2 disp = p_pimKonu - start; float R = max(p_pimEtkiAlan, 1.0) * (1.0 + (1.0 - p_sertlik / 100.0));
  float w = exp(-dot(q - p_pimKonu, q - p_pimKonu) / (R * R)); if (p_pimTuru > 0.5) w = 0.0; vec4 c = texU(q - disp * w);
  if (p_agiGost > 0.5 && u_export < 0.5) { vec2 g = abs(fract((q - disp * w) / 20.0) - 0.5); c = overPre(vec4(0.3, 0.7, 1.0, 1.0) * (1.0 - smoothstep(0.0, 0.05, min(g.x, g.y))) * 0.5 * c.a, c); c = overPre(vec4(1.0, 0.8, 0.2, 1.0) * (1.0 - smoothstep(4.0, 6.0, length(q - p_pimKonu))), c); }
  o = c; }
