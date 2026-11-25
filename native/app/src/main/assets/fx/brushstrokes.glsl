// brushstrokes
uniform float p_size; uniform float p_ang; uniform float p_len; uniform float p_rand;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 px = v_uv * u_res; float sz = p_size * u_s; vec2 cell = floor(px / sz); float j = hash1(cell);
  float ang = radians(p_ang + (j - 0.5) * 90.0 * p_rand / 100.0); vec2 dir = vec2(cos(ang), sin(ang));
  vec4 acc = vec4(0.0); float L = sz * (1.0 + p_len / 15.0);
  for (int i = -6; i <= 6; i++) acc += tex(v_uv + dir * L * float(i) / 6.0 / u_res);
  acc /= 13.0; vec3 c = unpre(acc); float streak = 0.92 + 0.08 * sin(dot(px, vec2(-dir.y, dir.x)) / (sz * 0.35) + j * 6.0);
  o = pre(clamp(c * streak, 0.0, 1.0), s.a);
}
