// perspgrid
uniform vec2 p_ufukNokt, p_hareketHizi; uniform vec3 p_izgaraDonu, c_cizgiReng; uniform float p_izgaraGeni, p_izgaraDeri, p_hucreBuyu, p_cizgiKali, p_cizgiOpak, p_hucreDolg, p_uzakliktSolm, p_perspektGucu, p_parlama, p_parlamaGucu;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_ufukNokt; float y = q.y; if (y <= 0.5) { o = s; return; }
  float tilt = radians(clamp(p_izgaraDonu.x, 5.0, 89.0)); float F = 400.0 * (1.0 - p_perspektGucu / 100.0 * 0.7) / tan(tilt) + 50.0; float z = F * 400.0 / max(y, 0.5) / max(F, 1.0) * 1.0;
  float depth = 300.0 * F / y; vec2 g = vec2(q.x * depth / F, depth); g = rot2(-p_izgaraDonu.y) * g; g += p_hareketHizi * u_t; if (depth > p_izgaraDeri || abs(g.x) > p_izgaraGeni * 0.5 + 1e5 * 0.0) { o = s; return; }
  vec2 cell = g / max(p_hucreBuyu, 1.0); vec2 fw = fwidth(cell); vec2 ln = abs(fract(cell - 0.5) - 0.5) / max(fw, vec2(1e-4)); float line = 1.0 - min(min(ln.x, ln.y) / max(p_cizgiKali, 0.3), 1.0);
  float fade = 1.0 - smoothstep(0.0, p_izgaraDeri, depth) * p_uzakliktSolm / 100.0; fade *= step(abs(g.x), p_izgaraGeni * 0.5);
  vec4 c = s; if (p_hucreDolg > 0.5) c = overPre(vec4(c_cizgiReng, 1.0) * 0.12 * fade, c); c = overPre(vec4(c_cizgiReng, 1.0) * line * fade * p_cizgiOpak / 100.0, c);
  if (p_parlama > 0.5) c = overPre(vec4(c_cizgiReng, 1.0) * exp(-y / 30.0) * p_parlamaGucu / 100.0, c); o = c; }
