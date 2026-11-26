// blur_v
uniform sampler2D u_src; uniform sampler2D s_maske; uniform float p_maskeOn;
uniform float p_yaricap, p_boyutlar, p_kenarPiksTekr, p_alfayiBula, p_eksenBagla, p_alan, p_maskeTers, p_koyuKenarOnle; uniform vec2 p_xyYari;
float ry() { return (p_xyYari.x > 0.0 || p_xyYari.y > 0.0) ? (p_eksenBagla > 0.5 ? p_xyYari.x : p_xyYari.y) : p_yaricap; }
void main() {
  float sg = (p_boyutlar > 0.5 && p_boyutlar < 1.5) ? 0.0 : ry() * u_s * 0.5; vec4 c = gauss1(here(), vec2(0.0, 1.0), sg, p_kenarPiksTekr > 0.5 ? 3.0 : 0.0);
  vec4 src = texture(u_src, v_uv);
  if (p_alfayiBula < 0.5) c = pre(c.a > 0.0 ? c.rgb / c.a : vec3(0.0), src.a);
  if (p_koyuKenarOnle > 0.5 && c.a > 0.0) c.rgb = min(c.rgb, vec3(c.a));
  float m = 1.0;
  if (p_alan > 0.5 && p_alan < 1.5) m = src.a; else if (p_alan > 1.5 && p_alan < 2.5) m = p_maskeOn > 0.5 ? texture(s_maske, clamp(boxUV(here()), 0.0, 1.0)).a : 1.0; else if (p_alan > 2.5) m = luma(unpre(src));
  if (p_maskeTers > 0.5) m = 1.0 - m;
  o = mix(src, c, m);
}
