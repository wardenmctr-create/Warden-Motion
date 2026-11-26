// stabilize
uniform float p_sabitlemGucu, p_kenarYone, p_enFazlYaki, p_takipNoktGost, p_dvN; uniform float p_dv[8];
void main() { vec2 q = toUnit(here()); vec2 sh = p_dvN >= 2.0 ? vec2(p_dv[0], p_dv[1]) : vec2(0.0); float z = p_kenarYone < 0.5 ? min(1.0 + length(sh) / max(min(boxU().x, boxU().y), 1.0) * 2.2, p_enFazlYaki / 100.0) : 1.0;
  vec2 src = (q / z) + sh; vec2 b = boxUV(fromUnit(src)); vec4 c = texU(src); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) c = p_kenarYone > 1.5 ? texEdge(fromUnit(src), 3.0) : vec4(0.0);
  if (p_takipNoktGost > 0.5 && u_export < 0.5) c = overPre(vec4(0.2, 1.0, 0.4, 1.0) * (1.0 - smoothstep(3.0, 4.0, length(q + sh * 0.0 - sh))), c); o = c; }
