// gamutwarn
uniform float p_hedefProf, p_opaklik; uniform vec3 c_uyariReng;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float sat = length(c - luma(c)); float lim = p_hedefProf < 0.5 ? 0.985 : p_hedefProf < 1.5 ? 0.995 : p_hedefProf < 2.5 ? 0.985 : 0.999;
  float lo = 1.0 - lim; bool clip = (max(c.r, max(c.g, c.b)) >= lim || min(c.r, min(c.g, c.b)) <= lo) && sat > 0.25; float m = clip ? 1.0 : 0.0; m *= 0.6 + 0.4 * step(0.5, fract((here().x + here().y) / (6.0 * u_s)));
  o = overPre(vec4(c_uyariReng, 1.0) * m * p_opaklik / 100.0 * s.a, s); }
