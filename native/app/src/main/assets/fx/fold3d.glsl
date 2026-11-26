// fold3d
INCLUDE(_3d)
uniform vec2 p_katCizgBasl, p_katCizgSonu; uniform float p_katAcis, p_katYari, p_golge, p_arkaYuzuGost; uniform vec3 c_arkaYuzReng;
float sdf(vec3 p) { return 1e5; } vec4 surf(vec3 p, vec3 n) { return vec4(0.0); }
void main() {
  // Katlama: çizginin sağ tarafı çizgi etrafında katAcis kadar döner (ekrana doğru)
  vec2 q = toUnit(here()); vec2 A = p_katCizgBasl, Bp = p_katCizgSonu; vec2 d = normalize(Bp - A + 1e-5); vec2 n = vec2(-d.y, d.x);
  float s = dot(q - A, n); vec2 B = boxU();
  vec4 base = vec4(0.0);
  if (s <= 0.0) base = layerAt(q / B * vec2(1.0) + 0.5);
  // katlanan kanat: düzlemde iz düşüm kısalır (cos), ve arka yüz görünür (açı > 90)
  float a = radians(p_katAcis); float c = cos(a);
  if (s > 0.0 || c < 0.0) {
    float sp = s / max(abs(c), 0.02); vec2 src = q - n * s + n * sp * sign(c == 0.0 ? 1.0 : c);
    if (c < 0.0) src = q - n * s - n * s / max(abs(c), 0.02);
    vec2 bb = src / B + 0.5; bool ok = all(greaterThanEqual(bb, vec2(0.0))) && all(lessThanEqual(bb, vec2(1.0))) && dot(src - A, n) >= 0.0;
    if (ok) { vec4 f = layerAt(bb); vec3 col = f.a > 0.0 ? f.rgb / f.a : vec3(0.0);
      if (c < 0.0) col = p_arkaYuzuGost > 0.5 ? c_arkaYuzReng : col; col *= mix(1.0, 0.55 + 0.45 * abs(c), p_golge / 100.0);
      vec4 w = vec4(col * f.a, f.a); base = c < 0.0 ? overPre(w, base) : w; }
  }
  o = base;
}
