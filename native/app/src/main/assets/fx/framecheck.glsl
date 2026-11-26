// framecheck
INCLUDE(_hist)
uniform sampler2D s_klip; uniform float p_klipOn, p_benzerliEsig, p_donmaAltSini, p_cikti;
// Ardışık karelerin benzerliği: art arda en az N kare neredeyse aynıysa donma (mavi), ani düşüşte kesme (kırmızı) işareti
float sim(float a, float c) { float d = 0.0; for (int j = 0; j < 5; j++) for (int i = 0; i < 5; i++) { vec2 uv = (vec2(i, j) + 0.5) / 5.0; d += length(hist(a, uv).rgb - hist(c, uv).rgb); } return 1.0 - d / 25.0 / 1.732; }
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 2.0) { o = s; return; } float th = p_benzerliEsig / 100.0; float run = 0.0; for (int k = 0; k < 15; k++) { if (float(k + 1) >= n) break; if (sim(float(k), float(k + 1)) >= th) run += 1.0; else break; }
  bool frozen = run + 1.0 >= p_donmaAltSini; bool cut = sim(0.0, 1.0) < 0.55; vec2 b = boxUV(here()); float border = step(min(min(b.x, 1.0 - b.x), min(b.y, 1.0 - b.y)), 0.025); vec4 res = s;
  if (frozen && p_cikti != 1.0) res = mix(res, vec4(0.25, 0.5, 1.0, 1.0), border * 0.9 + 0.12); if (cut && p_cikti != 0.0) res = mix(res, vec4(1.0, 0.25, 0.2, 1.0), border * 0.9 + 0.15); o = res; }
