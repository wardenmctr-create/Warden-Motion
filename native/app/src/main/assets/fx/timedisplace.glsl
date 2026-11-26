// timedisplace
INCLUDE(_hist)
uniform sampler2D s_haritaKatm; uniform float p_haritaKatmOn, p_harita, p_maksimumZama, p_ornekSayi, p_yumusatm, p_zamanSini, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 2.0) { o = s; return; } vec2 b = clamp(boxUV(here()), 0.0, 1.0); float m;
  if (p_harita < 0.5) m = b.y; else if (p_harita < 1.5) m = b.x; else if (p_harita < 2.5 || p_haritaKatmOn < 0.5) m = luma(unpre(s)); else { vec4 q = texture(s_haritaKatm, v_uv); m = luma(unpre(q)) * q.a; }
  if (p_ters > 0.5) m = 1.0 - m; float k = clamp(m, 0.0, 1.0) * (n - 1.0); float f = fract(k); float sm = p_yumusatm / 100.0;
  float w = sm < 0.01 ? step(0.5, f) : smoothstep(0.5 - sm * 0.5, 0.5 + sm * 0.5, f);
  o = mix(hist(floor(k), v_uv), hist(min(floor(k) + 1.0, n - 1.0), v_uv), w); }
