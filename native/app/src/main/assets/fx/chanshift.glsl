// chanshift
uniform float p_kirmiziKayn, p_yesilKayn, p_maviKayn, p_alfaKayn;
float src(vec4 s, vec3 c, float k, int base) {
  // her seçim listesinin ilk öğesi kanalın kendisi; diğerleri sıradaki
  int i = int(k + 0.5); int ord[7];
  if (base == 0) ord = int[7](0, 1, 2, 3, 4, 5, 6); else if (base == 1) ord = int[7](1, 0, 2, 3, 4, 5, 6); else if (base == 2) ord = int[7](2, 0, 1, 3, 4, 5, 6); else ord = int[7](3, 0, 1, 2, 4, 5, 6);
  int w = ord[clamp(i, 0, 6)];
  return w == 0 ? c.r : w == 1 ? c.g : w == 2 ? c.b : w == 3 ? s.a : w == 4 ? luma(c) : w == 5 ? 0.0 : 1.0;
}
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s);
  o = pre(vec3(src(s, c, p_kirmiziKayn, 0), src(s, c, p_yesilKayn, 1), src(s, c, p_maviKayn, 2)), src(s, c, p_alfaKayn, 3));
}
