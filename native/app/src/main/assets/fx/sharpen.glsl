// sharpen
uniform float p_amount; uniform float p_rad;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 d = p_rad * u_s / u_res; vec4 b = (tex(v_uv + vec2(d.x, 0)) + tex(v_uv - vec2(d.x, 0)) + tex(v_uv + vec2(0, d.y)) + tex(v_uv - vec2(0, d.y))) * 0.25;
  vec3 c = unpre(s) + (unpre(s) - unpre(b)) * p_amount / 100.0 * 1.5; o = pre(clamp(c, 0.0, 1.0), s.a); }
