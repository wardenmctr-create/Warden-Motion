// regionmerge
uniform sampler2D s_bolgeGeom; uniform float p_bolgeGeomOn, p_tolerans, p_icSiniSakl;
// Bölge haritasındaki iç sınır çizgileri (dolgunun içindeki ince koyu çizgiler) komşu dolgu rengiyle kapatılır; dış sınır korunur
vec4 G(vec2 px) { return p_bolgeGeomOn > 0.5 ? texture(s_bolgeGeom, boxUV(px)) : texPx(px); }
float line(vec4 c, vec4 ref) { return c.a > 0.5 && luma(unpre(c)) < luma(unpre(ref)) - 0.18 - p_tolerans * 0.02 ? 1.0 : 0.0; }
void main() { vec4 s = G(here()); if (s.a < 0.5) { o = s; return; } vec4 best = s; float bl = 9.0; vec4 avg = vec4(0.0); float n = 0.0; bool inside = true;
  for (int i = 0; i < 8; i++) { float a = float(i) / 8.0 * TAU; vec2 d = vec2(cos(a), sin(a)); for (int k = 1; k <= 6; k++) { vec4 c = G(here() + d * float(k) * u_s); if (c.a < 0.5) { inside = false; break; } float l = luma(unpre(c)); if (l > luma(unpre(s)) + 0.15) { avg += c; n += 1.0; break; } } }
  if (!inside || n < 2.0 || luma(unpre(s)) > 0.45) { o = s; return; } vec4 fill = avg / n; o = p_icSiniSakl > 0.5 ? mix(fill, s, 0.25 * step(0.5, fract((here().x + here().y) / (6.0 * u_s)))) : fill; }
