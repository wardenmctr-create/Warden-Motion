// frame
uniform float p_width; uniform vec3 c_col; uniform float p_rad;
float sdRR(vec2 p, vec2 b, float r) { vec2 q = abs(p) - b + r; return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r; }
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 p = v_uv * u_res - boxCenter(); vec2 b = u_box.zw * 0.5 + p_width * u_s * 0.5; float r = p_rad * u_s;
  float d = abs(sdRR(p, b, r)) - p_width * u_s * 0.5; float a = 1.0 - smoothstep(-0.75, 0.75, d);
  o = vec4(c_col, 1.0) * a + s * (1.0 - a);
}
