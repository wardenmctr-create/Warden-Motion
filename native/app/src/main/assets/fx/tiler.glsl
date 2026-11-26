// tiler
uniform float p_karoOlce, p_aci, p_ayna, p_bosluk, p_yalnizKatmAlan; uniform vec2 p_ofset;
void main() {
  vec2 B = boxU(); vec2 q = rot2(-p_aci) * (toUnit(here())) + p_ofset / 100.0 * B;
  if (p_yalnizKatmAlan > 0.5) { vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = vec4(0.0); return; } }
  vec2 cell = B * max(p_karoOlce / 100.0, 0.02); vec2 p = q + cell * 0.5;
  vec2 id = floor(p / cell); vec2 f = fract(p / cell);
  if (p_ayna > 0.5) { if (mod(id.x, 2.0) > 0.5) f.x = 1.0 - f.x; if (mod(id.y, 2.0) > 0.5) f.y = 1.0 - f.y; }
  vec2 g = p_bosluk / cell; vec2 f2 = (f - g * 0.5) / max(vec2(0.01), 1.0 - g);
  if (any(lessThan(f2, vec2(0.0))) || any(greaterThan(f2, vec2(1.0)))) { o = vec4(0.0); return; }
  o = texPx(boxPx(f2));
}
