// seamlessfix
uniform float p_kenarSeri, p_eksen, p_dokuKoru, p_tekrarOniz;
// Döşenebilir doku: kenara yaklaştıkça görüntünün yarım tur kaydırılmış kopyası öne geçer (sarmal sürekli); doku koruma geçişi keskinleştirir; önizlemede 2×2 tekrar
vec4 img(vec2 b) { return texPx(boxPx(fract(b))); }
void main() { vec2 b = boxUV(here()); if (p_tekrarOniz > 0.5) b = fract(b * 2.0); vec2 e = vec2(p_kenarSeri * u_s) / u_box.zw; float sharp = mix(1.0, 3.0, p_dokuKoru / 100.0);
  float wx = p_eksen != 1.0 ? pow(1.0 - smoothstep(0.0, e.x, min(b.x, 1.0 - b.x)), sharp) : 0.0; float wy = p_eksen != 0.0 ? pow(1.0 - smoothstep(0.0, e.y, min(b.y, 1.0 - b.y)), sharp) : 0.0;
  vec4 c = img(b); c = mix(c, img(b + vec2(0.5, 0.0)), wx); vec4 cy = mix(img(b), img(b + vec2(0.0, 0.5)), wy); o = mix(c, cy, wy / max(wx + wy, 1e-4) * step(1e-4, wy)); }
