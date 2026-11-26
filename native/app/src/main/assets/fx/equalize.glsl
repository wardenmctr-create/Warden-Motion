// equalize
uniform float p_yontem, p_guc, p_bolgeBoyu, p_kontrastSini;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c);
  // yaklaşık eşitleme: kaba histogramdan birikimli dağılım
  float below = 0.0, n = 0.0;
  for (int j = 0; j < 10; j++) for (int i = 0; i < 10; i++) {
    vec2 b = (vec2(float(i), float(j)) + 0.5) / 10.0;
    if (p_yontem > 1.5) b = boxUV(here()) + (b - 0.5) * p_bolgeBoyu * u_s / u_box.zw * 2.0;
    vec4 x = texPx(boxPx(b)); if (x.a < 0.1) continue; n += 1.0; below += step(luma(x.rgb / x.a), l); }
  float e = n > 0.0 ? below / n : l; e = mix(l, e, 1.0 / max(1.0, p_kontrastSini * 0.3));
  vec3 r = p_yontem > 0.5 && p_yontem < 1.5 ? c * (e / max(l, 1e-3)) : c * (e / max(l, 1e-3));
  o = pre(clamp(mix(c, r, p_guc / 100.0), 0.0, 1.0), s.a);
}
