// pixelclean
uniform float p_hucreBoyu, p_kural, p_gecis, p_paletiKoru;
// Piksel sanatı hücreleri: tek hücrelik çıkıntı (komşuların çoğu aynı ve farklı) → komşu rengi; çentik (boş hücre, dolu komşular) → doldur
void main() { vec4 s = texture(u_tex, v_uv); float C = max(p_hucreBoyu * u_s, 1.0); vec2 c0 = (floor(here() / C) + 0.5) * C; vec4 me = texPx(c0);
  vec4 n[4]; n[0] = texPx(c0 + vec2(C, 0.0)); n[1] = texPx(c0 - vec2(C, 0.0)); n[2] = texPx(c0 + vec2(0.0, C)); n[3] = texPx(c0 - vec2(0.0, C));
  float need = 4.0 - min(p_gecis - 1.0, 1.0); vec4 best = me; float bc = 0.0;
  for (int i = 0; i < 4; i++) { float cnt = 0.0; for (int j = 0; j < 4; j++) cnt += step(length(n[i] - n[j]), 0.08); if (cnt > bc) { bc = cnt; best = n[i]; } }
  bool differs = length(best - me) > 0.08; vec4 r = me;
  if (p_kural < 0.5 && differs && bc >= need - 1.0 && me.a > 0.5) r = best; else if (p_kural >= 0.5 && me.a < 0.5 && best.a > 0.5 && bc >= need - 1.0) r = best;
  o = r; }
