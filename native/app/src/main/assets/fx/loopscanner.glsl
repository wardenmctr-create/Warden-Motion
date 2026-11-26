// loopscanner
INCLUDE(_hist)
INCLUDE(_chart)
uniform float p_enKisaSure, p_enUzun, p_aday, p_hareketAgir;
// Şimdiki kare ile en kısa…en uzun süre sonraki kareler (motor: kare şeridi) karşılaştırılır; benzerlik çubukları, en iyi aday yeşil, süre etiketi
float simK(float k) { float d = 0.0; for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) { vec2 uv = (vec2(i, j) + 0.5) / 4.0; d += length(hist(0.0, uv).rgb - hist(k, uv).rgb); } return 1.0 - d / 16.0 / 1.732; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float n = histN(); if (n < 2.0 || b.y < 0.7) { o = s; return; } vec4 res = overPre(vec4(0.04, 0.05, 0.08, 0.8), s); float K = n - 1.0; float best = -1.0, bk = 1.0;
  for (int k = 1; k < 16; k++) { if (float(k) > K) break; float v = simK(float(k)); if (v > best) { best = v; bk = float(k); } }
  float k = floor(b.x * K) + 1.0; float v = simK(k); float h = clamp((v - 0.5) * 2.0, 0.02, 1.0); if (b.y > 0.98 - h * 0.2 && fract(b.x * K) > 0.15) res = vec4(k == bk ? vec3(0.3, 1.0, 0.45) : vec3(0.5, 0.6, 0.8), 1.0);
  float dur = p_enKisaSure + (p_enUzun - p_enKisaSure) * (bk - 1.0) / max(K - 1.0, 1.0); vec2 lp = (b - vec2(0.12, 0.75)) / vec2(0.03, 0.035); res = overPre(vec4(1.0) * numAt(lp, dur * 10.0), res); o = res; }
