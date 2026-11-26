// cartogram
INCLUDE(_chart)
uniform float p_yineleme, p_kenarKoru, p_ilerleme;
// Satır: x %, y %, değer → merkez çevresinde alan değerle (√oran) büyür/küçülür; yumuşak ağırlıklı yer değiştirme alanı, kenarlar korunur
void main() { vec2 b = boxUV(here()); int N = int(min(dR(), 32.0)); float mean = 0.0; for (int r = 0; r < 32; r++) { if (r >= N) break; mean += abs(dat(float(r), 2.0)); } mean = max(mean / float(max(N, 1)), 1e-6);
  vec2 off = vec2(0.0); for (int r = 0; r < 32; r++) { if (r >= N) break; vec2 c = vec2(dat(float(r), 0.0), dat(float(r), 1.0)) / 100.0; float k = sqrt(abs(dat(float(r), 2.0)) / mean) - 1.0; vec2 d = b - c; float w = exp(-dot(d, d) / 0.02); off -= d * k * w * 0.6; }
  float edge = min(min(b.x, 1.0 - b.x), min(b.y, 1.0 - b.y)); off *= mix(1.0, smoothstep(0.0, 0.2, edge), p_kenarKoru / 100.0); o = texPx(boxPx(b + off * p_ilerleme / 100.0)); }
