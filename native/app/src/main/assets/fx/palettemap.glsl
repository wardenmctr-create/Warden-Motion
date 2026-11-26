// palettemap
GRADIENT(palet)
uniform float p_eslemeYont, p_dagitim, p_paletDisiRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); c += (hash1(floor(here())) - 0.5) * p_dagitim / 100.0 * 0.25;
  int n = paln_palet(); float best = 1e9; vec3 bc = c;
  for (int i = 0; i < 8; i++) { if (i >= n) break; vec3 p = palc_palet(i);
    float d = p_eslemeYont < 0.5 ? distance(c, p) : p_eslemeYont < 1.5 ? length((c - p) * vec3(0.299, 0.587, 0.114) * 3.0) : abs(luma(c) - luma(p));
    if (d < best) { best = d; bc = p; } }
  if (p_paletDisiRenk > 0.5 && best > 0.35) bc = c;
  o = pre(bc, s.a);
}
