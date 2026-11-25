// glow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform float p_str;
void main() { vec4 s = texture(u_src, v_uv); vec4 g = texture(u_aux, v_uv) * (p_str / 100.0) * 1.6; g = min(g, vec4(1.0)); o = s + g * (1.0 - s.a); o.rgb += g.rgb * s.a * 0.15; }
