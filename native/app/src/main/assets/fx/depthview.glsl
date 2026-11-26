// depthview
uniform float p_yakinUzakSini, p_tersCevi, p_dogrusal;
void main() { vec4 s = texture(u_tex, v_uv); float z = luma(unpre(s)); float k = max(p_yakinUzakSini, 0.01); float v = p_dogrusal < 0.5 ? clamp(z * 10.0 / k, 0.0, 1.0) : log(1.0 + z * k) / log(1.0 + k); if (p_tersCevi > 0.5) v = 1.0 - v; o = vec4(vec3(v), 1.0) * s.a; }
