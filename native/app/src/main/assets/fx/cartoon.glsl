// cartoon
uniform float p_renkSevi, p_kenarEsig, p_kenarKali, p_yuzeyYumu, p_cizgilerGost; uniform vec3 c_kenarReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 acc = vec3(0.0); float ws = 0.0; float R = p_yuzeyYumu * u_s; vec3 c0 = unpre(s);
  for (int i = -2; i <= 2; i++) for (int j = -2; j <= 2; j++) { vec2 d = vec2(float(i), float(j)) * R * 0.5; vec4 x = texPx(here() + d); if (x.a < 0.01) continue; vec3 c = x.rgb / x.a; float w = exp(-dot(c - c0, c - c0) * 12.0); acc += c * w; ws += w; }
  vec3 c = acc / max(ws, 1e-3); float n = max(2.0, p_renkSevi) - 1.0; vec3 h = rgb2hsv(c); h.z = floor(h.z * n + 0.5) / n; c = hsv2rgb(h);
  if (p_cizgilerGost > 0.5) { float e = smoothstep(p_kenarEsig / 100.0 * 0.5, p_kenarEsig / 100.0 * 0.5 + 0.1, sobel(here(), max(1.0, p_kenarKali * u_s * 0.6)) * 0.5); c = mix(c, c_kenarReng, e); }
  o = pre(c, s.a);
}
