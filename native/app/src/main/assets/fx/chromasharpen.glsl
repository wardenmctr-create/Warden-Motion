// chromasharpen
uniform float p_yaricap, p_guc, p_esik;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float R = max(p_yaricap, 0.3) * u_s; vec3 acc = vec3(0.0); for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; acc += unpre(texPx(here() + vec2(cos(a), sin(a)) * R)); } acc /= 8.0;
  vec3 d = (c - luma(c)) - (acc - luma(acc)); float m = smoothstep(p_esik / 100.0 * 0.2, p_esik / 100.0 * 0.2 + 0.02, length(d)); o = pre(clamp(c + d * p_guc / 100.0 * m, 0.0, 1.0), s.a); }
