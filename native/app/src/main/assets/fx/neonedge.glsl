// neonedge
uniform float p_esik, p_kenarKali, p_hale, p_yogunluk, p_kaynakRenkKull, p_arkaPlanKara; uniform vec3 c_neonReng;
void main() {
  vec4 s = texture(u_tex, v_uv); float st = max(1.0, p_kenarKali * u_s * 0.5);
  float e = smoothstep(p_esik / 100.0 * 0.4, p_esik / 100.0 * 0.4 + 0.12, sobel(here(), st) * 0.5 + length(alphaGrad(here(), st)) * st);
  float g = 0.0; float R = p_hale * u_s;
  for (int i = 0; i < 12; i++) { float a = float(i) * TAU / 12.0; vec2 d = vec2(cos(a), sin(a)); g += smoothstep(p_esik / 100.0 * 0.4, p_esik / 100.0 * 0.4 + 0.12, sobel(here() + d * R * 0.45, st) * 0.5) * 0.5 + smoothstep(p_esik / 100.0 * 0.4, p_esik / 100.0 * 0.4 + 0.12, sobel(here() + d * R, st) * 0.5) * 0.25; }
  g /= 12.0;
  vec3 col = p_kaynakRenkKull > 0.5 ? (s.a > 0.0 ? normalize(unpre(s) + 0.05) : c_neonReng) : c_neonReng;
  float k = p_yogunluk / 100.0; vec3 line = mix(col, vec3(1.0), 0.5 * e) * e;
  vec3 bg = p_arkaPlanKara > 0.5 ? vec3(0.02, 0.03, 0.08) : unpre(s) * 0.35;
  vec3 r = bg + (line + col * g * 1.5) * k;
  o = pre(clamp(r, 0.0, 1.0), max(s.a, clamp(e + g, 0.0, 1.0)));
}
