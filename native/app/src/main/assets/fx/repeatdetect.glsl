// repeatdetect
INCLUDE(_chart)
uniform sampler2D s_motifOrne; uniform float p_motifOrneOn, p_benzerli, p_azamiEsle, p_olcekDegiIzin;
// Motif: kaynak katman (yoksa kutunun sol üst çeyreği) 6×6 tanımlayıcı; her ızgara hücresinde karşılaştırılır, benzer hücreler kutuyla işaretlenir
vec3 mot(vec2 u) { if (p_motifOrneOn > 0.5) return unpre(texture(s_motifOrne, u)); return unpre(texPx(boxPx(vec2(0.04, 0.04) + u * 0.22))); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float cell = 0.22; vec2 g = floor(b / cell); vec2 f = fract(b / cell);
  float best = 0.0; for (int sc = 0; sc < 2; sc++) { if (sc == 1 && p_olcekDegiIzin < 0.5) break; float k = sc == 0 ? 1.0 : 0.75; float err = 0.0;
    for (int j = 0; j < 6; j++) for (int i = 0; i < 6; i++) { vec2 u = (vec2(i, j) + 0.5) / 6.0; vec3 a = mot(u); vec3 c = unpre(texPx(boxPx((g + 0.5 - k * 0.5 + u * k) * cell))); err += length(a - c); }
    best = max(best, 1.0 - err / 36.0 / 0.6); }
  float idx = g.y * floor(1.0 / cell + 1.0) + g.x; bool hit = best * 100.0 >= p_benzerli && idx < p_azamiEsle;
  if (!hit || any(greaterThan(g * cell, vec2(1.0)))) { o = s; return; }
  float edge = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)) * cell * min(u_box.z, u_box.w); float line = 1.0 - smoothstep(1.0, 2.0, edge);
  vec2 lp = (f - vec2(0.2, 0.15)) / vec2(0.12, 0.09); float num = (lp.x > -0.6 && lp.x < 2.6 && abs(lp.y) < 1.0) ? numAt(lp - vec2(1.0, 0.0), best * 100.0) : 0.0;
  o = overPre(vec4(1.0, 0.8, 0.2, 1.0) * max(line, num), s); }
