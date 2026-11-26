// ambientocc
uniform sampler2D s_derinlikKatm; uniform float p_derinlikKatmOn;
uniform float p_kaynak, p_golgeYari, p_yogunluk, p_derinlikHass, p_yumusakl, p_kontrast, p_alfaSiniKoru, p_yalnizGolgGost, p_kalite; uniform vec3 c_golgeReng;
float hAt(vec2 px) { if (p_kaynak > 0.5 && p_derinlikKatmOn > 0.5) return luma(unpre(texture(s_derinlikKatm, clamp(boxUV(px), 0.0, 1.0)))); if (p_kaynak > 0.5) return luma(unpre(texPx(px))) * texPx(px).a; return texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); float R = max(p_golgeYari * u_s, 1.0); int N = p_kalite < 1.5 && p_kalite > 0.5 ? 8 : p_kalite < 2.5 ? 16 : 24; float h0 = hAt(here()); float occ = 0.0;
  for (int i = 0; i < 24; i++) { if (i >= N) break; float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / float(N)); float h = hAt(here() + vec2(cos(a), sin(a)) * r);
    occ += clamp((h - h0) * (1.0 + p_derinlikHass / 25.0), 0.0, 1.0) * (1.0 - r / R * (1.0 - p_yumusakl / 100.0) * 0.5); }
  occ = clamp(occ / float(N) * 2.0 * p_yogunluk / 100.0 * 2.0, 0.0, 1.0);
  if (p_kaynak < 0.5 && s.a > 0.0) { float id = innerDist(here(), R); occ = max(occ, (1.0 - smoothstep(0.0, R, id)) * p_yogunluk / 100.0 * (0.6 + p_derinlikHass / 125.0)); } // kenara yaklaştıkça hacim gölgesi occ = pow(occ, 1.0 / (1.0 + p_kontrast / 50.0));
  if (p_yalnizGolgGost > 0.5) { o = vec4(c_golgeReng, 1.0) * occ * (p_alfaSiniKoru > 0.5 ? s.a : 1.0); return; }
  vec4 c = s; c.rgb = mix(c.rgb, c_golgeReng * c.a, occ * s.a); if (p_alfaSiniKoru < 0.5) c = overPre(c, vec4(c_golgeReng, 1.0) * occ * (1.0 - s.a)); o = c; }
