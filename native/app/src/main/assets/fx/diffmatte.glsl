// diffmatte
INCLUDE(_hist)
uniform sampler2D s_temizKareKatm; uniform float p_temizKareKatmOn, p_referansZama, p_tolerans, p_yumusakl, p_onBula, p_ters, p_matiGost;
vec4 refAt(vec2 uv) { return p_temizKareKatmOn > 0.5 ? texture(s_temizKareKatm, uv) : hist(0.0, uv); }
void main() { vec4 s = texture(u_tex, v_uv); if (p_temizKareKatmOn < 0.5 && histN() < 1.0) { o = s; return; }
  vec2 px = max(p_onBula, 0.0) * u_s / u_res; vec3 a = vec3(0.0), r = vec3(0.0);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 uv = v_uv + vec2(i, j) * px; a += unpre(texture(u_tex, uv)); r += unpre(refAt(uv)); }
  float d = length(a / 9.0 - r / 9.0) / 1.732; float tol = p_tolerans / 100.0; float m = smoothstep(tol, tol + max(p_yumusakl / 100.0, 1e-3), d);
  if (p_ters > 0.5) m = 1.0 - m;
  o = p_matiGost > 0.5 ? vec4(vec3(m) * s.a, s.a) : s * m; }
