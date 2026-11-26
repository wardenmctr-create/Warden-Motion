// chromakey
uniform vec3 c_anahtarReng, c_anahtar2, c_anahtar3; uniform float p_tolerans, p_yumusakl, p_renkTasm, p_kenarDara, p_matiGost, p_ters, p_yontem, p_siyahAlfa, p_beyazAlfa, p_yariSaydam, p_kenarTemiz, p_ayrintiKoru, p_cokluAnahtar, p_anahtar3Acik, p_onizleme;
float dist1(vec3 c, vec3 k) {
  if (p_yontem > 0.5 && p_yontem < 1.5) return distance(c, k) * 0.6;
  if (p_yontem > 1.5) { vec3 a = rgb2hsv(c), b = rgb2hsv(k); return length(vec3(min(abs(a.x - b.x), 1.0 - abs(a.x - b.x)) * 2.0, (a.y - b.y) * 0.5, (a.z - b.z) * 0.25)) * 0.6; }
  vec2 cc = vec2(dot(c, vec3(-0.169, -0.331, 0.5)), dot(c, vec3(0.5, -0.419, -0.081))), kc = vec2(dot(k, vec3(-0.169, -0.331, 0.5)), dot(k, vec3(0.5, -0.419, -0.081))); return distance(cc, kc); }
float keyA(vec2 px) { vec4 s = texPx(px); vec3 c = unpre(s); float d = dist1(c, c_anahtarReng);
  if (p_cokluAnahtar > 0.5) { d = min(d, dist1(c, c_anahtar2)); if (p_anahtar3Acik > 0.5) d = min(d, dist1(c, c_anahtar3)); }
  float tol = p_tolerans / 100.0 * 0.4; float a = smoothstep(tol, tol + p_yumusakl / 100.0 * 0.3 + 0.005, d);
  a = clamp((a - p_siyahAlfa / 100.0) / max((p_beyazAlfa - p_siyahAlfa) / 100.0, 0.01), 0.0, 1.0); a = mix(step(0.5, a), a, p_yariSaydam / 100.0 * 2.0 > 1.0 ? 1.0 : p_yariSaydam / 50.0);
  if (p_ters > 0.5) a = 1.0 - a; return a * s.a; }
void main() {
  vec4 s = texture(u_tex, v_uv); float a = keyA(here());
  if (abs(p_kenarDara) > 0.1 || p_kenarTemiz > 0.0) { float r = max(abs(p_kenarDara), p_kenarTemiz * 0.05) * u_s; float m = a, mn = a; for (int i = 0; i < 8; i++) { float an = float(i) * TAU / 8.0; float x = keyA(here() + vec2(cos(an), sin(an)) * r); m = p_kenarDara < 0.0 ? min(m, x) : max(m, x); mn = min(mn, x); }
    a = abs(p_kenarDara) > 0.1 ? m : a; if (p_kenarTemiz > 0.0) a = mix(a, mn, p_kenarTemiz / 100.0 * (p_ayrintiKoru > 0.5 ? 0.5 : 1.0)); }
  if (p_matiGost > 0.5 || (p_onizleme > 0.5 && p_onizleme < 1.5)) { o = vec4(vec3(a), 1.0); return; }
  vec3 c = unpre(s); vec3 k = normalize(c_anahtarReng + 1e-3); float spill = max(0.0, dot(c, k) - dot(c, vec3(1.0) - k) * 0.5) * p_renkTasm / 100.0; c -= k * spill * 0.6; c += vec3(spill * 0.3);
  vec4 r = pre(clamp(c, 0.0, 1.0), a);
  if (p_onizleme > 1.5) r = overPre(r, p_onizleme < 2.5 ? vec4(0.0, 0.0, 0.0, 1.0) : vec4(1.0));
  o = r;
}
