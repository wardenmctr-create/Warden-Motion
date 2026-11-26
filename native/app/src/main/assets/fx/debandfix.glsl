// debandfix
uniform float p_guc, p_renkFarkEsig, p_ornekYari, p_gecisSayi, p_kenarKoru, p_inceAyriKoru, p_renkKanaBirl, p_inceGrenEkle, p_grenMikt, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c0 = unpre(s); vec3 acc = c0; float wsum = 1.0; float th = p_renkFarkEsig / 100.0;
  int P = int(clamp(p_gecisSayi, 1.0, 8.0)); float R = p_ornekYari * u_s;
  for (int k = 0; k < 8; k++) { if (k >= P) break; float rr = R * (float(k) + 1.0) / float(P);
    for (int i = 0; i < 8; i++) { float a = float(i) * 0.785 + float(k) * 0.39 + hash1(here() * 0.01 + float(k)) * 0.6; vec3 c = unpre(texPx(here() + vec2(cos(a), sin(a)) * rr));
      vec3 d = abs(c - c0); float diff = p_renkKanaBirl > 0.5 ? max(d.r, max(d.g, d.b)) : luma(d); float w = 1.0 - smoothstep(th * 0.5, th, diff); acc += c * w; wsum += w; } }
  vec3 sm = acc / wsum; float edge = smoothstep(0.05, 0.25, sobel(here(), u_s)) * p_kenarKoru / 100.0; float det = smoothstep(0.01, 0.05, length(c0 - unpre(texPx(here() + vec2(u_s, 0.0))))) * p_inceAyriKoru / 100.0 * 0.5;
  vec3 r = mix(c0, sm, p_guc / 100.0 * (1.0 - max(edge, det)));
  if (p_inceGrenEkle > 0.5) r += (hash1(here() + seedf(p_tohum)) - 0.5) * p_grenMikt / 100.0 * 2.0 / 255.0 * 64.0 * 0.25;
  o = pre(clamp(r, 0.0, 1.0), s.a); }
