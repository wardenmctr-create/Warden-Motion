// ominodiff
GRADIENT(palet)
uniform float p_hataYayi, p_pikselBoyu, p_renkKaym, p_taramaYonu, p_tohum, p_zamanaBagl;
void main() {
  vec4 s = texture(u_tex, v_uv); float ps = max(p_pikselBoyu * u_s, 1.0); vec2 g = floor(here() / ps); vec4 x = texPx((g + 0.5) * ps); if (x.a <= 0.0) { o = x; return; }
  vec3 c = unpre(x); float tk = p_zamanaBagl > 0.5 ? floor(u_t * 12.0) : 0.0;
  float bayer = hash1(g + seedf(p_tohum) + tk) - 0.5; c += bayer * p_hataYayi / 100.0 * 0.35;
  c.r += p_renkKaym / 100.0 * 0.2 * sin((p_taramaYonu < 0.5 ? g.y : g.x) * 0.5);
  int n = paln_palet(); float best = 1e9; vec3 bc = c;
  for (int i = 0; i < 8; i++) { if (i >= n) break; vec3 p = palc_palet(i); float d = distance(c, p); if (d < best) { best = d; bc = p; } }
  o = pre(bc, x.a);
}
