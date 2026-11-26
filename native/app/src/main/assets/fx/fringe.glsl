// fringe
uniform vec3 c_eskiFonReng; uniform float p_guc, p_kenarGeni, p_alfaEsig, p_parlakliKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float edge = 1.0 - smoothstep(0.0, max(p_kenarGeni * u_s, 1.0), innerDist(here(), max(p_kenarGeni * u_s, 1.0) + 1.0)); float semi = 1.0 - step(p_alfaEsig / 100.0, s.a);
  float k = max(edge, semi) * p_guc / 100.0; vec3 c = unpre(s); vec3 fixed_ = (c - c_eskiFonReng * (1.0 - s.a)) / max(s.a, 0.05); fixed_ = mix(c, clamp(fixed_, 0.0, 1.0), 0.7);
  vec3 nb = unpre(texPx(here() - normalize(alphaGrad(here(), 2.0) + 1e-5) * p_kenarGeni * u_s * 1.5)); fixed_ = mix(fixed_, nb, 0.5 * edge);
  if (p_parlakliKoru > 0.5) fixed_ *= luma(c) / max(luma(fixed_), 1e-3); o = pre(mix(c, clamp(fixed_, 0.0, 1.0), k), s.a); }
