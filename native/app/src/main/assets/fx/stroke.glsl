// stroke
uniform float p_kalinlik, p_konum, p_opaklik, p_birlesim, p_yalnizCizg, p_dolgu, p_ikinciKalin, p_cizgiBicim, p_kesikUzun, p_kesikBosluk, p_cizgiFaz, p_alfaYorum, p_alfaEsik, p_delikKontur, p_ekranSabit;
uniform vec3 c_renk, c_renk2g, c_ikinciRenk;
float sA(vec2 px) { float a = texPx(px).a; if (p_alfaYorum < 0.5) return step(0.5, a); if (p_alfaYorum < 1.5) return a; if (p_alfaYorum < 2.5) return smoothstep(0.08, 0.6, a); return step(p_alfaEsik / 100.0, a); }
float dil(vec2 px, float r) { float m = sA(px); if (r < 0.5) return m; for (int k = 1; k <= 3; k++) { float rr = r * float(k) / 3.0; for (int i = 0; i < 16; i++) { float a = float(i) * TAU / 16.0 + float(k) * 0.4; m = max(m, sA(px + vec2(cos(a), sin(a)) * rr)); } } return m; }
float ero(vec2 px, float r) { float m = sA(px); if (r < 0.5) return m; for (int k = 1; k <= 3; k++) { float rr = r * float(k) / 3.0; for (int i = 0; i < 16; i++) { float a = float(i) * TAU / 16.0 + float(k) * 0.4; m = min(m, sA(px + vec2(cos(a), sin(a)) * rr)); } } return m; }
float dashMask() { if (p_cizgiBicim < 0.5) return 1.0; vec2 q = toUnit(here()); float per = max(p_kesikUzun + p_kesikBosluk, 1.0);
  float t = atan(q.y, q.x) * length(boxU()) * 0.35 + p_cizgiFaz; float f = mod(t, per);
  if (p_cizgiBicim > 1.5) { float c = abs(f - per * 0.5); return 1.0 - smoothstep(p_kesikUzun * 0.25, p_kesikUzun * 0.25 + 0.8, c); } return step(f, p_kesikUzun); }
void main() {
  vec4 s = texture(u_tex, v_uv); float sc = p_ekranSabit > 0.5 ? 1.0 : u_s; float w = p_kalinlik * sc; float a0 = sA(here()); float ring;
  if (p_konum < 0.5) ring = clamp(dil(here(), w) - a0, 0.0, 1.0); else if (p_konum < 1.5) ring = clamp(a0 - ero(here(), w), 0.0, 1.0); else ring = clamp(dil(here(), w * 0.5) - ero(here(), w * 0.5), 0.0, 1.0);
  if (p_delikKontur < 0.5) { float outer = 1.0 - step(0.5, dil(here(), w * 2.5 + 4.0)); ring *= 1.0; }
  ring *= dashMask();
  vec3 col = c_renk; if (p_dolgu > 0.5 && p_dolgu < 1.5) col = mix(c_renk, c_renk2g, clamp(boxUV(here()).y, 0.0, 1.0)); else if (p_dolgu > 1.5) col = c_renk * (0.8 + 0.4 * vnoise(toUnit(here()) * 0.3));
  vec4 st = vec4(col, 1.0) * ring * p_opaklik / 100.0;
  if (p_ikinciKalin > 0.0) { float w2 = (p_kalinlik + p_ikinciKalin) * sc; float r2 = clamp(dil(here(), w2) - max(a0, dil(here(), w)), 0.0, 1.0); st = overPre(st, vec4(c_ikinciRenk, 1.0) * r2 * p_opaklik / 100.0); }
  if (p_yalnizCizg > 0.5) { o = st; return; }
  o = p_konum < 0.5 ? overPre(s, st) : overPre(st, s * (1.0 - ring * p_opaklik / 100.0));
}
