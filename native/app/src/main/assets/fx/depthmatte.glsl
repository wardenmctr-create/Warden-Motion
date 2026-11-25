// depthmatte
uniform sampler2D u_depth; uniform float p_depth; uniform float p_soft; uniform float p_inv;
void main() { vec4 s = texture(u_tex, v_uv); float z = texture(u_depth, v_uv).r * 100.0; float k = 1.0 - smoothstep(p_depth - p_soft * 0.5, p_depth + p_soft * 0.5 + 0.01, z); if (p_inv > 0.5) k = 1.0 - k; o = s * k; }
