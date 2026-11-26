// Grafik verisi: motor, seçilen metin katmanının satırlarını p_dv (satır×sütun), p_dvR, p_dvC olarak verir. Veri yoksa örnek tablo kullanılır.
uniform float p_dv[256]; uniform float p_dvR, p_dvC;
float dR() { return p_dvR > 0.5 ? p_dvR : 6.0; }
float dC() { return p_dvC > 0.5 ? p_dvC : 3.0; }
float dat(float r, float c) { if (p_dvR > 0.5) { int i = int(r) * int(p_dvC) + int(c); return i >= 0 && i < 256 ? p_dv[i] : 0.0; } return 20.0 + 15.0 * sin(r * 1.3 + c * 2.1) + c * 8.0 + r * 3.0; }
float dMax() { float m = 1e-6; for (int r = 0; r < 64; r++) { if (float(r) >= dR()) break; for (int c = 0; c < 16; c++) { if (float(c) >= dC()) break; m = max(m, abs(dat(float(r), float(c)))); } } return m; }
vec3 serCol(float i, vec3 base) { return hsv2rgb(vec3(fract(rgb2hsv(base).x + i * 0.17 + (rgb2hsv(base).y < 0.1 ? 0.58 : 0.0)), 0.65, 0.95)); }
float seg7(vec2 p, int d) { int m[10] = int[10](63, 6, 91, 79, 102, 109, 125, 7, 127, 111); int b = m[abs(d) % 10]; float r = 0.0;
  vec2 a[7] = vec2[7](vec2(0.0, 0.8), vec2(0.45, 0.4), vec2(0.45, -0.4), vec2(0.0, -0.8), vec2(-0.45, -0.4), vec2(-0.45, 0.4), vec2(0.0, 0.0));
  for (int i = 0; i < 7; i++) { if ((b / int(pow(2.0, float(i)))) % 2 == 0) continue; vec2 q = p - a[i]; bool hz = i == 0 || i == 3 || i == 6; vec2 e = hz ? vec2(0.34, 0.08) : vec2(0.08, 0.32); vec2 dd = abs(q) - e; r = max(r, 1.0 - smoothstep(0.0, 0.08, max(dd.x, dd.y))); } return r; }
float numAt(vec2 p, float v) { int iv = int(floor(abs(v) + 0.5)); int nd = 1; int t = iv; for (int i = 0; i < 6; i++) { if (t < 10) break; t /= 10; nd++; } float r = 0.0; t = iv;
  for (int i = 0; i < 7; i++) { if (i >= nd) break; r = max(r, seg7(p - vec2((float(nd - 1 - i) - float(nd - 1) * 0.5) * 1.1, 0.0), t % 10)); t /= 10; } return r; }
