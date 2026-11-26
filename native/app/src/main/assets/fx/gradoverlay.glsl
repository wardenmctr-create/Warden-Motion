// gradoverlay
GRADIENT(renkDura)
uniform float p_gecisTuru, p_aci, p_olcek, p_tersCevi, p_karistir; uniform vec2 p_baslangi, p_bitis;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 q = toUnit(here()); vec2 A = p_baslangi, B = p_bitis; vec2 ab = rot2(p_aci) * (B - A); float L = max(length(ab), 1.0) * max(p_olcek / 100.0, 0.01);
  float x;
  if (p_gecisTuru < 0.5) x = dot(q - A, normalize(ab)) / L; else if (p_gecisTuru < 1.5) x = length(q - A) / L;
  else x = fract((atan(q.y - A.y, q.x - A.x) - atan(ab.y, ab.x)) / TAU);
  x = clamp(x, 0.0, 1.0); if (p_tersCevi > 0.5) x = 1.0 - x;
  o = pre(blendMode(unpre(s), grad_renkDura(x), p_karistir), s.a);
}
