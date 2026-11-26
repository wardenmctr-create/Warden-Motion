// roughmeter
uniform vec3 c_isaret; uniform float p_pencere, p_olcu, p_kontrast;
// Yapı tensörü: pürüz = gradyan enerjisi, yön tutarlılığı = (λ1−λ2)/(λ1+λ2)
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float R = max(p_pencere * u_s * 0.5, 1.0); float jxx = 0.0, jyy = 0.0, jxy = 0.0;
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 g = lumGrad(p + vec2(i, j) / 3.0 * R, 1.0); jxx += g.x * g.x; jyy += g.y * g.y; jxy += g.x * g.y; }
  jxx /= 49.0; jyy /= 49.0; jxy /= 49.0; float tr = jxx + jyy; float dt = sqrt(max((jxx - jyy) * (jxx - jyy) + 4.0 * jxy * jxy, 0.0)); float coh = tr > 1e-6 ? dt / tr : 0.0;
  float v = p_olcu < 0.5 ? sqrt(tr) * 6.0 : coh; v = clamp((v - 0.5) * (0.5 + p_kontrast / 50.0) + 0.5, 0.0, 1.0);
  vec3 c = mix(unpre(s) * 0.35, c_isaret, v); o = pre(c, max(s.a, 0.0)); }
