// ascii
uniform float p_hucreBoyu, p_kaynakRenkKull, p_ters; uniform vec3 c_yaziReng, c_arkaPlanReng;
float glyphA(vec2 f, float lev) { // 0..1 yoğunluğa göre basit karakter desenleri (. : - = + * # % @)
  vec2 g = floor(f * vec2(5.0, 7.0)); float x = g.x, y = g.y; float on = 0.0; int l = int(lev * 8.99);
  if (l == 0) on = 0.0; else if (l == 1) on = float(x == 2.0 && y == 5.0); else if (l == 2) on = float(x == 2.0 && (y == 2.0 || y == 5.0));
  else if (l == 3) on = float(y == 3.0 && x > 0.0 && x < 4.0); else if (l == 4) on = float((y == 2.0 || y == 4.0) && x > 0.0 && x < 4.0);
  else if (l == 5) on = float((x == 2.0 && y > 0.0 && y < 6.0) || (y == 3.0 && x > 0.0 && x < 4.0)); else if (l == 6) on = float(abs(x - 2.0) == abs(y - 3.0) || x == 2.0 || y == 3.0) * float(y > 0.0 && y < 6.0);
  else if (l == 7) on = float((x == 1.0 || x == 3.0) || (y == 2.0 || y == 4.0)) * float(y > 0.0 && y < 6.0); else on = float(y > 0.0 && y < 6.0 && x < 5.0) * float(!(x == 2.0 && y == 3.0));
  return on; }
void main() {
  vec4 s = texture(u_tex, v_uv); float cs = max(p_hucreBoyu * u_s, 3.0); vec2 id = floor((here() - u_box.xy) / cs); vec2 f = fract((here() - u_box.xy) / cs);
  vec4 x = texPx(u_box.xy + (id + 0.5) * cs); if (s.a <= 0.0 && x.a <= 0.0) { o = vec4(0.0); return; }
  float l = luma(unpre(x)); if (p_ters > 0.5) l = 1.0 - l; float on = glyphA(f, l);
  vec3 col = p_kaynakRenkKull > 0.5 ? unpre(x) : c_yaziReng; o = pre(mix(c_arkaPlanReng, col, on), max(s.a, x.a));
}
