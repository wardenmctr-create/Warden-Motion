// stringart
uniform float p_civiYerl, p_civiSayi, p_cercevePayi, p_iplikSayi, p_iplikKali, p_iplikOpak, p_renkSayi, p_kaynakRenkKull, p_dokumaIler, p_tohum;
vec2 nail(float i, float N) { vec2 B = boxU() * 0.5 * (1.0 - p_cercevePayi / 100.0); float t = fract(i / N);
  if (p_civiYerl < 0.5) return vec2(cos(t * TAU), sin(t * TAU)) * min(B.x, B.y);
  if (p_civiYerl < 1.5 || p_civiYerl > 2.5) { float per = 4.0 * t; vec2 p = per < 1.0 ? vec2(mix(-B.x, B.x, per), -B.y) : per < 2.0 ? vec2(B.x, mix(-B.y, B.y, per - 1.0)) : per < 3.0 ? vec2(mix(B.x, -B.x, per - 2.0), B.y) : vec2(-B.x, mix(B.y, -B.y, per - 3.0)); return p; }
  // siluet: merkezden ışın boyunca alfanın bittiği yer
  vec2 d = vec2(cos(t * TAU), sin(t * TAU)); float r = 0.0; for (int k = 0; k < 24; k++) { float rr = float(k) / 23.0 * length(B); if (texU(d * rr).a > 0.5) r = rr; } return d * max(r, 4.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float N = max(floor(p_civiSayi), 3.0); int T = int(clamp(p_iplikSayi * p_dokumaIler / 100.0, 0.0, 400.0)); float sd = seedf(p_tohum);
  vec4 acc = vec4(0.0); float w = max(p_iplikKali, 0.3) * 0.5;
  for (int i = 0; i < 400; i++) { if (i >= T) break; vec2 h = hash2(vec2(float(i), sd)); float a = floor(h.x * N), b = floor(mod(a + N * 0.25 + h.y * N * 0.5, N)); vec2 A = nail(a, N), Bp = nail(b, N);
    vec2 ab = Bp - A; float t = clamp(dot(q - A, ab) / max(dot(ab, ab), 1e-3), 0.0, 1.0); float d = length(q - A - ab * t); float cov = 1.0 - smoothstep(w, w + 0.8 / u_s, d); if (cov <= 0.0) continue;
    vec3 col = p_kaynakRenkKull > 0.5 ? unpre(texU(A + ab * t)) : vec3(0.1); float L = luma(unpre(texU(A + ab * t))); if (p_kaynakRenkKull > 0.5) { float k = max(p_renkSayi, 2.0); col = floor(col * k + 0.5) / k; }
    float dens = p_kaynakRenkKull > 0.5 ? texU(A + ab * t).a : (1.0 - L) * texU(A + ab * t).a; acc = overPre(vec4(col, 1.0) * cov * p_iplikOpak / 100.0 * dens, acc); }
  vec4 nails = vec4(0.0); for (int i = 0; i < 300; i++) { if (float(i) >= N) break; nails = max(nails, vec4(0.75) * (1.0 - smoothstep(1.2, 2.0, length(q - nail(float(i), N))))); }
  o = overPre(nails, acc); }
