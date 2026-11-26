// maze
uniform float p_satir, p_sutun, p_bicim, p_tohum, p_donguOran, p_duvarKali, p_cizimIler; uniform vec3 c_duvarReng;
// İkili ağaç labirenti: her hücre kuzey ya da doğu duvarını rastgele açar → tek parça, döngüsüz labirent (hücre başına yerel karar)
bool openN(vec2 id, vec2 n) { if (id.y >= n.y - 1.0) return false; if (id.x >= n.x - 1.0) return true; float h = hash1(id + seedf(p_tohum)); return h < 0.5 || hash1(id + 7.1) < p_donguOran / 100.0; }
bool openE(vec2 id, vec2 n) { if (id.x >= n.x - 1.0) return false; if (id.y >= n.y - 1.0) return true; float h = hash1(id + seedf(p_tohum)); return h >= 0.5 || hash1(id + 3.3) < p_donguOran / 100.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 n = vec2(max(floor(p_sutun), 2.0), max(floor(p_satir), 2.0)); vec2 b = boxUV(here()); vec2 g;
  if (p_bicim > 1.5) { vec2 q = toUnit(here()) / (min(boxU().x, boxU().y) * 0.5); float r = length(q); if (r > 1.0) { o = s; return; } g = vec2(fract(atan(q.y, q.x) / TAU + 0.5) * n.x, r * n.y); }
  else { g = vec2(b.x, 1.0 - b.y) * n; if (p_bicim > 0.5) g.x += mod(floor(g.y), 2.0) * 0.5; }
  vec2 id = floor(g); vec2 f = fract(g); if (any(lessThan(id, vec2(0.0))) || any(greaterThanEqual(id, n))) { o = s; return; }
  float w = max(p_duvarKali, 0.5) / (boxU().x / n.x) * 0.5; float wall = 0.0;
  if (!openN(id, n)) wall = max(wall, step(1.0 - w, f.y)); if (!openE(id, n)) wall = max(wall, step(1.0 - w, f.x));
  if (id.y < 0.5) wall = max(wall, step(f.y, w)); if (id.x < 0.5 && p_bicim < 1.5) wall = max(wall, step(f.x, w));
  if (!openN(id - vec2(0, 1), n) && id.y > 0.5) wall = max(wall, step(f.y, w)); if (!openE(id - vec2(1, 0), n) && id.x > 0.5) wall = max(wall, step(f.x, w));
  wall = max(wall, step(length(min(f, 1.0 - f)), w * 1.2));
  float reveal = step((id.y * n.x + id.x) / (n.x * n.y), p_cizimIler / 100.0 * 1.0001); o = overPre(vec4(c_duvarReng, 1.0) * wall * reveal, s); }
