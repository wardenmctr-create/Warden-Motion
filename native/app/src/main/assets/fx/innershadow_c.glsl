// innershadow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_col; uniform float p_op;
void main() { vec4 s = texture(u_src, v_uv); float g = clamp(texture(u_aux, v_uv).a, 0.0, 1.0) * p_op / 100.0; o = pre(mix(unpre(s), c_col, g), s.a); }
