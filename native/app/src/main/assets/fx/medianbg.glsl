// medianbg
INCLUDE(_hist)
uniform float p_analizSure, p_ornek, p_hareketEsig, p_sonucuOnbe;
// Kare şeridindeki karelerin piksel bazlı medyanı (parlaklığa göre sıralı orta değer); hareket eşiği aykırıları dışlar
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 3.0) { o = s; return; } vec4 c[16]; float l[16]; int m = int(min(n, 16.0));
  for (int i = 0; i < 16; i++) { if (i >= m) break; c[i] = hist(float(i), v_uv); l[i] = luma(c[i].rgb) + c[i].a * 0.001; }
  for (int a = 0; a < 16; a++) for (int i = 0; i < 15; i++) { if (i + 1 >= m) break; if (l[i] > l[i + 1]) { float t = l[i]; l[i] = l[i + 1]; l[i + 1] = t; vec4 tc = c[i]; c[i] = c[i + 1]; c[i + 1] = tc; } }
  vec4 med = c[m / 2]; vec4 acc = vec4(0.0); float w = 0.0; float th = p_hareketEsig / 100.0 + 0.02;
  for (int i = 0; i < 16; i++) { if (i >= m) break; if (abs(l[i] - l[m / 2]) <= th) { acc += c[i]; w += 1.0; } }
  o = w > 0.0 ? acc / w : med; }
