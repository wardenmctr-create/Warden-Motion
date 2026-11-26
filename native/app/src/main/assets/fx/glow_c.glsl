// glow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk, c_icRenk, c_disRenk; uniform float p_yogunluk, p_karistir, p_yalnizParl, p_icBuyu, p_disBuyu, p_icGuc, p_disGuc, p_kaynakRenk;
float haloA(float r) { if (r < 0.5) return 0.0; float a = 0.0; for (int i = 0; i < 12; i++) { float an = float(i) * TAU / 12.0; a += texPx(here() + vec2(cos(an), sin(an)) * r).a * 0.7 + texPx(here() + vec2(cos(an), sin(an)) * r * 0.5).a * 0.3; } return a / 12.0; }
void main() {
  vec4 s = texture(u_src, v_uv); vec4 bl = texture(u_aux, v_uv);
  vec3 col = p_kaynakRenk > 0.5 && bl.a > 0.0 ? bl.rgb / bl.a : c_renk;
  float g = clamp(bl.a * p_yogunluk / 100.0 * 1.8, 0.0, 1.0); vec4 gc = vec4(col, 1.0) * g;
  // iki katmanlı hale (iç ve dış)
  float ih = p_icBuyu > 0.0 ? haloA(p_icBuyu * u_s) * p_icGuc / 100.0 : 0.0; float dh = p_disBuyu > 0.0 ? haloA(p_disBuyu * u_s) * p_disGuc / 100.0 : 0.0;
  gc = overPre(vec4(c_icRenk, 1.0) * clamp(ih, 0.0, 1.0), overPre(gc, vec4(c_disRenk, 1.0) * clamp(dh, 0.0, 1.0)));
  float ga = gc.a;
  if (p_yalnizParl > 0.5) { o = gc * (1.0 - s.a); return; }
  if (p_karistir < 0.5) o = vec4(s.rgb + gc.rgb * (1.0 - s.rgb) * (1.0 - s.a * 0.7), max(s.a, ga));
  else if (p_karistir < 1.5) o = vec4(min(s.rgb + gc.rgb * (1.0 - s.a * 0.6), vec3(1.0)), max(s.a, ga));
  else o = overPre(s, gc);
}
