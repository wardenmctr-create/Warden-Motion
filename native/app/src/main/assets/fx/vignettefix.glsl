// vignettefix
uniform vec2 p_optikMerk; uniform float p_guc, p_yaricap, p_renkDeng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()) - p_optikMerk / 100.0; b.x *= boxU().x / max(boxU().y, 1.0); float r = length(b) / max(p_yaricap / 100.0 * 0.75, 0.01); float k = 1.0 + p_guc / 100.0 * r * r;
  vec3 c = unpre(s) * k; c *= vec3(1.0 + p_renkDeng / 100.0 * 0.1 * r * r, 1.0, 1.0 - p_renkDeng / 100.0 * 0.1 * r * r); o = pre(clamp(c, 0.0, 1.0), s.a); }
