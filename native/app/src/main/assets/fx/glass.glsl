// glass
uniform sampler2D s_dokuKatm; uniform float p_dokuKatmOn; uniform float p_kirilma, p_camDoku, p_dokuOlce, p_bulanikl, p_parlakli;
void main() {
  vec2 q = toUnit(here()); vec2 n;
  if (p_dokuKatmOn > 0.5 || p_camDoku > 1.5) { vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec2 e = 2.0 / u_box.zw; n = vec2(luma(unpre(texture(s_dokuKatm, b + vec2(e.x, 0.0)))) - luma(unpre(texture(s_dokuKatm, b - vec2(e.x, 0.0)))), luma(unpre(texture(s_dokuKatm, b + vec2(0.0, e.y)))) - luma(unpre(texture(s_dokuKatm, b - vec2(0.0, e.y))))) * 4.0; }
  else if (p_camDoku < 0.5) { vec2 p = q / max(p_dokuOlce, 1.0) * 6.0; n = vec2(hash1(floor(p * 3.0)) - 0.5, hash1(floor(p * 3.0) + 9.0) - 0.5) * 0.6 + vec2(pnoise(p), pnoise(p + 5.0)) * 0.6; }
  else { vec2 p = q / max(p_dokuOlce, 1.0); n = vec2(sin(p.y * TAU + sin(p.x * 3.0)), cos(p.x * TAU * 0.7)) * 0.6; }
  vec2 d = n * p_kirilma; vec4 acc = vec4(0.0); float R = p_bulanikl;
  for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; acc += texU(q + d + vec2(cos(a), sin(a)) * R * 0.6); }
  vec4 c = mix(texU(q + d), acc / 8.0, step(0.5, R));
  c.rgb += p_parlakli / 100.0 * 0.4 * max(n.x + n.y, 0.0) * c.a;
  o = c;
}
