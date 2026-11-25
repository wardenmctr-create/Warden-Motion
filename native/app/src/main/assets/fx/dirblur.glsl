// dirblur
uniform float p_amount; uniform float p_ang;
void main() { vec2 d = vec2(cos(radians(p_ang)), sin(radians(p_ang))) * p_amount * u_s / u_res; vec4 acc = vec4(0.0);
  for (int i = 0; i < 48; i++) { float t = float(i) / 47.0 - 0.5; acc += tex(v_uv + d * t); } o = acc / 48.0; }
