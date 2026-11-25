// gradoverlay
uniform vec3 c_c1; uniform vec3 c_c2; uniform float p_ang; uniform float p_gtype; uniform float p_mix;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 u = boxUV(v_uv * u_res) - 0.5; float f;
  if (p_gtype < 0.5) { vec2 d = vec2(sin(radians(p_ang)), -cos(radians(p_ang))); f = clamp(dot(u, d) * 1.0 + 0.5, 0.0, 1.0); } else f = clamp(length(u) * 1.6, 0.0, 1.0);
  o = overOpaque(s, mix(c_c1, c_c2, f), 1.0, p_mix / 100.0);
}
