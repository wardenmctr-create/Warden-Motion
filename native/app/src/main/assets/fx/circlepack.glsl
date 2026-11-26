// circlepack
uniform sampler2D s_sinir; uniform float p_sinirOn, p_enKucuYari, p_enBuyu, p_doluluk, p_tohum;
// Üç ölçekte çember: büyükler önce, küçükler yalnız büyüklerin örtmediği yerde; sınır içinde ve kenara taşmadan; renk katmandan
float B(vec2 u) { return p_sinirOn > 0.5 ? texture(s_sinir, boxUV(fromUnit(u))).a : texU(u).a; }
vec3 cand(vec2 id, float L, float R) { vec2 h = hash2(id + L * 17.0 + p_tohum * 0.31); float cellS = R * 2.2; vec2 c = (id + 0.5 + (h - 0.5) * 0.25) * cellS; float r = R * (0.75 + 0.25 * hash1(id + L + 5.0));
  float ok = step(hash1(id * 1.7 + L + p_tohum), p_doluluk / 100.0) * step(0.5, B(c)) * step(0.5, B(c + vec2(r, 0.0))) * step(0.5, B(c - vec2(r, 0.0))) * step(0.5, B(c + vec2(0.0, r))) * step(0.5, B(c - vec2(0.0, r)));
  return vec3(c, ok > 0.5 ? r : -1.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R0 = p_enBuyu, R2 = max(p_enKucuYari, 1.0), R1 = sqrt(R0 * R2); vec4 res = vec4(0.0); float covered = 0.0;
  for (int L = 0; L < 3; L++) { float R = L == 0 ? R0 : (L == 1 ? R1 : R2); vec2 id0 = floor(q / (R * 2.2));
    for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec3 c = cand(id0 + vec2(i, j), float(L), R); if (c.z <= 0.0) continue;
      // daha büyük ölçekteki çemberlerle çakışıyorsa atla
      bool hit = false; for (int P = 0; P < 2; P++) { if (P >= L) break; float RP = P == 0 ? R0 : R1; vec2 pid = floor(c.xy / (RP * 2.2)); for (int jj = -1; jj <= 1; jj++) for (int ii = -1; ii <= 1; ii++) { vec3 pc = cand(pid + vec2(ii, jj), float(P), RP); if (pc.z > 0.0 && length(pc.xy - c.xy) < pc.z + c.z + 1.0) hit = true; } }
      if (hit) continue; float d = length(q - c.xy) - c.z; float a = 1.0 - smoothstep(-0.8 / u_s, 0.8 / u_s, d); if (a <= 0.0) continue; vec4 col = texU(c.xy); res = vec4(unpre(col) * (0.85 + 0.15 * (1.0 - length(q - c.xy) / c.z)), 1.0) * a; covered = 1.0; } }
  o = covered > 0.0 ? res : vec4(0.0); }
