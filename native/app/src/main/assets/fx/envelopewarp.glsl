// envelopewarp
uniform sampler2D s_kaynakAg; uniform float p_kaynakAgOn, p_bagGucu;
void main() { vec2 b = boxUV(here()); if (p_kaynakAgOn < 0.5) { o = texture(u_tex, v_uv); return; } float L = 1.0, R = 0.0; for (int i = 0; i < 48; i++) { float x = (float(i) + 0.5) / 48.0; if (texture(s_kaynakAg, vec2(x, b.y)).a > 0.5) { L = min(L, x); R = max(R, x); } }
  if (R <= L) { o = vec4(0.0); return; } float u = (b.x - L) / max(R - L, 1e-3); if (u < 0.0 || u > 1.0) { o = mix(texture(u_tex, v_uv), vec4(0.0), p_bagGucu / 100.0); return; } vec2 src = vec2(mix(b.x, u, p_bagGucu / 100.0), b.y); o = texPx(boxPx(src)); }
