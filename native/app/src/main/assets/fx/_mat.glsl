// Ortak malzeme kütüphanesi (Dokulandır, Kesim Altlığı, Karton Kukla). Shader "INCLUDE(_mat)" ile alır.
// Malzeme kimlikleri:
//  0 Düz renk  1 Kâğıt  2 Renkli kâğıt  3 Karton  4 Oluklu karton  5 Mukavva  6 Kraft kâğıt  7 Buruşturulmuş kâğıt
//  8 Yırtılmış kâğıt  9 Eski parşömen  10 Keçe  11 Kumaş / ince bez  12 Ahşap  13 Plastik  14 Metal  15 Çıkartma
// 16 Köpük  17 Özel doku  18 Tuval  19 Tuğla  20 Beton  21 Geri dönüşüm kâğıdı  22 Geçiş
// p: katman birimi (ölçek ve açı uygulanmış), sd: tohum, sp: malzemeye özel ayarlar (0..1),
// fib: lif belirginliği 0..1, cr: buruşukluk 0..1. Çıktı: doğal renk (rgb) + yükselti h (0..1)
vec3 matBase(int id) {
  if (id == 1) return vec3(0.96, 0.95, 0.92); if (id == 2) return vec3(0.95, 0.94, 0.92); if (id == 3) return vec3(0.79, 0.65, 0.48);
  if (id == 4) return vec3(0.76, 0.61, 0.42); if (id == 5) return vec3(0.66, 0.54, 0.41); if (id == 6) return vec3(0.72, 0.54, 0.35);
  if (id == 7) return vec3(0.93, 0.92, 0.89); if (id == 8) return vec3(0.95, 0.93, 0.9); if (id == 9) return vec3(0.9, 0.82, 0.62);
  if (id == 10) return vec3(0.6, 0.56, 0.53); if (id == 11) return vec3(0.85, 0.82, 0.76); if (id == 12) return vec3(0.69, 0.48, 0.27);
  if (id == 13) return vec3(0.9, 0.91, 0.93); if (id == 14) return vec3(0.72, 0.75, 0.78); if (id == 15) return vec3(1.0);
  if (id == 16) return vec3(0.95, 0.95, 0.94); if (id == 18) return vec3(0.91, 0.89, 0.83); if (id == 19) return vec3(0.65, 0.32, 0.23);
  if (id == 20) return vec3(0.6, 0.6, 0.59); if (id == 21) return vec3(0.81, 0.78, 0.71); return vec3(0.8);
}
float fibers(vec2 p, float sd) { // uzun, ince lifler
  vec2 q = vec2(p.x * 0.35, p.y * 2.2) + sd; return pow(abs(pnoise(q * 0.6) + pnoise(q * 1.3 + 7.0) * 0.5), 1.5); }
float crumple(vec2 p, float size, float sd) { vec4 v = voronoi(p / max(size, 1.0) + sd); vec4 w = voronoi(p / max(size * 0.45, 1.0) + sd + 3.1);
  return (v.y - v.x) * 0.7 + (w.y - w.x) * 0.3; }
vec4 matSample(int id, vec2 p, float sd, vec4 sp, float fib, float cr) {
  vec3 c = matBase(id); float h = 0.5; float g = hash1(floor(p * 2.0) + sd) - 0.5;
  if (id == 0 || id == 22) { h = 0.5; }
  else if (id == 1 || id == 2 || id == 21) { h = 0.5 + fbm(p / 18.0 + sd, 3.0) * 0.15 + g * 0.06 + fibers(p, sd) * 0.25 * fib; if (id == 21) { h += step(0.985, hash1(floor(p / 3.0) + sd)) * 0.3; c *= 1.0 - step(0.99, hash1(floor(p / 2.0) + sd + 5.0)) * 0.4; } }
  else if (id == 3) { h = 0.5 + fbm(p / 14.0 + sd, 4.0) * 0.25 + g * 0.08 + fibers(p, sd) * 0.3 * fib; c *= 0.94 + fbm(p / 40.0 + sd, 2.0) * 0.12; }
  else if (id == 4) { float w = max(sp.x * 30.0 + 4.0, 2.0); float a = sp.z * PI; vec2 r = mat2(cos(a), sin(a), -sin(a), cos(a)) * p;
    h = 0.5 + 0.5 * sin(r.x / w * TAU) * (0.3 + sp.y * 0.7) + fbm(p / 12.0 + sd, 3.0) * 0.15; c *= 0.93 + 0.07 * sin(r.x / w * TAU); }
  else if (id == 5) { h = 0.5 + fbm(p / 8.0 + sd, 5.0) * 0.35 + g * 0.15; c *= 0.9 + fbm(p / 30.0 + sd, 3.0) * 0.2; }
  else if (id == 6) { h = 0.5 + fbm(p / 16.0 + sd, 3.0) * 0.2 + fibers(p, sd) * 0.45 * max(fib, 0.3); c *= 0.92 + fibers(p * 0.5, sd) * 0.15; }
  else if (id == 7) { float sz = mix(15.0, 90.0, sp.x); h = 0.5 + (crumple(p, sz, sd) - 0.3) * mix(0.3, 1.2, sp.y) * mix(0.5, 1.5, sp.z) + g * 0.04; }
  else if (id == 8) { h = 0.5 + fbm(p / 16.0 + sd, 3.0) * 0.15 + fibers(p, sd) * 0.35 * fib; }
  else if (id == 9) { float age = sp.x, yel = sp.y, stain = sp.z; h = 0.5 + fbm(p / 20.0 + sd, 4.0) * 0.25;
    c = mix(c, vec3(0.82, 0.68, 0.4), yel * 0.6 * (0.5 + fbm(p / 60.0 + sd, 3.0))); c *= 1.0 - smoothstep(0.55, 0.9, fbm(p / 45.0 + sd + 9.0, 4.0) * 0.5 + 0.5) * stain * 0.5; c *= 1.0 - age * 0.15 * (fbm(p / 10.0, 3.0) * 0.5 + 0.5); }
  else if (id == 10) { float len = sp.x, den = sp.y; h = 0.5 + (hash1(floor(p * mix(1.0, 3.0, den)) + sd) - 0.5) * 0.35 + fbm(p / mix(3.0, 12.0, len) + sd, 3.0) * 0.3; }
  else if (id == 11 || id == 18) { float s = id == 18 ? 5.0 : 3.0; vec2 f = fract(p / s); vec2 cell = floor(p / s); float over = mod(cell.x + cell.y, 2.0);
    float th = mix(sin(f.x * PI), sin(f.y * PI), over); h = 0.35 + th * 0.4 + fbm(p / 25.0 + sd, 2.0) * 0.1; }
  else if (id == 12) { float w = mix(4.0, 20.0, sp.x); float a = sp.y * PI; vec2 r = mat2(cos(a), sin(a), -sin(a), cos(a)) * p;
    float ring = sin((r.y + fbm(r / vec2(80.0, 12.0) + sd, 3.0) * 25.0) / w * TAU); h = 0.5 + ring * 0.2 + fbm(r / vec2(60.0, 4.0) + sd, 3.0) * 0.15; c *= 0.82 + ring * 0.12 + fbm(r / vec2(90.0, 6.0), 2.0) * 0.1; }
  else if (id == 13) { h = 0.5 + fbm(p / 40.0 + sd, 2.0) * 0.05; }
  else if (id == 14) { h = 0.5 + fbm(vec2(p.x / 60.0, p.y * 2.0) + sd, 3.0) * 0.08 * (1.0 - sp.y * 0.5); c *= 0.85 + 0.3 * (0.5 + 0.5 * sin(p.y * 0.02 + fbm(p / 80.0, 2.0) * 3.0)); }
  else if (id == 15) { h = 0.5; c = vec3(1.0); }
  else if (id == 16) { vec4 v = voronoi(p / 6.0 + sd); h = 0.35 + smoothstep(0.0, 0.5, v.x) * 0.4 + fbm(p / 20.0, 2.0) * 0.1; c *= 0.95 + v.x * 0.08; }
  else if (id == 19) { vec2 b = p / vec2(40.0, 18.0); b.x += step(1.0, mod(floor(b.y), 2.0)) * 0.5; vec2 f = fract(b); float m = step(0.06, f.x) * step(0.1, f.y);
    h = 0.25 + 0.5 * m + fbm(p / 6.0 + sd, 3.0) * 0.15; c = mix(vec3(0.75, 0.73, 0.7), c * (0.85 + hash1(floor(b)) * 0.3), m); }
  else if (id == 20) { h = 0.5 + fbm(p / 6.0 + sd, 4.0) * 0.25 - step(0.96, hash1(floor(p / 2.5) + sd)) * 0.3; c *= 0.92 + fbm(p / 50.0 + sd, 2.0) * 0.12; }
  if (cr > 0.0 && id != 7) h += (crumple(p, 40.0, sd) - 0.3) * cr;
  return vec4(c, clamp(h, 0.0, 1.0));
}
// Yükseltiden aydınlatma çarpanı (ışık açısı derece, kabartma px)
float matLight(int id, vec2 p, float sd, vec4 sp, float fib, float cr, float bump, float ang) {
  float e = 1.0; float h0 = matSample(id, p, sd, sp, fib, cr).a; float hx = matSample(id, p + vec2(e, 0.0), sd, sp, fib, cr).a; float hy = matSample(id, p + vec2(0.0, e), sd, sp, fib, cr).a;
  vec3 n = normalize(vec3(-(hx - h0) * bump, -(hy - h0) * bump, 1.0)); float a = radians(ang); vec3 L = normalize(vec3(cos(a), sin(a), 0.9));
  return clamp(dot(n, L) / dot(vec3(0, 0, 1), L), 0.3, 1.7);
}
