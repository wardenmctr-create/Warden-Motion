// glintstretch
uniform sampler2D s_yonHari; uniform float p_yonHariOn, p_uzunluk, p_parlakliEsig, p_karisim;
// Parlak noktalar yön alanı boyunca uzar: yön haritası (RG) ya da yerel doku yönü
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); vec2 dir; if (p_yonHariOn > 0.5) { vec2 r = texture(s_yonHari, boxUV(p)).rg * 2.0 - 1.0; dir = length(r) > 0.05 ? normalize(r) : vec2(1.0, 0.0); }
  else { vec2 g = lumGrad(p, 2.0); dir = length(g) > 1e-4 ? normalize(vec2(-g.y, g.x)) : vec2(1.0, 0.0); }
  float L = p_uzunluk * u_s; float th = p_parlakliEsig / 100.0; vec3 acc = vec3(0.0);
  for (int k = 1; k <= 24; k++) { float r = float(k) / 24.0 * L; float w = 1.0 - float(k) / 25.0; for (int sgn = -1; sgn <= 1; sgn += 2) { vec4 c = texPx(p + dir * r * float(sgn)); float l = luma(unpre(c)) * c.a; acc += unpre(c) * c.a * max(l - th, 0.0) / max(1.0 - th, 0.01) * w; } }
  vec3 st = acc / 10.0; o = vec4(s.rgb + st * p_karisim / 100.0, max(s.a, clamp(luma(st) * p_karisim / 100.0, 0.0, 1.0))); }
