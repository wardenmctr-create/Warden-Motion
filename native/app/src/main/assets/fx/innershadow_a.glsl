// innershadow_a
uniform float p_dist; uniform float p_ang;
void main() { vec2 d = vec2(cos(radians(p_ang)), sin(radians(p_ang))) * p_dist * u_s; o = vec4(1.0 - tex(v_uv - d / u_res).a); }
