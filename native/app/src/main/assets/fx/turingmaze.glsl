// turingmaze
uniform sampler2D s_anl; uniform float p_anlOn, p_dalKali;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } float g = texture(s_anl, fract(boxUV(here()) * max(1.0, 3.0 / max(p_dalKali, 0.5)))).r; o = pre(mix(vec3(0.06, 0.08, 0.16), vec3(0.95, 0.9, 0.8), smoothstep(0.35, 0.6, g)), s.a); }
