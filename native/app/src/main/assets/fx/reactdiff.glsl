// reactdiff
uniform sampler2D s_anl; uniform float p_anlOn, p_olcek; uniform vec3 c_birinciRenk, c_ikinciRenk;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } float g = texture(s_anl, fract(boxUV(here()) * max(p_olcek / 100.0, 0.1))).r; o = pre(mix(c_birinciRenk, c_ikinciRenk, smoothstep(0.2, 0.7, g)), s.a); }
