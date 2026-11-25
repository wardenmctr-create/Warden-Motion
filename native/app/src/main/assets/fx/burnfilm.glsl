// burnfilm
uniform float p_prog; uniform float p_scale; uniform vec2 p_center;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 px = v_uv * u_res; float d = length(px - fromUnit(p_center)) / length(u_box.zw) * 2.0;
  float n = fbm(px / (p_scale * u_s), 5.0) * 0.5; float v = d + n - p_prog / 100.0 * 1.8;
  float hole = smoothstep(-0.02, 0.0, v); float ember = (1.0 - smoothstep(0.0, 0.06, abs(v - 0.02))) * step(0.0, v); float char = 1.0 - smoothstep(0.02, 0.18, v);
  vec3 c = unpre(s); c = mix(c, vec3(0.12, 0.05, 0.02), char * 0.85); c += vec3(1.0, 0.55, 0.1) * ember * 1.4;
  float a = s.a * hole; o = pre(clamp(c, 0.0, 1.0), a);
}
