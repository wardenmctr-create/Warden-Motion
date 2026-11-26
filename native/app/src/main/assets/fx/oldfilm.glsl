// oldfilm
uniform float p_gren, p_cizikSayi, p_toz, p_kareTitr, p_solma, p_titresim, p_tohum; uniform vec3 c_renkTonu;
void main() {
  float fr = floor(u_t * 24.0); float sd = seedf(p_tohum); vec2 jit = (hash2(vec2(fr, sd)) - 0.5) * p_kareTitr * u_s;
  vec4 s = texPx(here() + jit); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); vec2 b = boxUV(here());
  float l = luma(c); c = mix(c, c_renkTonu * (l * 1.3), 0.7); c = mix(c, vec3(0.92, 0.88, 0.78), p_solma / 100.0 * 0.4);
  c += (hash1(floor(here() / max(u_s, 1.0)) + fr) - 0.5) * p_gren / 100.0 * 0.5;
  for (int i = 0; i < 12; i++) { if (float(i) >= p_cizikSayi) break; float x = hash1(vec2(float(i), floor(fr / 3.0) + sd)); c *= 1.0 - 0.5 * (1.0 - smoothstep(0.0, 0.0025, abs(b.x - x - sin(b.y * 5.0 + float(i)) * 0.004))); }
  float dust = step(1.0 - p_toz / 100.0 * 0.01, hash1(floor(here() / max(u_s * 2.0, 1.0)) + fr * 3.1)); c *= 1.0 - dust * 0.8;
  c *= 1.0 - p_titresim / 100.0 * 0.3 * hash1(vec2(fr, 7.0)); vec2 v = b - 0.5; c *= 1.0 - smoothstep(0.35, 0.75, length(v)) * 0.45;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
