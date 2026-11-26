// wetsurface
uniform sampler2D s_yansimaKatm, s_bgsrc; uniform float p_yansimaKatmOn, p_bgsrcOn;
uniform float p_islaklik, p_yuzeyKara, p_yansimaGucu, p_puruzlul, p_suKali, p_yansimaBula, p_yansimaKayn, p_suBiri, p_birikintYogu, p_suAkis, p_akisHizi, p_alfaSiniKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 b = boxUV(here()); float w = p_islaklik / 100.0;
  float pud = p_suBiri > 0.5 ? smoothstep(0.55 - p_birikintYogu / 200.0, 0.6 - p_birikintYogu / 200.0, fbm(q * 0.008, 4.0)) : 0.0;
  vec2 rip = p_suAkis > 0.5 ? vec2(sin(q.y * 0.2 + u_t * p_akisHizi * 0.2), cos(q.x * 0.17 + u_t * p_akisHizi * 0.15)) * 0.004 : vec2(0.0);
  vec2 n = (vec2(fbm(q * 0.05, 3.0), fbm(q * 0.05 + 5.0, 3.0)) - 0.5) * p_puruzlul / 100.0 * 0.05 * (1.0 - pud) + rip;
  vec2 ru = vec2(b.x, 1.0 - b.y) + n; vec3 refl;
  if (p_yansimaKayn > 1.5 && p_yansimaKatmOn > 0.5) refl = unpre(texture(s_yansimaKatm, clamp(ru, 0.0, 1.0)));
  else if (p_yansimaKayn > 0.5 && p_bgsrcOn > 0.5) refl = unpre(texture(s_bgsrc, clamp(ru, 0.0, 1.0)));
  else { float l1 = exp(-pow((b.x - 0.3 + n.x * 4.0) * 12.0, 2.0)) + exp(-pow((b.x - 0.72 + n.x * 4.0) * 16.0, 2.0)) * 0.7; refl = vec3(1.0, 0.92, 0.8) * l1 * smoothstep(0.0, 0.8, b.y); }
  vec3 c = unpre(s); c *= 1.0 - w * p_yuzeyKara / 100.0; c = satAdj(c, 1.0 + w * 0.25);
  float rs = (p_yansimaGucu / 100.0) * w * (0.35 + 0.65 * pud) * (1.0 + p_suKali / 100.0); c = mix(c, c + refl * 0.8, clamp(rs, 0.0, 1.0));
  float a = p_alfaSiniKoru > 0.5 ? s.a : max(s.a, pud * rs); o = pre(clamp(c, 0.0, 1.0), a); }
