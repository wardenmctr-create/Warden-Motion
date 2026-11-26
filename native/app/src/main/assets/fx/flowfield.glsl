// flowfield
uniform sampler2D s_vektorHari; uniform float p_vektorHariOn;
uniform float p_alanKayn, p_olcek, p_turbulan, p_tohum, p_sayi, p_hiz, p_izSure, p_kalinlik; uniform vec3 c_renk;
vec2 fieldAt(vec2 q) { float sd = seedf(p_tohum); if (p_alanKayn < 0.5) { float a = fbm01(q / max(p_olcek, 1.0) + sd, 2.0 + p_turbulan / 30.0) * TAU * 2.0; return vec2(cos(a), sin(a)); }
  if (p_alanKayn < 1.5) return normalize(q + 1e-3); if (p_alanKayn < 2.5) return normalize(vec2(-q.y, q.x) + q * 0.15 + 1e-3);
  if (p_vektorHariOn > 0.5) { vec2 v = unpre(texture(s_vektorHari, clamp(boxUV(fromUnit(q)), 0.0, 1.0))).rg * 2.0 - 1.0; return length(v) > 1e-3 ? normalize(v) : vec2(1.0, 0.0); } return vec2(1.0, 0.0); }
// Akış çizgileri: piksel, alan boyunca geriye izlenir; yol üzerinde rastgele "parçacık başları" taşınır
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float dens = clamp(p_sayi / 2000.0, 0.02, 1.0); float acc = 0.0; vec2 p = q; float L = max(p_izSure, 0.05) * p_hiz; float st = L / 16.0;
  for (int i = 0; i < 16; i++) { vec2 cell = floor(p / max(p_kalinlik * 3.0, 3.0)); float h = hash1(cell + seedf(p_tohum)); float ph = fract(h * 7.0 + u_t * p_hiz / max(L, 1.0) * 0.5);
    float head = step(1.0 - dens, h) * smoothstep(0.0, 1.0, 1.0 - abs(fract(float(i) / 16.0 + ph) - 0.5) * 2.0); acc = max(acc, head * (1.0 - float(i) / 16.0)); p -= fieldAt(p) * st; }
  o = overPre(vec4(c_renk, 1.0) * acc, s); }
