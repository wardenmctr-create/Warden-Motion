// feather
uniform float p_yaricap, p_icDisDeng, p_xEkse, p_yEkse, p_kenarBici, p_ters;
void main() {
  vec4 s = texture(u_tex, v_uv); float R = max(p_yaricap * u_s, 0.5); float acc = 0.0, ws = 0.0; vec2 ax = vec2(p_xEkse > 0.5 ? 1.0 : 0.0, p_yEkse > 0.5 ? 1.0 : 0.0);
  vec2 off = normalize(alphaGrad(here(), 2.0) + 1e-5) * R * p_icDisDeng / 100.0 * 0.5;
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec2 f = vec2(float(i), float(j)) / 4.0 * ax; float w = p_kenarBici < 0.5 ? exp(-dot(f, f) * 2.0) : max(0.0, 1.0 - length(f)); acc += texPx(here() - off + f * R).a * w; ws += w; }
  float a = acc / max(ws, 1e-4); if (p_ters > 0.5) a = s.a * (1.0 - a);
  vec3 c = s.a > 0.0 ? unpre(s) : unpre(texPx(here() - alphaGrad(here(), 2.0) * R)); o = pre(c, min(a, max(s.a, a)));
}
