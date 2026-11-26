// pitchcurve
INCLUDE(_chart)
uniform float p_dvN, p_altSini, p_ustSini, p_guvenEsig, p_notaEtik;
// Nota ekseni (yarım ton çizgileri, Do notaları belirgin) üzerinde son 3 saniyenin perde eğrisi
float M(int i) { if (p_dvN > 0.5) return dvAt(i); float x = float(i) / 127.0; return 60.0 + 7.0 * sin(x * 9.0 + u_t * 2.0) + 3.0 * sin(x * 23.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float m0 = 69.0 + 12.0 * log2(max(p_altSini, 20.0) / 440.0), m1 = 69.0 + 12.0 * log2(max(p_ustSini, p_altSini + 10.0) / 440.0);
  float m = mix(m1, m0, b.y); float semi = abs(fract(m + 0.5) - 0.5); float isC = step(abs(mod(floor(m + 0.5), 12.0)), 0.5); vec4 res = overPre(vec4(vec3(1.0), 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.w * (m1 - m0), semi)) * mix(0.08, 0.3, isC), s);
  float f = clamp(b.x, 0.0, 1.0) * 127.0; int i = int(floor(f)); float a = M(i), c = M(min(i + 1, 127)); float val = (a > 0.0 && c > 0.0) ? mix(a, c, fract(f)) : 0.0;
  if (val > 0.0) { float y = (m1 - val) / (m1 - m0); float d = abs(b.y - y) * u_box.w; res = overPre(vec4(1.0, 0.7, 0.25, 1.0) * (1.0 - smoothstep(1.2, 2.5, d)), res); }
  if (p_notaEtik > 0.5) { float cur = M(127); vec2 lp = (b - vec2(0.12, 0.08)) / vec2(0.035, 0.05); res = overPre(vec4(1.0) * numAt(lp, cur), res); } o = res; }
