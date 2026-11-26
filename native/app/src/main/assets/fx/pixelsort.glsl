// pixelsort
uniform float p_yon, p_altEsik, p_ustEsik, p_maksimumIz, p_siralama, p_tersSira, p_tohum;
float key(vec4 x) { vec3 c = unpre(x); vec3 h = rgb2hsv(c); return p_siralama < 0.5 ? luma(c) : p_siralama < 1.5 ? h.x : h.y; }
void main() {
  vec4 s = texture(u_tex, v_uv); float a = radians(p_yon); vec2 d = vec2(cos(a), sin(a)); float L = p_maksimumIz * u_s * (0.4 + 0.6 * hash1(vec2(floor(dot(here(), vec2(-d.y, d.x)) / max(u_s, 1.0)), seedf(p_tohum))));
  vec4 best = s; float bk = p_tersSira > 0.5 ? 1e9 : -1e9; float lo = p_altEsik / 100.0, hi = p_ustEsik / 100.0;
  for (int i = 0; i <= 24; i++) { float t = float(i) / 24.0; vec4 x = texPx(here() - d * L * t); float k = key(x); if (k < lo || k > hi) break;
    if ((p_tersSira < 0.5 && k > bk) || (p_tersSira > 0.5 && k < bk)) { bk = k; best = x; } }
  float ks = key(s); o = (ks >= lo && ks <= hi) ? best : s;
}
