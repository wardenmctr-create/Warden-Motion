// invert
uniform float p_kanal, p_guc, p_alfayiDaTers;
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float a = s.a; vec3 n = c;
  if (p_kanal < 0.5) n = 1.0 - c; else if (p_kanal < 1.5) n.r = 1.0 - c.r; else if (p_kanal < 2.5) n.g = 1.0 - c.g; else if (p_kanal < 3.5) n.b = 1.0 - c.b;
  float k = p_guc / 100.0; vec3 r = mix(c, n, k);
  if (p_kanal > 3.5 || p_alfayiDaTers > 0.5) { a = mix(a, 1.0 - a, k); if (s.a < 0.001) r = vec3(1.0) - vec3(0.0); }
  o = pre(clamp(r, 0.0, 1.0), a);
}
