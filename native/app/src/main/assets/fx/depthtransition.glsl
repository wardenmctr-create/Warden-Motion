// depthtransition
uniform sampler2D s_hedefKlip, s_derinlik; uniform float p_hedefKlipOn, p_derinlikOn, p_ilerleme, p_katmanGeci, p_sirayiTersCevi;
// Derinlik (kaynak ya da parlaklık; parlak = yakın) sırasıyla açılış: önce yakın yüzeyler, sonra uzaklar hedef kliple değişir
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float d = p_derinlikOn > 0.5 ? luma(texture(s_derinlik, b).rgb) : luma(unpre(s)); float order = p_sirayiTersCevi > 0.5 ? d : 1.0 - d; float g = max(p_katmanGeci / 100.0, 0.01);
  float k = smoothstep(order - g, order + g, p_ilerleme / 100.0 * (1.0 + 2.0 * g) - g); vec4 t = p_hedefKlipOn > 0.5 ? texture(s_hedefKlip, b) : vec4(vec3(0.15, 0.4, 0.9) * (0.5 + 0.5 * b.y), 1.0); o = mix(s, t, k); }
