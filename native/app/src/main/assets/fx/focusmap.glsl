// focusmap
uniform float p_pencere, p_esik; uniform vec3 c_odakReng;
void main() { vec4 s = texture(u_tex, v_uv); float R = max(p_pencere, 3.0) * 0.5 * u_s; float m = 0.0, m2 = 0.0;
  for (int i = 0; i < 16; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 16.0); vec2 p = here() + vec2(cos(a), sin(a)) * r; float lap = luma(unpre(texPx(p))) * 4.0 - luma(unpre(texPx(p + vec2(u_s, 0.0)))) - luma(unpre(texPx(p - vec2(u_s, 0.0)))) - luma(unpre(texPx(p + vec2(0.0, u_s)))) - luma(unpre(texPx(p - vec2(0.0, u_s)))); m += lap; m2 += lap * lap; }
  float v = sqrt(max(m2 / 16.0 - (m / 16.0) * (m / 16.0), 0.0)); float f = smoothstep(p_esik / 100.0 * 0.3, p_esik / 100.0 * 0.3 + 0.05, v); o = overPre(vec4(c_odakReng, 1.0) * f * 0.6 * s.a, s); }
