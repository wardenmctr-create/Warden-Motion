// spinblur
uniform float p_amount; uniform vec2 p_center;
void main() { vec2 c = fromUnit(p_center); vec2 px = v_uv * u_res - c; vec4 acc = vec4(0.0);
  for (int i = 0; i < 40; i++) { float a = radians(p_amount) * (float(i) / 39.0 - 0.5); vec2 q = rot2(degrees(a)) * px; acc += texPx(c + q); } o = acc / 40.0; }
