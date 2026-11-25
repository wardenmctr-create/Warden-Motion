// longshadow
uniform float p_ang; uniform float p_len; uniform vec3 c_col; uniform float p_fade; uniform float p_op;
void main() {
  vec4 s = texture(u_tex, v_uv);
  vec2 d = vec2(cos(radians(p_ang)), sin(radians(p_ang))); float L = p_len * u_s; float sh = 0.0;
  for (int i = 1; i <= 96; i++) {
    float x = L * float(i) / 96.0; float a = tex(v_uv - d * x / u_res).a;
    if (a > 0.0) { sh = max(sh, a * (1.0 - p_fade / 100.0 * float(i) / 96.0)); }
  }
  vec4 shad = vec4(c_col, 1.0) * sh * p_op / 100.0;
  o = s + shad * (1.0 - s.a);
}
