// chromakey
uniform vec3 c_anahtarReng; uniform float p_tolerans, p_yumusakl, p_renkTasm, p_kenarDara, p_matiGost, p_ters;
float keyA(vec2 px) { vec4 s = texPx(px); vec3 c = unpre(s); vec3 k = c_anahtarReng;
  vec2 cc = vec2(dot(c, vec3(-0.169, -0.331, 0.5)), dot(c, vec3(0.5, -0.419, -0.081))), kc = vec2(dot(k, vec3(-0.169, -0.331, 0.5)), dot(k, vec3(0.5, -0.419, -0.081)));
  float d = distance(cc, kc); float tol = p_tolerans / 100.0 * 0.4; float a = smoothstep(tol, tol + p_yumusakl / 100.0 * 0.3 + 0.005, d); if (p_ters > 0.5) a = 1.0 - a; return a * s.a; }
void main() {
  vec4 s = texture(u_tex, v_uv); float a = keyA(here());
  if (abs(p_kenarDara) > 0.1) { float r = abs(p_kenarDara) * u_s; float m = a; for (int i = 0; i < 8; i++) { float an = float(i) * TAU / 8.0; float x = keyA(here() + vec2(cos(an), sin(an)) * r); m = p_kenarDara < 0.0 ? min(m, x) : max(m, x); } a = m; }
  if (p_matiGost > 0.5) { o = vec4(vec3(a), 1.0) * step(0.001, s.a + 1.0); return; }
  vec3 c = unpre(s); vec3 k = normalize(c_anahtarReng + 1e-3);
  float spill = max(0.0, dot(c, k) - dot(c, vec3(1.0) - k) * 0.5) * p_renkTasm / 100.0; c -= k * spill * 0.6; c += vec3(spill * 0.3);
  o = pre(clamp(c, 0.0, 1.0), a);
}
