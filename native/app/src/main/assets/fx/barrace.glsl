// barrace
INCLUDE(_chart)
uniform float p_gorunenOge, p_gecis, p_degerEtik;
void main() { vec2 b = boxUV(here()); float R = dR(), C = dC(); float tt = clamp(u_t / max(u_dur, 0.1), 0.0, 1.0) * (R - 1.0); float r0 = floor(tt), f = smoothstep(0.0, 1.0, fract(tt));
  float M = 1e-6; float vals[16]; for (int c = 0; c < 16; c++) { if (float(c) >= C) break; vals[c] = mix(dat(r0, float(c)), dat(min(r0 + 1.0, R - 1.0), float(c)), f); M = max(M, vals[c]); }
  float N = min(floor(p_gorunenOge), C); vec4 col = vec4(0.04, 0.06, 0.12, 0.85);
  for (int c = 0; c < 16; c++) { if (float(c) >= C) break; float rank = 0.0; for (int d = 0; d < 16; d++) { if (float(d) >= C) break; if (vals[d] > vals[c] || (vals[d] == vals[c] && d < c)) rank += 1.0; } if (rank >= N) continue;
    float y0 = rank / N, y1 = y0 + 0.8 / N; float w = vals[c] / M * 0.82; if (b.y > y0 + 0.05 / N && b.y < y1 && b.x < w + 0.02) col = vec4(serCol(float(c), vec3(0.2, 0.5, 1.0)), 1.0);
    if (p_degerEtik > 0.5) { vec2 lp = (b - vec2(w + 0.08, (y0 + y1) * 0.5 + 0.02 / N)) * boxU() / (boxU().y / N * 0.3); col = overPre(vec4(1.0) * numAt(lp, vals[c]), col); } }
  o = col; }
