// geodesiccolor
uniform sampler2D s_baslangiMask, s_bitisMask; uniform float p_baslangiMaskOn, p_bitisMaskOn; uniform vec3 c_baslangi, c_bitis;
// İç uzaklık yaklaşık: silüet dışına çıkmayan ışınlarla iki maskeye en kısa uzaklık; renk oranla karışır
float maskA(sampler2D t, float on, vec2 b, float side) { if (on > 0.5) return texture(t, b).a; return side < 0.5 ? step(b.x, 0.12) : step(0.88, b.x); }
float reach(sampler2D t, float on, float side) { vec2 p = here(); float best = 1e5; float st = max(length(u_box.zw) / 48.0, 1.0);
  for (int i = 0; i < 16; i++) { float a = float(i) / 16.0 * TAU; vec2 d = vec2(cos(a), sin(a));
    for (int k = 0; k <= 48; k++) { vec2 q = p + d * float(k) * st; if (texPx(q).a < 0.3) break; if (maskA(t, on, boxUV(q), side) > 0.5) { best = min(best, float(k) * st); break; } } }
  return best; }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float a = reach(s_baslangiMask, p_baslangiMaskOn, 0.0), b = reach(s_bitisMask, p_bitisMaskOn, 1.0);
  float k = (a > 9e4 && b > 9e4) ? boxUV(here()).x : a / max(a + b, 1e-3); vec3 c = mix(c_baslangi, c_bitis, clamp(k, 0.0, 1.0)); o = pre(c * mix(0.75, 1.0, luma(unpre(s))) + unpre(s) * 0.0, s.a); }
