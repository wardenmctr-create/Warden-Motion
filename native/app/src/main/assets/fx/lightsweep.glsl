// lightsweep
uniform float p_pos; uniform float p_ang; uniform float p_width; uniform vec3 c_col; uniform float p_str;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 b = boxUV(v_uv * u_res) - 0.5; vec2 dir = vec2(cos(radians(p_ang)), sin(radians(p_ang)));
  float x = dot(b * u_box.zw, dir) / u_s; float c0 = (p_pos / 100.0 - 0.5) * (abs(dir.x) * u_box.z + abs(dir.y) * u_box.w) / u_s;
  float k = exp(-pow((x - c0) / max(1.0, p_width), 2.0) * 2.0) * p_str / 100.0;
  vec3 c = unpre(s) + c_col * k; o = pre(clamp(c, 0.0, 1.0), s.a);
}
