// chorddiagram
INCLUDE(_chart)
uniform float p_icYari, p_seritEgim, p_bosluk, p_etiketle;
// Grup yayları (satır toplamlarıyla orantılı, aralarında boşluk) ve gruplar arası şeritler (değerle orantılı genişlik, merkeze doğru eğik)
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = int(min(dR(), 8.0)); float R = p_icYari; float gap = radians(p_bosluk); float tot = 0.0; float rs[8];
  for (int i = 0; i < 8; i++) { rs[i] = 0.0; if (i >= N) break; for (int j = 0; j < 8; j++) { if (j >= N) break; rs[i] += abs(dat(float(i), float(min(j, int(dC()) - 1)))) ; } tot += rs[i]; }
  float span = 6.2832 - gap * float(N); float a0[8]; float acc = 0.0; for (int i = 0; i < 8; i++) { a0[i] = acc; if (i < N) acc += rs[i] / max(tot, 1e-6) * span + gap; }
  float r = length(q); float ang = mod(atan(q.y, q.x) + 6.2832, 6.2832); vec4 res = s; float aa = 1.0 / u_s;
  for (int i = 0; i < 8; i++) { if (i >= N) break; float a1 = a0[i] + rs[i] / max(tot, 1e-6) * span; vec3 c = serCol(float(i), vec3(0.2, 0.55, 1.0));
    float ring = step(R, r) * step(r, R * 1.08) * step(a0[i], ang) * step(ang, a1); res = mix(res, vec4(c, 1.0), ring);
    if (p_etiketle > 0.5) { float am = (a0[i] + a1) * 0.5; vec2 lp = (q - vec2(cos(am), sin(am)) * R * 1.18) / (R * 0.06); res = overPre(vec4(1.0) * numAt(lp, rs[i]), res); } }
  if (r < R) for (int i = 0; i < 8; i++) { if (i >= N) break; float ai = a0[i]; for (int j = 0; j < 8; j++) { if (j >= N || j == i) continue; float v = abs(dat(float(i), float(min(j, int(dC()) - 1)))); if (v <= 0.0) continue;
      float wi = v / max(tot, 1e-6) * span; float pa = ai + wi * 0.5; ai += wi; float pb = a0[j] + rs[j] / max(tot, 1e-6) * span * 0.5; vec2 A = vec2(cos(pa), sin(pa)) * R, B = vec2(cos(pb), sin(pb)) * R; vec2 C = (A + B) * 0.5 * (1.0 - p_seritEgim / 100.0);
      float d = 1e5; vec2 pv = A; for (int k = 1; k <= 12; k++) { float t = float(k) / 12.0; vec2 pt = mix(mix(A, C, t), mix(C, B, t), t); vec2 ab = pt - pv; float tt = clamp(dot(q - pv, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); d = min(d, length(q - pv - ab * tt)); pv = pt; }
      float w = max(wi * R * 0.5, 1.0); res = overPre(vec4(serCol(float(i), vec3(0.2, 0.55, 1.0)), 1.0) * (1.0 - smoothstep(w - aa, w + aa, d)) * 0.55, res); } }
  o = res; }
