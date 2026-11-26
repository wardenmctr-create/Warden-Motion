// colortune
uniform float p_kirmizi, p_yesil, p_mavi, p_parlakliKoru, p_duzenMod, p_golgeYon, p_golgeGuc, p_golgeParlak, p_ortaYon, p_ortaGuc, p_ortaParlak, p_acikYon, p_acikGuc, p_acikParlak,
  p_genelYon, p_genelGuc, p_genelParlak, p_parlakKoruG, p_tasmaSinir;
vec3 wheel(float yon, float guc) { return (hsv2rgb(vec3(fract(yon / 360.0), 1.0, 1.0)) - 0.5) * guc / 100.0 * 0.6; } // merkez nötr
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l0 = luma(c);
  c *= 1.0 + vec3(p_kirmizi, p_yesil, p_mavi) / 100.0;
  if (p_parlakliKoru > 0.5) c *= l0 / max(luma(c), 1e-3);
  if (p_duzenMod > 0.5) {
    float l = luma(c); float wS = 1.0 - smoothstep(0.0, 0.5, l), wH = smoothstep(0.5, 1.0, l), wM = 1.0 - wS - wH;
    c += wheel(p_golgeYon, p_golgeGuc) * wS + wheel(p_ortaYon, p_ortaGuc) * wM + wheel(p_acikYon, p_acikGuc) * wH + wheel(p_genelYon, p_genelGuc);
    c += (p_golgeParlak * wS + p_ortaParlak * wM + p_acikParlak * wH + p_genelParlak) / 100.0 * 0.5;
    if (p_parlakKoruG > 0.5) c *= l0 / max(luma(c), 1e-3);
    if (p_tasmaSinir > 0.5) { float m = max(c.r, max(c.g, c.b)); if (m > 1.0) c = mix(vec3(luma(c)), c, 1.0 / m); }
  }
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
