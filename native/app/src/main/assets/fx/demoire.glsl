// demoire
uniform sampler2D s_bolgeMask; uniform float p_bolgeMaskOn;
uniform float p_mod, p_desenAral, p_desenYonu, p_otomatikYonBul, p_guc, p_frekansGeni, p_ayrintiKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float r = max(p_desenAral, 1.0) * u_s * (1.0 + p_frekansGeni / 100.0) * 0.6; float ang = radians(p_desenYonu);
  if (p_otomatikYonBul > 0.5) { vec2 g = lumGrad(here(), r * 0.5); ang = atan(g.y, g.x); }
  vec2 d1 = vec2(cos(ang), sin(ang)), d2 = vec2(-d1.y, d1.x); vec3 acc = c0; float n = 1.0;
  for (int i = 1; i <= 4; i++) { float t = r * float(i) / 4.0; acc += unpre(texPx(here() + d1 * t)) + unpre(texPx(here() - d1 * t)) + (unpre(texPx(here() + d2 * t)) + unpre(texPx(here() - d2 * t))) * 0.5; n += 3.0; }
  vec3 lp = acc / n; vec3 r3;
  if (p_mod < 0.5) r3 = luma(c0) + (lp - luma(lp)); else if (p_mod < 1.5) r3 = c0 - luma(c0) + luma(lp); else r3 = lp;
  float edge = smoothstep(0.15, 0.4, sobel(here(), r)) * p_ayrintiKoru / 100.0; float w = p_guc / 100.0 * (1.0 - edge);
  if (p_bolgeMaskOn > 0.5) w *= texture(s_bolgeMask, clamp(boxUV(here()), 0.0, 1.0)).a; o = pre(clamp(mix(c0, r3, w), 0.0, 1.0), s.a); }
