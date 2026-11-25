// vignette
uniform float p_amount; uniform float p_size; uniform float p_soft; uniform vec3 c_col; uniform float p_round;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 u = boxUV(v_uv * u_res) - 0.5; if (p_round > 0.5) u.x *= u_box.z / u_box.w;
  float d = length(u * vec2(1.0, p_round > 0.5 ? 1.0 : 1.0)) * 1.414; float r = p_size / 100.0, f = max(0.01, p_soft / 100.0);
  float k = smoothstep(r, r + f, d) * p_amount / 100.0;
  vec3 c = unpre(s); o = pre(mix(c, c_col, k), s.a);
}
