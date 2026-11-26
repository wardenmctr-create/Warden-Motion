// 800 rehberi, bölüm 8: katman kartı üzerinde 3B geometri işlemleri
//== thicken3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_duvar, p_ofset, p_acikKenaKapa;
float sdf(vec3 p) { float d = cardD(p - vec3(0.0, 0.0, p_ofset), max(p_duvar, 0.5) * 2.0); if (p_acikKenaKapa < 0.5) d = max(d, -cardD(p - vec3(0.0, 0.0, p_ofset), max(p_duvar - 2.0, 0.1) * 2.0) + 0.0); return d; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== spikes3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_uzunluk, p_yogunluk, p_normalYonu;
float sdf(vec3 p) { float base = cardD(p, 12.0); float cs = mix(40.0, 8.0, p_yogunluk / 100.0); vec2 id = floor(p.xy / cs); vec2 c = (id + 0.5) * cs; float on = step(0.5, cardA(c)); if (on < 0.5) return base;
  vec3 q = p - vec3(c, 6.0); float h = p_uzunluk; float side = p_normalYonu > 0.5 ? 1.0 : sign(p.z + 1e-4); q.z *= side; float t = clamp(q.z / max(h, 1.0), 0.0, 1.0); float cone = max(length(q.xy) - cs * 0.3 * (1.0 - t), -q.z); cone = max(cone, q.z - h);
  return min(base, cone * 0.7); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== explodefaces
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_ayirmaMesa, p_donus, p_yuzOlce;
float sdf(vec3 p) { float cs = 30.0; vec2 id = floor(p.xy / cs); float d = 1e5;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 cid = id + vec2(i, j); vec2 c = (cid + 0.5) * cs; if (cardA(c) < 0.3) continue; vec2 h = hash2(cid) - 0.5; vec3 off = vec3(h * p_ayirmaMesa * 0.5, (hash1(cid + 3.0) - 0.3) * p_ayirmaMesa);
    vec3 q = p - vec3(c, 0.0) - off; float a = radians(p_donus) * (h.x * 2.0); q.xz = mat2(cos(a), -sin(a), sin(a), cos(a)) * q.xz; vec3 b = vec3(cs * 0.5 * p_yuzOlce / 100.0, cs * 0.5 * p_yuzOlce / 100.0, 5.0); vec3 dd = abs(q) - b; d = min(d, length(max(dd, 0.0)) + min(max(dd.x, max(dd.y, dd.z)), 0.0)); }
  return d; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== facethick
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_derinlik, p_aralik;
float sdf(vec3 p) { float cs = 24.0; vec2 id = floor(p.xy / cs); vec2 c = (id + 0.5) * cs; float on = cardA(c); vec3 q = p - vec3(c, 0.0); float gap = cs * 0.5 * (1.0 - p_aralik / 100.0); float hz = max(abs(p_derinlik), 1.0) * (0.5 + 0.5 * on);
  vec3 dd = abs(q) - vec3(gap, gap, hz * 0.5); float d = length(max(dd, 0.0)) + min(max(dd.x, max(dd.y, dd.z)), 0.0); return on > 0.3 ? d : max(d, cs * 0.5); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== mirror3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_eksen, p_duzlemOfse;
vec3 fold(vec3 p) { int a = int(p_eksen + 0.5); if (a == 0 || a == 3) p.x = abs(p.x - p_duzlemOfse) + p_duzlemOfse; if (a == 1) p.y = abs(p.y - p_duzlemOfse) + p_duzlemOfse; if (a == 2) p.z = abs(p.z - p_duzlemOfse) + p_duzlemOfse; return p; }
float sdf(vec3 p) { return cardD(fold(p) - vec3(p_eksen > 1.5 && p_eksen < 2.5 ? 0.0 : 0.0, 0.0, p_eksen > 1.5 && p_eksen < 2.5 ? 10.0 : 0.0), 10.0); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(fold(p), n); }
void main() { o = render3d(vec3(0.0)); }
//== spherify
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_hedefSeki, p_guc, p_yaricap;
float tgt(vec3 p) { float R = max(p_yaricap, 1.0); if (p_hedefSeki < 0.5) return length(p) - R; if (p_hedefSeki < 1.5) return max(length(p.xz) - R, abs(p.y) - R); vec3 d = abs(p) - R; return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0); }
float sdf(vec3 p) { float k = p_guc / 100.0; return mix(cardD(p, 14.0), tgt(p), k) * (1.0 - 0.3 * k); }
vec4 surf(vec3 p, vec3 n) { vec2 uv = p_guc > 50.0 ? vec2(atan(p.x, p.z) / TAU + 0.5, 0.5 - asin(clamp(p.y / max(length(p), 1e-3), -1.0, 1.0)) / PI) : vec2(p.x, -p.y) / boxU() + 0.5; vec4 c = layerAt(clamp(uv, 0.0, 1.0)); return vec4(c.a > 0.0 ? c.rgb : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== twist3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_eksen, p_burguAcis, p_etkiAral;
vec3 tw(vec3 p) { int a = int(p_eksen + 0.5); float ext = (a == 0 ? boxU().x : a == 1 ? boxU().y : 40.0) * 0.5 * p_etkiAral / 100.0; float coord = a == 0 ? p.x : a == 1 ? p.y : p.z; float ang = radians(p_burguAcis) * clamp(coord / max(ext, 1.0), -1.0, 1.0) * 0.5; mat2 m = mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
  if (a == 0) p.yz = m * p.yz; else if (a == 1) p.xz = m * p.xz; else p.xy = m * p.xy; return p; }
float sdf(vec3 p) { return cardD(tw(p), 16.0) * 0.5; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(tw(p), n); }
void main() { o = render3d(vec3(0.0)); }
//== taper3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_eksen, p_merkez;
vec3 tp(vec3 p) { int a = int(p_eksen + 0.5); float ext = (a == 0 ? boxU().x : boxU().y) * 0.5; float coord = a == 0 ? p.x : a == 1 ? p.y : p.z * 4.0; float k = mix(0.4, 1.4, clamp(coord / max(ext, 1.0) * 0.5 + p_merkez / 100.0, 0.0, 1.0));
  if (a == 0) p.yz /= k; else if (a == 1) p.xz /= k; else p.xy /= k; return p; }
float sdf(vec3 p) { return cardD(tp(p), 16.0) * 0.5; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(tp(p), n); }
void main() { o = render3d(vec3(0.0)); }
//== buildorder
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_ilerleme, p_sira, p_tohum;
float ord(vec2 id, vec2 c) { return p_sira < 0.5 ? (id.y * 40.0 + id.x) / 1600.0 + 0.5 : p_sira < 1.5 ? (c.y / boxU().y + 0.5) : hash1(id + seedf(p_tohum)); }
float sdf(vec3 p) { float cs = 20.0; vec2 id = floor(p.xy / cs); float d = 1e5; float pr = p_ilerleme / 100.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 cid = id + vec2(i, j); vec2 c = (cid + 0.5) * cs; if (cardA(c) < 0.3) continue; float k = clamp((pr * 1.3 - ord(cid, c)) * 4.0, 0.0, 1.0); if (k <= 0.0) continue;
    vec3 q = p - vec3(c, (1.0 - k) * 120.0); vec3 dd = abs(q) - vec3(cs * 0.48 * k, cs * 0.48 * k, 6.0); d = min(d, length(max(dd, 0.0)) + min(max(dd.x, max(dd.y, dd.z)), 0.0)); }
  return d; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
//== voxelize
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_voxelBoyu, p_yogunluk, p_iciDold;
float sdf(vec3 p) { float V = max(p_voxelBoyu, 1.0); vec3 id = floor(p / V); vec3 c = (id + 0.5) * V; float on = step(0.5, cardA(c.xy)) * step(abs(c.z), 12.0) * step(hash1(id.xy + id.z * 7.0), p_yogunluk / 100.0 + 0.001);
  if (p_iciDold < 0.5) on *= 1.0 - step(0.5, cardA(c.xy + vec2(V, 0.0)) * cardA(c.xy - vec2(V, 0.0)) * cardA(c.xy + vec2(0.0, V)) * cardA(c.xy - vec2(0.0, V)) * step(abs(c.z), 12.0 - V));
  vec3 dd = abs(p - c) - V * 0.45; float d = length(max(dd, 0.0)) + min(max(dd.x, max(dd.y, dd.z)), 0.0); return on > 0.5 ? d : max(V * 0.5, cardD(p, 24.0)); }
vec4 surf(vec3 p, vec3 n) { float V = max(p_voxelBoyu, 1.0); vec3 c = (floor(p / V) + 0.5) * V; return cardSurf(vec3(c.xy, 0.0), vec3(0.0, 0.0, 1.0)) * vec4(vec3(0.8 + 0.2 * abs(n.z)), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== ocean3d
INCLUDE(_3d)
uniform float p_dalgaOlce, p_ruzgar, p_kopukEsig, p_zamanHizi;
float wave(vec2 x) { float t = u_t * p_zamanHizi / 100.0; float h = 0.0; float a = p_dalgaOlce * 0.12; vec2 d = vec2(1.0, 0.3);
  for (int i = 0; i < 5; i++) { float k = 0.02 * pow(1.8, float(i)); d = rot2(37.0) * d; h += sin(dot(x, d) * k + t * sqrt(9.8 * k) * 3.0) * a / pow(1.9, float(i)); } return h * (0.5 + p_ruzgar / 30.0); }
float sdf(vec3 p) { vec2 B = boxU() * 0.5; float plane = p.y - wave(p.xz) + B.y * 0.2; float box = max(abs(p.x) - B.x, abs(p.z) - B.x); return max(plane * 0.6, box); }
vec4 surf(vec3 p, vec3 n) { float h = wave(p.xz); float foam = smoothstep(p_kopukEsig / 100.0, 1.0, h / max(p_dalgaOlce * 0.12, 1.0) * 0.8 + 0.2); vec2 b = vec2(p.x / boxU().x + 0.5, p.z / boxU().x + 0.5); vec4 c = layerAt(fract(b));
  vec3 col = mix(vec3(0.02, 0.2, 0.35), c.a > 0.0 ? c.rgb : vec3(0.05, 0.3, 0.5), 0.25); return vec4(mix(col, vec3(0.95), foam), 1.0); }
void main() { o = render3d(vec3(0.0)); }
//== depthclip3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_yakinSini, p_uzakSini, p_gecis;
float sdf(vec3 p) { return cardD(p, 16.0); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { vec4 c = render3d(vec3(0.0)); float z = (p_kameraUzak > 0.0 ? p_kameraUzak : 800.0); float near = smoothstep(p_yakinSini - p_gecis * 0.5 - 1e-3, p_yakinSini + p_gecis * 0.5 + 1e-3, z); float far = 1.0 - smoothstep(p_uzakSini - p_gecis * 0.5 - 1e-3, p_uzakSini + p_gecis * 0.5 + 1e-3, z);
  o = c * near * far; }
