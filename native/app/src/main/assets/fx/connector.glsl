// connector
uniform vec2 p_baslangiBagl, p_bitisBagl; uniform float p_bicim, p_egrilik, p_kalinlik, p_ucIsar, p_cizimIler; uniform vec3 c_renk;
vec2 bez(vec2 a, vec2 c, vec2 b, float t) { return mix(mix(a, c, t), mix(c, b, t), t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 A = p_baslangiBagl, B = p_bitisBagl; vec2 m = (A + B) * 0.5; vec2 nrm = normalize(vec2(-(B - A).y, (B - A).x) + 1e-5);
  vec2 C = p_bicim < 0.5 ? m : p_bicim < 1.5 ? m + nrm * length(B - A) * (0.3 + p_egrilik / 200.0) : p_bicim < 2.5 ? vec2(B.x, A.y) : m + nrm * length(B - A) * p_egrilik / 100.0;
  float best = 1e9, bt = 0.0; vec2 prev = A; float prog = p_cizimIler / 100.0;
  for (int i = 1; i <= 32; i++) { float t = float(i) / 32.0; if (t - 1.0 / 32.0 > prog) break; vec2 p = p_bicim > 1.5 && p_bicim < 2.5 ? (t < 0.5 ? mix(A, C, t * 2.0) : mix(C, B, t * 2.0 - 1.0)) : bez(A, C, B, min(t, prog));
    vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(q - prev - ab * u); if (d < best) { best = d; bt = t; } prev = p; }
  float w = p_kalinlik * 0.5; float line = 1.0 - smoothstep(w, w + 0.8 / u_s, best); vec2 end = prev; float cap = 0.0;
  if (p_ucIsar > 0.5) { vec2 dir = normalize(end - bez(A, C, B, max(prog - 0.03, 0.0)) + 1e-5); vec2 l = vec2(dot(q - end, dir), dot(q - end, vec2(-dir.y, dir.x))); float hs = w * 4.0 + 4.0;
    if (p_ucIsar < 1.5 || p_ucIsar > 2.5) cap = max(cap, step(l.x, 0.0) * step(-hs * 1.6, l.x) * step(abs(l.y), (l.x + hs * 1.6) * 0.5)); if (p_ucIsar > 1.5) cap = max(cap, 1.0 - smoothstep(hs * 0.6, hs * 0.6 + 1.0, length(q - A))); }
  o = overPre(vec4(c_renk, 1.0) * max(line, cap), s); }
