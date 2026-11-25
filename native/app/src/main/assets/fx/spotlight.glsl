// spotlight
uniform vec2 p_pos; uniform float p_rad; uniform float p_soft; uniform float p_dark; uniform vec3 c_col;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float d = length(v_uv * u_res - fromUnit(p_pos)) / (p_rad * u_s); float k = 1.0 - smoothstep(1.0 - p_soft / 100.0, 1.0 + p_soft / 100.0, d);
  vec3 c = unpre(s); vec3 lit = c * mix(vec3(1.0), c_col * 1.3, 0.5) ; c = mix(c * (1.0 - p_dark / 100.0), lit, k); o = pre(clamp(c, 0.0, 1.0), s.a);
}
