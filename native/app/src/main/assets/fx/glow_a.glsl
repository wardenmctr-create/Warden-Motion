// glow_a
uniform float p_yayilim;
void main() { float a = dilateA(here(), 0.0); vec4 s = texture(u_tex, v_uv); o = vec4(min(1.0, s.a * (1.0 + p_yayilim / 100.0 * 3.0))); }
