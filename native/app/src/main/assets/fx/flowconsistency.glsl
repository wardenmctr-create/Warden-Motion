// flowconsistency
INCLUDE(_hist)
uniform sampler2D s_duzenlemMask; uniform float p_duzenlemMaskOn, p_baglilik, p_komsu, p_okluzyonEsig;
// Düzenlenmiş bölgede (maske ya da tüm katman) şimdiki kare, komşu karelerin ortalamasına bağlılık oranında çekilir; büyük farkta (örtülme) bağlanmaz
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 2.0) { o = s; return; } float m = p_duzenlemMaskOn > 0.5 ? texture(s_duzenlemMask, boxUV(here())).a : 1.0; vec4 acc = vec4(0.0); float w = 0.0;
  for (int k = 1; k < 9; k++) { if (float(k) >= min(n, p_komsu + 1.0)) break; vec4 c = hist(float(k), v_uv); if (length(c.rgb - s.rgb) > p_okluzyonEsig / 100.0 + 0.02) continue; acc += c; w += 1.0; }
  if (w <= 0.0) { o = s; return; } o = mix(s, acc / w, m * p_baglilik / 100.0); }
