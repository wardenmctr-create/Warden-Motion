// edgedirextend
uniform float p_uzama, p_yonYumu, p_alfayiGeni, p_karisim;
// Kenar teğeti boyunca rengi uzatır (çizgi akışı): teğet yönünde ileri-geri ortalama
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); vec2 g = vec2(0.0); float R = max(p_yonYumu * u_s, 1.0);
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 q = p + vec2(i, j) * R * 0.5; vec2 gg = lumGrad(q, 1.0) + alphaGrad(q, 1.0); g += vec2(gg.x * gg.x - gg.y * gg.y, 2.0 * gg.x * gg.y); }
  float ang = 0.5 * atan(g.y, g.x); vec2 t = vec2(-sin(ang), cos(ang)); float L = p_uzama * u_s; vec4 acc = s; float w = 1.0;
  for (int k = 1; k <= 16; k++) { float r = float(k) / 16.0 * L; float ww = 1.0 - float(k) / 17.0; acc += (texPx(p + t * r) + texPx(p - t * r)) * ww; w += 2.0 * ww; }
  vec4 e = acc / w; if (p_alfayiGeni < 0.5) e = e.a > 0.0 ? vec4(unpre(e) * s.a, s.a) : vec4(0.0); o = mix(s, e, p_karisim / 100.0); }
