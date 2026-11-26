// gridrepeat
uniform float p_sutun, p_satir, p_aralikX, p_aralikY, p_kopyaOlce, p_kopyaAcis, p_satirKaym, p_aynala; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); vec2 sp = vec2(max(p_aralikX, 1.0), max(p_aralikY, 1.0)); vec4 res = vec4(0.0); float sc = max(p_kopyaOlce / 100.0, 0.01);
  vec2 rel = q - p_merkez; vec2 g0 = floor(rel / sp + (n - 1.0) * 0.5 + 0.5);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = g0 + vec2(float(i), float(j)); if (any(lessThan(id, vec2(0.0))) || any(greaterThanEqual(id, n))) continue;
    vec2 c = p_merkez + (id - (n - 1.0) * 0.5) * sp + vec2(mod(id.y, 2.0) * p_satirKaym, 0.0); vec2 l = rot2(-p_kopyaAcis) * (q - c) / sc;
    if (p_aynala > 0.5 && mod(id.x + id.y, 2.0) > 0.5) l.x = -l.x; res = overPre(res, texU(l)); }
  o = res;
}
