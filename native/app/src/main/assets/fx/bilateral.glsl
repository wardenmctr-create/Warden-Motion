// bilateral
uniform float p_uzamsalYari, p_renkTole, p_yineleme, p_kenarKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float R = max(p_uzamsalYari * u_s, 0.5); float tol = max(p_renkTole / 100.0, 0.01) * mix(1.6, 0.6, p_kenarKoru / 100.0);
  vec4 acc = vec4(0.0); float ws = 0.0; float it = clamp(p_yineleme, 1.0, 8.0);
  for (int j = -4; j <= 4; j++) for (int i = -4; i <= 4; i++) { vec2 f = vec2(float(i), float(j)) / 4.0; vec4 x = texPx(here() + f * R * sqrt(it) * 0.7); vec3 c = unpre(x);
    float w = exp(-dot(f, f) * 2.0) * exp(-dot(c - c0, c - c0) / (tol * tol)) * (x.a > 0.01 ? 1.0 : 0.05); acc += x * w; ws += w; }
  o = acc / max(ws, 1e-4);
}
