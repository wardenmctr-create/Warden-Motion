// cutcolormatch
uniform sampler2D s_komsuKlip; uniform float p_komsuKlipOn, p_analiz, p_gecis, p_guc;
// Kesimden (katman başı) sonra geçiş süresi içinde, katmanın renk ortalaması/sapması komşu klibe doğru taşınır ve geri bırakılır
void main() { vec4 s = texture(u_tex, v_uv); if (p_komsuKlipOn < 0.5 || s.a <= 0.0) { o = s; return; } vec3 ma = vec3(0.0), mb = vec3(0.0), va = vec3(0.0), vb = vec3(0.0);
  for (int j = 0; j < 6; j++) for (int i = 0; i < 6; i++) { vec2 uv = (vec2(i, j) + 0.5) / 6.0; vec3 a = unpre(texPx(boxPx(uv))), c = unpre(texture(s_komsuKlip, uv)); ma += a; mb += c; va += a * a; vb += c * c; }
  ma /= 36.0; mb /= 36.0; vec3 sa = sqrt(max(va / 36.0 - ma * ma, 1e-5)), sb = sqrt(max(vb / 36.0 - mb * mb, 1e-5)); float k = (1.0 - smoothstep(0.0, max(p_gecis, 0.01), u_t)) * p_guc / 100.0;
  vec3 c = unpre(s); vec3 m = (c - ma) / sa * sb + mb; o = pre(clamp(mix(c, m, k), 0.0, 1.0), s.a); }
