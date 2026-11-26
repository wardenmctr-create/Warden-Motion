// solidmatte
uniform sampler2D s_ozelGorsel; uniform float p_ozelGorselOn;
uniform vec3 c_matReng, c_renk2, c_renklendirRenk; uniform float p_opaklik, p_yalnizSaydAlan, p_mevcutAlfaKoru, p_dolguMod, p_bgBulanik, p_bgDoyg, p_bgParlak, p_bgGama, p_bgRenklendir, p_onYumu, p_onOpak, p_onOlcek, p_bgOlcek, p_taramaGuc, p_taramaSayi;
uniform vec2 p_onKay, p_bgKay;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float inBox = step(0.0, b.x) * step(b.x, 1.0) * step(0.0, b.y) * step(b.y, 1.0);
  if (p_dolguMod < 1.5) { vec3 bc = p_dolguMod < 0.5 ? c_matReng : mix(c_matReng, c_renk2, clamp(b.y, 0.0, 1.0)); vec4 m = vec4(bc, 1.0) * p_opaklik / 100.0 * inBox;
    vec4 r = p_yalnizSaydAlan > 0.5 ? overPre(s, m) : mix(s, m, p_opaklik / 100.0); if (p_mevcutAlfaKoru > 0.5) r = pre(unpre(r), s.a); o = r; return; }
  // Arka plan doldurma: katmanın bulanık kopyası (ya da özel görsel) kutuyu doldurur, ön plan üstte
  vec2 cb = (b - 0.5 - p_bgKay / boxU()) / max(p_bgOlcek / 100.0, 0.01) + 0.5;
  vec4 bg;
  if (p_dolguMod > 2.5 && p_ozelGorselOn > 0.5) bg = texture(s_ozelGorsel, clamp(cb, 0.0, 1.0));
  else { // içerik kutusunun dolu kısmından örnek: kenarlara uzatılmış, büyütülmüş ve bulanık
    vec2 cc = (cb - 0.5) * 0.7 + 0.5; float R = p_bgBulanik / max(boxU().x, 1.0); vec4 acc = vec4(0.0); float ws = 0.0;
    for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 f = vec2(float(i), float(j)) / 3.0; float w = exp(-dot(f, f) * 2.0); acc += texPx(boxPx(clamp(cc + f * R, 0.0, 1.0))) * w; ws += w; } bg = acc / ws; }
  vec3 bc = bg.a > 0.0 ? bg.rgb / bg.a : c_matReng; bc = satAdj(bc, 1.0 + p_bgDoyg / 100.0); bc += p_bgParlak / 100.0 * 0.5; bc = pow(clamp(bc, 0.0, 1.0), vec3(1.0 / max(p_bgGama, 0.01)));
  bc = mix(bc, c_renklendirRenk * luma(bc) * 1.5, p_bgRenklendir / 100.0); bc *= 1.0 - p_taramaGuc / 100.0 * 0.5 * step(0.5, fract(b.y * p_taramaSayi * 0.5));
  vec2 fb = (b - 0.5 - p_onKay / boxU()) / max(p_onOlcek / 100.0, 0.01) + 0.5; vec4 fg = texPx(boxPx(fb)) * step(0.0, fb.x) * step(fb.x, 1.0) * step(0.0, fb.y) * step(fb.y, 1.0);
  if (p_onYumu > 0.0) { float e = min(min(fb.x, 1.0 - fb.x), min(fb.y, 1.0 - fb.y)) * boxU().x; fg *= smoothstep(0.0, p_onYumu, e); }
  o = overPre(fg * p_onOpak / 100.0, vec4(clamp(bc, 0.0, 1.0), 1.0) * inBox * p_opaklik / 100.0);
}
