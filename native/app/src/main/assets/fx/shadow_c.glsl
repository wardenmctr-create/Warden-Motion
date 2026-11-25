// shadow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform float p_op;
void main() { vec4 s = texture(u_src, v_uv); vec4 g = texture(u_aux, v_uv) * p_op / 100.0; o = s + g * (1.0 - s.a); }
