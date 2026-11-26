// lineweight
uniform float p_enBuyuKali, p_yumusatm, p_uclariKoru;
// Mürekkep çizgileri: kutu boyunca konum u (en uzun eksen) → kalınlık profili sin(πu); çizgi o kalınlığa genişler, uçlar korunur/incelir
float ink(vec2 p) { vec4 c = texPx(p); return c.a > 0.5 && luma(unpre(c)) < 0.4 ? 1.0 : 0.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float u = u_box.z >= u_box.w ? b.x : b.y; float prof = sin(clamp(u, 0.0, 1.0) * 3.14159); if (p_uclariKoru > 0.5) prof = max(prof, 0.35);
  float W = p_enBuyuKali * u_s * prof * 0.5; float sm = max(p_yumusatm * u_s * 0.2, 0.75); float d = 1e5;
  for (int i = 0; i < 16; i++) { float a = float(i) / 16.0 * TAU; vec2 dd = vec2(cos(a), sin(a)); for (int k = 0; k <= 12; k++) { float r = float(k) / 12.0 * max(W, 1.0); if (ink(here() + dd * r) > 0.5) { d = min(d, r); break; } } }
  float cov = 1.0 - smoothstep(W - sm, W + sm, d); if (cov <= 0.0 || ink(here()) > 0.5 && W < 0.6) { o = s; return; }
  vec4 lc = vec4(0.05, 0.05, 0.07, 1.0); o = mix(s, overPre(lc, s), cov); }
