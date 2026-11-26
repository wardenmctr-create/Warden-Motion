// plateseparate
uniform float p_plaka, p_kayma, p_gecikme, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; int N = int(clamp(p_plaka, 2.0, 8.0)); vec3 acc = vec3(0.0); float a = 0.0;
  for (int i = 0; i < 8; i++) { if (i >= N) break; float k = clamp((p - float(i) * p_gecikme) / max(1.0 - float(N - 1) * p_gecikme, 0.1), 0.0, 1.0); float ang = float(i) * TAU / float(N); vec2 off = vec2(cos(ang), sin(ang)) * p_kayma * k * u_s;
    vec4 c = texPx(here() - off); vec3 ink = hsv2rgb(vec3(float(i) / float(N), 0.9, 1.0)); acc += unpre(c) * ink * c.a * (1.0 - k) * (3.0 / float(N)); a = max(a, c.a * (1.0 - k)); }
  o = pre(clamp(acc, 0.0, 1.0), a); }
