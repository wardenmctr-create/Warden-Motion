// clahe
uniform float p_bolgeSayi, p_kontrastSini, p_karisim;
float rankIn(vec2 tile, float L, float N) { vec2 cs = boxU() / N; vec2 o2 = tile * cs - boxU() * 0.5; float below = 0.0; float lim = p_kontrastSini / 64.0 * 4.0; float clipped = 0.0;
  for (int j = 0; j < 8; j++) for (int i = 0; i < 8; i++) { vec2 q = o2 + (vec2(i, j) + 0.5) / 8.0 * cs; float l = luma(unpre(texU(q))); below += step(l, L); }
  float cdf = below / 64.0; return mix(L, cdf, clamp(p_kontrastSini / 4.0, 0.15, 1.0)); }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); float L = luma(c); float N = max(floor(p_bolgeSayi), 1.0);
  vec2 g = boxUV(here()) * N - 0.5; vec2 t0 = clamp(floor(g), vec2(0.0), vec2(N - 1.0)); vec2 t1 = clamp(t0 + 1.0, vec2(0.0), vec2(N - 1.0)); vec2 f = clamp(g - t0, 0.0, 1.0);
  float r = mix(mix(rankIn(t0, L, N), rankIn(vec2(t1.x, t0.y), L, N), f.x), mix(rankIn(vec2(t0.x, t1.y), L, N), rankIn(t1, L, N), f.x), f.y);
  float nl = mix(L, r, p_karisim / 100.0); o = pre(clamp(c * (nl / max(L, 1e-3)), 0.0, 1.0), s.a); }
