// pixelate
uniform float p_pikselGeni, p_pikselYuks, p_karePiks, p_orneklem; uniform vec2 p_izgaraKonu;
void main() {
  vec2 cs = vec2(max(p_pikselGeni, 0.5), max(p_karePiks > 0.5 ? p_pikselGeni : p_pikselYuks, 0.5)) * u_s;
  vec2 org = u_box.xy + p_izgaraKonu / 100.0 * u_box.zw;
  vec2 id = floor((here() - org) / cs); vec2 c0 = org + id * cs;
  if (p_orneklem > 0.5) { o = texPx(c0 + cs * 0.5); return; }
  vec4 acc = vec4(0.0);
  for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) acc += texPx(c0 + cs * (vec2(float(i), float(j)) + 0.5) / 4.0);
  o = acc / 16.0;
}
