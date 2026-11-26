// deinterlace
uniform float p_alanSira, p_yontem, p_hareketEsig, p_ayrintiKoru, p_yalnizTaraBolg, p_gorunum;
void main() { vec2 px = here(); vec4 s = texture(u_tex, v_uv); float row = floor(px.y); bool keepEven = p_alanSira < 1.5; bool missing = (mod(row, 2.0) > 0.5) == keepEven;
  vec4 up = texPx(px - vec2(0.0, 1.0)), dn = texPx(px + vec2(0.0, 1.0)); vec4 up2 = texPx(px - vec2(0.0, 2.0)), dn2 = texPx(px + vec2(0.0, 2.0));
  float comb = abs(luma(unpre(s)) - luma(unpre(up + dn) * 0.5)) - abs(luma(unpre(up)) - luma(unpre(dn))) * 0.5; float m = smoothstep(p_hareketEsig / 100.0 * 0.3, p_hareketEsig / 100.0 * 0.3 + 0.05, comb);
  if (p_gorunum > 1.5) { o = vec4(vec3(m), 1.0); return; } if (p_gorunum > 0.5) { o = missing ? vec4(0.0, 0.0, 0.0, 1.0) : s; return; }
  if (!missing) { o = s; return; }
  vec4 fix = p_yontem < 0.5 ? up : mix((up + dn) * 0.5, (up + dn) * 0.5 + ((up - up2) + (dn - dn2)) * 0.125 * p_ayrintiKoru / 100.0, 0.5);
  float w = p_yontem > 1.5 || p_yalnizTaraBolg > 0.5 ? m : 1.0; o = mix(s, clamp(fix, 0.0, 1.0), w); }
