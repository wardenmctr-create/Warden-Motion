// smoothedges
uniform float p_yumusatm, p_esik, p_kenarDara, p_ayrintiyKoru, p_yalnizAlfa;
void main() {
  vec4 s = texture(u_tex, v_uv); float R = max(p_yumusatm * u_s, 0.5);
  float a = 0.0; vec4 c = vec4(0.0);
  for (int i = -2; i <= 2; i++) for (int j = -2; j <= 2; j++) { vec4 x = texPx(here() + vec2(float(i), float(j)) * R * 0.5); a += x.a; c += x; }
  a /= 25.0; c /= 25.0;
  float th = clamp(p_esik / 100.0 - p_kenarDara / 500.0, 0.01, 0.99); float na = smoothstep(th - 0.15, th + 0.15, a);
  vec3 col = p_yalnizAlfa > 0.5 || s.a > 0.05 ? (s.a > 0.0 ? s.rgb / s.a : (c.a > 0.0 ? c.rgb / c.a : vec3(0.0))) : (c.a > 0.0 ? c.rgb / c.a : vec3(0.0));
  if (p_yalnizAlfa < 0.5 && c.a > 0.0) col = mix(c.rgb / c.a, col, p_ayrintiyKoru / 100.0);
  o = pre(col, na);
}
