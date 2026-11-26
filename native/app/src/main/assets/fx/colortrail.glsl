// colortrail
INCLUDE(_hist)
uniform float p_ornek, p_zamanAral; uniform vec3 c_basSonRenk;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); vec4 acc = vec4(0.0);
  for (int i = 15; i >= 1; i--) { if (float(i) >= N) continue; vec4 h = hist(float(i), v_uv); float k = float(i) / max(N - 1.0, 1.0); vec3 tint = mix(vec3(1.0), c_basSonRenk, k); acc = overPre(vec4(tint, 1.0) * h.a * (1.0 - k * 0.6), acc); }
  o = overPre(s, acc); }
