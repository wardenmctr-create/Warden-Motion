// poseblend
uniform sampler2D s_ikiPoz; uniform float p_ikiPozOn, p_karisim, p_simetri;
void main() { vec4 s = texture(u_tex, v_uv); if (p_ikiPozOn < 0.5) { o = s; return; } vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec4 c = texture(s_ikiPoz, b); if (p_simetri > 0.5) c = mix(c, texture(s_ikiPoz, vec2(1.0 - b.x, b.y)), 0.5 * step(0.5, b.x) * 0.0); o = mix(s, c, p_karisim / 100.0); }
