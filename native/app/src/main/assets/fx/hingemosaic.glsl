// hingemosaic
uniform sampler2D s_hedef; uniform float p_hedefOn, p_satir, p_sutun, p_gecikme, p_ilerleme;
// Pano ızgarası: her pano menteşesi (sol kenarı) çevresinde 180° döner; köşegen sırayla gecikmeli; ön yüz katman, arka yüz hedef
void main() { vec2 b = boxUV(here()); vec2 N = vec2(max(floor(p_sutun), 1.0), max(floor(p_satir), 1.0)); vec2 id = floor(b * N); vec2 f = fract(b * N); float order = (id.x + id.y) / (N.x + N.y - 1.0);
  float d = p_gecikme / 100.0; float k = clamp((p_ilerleme / 100.0 * (1.0 + d) - order * d) / 1.0, 0.0, 1.0); float a = k * 3.14159; float w = cos(a); vec4 res = vec4(0.0);
  if (w >= 0.0) { if (f.x <= w) { vec2 uv = (id + vec2(f.x / max(w, 1e-3), f.y)) / N; res = texPx(boxPx(uv)) * (0.75 + 0.25 * w); } }
  else { float ww = -w; if (f.x <= ww) { vec2 uv = (id + vec2(f.x / max(ww, 1e-3), f.y)) / N; res = (p_hedefOn > 0.5 ? texture(s_hedef, uv) : vec4(0.2, 0.55, 1.0, 1.0)) * (0.75 + 0.25 * ww); } }
  o = res; }
