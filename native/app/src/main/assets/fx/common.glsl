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
