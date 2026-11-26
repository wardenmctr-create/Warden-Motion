// measurearrow
uniform vec2 p_baslangiNokt, p_bitisNokt; uniform float p_olcum, p_birimBasiPiks, p_ondalikBasa, p_okKali, p_yaziBoyu; uniform vec3 c_renk;
float seg7(vec2 p, int d) { int m[10] = int[10](63, 6, 91, 79, 102, 109, 125, 7, 127, 111); int b = m[d % 10]; float r = 0.0;
  vec2 a[7] = vec2[7](vec2(0.0, 0.8), vec2(0.45, 0.4), vec2(0.45, -0.4), vec2(0.0, -0.8), vec2(-0.45, -0.4), vec2(-0.45, 0.4), vec2(0.0, 0.0));
  for (int i = 0; i < 7; i++) { if ((b / int(pow(2.0, float(i)))) % 2 == 0) continue; vec2 q = p - a[i]; bool hz = i == 0 || i == 3 || i == 6; vec2 e = hz ? vec2(0.34, 0.08) : vec2(0.08, 0.32); vec2 dd = abs(q) - e; r = max(r, 1.0 - smoothstep(0.0, 0.06, max(dd.x, dd.y))); } return r; }
float number(vec2 p, float v, int dec) { float r = 0.0; int iv = int(floor(v * pow(10.0, float(dec)) + 0.5)); int nd = 1; int t = iv; for (int i = 0; i < 8; i++) { if (t < 10) break; t /= 10; nd++; } nd = max(nd, dec + 1);
  float w = float(nd) + (dec > 0 ? 0.4 : 0.0); float x0 = -w * 0.55; t = iv;
  for (int i = 0; i < 9; i++) { if (i >= nd) break; int dgt = t % 10; t /= 10; float pos = float(nd - 1 - i) + (dec > 0 && nd - 1 - i >= nd - dec ? 0.4 : 0.0); r = max(r, seg7((p - vec2(x0 + pos * 1.1 + 0.5, 0.0)), dgt)); }
  if (dec > 0) r = max(r, 1.0 - smoothstep(0.08, 0.14, length(p - vec2(x0 + float(nd - dec) * 1.1 + 0.1, -0.8)))); return r; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 A = p_baslangiNokt, B = p_bitisNokt; if (p_olcum > 0.5 && p_olcum < 1.5) B.y = A.y; if (p_olcum > 1.5) B.x = A.x;
  vec2 ab = B - A; float L = length(ab); vec2 dir = ab / max(L, 1e-3); vec2 n = vec2(-dir.y, dir.x); vec2 l = vec2(dot(q - A, dir), dot(q - A, n)); float w = p_okKali * 0.5;
  float line = (1.0 - smoothstep(w, w + 0.8, abs(l.y))) * step(0.0, l.x) * step(l.x, L); float hs = w * 4.0 + 5.0;
  float head = step(abs(l.y), (l.x) * 0.45) * step(l.x, hs) + step(abs(l.y), (L - l.x) * 0.45) * step(L - hs, l.x); float ticks = (1.0 - smoothstep(w, w + 0.8, min(abs(l.x), abs(l.x - L)))) * step(abs(l.y), hs);
  float val = L * u_s / max(p_birimBasiPiks, 1e-3) / u_s; vec2 tp = (vec2(l.x - L * 0.5, -l.y - hs * 1.8)) / max(p_yaziBoyu * 0.5, 1.0); float txt = number(tp, val, int(clamp(p_ondalikBasa, 0.0, 3.0)));
  o = overPre(vec4(c_renk, 1.0) * clamp(max(max(line, head), max(ticks, txt)), 0.0, 1.0), s); }
