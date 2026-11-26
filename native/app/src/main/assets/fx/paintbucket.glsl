// paintbucket
uniform vec2 p_dolguNokt; uniform float p_tolerans, p_kenarYumu, p_bitisikAlan, p_alfayiKoru; uniform vec3 c_dolguReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec4 ref = texU(p_dolguNokt); vec3 c = unpre(s), rc = unpre(ref);
  float d = distance(c, rc) + abs(s.a - ref.a); float tol = p_tolerans / 100.0 * 0.8; float m = 1.0 - smoothstep(tol, tol + 0.02 + p_kenarYumu * 0.01, d);
  if (p_bitisikAlan > 0.5) { // yaklaşık bitişiklik: noktadan buraya giden yol boyunca benzer renk
    vec2 A = fromUnit(p_dolguNokt); for (int i = 1; i < 12; i++) { float t = float(i) / 12.0; vec4 x = texPx(mix(A, here(), t)); if (distance(unpre(x), rc) + abs(x.a - ref.a) > tol + 0.05) { m = 0.0; break; } } }
  float a = p_alfayiKoru > 0.5 ? s.a : max(s.a, m);
  o = pre(mix(c, c_dolguReng, m), a);
}
