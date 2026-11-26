// temporalfreq
INCLUDE(_hist)
uniform float p_altUst, p_pencere, p_cikti;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 4.0) { o = s; return; } float re = 0.0, im = 0.0; float f = clamp(p_altUst, 0.1, N / 2.0);
  float mean = 0.0; for (int i = 0; i < 16; i++) { if (float(i) >= N) break; mean += luma(hist(float(i), v_uv).rgb); } mean /= N;
  for (int i = 0; i < 16; i++) { if (float(i) >= N) break; float l = luma(hist(float(i), v_uv).rgb) - mean; float ph = TAU * f * float(i) / N; re += l * cos(ph); im += l * sin(ph); }
  float e = clamp(sqrt(re * re + im * im) / N * 8.0, 0.0, 1.0); o = p_cikti < 0.5 ? vec4(vec3(e), e) : p_cikti < 1.5 ? overPre(vec4(hsv2rgb(vec3(0.66 - e * 0.66, 1.0, 1.0)), 1.0) * e, s * 0.5) : vec4(vec3(e), 1.0); }
