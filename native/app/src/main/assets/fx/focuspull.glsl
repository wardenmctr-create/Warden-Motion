// focuspull
uniform float p_azamiBoke, p_odakMerk, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; float k = 1.0 - abs(p - p_odakMerk / 100.0) / max(p_odakMerk / 100.0, 1.0 - p_odakMerk / 100.0); float r = p_azamiBoke * (1.0 - k) * u_s * step(0.001, p); vec4 acc = vec4(0.0);
  for (int i = 0; i < 24; i++) { float a = float(i) * 2.39996; float rr = r * sqrt((float(i) + 0.5) / 24.0); acc += texPx(here() + vec2(cos(a), sin(a)) * rr); } o = acc / 24.0 * (1.0 - smoothstep(0.6, 1.0, p)); }
