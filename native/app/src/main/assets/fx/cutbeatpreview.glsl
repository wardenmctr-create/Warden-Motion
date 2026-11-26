// cutbeatpreview
INCLUDE(_hist)
uniform vec4 p_dv4[4]; float dvAt(int i) { return i < 0 || i >= 16 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_dvN, p_arama, p_ritimAgir, p_hareketUyum;
// Alt şerit: ±arama penceresinde vuruşlar (motor: ses başlangıç zamanları, şimdiye göre), hareket miktarı ve önerilen kesme noktası
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); if (b.y < 0.84) { o = s; return; } float x = (b.x - 0.5) * 2.0 * p_arama; vec4 res = overPre(vec4(0.03, 0.04, 0.08, 0.8), s);
  float mot = 0.0; if (histN() >= 2.0) { for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) { vec2 uv = (vec2(i, j) + 0.5) / 4.0; mot += length(hist(0.0, uv).rgb - hist(1.0, uv).rgb); } mot /= 16.0; }
  int N = p_dvN > 0.5 ? int(p_dvN) : 6; float best = 1e9; float bestT = 0.0;
  for (int k = 0; k < 16; k++) { if (k >= N) break; float bt = p_dvN > 0.5 ? dvAt(k) : (float(k) - 2.5) * 0.24 - mod(u_t, 0.24); if (abs(bt) > p_arama) continue; float score = abs(bt) * (1.0 - p_ritimAgir / 100.0 * 0.8); if (score < best) { best = score; bestT = bt; }
    res = overPre(vec4(1.0, 0.8, 0.3, 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.z * 2.0 * p_arama, abs(x - bt))) * step(0.88, b.y), res); }
  if (p_hareketUyum > 0.5) res = overPre(vec4(0.3, 0.8, 1.0, 1.0) * step(b.y, 0.88) * step(abs(b.x - 0.5) * 2.0, clamp(mot * 3.0, 0.0, 1.0)) * 0.7, res);
  res = overPre(vec4(1.0) * (1.0 - smoothstep(0.0, 1.0 / u_box.z * 2.0 * p_arama, abs(x))) * 0.6, res); if (best < 1e8) res = overPre(vec4(0.3, 1.0, 0.4, 1.0) * (1.0 - smoothstep(0.0, 3.0 / u_box.z * 2.0 * p_arama, abs(x - bestT))), res); o = res; }
