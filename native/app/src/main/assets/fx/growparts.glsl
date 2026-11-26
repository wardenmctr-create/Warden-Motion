// growparts
uniform float p_parcalam, p_satir, p_sutun, p_ilerleme, p_baslangiOlce, p_parcaGeci, p_sira, p_tohum;
void main() {
  vec2 b = boxUV(here()); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); if (p_parcalam < 1.5) n = vec2(max(1.0, floor(p_sutun * 2.0)), 1.0);
  vec2 id = floor(b * n); vec2 c = (id + 0.5) / n; float ord = p_sira < 0.5 ? id.x / n.x : p_sira < 1.5 ? 1.0 - id.x / n.x : p_sira < 2.5 ? abs(id.x / max(n.x - 1.0, 1.0) - 0.5) * 2.0 : hash1(id + seedf(p_tohum));
  float g = p_parcaGeci / 100.0; float pp = clamp((p_ilerleme / 100.0 - ord * g) / max(1.0 - g, 0.05), 0.0, 1.0); pp = 1.0 - pow(1.0 - pp, 3.0);
  float sc = mix(p_baslangiOlce / 100.0, 1.0, pp); vec2 sb = c + (b - c) / max(sc, 0.001); if (any(greaterThan(abs(sb - c), 0.5 / n))) { o = vec4(0.0); return; } o = texPx(boxPx(sb)) * smoothstep(0.0, 0.2, pp);
}
