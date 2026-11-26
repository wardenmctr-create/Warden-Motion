// spill
uniform vec3 c_perdeReng, c_duzeltmeReng; uniform float p_bastirma, p_yontem, p_parlakliKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); vec3 k = c_perdeReng; int ch = k.g >= k.r && k.g >= k.b ? 1 : (k.b >= k.r ? 2 : 0);
  float ex = p_yontem < 0.5 ? (ch == 1 ? c.g - max(c.r, c.b) : ch == 2 ? c.b - max(c.r, c.g) : c.r - max(c.g, c.b)) : max(0.0, 0.6 - distance(c, k));
  ex = max(ex, 0.0) * p_bastirma / 100.0; vec3 r = c; if (ch == 1) r.g -= ex; else if (ch == 2) r.b -= ex; else r.r -= ex; r += (c_duzeltmeReng - 0.5) * ex;
  if (p_parlakliKoru > 0.5) r *= luma(c) / max(luma(r), 1e-3); o = pre(clamp(r, 0.0, 1.0), s.a); }
