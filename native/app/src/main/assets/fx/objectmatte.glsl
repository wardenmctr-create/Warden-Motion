// objectmatte
uniform sampler2D s_nesne; uniform float p_nesneOn, p_kimlikTuru;
void main() { vec4 s = texture(u_tex, v_uv); if (p_nesneOn < 0.5) { o = vec4(vec3(s.a), 1.0) * 1.0; return; } vec4 n = texture(s_nesne, clamp(boxUV(here()), 0.0, 1.0)); float m = p_kimlikTuru < 0.5 ? n.a : step(0.05, length(unpre(n) - unpre(s))) * n.a; o = vec4(vec3(m), 1.0); }
