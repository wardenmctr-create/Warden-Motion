// fresnelmatte
uniform float p_kirilmaIndi, p_guc, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float R = 40.0 * u_s; float d = innerDist(here(), R) / R; float cosT = clamp(d * 1.5, 0.0, 1.0); float r0 = pow((p_kirilmaIndi - 1.0) / (p_kirilmaIndi + 1.0), 2.0);
  float f = clamp((r0 + (1.0 - r0) * pow(1.0 - cosT, 5.0)) * p_guc / 100.0, 0.0, 1.0); if (p_ters > 0.5) f = 1.0 - f; o = vec4(vec3(f), 1.0) * s.a; }
