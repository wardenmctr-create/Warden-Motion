// thicknessmap
uniform float p_enBuyuOlcu, p_cikti, p_detay, p_siluetiKoru;
// Yerel kalınlık: çevredeki iç uzaklık tepelerinin (medial eksen) en büyüğünün iki katı
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = p_siluetiKoru > 0.5 ? vec4(0.0) : s; return; } vec2 p = here(); float M = p_enBuyuOlcu * u_s * 0.5; float d0 = innerDist(p, M);
  float best = d0; float R = d0 * (1.0 + (1.0 - p_detay / 100.0)); for (int i = 0; i < 8; i++) { float a = float(i) / 8.0 * TAU; for (int k = 1; k <= 3; k++) { vec2 q = p + vec2(cos(a), sin(a)) * R * float(k) / 3.0; if (texPx(q).a < 0.5) break; best = max(best, innerDist(q, M)); } }
  float th = clamp(best * 2.0 / max(M * 2.0, 1.0), 0.0, 1.0); vec3 c = p_cikti < 0.5 ? vec3(th) : hsv2rgb(vec3(0.66 - th * 0.66, 0.85, 0.95)); o = pre(c, s.a); }
