// foldpanels
uniform float p_panel, p_katlanma, p_perspekt, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 b = boxUV(here()); float N = max(floor(p_panel), 2.0); float a = radians(p_katlanma) * p; float pw = cos(a) / N; float total = pw * N; float x = (b.x - 0.5) / max(total, 1e-3) * 1.0 + 0.5;
  if (x < 0.0 || x > 1.0 || total < 1e-3) { o = vec4(0.0); return; } float id = floor(x * N); float f = fract(x * N); bool odd = mod(id, 2.0) > 0.5; float shade = odd ? 1.0 - sin(a) * 0.5 : 1.0;
  float persp = 1.0 + (odd ? f : 1.0 - f) * sin(a) * p_perspekt / 200.0; float y = (b.y - 0.5) * persp + 0.5; if (y < 0.0 || y > 1.0) { o = vec4(0.0); return; } vec4 c = texPx(boxPx(vec2((id + f) / N, y))); c.rgb *= shade; o = c; }
