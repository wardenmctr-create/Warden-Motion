// scribble
uniform float p_width; uniform float p_space; uniform float p_ang; uniform float p_wiggle; uniform vec3 c_col; uniform float p_keep;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = p_keep > 0.5 ? s : vec4(0.0); return; }
  vec2 q = rot2(p_ang) * (v_uv * u_res) / u_s; float fr = floor(u_t * 12.0);
  float y = q.y + sin(q.x * 0.08 + fr) * p_wiggle + vnoise(vec2(q.x * 0.05, fr)) * p_wiggle;
  float d = abs(fract(y / p_space) - 0.5) * p_space; float line = 1.0 - smoothstep(p_width * 0.5 - 0.6, p_width * 0.5 + 0.6, d);
  float a = line * s.a; vec4 ink = vec4(c_col, 1.0) * a;
  o = p_keep > 0.5 ? ink + s * (1.0 - a) : ink;
}
