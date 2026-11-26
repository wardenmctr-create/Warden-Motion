// clouds
uniform float p_bulutOlce, p_ayrinti, p_kontrast, p_evrim, p_hiz, p_tohum; uniform vec2 p_ofset; uniform vec3 c_renk1, c_renk2;
void main() {
  vec2 p = (toUnit(here()) + p_ofset / 100.0 * boxU()) / max(p_bulutOlce, 1.0) + seedf(p_tohum) + vec2(u_t * p_hiz, 0.0);
  float n = fbm(p + vec2(0.0, p_evrim * 0.03), p_ayrinti - 1.0) * 0.5 + 0.5; n = clamp((n - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5, 0.0, 1.0);
  o = genOver(vec4(mix(c_renk1, c_renk2, smoothstep(0.25, 0.85, n)), 1.0));
}
