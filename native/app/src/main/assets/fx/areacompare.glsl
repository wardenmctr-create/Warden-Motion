// areacompare
uniform float p_alanBiri, p_alanEtik, p_dvN; uniform float p_dv[8];
float seg7(vec2 p, int d) { int m[10] = int[10](63, 6, 91, 79, 102, 109, 125, 7, 127, 111); int b = m[d % 10]; float r = 0.0; vec2 a[7] = vec2[7](vec2(0.0, 0.8), vec2(0.45, 0.4), vec2(0.45, -0.4), vec2(0.0, -0.8), vec2(-0.45, -0.4), vec2(-0.45, 0.4), vec2(0.0, 0.0));
  for (int i = 0; i < 7; i++) { if ((b / int(pow(2.0, float(i)))) % 2 == 0) continue; vec2 q = p - a[i]; bool hz = i == 0 || i == 3 || i == 6; vec2 e = hz ? vec2(0.34, 0.08) : vec2(0.08, 0.32); vec2 dd = abs(q) - e; r = max(r, 1.0 - smoothstep(0.0, 0.08, max(dd.x, dd.y))); } return r; }
void main() { vec2 b = boxUV(here()); int N = int(p_dvN + 0.5); if (N < 1) N = 3; float km2PerUnit2 = pow(40075.0 / 1920.0, 2.0); float unit = p_alanBiri < 0.5 ? 1e6 : p_alanBiri < 1.5 ? 1.0 : 100.0; float M = 1e-6; float vals[4];
  for (int i = 0; i < 4; i++) { vals[i] = p_dvN > 0.5 ? p_dv[i] * km2PerUnit2 * unit : (3.0 - float(i)) * 1000.0; if (i < N) M = max(M, vals[i]); }
  vec4 col = vec4(0.04, 0.06, 0.12, 0.85); for (int i = 0; i < 4; i++) { if (i >= N) break; float y0 = float(i) / float(N); float w = vals[i] / M * 0.6; if (b.y > y0 + 0.1 / float(N) && b.y < y0 + 0.8 / float(N) && b.x > 0.05 && b.x < 0.05 + w) col = vec4(hsv2rgb(vec3(float(i) * 0.17 + 0.55, 0.6, 0.95)), 1.0);
    if (p_alanEtik > 0.5) { int iv = int(vals[i] + 0.5); int nd = 1; int t = iv; for (int k = 0; k < 8; k++) { if (t < 10) break; t /= 10; nd++; } t = iv; vec2 lp = (b - vec2(0.1 + w, y0 + 0.45 / float(N))) * boxU() / (boxU().y / float(N) * 0.25); float nm = 0.0;
      for (int k = 0; k < 9; k++) { if (k >= nd) break; nm = max(nm, seg7(lp - vec2(float(nd - 1 - k) * 1.1, 0.0), t % 10)); t /= 10; } col = overPre(vec4(1.0) * nm, col); } }
  o = col; }
