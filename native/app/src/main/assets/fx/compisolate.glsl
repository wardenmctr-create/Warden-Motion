// compisolate
uniform sampler2D s_anl; uniform float p_anlOn;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } float m = texture(s_anl, v_uv).a; o = s * step(0.5, m); }
