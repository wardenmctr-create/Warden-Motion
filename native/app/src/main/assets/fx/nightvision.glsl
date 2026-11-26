// nightvision
uniform vec3 c_yesilTonu; uniform float p_kazanc, p_gren, p_tarama, p_vinyet, p_otomatikPozl;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); if (p_otomatikPozl > 0.5) { vec3 mn, mx, av; stats(mn, mx, av); l = l / max(luma(av) * 2.0, 0.1); }
  l = 1.0 - exp(-l * p_kazanc * 1.6);
  l += (hash1(floor(here()) + floor(u_t * 24.0) * 3.1) - 0.5) * p_gren / 100.0 * 0.6;
  l *= 1.0 - p_tarama / 100.0 * 0.5 * step(0.5, fract(here().y / 3.0));
  vec2 b = boxUV(here()) - 0.5; l *= 1.0 - p_vinyet / 100.0 * smoothstep(0.2, 0.75, length(b));
  o = pre(clamp(c_yesilTonu * l * 1.2, 0.0, 1.0), s.a);
}
