// embroidery
INCLUDE(_mat)
uniform float p_dikisTuru, p_dikisUzun, p_iplikKali, p_dikisAral, p_dikisYonu, p_dikisYonl, p_dikisDuze, p_iplikKaba, p_orijinalRenkKull, p_renkSayi, p_kumasAltl, p_kumasTuru, p_kenarDiki, p_islenmeIler, p_sekilDegiTaki; uniform vec3 c_ozelIpliReng;
vec3 quant(vec3 c) { float n = max(p_renkSayi, 2.0); float k = pow(n, 1.0 / 3.0); return floor(c * k + 0.5) / k; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float ang = p_dikisYonu;
  if (p_dikisYonl > 0.5) { vec2 g = p_dikisYonl < 1.5 ? alphaGrad(here(), 2.0 * u_s) + lumGrad(here(), 2.0 * u_s) * 0.5 : lumGrad(here(), 3.0 * u_s); if (length(g) > 1e-3) ang = degrees(atan(g.y, g.x)) + 90.0; }
  float L = max(p_dikisUzun, 1.0); float W = max(p_iplikKali, 0.5) + p_dikisAral; vec2 r = rot2(-ang) * q; float row = floor(r.y / W); float off = p_dikisTuru > 0.5 && p_dikisTuru < 1.5 ? 0.0 : mod(row, 2.0) * 0.5 * L;
  if (p_dikisTuru > 3.5) r.x += sin(r.y / W * PI) * W * 0.5; float cx = (r.x + off) / L; float id = floor(cx); float fx = fract(cx); float fy = fract(r.y / W);
  vec2 jit = (hash2(vec2(id, row)) - 0.5) * p_dikisDuze / 100.0 * 0.4; fx += jit.x; fy += jit.y;
  float thr = max(p_iplikKali, 0.5) / W; float yy = (fy - 0.5) / max(thr * 0.5, 0.05);
  float stitch; if (p_dikisTuru > 2.5 && p_dikisTuru < 3.5) stitch = 1.0 - smoothstep(0.8, 1.0, abs(yy)); else if (p_dikisTuru > 1.5 && p_dikisTuru < 2.5) { vec2 f = vec2(fx, fy) - 0.5; stitch = max(1.0 - smoothstep(0.06, 0.12, abs(f.x - f.y)), 1.0 - smoothstep(0.06, 0.12, abs(f.x + f.y))); }
  else stitch = (1.0 - smoothstep(0.8, 1.0, abs(yy))) * smoothstep(0.0, 0.08, fx) * smoothstep(1.0, 0.92, fx);
  float shade = 0.7 + 0.3 * sqrt(max(0.0, 1.0 - yy * yy)) + (vnoise(r * vec2(0.5, 3.0)) - 0.5) * p_iplikKaba / 100.0 * 0.6; shade *= 0.85 + 0.3 * fx * (1.0 - fx) * 2.0;
  vec3 thread = p_orijinalRenkKull > 0.5 ? quant(unpre(texPx(here() - (vec2(fx, fy) - 0.5) * vec2(L, W) * 0.0))) : c_ozelIpliReng;
  float reveal = step(hash1(vec2(id, row) + 0.37), p_islenmeIler / 100.0 * 1.001);
  float edge = 0.0; if (p_kenarDiki > 0.5) { float d = innerDist(here(), 4.0 * u_s); edge = smoothstep(4.0 * u_s, 3.0 * u_s, d) * step(0.001, s.a); }
  float a = s.a * stitch * reveal; vec3 col = thread * shade; if (edge > 0.0) { float sat = 0.75 + 0.25 * sin(q.x * 2.0 + q.y * 2.0); col = mix(col, quant(unpre(s)) * 0.7 * sat, edge); a = max(a, edge * s.a); }
  vec4 res = pre(clamp(col, 0.0, 1.0), clamp(a, 0.0, 1.0));
  if (p_kumasAltl > 0.5) { int id2 = p_kumasTuru < 0.5 ? 10 : 11; vec3 fab = matSample(id2, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb; vec3 fc = p_kumasTuru > 2.5 && p_kumasTuru < 3.5 ? vec3(0.2, 0.3, 0.55) * fab / max(luma(fab), 0.05) * 0.5 : fab;
    res = overPre(res, vec4(fc, 1.0) * max(s.a, dilateA(here(), 6.0 * u_s))); }
  o = res; }
