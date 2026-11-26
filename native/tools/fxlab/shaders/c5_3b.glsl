// 3B şekiller (rehber: şeklin kendi ayarları + Ortak 3B grubu). Birim: katman birimi (px). Nesne uzayı y yukarı.
//== cube
INCLUDE(_3d)
uniform float p_boyut, p_kosePahi, p_yuzDoku, p_dokuDose, p_arkaYuz;
float sdf(vec3 p) { vec3 b = vec3(max(p_boyut, 2.0) * 0.5); float r = min(p_kosePahi, b.x); vec3 q = abs(p) - b + r; return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r; }
vec4 surf(vec3 p, vec3 n) { vec2 uv = boxMapUV(p, n, vec3(max(p_boyut, 2.0) * 0.5)); uv = fract((uv - 0.5) * p_dokuDose / 100.0 + 0.5); vec4 c = layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), max(c.a, 0.999)); }
void main() { o = render3d(vec3(0.0)); }
//== sphere
INCLUDE(_3d)
uniform float p_yaricap, p_yatayDokuAcis, p_dikeyDokuAcis, p_dokuEsle, p_segment;
float sdf(vec3 p) { return length(p) - max(p_yaricap, 1.0); }
vec4 surf(vec3 p, vec3 n) { vec2 uv = p_dokuEsle < 0.5 ? vec2(atan(p.x, p.z) / TAU + 0.5 + p_yatayDokuAcis / 360.0, acos(clamp(-p.y / max(p_yaricap, 1.0), -1.0, 1.0)) / PI * -1.0 + 1.0 + p_dikeyDokuAcis / 180.0) : vec2(p.x, -p.y) / (2.0 * max(p_yaricap, 1.0)) + 0.5;
  uv.x = fract(uv.x); uv.y = 1.0 - uv.y; vec4 c = layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== cylinder
INCLUDE(_3d)
uniform float p_yaricap, p_yuksekli, p_dokuSariAcis, p_ustKapa, p_altKapa, p_segment; uniform vec3 c_kapakReng;
float sdf(vec3 p) { vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(max(p_yaricap, 1.0), max(p_yuksekli, 1.0) * 0.5); return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)); }
vec4 surf(vec3 p, vec3 n) { if (abs(n.y) > 0.7) { bool top = n.y > 0.0; if ((top && p_ustKapa < 0.5) || (!top && p_altKapa < 0.5)) return vec4(c_kapakReng * 0.4, 1.0); return vec4(c_kapakReng, 1.0); }
  float u = (atan(p.x, p.z) / TAU + 0.5) * 360.0 / max(abs(p_dokuSariAcis), 1.0); vec4 c = layerAt(vec2(fract(u), 0.5 - p.y / max(p_yuksekli, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== cone
INCLUDE(_3d)
uniform float p_tabanYari, p_ustYari, p_yuksekli, p_tabanKapa, p_segment; uniform vec3 c_kapakReng;
float sdf(vec3 p) { float h = max(p_yuksekli, 1.0) * 0.5; float r1 = max(p_tabanYari, 0.5), r2 = max(p_ustYari, 0.0);
  vec2 q = vec2(length(p.xz), p.y); vec2 k1 = vec2(r2, h), k2 = vec2(r2 - r1, 2.0 * h); vec2 ca = vec2(q.x - min(q.x, q.y < 0.0 ? r1 : r2), abs(q.y) - h);
  vec2 cb = q - k1 + k2 * clamp(dot(k1 - q, k2) / dot(k2, k2), 0.0, 1.0); float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0; return s * sqrt(min(dot(ca, ca), dot(cb, cb))); }
vec4 surf(vec3 p, vec3 n) { if (n.y < -0.8) return vec4(c_kapakReng * (p_tabanKapa > 0.5 ? 1.0 : 0.4), 1.0);
  vec4 c = layerAt(vec2(atan(p.x, p.z) / TAU + 0.5, 0.5 - p.y / max(p_yuksekli, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== pyramid
INCLUDE(_3d)
uniform float p_tabanGeni, p_yuksekli, p_kenarSayi, p_tabanKapa, p_dokuYonu;
float sdf(vec3 p) { float n = clamp(floor(p_kenarSayi), 3.0, 12.0); float h = max(p_yuksekli, 1.0); float r = max(p_tabanGeni, 1.0) * 0.5 * cos(PI / n); float y = p.y + h * 0.5;
  float a = atan(p.z, p.x); float seg = TAU / n; float c = floor(a / seg + 0.5) * seg; float x = cos(c) * p.x + sin(c) * p.z;
  vec2 nn = normalize(vec2(h, r)); float side = dot(vec2(x, y) - vec2(r, 0.0), nn); return max(side, -y) * 0.8; }
vec4 surf(vec3 p, vec3 n) { if (n.y < -0.8) return vec4(vec3(0.8) * (p_tabanKapa > 0.5 ? 1.0 : 0.4), 1.0);
  vec2 uv = rot2(p_dokuYonu) * (vec2(p.x, p.z) / max(p_tabanGeni, 1.0)) + 0.5; uv.y = mix(uv.y, 0.5 - p.y / max(p_yuksekli, 1.0), 0.6); vec4 c = layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== octahedron
INCLUDE(_3d)
uniform float p_boyut, p_yatayOran, p_dikeyOran, p_yuzCizg; uniform vec3 c_yuzReng;
float sdf(vec3 p) { vec3 s = vec3(p_yatayOran, p_dikeyOran, p_yatayOran); vec3 q = abs(p / s); float r = max(p_boyut, 1.0) * 0.5; return (q.x + q.y + q.z - r) * 0.57735 * min(s.x, s.y); }
vec4 surf(vec3 p, vec3 n) { vec2 uv = vec2(p.x, -p.y) / max(p_boyut, 1.0) + 0.5; vec4 c = layerAt(uv); vec3 col = (c.a > 0.0 ? c.rgb / c.a : vec3(1.0)) * c_yuzReng;
  if (p_yuzCizg > 0.5) { vec3 a = abs(p) / max(p_boyut * 0.5, 1.0); float e = min(a.x, min(a.y, a.z)); col *= mix(0.3, 1.0, smoothstep(0.0, 0.03, e)); } return vec4(col, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== hexprism
INCLUDE(_3d)
uniform float p_yaricap, p_yuksekli, p_kapaklar, p_kenarPahi; uniform vec3 c_kapakReng;
float sdf(vec3 p) { vec3 k = vec3(-0.8660254, 0.5, 0.57735); vec3 q = abs(p.xzy); vec2 h = vec2(max(p_yaricap, 1.0) * 0.866, max(p_yuksekli, 1.0) * 0.5);
  q.xy -= 2.0 * min(dot(k.xy, q.xy), 0.0) * k.xy; vec2 d = vec2(length(q.xy - vec2(clamp(q.x, -k.z * h.x, k.z * h.x), h.x)) * sign(q.y - h.x), q.z - h.y); return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - p_kenarPahi * 0.3; }
vec4 surf(vec3 p, vec3 n) { if (abs(n.y) > 0.8) return vec4(p_kapaklar > 0.5 ? c_kapakReng : vec3(0.3), 1.0); vec4 c = layerAt(vec2(atan(p.x, p.z) / TAU + 0.5, 0.5 - p.y / max(p_yuksekli, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== torus
INCLUDE(_3d)
uniform float p_anaYari, p_tupYari, p_halkaAcis, p_segment, p_tupSegm;
float sdf(vec3 p) { vec2 q = vec2(length(p.xz) - max(p_anaYari, 1.0), p.y); float d = length(q) - max(p_tupYari, 0.5);
  if (abs(p_halkaAcis) < 359.0) { float a = degrees(atan(p.z, p.x)) + 180.0; float lim = abs(p_halkaAcis); if (a > lim) { float a1 = radians(lim - 180.0); vec3 e1 = vec3(cos(a1), 0.0, sin(a1)) * p_anaYari; vec3 e0 = vec3(-p_anaYari, 0.0, 0.0); d = max(d, -min(length(p - e1), length(p - e0)) + p_tupYari * 1.0); d = min(length(p - e1), length(p - e0)) - p_tupYari; } }
  return d; }
vec4 surf(vec3 p, vec3 n) { float u = atan(p.z, p.x) / TAU + 0.5; vec2 q = vec2(length(p.xz) - p_anaYari, p.y); float v = atan(q.y, q.x) / TAU + 0.5; vec4 c = layerAt(vec2(fract(u * 2.0), v)); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== heart3d
INCLUDE(_3d)
uniform float p_genislik, p_yuksekli, p_derinlik, p_kenarYuva, p_dokuOlce;
float sdf(vec3 p) { vec2 s = vec2(max(p_genislik, 1.0), max(p_yuksekli, 1.0)) * 0.5; vec2 q = vec2(p.x, -p.y) / s; float d2 = heartSDF(q) * min(s.x, s.y);
  float r = min(p_kenarYuva, p_derinlik * 0.5); vec2 w = vec2(d2 + r, abs(p.z) - max(p_derinlik, 1.0) * 0.5 + r); return (min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - r) * 0.7; }
vec4 surf(vec3 p, vec3 n) { vec2 uv = (vec2(p.x, -p.y) / vec2(max(p_genislik, 1.0), max(p_yuksekli, 1.0))) / max(p_dokuOlce / 100.0, 0.01) + 0.5; vec4 c = layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.9, 0.2, 0.3), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== starprism
INCLUDE(_3d)
uniform float p_disYari, p_icYari, p_ucSayi, p_kalinlik, p_kenarPahi, p_kapaklar;
float star2(vec2 p) { float n = clamp(floor(p_ucSayi), 3.0, 20.0); float r1 = max(p_disYari, 1.0), r2 = clamp(p_icYari, 0.5, r1); float an = PI / n; float a = atan(p.x, p.y); float bn = mod(a, 2.0 * an) - an;
  p = length(p) * vec2(cos(bn), abs(sin(bn))); vec2 A = vec2(r1, 0.0), Bq = vec2(r2 * cos(an), r2 * sin(an)); vec2 e = Bq - A; vec2 w = p - A; vec2 b = w - e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
  return length(b) * sign(e.x * w.y - e.y * w.x) * -1.0; }
float sdf(vec3 p) { float r = p_kenarPahi; vec2 w = vec2(star2(p.xy) + r, abs(p.z) - max(p_kalinlik, 1.0) * 0.5 + r); return (min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - r) * 0.8; }
vec4 surf(vec3 p, vec3 n) { vec4 c = layerAt(vec2(p.x, -p.y) / (2.0 * max(p_disYari, 1.0)) + 0.5); vec3 col = c.a > 0.0 ? c.rgb / c.a : vec3(0.95, 0.8, 0.2); if (abs(n.z) < 0.6) col *= 0.75; return vec4(col, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== capsule
INCLUDE(_3d)
uniform float p_yaricap, p_govdeUzun, p_ucYuva, p_segment, p_dokuSari;
float sdf(vec3 p) { float h = max(p_govdeUzun, 0.0) * 0.5; vec3 q = p; q.y -= clamp(q.y, -h, h); return length(q * vec3(1.0, 1.0 / max(p_ucYuva / 100.0, 0.05), 1.0)) * mix(0.6, 1.0, p_ucYuva / 100.0) - max(p_yaricap, 1.0) * mix(0.6, 1.0, p_ucYuva / 100.0); }
vec4 surf(vec3 p, vec3 n) { float H = max(p_govdeUzun, 0.0) + 2.0 * p_yaricap; vec4 c = layerAt(vec2(atan(p.x, p.z) / TAU + 0.5, 0.5 - p.y / max(H, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== extrude
INCLUDE(_3d)
uniform float p_derinlik, p_pah, p_kaynakDokuYanl, p_onYuz; uniform vec3 c_yanYuzReng, c_arkaYuzReng;
float aAt(vec2 xy) { vec2 b = vec2(xy.x, -xy.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; return texPx(boxPx(b)).a; }
float sdf(vec3 p) { float a = aAt(p.xy); float d2 = (0.5 - a) * 6.0; vec2 w = vec2(d2, abs(p.z) - max(p_derinlik, 1.0) * 0.5); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)); }
vec4 surf(vec3 p, vec3 n) { vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; vec4 c = layerAt(b); vec3 col = c.a > 0.0 ? c.rgb / c.a : c_yanYuzReng;
  if (n.z > 0.7) return vec4(p_onYuz > 0.5 ? col : c_yanYuzReng, 1.0); if (n.z < -0.7) return vec4(c_arkaYuzReng, 1.0); return vec4(p_kaynakDokuYanl > 0.5 ? col * 0.8 : c_yanYuzReng, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== tetra
INCLUDE(_3d)
uniform float p_boyut, p_yuksekliOran, p_yuzDoku, p_kenarCizg;
float sdf(vec3 p) { float s = max(p_boyut, 1.0) * 0.35; p.y /= max(p_yuksekliOran, 0.1); return (max(abs(p.x + p.y) - p.z, abs(p.x - p.y) + p.z) - s) * 0.57735 * min(1.0, p_yuksekliOran); }
vec4 surf(vec3 p, vec3 n) { vec4 c = layerAt(vec2(p.x, -p.y) / max(p_boyut, 1.0) + 0.5 + n.xy * 0.1); vec3 col = c.a > 0.0 ? c.rgb / c.a : vec3(0.85);
  if (p_kenarCizg > 0.5) { float e = abs(sdf(p + n * 2.0)); col *= 1.0; } return vec4(col, 1.0); }
void main() { o = render3d(vec3(35.0, 25.0, 0.0)); }
//== icosa
INCLUDE(_3d)
uniform float p_yaricap, p_altBolm, p_duzYuze, p_dokuEsle;
float sdf(vec3 p) { float r = max(p_yaricap, 1.0); if (p_altBolm > 2.5 && p_duzYuze < 0.5) return length(p) - r;
  const float G = 1.618034; vec3 n1 = normalize(vec3(G, 1.0 / G, 0.0)), n2 = normalize(vec3(1.0)); vec3 q = abs(p);
  float d = max(max(max(dot(q, n1.xyz), dot(q, n1.yzx)), max(dot(q, n1.zxy), dot(q, n2))), 0.0) - r * 0.85;
  return mix(d, length(p) - r, clamp(p_altBolm / 4.0, 0.0, 1.0)); }
vec4 surf(vec3 p, vec3 n) { vec2 uv = p_dokuEsle < 0.5 ? vec2(atan(p.x, p.z) / TAU + 0.5, 0.5 - p.y / (2.0 * max(p_yaricap, 1.0))) : fract(n.xy * 2.0 + 0.5); vec4 c = layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== box3d
INCLUDE(_3d)
uniform sampler2D s_yuzKatm; uniform float p_yuzKatmOn; uniform float p_en, p_boy, p_derinlik, p_pah, p_oranlariBagl;
vec3 hs() { return vec3(max(p_en, 1.0), max(p_oranlariBagl > 0.5 ? p_en : p_boy, 1.0), max(p_oranlariBagl > 0.5 ? p_en : p_derinlik, 1.0)) * 0.5; }
float sdf(vec3 p) { vec3 b = hs(); float r = min(p_pah, min(b.x, min(b.y, b.z))); vec3 q = abs(p) - b + r; return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r; }
vec4 surf(vec3 p, vec3 n) { vec2 uv = boxMapUV(p, n, hs()); vec4 c = (p_yuzKatmOn > 0.5 && abs(n.z) < 0.7) ? texture(s_yuzKatm, clamp(uv, 0.0, 1.0)) : layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== ellipsoid
INCLUDE(_3d)
uniform float p_xYari, p_yYari, p_zYari, p_oranlariBagl, p_segment;
vec3 rr() { return p_oranlariBagl > 0.5 ? vec3(max(p_xYari, 1.0)) : max(vec3(p_xYari, p_yYari, p_zYari), vec3(1.0)); }
float sdf(vec3 p) { vec3 r = rr(); float k0 = length(p / r); float k1 = length(p / (r * r)); return k0 * (k0 - 1.0) / max(k1, 1e-5); }
vec4 surf(vec3 p, vec3 n) { vec3 q = p / rr(); vec4 c = layerAt(vec2(atan(q.x, q.z) / TAU + 0.5, acos(clamp(q.y, -1.0, 1.0)) / PI)); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== hollowbox
INCLUDE(_3d)
uniform float p_en, p_boy, p_derinlik, p_duvarKali, p_acikYuz; uniform vec3 c_icYuzReng;
float sdBox(vec3 p, vec3 b) { vec3 q = abs(p) - b; return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0); }
vec3 hs() { return vec3(max(p_en, 2.0), max(p_boy, 2.0), max(p_derinlik, 2.0)) * 0.5; }
float sdf(vec3 p) { vec3 b = hs(); float w = clamp(p_duvarKali, 0.5, min(b.x, min(b.y, b.z)) * 0.9); float outer = sdBox(p, b); vec3 off = vec3(0.0);
  int f = int(p_acikYuz + 0.5); vec3 dir = f == 0 ? vec3(0, 1, 0) : f == 1 ? vec3(0, -1, 0) : f == 2 ? vec3(0, 0, 1) : f == 3 ? vec3(0, 0, -1) : f == 4 ? vec3(-1, 0, 0) : vec3(1, 0, 0);
  float inner = sdBox(p - dir * w, b - w + abs(dir) * w); return max(outer, -inner); }
vec4 surf(vec3 p, vec3 n) { vec3 b = hs(); bool inside = all(lessThan(abs(p), b - p_duvarKali * 0.9)); if (inside) return vec4(c_icYuzReng, 1.0);
  vec4 c = layerAt(boxMapUV(p, n, b)); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(25.0, 30.0, 0.0)); }
//== ring3d
INCLUDE(_3d)
uniform float p_disYari, p_icYari, p_kalinlik, p_yayAcis, p_pah, p_segment;
float sdf(vec3 p) { float ro = max(p_disYari, 1.0), ri = clamp(p_icYari, 0.0, ro - 0.5); float r = length(p.xz); vec2 d = vec2(max(r - ro, ri - r), abs(p.y) - max(p_kalinlik, 1.0) * 0.5);
  float s = min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - p_pah * 0.3;
  if (abs(p_yayAcis) < 359.0) { float a = degrees(atan(p.z, p.x)) + 180.0; if (a > abs(p_yayAcis)) s = max(s, 2.0); } return s; }
vec4 surf(vec3 p, vec3 n) { float u = atan(p.z, p.x) / TAU + 0.5; float v = (length(p.xz) - p_icYari) / max(p_disYari - p_icYari, 1.0); vec4 c = layerAt(vec2(u, abs(n.y) > 0.7 ? v : 0.5 - p.y / max(p_kalinlik, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.9, 0.75, 0.3), 1.0); }
void main() { o = render3d(vec3(60.0, 0.0, 0.0)); }
//== starpoly
INCLUDE(_3d)
uniform float p_yaricap, p_sivrilik, p_bicim, p_yuzCizg;
float sdTet(vec3 p, float s) { return (max(abs(p.x + p.y) - p.z, abs(p.x - p.y) + p.z) - s) * 0.57735; }
float sdf(vec3 p) { float s = max(p_yaricap, 1.0) * 0.45 * p_sivrilik / 1.6; float d = min(sdTet(p, s), sdTet(vec3(p.x, -p.y, -p.z) * vec3(1.0, 1.0, 1.0), s));
  if (p_bicim > 0.5) { float d2 = min(sdTet(p.yzx, s), sdTet(vec3(p.y, -p.z, -p.x), s)); d = min(d, d2); } return d; }
vec4 surf(vec3 p, vec3 n) { vec4 c = layerAt(vec2(p.x, -p.y) / (2.0 * max(p_yaricap, 1.0)) + 0.5); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.95, 0.85, 0.3), 1.0); }
void main() { o = render3d(vec3(20.0, 30.0, 0.0)); }
//== cross3
INCLUDE(_3d)
uniform float p_kolUzun, p_kolKali, p_xKolu, p_yKolu, p_zKolu, p_kosePahi;
float rb(vec3 p, vec3 b, float r) { vec3 q = abs(p) - b + r; return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r; }
float sdf(vec3 p) { float L = max(p_kolUzun, 1.0) * 0.5, w = max(p_kolKali, 1.0) * 0.5, r = min(p_kosePahi, w); float d = 1e5;
  if (p_xKolu > 0.5) d = min(d, rb(p, vec3(L, w, w), r)); if (p_yKolu > 0.5) d = min(d, rb(p, vec3(w, L, w), r)); if (p_zKolu > 0.5) d = min(d, rb(p, vec3(w, w, L), r)); return d; }
vec4 surf(vec3 p, vec3 n) { vec4 c = layerAt(boxMapUV(p, n, vec3(max(p_kolUzun, 1.0) * 0.5))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(25.0, 35.0, 0.0)); }
//== triprism
INCLUDE(_3d)
uniform float p_tabanGeni, p_ucgenYuks, p_derinlik, p_kapaklar, p_pah;
float sdf(vec3 p) { float w = max(p_tabanGeni, 1.0) * 0.5, h = max(p_ucgenYuks, 1.0); vec2 q = vec2(abs(p.x), p.y + h / 3.0);
  vec2 nn = normalize(vec2(h, w)); float tri = max(dot(q - vec2(w, 0.0), nn), -q.y); vec2 d = vec2(tri, abs(p.z) - max(p_derinlik, 1.0) * 0.5); return (min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - p_pah * 0.3) * 0.9; }
vec4 surf(vec3 p, vec3 n) { if (abs(n.z) > 0.8) return vec4(vec3(p_kapaklar > 0.5 ? 0.9 : 0.35), 1.0); vec4 c = layerAt(vec2(p.z / max(p_derinlik, 1.0) + 0.5, 0.5 - p.y / max(p_ucgenYuks, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0, 35.0, 0.0)); }
//== flip3d
INCLUDE(_3d)
uniform float p_donusX, p_donusY, p_donusZ, p_arkaYuzuGost; uniform vec2 p_dayanak; uniform vec3 c_arkaYuzReng;
float sdf(vec3 p) { return 1e5; } vec4 surf(vec3 p, vec3 n) { return vec4(0.0); }
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float F = max(B.x, B.y) * 0.5 / tan(radians(clamp(p_gorusAcis, 10.0, 120.0)) * 0.5) * mix(3.0, 1.0, clamp(p_perspekt < 0.5 ? 1.0 : 0.0, 0.0, 1.0));
  vec3 piv = vec3(p_dayanak.x, -p_dayanak.y, 0.0);
  vec3 ro = p_perspekt < 0.5 ? vec3(0.0, 0.0, F) : vec3(q.x, -q.y, F); vec3 rd = p_perspekt < 0.5 ? normalize(vec3(q.x, -q.y, -F)) : vec3(0.0, 0.0, -1.0);
  mat3 R = rotXYZ(vec3(p_donusX, p_donusY, p_donusZ) + p_yonelimXY + p_surekliDonuX * u_t); mat3 Ri = transpose(R); vec3 T = vec3(p_konumXY.x, -p_konumXY.y, -p_konumXY.z);
  vec3 o2 = Ri * (ro - T - piv) + piv, d2 = Ri * rd;
  if (abs(d2.z) < 1e-5) { o = vec4(0.0); return; } float t = -o2.z / d2.z; if (t < 0.0) { o = vec4(0.0); return; }
  vec3 p = o2 + d2 * t; vec2 b = vec2(p.x, -p.y) / B + 0.5;
  if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = vec4(0.0); return; }
  vec4 c = layerAt(b); bool back = d2.z > 0.0;
  if (back) { if (p_arkaYuzuGost < 0.5) { o = vec4(0.0); return; } c = vec4(c_arkaYuzReng, 1.0) * c.a; }
  vec3 n = vec3(0.0, 0.0, back ? -1.0 : 1.0); vec3 col = c.a > 0.0 ? c.rgb / c.a : vec3(0.0); col = shade(col, p, n, d2, Ri);
  o = vec4(clamp(col, 0.0, 1.0) * c.a, c.a);
}
//== fold3d
INCLUDE(_3d)
uniform vec2 p_katCizgBasl, p_katCizgSonu; uniform float p_katAcis, p_katYari, p_golge, p_arkaYuzuGost; uniform vec3 c_arkaYuzReng;
float sdf(vec3 p) { return 1e5; } vec4 surf(vec3 p, vec3 n) { return vec4(0.0); }
void main() {
  // Katlama: çizginin sağ tarafı çizgi etrafında katAcis kadar döner (ekrana doğru)
  vec2 q = toUnit(here()); vec2 A = p_katCizgBasl, Bp = p_katCizgSonu; vec2 d = normalize(Bp - A + 1e-5); vec2 n = vec2(-d.y, d.x);
  float s = dot(q - A, n); vec2 B = boxU();
  vec4 base = vec4(0.0);
  if (s <= 0.0) base = layerAt(q / B * vec2(1.0) + 0.5);
  // katlanan kanat: düzlemde iz düşüm kısalır (cos), ve arka yüz görünür (açı > 90)
  float a = radians(p_katAcis); float c = cos(a);
  if (s > 0.0 || c < 0.0) {
    float sp = s / max(abs(c), 0.02); vec2 src = q - n * s + n * sp * sign(c == 0.0 ? 1.0 : c);
    if (c < 0.0) src = q - n * s - n * s / max(abs(c), 0.02);
    vec2 bb = src / B + 0.5; bool ok = all(greaterThanEqual(bb, vec2(0.0))) && all(lessThanEqual(bb, vec2(1.0))) && dot(src - A, n) >= 0.0;
    if (ok) { vec4 f = layerAt(bb); vec3 col = f.a > 0.0 ? f.rgb / f.a : vec3(0.0);
      if (c < 0.0) col = p_arkaYuzuGost > 0.5 ? c_arkaYuzReng : col; col *= mix(1.0, 0.55 + 0.45 * abs(c), p_golge / 100.0);
      vec4 w = vec4(col * f.a, f.a); base = c < 0.0 ? overPre(w, base) : w; }
  }
  o = base;
}
//== tunnel
INCLUDE(_3d)
uniform float p_tunelYari, p_tunelUzun, p_ilerleme, p_hiz, p_kameraAcis, p_dokuTekr, p_segment, p_sis;
float sdf(vec3 p) { return 1e5; } vec4 surf(vec3 p, vec3 n) { return vec4(0.0); }
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float F = max(B.x, B.y) * 0.5 / tan(radians(clamp(p_gorusAcis, 10.0, 120.0)) * 0.5);
  vec3 rd = normalize(vec3(q.x, -q.y, -F)); rd = rotXYZ(p_yonelimXY + vec3(0.0, 0.0, p_kameraAcis) + p_surekliDonuX * u_t) * rd;
  float r = max(p_tunelYari, 1.0); float t = r / max(length(rd.xy), 1e-4); vec3 p = rd * t;
  float z = -p.z + p_ilerleme + u_t * p_hiz; float ang = atan(p.y, p.x);
  vec2 uv = vec2(fract(ang / TAU * max(1.0, floor(p_dokuTekr * 0.5))), fract(z / max(p_tunelUzun, 1.0) * p_dokuTekr));
  vec4 c = layerAt(uv); vec3 col = c.a > 0.0 ? c.rgb / c.a : vec3(0.2);
  float fog = p_sis > 0.5 ? exp(-t / (r * 6.0)) : exp(-t / (r * 30.0)); col *= fog;
  o = vec4(col, 1.0);
}
