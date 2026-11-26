// gantt
INCLUDE(_chart)
uniform float p_satirYuks, p_ilerleme, p_bagimlilCizg;
// Satır: başlangıç, bitiş, [bağlı olduğu satır no] → çubuklar; zaman ekseni ilerlemeyle açılır; bağımlılık okları
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); int N = int(min(dR(), 24.0)); float t0 = 1e9, t1 = -1e9; for (int r = 0; r < 24; r++) { if (r >= N) break; t0 = min(t0, dat(float(r), 0.0)); t1 = max(t1, dat(float(r), 1.0)); }
  float span = max(t1 - t0, 1e-6); float H = p_satirYuks * u_s / u_box.w; float now = t0 + span * p_ilerleme / 100.0; vec4 res = s;
  float xn = 0.08 + (now - t0) / span * 0.86; res = overPre(vec4(1.0, 0.3, 0.3, 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.z, abs(b.x - xn))) * 0.8, res);
  int r = int(floor((b.y - 0.06) / H)); if (r >= 0 && r < N) { float fy = fract((b.y - 0.06) / H); float a = dat(float(r), 0.0), e = min(dat(float(r), 1.0), now); float xa = 0.08 + (a - t0) / span * 0.86, xe = 0.08 + (e - t0) / span * 0.86;
    if (fy > 0.18 && fy < 0.82 && b.x >= xa && b.x <= xe) res = vec4(serCol(float(r), vec3(0.25, 0.55, 1.0)), 1.0); }
  if (p_bagimlilCizg > 0.5 && dC() > 2.5) for (int i = 0; i < 24; i++) { if (i >= N) break; float dep = dat(float(i), 2.0) - 1.0; if (dep < 0.0 || dep >= float(N) || dep == float(i)) continue; float xe = 0.08 + (dat(dep, 1.0) - t0) / span * 0.86, xs = 0.08 + (dat(float(i), 0.0) - t0) / span * 0.86;
    float ye = 0.06 + (dep + 0.5) * H, ys = 0.06 + (float(i) + 0.5) * H; float vline = step(abs(b.x - xe), 1.0 / u_box.z) * step(min(ye, ys), b.y) * step(b.y, max(ye, ys)); float hline = step(abs(b.y - ys), 1.0 / u_box.w) * step(min(xe, xs), b.x) * step(b.x, max(xe, xs));
    res = overPre(vec4(vec3(0.85), 1.0) * max(vline, hline), res); }
  o = res; }
