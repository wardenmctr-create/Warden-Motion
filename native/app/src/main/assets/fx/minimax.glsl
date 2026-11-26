// minimax
uniform float p_islem, p_yaricap, p_kanal, p_yon;
vec4 mm(vec2 px, float R, bool mx) { vec4 best = texPx(px); float bk = mx ? -1.0 : 2.0; vec2 ax = p_yon < 0.5 ? vec2(1.0) : p_yon < 1.5 ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 f = vec2(float(i), float(j)) / 3.0 * ax; if (length(f) > 1.0) continue; vec4 x = texPx(px + f * R); float k = p_kanal < 0.5 ? luma(unpre(x)) * x.a : p_kanal < 1.5 ? x.a : luma(unpre(x)); if ((mx && k > bk) || (!mx && k < bk)) { bk = k; best = x; } } return best; }
void main() { float R = max(p_yaricap * u_s, 0.7); vec4 r;
  if (p_islem < 0.5) r = mm(here(), R, false); else if (p_islem < 1.5) r = mm(here(), R, true); else if (p_islem < 2.5) r = mix(mm(here(), R, false), mm(here(), R * 0.6, true), 0.5); else r = mix(mm(here(), R, true), mm(here(), R * 0.6, false), 0.5);
  if (p_kanal > 0.5 && p_kanal < 1.5) { vec4 s = texture(u_tex, v_uv); r = pre(s.a > 0.0 ? unpre(s) : unpre(r), r.a); } o = r; }
