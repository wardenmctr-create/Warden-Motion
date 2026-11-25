// deblur
uniform float p_len; uniform float p_ang; uniform float p_amount; uniform float p_iter;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 d = vec2(cos(radians(p_ang)), sin(radians(p_ang))) * p_len * u_s / u_res;
  vec4 b = vec4(0.0); for (int i = 0; i < 16; i++) b += tex(v_uv + d * (float(i) / 15.0 - 0.5)); b /= 16.0;
  vec3 c = unpre(s) + (unpre(s) - unpre(b)) * p_amount / 100.0 * p_iter * 0.7; o = pre(clamp(c, 0.0, 1.0), s.a); }
