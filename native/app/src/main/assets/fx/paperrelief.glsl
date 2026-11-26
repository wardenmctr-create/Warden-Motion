// paperrelief
INCLUDE(_mat)
uniform sampler2D s_derinlikKayn; uniform float p_derinlikKaynOn;
uniform float p_seviyeKayn, p_katSayi, p_katArasYuks, p_kenarGeni, p_kenarDuze, p_malzeme, p_dokuGucu, p_kaynakRenkKull, p_golgeGucu, p_isikYonu, p_katAcil;
float lev(vec2 px) { vec4 c = texPx(px); float v = p_seviyeKayn < 0.5 ? luma(unpre(c)) : p_seviyeKayn < 1.5 ? rgb2hsv(unpre(c)).x : (p_derinlikKaynOn > 0.5 ? luma(unpre(texture(s_derinlikKayn, clamp(boxUV(px), 0.0, 1.0)))) : luma(unpre(c)));
  float n = max(p_katSayi, 2.0); vec2 w = vec2(pnoise(toUnit(px) * 0.05), pnoise(toUnit(px) * 0.05 + 4.0)) * p_kenarDuze / 100.0 * 0.1; return floor(clamp(v + w.x, 0.0, 0.999) * n) * step(0.01, c.a); }
void main() { vec4 s = texture(u_tex, v_uv); float l = lev(here()); vec2 ld = -vec2(cos(radians(p_isikYonu)), sin(radians(p_isikYonu))); float sh = 0.0; float hgt = p_katArasYuks * u_s;
  for (int k = 1; k <= 6; k++) { float lk = lev(here() + ld * hgt * float(k) * 0.5); sh = max(sh, clamp((lk - l) / 3.0, 0.0, 1.0) * (1.0 - float(k) / 7.0)); }
  float n = max(p_katSayi, 2.0); vec3 base = p_kaynakRenkKull > 0.5 ? unpre(s) : vec3(mix(0.55, 1.0, l / n)); int mid[6] = int[6](1, 2, 6, 3, 9, 10); int m = mid[int(clamp(p_malzeme, 0.0, 5.0))];
  vec3 paper = matSample(m, toUnit(here()), 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb / max(luma(matBase(m)), 0.1); vec3 c = mix(base, base * paper, p_dokuGucu / 100.0);
  float edge = step(0.5, abs(lev(here() + ld * p_kenarGeni * u_s) - l)); c *= 1.0 + edge * 0.15; c *= 1.0 - sh * p_golgeGucu / 100.0 * 0.8;
  float show = step(l / n, p_katAcil / 100.0 + 0.001); o = pre(clamp(c, 0.0, 1.0), s.a * show); }
