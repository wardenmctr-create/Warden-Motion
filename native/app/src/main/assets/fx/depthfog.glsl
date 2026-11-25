// depthfog
uniform sampler2D u_depth; uniform float p_start; uniform float p_end; uniform vec3 c_col; uniform float p_dens;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float z = texture(u_depth, v_uv).r * 100.0; float k = smoothstep(p_start, max(p_start + 0.1, p_end), z) * p_dens / 100.0; o = pre(mix(unpre(s), c_col, k), s.a); }
