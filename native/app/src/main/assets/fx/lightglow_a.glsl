// lightglow_a
uniform float p_esik;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = s.a > 0.0 ? s.rgb / s.a : vec3(0.0); float k = smoothstep(p_esik / 100.0 - 0.05, p_esik / 100.0 + 0.15, luma(c)); o = vec4(c * k, k) * s.a; }
