// gridwipe
uniform float p_ilerleme, p_satir, p_sutun, p_bicim, p_aci, p_sira, p_yumusatm, p_tohum;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); vec2 cs = B / n; vec2 id = floor((q + B * 0.5) / cs); vec2 c = (id + 0.5) * cs - B * 0.5; vec2 g = id / max(n - 1.0, 1.0);
  float ord = p_sira < 0.5 ? length(g - 0.5) * 1.4 : p_sira < 1.5 ? g.x : p_sira < 2.5 ? 1.0 - g.x : hash1(id + seedf(p_tohum)); float pp = clamp(p_ilerleme / 100.0 * 1.6 - ord * 0.6, 0.0, 1.0);
  float sc = p_bicim > 0.5 && p_bicim < 1.5 ? 1.0 : 1.0 - pp; float ang = p_bicim > 0.5 ? p_aci * pp : 0.0; vec2 src = rot2(-ang) * (q - c) / max(sc, 0.001);
  if (abs(src.x) > cs.x * 0.5 || abs(src.y) > cs.y * 0.5 || (p_bicim > 0.5 && p_bicim < 1.5 && pp > 0.999)) { o = vec4(0.0); return; } o = texU(c + src) * (p_bicim > 0.5 && p_bicim < 1.5 ? 1.0 - pp : 1.0); }
