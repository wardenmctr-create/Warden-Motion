// hologram
uniform vec3 c_hologramReng; uniform float p_taramaAral, p_cizgiOpak, p_bozulma, p_akisHizi, p_titreme, p_saydamla;
void main() {
  vec2 px = here(); float y = px.y / u_s; float jit = (hash1(vec2(floor(y / 3.0), floor(u_t * 12.0))) - 0.5) * p_bozulma * step(0.85, hash1(vec2(floor(u_t * 6.0), floor(y / 20.0))));
  vec4 s = texPx(px + vec2(jit * u_s, 0.0)); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); vec3 c = c_hologramReng * (0.35 + l * 1.1);
  float scan = step(0.5, fract((y - u_t * p_akisHizi * 20.0) / max(p_taramaAral, 0.5))); c *= 1.0 - scan * p_cizgiOpak / 100.0;
  c += c_hologramReng * 0.6 * clamp(length(alphaGrad(px, 1.5)) * 4.0, 0.0, 1.0);
  float fl = 1.0 - p_titreme / 100.0 * hash1(vec2(floor(u_t * 20.0), 3.0));
  o = pre(clamp(c, 0.0, 1.0), s.a * (1.0 - p_saydamla / 100.0) * fl);
}
