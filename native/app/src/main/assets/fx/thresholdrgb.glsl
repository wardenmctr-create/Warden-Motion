// thresholdrgb
uniform float p_r; uniform float p_g; uniform float p_b;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); c = step(vec3(p_r, p_g, p_b) / 255.0, c); o = pre(c, s.a); }
