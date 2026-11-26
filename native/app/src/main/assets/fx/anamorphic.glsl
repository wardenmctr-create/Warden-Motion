// anamorphic
uniform float p_sikistirOran, p_bokehOval, p_isikIzi;
void main() { vec2 q = toUnit(here()); q.x /= max(p_sikistirOran / 2.0 + 0.5, 0.5); vec4 c = texU(q); vec3 streak = vec3(0.0);
  for (int i = -12; i <= 12; i++) { vec4 n = texU(q + vec2(float(i) * boxU().x * 0.02 * p_isikIzi / 30.0, 0.0)); float l = luma(unpre(n)); streak += vec3(0.3, 0.6, 1.0) * smoothstep(0.75, 1.0, l) * n.a * exp(-abs(float(i)) * 0.15); }
  vec4 bo = vec4(0.0); for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; vec2 o2 = vec2(cos(a) / max(p_bokehOval, 0.25), sin(a)) * 3.0; vec4 n = texU(q + o2); bo += n * smoothstep(0.8, 1.0, luma(unpre(n))); }
  c.rgb += (streak * p_isikIzi / 100.0 * 0.3 + bo.rgb / 12.0 * 0.4) * c.a; o = vec4(clamp(c.rgb, 0.0, c.a + 0.0001), c.a); }
