// tiles
uniform float p_karoBoyu, p_karoAcis, p_aralik, p_kirpma, p_siraKayd, p_ayna, p_dikeyKayd; uniform vec2 p_ofset;
void main() {
  vec2 B = boxU(); vec2 q = toUnit(here()) + p_ofset / 100.0 * B;
  vec2 p = rot2(-p_karoAcis) * q + 0.5 * B;
  vec2 cell = vec2(max(p_karoBoyu, 2.0)); cell.y *= B.y / B.x;
  if (p_dikeyKayd > 0.5) { float col = floor(p.x / cell.x); p.y += col * cell.y * p_siraKayd / 100.0; }
  else { float row = floor(p.y / cell.y); p.x += row * cell.x * p_siraKayd / 100.0; }
  vec2 id = floor(p / cell); vec2 f = fract(p / cell);
  if (p_kirpma > 0.0) { vec2 lim = ceil(B / cell * 0.5 * (1.0 + 2.0 * p_kirpma)); vec2 cid = id - floor(B / cell * 0.5); if (abs(cid.x) > lim.x || abs(cid.y) > lim.y) { o = vec4(0.0); return; } }
  if (p_ayna > 0.5) { if (mod(id.x, 2.0) > 0.5) f.x = 1.0 - f.x; if (mod(id.y, 2.0) > 0.5) f.y = 1.0 - f.y; }
  vec2 g = p_aralik / cell; vec2 f2 = (f - g * 0.5) / max(vec2(0.01), 1.0 - g);
  if (any(lessThan(f2, vec2(0.0))) || any(greaterThan(f2, vec2(1.0)))) { o = vec4(0.0); return; }
  o = texPx(boxPx(f2));
}
