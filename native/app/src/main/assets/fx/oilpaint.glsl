// oilpaint
uniform float p_fircaYari, p_darbeUzun, p_stilGucu, p_aydinlatAcis, p_kabartma, p_renkYumu;
void main() {
  vec4 s0 = texture(u_tex, v_uv); if (s0.a <= 0.0) { o = s0; return; }
  float R = max(p_fircaYari * u_s, 1.0); vec2 g = lumGrad(here(), R * 0.5); vec2 dir = length(g) > 1e-5 ? normalize(vec2(-g.y, g.x)) : vec2(1.0, 0.0);
  // Kuwahara benzeri: 4 çeyrekten en düşük varyanslı
  vec3 best = unpre(s0); float bv = 1e9;
  for (int k = 0; k < 4; k++) { vec2 o2 = vec2(k == 0 || k == 3 ? -1.0 : 1.0, k < 2 ? -1.0 : 1.0); vec3 m = vec3(0.0), m2 = vec3(0.0);
    for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) { vec2 d = (vec2(float(i), float(j)) / 2.0) * o2 * R; vec3 c = unpre(texPx(here() + d + dir * float(i - 1) * p_darbeUzun * u_s * 0.15)); m += c; m2 += c * c; }
    m /= 9.0; vec3 v = m2 / 9.0 - m * m; float vv = v.r + v.g + v.b; if (vv < bv) { bv = vv; best = m; } }
  vec3 c = mix(unpre(s0), best, p_stilGucu / 100.0);
  float a = radians(p_aydinlatAcis); float h = dot(lumGrad(here(), 1.5), vec2(cos(a), sin(a))) * 6.0;
  c *= 1.0 + h * p_kabartma / 100.0; c = mix(c, satAdj(c, 1.1), p_renkYumu / 100.0 * 0.5);
  o = pre(clamp(c, 0.0, 1.0), s0.a);
}
