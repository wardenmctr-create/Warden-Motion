// cbsticker
uniform float p_icKont, p_disKont, p_golgeUzak, p_golge, p_kose, p_bosluklaDold; uniform vec3 c_icRenk, c_disRenk;
void main() { vec4 s = texture(u_tex, v_uv); float wi = p_icKont * u_s, wo = p_disKont * u_s; float a1 = dilateA(here(), wi); float a2 = dilateA(here(), wi + wo); if (p_kose > 0.5) { a1 = step(0.5, a1); a2 = step(0.5, a2); }
  float sh = dilateA(here() - vec2(0.0, p_golgeUzak * u_s), wi + wo) * p_golge / 100.0; vec4 c = vec4(0.0, 0.0, 0.0, 1.0) * sh; c = overPre(vec4(c_disRenk, 1.0) * a2, c); c = overPre(vec4(c_icRenk, 1.0) * a1, c);
  c = overPre(s, c); o = c; }
