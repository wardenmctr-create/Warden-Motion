// Warden Motion efekt motoru: ortak başlık (GLSL ES 3.00). Telefon (OpenGL ES 3.0) ve önizleme üretici (WebGL2) aynı dosyayı kullanır.
// Dokular önceden çarpılmış alfalıdır (premultiplied). Koordinatlar: v_uv 0..1 (ara resim), piksel = v_uv * u_res.
precision highp float;
precision highp int;
uniform sampler2D u_tex;   // katmanın kendisi (bu efektten önceki hâli)
uniform vec2 u_res;        // ara resim boyutu (px)
uniform vec4 u_box;        // katman kutusu ara resim içinde: x, y, genişlik, yükseklik (px)
uniform float u_t;         // katman başlangıcından beri geçen süre (sn)
uniform float u_s;         // katman biriminde 1 = kaç px
uniform float u_dur;       // katmanın süresi (sn)
in vec2 v_uv;
out vec4 o;

const float PI = 3.14159265359;
const float TAU = 6.28318530718;

// --- örnekleme ---
vec4 tex(vec2 uv) { return (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) ? vec4(0.0) : texture(u_tex, uv); }
vec4 texPx(vec2 px) { return tex(px / u_res); }
// Katman birimi (kutunun merkezine göre) <-> px
vec2 boxCenter() { return u_box.xy + u_box.zw * 0.5; }
vec2 toUnit(vec2 px) { return (px - boxCenter()) / u_s; }
vec2 fromUnit(vec2 u) { return u * u_s + boxCenter(); }
vec2 boxUV(vec2 px) { return (px - u_box.xy) / u_box.zw; } // kutuya göre 0..1

// --- renk ---
vec3 unpre(vec4 c) { return c.a > 0.0 ? c.rgb / c.a : vec3(0.0); }
vec4 pre(vec3 rgb, float a) { return vec4(rgb * a, a); }
float luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }
vec3 rgb2hsv(vec3 c) {
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
  float d = q.x - min(q.w, q.y); float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) { vec3 p = abs(fract(c.xxx + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0); return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y); }
vec3 hueRotate(vec3 c, float deg) { vec3 h = rgb2hsv(c); h.x = fract(h.x + deg / 360.0); return hsv2rgb(h); }

// --- gürültü ---
float hash1(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
vec2 hash2(vec2 p) { float n = hash1(p); return vec2(n, hash1(p + n + 17.0)); }
float vnoise(vec2 p) {
  vec2 i = floor(p), f = fract(p); vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash1(i), hash1(i + vec2(1, 0)), u.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), u.x), u.y);
}
vec2 grad2(vec2 i) { float a = hash1(i) * TAU; return vec2(cos(a), sin(a)); }
float pnoise(vec2 p) { // Perlin benzeri, -1..1
  vec2 i = floor(p), f = fract(p); vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
  float a = dot(grad2(i), f), b = dot(grad2(i + vec2(1, 0)), f - vec2(1, 0));
  float c = dot(grad2(i + vec2(0, 1)), f - vec2(0, 1)), d = dot(grad2(i + vec2(1, 1)), f - vec2(1, 1));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y) * 1.414;
}
float fbm(vec2 p, float oct) { // oct: ondalıklı ayrıntı
  float s = 0.0, a = 0.5, n = 0.0;
  for (int i = 0; i < 8; i++) { float w = clamp(oct + 1.0 - float(i), 0.0, 1.0); if (w <= 0.0) break; s += pnoise(p) * a * w; n += a * w; p = p * 2.03 + 17.1; a *= 0.5; }
  return n > 0.0 ? s / n : 0.0;
}

// --- yardımcılar ---
mat2 rot2(float deg) { float a = radians(deg), c = cos(a), s = sin(a); return mat2(c, s, -s, c); }
float sat(float x) { return clamp(x, 0.0, 1.0); }
// Üretici efektler: deseni katmanın dolu kısmına koy (karışım = mix 0..1)
vec4 overOpaque(vec4 src, vec3 col, float colA, float mixv) { vec3 base = unpre(src); vec3 rgb = mix(base, col, colA * mixv); return pre(rgb, src.a); }

// --- bükme yardımcıları ---
vec2 boxU() { return u_box.zw / u_s; }                 // kutu boyu (katman birimi)
vec2 boxPx(vec2 b) { return u_box.xy + b * u_box.zw; } // kutu 0..1 → px
vec2 here() { return v_uv * u_res; }                   // bu pikselin px konumu
// Kenar modu: 0 saydam, 1 ayna, 2 tekrar (sarmala), 3 uzat — kutuya göre
vec4 texEdge(vec2 px, float mode) {
  if (mode < 0.5) return texPx(px);
  vec2 b = boxUV(px);
  if (mode < 1.5) b = 1.0 - abs(1.0 - mod(b, 2.0)); else if (mode < 2.5) b = fract(b); else b = clamp(b, 0.0, 1.0);
  return texPx(boxPx(clamp(b, 0.0005, 0.9995)));
}
vec4 texU(vec2 u) { return texPx(fromUnit(u)); }       // katman biriminden örnekle
float seedf(float s) { return fract(sin(s * 12.9898 + 1.7) * 43758.5453) * 113.0; }
float triw(float a) { return 1.0 - 4.0 * abs(fract(a / TAU + 0.25) - 0.5); } // -1..1, sin ile aynı faz
float sqw(float a) { return clamp(sin(a) * 6.0, -1.0, 1.0); }
float wavef(float kind, float a) { return kind < 0.5 ? sin(a) : (kind < 1.5 ? triw(a) : sqw(a)); }
vec4 overPre(vec4 top, vec4 bot) { return top + bot * (1.0 - top.a); }
// Altıgen ızgara (sivri üst): xy = hücre merkezi, zw = hücre kimliği
vec4 hexGrid(vec2 p, float s) {
  vec2 r = vec2(1.0, 1.7320508); vec2 h = r * 0.5;
  vec2 a = mod(p / s, r) - h; vec2 b = mod(p / s - h, r) - h;
  vec2 g = dot(a, a) < dot(b, b) ? a : b;
  vec2 c = p / s - g;
  return vec4(c * s, floor(c * 2.0 + 0.5));
}
float hexDist(vec2 g) { g = abs(g); return max(dot(g, vec2(0.5, 0.8660254)), g.x); } // merkez 0, kenar 0.5 (s=1)
// Sabit kenar ağırlığı: 0 yok, 1 tümü, 2 sol, 3 sağ, 4 üst, 5 alt (kutuya göre 0..1)
float pinW(float mode, vec2 b) {
  if (mode < 0.5) return 1.0;
  if (mode < 1.5) return smoothstep(0.0, 0.15, min(min(b.x, 1.0 - b.x), min(b.y, 1.0 - b.y)));
  if (mode < 2.5) return clamp(b.x, 0.0, 1.0); if (mode < 3.5) return clamp(1.0 - b.x, 0.0, 1.0);
  if (mode < 4.5) return clamp(b.y, 0.0, 1.0); return clamp(1.0 - b.y, 0.0, 1.0);
}
// Renk geçişi ayarı: shader içinde "GRADIENT(anahtar)" satırı motor tarafından açılır → grad_anahtar(x), paln_anahtar(), palc_anahtar(i)

// --- renk yardımcıları ---
vec3 hsl2rgb(vec3 h) { vec3 r = clamp(abs(mod(h.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0); return h.z + h.y * (r - 0.5) * (1.0 - abs(2.0 * h.z - 1.0)); }
vec3 rgb2hsl(vec3 c) { float mx = max(c.r, max(c.g, c.b)), mn = min(c.r, min(c.g, c.b)); float l = (mx + mn) * 0.5; float d = mx - mn; if (d < 1e-5) return vec3(0.0, 0.0, l);
  float s = d / (1.0 - abs(2.0 * l - 1.0) + 1e-5); float h = mx == c.r ? mod((c.g - c.b) / d, 6.0) : mx == c.g ? (c.b - c.r) / d + 2.0 : (c.r - c.g) / d + 4.0; return vec3(h / 6.0, s, l); }
vec3 satAdj(vec3 c, float k) { float l = luma(c); return mix(vec3(l), c, k); }
vec3 conAdj(vec3 c, float k, float mid) { return (c - mid) * k + mid; }
vec3 screenB(vec3 a, vec3 b) { return 1.0 - (1.0 - a) * (1.0 - b); }
vec3 overlayB(vec3 a, vec3 b) { return mix(2.0 * a * b, 1.0 - 2.0 * (1.0 - a) * (1.0 - b), step(0.5, a)); }
vec3 softLightB(vec3 a, vec3 b) { return mix(2.0 * a * b + a * a * (1.0 - 2.0 * b), sqrt(a) * (2.0 * b - 1.0) + 2.0 * a * (1.0 - b), step(0.5, b)); }
// Karıştırma: 0 normal, 1 ekran, 2 çarp, 3 bindirme
vec3 blendMode(vec3 base, vec3 top, float m) { return m < 0.5 ? top : m < 1.5 ? screenB(base, top) : m < 2.5 ? base * top : overlayB(base, top); }
// Renk aralığı ağırlığı (0 tümü, 1 kırmızı, 2 sarı, 3 yeşil, 4 camgöbeği, 5 mavi, 6 mor)
float hueRange(vec3 c, float r) { if (r < 0.5) return 1.0; vec3 h = rgb2hsv(c); float target = (r - 1.0) / 6.0; float d = abs(fract(h.x - target + 0.5) - 0.5); return (1.0 - smoothstep(0.06, 0.13, d)) * smoothstep(0.05, 0.25, h.y); }
// Kelvin → RGB (yaklaşık)
vec3 kelvin(float k) { float t = k / 100.0; vec3 c;
  c.r = t <= 66.0 ? 1.0 : clamp(1.29293618606 * pow(t - 60.0, -0.1332047592), 0.0, 1.0);
  c.g = t <= 66.0 ? clamp(0.39008157876 * log(t) - 0.63184144378, 0.0, 1.0) : clamp(1.12989086089 * pow(t - 60.0, -0.0755148492), 0.0, 1.0);
  c.b = t >= 66.0 ? 1.0 : (t <= 19.0 ? 0.0 : clamp(0.54320678911 * log(t - 10.0) - 1.19625408914, 0.0, 1.0)); return c; }
vec3 srgb2lin(vec3 c) { return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c)); }
vec3 lin2srgb(vec3 c) { c = max(c, 0.0); return mix(c * 12.92, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, step(0.0031308, c)); }
// Katmanın ortalama/en düşük/en yüksek parlaklığı (kaba örnekleme)
void stats(out vec3 mn, out vec3 mx, out vec3 avg) { mn = vec3(1.0); mx = vec3(0.0); avg = vec3(0.0); float n = 0.0;
  for (int j = 0; j < 8; j++) for (int i = 0; i < 8; i++) { vec4 s = texPx(boxPx((vec2(float(i), float(j)) + 0.5) / 8.0)); if (s.a < 0.1) continue; vec3 c = s.rgb / s.a; mn = min(mn, c); mx = max(mx, c); avg += c; n += 1.0; }
  avg = n > 0.0 ? avg / n : vec3(0.5); if (n < 1.0) { mn = vec3(0.0); mx = vec3(1.0); } }
