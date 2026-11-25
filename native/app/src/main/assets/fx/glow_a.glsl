// glow_a
uniform vec3 c_col;
void main() { float a = texture(u_tex, v_uv).a; o = vec4(c_col, 1.0) * a; }
