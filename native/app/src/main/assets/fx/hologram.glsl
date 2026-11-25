// hologram
uniform vec3 c_col; uniform float p_lines; uniform float p_flick; uniform float p_speed;
void main() {
  float jit = (hash1(vec2(floor(u_t * 10.0 * p_speed), floor(v_uv.y * 40.0))) - 0.5) * 0.01 * p_flick / 100.0 * step(0.85, hash1(vec2(floor(u_t * 7.0), 1.0)));
  vec4 s = tex(v_uv + vec2(jit, 0.0)); if (s.a <= 0.0) { o = vec4(0.0); return; }
  float l = luma(unpre(s)); vec3 c = c_col * (0.35 + l * 1.1);
  float ln = 0.65 + 0.35 * step(0.5, fract(v_uv.y * u_res.y / (4.0 * u_s) - u_t * p_speed * 2.0)); c *= mix(1.0, ln, p_lines / 100.0);
  float band = smoothstep(0.0, 0.05, abs(fract(v_uv.y - u_t * 0.35 * p_speed) - 0.5)); c += c_col * (1.0 - band) * 0.4;
  float fl = 1.0 - p_flick / 100.0 * 0.4 * hash1(vec2(floor(u_t * 20.0), 5.0)); float a = s.a * 0.85 * fl;
  o = vec4(min(c, vec3(1.0)) * a, a);
}
