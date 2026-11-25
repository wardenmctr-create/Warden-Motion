// radialshadow
uniform vec2 p_light; uniform float p_dist; uniform float p_blur; uniform vec3 c_col; uniform float p_op;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 px = v_uv * u_res; vec2 lp = fromUnit(p_light);
  vec2 dir = normalize(px - lp + 1e-4); float L = p_dist * u_s; float b = p_blur * u_s * 0.5;
  float a = 0.0; float n = 0.0;
  for (int i = 0; i < 24; i++) { float j = (float(i) / 23.0 - 0.5); vec2 q = px - dir * (L + j * b) + vec2(-dir.y, dir.x) * j * b * 0.6; a += texPx(q).a; n += 1.0; }
  a /= n; vec4 shad = vec4(c_col, 1.0) * a * p_op / 100.0;
  o = s + shad * (1.0 - s.a);
}
