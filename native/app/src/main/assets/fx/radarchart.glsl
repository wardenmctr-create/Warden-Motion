// radarchart
INCLUDE(_chart)
uniform float p_eksen; uniform vec3 c_seriReng;
void main() { vec2 q = (boxUV(here()) - 0.5) * 2.0; q.y = -q.y; float N = clamp(floor(p_eksen), 3.0, 24.0); float a = atan(q.y, q.x); float r = length(q); float M = dMax();
  float sec = TAU / N; float k = (a + PI * 0.5) / sec; float i0 = floor(mod(k, N)); float f = fract(k); vec4 col = vec4(0.04, 0.06, 0.12, 0.85) * step(r, 1.0);
  for (int g = 1; g <= 4; g++) col = overPre(vec4(0.4, 0.45, 0.55, 1.0) * (1.0 - smoothstep(0.0, 0.01, abs(r - float(g) * 0.22))), col);
  col = overPre(vec4(0.4, 0.45, 0.55, 1.0) * (1.0 - smoothstep(0.0, 0.012, abs(f - 0.0) * r * sec)) * step(r, 0.88), col);
  for (int s = 0; s < 4; s++) { if (float(s) >= dR()) break; float v0 = dat(float(s), mod(i0, dC())) / M * 0.88, v1 = dat(float(s), mod(i0 + 1.0, dC())) / M * 0.88; float rr = mix(v0, v1, f);
    vec3 c = s == 0 ? c_seriReng : serCol(float(s), c_seriReng); col = overPre(vec4(c, 1.0) * (step(r, rr) * 0.3 + (1.0 - smoothstep(0.0, 0.015, abs(r - rr)))), col); }
  o = col; }
