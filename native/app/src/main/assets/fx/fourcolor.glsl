// fourcolor
uniform vec3 c_c1; uniform vec3 c_c2; uniform vec3 c_c3; uniform vec3 c_c4; uniform float p_speed; uniform float p_mix;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 b = clamp(boxUV(v_uv * u_res), 0.0, 1.0); float a = u_t * p_speed * TAU;
  b += 0.12 * vec2(sin(a + b.y * 3.0), cos(a * 0.8 + b.x * 3.0));
  b = clamp(b, 0.0, 1.0); vec3 col = mix(mix(c_c1, c_c2, b.x), mix(c_c3, c_c4, b.x), b.y);
  o = overOpaque(s, col, 1.0, p_mix / 100.0);
}
