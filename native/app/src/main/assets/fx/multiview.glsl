// multiview
INCLUDE(_chart)
float cardA(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return texPx(boxPx(b)).a; }
float cardD(vec3 p, float th) { float d2 = (0.5 - cardA(p.xy)) * 6.0; vec2 w = vec2(d2, abs(p.z) - th * 0.5); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); }
uniform float p_duzen, p_bosluk, p_kameraEtik;
// Ön, yan, üst ve perspektif görünüm aynı karede: her bölmede kart küçük ışın izleyiciyle farklı açıdan
float cd(vec3 p) { return cardD(p, 20.0); }
vec4 view(vec2 uv, mat3 R) { vec2 B = boxU(); vec3 ro = R * vec3((uv - 0.5) * vec2(1.0, -1.0) * max(B.x, B.y) * 1.1, 400.0); vec3 rd = R * vec3(0.0, 0.0, -1.0); float t = 0.0;
  for (int i = 0; i < 64; i++) { vec3 p = ro + rd * t; float d = cd(p); if (d < 0.1) { vec2 e = vec2(0.5, 0.0); vec3 n = normalize(vec3(cd(p + e.xyy) - cd(p - e.xyy), cd(p + e.yxy) - cd(p - e.yxy), cd(p + e.yyx) - cd(p - e.yyx)));
      vec2 b = vec2(p.x, -p.y) / B + 0.5; vec4 c = texPx(boxPx(clamp(b, 0.0, 1.0))); vec3 col = c.a > 0.0 ? unpre(c) : vec3(0.8); float l = 0.45 + 0.55 * clamp(dot(n, normalize(vec3(0.4, 0.6, 0.8))), 0.0, 1.0); return vec4(col * l, 1.0); } t += d * 0.9; if (t > 900.0) break; }
  return vec4(0.08, 0.09, 0.12, 1.0); }
mat3 rotY(float a) { float c = cos(a), s2 = sin(a); return mat3(c, 0.0, -s2, 0.0, 1.0, 0.0, s2, 0.0, c); }
mat3 rotX(float a) { float c = cos(a), s2 = sin(a); return mat3(1.0, 0.0, 0.0, 0.0, c, s2, 0.0, -s2, c); }
void main() { vec2 b = boxUV(here()); float gap = p_bosluk * u_s / u_box.z; vec2 cell, f; float idx;
  if (p_duzen < 0.5) { cell = floor(b * 2.0); f = fract(b * 2.0); idx = cell.y * 2.0 + cell.x; } else { cell = vec2(floor(b.x * 4.0), 0.0); f = vec2(fract(b.x * 4.0), (b.y - 0.375) * 4.0); idx = cell.x; if (f.y < 0.0 || f.y > 1.0) { o = vec4(0.0); return; } }
  if (any(lessThan(f, vec2(gap))) || any(greaterThan(f, vec2(1.0 - gap)))) { o = vec4(0.0); return; } f = (f - gap) / (1.0 - 2.0 * gap);
  mat3 R = idx < 0.5 ? mat3(1.0) : (idx < 1.5 ? rotY(1.5708) : (idx < 2.5 ? rotX(-1.5708) : rotY(0.6) * rotX(-0.45))); vec4 c = view(f, R);
  if (p_kameraEtik > 0.5) { vec2 lp = (f - vec2(0.08, 0.1)) / vec2(0.05, 0.06); c = mix(c, vec4(1.0, 0.85, 0.3, 1.0), numAt(lp, idx + 1.0)); } o = c; }
