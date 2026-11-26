// linejunction
uniform vec3 c_ucReng, c_kavsakReng; uniform float p_algilamaEsig, p_isaretCapi;
// İskelet komşuluğu: çevre halkasındaki çizgi geçişi sayısı 1 = uç, ≥3 = kavşak
float on(vec2 p) { vec4 c = texPx(p); return step(1.0 - p_algilamaEsig / 100.0, c.a * (0.4 + 0.6 * (1.0 - luma(unpre(c))))); }
float crossings(vec2 c, float r) { float n = 0.0; float prev = on(c + vec2(r, 0.0)); for (int i = 1; i <= 24; i++) { float a = float(i) / 24.0 * TAU; float cur = on(c + vec2(cos(a), sin(a)) * r); if (cur > 0.5 && prev < 0.5) n += 1.0; prev = cur; } return n; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float R = max(p_isaretCapi * u_s * 0.5, 1.5); vec4 res = s;
  // işaret: yakın 3×3 adaydan en güçlüsü
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = floor((p + vec2(i, j) * R * 2.0) / (R * 2.0)) * R * 2.0 + R; if (on(c) < 0.5) continue; float n = crossings(c, R * 1.6);
    float d = length(p - c); float a = 1.0 - smoothstep(R - 1.0, R, d); if (a <= 0.0) continue;
    if (n < 1.5 && n > 0.5) res = overPre(vec4(c_ucReng, 1.0) * a, res); else if (n > 2.5) res = overPre(vec4(c_kavsakReng, 1.0) * a, res); }
  o = res; }
