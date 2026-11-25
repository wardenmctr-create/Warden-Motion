// shadow_a
uniform vec3 c_col; uniform float p_dist; uniform float p_ang;
void main() { vec2 d = vec2(cos(radians(p_ang)), sin(radians(p_ang))) * p_dist * u_s; float a = tex(v_uv - d / u_res).a; o = vec4(c_col, 1.0) * a; }
