// dice3d
INCLUDE(_3d)
uniform sampler2D s_herYuzIcin; uniform float p_herYuzIcinOn;
uniform float p_yuzSayi, p_buyukluk, p_koseYuva, p_kenarPahi, p_yuzGoru, p_noktaBuyu, p_noktaDeri, p_otomatikYuva, p_yuvarlanIler, p_sicramaYuks, p_sonYuz, p_tohum; uniform vec3 c_zarReng, c_isaretReng;
float Hs() { return max(p_buyukluk * 0.5, 2.0); }
float sdf(vec3 p) { float h = Hs(); float k = p_yuzSayi;
  if (k > 0.5 && k < 1.5 || k < 0.5 && false) {}
  if (k < 0.5) { return (max(abs(p.x + p.y) - p.z, abs(p.x - p.y) + p.z) - h * 0.55) / 1.732; }
  if (k < 1.5) { float r = min(p_koseYuva, h * 0.9); vec3 q = abs(p) - vec3(h - r); return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r; }
  if (k < 2.5) { vec3 a = abs(p); return (a.x + a.y + a.z - h * 1.3) * 0.577; }
  vec3 a = abs(p); const float G = 1.618034;
  if (k < 3.5) { vec3 n1 = normalize(vec3(0.0, 1.0, G)); vec3 n2 = n1.zxy, n3 = n1.yzx; return max(max(dot(a, n1), dot(a, n2)), dot(a, n3)) - h * 0.95; }
  vec3 m1 = normalize(vec3(1.0)), m2 = normalize(vec3(0.0, 1.0 / G, G)), m3 = m2.zxy, m4 = m2.yzx; return max(max(dot(a, m1), dot(a, m2)), max(dot(a, m3), dot(a, m4))) - h * 0.92; }
float seg7(vec2 p, int d) { // 7 segment rakam
  int m[10] = int[10](63, 6, 91, 79, 102, 109, 125, 7, 127, 111); int b = m[d]; float r = 0.0;
  vec2 a[7] = vec2[7](vec2(0.0, 0.8), vec2(0.45, 0.4), vec2(0.45, -0.4), vec2(0.0, -0.8), vec2(-0.45, -0.4), vec2(-0.45, 0.4), vec2(0.0, 0.0));
  for (int i = 0; i < 7; i++) { if ((b / int(pow(2.0, float(i)))) % 2 == 0) continue; vec2 q = p - a[i]; bool hz = i == 0 || i == 3 || i == 6; vec2 e = hz ? vec2(0.36, 0.09) : vec2(0.09, 0.34); vec2 dd = abs(q) - e; r = max(r, 1.0 - smoothstep(0.0, 0.04, max(dd.x, dd.y))); } return r; }
float digits(vec2 p, int v) { if (v < 10) return seg7(p * 1.2, v); return max(seg7((p - vec2(-0.5, 0.0)) * 1.2 * 1.6, v / 10), seg7((p - vec2(0.5, 0.0)) * 1.2 * 1.6, v % 10)); }
float pips(vec2 f, int v) { float r = p_noktaBuyu / 100.0 * 0.5; float acc = 0.0;
  for (int i = 0; i < 9; i++) { vec2 c = vec2(float(i % 3) - 1.0, float(i / 3) - 1.0) * 0.55; bool on = false; int k = i;
    if (v == 1) on = k == 4; else if (v == 2) on = k == 0 || k == 8; else if (v == 3) on = k == 0 || k == 4 || k == 8; else if (v == 4) on = k == 0 || k == 2 || k == 6 || k == 8;
    else if (v == 5) on = k == 0 || k == 2 || k == 4 || k == 6 || k == 8; else on = k == 0 || k == 2 || k == 3 || k == 5 || k == 6 || k == 8;
    if (on) acc = max(acc, 1.0 - smoothstep(r * 0.85, r, length(f - c))); } return acc; }
vec4 surf(vec3 p, vec3 n) { vec3 a = abs(n); vec2 f; int face;
  if (a.x > a.y && a.x > a.z) { f = p.zy / Hs(); face = n.x > 0.0 ? 3 : 4; } else if (a.y > a.z) { f = p.xz / Hs(); face = n.y > 0.0 ? 1 : 6; } else { f = p.xy / Hs(); face = n.z > 0.0 ? 2 : 5; }
  int maxF = p_yuzSayi < 0.5 ? 4 : p_yuzSayi < 1.5 ? 6 : p_yuzSayi < 2.5 ? 8 : p_yuzSayi < 3.5 ? 12 : 20;
  if (p_yuzSayi > 1.5 || p_yuzSayi < 0.5) { vec3 d = normalize(p); face = 1 + int(mod(floor((atan(d.x, d.z) / TAU + 0.5) * 5.0) + floor((d.y * 0.5 + 0.5) * 4.0) * 5.0, float(maxF))); f = vec2(0.0); vec3 t = normalize(cross(n, vec3(0.0, 1.0, 0.01))); f = vec2(dot(p - n * dot(p, n), t), dot(p - n * dot(p, n), cross(n, t))) / Hs() * 1.6; }
  float mark = 0.0; if (p_yuzGoru < 0.5 && maxF == 6) mark = pips(f, face); else if (p_yuzGoru < 1.5 || maxF != 6) mark = digits(f * 1.2, face);
  vec3 c = c_zarReng; if (p_yuzGoru > 1.5 && p_herYuzIcinOn > 0.5 && maxF == 6) { vec2 uv = (f * 0.5 + 0.5); uv.x = (uv.x + float(face - 1)) / 6.0; c = unpre(texture(s_herYuzIcin, clamp(uv, 0.0, 1.0))); mark = 0.0; }
  c = mix(c, c_isaretReng, mark); c *= 1.0 - mark * p_noktaDeri / 20.0 * 0.3; return vec4(c, 1.0); }
void main() { vec3 ex = vec3(0.0); if (p_otomatikYuva > 0.5) { float k = clamp(p_yuvarlanIler / 100.0, 0.0, 1.0); float e = 1.0 - pow(1.0 - k, 3.0); vec2 h = hash2(vec2(seedf(p_tohum), 3.0));
    ex = vec3(720.0 + h.x * 360.0, 540.0 + h.y * 360.0, 90.0) * (1.0 - e); }
  vec4 c = render3d(ex);
  o = c; }
