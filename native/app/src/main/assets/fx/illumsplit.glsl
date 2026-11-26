// illumsplit
uniform float p_isikOlce, p_kenarKoru, p_cikti, p_guc;
// Çarpımsal model: görüntü = yansıtım × aydınlatma; aydınlatma = kenar duyarlı geniş ortalama parlaklık
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); float l0 = luma(c); float R = p_isikOlce * u_s; float acc = 0.0, w = 0.0; float ek = p_kenarKoru / 100.0;
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec4 q = texPx(here() + vec2(i, j) / 4.0 * R); if (q.a <= 0.0) continue; float l = luma(unpre(q)); float ww = exp(-dot(vec2(i, j), vec2(i, j)) / 16.0) * exp(-abs(l - l0) * ek * 8.0); acc += l * ww; w += ww; }
  float L = max(acc / max(w, 1e-4), 0.02); vec3 refl = clamp(c / L * 0.5, 0.0, 1.0); vec3 r = p_cikti < 0.5 ? refl : (p_cikti < 1.5 ? vec3(L) : clamp(refl * 2.0 * mix(L, 0.5, 0.6), 0.0, 1.0));
  o = pre(mix(c, r, p_guc / 100.0), s.a); }
