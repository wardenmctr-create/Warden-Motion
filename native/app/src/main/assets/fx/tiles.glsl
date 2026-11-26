// tiles
uniform float p_karoBoyu, p_karoAcis, p_aralik, p_kirpma, p_siraKayd, p_ayna, p_dikeyKayd, p_bicim, p_izgaraAci, p_alanT, p_yAyna, p_dAyna, p_disPiksel, p_dikisGizle, p_dikisYumu; uniform vec2 p_ofset, p_karoOran;
void main() {
  vec2 B = boxU(); vec2 q = rot2(-p_izgaraAci) * toUnit(here()) + p_ofset / 100.0 * B; vec2 p = q + 0.5 * B;
  vec2 cell = vec2(max(p_karoBoyu, 2.0)); cell.y *= B.y / B.x; cell *= max(p_karoOran, vec2(1.0)) / 100.0; if (p_bicim > 0.5 && p_bicim < 1.5) cell.y *= 0.6;
  float sk = p_siraKayd / 100.0; if (p_bicim > 1.5 && p_bicim < 2.5 && abs(sk) < 1e-3) sk = 0.5;
  if (p_bicim > 2.5) { vec2 r = rot2(45.0) * p; p = r; }
  if (p_dikeyKayd > 0.5) { float col = floor(p.x / cell.x); p.y += col * cell.y * sk; } else { float row = floor(p.y / cell.y); p.x += row * cell.x * sk; }
  vec2 id = floor(p / cell); vec2 f = fract(p / cell);
  if (p_alanT < 0.5) { vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = vec4(0.0); return; } }
  if (p_kirpma > 0.0 && p_alanT > 1.5) { vec2 lim = ceil(B / cell * 0.5 * (1.0 + 2.0 * p_kirpma)); vec2 cid = id - floor(B / cell * 0.5); if (abs(cid.x) > lim.x || abs(cid.y) > lim.y) { o = vec4(0.0); return; } }
  if (p_ayna > 0.5 || p_yAyna > 0.5) { if (mod(id.x, 2.0) > 0.5) f.x = 1.0 - f.x; } if (p_ayna > 0.5 || p_dAyna > 0.5) { if (mod(id.y, 2.0) > 0.5) f.y = 1.0 - f.y; }
  vec2 g = p_aralik / cell; vec2 f2 = (f - g * 0.5) / max(vec2(0.01), 1.0 - g);
  if (any(lessThan(f2, vec2(0.0))) || any(greaterThan(f2, vec2(1.0)))) { o = vec4(0.0); return; }
  // karo içeriği kendi açısıyla döner (ızgara açısından bağımsız)
  f2 = rot2(-p_karoAcis) * (f2 - 0.5) + 0.5; if (p_disPiksel < 0.5) f2 = clamp(f2, 0.0, 1.0);
  vec4 c = texEdge(boxPx(f2), p_disPiksel > 0.5 ? 0.0 : 3.0);
  if (p_dikisGizle > 0.5 && p_dikisYumu > 0.0) { float e = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)) * min(cell.x, cell.y); c = mix(texPx(boxPx(clamp(f2 + 0.5 * sign(0.5 - f2) * 0.0, 0.0, 1.0))), c, smoothstep(0.0, p_dikisYumu, e)); }
  o = c;
}
