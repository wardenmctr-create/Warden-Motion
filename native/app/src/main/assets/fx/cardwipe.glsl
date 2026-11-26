// cardwipe
uniform float p_ilerleme, p_satir, p_sutun, p_eksen, p_sira, p_perspekt, p_tohum; uniform vec3 c_arkaYuzReng;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); vec2 cs = B / n; vec2 id = floor((q + B * 0.5) / cs);
  if (any(lessThan(id, vec2(0.0))) || any(greaterThanEqual(id, n))) { o = vec4(0.0); return; } vec2 c = (id + 0.5) * cs - B * 0.5; vec2 g = id / max(n - 1.0, 1.0);
  float ord = p_sira < 0.5 ? g.x : p_sira < 1.5 ? 1.0 - g.x : p_sira < 2.5 ? g.y : p_sira < 3.5 ? 1.0 - g.y : hash1(id + seedf(p_tohum));
  float pp = clamp(p_ilerleme / 100.0 * 1.5 - ord * 0.5, 0.0, 1.0); float ang = pp * PI; float cf = cos(ang); vec2 rel = q - c;
  float persp = 1.0 + sin(ang) * p_perspekt / 100.0 * 0.3 * (p_eksen < 0.5 ? rel.x / cs.x : rel.y / cs.y);
  vec2 src = p_eksen < 0.5 ? vec2(rel.x, rel.y / max(abs(cf), 0.01)) : vec2(rel.x / max(abs(cf), 0.01), rel.y); src /= persp;
  if (abs(src.x) > cs.x * 0.5 || abs(src.y) > cs.y * 0.5) { o = vec4(0.0); return; } vec4 col = texU(c + src); if (cf < 0.0) col = vec4(c_arkaYuzReng, 1.0) * col.a; col.rgb *= 0.6 + 0.4 * abs(cf); o = col; }
