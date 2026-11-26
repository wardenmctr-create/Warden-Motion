// fog
uniform vec3 c_renk; uniform float p_yogunluk, p_olcek, p_hiz, p_yon, p_yuksekli, p_yumusakl, p_tohum, p_alfayaKirp;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 dir = vec2(cos(radians(p_yon)), sin(radians(p_yon)));
  vec2 p = q / max(p_olcek, 1.0) + seedf(p_tohum) - dir * u_t * p_hiz / max(p_olcek, 1.0); float n = fbm(p, 4.0) * 0.5 + 0.5; n = fbm(p + n * 0.8, 3.0) * 0.5 + 0.5;
  float hgt = clamp(boxUV(here()).y, 0.0, 1.0); float hm = smoothstep(1.0 - p_yuksekli / 100.0 - p_yumusakl / 200.0, 1.0 - p_yuksekli / 100.0 + p_yumusakl / 200.0 + 0.01, hgt);
  float d = clamp(smoothstep(0.3, 0.8, n) * hm * p_yogunluk / 100.0 * 1.6, 0.0, 1.0); vec4 f = vec4(c_renk, 1.0) * d; if (p_alfayaKirp > 0.5) f *= s.a; o = overPre(f, s); }
