// Tekrar efektlerinin ortak ayarları: kopya başına renk tonu/opaklık, rastgele konum/açı/ölçek, tohum, çizim sırası
uniform float p_rTonAdim, p_rOpakAdim, p_rRastKonum, p_rRastAci, p_rRastOlcek, p_rTohum, p_rSiraTers;
vec3 hueRot(vec3 c, float d) { float a = radians(d); vec3 k = vec3(0.57735); float ca = cos(a); return c * ca + cross(k, c) * sin(a) + k * dot(k, c) * (1.0 - ca); }
vec2 repL(vec2 l, float k) { if (p_rRastKonum <= 0.0 && p_rRastAci <= 0.0 && p_rRastOlcek <= 0.0) return l;
  vec2 h = hash2(vec2(k * 1.13 + 0.5, seedf(p_rTohum) + 11.0)) - 0.5; vec2 h2 = hash2(vec2(k * 0.71 + 2.3, seedf(p_rTohum) + 29.0)) - 0.5;
  float s = max(1.0 + h2.x * 2.0 * p_rRastOlcek / 100.0, 0.05); return rot2(-h2.y * 2.0 * p_rRastAci) * (l - h * 2.0 * p_rRastKonum) / s; }
vec4 repC(vec4 c, float k) { if (c.a <= 0.0) return c; if (p_rTonAdim != 0.0) c.rgb = clamp(hueRot(c.rgb / c.a, p_rTonAdim * k), 0.0, 1.0) * c.a;
  return c * clamp(1.0 + p_rOpakAdim / 100.0 * k, 0.0, 1.0); }
vec4 rov(vec4 a, vec4 b) { return p_rSiraTers > 0.5 ? overPre(b, a) : overPre(a, b); }
