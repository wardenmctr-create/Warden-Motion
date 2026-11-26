// neonsign
uniform float p_tupKali, p_hale, p_yogunluk, p_titreme, p_titremeHizi, p_arkaPlanKara; uniform vec3 c_tupReng;
void main() {
  vec4 s = texture(u_tex, v_uv); float w = max(p_tupKali * u_s, 1.0);
  float ring = clamp(dilateA(here(), w * 0.5) - erodeA(here(), w * 0.5), 0.0, 1.0);
  float glow = clamp(dilateA(here(), w * 0.5 + p_hale * u_s) - erodeA(here(), w * 0.5 + p_hale * u_s), 0.0, 1.0) * 0.0;
  float g = 0.0; for (int i = 0; i < 12; i++) { float a = float(i) * TAU / 12.0; vec2 d = vec2(cos(a), sin(a)) * p_hale * u_s; g += clamp(dilateA(here() + d * 0.5, w * 0.5) - erodeA(here() + d * 0.5, w * 0.5), 0.0, 1.0); }
  g /= 12.0;
  float fl = 1.0 - p_titreme / 100.0 * step(0.75, hash1(vec2(floor(u_t * p_titremeHizi * 8.0), 1.0)));
  vec3 core = mix(c_tupReng, vec3(1.0), 0.55);
  vec3 bg = p_arkaPlanKara > 0.5 ? vec3(0.03, 0.03, 0.06) : unpre(s) * 0.4;
  vec3 c = mix(bg, core, ring) + c_tupReng * g * 1.6 * p_yogunluk / 100.0;
  o = pre(clamp(c * fl, 0.0, 1.0), max(s.a, clamp(ring + g, 0.0, 1.0)));
}
