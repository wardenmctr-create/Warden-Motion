// darkglow_a
uniform float p_esik;
void main() { vec4 s = texture(u_tex, v_uv); float l = s.a > 0.0 ? luma(s.rgb / s.a) : 1.0; float d = (1.0 - smoothstep(p_esik / 100.0 - 0.1, p_esik / 100.0 + 0.05, l)) * s.a; o = vec4(d); }
