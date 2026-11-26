// frameoverflow
uniform sampler2D s_cerceve, s_nesneMask; uniform float p_cerceveOn, p_nesneMaskOn, p_tasma, p_disParcGolg;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = clamp(boxUV(here()), 0.0, 1.0); float fr = p_cerceveOn > 0.5 ? texture(s_cerceve, b).a : step(0.15, b.x) * step(b.x, 0.85) * step(0.2, b.y) * step(b.y, 0.85); float obj = p_nesneMaskOn > 0.5 ? texture(s_nesneMask, b).a : step(0.4, luma(unpre(s))) * s.a;
  float vis = max(fr, obj * p_tasma / 100.0); float sh = 0.0; if (p_nesneMaskOn > 0.5) { sh = texture(s_nesneMask, clamp(b - vec2(0.01, -0.015), 0.0, 1.0)).a * (1.0 - fr) * (1.0 - obj) * p_disParcGolg / 100.0; }
  vec4 frameBorder = vec4(1.0) * (fr - (p_cerceveOn > 0.5 ? texture(s_cerceve, clamp(b + vec2(0.006), 0.0, 1.0)).a * texture(s_cerceve, clamp(b - vec2(0.006), 0.0, 1.0)).a : step(0.155, b.x) * step(b.x, 0.845) * step(0.205, b.y) * step(b.y, 0.845)));
  o = overPre(s * vis, overPre(frameBorder * (1.0 - obj), vec4(0.0, 0.0, 0.0, 1.0) * sh)); }
