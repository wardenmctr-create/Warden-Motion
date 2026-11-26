// photocopy
uniform float p_kontrast, p_parlakli, p_tonerYogu, p_siyahEsig, p_renkKayb, p_baskiCozu, p_kenarAsin, p_tonerTasm, p_gurultu, p_kagitDoku, p_lekeYogu, p_baskiCizg, p_kopyaNesl, p_saydamliKoru; uniform vec3 c_tonerReng, c_kagitReng;
void main() { float gen = max(p_kopyaNesl, 1.0); float g = log2(gen + 1.0); float res = mix(3.0, 0.5, p_baskiCozu / 100.0) * (1.0 + g * 0.35);
  vec2 px = here() + vec2(0.0, sin(here().y * 0.01) * g * 0.6 * u_s); vec2 cell = floor(px / max(res * u_s, 1.0)) * max(res * u_s, 1.0); vec4 s = texture(u_tex, v_uv); vec4 sp = texPx(mix(px, cell, 0.6));
  vec3 c = unpre(sp); float L = luma(c); L = (L - 0.5) * (1.0 + p_kontrast / 50.0 + g * 0.25) + 0.5 + p_parlakli / 100.0;
  float n = (hash1(floor(px / max(u_s, 0.5)) + floor(u_t * 12.0)) - 0.5) * p_gurultu / 100.0 * (1.0 + g * 0.3); float th = p_siyahEsig / 100.0;
  float toner = smoothstep(th + 0.08, th - 0.08 - p_tonerTasm * 0.02, L + n) * p_tonerYogu / 100.0 * (1.0 + 0.15 * g);
  float wear = p_kenarAsin / 100.0 * smoothstep(0.0, 1.0, 1.0 - innerDist(here(), 6.0 * u_s) / (6.0 * u_s)) * step(0.5, hash1(floor(px / (2.0 * u_s)))); toner *= 1.0 - wear;
  if (p_baskiCizg > 0.5) toner = max(toner, step(0.985, hash1(vec2(floor(px.x / (1.5 * u_s)), 3.0))) * 0.6 * step(0.3, vnoise(vec2(px.x * 0.01, px.y * 0.002))));
  float spots = step(1.0 - p_lekeYogu / 100.0 * 0.03 * (1.0 + g * 0.2), hash1(floor(px / (3.0 * u_s)) + 7.0)); toner = max(toner, spots * 0.8);
  vec3 paper = c_kagitReng * (1.0 - p_kagitDoku / 100.0 * 0.15 * vnoise(toUnit(px) * 0.4)) * (1.0 - g * 0.03);
  vec3 colKept = mix(c, vec3(luma(c)), p_renkKayb / 100.0); vec3 outc = mix(mix(paper, paper * colKept, 1.0 - p_renkKayb / 100.0), c_tonerReng, clamp(toner, 0.0, 1.0));
  o = pre(clamp(outc, 0.0, 1.0), p_saydamliKoru > 0.5 ? s.a : 1.0); }
