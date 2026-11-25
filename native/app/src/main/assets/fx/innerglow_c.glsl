// innerglow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_col; uniform float p_str;
void main() { vec4 s = texture(u_src, v_uv); float g = clamp(texture(u_aux, v_uv).a * p_str / 100.0 * 1.5, 0.0, 1.0); vec3 c = unpre(s); c = mix(c, c_col, g); o = pre(c, s.a); }
