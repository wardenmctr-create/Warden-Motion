// lowpoly
uniform float p_noktaSayi, p_dagilim, p_kenarHass, p_duzensiz, p_renkOrne, p_kenarCizg, p_cizgiKali, p_noktalarSabi, p_tohum; uniform vec3 c_cizgiReng;
vec2 jit(vec2 id, float cs) { float sd = seedf(p_tohum) + (p_noktalarSabi > 0.5 ? 0.0 : floor(u_t * 4.0)); vec2 h = hash2(id + sd) - 0.5; float k = p_dagilim < 0.5 ? 0.0 : p_duzensiz / 100.0 * 0.8;
  vec2 p = (id + 0.5 + h * k) * cs; if (p_dagilim > 1.5) { vec2 g = lumGrad(fromUnit(p), cs * u_s * 0.5); if (length(g) > 0.02) p += normalize(g) * cs * 0.3 * p_kenarHass / 100.0; } return p; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); float cs = sqrt(B.x * B.y / max(p_noktaSayi, 4.0)); vec2 id = floor(q / cs);
  vec2 p00 = jit(id, cs), p10 = jit(id + vec2(1, 0), cs), p01 = jit(id + vec2(0, 1), cs), p11 = jit(id + vec2(1, 1), cs);
  vec2 c = q; vec2 A, Bv, C;
  // hücreyi iki üçgene böl (köşegen), q hangisinde?
  vec2 f = (q - p00); bool upper = cross(vec3(p11 - p00, 0.0), vec3(q - p00, 0.0)).z > 0.0;
  if (!upper) { A = p00; Bv = p10; C = p11; } else { A = p00; Bv = p11; C = p01; }
  vec2 ctr = (A + Bv + C) / 3.0; vec4 col; if (p_renkOrne < 0.5) col = (texU(A * 0.25 + ctr * 0.75) + texU(Bv * 0.25 + ctr * 0.75) + texU(C * 0.25 + ctr * 0.75) + texU(ctr)) * 0.25; else col = texU(ctr);
  if (p_renkOrne > 1.5) { vec4 a = texU(A * 0.3 + ctr * 0.7), b = texU(Bv * 0.3 + ctr * 0.7), cc = texU(C * 0.3 + ctr * 0.7); col = luma(a.rgb) > luma(b.rgb) ? (luma(a.rgb) > luma(cc.rgb) ? a : cc) : (luma(b.rgb) > luma(cc.rgb) ? b : cc); }
  if (p_kenarCizg > 0.5) { float d = min(min(length(q - A - (Bv - A) * clamp(dot(q - A, Bv - A) / dot(Bv - A, Bv - A), 0.0, 1.0)), length(q - Bv - (C - Bv) * clamp(dot(q - Bv, C - Bv) / dot(C - Bv, C - Bv), 0.0, 1.0))), length(q - C - (A - C) * clamp(dot(q - C, A - C) / dot(A - C, A - C), 0.0, 1.0)));
    col = overPre(vec4(c_cizgiReng, 1.0) * (1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali * 0.5 + 0.8 / u_s, d)) * col.a, col); }
  o = col * step(0.001, s.a + col.a); }
