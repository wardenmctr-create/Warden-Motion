// cbdust
uniform vec2 p_merkez; uniform float p_tetiklem, p_sure, p_pufSayi, p_boyut, p_yayilma, p_yumusakl, p_tohum; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float pr = (u_t - p_tetiklem) / max(p_sure, 0.05); if (pr < 0.0 || pr > 1.0) { o = s; return; } float acc = 0.0; int N = int(clamp(p_pufSayi, 1.0, 30.0));
  for (int i = 0; i < 30; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum))); float side = (float(i) / max(float(N) - 1.0, 1.0) - 0.5) * 2.0; vec2 c = p_merkez + vec2(side * p_yayilma * (0.4 + 0.6 * pr), -p_boyut * 0.3 * pr * (0.5 + h.y));
    float r = p_boyut * (0.4 + 0.6 * pr) * (0.6 + 0.6 * h.x); float d = length(q - c); acc = max(acc, (1.0 - smoothstep(r * (1.0 - p_yumusakl / 100.0) - 0.5, r, d)) * (1.0 - pr)); }
  o = overPre(s, vec4(c_renk, 1.0) * acc); }
