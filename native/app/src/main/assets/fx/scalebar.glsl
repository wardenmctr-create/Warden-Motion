// scalebar
uniform sampler2D s_harita; uniform float p_haritaOn, p_birim, p_hedefGeni;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float kmPerUnit = 40075.0 / max(boxU().x, 1.0); float target = p_hedefGeni * kmPerUnit; float unit = p_birim < 0.5 ? 1000.0 : p_birim < 1.5 ? 1.0 : 0.621371;
  float val = target * unit; float p10 = pow(10.0, floor(log(val) / log(10.0))); float nice = val / p10 < 2.0 ? p10 : val / p10 < 5.0 ? 2.0 * p10 : 5.0 * p10; float L = nice / unit / kmPerUnit;
  vec2 o0 = vec2(-boxU().x * 0.45, boxU().y * 0.4); vec2 lq = q - o0; float bar = step(0.0, lq.x) * step(lq.x, L) * step(abs(lq.y), 3.0); float seg = step(0.5, fract(lq.x / max(L / 4.0, 1.0) * 0.5)); float ticks = step(abs(lq.y + 3.0), 5.0) * (step(abs(lq.x), 1.0) + step(abs(lq.x - L), 1.0));
  vec3 c = mix(vec3(1.0), vec3(0.1), seg); vec4 col = overPre(vec4(c, 1.0) * bar, s); col = overPre(vec4(1.0) * clamp(ticks, 0.0, 1.0), col);
  int iv = int(nice + 0.5); float num = 0.0; int nd = 1; int t = iv; for (int i = 0; i < 6; i++) { if (t < 10) break; t /= 10; nd++; } t = iv;
  for (int i = 0; i < 7; i++) { if (i >= nd) break; vec2 lp = (lq - vec2(L + 14.0 + float(nd - 1 - i) * 11.0, 0.0)) / 9.0; int m[10] = int[10](63, 6, 91, 79, 102, 109, 125, 7, 127, 111); int bb = m[t % 10]; t /= 10;
    vec2 a[7] = vec2[7](vec2(0.0, 0.8), vec2(0.45, 0.4), vec2(0.45, -0.4), vec2(0.0, -0.8), vec2(-0.45, -0.4), vec2(-0.45, 0.4), vec2(0.0, 0.0)); for (int k = 0; k < 7; k++) { if ((bb / int(pow(2.0, float(k)))) % 2 == 0) continue; vec2 qq = lp - a[k]; bool hz = k == 0 || k == 3 || k == 6; vec2 e = hz ? vec2(0.34, 0.08) : vec2(0.08, 0.32); vec2 dd = abs(qq) - e; num = max(num, 1.0 - smoothstep(0.0, 0.08, max(dd.x, dd.y))); } }
  o = overPre(vec4(1.0) * num, col); }
