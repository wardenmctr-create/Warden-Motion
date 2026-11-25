// zoomblur
uniform float p_amount; uniform vec2 p_center;
void main() { vec2 c = fromUnit(p_center); vec2 px = v_uv * u_res - c; vec4 acc = vec4(0.0);
  for (int i = 0; i < 40; i++) { float k = 1.0 - p_amount / 100.0 * 0.5 * float(i) / 39.0; acc += texPx(c + px * k); } o = acc / 40.0; }
