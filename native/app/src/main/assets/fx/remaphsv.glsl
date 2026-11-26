// remaphsv
uniform float p_tonKayn, p_doygunluKayn, p_degerKayn, p_sabitTon, p_sabitDoyg, p_sabitDege, p_alfaKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec3 h = rgb2hsv(unpre(s));
  float H = p_tonKayn < 0.5 ? h.x : p_tonKayn < 1.5 ? h.y : p_tonKayn < 2.5 ? h.z : fract(p_sabitTon / 360.0);
  float S = p_doygunluKayn < 0.5 ? h.y : p_doygunluKayn < 1.5 ? h.x : p_doygunluKayn < 2.5 ? h.z : p_sabitDoyg / 100.0;
  float V = p_degerKayn < 0.5 ? h.z : p_degerKayn < 1.5 ? h.x : p_degerKayn < 2.5 ? h.y : p_sabitDege / 100.0;
  o = pre(hsv2rgb(vec3(H, S, V)), p_alfaKoru > 0.5 ? s.a : 1.0); }
