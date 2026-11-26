// dla
uniform sampler2D s_anl; uniform float p_anlOn;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } float g = texture(s_anl, clamp(boxUV(here()), 0.0, 1.0)).r; o = overPre(vec4(hsv2rgb(vec3(0.55 + g * 0.3, 0.6, 1.0)), 1.0) * smoothstep(0.05, 0.3, g), s); }
