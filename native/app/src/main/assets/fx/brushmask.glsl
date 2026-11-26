// brushmask
uniform float p_fircaCapi, p_sertlik, p_ilerleme, p_maskeyiTersCevi, p_dvN; uniform float p_dv[128];
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = int(p_dvN / 2.0); if (N < 2) { o = s; return; } float tot = 0.0; for (int i = 0; i < 63; i++) { if (i >= N - 1) break; tot += length(vec2(p_dv[i * 2 + 2], p_dv[i * 2 + 3]) - vec2(p_dv[i * 2], p_dv[i * 2 + 1])); }
  float lim = tot * p_ilerleme / 100.0; float acc = 0.0; float best = 1e9;
  for (int i = 0; i < 63; i++) { if (i >= N - 1) break; vec2 a = vec2(p_dv[i * 2], p_dv[i * 2 + 1]), b = vec2(p_dv[i * 2 + 2], p_dv[i * 2 + 3]); vec2 ab = b - a; float L = length(ab); if (acc >= lim) break; float um = min(1.0, (lim - acc) / max(L, 1e-4)); float u = clamp(dot(q - a, ab) / max(L * L, 1e-4), 0.0, um); best = min(best, length(q - a - ab * u)); acc += L; }
  float R = p_fircaCapi * 0.5; float m = 1.0 - smoothstep(R * (p_sertlik / 100.0) * 0.99, R + 0.5, best); if (p_maskeyiTersCevi > 0.5) m = 1.0 - m; o = s * m; }
