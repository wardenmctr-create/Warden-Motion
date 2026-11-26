// cellnetwork
uniform sampler2D s_kaynakHucrAgi; uniform float p_kaynakHucrAgiOn, p_kenarKali, p_kavsakYuva, p_kapaliDisCevr;
// Hücre ağı çizgileri (kaynak katman, koyu çizgiler ya da üretilmiş Voronoi) kalınlaştırılır; kavşaklarda yuvarlatma
float L(vec2 px) { if (p_kaynakHucrAgiOn > 0.5) return texture(s_kaynakHucrAgi, boxUV(px)).a; vec4 c = texPx(px); if (c.a > 0.5 && luma(unpre(c)) < 0.3) return 1.0; vec4 v = voronoi(toUnit(px) / 40.0); return step(v.y - v.x, 0.03); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float W = p_kenarKali * u_s * 0.5; float J = p_kavsakYuva * u_s; float d = 1e5; float cnt = 0.0;
  for (int i = 0; i < 16; i++) { float a = float(i) / 16.0 * TAU; for (int k = 0; k <= 10; k++) { float r = float(k) / 10.0 * (W + J); if (L(p + vec2(cos(a), sin(a)) * r) > 0.5) { d = min(d, r); if (r < W + J) cnt += 1.0; break; } } }
  float jw = W + J * smoothstep(8.0, 14.0, cnt); float a = 1.0 - smoothstep(jw - 0.8, jw + 0.8, d); vec2 b = boxUV(p); if (p_kapaliDisCevr > 0.5) a = max(a, 1.0 - smoothstep(W / u_box.z * 2.0, W / u_box.z * 2.0 + 0.004, min(min(b.x, 1.0 - b.x), min(b.y, 1.0 - b.y))));
  o = overPre(vec4(0.08, 0.1, 0.14, 1.0) * a, s); }
