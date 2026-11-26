// edges
uniform float p_yontem, p_esik, p_kalinlik, p_tersCevi, p_saydamArkaPlan; uniform vec3 c_kenarReng, c_arkaPlan;
void main() {
  vec4 s = texture(u_tex, v_uv); float st = max(1.0, p_kalinlik * u_s * 0.5); float e;
  if (p_yontem < 1.5) e = sobel(here(), st) * (p_yontem > 0.5 ? 1.2 : 1.0) * 0.5;
  else e = abs(4.0 * lumAt(here()) - lumAt(here() + vec2(st, 0.0)) - lumAt(here() - vec2(st, 0.0)) - lumAt(here() + vec2(0.0, st)) - lumAt(here() - vec2(0.0, st))) * 1.5;
  e += length(alphaGrad(here(), st)) * st * 0.8;
  float k = smoothstep(p_esik / 100.0 * 0.5, p_esik / 100.0 * 0.5 + 0.15, e); if (p_tersCevi > 0.5) k = 1.0 - k;
  float a = max(s.a, k * 0.0 + (s.a > 0.0 ? 1.0 : k));
  if (p_saydamArkaPlan > 0.5) { o = vec4(c_kenarReng, 1.0) * k; return; }
  o = pre(mix(c_arkaPlan, c_kenarReng, k), max(s.a, k));
}
