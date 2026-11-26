// sankey
INCLUDE(_chart)
uniform float p_bantKivr, p_dugumAral, p_degerEtik;
void main() { vec2 b = boxUV(here()); float R = dR(); float ns = 1.0, nt = 1.0, tot = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; ns = max(ns, dat(float(r), 0.0) + 1.0); nt = max(nt, dat(float(r), 1.0) + 1.0); tot += max(dat(float(r), 2.0), 0.0); }
  if (p_dvR < 0.5) { ns = 3.0; nt = 3.0; } float gap = p_dugumAral / boxU().y; float usable = 1.0 - gap * max(ns, nt); vec4 col = vec4(0.04, 0.06, 0.12, 0.85);
  float sOff[16]; float tOff[16]; float sAcc = gap * 0.5, tAcc = gap * 0.5; for (int i = 0; i < 16; i++) { sOff[i] = 0.0; tOff[i] = 0.0; }
  for (int i = 0; i < 16; i++) { if (float(i) >= ns) break; float sum = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; if (int(dat(float(r), 0.0)) == i) sum += dat(float(r), 2.0); } sOff[i] = sAcc; sAcc += sum / max(tot, 1e-6) * usable + gap; }
  for (int i = 0; i < 16; i++) { if (float(i) >= nt) break; float sum = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; if (int(dat(float(r), 1.0)) == i) sum += dat(float(r), 2.0); } tOff[i] = tAcc; tAcc += sum / max(tot, 1e-6) * usable + gap; }
  float sCur[16]; float tCur[16]; for (int i = 0; i < 16; i++) { sCur[i] = sOff[i]; tCur[i] = tOff[i]; }
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; int si = int(dat(float(r), 0.0)), ti = int(dat(float(r), 1.0)); float h = max(dat(float(r), 2.0), 0.0) / max(tot, 1e-6) * usable; if (si > 15 || ti > 15) continue;
    float x = clamp((b.x - 0.1) / 0.8, 0.0, 1.0); float e = mix(x, x * x * (3.0 - 2.0 * x), p_bantKivr / 100.0); float y0 = mix(sCur[si], tCur[ti], e); if (b.x > 0.1 && b.x < 0.9 && b.y > y0 && b.y < y0 + h) col = overPre(vec4(serCol(float(si), vec3(0.2, 0.5, 1.0)), 1.0) * 0.7, col);
    sCur[si] += h; tCur[ti] += h; }
  for (int i = 0; i < 16; i++) { if (float(i) < ns && b.x > 0.08 && b.x < 0.1 && b.y > sOff[i] && b.y < (i + 1 < 16 && float(i + 1) < ns ? sOff[i + 1] - gap : sAcc - gap)) col = vec4(0.9, 0.9, 0.95, 1.0);
    if (float(i) < nt && b.x > 0.9 && b.x < 0.92 && b.y > tOff[i] && b.y < (i + 1 < 16 && float(i + 1) < nt ? tOff[i + 1] - gap : tAcc - gap)) col = vec4(0.9, 0.9, 0.95, 1.0); }
  o = col; }
