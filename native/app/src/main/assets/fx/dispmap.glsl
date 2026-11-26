// dispmap
uniform sampler2D s_haritaKatm, s_hedefKatm, s_bgsrc; uniform float p_haritaKatmOn, p_hedefKatmOn, p_bgsrcOn;
uniform float p_yatayKana, p_dikeyKana, p_yatayMikt, p_dikeyMikt, p_haritayiTersCevi, p_kenarModu, p_etkiAlan, p_haritaGorunur, p_merkezden, p_notr, p_birim, p_haritaYumu, p_haritaKontrast, p_hedefUyar, p_yerlesim;
float ch(vec4 c, float k) { vec3 u = unpre(c); return k < 0.5 ? u.r : k < 1.5 ? u.g : k < 2.5 ? u.b : k < 3.5 ? c.a : luma(u); }
vec2 mapUV(vec2 b) { if (p_yerlesim > 1.5 && p_yerlesim < 2.5) return fract(b * 2.0); if (p_yerlesim > 2.5) return (b - 0.5) * 1.5 + 0.5; return b; }
vec4 mapAt(vec2 b) { if (p_haritaKatmOn < 0.5) return texPx(boxPx(b)); vec4 a = texture(s_haritaKatm, clamp(mapUV(b), 0.0, 1.0));
  if (p_haritaYumu > 0.0) { float r = p_haritaYumu / max(boxU().x, 1.0); for (int i = 0; i < 6; i++) { float an = float(i) * TAU / 6.0; a += texture(s_haritaKatm, clamp(mapUV(b + vec2(cos(an), sin(an)) * r), 0.0, 1.0)); } a /= 7.0; } return a; }
vec4 target(vec2 px) { vec2 b = boxUV(px); if (p_etkiAlan > 0.5 && p_etkiAlan < 1.5 && p_bgsrcOn > 0.5) return texture(s_bgsrc, clamp(b, 0.0, 1.0));
  if (p_etkiAlan > 1.5 && p_hedefKatmOn > 0.5) return texture(s_hedefKatm, clamp(b, 0.0, 1.0)); return texEdge(px, p_kenarModu < 0.5 ? 0.0 : p_kenarModu < 1.5 ? 1.0 : p_kenarModu < 2.5 ? 2.0 : 3.0); }
void main() {
  vec2 b = boxUV(here()); vec4 m = mapAt(clamp(b, 0.0, 1.0)); float kx = p_yatayKana; float ky = p_dikeyKana < 0.5 ? 1.0 : p_dikeyKana < 1.5 ? 0.0 : p_dikeyKana;
  vec2 v = vec2(ch(m, kx), ch(m, ky)); if (p_haritayiTersCevi > 0.5) v = 1.0 - v;
  float nt = p_merkezden > 0.5 ? 0.5 : p_notr / 100.0; vec2 dv = (v - nt) * p_haritaKontrast / 100.0;
  vec2 B = boxU(); vec2 d = p_birim > 0.5 ? dv * 2.0 * vec2(p_yatayMikt, p_dikeyMikt) : dv * 2.0 * vec2(p_yatayMikt, p_dikeyMikt) / 100.0 * min(B.x, B.y) * 0.25;
  if (p_haritaKatmOn < 0.5 && m.a < 0.01) d = vec2(0.0);
  vec4 r = target(fromUnit(toUnit(here()) - d));
  if (p_etkiAlan > 0.5) { vec4 own = texture(u_tex, v_uv); r = p_haritaGorunur > 0.5 ? overPre(own, r * step(0.001, own.a + 1.0)) : r * own.a; }
  o = r;
}
