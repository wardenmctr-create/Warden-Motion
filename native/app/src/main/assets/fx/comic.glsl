// comic
uniform float p_renkSevi, p_kontur, p_noktaBoyu, p_tramYogu, p_noktalarGost; uniform vec3 c_kenarReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float n = max(2.0, p_renkSevi) - 1.0; vec3 h = rgb2hsv(c); h.z = floor(h.z * n + 0.5) / n; h.y = min(1.0, h.y * 1.2); c = hsv2rgb(h);
  if (p_noktalarGost > 0.5) { float sz = max(p_noktaBoyu * u_s, 2.0); vec2 p = rot2(-45.0) * here(); vec2 f = fract(p / sz) - 0.5; float r = sqrt(1.0 - luma(c)) * 0.5;
    float dt = 1.0 - smoothstep(r - 0.06, r + 0.06, length(f)); c *= 1.0 - dt * p_tramYogu / 100.0 * 0.6; }
  float e = smoothstep(0.15, 0.35, sobel(here(), max(1.0, p_kontur * u_s * 0.5)) * 0.5 + length(alphaGrad(here(), 1.5)) * 1.5);
  o = pre(mix(c, c_kenarReng, e), s.a);
}
