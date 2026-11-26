// innerblur
uniform float p_icYari, p_kenarKoru, p_gecis, p_alfayiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float R = max(p_icYari * u_s * 0.5, 0.5); vec4 acc = vec4(0.0); float ws = 0.0;
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec2 f = vec2(float(i), float(j)) / 4.0; vec4 c = texPx(here() + f * R * 1.5); if (c.a < 0.5) continue; float w = exp(-dot(f, f) * 2.0); acc += c * w; ws += w; }
  vec4 b = ws > 0.0 ? acc / ws : s;
  float d = innerDist(here(), (p_kenarKoru + p_gecis) * u_s + 1.0); float m = smoothstep(p_kenarKoru * u_s, (p_kenarKoru + p_gecis) * u_s + 0.5, d);
  vec4 c = mix(s, b, m); if (p_alfayiKoru > 0.5) c = pre(unpre(c), s.a);
  o = c;
}
