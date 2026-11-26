// framerepair
INCLUDE(_hist)
uniform float p_kareSeci, p_tahminYont, p_hareketGuve, p_sahneKesiKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 3.0) { o = s; return; } vec4 a = hist(1.0, v_uv), b = hist(2.0, v_uv); vec4 avg = (a + b) * 0.5;
  // karenin tamamına bakılır: 4×4 örnekte komşu karelere göre aykırı mı?
  float dev = 0.0, nb = 0.0; for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) { vec2 uv = (vec2(i, j) + 0.5) / 4.0; vec4 c = hist(0.0, uv), p = hist(1.0, uv), n = hist(2.0, uv); dev += length(c.rgb - (p.rgb + n.rgb) * 0.5); nb += length(p.rgb - n.rgb); }
  bool bad = dev > nb * (1.0 + p_hareketGuve / 50.0) + 0.6; if (p_sahneKesiKoru > 0.5 && nb > 4.0) bad = false; if (!bad) { o = s; return; } o = p_tahminYont < 0.5 ? a : avg; }
