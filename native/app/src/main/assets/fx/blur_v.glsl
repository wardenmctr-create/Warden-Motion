// blur_v
uniform sampler2D u_src; uniform float p_yaricap, p_boyutlar, p_kenarPiksTekr, p_alfayiBula;
void main() { float sg = (p_boyutlar > 0.5 && p_boyutlar < 1.5) ? 0.0 : p_yaricap * u_s * 0.5; vec4 c = gauss1(here(), vec2(0.0, 1.0), sg, p_kenarPiksTekr > 0.5 ? 3.0 : 0.0);
  if (p_alfayiBula < 0.5) { float a = texture(u_src, v_uv).a; c = pre(c.a > 0.0 ? c.rgb / c.a : vec3(0.0), a); } o = c; }
